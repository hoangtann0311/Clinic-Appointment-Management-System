package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Danh sách đơn thuốc bác sĩ đã kê.
 * GET /doctor/prescriptions-list?keyword=...
 */
@WebServlet("/doctor/prescriptions-list")
public class DoctorPrescriptionListServlet extends HttpServlet {

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

        String sql =
            "SELECT p.id, p.prescription_code, p.status, p.created_at, " +
            "       pt.full_name AS patient_name, pt.id AS patient_id, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       mr.id AS record_id, mr.final_diagnosis, " +
            "       (SELECT COUNT(*) FROM prescription_items pi WHERE pi.prescription_id = p.id) AS item_count " +
            "FROM prescriptions p " +
            "JOIN medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN appointments a ON mr.appointment_id = a.id " +
            "JOIN patients pt ON a.patient_id = pt.id " +
            "WHERE a.doctor_id = ? " +
            (hasKw ? "AND (pt.full_name LIKE ? OR p.prescription_code LIKE ?) " : "") +
            "ORDER BY p.created_at DESC";

        List<PrescriptionRow> rows = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            if (hasKw) {
                String lk = "%" + keyword.trim() + "%";
                ps.setString(2, lk);
                ps.setString(3, lk);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PrescriptionRow row = new PrescriptionRow();
                row.id              = rs.getInt("id");
                row.code            = rs.getString("prescription_code");
                row.status          = rs.getString("status");
                row.createdAt       = rs.getString("created_at");
                row.patientName     = rs.getString("patient_name");
                row.patientId       = rs.getInt("patient_id");
                row.appointmentDate = rs.getString("appointment_date");
                row.recordId        = rs.getInt("record_id");
                row.finalDiagnosis  = rs.getString("final_diagnosis");
                row.itemCount       = rs.getInt("item_count");
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("prescriptions", rows);
        req.setAttribute("keyword",       keyword != null ? keyword : "");
        req.setAttribute("doctorName",    user.getFullName());
        req.getRequestDispatcher("/views/doctors/prescription_list.jsp").forward(req, resp);
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

    public static class PrescriptionRow {
        public int    id;
        public String code;
        public String status;
        public String createdAt;
        public String patientName;
        public int    patientId;
        public String appointmentDate;
        public int    recordId;
        public String finalDiagnosis;
        public int    itemCount;

        public int    getId()              { return id; }
        public String getCode()            { return code; }
        public String getStatus()          { return status; }
        public String getCreatedAt()       { return createdAt; }
        public String getPatientName()     { return patientName; }
        public int    getPatientId()       { return patientId; }
        public String getAppointmentDate() { return appointmentDate; }
        public int    getRecordId()        { return recordId; }
        public String getFinalDiagnosis()  { return finalDiagnosis; }
        public int    getItemCount()       { return itemCount; }
    }
}