package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;
import com.clinic.utils.EncryptionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Danh sách bệnh nhân từng khám với bác sĩ này.
 * GET /doctor/patients?keyword=...
 */
@WebServlet("/doctor/patients")
public class DoctorPatientListServlet extends HttpServlet {

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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String keyword = req.getParameter("keyword");
        boolean hasKw = keyword != null && !keyword.isBlank();

        // Lấy danh sách bệnh nhân đã từng có appointment với bác sĩ này
        String sql =
            "SELECT DISTINCT p.id, p.full_name, " +
            "  " + EncryptionUtil.decryptEmailSql("u.email") + " AS email, " +
            "  p.phone_number AS phone, " +
            "  (SELECT COUNT(*) FROM appointments a2 WHERE a2.patient_id = p.id AND a2.doctor_id = ?) AS total_visits, " +
            "  (SELECT MAX(a3.appointment_date) FROM appointments a3 WHERE a3.patient_id = p.id AND a3.doctor_id = ?) AS last_visit " +
            "FROM patients p " +
            "JOIN appointments a ON a.patient_id = p.id " +
            "LEFT JOIN users u ON p.user_id = u.id " +
            "WHERE a.doctor_id = ? " +
            (hasKw ? "AND (p.full_name LIKE ? OR p.phone_number LIKE ? OR " + EncryptionUtil.decryptEmailWhere("u.email") + " LIKE ?) " : "") +
            "ORDER BY last_visit DESC";

        List<PatientRow> patients = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setInt(2, doctorId);
            ps.setInt(3, doctorId);
            if (hasKw) {
                String lk = "%" + keyword.trim() + "%";
                ps.setString(4, lk);
                ps.setString(5, lk);
                ps.setString(6, lk);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PatientRow row = new PatientRow();
                row.id          = rs.getInt("id");
                row.fullName    = rs.getString("full_name");
                row.email       = rs.getString("email");
                row.phone       = rs.getString("phone");
                row.totalVisits = rs.getInt("total_visits");
                row.lastVisit   = rs.getString("last_visit");
                patients.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("patients",    patients);
        req.setAttribute("keyword",     keyword != null ? keyword : "");
        req.setAttribute("doctorName",  user.getFullName());
        req.getRequestDispatcher("/views/doctors/patient_list.jsp").forward(req, resp);
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

    /** DTO nội bộ để truyền sang JSP */
    public static class PatientRow {
        public int    id;
        public String fullName;
        public String email;
        public String phone;
        public int    totalVisits;
        public String lastVisit;

        public int    getId()          { return id; }
        public String getFullName()    { return fullName; }
        public String getEmail()       { return email; }
        public String getPhone()       { return phone; }
        public int    getTotalVisits() { return totalVisits; }
        public String getLastVisit()   { return lastVisit; }
    }
}