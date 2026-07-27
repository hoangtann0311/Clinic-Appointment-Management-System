package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.DoctorDAO;
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
        try {
            User user = (User) session.getAttribute("user");
            Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());

            String action = req.getParameter("action");
            if ("detail".equalsIgnoreCase(action) || "items".equalsIgnoreCase(action)) {
                String rxIdStr = req.getParameter("id");
                if (rxIdStr != null) {
                    try {
                        int rxId = Integer.parseInt(rxIdStr.trim());
                        com.clinic.dao.PrescriptionDAO prescriptionDAO = new com.clinic.dao.PrescriptionDAO();
                        com.clinic.model.Prescription p = prescriptionDAO.getById(rxId);
                        if (p != null) {
                            resp.setContentType("application/json;charset=UTF-8");
                            StringBuilder json = new StringBuilder("[");
                            if (p.getItems() != null) {
                                for (int i = 0; i < p.getItems().size(); i++) {
                                    com.clinic.model.PrescriptionItem item = p.getItems().get(i);
                                    if (i > 0) json.append(",");
                                    json.append("{")
                                        .append("\"medicineName\":\"").append(escapeJson(item.getMedicineName())).append("\",")
                                        .append("\"quantity\":").append(item.getQuantity()).append(",")
                                        .append("\"dosage\":\"").append(escapeJson(item.getDosage())).append("\"")
                                        .append("}");
                                }
                            }
                            json.append("]");
                            resp.getWriter().write(json.toString());
                            return;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            String keyword = req.getParameter("keyword");
            boolean hasKw = keyword != null && !keyword.isBlank();

            String statusFilter = req.getParameter("status");
            boolean hasStatus = statusFilter != null && !statusFilter.isBlank();

            String dateFromParam = req.getParameter("dateFrom");
            String dateToParam = req.getParameter("dateTo");
            boolean hasDateFrom = dateFromParam != null && !dateFromParam.isBlank();
            boolean hasDateTo = dateToParam != null && !dateToParam.isBlank();

            int page = 1;
            int pageSize = 10;
            String pageParam = req.getParameter("page");
            if (pageParam != null && !pageParam.isBlank()) {
                try { page = Integer.parseInt(pageParam.trim()); } catch (Exception ignored) {}
            }
            if (page < 1) page = 1;

            String countSql = "SELECT COUNT(*) FROM prescriptions p " +
                              "JOIN medical_records mr ON p.medical_record_id = mr.id " +
                              "JOIN appointments a ON mr.appointment_id = a.id " +
                              "JOIN patients pt ON a.patient_id = pt.id " +
                              "WHERE 1=1 " +
                              (doctorId != null ? "AND (a.doctor_id = ? OR a.doctor_id IS NULL) " : "") +
                              "AND EXISTS (SELECT 1 FROM prescription_items pi WHERE pi.prescription_id = p.id) " +
                              (hasKw ? "AND (pt.full_name LIKE ? OR p.prescription_code LIKE ?) " : "") +
                              (hasStatus ? "AND p.status = ? " : "") +
                              (hasDateFrom ? "AND a.appointment_date >= ? " : "") +
                              (hasDateTo ? "AND a.appointment_date <= ? " : "");
            int totalRecords = 0;
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(countSql)) {
                int pIdx = 1;
                if (doctorId != null) {
                    ps.setInt(pIdx++, doctorId);
                }
                if (hasKw) {
                    String lk = "%" + keyword.trim() + "%";
                    ps.setString(pIdx++, lk);
                    ps.setString(pIdx++, lk);
                }
                if (hasStatus) {
                    ps.setString(pIdx++, statusFilter.trim());
                }
                if (hasDateFrom) {
                    ps.setDate(pIdx++, java.sql.Date.valueOf(dateFromParam.trim()));
                }
                if (hasDateTo) {
                    ps.setDate(pIdx++, java.sql.Date.valueOf(dateToParam.trim()));
                }
                ResultSet rs = ps.executeQuery();
                if (rs.next()) totalRecords = rs.getInt(1);
            } catch (SQLException e) {
                e.printStackTrace();
            }

            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            if (page > totalPages && totalPages > 0) page = totalPages;
            int offset = (page - 1) * pageSize;

            String sql =
                "SELECT p.id, p.prescription_code, p.status, p.created_at, " +
                "       pt.full_name AS patient_name, pt.id AS patient_id, " +
                "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
                "       mr.id AS record_id, a.id AS appointment_id, mr.final_diagnosis, " +
                "       (SELECT COUNT(*) FROM prescription_items pi WHERE pi.prescription_id = p.id) AS item_count " +
                "FROM prescriptions p " +
                "JOIN medical_records mr ON p.medical_record_id = mr.id " +
                "JOIN appointments a ON mr.appointment_id = a.id " +
                "JOIN patients pt ON a.patient_id = pt.id " +
                "WHERE 1=1 " +
                (doctorId != null ? "AND (a.doctor_id = ? OR a.doctor_id IS NULL) " : "") +
                "AND EXISTS (SELECT 1 FROM prescription_items pi WHERE pi.prescription_id = p.id) " +
                (hasKw ? "AND (pt.full_name LIKE ? OR p.prescription_code LIKE ?) " : "") +
                (hasStatus ? "AND p.status = ? " : "") +
                (hasDateFrom ? "AND a.appointment_date >= ? " : "") +
                (hasDateTo ? "AND a.appointment_date <= ? " : "") +
                "ORDER BY p.created_at DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

            List<PrescriptionRow> rows = new ArrayList<>();
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                int paramIndex = 1;
                if (doctorId != null) {
                    ps.setInt(paramIndex++, doctorId);
                }
                if (hasKw) {
                    String lk = "%" + keyword.trim() + "%";
                    ps.setString(paramIndex++, lk);
                    ps.setString(paramIndex++, lk);
                }
                if (hasStatus) {
                    ps.setString(paramIndex++, statusFilter.trim());
                }
                if (hasDateFrom) {
                    ps.setDate(paramIndex++, java.sql.Date.valueOf(dateFromParam.trim()));
                }
                if (hasDateTo) {
                    ps.setDate(paramIndex++, java.sql.Date.valueOf(dateToParam.trim()));
                }
                ps.setInt(paramIndex++, offset);
                ps.setInt(paramIndex, pageSize);
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
                    row.appointmentId   = rs.getInt("appointment_id");
                    row.finalDiagnosis  = rs.getString("final_diagnosis");
                    row.itemCount       = rs.getInt("item_count");
                    rows.add(row);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            req.setAttribute("prescriptions", rows);
            req.setAttribute("keyword",       keyword != null ? keyword : "");
            req.setAttribute("statusFilter",  statusFilter != null ? statusFilter : "");
            req.setAttribute("dateFrom",      dateFromParam != null ? dateFromParam : "");
            req.setAttribute("dateTo",        dateToParam != null ? dateToParam : "");
            req.setAttribute("doctorName",    user.getFullName());
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("totalRecords",totalRecords);
            req.getRequestDispatcher("/views/doctors/prescription_list.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[DoctorPrescriptionListServlet] doGet ERROR: " + e.getMessage());
            e.printStackTrace();
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
                req.getRequestDispatcher("/views/doctors/prescription_list.jsp").forward(req, resp);
            }
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
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
        public int    appointmentId;
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
        public int    getAppointmentId()   { return appointmentId; }
        public String getFinalDiagnosis()  { return finalDiagnosis; }
        public int    getItemCount()       { return itemCount; }
    }
}
