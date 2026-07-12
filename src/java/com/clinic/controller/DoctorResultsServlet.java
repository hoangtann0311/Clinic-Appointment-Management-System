package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Bác sĩ xem kết quả xét nghiệm và siêu âm của 1 hồ sơ bệnh án.
 *
 * GET /doctor/results?recordId=X
 */
@WebServlet("/doctor/results")
public class DoctorResultsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Auth
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        User user = (User) session.getAttribute("user");

        // recordId
        String ridStr = req.getParameter("recordId");
        if (ridStr == null || ridStr.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu recordId."); return;
        }
        int recordId;
        try { recordId = Integer.parseInt(ridStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "recordId không hợp lệ."); return;
        }

        // Load kết quả xét nghiệm
        List<Map<String,Object>> labResults    = loadLabResults(recordId);
        // Load kết quả siêu âm
        List<Map<String,Object>> ultrasoundResults = loadUltrasoundResults(recordId);
        // Load thông tin hồ sơ (tên BN, ngày khám)
        Map<String,String> recordInfo = loadRecordInfo(recordId);

        req.setAttribute("recordId",          recordId);
        req.setAttribute("recordInfo",         recordInfo);
        req.setAttribute("labResults",         labResults);
        req.setAttribute("ultrasoundResults",  ultrasoundResults);
        req.setAttribute("doctorName",         user.getFullName());
        req.getRequestDispatcher("/views/doctors/doctor_results.jsp").forward(req, resp);
    }

    // ── Kết quả xét nghiệm ──────────────────────────────────────────────────
    private List<Map<String,Object>> loadLabResults(int recordId) {
        String sql =
            "SELECT to2.id AS order_id, s.service_name, s.service_code, " +
            "       to2.status, to2.created_at AS ordered_at, " +
            "       lr.result_details, lr.image_url, lr.updated_at AS result_at, " +
            "       u.full_name AS tech_name " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN service_categories sc ON sc.id = s.category_id " +
            "LEFT JOIN lab_results lr ON lr.test_order_id = to2.id " +
            "LEFT JOIN users u ON u.id = lr.lab_technician_id " +
            "WHERE to2.medical_record_id = ? " +
            "  AND (sc.category_name NOT LIKE N'%siêu âm%' " +
            "       AND sc.category_name NOT LIKE N'%ultrasound%' " +
            "       AND ISNULL(s.required_room_type,'') NOT LIKE N'%ultrasound%') " +
            "ORDER BY to2.created_at";
        return queryToMapList(sql, recordId);
    }

    // ── Kết quả siêu âm ─────────────────────────────────────────────────────
    private List<Map<String,Object>> loadUltrasoundResults(int recordId) {
        String sql =
            "SELECT ur.id, ur.raw_image_url, ur.ai_processed_image_url, " +
            "       ur.ai_suggested_label, ur.ai_confidence_score, " +
            "       u.full_name AS sonographer_name, " +
            "       s.service_name, " +
            "       to2.id AS order_id, to2.status AS order_status, to2.created_at AS ordered_at " +
            "FROM ultrasound_results ur " +
            "JOIN test_orders to2 ON to2.medical_record_id = ur.medical_record_id " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN service_categories sc ON sc.id = s.category_id " +
            "LEFT JOIN users u ON u.id = ur.sonographer_id " +
            "WHERE ur.medical_record_id = ? " +
            "  AND (sc.category_name LIKE N'%siêu âm%' " +
            "       OR sc.category_name LIKE N'%ultrasound%' " +
            "       OR ISNULL(s.required_room_type,'') LIKE N'%ultrasound%') " +
            "ORDER BY ur.id";

        // Nếu không có kết quả siêu âm qua test_orders, thử lấy trực tiếp từ ultrasound_results
        List<Map<String,Object>> list = queryToMapList(sql, recordId);
        if (list.isEmpty()) {
            String fallback =
                "SELECT ur.id, ur.raw_image_url, ur.ai_processed_image_url, " +
                "       ur.ai_suggested_label, ur.ai_confidence_score, " +
                "       u.full_name AS sonographer_name, " +
                "       NULL AS service_name, NULL AS order_id, " +
                "       NULL AS order_status, NULL AS ordered_at " +
                "FROM ultrasound_results ur " +
                "LEFT JOIN users u ON u.id = ur.sonographer_id " +
                "WHERE ur.medical_record_id = ? " +
                "ORDER BY ur.id";
            list = queryToMapList(fallback, recordId);
        }
        return list;
    }

    // ── Thông tin hồ sơ bệnh án ─────────────────────────────────────────────
    private Map<String,String> loadRecordInfo(int recordId) {
        String sql =
            "SELECT u.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       mr.final_diagnosis " +
            "FROM medical_records mr " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN users u ON u.id = a.patient_id " +
            "WHERE mr.id = ?";
        Map<String,String> info = new LinkedHashMap<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                info.put("patientName",     rs.getString("patient_name"));
                info.put("appointmentDate", rs.getString("appointment_date"));
                info.put("finalDiagnosis",  rs.getString("final_diagnosis"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return info;
    }

    // ── Helper: query → List<Map> ────────────────────────────────────────────
    private List<Map<String,Object>> queryToMapList(String sql, int param) {
        List<Map<String,Object>> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, param);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) {
                    row.put(meta.getColumnLabel(i), rs.getObject(i));
                }
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}