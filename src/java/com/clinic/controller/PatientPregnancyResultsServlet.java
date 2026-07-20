package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.PatientDAO;
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
 * Bệnh nhân xem kết quả siêu âm + thông tin lần khám thai của CHÍNH MÌNH.
 *
 * Luồng: Hồ sơ thai kỳ → Dòng thời gian lần khám → chọn 1 lần khám → Kết quả siêu âm
 *        (ảnh + chỉ số thai nhi + kết luận bác sĩ), thay vì xem tất cả ảnh không có ngữ cảnh.
 *
 * GET /patient/pregnancy/results?recordId=X
 */
@WebServlet("/patient/pregnancy/results")
public class PatientPregnancyResultsServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 5) { // Bệnh nhân
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        int patientId = patientDAO.getPatientIdByUserId(user.getId());
        if (patientId <= 0) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa liên kết hồ sơ bệnh nhân.");
            return;
        }

        String ridStr = req.getParameter("recordId");
        int recordId;
        try { recordId = Integer.parseInt(ridStr); }
        catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "recordId không hợp lệ.");
            return;
        }

        // ── Thông tin lần khám (chỉ số thai nhi) + kiểm tra hồ sơ này có đúng là của bệnh nhân đang đăng nhập không
        Map<String, Object> visitInfo = loadVisitInfo(recordId, patientId);
        if (visitInfo == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem hồ sơ khám này.");
            return;
        }

        // ── Danh sách kết quả siêu âm (ảnh + kết luận bác sĩ) của lần khám này
        List<Map<String, Object>> ultrasoundResults = loadUltrasoundResults(recordId);

        req.setAttribute("recordId",         recordId);
        req.setAttribute("visitInfo",        visitInfo);
        req.setAttribute("ultrasoundResults", ultrasoundResults);
        req.getRequestDispatcher("/views/patient/pregnancy_visit_result.jsp").forward(req, resp);
    }

    /** Trả về null nếu hồ sơ khám này không thuộc về patientId đang đăng nhập (chặn xem hồ sơ người khác). */
    private Map<String, Object> loadVisitInfo(int recordId, int patientId) {
        String sql =
            "SELECT mr.id, mr.gestational_age_weeks, mr.gestational_age_days, mr.final_diagnosis, " +
            "       mr.weight_kg, mr.blood_pressure, mr.fundal_height_cm, mr.fetal_heart_rate, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       doc_u.full_name AS doctor_name " +
            "FROM medical_records mr " +
            "JOIN appointments a   ON mr.appointment_id = a.id " +
            "JOIN doctors doc      ON a.doctor_id = doc.id " +
            "JOIN users doc_u      ON doc.user_id = doc_u.id " +
            "WHERE mr.id = ? AND a.patient_id = ?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setInt(2, patientId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("appointmentDate", rs.getString("appointment_date"));
                m.put("doctorName", rs.getString("doctor_name"));
                m.put("finalDiagnosis", rs.getString("final_diagnosis"));

                int gaw = rs.getInt("gestational_age_weeks");
                m.put("gestationalAgeWeeks", rs.wasNull() ? null : gaw);
                int gad = rs.getInt("gestational_age_days");
                m.put("gestationalAgeDays", rs.wasNull() ? null : gad);

                double w = rs.getDouble("weight_kg");
                m.put("weightKg", rs.wasNull() ? null : w);
                m.put("bloodPressure", rs.getString("blood_pressure"));
                double fh = rs.getDouble("fundal_height_cm");
                m.put("fundalHeightCm", rs.wasNull() ? null : fh);
                int fhr = rs.getInt("fetal_heart_rate");
                m.put("fetalHeartRate", rs.wasNull() ? null : fhr);
                return m;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** Toàn bộ ảnh siêu âm + kết luận bác sĩ cho 1 hồ sơ khám (mỗi chỉ định siêu âm là 1 nhóm ảnh). */
    private List<Map<String, Object>> loadUltrasoundResults(int recordId) {
        String orderSql =
            "SELECT to2.id AS order_id, to2.status AS order_status, to2.created_at AS ordered_at, " +
            "       s.service_name, air.message AS doctor_conclusion " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN service_categories sc ON sc.id = s.category_id " +
            "LEFT JOIN ai_analysis_results air ON air.test_order_id = to2.id " +
            "WHERE to2.medical_record_id = ? " +
            "  AND (sc.category_name LIKE N'%siêu âm%' " +
            "       OR sc.category_name LIKE N'%ultrasound%' " +
            "       OR ISNULL(s.required_room_type,'') LIKE N'%ultrasound%') " +
            "  AND LOWER(LTRIM(RTRIM(ISNULL(to2.status, '')))) = 'confirmed' " + // only doctor-confirmed results are released to the patient
            "ORDER BY to2.created_at";

        List<Map<String, Object>> results = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(orderSql)) {
            ps.setInt(1, recordId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                int orderId = rs.getInt("order_id");
                m.put("orderId", orderId);
                m.put("serviceName", rs.getString("service_name"));
                m.put("orderedAt", rs.getTimestamp("ordered_at"));
                m.put("doctorConclusion", rs.getString("doctor_conclusion"));
                m.put("images", loadImages(c, orderId));
                results.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return results;
    }

    private List<String> loadImages(Connection c, int orderId) throws SQLException {
        List<String> images = new ArrayList<>();
        String sql = "SELECT file_path FROM ultrasound_images WHERE test_order_id = ? ORDER BY uploaded_at ASC";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) images.add(rs.getString("file_path"));
        }
        return images;
    }
}
