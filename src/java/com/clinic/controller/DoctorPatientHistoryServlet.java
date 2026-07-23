package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.List;

/**
 * Xem lịch sử khám của một bệnh nhân cụ thể (theo góc nhìn bác sĩ).
 *
 * GET /doctor/patient-history?patientId=X
 */
@WebServlet("/doctor/patient-history")
public class DoctorPatientHistoryServlet extends HttpServlet {

    private final MedicalRecordDAO dao = new MedicalRecordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        String patientIdStr = req.getParameter("patientId");
        if (patientIdStr == null || patientIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }

        int patientId;
        try { patientId = Integer.parseInt(patientIdStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "patientId không hợp lệ.");
            return;
        }

        // Lấy thông tin bệnh nhân
        String patientName = getPatientName(patientId);
        if (patientName == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bệnh nhân.");
            return;
        }

        // Kiểm tra xem bác sĩ có quyền xem lịch sử của bệnh nhân này không
        boolean hasAppointment = false;
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT 1 FROM appointments WHERE patient_id = ? AND doctor_id = ?")) {
            ps.setInt(1, patientId);
            ps.setInt(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    hasAppointment = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (!hasAppointment) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem thông tin bệnh nhân này.");
            return;
        }

        // Lịch sử tất cả hồ sơ bệnh án của bệnh nhân này (toàn hệ thống, không giới hạn bác sĩ)
        List<MedicalRecord> records = dao.getClinicalHistoryForDoctor(patientId, doctorId);

        req.setAttribute("patientName",  patientName);
        req.setAttribute("patientId",    patientId);
        req.setAttribute("records",      records);
        req.setAttribute("doctorName",   user.getFullName());

        req.getRequestDispatcher("/views/doctors/patient_history.jsp").forward(req, resp);
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

    private String getPatientName(int patientId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT full_name FROM patients WHERE id = ?")) {
            ps.setInt(1, patientId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("full_name");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}
