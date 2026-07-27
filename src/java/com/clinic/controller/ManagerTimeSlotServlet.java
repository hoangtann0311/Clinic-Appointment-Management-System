package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý Khung Giờ Khám (theo ca) cho Manager.
 *
 * <p>GET  → danh sách lịch đã duyệt (overview) hoặc danh sách bệnh nhân
 *           đã đặt trong 1 ca (detail).
 * <p>POST → xử lý các thao tác trên lịch.
 *
 * <p>URL Patterns:
 * <ul>
 *   <li>/manager/time-slots/</li>
 *   <li>/manager/time-slots</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/manager/time-slots/", "/manager/time-slots"})
public class ManagerTimeSlotServlet extends HttpServlet {

    private DoctorScheduleDAO scheduleDAO;

    @Override
    public void init() throws ServletException {
        scheduleDAO = new DoctorScheduleDAO();
    }

    // ═══════════════════════════════════════════════════════════
    //  GET
    // ═══════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String scheduleIdStr = req.getParameter("scheduleId");

        if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
            showOverview(req, resp);
        } else {
            try {
                int scheduleId = Integer.parseInt(scheduleIdStr);
                showDetail(req, resp, scheduleId);
            } catch (NumberFormatException e) {
                showOverview(req, resp);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    //  POST
    // ═══════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String scheduleIdStr = req.getParameter("scheduleId");
        String redirectUrl = req.getContextPath() + "/manager/time-slots/";

        if (scheduleIdStr != null) {
            resp.sendRedirect(redirectUrl + "?scheduleId=" + scheduleIdStr);
        } else {
            resp.sendRedirect(redirectUrl);
        }
    }

    // ═══════════════════════════════════════════════════════════
    //  OVERVIEW: danh sách lịch trực đã duyệt
    // ═══════════════════════════════════════════════════════════

    private void showOverview(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<DoctorSchedule> approvedSchedules = scheduleDAO.findAllApproved(0, 100);

        // slotCounts = số appointment đã đặt cho từng schedule
        Map<Integer, Integer> slotCounts = new HashMap<>();
        for (DoctorSchedule sched : approvedSchedules) {
            slotCounts.put(sched.getId(), scheduleDAO.countBookedBySchedule(sched.getId()));
        }

        req.setAttribute("overviewMode", true);
        req.setAttribute("approvedSchedules", approvedSchedules);
        req.setAttribute("slotCounts", slotCounts);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    // ═══════════════════════════════════════════════════════════
    //  DETAIL: danh sách BN đã đặt trong 1 ca
    // ═══════════════════════════════════════════════════════════

    private void showDetail(HttpServletRequest req, HttpServletResponse resp, int scheduleId)
            throws ServletException, IOException {

        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            resp.sendRedirect(req.getContextPath() + "/manager/time-slots/"
                    + "?error=" + java.net.URLEncoder.encode(
                    "Lịch làm việc #" + scheduleId + " không tồn tại.", "UTF-8"));
            return;
        }

        // Lấy danh sách appointment đã đặt cho schedule này
        List<Map<String, Object>> appointments = getAppointmentsForSchedule(scheduleId);
        int bookedCount = 0;
        for (Map<String, Object> appt : appointments) {
            String status = (String) appt.get("status");
            if (!"Cancelled".equalsIgnoreCase(status) && !"CANCELLED".equalsIgnoreCase(status)) {
                bookedCount++;
            }
        }

        boolean hasSlots = !appointments.isEmpty();

        req.setAttribute("overviewMode", false);
        req.setAttribute("schedule", schedule);
        req.setAttribute("hasSlots", hasSlots);
        req.setAttribute("appointments", appointments);
        req.setAttribute("totalSlots", appointments.size());
        req.setAttribute("bookedCount", bookedCount);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));
        req.setAttribute("warning", req.getParameter("warning"));

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    // ═══════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════

    /**
     * Lấy danh sách appointment cho 1 schedule (theo schedule_id).
     * Mỗi phần tử là Map chứa các field: id, patientName, timeLabel,
     * appointmentDate, status, createdAt, doctorName.
     */
    private List<Map<String, Object>> getAppointmentsForSchedule(int scheduleId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT a.id, a.appointment_date, a.time_slot, a.status, a.created_at, "
                   + "p.full_name AS patient_name, d.full_name AS doctor_name "
                   + "FROM appointments a "
                   + "LEFT JOIN patients p ON a.patient_id = p.id "
                   + "LEFT JOIN doctors d ON a.doctor_id = d.id "
                   + "WHERE a.schedule_id = ? "
                   + "ORDER BY a.time_slot ASC";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("patientName", rs.getString("patient_name"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("appointmentDate", rs.getDate("appointment_date"));
                    row.put("status", rs.getString("status"));

                    // time_slot: có thể là TIME hoặc String
                    try {
                        java.sql.Time t = rs.getTime("time_slot");
                        row.put("timeLabel", t != null ? t.toString().substring(0, 5) : "—");
                    } catch (Exception e) {
                        String ts = rs.getString("time_slot");
                        row.put("timeLabel", ts != null ? ts : "—");
                    }

                    row.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ManagerTimeSlotServlet] getAppointmentsForSchedule ERROR: " + e.getMessage());
        }
        return list;
    }
}
