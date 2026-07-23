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
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Bác sĩ mới được xem và xác nhận kết quả siêu âm.");
            return;
        }

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

        UltrasoundOrderService orderService = new UltrasoundOrderService();
        boolean reviewSchemaSupported = orderService.isReviewSchemaSupported();
        // Load kết quả siêu âm
        List<Map<String,Object>> ultrasoundResults = loadUltrasoundResults(recordId, reviewSchemaSupported);
        // Load thông tin hồ sơ (tên BN, ngày khám)
        Map<String,String> recordInfo = loadRecordInfo(recordId);

        req.setAttribute("recordId",          recordId);
        req.setAttribute("recordInfo",         recordInfo);
        req.setAttribute("ultrasoundResults",  ultrasoundResults);
        req.setAttribute("doctorName",         user.getFullName());
        req.setAttribute("reviewSchemaSupported", reviewSchemaSupported);
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
        if (doctorMsg.trim().length() < 20) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=incompleteConclusion"); return;
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
        boolean success = orderService.confirmUltrasoundResult(orderId, user.getId(), doctorMsg);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&success=confirmed#us-order-" + orderId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/doctor/results?recordId=" + recordId + "&error=confirmFailed&orderId=" + orderId);
        }
    }

    // ── Kết quả siêu âm ─────────────────────────────────────────────────────
    private List<Map<String,Object>> loadUltrasoundResults(int recordId, boolean reviewSchemaSupported) {
        String reportColumns = reviewSchemaSupported
                ? "       ann.annotation_data, ann.annotation_type, ann.review_status, ann.rejection_reason, "
                  + "       ur.image_description, ur.professional_findings, ur.conclusion AS sonographer_conclusion, "
                  + "       ur.report_status, ur.signed_name, ur.signed_at, ur.doctor_review_notes, ur.doctor_confirmed_at, "
                : "       CAST(NULL AS nvarchar(max)) AS annotation_data, CAST(NULL AS nvarchar(30)) AS annotation_type, "
                  + "       CAST(NULL AS nvarchar(30)) AS review_status, CAST(NULL AS nvarchar(500)) AS rejection_reason, "
                  + "       CAST(NULL AS nvarchar(max)) AS image_description, CAST(NULL AS nvarchar(max)) AS professional_findings, "
                  + "       CAST(NULL AS nvarchar(max)) AS sonographer_conclusion, CAST(NULL AS nvarchar(20)) AS report_status, "
                  + "       CAST(NULL AS nvarchar(200)) AS signed_name, CAST(NULL AS datetime2) AS signed_at, "
                  + "       CAST(NULL AS nvarchar(2000)) AS doctor_review_notes, CAST(NULL AS datetime2) AS doctor_confirmed_at, ";
        String reviewJoins = reviewSchemaSupported
                ? "LEFT JOIN ultrasound_reports ur ON ur.test_order_id = to2.id AND ur.is_current = 1 "
                  + "AND ur.report_status = 'Signed' AND ur.signed_at IS NOT NULL "
                  + "LEFT JOIN ultrasound_annotations ann ON ann.order_id = to2.id AND ann.is_current = 1 "
                  + "AND ur.id IS NOT NULL "
                : "";
        String preferredImageOrder = reviewSchemaSupported
                ? "CASE WHEN ann.image_id IS NOT NULL AND img.id = ann.image_id THEN 0 ELSE 1 END, "
                : "";
        String sql =
            "SELECT to2.id AS id, " +
            "       to2.id AS order_id, to2.status AS order_status, " +
            "       to2.created_at AS ordered_at, " +
            "       s.service_name, " +
            // Ảnh gốc phải là chính ảnh mà phiếu/vùng duyệt đã ký tham chiếu.
            "       ui.id AS raw_image_id, ui.file_path AS raw_image_url, " +
            // Kết quả AI từ ai_analysis_results
            "       air.result_image AS ai_processed_image_url, " +
            "       air.message AS ai_suggested_label, " +
            "       air.confidence AS ai_confidence_score, " +
            "       air.xmin, air.ymin, air.xmax, air.ymax, " + reportColumns +
            // Sonographer (người upload ảnh)
            "       uploader.full_name AS sonographer_name " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN service_categories sc ON sc.id = s.category_id " +
            reviewJoins +
            // Khi đã có phiếu, ưu tiên tuyệt đối annotation.image_id; chỉ
            // fallback ảnh upload đầu tiên cho ca chưa có phiếu.
            "OUTER APPLY ( " +
            "    SELECT TOP 1 img.id, img.file_path, img.uploaded_by " +
            "    FROM ultrasound_images img " +
            "    WHERE img.test_order_id = to2.id " +
            "    ORDER BY " + preferredImageOrder + "img.uploaded_at ASC, img.id ASC " +
            ") ui " +
            // Chỉ lấy AI result thành công được tạo từ đúng ảnh ở trên.
            "OUTER APPLY (SELECT TOP 1 * FROM ai_analysis_results ar " +
            "             WHERE ar.test_order_id = to2.id AND ar.status = 'Success' " +
            "               AND REPLACE(LTRIM(RTRIM(ar.input_image)), CHAR(92), '/') " +
            "                   = REPLACE(LTRIM(RTRIM(ui.file_path)), CHAR(92), '/') " +
            "             ORDER BY ar.analyzed_at DESC, ar.id DESC) air " +
            "LEFT JOIN users uploader ON uploader.id = ui.uploaded_by " +
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
            "SELECT p.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       mr.final_diagnosis " +
            "FROM medical_records mr " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN patients p ON p.id = a.patient_id " +
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
        } catch (SQLException e) {
            System.err.println("[DoctorResultsServlet] Không thể đọc thông tin hồ sơ: " + e.getMessage());
        }
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
        } catch (SQLException e) {
            System.err.println("[DoctorResultsServlet] Không thể đọc kết quả siêu âm: " + e.getMessage());
        }
        return list;
    }

    private Integer getDoctorId(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM doctors WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) {
            System.err.println("[DoctorResultsServlet] Không thể xác định hồ sơ bác sĩ: " + e.getMessage());
        }
        return null;
    }
}
