package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.UltrasoundOrderDAO;
import com.clinic.model.UltrasoundWaitingPatient;

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
 * Bác sĩ xem kết quả siêu âm của một hồ sơ bệnh án.
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

        // IDOR Check
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        MedicalRecordDAO recordDAO = new MedicalRecordDAO();
        if (!recordDAO.recordBelongsToDoctor(recordId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập kết quả siêu âm của bệnh án này.");
            return;
        }

        // Load kết quả siêu âm
        List<Map<String,Object>> ultrasoundResults = loadUltrasoundResults(recordId);
        // Load thông tin hồ sơ (tên BN, ngày khám)
        Map<String,String> recordInfo = loadRecordInfo(recordId);

        req.setAttribute("recordId",          recordId);
        req.setAttribute("recordInfo",         recordInfo);
        req.setAttribute("ultrasoundResults",  ultrasoundResults);
        req.setAttribute("doctorName",         user.getFullName());
        req.getRequestDispatcher("/views/doctors/doctor_results.jsp").forward(req, resp);
    }

    /**
     * POST /doctor/results
     * Bác sĩ xác nhận kết quả phân tích AI siêu âm.
     * Params: orderId, doctorMessage, recordId (dùng để redirect sau khi xác nhận)
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Auth
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        User user = (User) session.getAttribute("user");
        // Kết luận lâm sàng là trách nhiệm của bác sĩ điều trị.
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Bác sĩ mới có quyền xác nhận kết quả siêu âm."); return;
        }

        // Nhận tham số
        String orderIdStr   = req.getParameter("orderId");
        String doctorMsg    = req.getParameter("doctorMessage");
        String recordIdStr  = req.getParameter("recordId");

        int recordId = -1;
        try { recordId = Integer.parseInt(recordIdStr); } catch (Exception ignored) {}

        if (orderIdStr == null || orderIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=invalidOrder"); return;
        }
        if (doctorMsg == null || doctorMsg.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=missingConclusion"); return;
        }

        int orderId;
        try { orderId = Integer.parseInt(orderIdStr); }
        catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=invalidOrder"); return;
        }

        // IDOR Check
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=noDoctorProfile");
            return;
        }

        MedicalRecordDAO recordDAO = new MedicalRecordDAO();
        if (!recordDAO.recordBelongsToDoctor(recordId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xác nhận kết quả siêu âm cho bệnh án này.");
            return;
        }

        UltrasoundWaitingPatient order = new UltrasoundOrderDAO().getById(orderId);
        if (order == null || order.getMedicalRecordId() != recordId) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=invalidOrderMapping");
            return;
        }

        // Thực hiện xác nhận
        UltrasoundOrderService orderService = new UltrasoundOrderService();
        boolean success = orderService.confirmUltrasoundResult(orderId, doctorMsg);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&success=confirmed#us-order-" + orderId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=confirmFailed&orderId=" + orderId);
        }
    }

    // ── Kết quả siêu âm ─────────────────────────────────────────────────────
    private List<Map<String,Object>> loadUltrasoundResults(int recordId) {
        // Query đúng bảng: test_orders → ultrasound_images (ảnh gốc) + ai_analysis_results (kết quả AI)
        String sql =
            "SELECT to2.id AS id, " +
            "       to2.id AS order_id, to2.status AS order_status, " +
            "       to2.created_at AS ordered_at, " +
            "       s.service_name, " +
            // Ảnh gốc từ ultrasound_images (lấy ảnh đầu tiên)
            "       ui.file_path AS raw_image_url, " +
            // Kết quả AI từ ai_analysis_results
            "       air.result_image AS ai_processed_image_url, " +
            "       air.message AS ai_suggested_label, " +
            "       air.confidence AS ai_confidence_score, " +
            // Sonographer (người upload ảnh)
            "       uploader.full_name AS sonographer_name " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN service_categories sc ON sc.id = s.category_id " +
            // Lấy ảnh đầu tiên đã upload
            "OUTER APPLY ( " +
            "    SELECT TOP 1 file_path " +
            "    FROM ultrasound_images " +
            "    WHERE test_order_id = to2.id " +
            "    ORDER BY uploaded_at ASC " +
            ") ui " +
            // Kết quả phân tích AI
            "LEFT JOIN ai_analysis_results air ON air.test_order_id = to2.id " +
            // Tên sonographer (người upload)
            "OUTER APPLY ( " +
            "    SELECT TOP 1 u.full_name " +
            "    FROM ultrasound_images img " +
            "    JOIN users u ON u.id = img.uploaded_by " +
            "    WHERE img.test_order_id = to2.id " +
            "    ORDER BY img.uploaded_at ASC " +
            ") uploader " +
            "WHERE to2.medical_record_id = ? " +
            "  AND (sc.category_name LIKE N'%siêu âm%' " +
            "       OR sc.category_name LIKE N'%ultrasound%' " +
            "       OR ISNULL(s.required_room_type,'') LIKE N'%ultrasound%') " +
            "ORDER BY to2.created_at";

        return queryToMapList(sql, recordId);
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

    private Integer getDoctorId(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM doctors WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}
