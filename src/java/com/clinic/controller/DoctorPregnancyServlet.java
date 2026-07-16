package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.PregnancyDAO;
import com.clinic.model.Pregnancy;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;

/**
 * Xem chi tiết một thai kỳ (timeline các lần khám) và tạo thai kỳ mới,
 * gắn vào một appointment cụ thể.
 *
 * GET  /doctor/pregnancy?id=X                     → xem chi tiết thai kỳ X
 * GET  /doctor/pregnancy?apptId=X                  → tạo thai kỳ mới cho appointment X
 *                                                     (nếu appointment đã có pregnancy_id thì
 *                                                      chuyển thẳng sang xem chi tiết)
 * POST /doctor/pregnancy  (action=create)           → tạo thai kỳ mới + gắn vào apptId
 * POST /doctor/pregnancy  (action=update, id=X)      → cập nhật thông tin thai kỳ
 */
@WebServlet("/doctor/pregnancy")
public class DoctorPregnancyServlet extends HttpServlet {

    private final PregnancyDAO pregnancyDAO = new PregnancyDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req, resp);
        if (user == null) return;
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        String idStr     = req.getParameter("id");
        String apptIdStr = req.getParameter("apptId");

        if (idStr != null && !idStr.isBlank()) {
            showDetail(req, resp, user, doctorId, idStr);
            return;
        }

        if (apptIdStr != null && !apptIdStr.isBlank()) {
            showCreateForApptOrRedirect(req, resp, user, doctorId, apptIdStr);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req, resp);
        if (user == null) return;
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        String action = req.getParameter("action");
        if ("create".equals(action)) {
            handleCreate(req, resp, doctorId);
        } else if ("update".equals(action)) {
            handleUpdate(req, resp, doctorId);
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "action không hợp lệ.");
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // GET handlers
    // ────────────────────────────────────────────────────────────────────────

    private void showDetail(HttpServletRequest req, HttpServletResponse resp,
                             User user, int doctorId, String idStr)
            throws ServletException, IOException {
        int pregnancyId;
        try { pregnancyId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "id không hợp lệ.");
            return;
        }

        if (!pregnancyDAO.pregnancyVisibleToDoctor(pregnancyId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem thai kỳ này.");
            return;
        }

        Pregnancy pregnancy = pregnancyDAO.getById(pregnancyId);
        if (pregnancy == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thai kỳ.");
            return;
        }

        List<java.util.Map<String, Object>> timeline =
                pregnancyDAO.getTimelineByPregnancyId(pregnancyId);

        req.setAttribute("pregnancy",  pregnancy);
        req.setAttribute("timeline",   timeline);
        req.setAttribute("doctorName", user.getFullName());
        req.getRequestDispatcher("/views/doctors/pregnancy_detail.jsp").forward(req, resp);
    }

    private void showCreateForApptOrRedirect(HttpServletRequest req, HttpServletResponse resp,
                                              User user, int doctorId, String apptIdStr)
            throws ServletException, IOException {
        int apptId;
        try { apptId = Integer.parseInt(apptIdStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "apptId không hợp lệ.");
            return;
        }

        AppointmentInfo info = loadAppointmentInfo(apptId);
        if (info == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch hẹn.");
            return;
        }
        if (info.doctorId != doctorId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Lịch hẹn này không thuộc về bạn.");
            return;
        }

        // Nếu appointment đã gắn sẵn 1 thai kỳ thì chuyển thẳng sang trang chi tiết
        if (info.pregnancyId != null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/pregnancy?id=" + info.pregnancyId);
            return;
        }

        // Gợi ý: nếu bệnh nhân đã có thai kỳ "active" khác (chưa sinh), hiện gợi ý gắn vào đó
        Pregnancy suggestion = pregnancyDAO.getActiveByPatientId(info.patientId);

        req.setAttribute("apptId",          apptId);
        req.setAttribute("patientId",       info.patientId);
        req.setAttribute("patientName",     info.patientName);
        req.setAttribute("lastMenstrualPeriod", info.lastMenstrualPeriod);
        req.setAttribute("suggestion",      suggestion);
        req.setAttribute("doctorName",      user.getFullName());
        req.getRequestDispatcher("/views/doctors/pregnancy_create.jsp").forward(req, resp);
    }

    // ────────────────────────────────────────────────────────────────────────
    // POST handlers
    // ────────────────────────────────────────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, int doctorId)
            throws ServletException, IOException {

        String apptIdStr = req.getParameter("apptId");
        String linkExistingIdStr = req.getParameter("linkExistingId");

        int apptId;
        try { apptId = Integer.parseInt(apptIdStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "apptId không hợp lệ.");
            return;
        }

        AppointmentInfo info = loadAppointmentInfo(apptId);
        if (info == null || info.doctorId != doctorId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int pregnancyId;

        // Trường hợp 1: bác sĩ chọn gắn vào thai kỳ "active" đã gợi ý sẵn
        if (linkExistingIdStr != null && !linkExistingIdStr.isBlank()) {
            try { pregnancyId = Integer.parseInt(linkExistingIdStr); }
            catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "linkExistingId không hợp lệ.");
                return;
            }
            if (!pregnancyDAO.pregnancyVisibleToDoctor(pregnancyId, doctorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        } else {
            // Trường hợp 2: tạo thai kỳ mới
            Pregnancy p = new Pregnancy();
            p.setPatientId(info.patientId);

            String startDateStr = req.getParameter("startDate");
            LocalDate startDate = parseDateOrNull(startDateStr);
            if (startDate == null) startDate = info.lastMenstrualPeriod; // fallback: dùng LMP của lịch hẹn
            p.setStartDate(startDate);

            LocalDate edd = parseDateOrNull(req.getParameter("estimatedDueDate"));
            if (edd == null && startDate != null) edd = startDate.plusDays(280); // ước tính 40 tuần
            p.setEstimatedDueDate(edd);

            String fetusCountStr = req.getParameter("fetusCount");
            if (fetusCountStr != null && !fetusCountStr.isBlank()) {
                try { p.setFetusCount(Integer.parseInt(fetusCountStr)); }
                catch (NumberFormatException ignored) { p.setFetusCount(1); }
            } else {
                p.setFetusCount(1);
            }

            p.setPregnancyStatus("active");
            p.setNotes(req.getParameter("notes"));

            pregnancyId = pregnancyDAO.create(p);
            if (pregnancyId <= 0) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Tạo thai kỳ thất bại.");
                return;
            }
        }

        pregnancyDAO.linkAppointment(apptId, pregnancyId);

        resp.sendRedirect(req.getContextPath() + "/doctor/pregnancy?id=" + pregnancyId);
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, int doctorId)
            throws ServletException, IOException {

        String idStr = req.getParameter("id");
        int pregnancyId;
        try { pregnancyId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "id không hợp lệ.");
            return;
        }
        if (!pregnancyDAO.pregnancyVisibleToDoctor(pregnancyId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Pregnancy p = pregnancyDAO.getById(pregnancyId);
        if (p == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        LocalDate edd = parseDateOrNull(req.getParameter("estimatedDueDate"));
        if (edd != null) p.setEstimatedDueDate(edd);

        LocalDate add = parseDateOrNull(req.getParameter("actualDeliveryDate"));
        p.setActualDeliveryDate(add);

        String status = req.getParameter("pregnancyStatus");
        if (status != null && !status.isBlank()) p.setPregnancyStatus(status);

        String fetusCountStr = req.getParameter("fetusCount");
        if (fetusCountStr != null && !fetusCountStr.isBlank()) {
            try { p.setFetusCount(Integer.parseInt(fetusCountStr)); } catch (NumberFormatException ignored) {}
        }

        p.setNotes(req.getParameter("notes"));

        pregnancyDAO.update(p);
        resp.sendRedirect(req.getContextPath() + "/doctor/pregnancy?id=" + pregnancyId);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private User currentUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private Integer getDoctorId(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM doctors WHERE user_id = ?")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private LocalDate parseDateOrNull(String s) {
        if (s == null || s.isBlank()) return null;
        try { return LocalDate.parse(s); } catch (Exception e) { return null; }
    }

    private static class AppointmentInfo {
        int patientId;
        int doctorId;
        String patientName;
        Integer pregnancyId;
        LocalDate lastMenstrualPeriod;
    }

    private AppointmentInfo loadAppointmentInfo(int apptId) {
        String sql =
            "SELECT a.patient_id, a.doctor_id, a.pregnancy_id, a.last_menstrual_period, pt.full_name " +
            "FROM appointments a JOIN patients pt ON a.patient_id = pt.id " +
            "WHERE a.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, apptId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                AppointmentInfo info = new AppointmentInfo();
                info.patientId = rs.getInt("patient_id");
                info.doctorId  = rs.getInt("doctor_id");
                int pid = rs.getInt("pregnancy_id");
                info.pregnancyId = rs.wasNull() ? null : pid;
                Date lmp = rs.getDate("last_menstrual_period");
                info.lastMenstrualPeriod = lmp != null ? lmp.toLocalDate() : null;
                info.patientName = rs.getString("full_name");
                return info;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}