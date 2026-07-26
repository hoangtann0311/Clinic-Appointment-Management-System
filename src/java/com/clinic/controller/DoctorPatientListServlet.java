package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.DoctorDAO;
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
        try {
            User user = (User) session.getAttribute("user");
            Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
            if (doctorId == null) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String keyword = req.getParameter("keyword");
            boolean hasKw = keyword != null && !keyword.isBlank();

            int page = 1;
            int pageSize = 10;
            String pageParam = req.getParameter("page");
            if (pageParam != null && !pageParam.isBlank()) {
                try { page = Integer.parseInt(pageParam.trim()); } catch (Exception ignored) {}
            }
            if (page < 1) page = 1;

            // Đếm tổng số bản ghi
            String countSql = "SELECT COUNT(DISTINCT p.id) FROM patients p " +
                              "JOIN appointments a ON a.patient_id = p.id " +
                              "LEFT JOIN users u ON p.user_id = u.id " +
                              "WHERE a.doctor_id = ? " +
                              (hasKw ? "AND (p.full_name LIKE ? OR p.phone_number LIKE ? OR " + EncryptionUtil.decryptEmailWhere("u.email") + " LIKE ?) " : "");
            int totalRecords = 0;
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, doctorId);
                if (hasKw) {
                    String lk = "%" + keyword.trim() + "%";
                    ps.setString(2, lk);
                    ps.setString(3, lk);
                    ps.setString(4, lk);
                }
                ResultSet rs = ps.executeQuery();
                if (rs.next()) totalRecords = rs.getInt(1);
            } catch (SQLException e) {
                e.printStackTrace();
            }

            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            if (page > totalPages && totalPages > 0) page = totalPages;
            int offset = (page - 1) * pageSize;

            // Lấy danh sách bệnh nhân đã từng có appointment với bác sĩ này
            String sql =
                "SELECT DISTINCT p.id, COALESCE(NULLIF(p.full_name,''), N'Người dùng') AS full_name, " +
                "  " + EncryptionUtil.decryptEmailSql("u.email") + " AS email, " +
                "  p.phone_number AS phone, " +
                "  (SELECT COUNT(*) FROM appointments a2 WHERE a2.patient_id = p.id AND a2.doctor_id = ?) AS total_visits, " +
                "  (SELECT MAX(a3.appointment_date) FROM appointments a3 WHERE a3.patient_id = p.id AND a3.doctor_id = ?) AS last_visit " +
                "FROM patients p " +
                "JOIN appointments a ON a.patient_id = p.id " +
                "LEFT JOIN users u ON p.user_id = u.id " +
                "WHERE a.doctor_id = ? " +
                (hasKw ? "AND (p.full_name LIKE ? OR p.phone_number LIKE ? OR " + EncryptionUtil.decryptEmailWhere("u.email") + " LIKE ?) " : "") +
                "ORDER BY last_visit DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

            List<PatientRow> patients = new ArrayList<>();
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, doctorId);
                ps.setInt(2, doctorId);
                ps.setInt(3, doctorId);
                int paramIndex = 4;
                if (hasKw) {
                    String lk = "%" + keyword.trim() + "%";
                    ps.setString(paramIndex++, lk);
                    ps.setString(paramIndex++, lk);
                    ps.setString(paramIndex++, lk);
                }
                ps.setInt(paramIndex++, offset);
                ps.setInt(paramIndex, pageSize);
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
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("totalRecords",totalRecords);
            req.getRequestDispatcher("/views/doctors/patient_list.jsp").forward(req, resp);
        } catch (Exception ex) {
            System.err.println("[DoctorPatientListServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            req.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/doctors/patient_list.jsp").forward(req, resp);
        }
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