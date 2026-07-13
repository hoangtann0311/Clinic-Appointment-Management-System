package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet hồ sơ bệnh án phụ sản.
 *
 * GET  /doctor/medical-records              → danh sách
 * GET  /doctor/medical-records?apptId=X     → form tạo / sửa
 * POST /doctor/medical-records              → lưu (tạo mới hoặc cập nhật)
 */
@WebServlet("/doctor/medical-records")
public class MedicalRecordServlet extends HttpServlet {

    private final MedicalRecordDAO dao = new MedicalRecordDAO();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = authenticate(req, resp); if (user == null) return;
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) { error(req, resp, "Tài khoản chưa liên kết hồ sơ bác sĩ."); return; }

        String apptIdParam = req.getParameter("apptId");

        if (apptIdParam != null) {
            // ── Form tạo / sửa ──────────────────────────────────────────────
            int apptId;
            try { apptId = Integer.parseInt(apptIdParam); }
            catch (NumberFormatException e) { error(req, resp, "apptId không hợp lệ."); return; }

            if (!dao.appointmentBelongsToDoctor(apptId, doctorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }

            MedicalRecord record = dao.getByAppointmentId(apptId);
            if (record == null) record = loadAppointmentInfo(apptId);

            // Load danh sách dịch vụ siêu âm active (category_id = 2)
            List<com.clinic.model.ServiceItem> ultrasoundServices = new java.util.ArrayList<>();
            String sql = "SELECT id, service_name, price FROM services WHERE category_id = 2 AND is_active = 1 ORDER BY service_name";
            try (Connection conn = com.clinic.config.DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.clinic.model.ServiceItem svc = new com.clinic.model.ServiceItem();
                    svc.setId(rs.getInt("id"));
                    svc.setServiceName(rs.getString("service_name"));
                    svc.setPrice(rs.getDouble("price"));
                    ultrasoundServices.add(svc);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            // Load danh sách các chỉ định siêu âm đã tạo cho bệnh án này
            List<com.clinic.model.UltrasoundWaitingPatient> testOrders = new java.util.ArrayList<>();
            java.util.Map<Integer, com.clinic.model.AiAnalysisResult> aiResultsMap = new java.util.HashMap<>();
            if (record != null && record.getId() > 0) {
                com.clinic.service.UltrasoundOrderService uService = new com.clinic.service.UltrasoundOrderService();
                testOrders = uService.getOrdersByMedicalRecordId(record.getId());
                
                // Đọc kết quả AI cho từng order đã Completed
                for (com.clinic.model.UltrasoundWaitingPatient order : testOrders) {
                    if ("Completed".equalsIgnoreCase(order.getStatus())) {
                        com.clinic.model.AiAnalysisResult aiRes = uService.getAiResult(order.getOrderId());
                        if (aiRes != null) {
                            aiResultsMap.put(order.getOrderId(), aiRes);
                        }
                    }
                }
            }

            req.setAttribute("record",             record);
            req.setAttribute("apptId",             apptId);
            req.setAttribute("doctorName",         user.getFullName());
            req.setAttribute("ultrasoundServices", ultrasoundServices);
            req.setAttribute("testOrders",         testOrders);
            req.setAttribute("aiResultsMap",       aiResultsMap);
            req.setAttribute("mode",               "form");
            req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);

        } else {
            // ── Danh sách ───────────────────────────────────────────────────
            String keyword = req.getParameter("keyword");
            List<MedicalRecord> records = dao.getByDoctorId(doctorId, keyword);
            req.setAttribute("records",    records);
            req.setAttribute("keyword",    keyword != null ? keyword : "");
            req.setAttribute("doctorName", user.getFullName());
            req.setAttribute("mode",       "list");
            req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
        }
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = authenticate(req, resp); if (user == null) return;
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) { error(req, resp, "Tài khoản chưa liên kết hồ sơ bác sĩ."); return; }

        String apptIdStr   = req.getParameter("appointmentId");
        String recordIdStr = req.getParameter("recordId");

        if (apptIdStr == null || apptIdStr.isBlank()) { error(req, resp, "Thiếu appointmentId."); return; }
        int apptId = Integer.parseInt(apptIdStr);

        if (!dao.appointmentBelongsToDoctor(apptId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        // ── Validate backend ─────────────────────────────────────────────────
        String finalDiagnosis = req.getParameter("finalDiagnosis");
        if (finalDiagnosis == null || finalDiagnosis.isBlank()) {
            error(req, resp, "Chẩn đoán không được để trống."); return;
        }
        if (finalDiagnosis.trim().length() > 1000) {
            error(req, resp, "Chẩn đoán không được vượt quá 1000 ký tự."); return;
        }

        // Validate sinh hiệu (chỉ khi có nhập)
        Double weightKg = parseDouble(req, "weightKg");
        if (weightKg != null && (weightKg < 20 || weightKg > 300)) {
            error(req, resp, "Cân nặng không hợp lệ (phải từ 20–300 kg)."); return;
        }
        Double heightCm = parseDouble(req, "heightCm");
        if (heightCm != null && (heightCm < 100 || heightCm > 250)) {
            error(req, resp, "Chiều cao không hợp lệ (phải từ 100–250 cm)."); return;
        }
        String bloodPressure = req.getParameter("bloodPressure");
        if (bloodPressure != null && !bloodPressure.isBlank()) {
            if (!bloodPressure.matches("^\\d{2,3}/\\d{2,3}$")) {
                error(req, resp, "Huyết áp không đúng định dạng (vd: 120/80)."); return;
            }
            String[] parts = bloodPressure.split("/");
            int systolic = Integer.parseInt(parts[0]), diastolic = Integer.parseInt(parts[1]);
            if (systolic < 50 || systolic > 250 || diastolic < 30 || diastolic > 150) {
                error(req, resp, "Huyết áp ngoài phạm vi hợp lệ (tâm thu 50–250, tâm trương 30–150)."); return;
            }
        }
        Integer pulseBpm = parseInt(req, "pulseBpm");
        if (pulseBpm != null && (pulseBpm < 30 || pulseBpm > 250)) {
            error(req, resp, "Mạch không hợp lệ (phải từ 30–250 bpm)."); return;
        }
        Double temperatureC = parseDouble(req, "temperatureC");
        if (temperatureC != null && (temperatureC < 34.0 || temperatureC > 43.0)) {
            error(req, resp, "Nhiệt độ không hợp lệ (phải từ 34.0–43.0 °C)."); return;
        }

        // Validate thai nhi
        Integer gestWeeks = parseInt(req, "gestationalAgeWeeks");
        if (gestWeeks != null && (gestWeeks < 4 || gestWeeks > 44)) {
            error(req, resp, "Tuổi thai (tuần) không hợp lệ (phải từ 4–44)."); return;
        }
        Integer gestDays = parseInt(req, "gestationalAgeDays");
        if (gestDays != null && (gestDays < 0 || gestDays > 6)) {
            error(req, resp, "Ngày lẻ tuổi thai không hợp lệ (phải từ 0–6)."); return;
        }
        Integer fetalHR = parseInt(req, "fetalHeartRate");
        if (fetalHR != null && (fetalHR < 60 || fetalHR > 220)) {
            error(req, resp, "Nhịp tim thai không hợp lệ (phải từ 60–220 bpm)."); return;
        }
        Double fundalHeight = parseDouble(req, "fundalHeightCm");
        if (fundalHeight != null && (fundalHeight < 5 || fundalHeight > 50)) {
            error(req, resp, "Chiều cao tử cung không hợp lệ (phải từ 5–50 cm)."); return;
        }

        // Validate độ mở CTC
        Double cervDilation = parseDouble(req, "cervicalDilationCm");
        if (cervDilation != null && (cervDilation < 0 || cervDilation > 10)) {
            error(req, resp, "Độ mở CTC không hợp lệ (phải từ 0–10 cm)."); return;
        }

        // Validate ngày tái khám
        String nadStr = req.getParameter("nextAppointmentDate");
        if (nadStr != null && !nadStr.isBlank()) {
            try {
                LocalDate nad = LocalDate.parse(nadStr);
                if (nad.isBefore(LocalDate.now())) {
                    error(req, resp, "Ngày tái khám phải từ hôm nay trở đi."); return;
                }
            } catch (Exception e) {
                error(req, resp, "Ngày tái khám không đúng định dạng."); return;
            }
        }

        // ── Đọc toàn bộ form ────────────────────────────────────────────────
        MedicalRecord mr = new MedicalRecord();
        mr.setAppointmentId(apptId);

        mr.setClinicalNotes(req.getParameter("clinicalNotes"));
        mr.setFinalDiagnosis(finalDiagnosis.trim());

        mr.setWeightKg(weightKg);
        mr.setBloodPressure(bloodPressure != null && !bloodPressure.isBlank() ? bloodPressure : null);
        mr.setPulseBpm(pulseBpm);
        mr.setTemperatureC(temperatureC);
        mr.setHeightCm(heightCm);

        mr.setGestationalAgeWeeks(gestWeeks);
        mr.setGestationalAgeDays(gestDays);
        mr.setFundalHeightCm(fundalHeight);
        mr.setFetalHeartRate(fetalHR);
        mr.setFetalPresentation(req.getParameter("fetalPresentation"));
        mr.setFetalPosition(req.getParameter("fetalPosition"));
        mr.setFetalMovement(req.getParameter("fetalMovement"));

        mr.setCervicalDilationCm(parseDouble(req, "cervicalDilationCm"));
        mr.setCervicalEffacement(req.getParameter("cervicalEffacement"));
        mr.setAmnioticFluid(req.getParameter("amnioticFluid"));
        mr.setPresentationStation(req.getParameter("presentationStation"));

        mr.setEdema(req.getParameter("edema"));
        mr.setProteinuria(req.getParameter("proteinuria"));
        mr.setVaginalBleeding("on".equals(req.getParameter("vaginalBleeding")));
        mr.setUterineContractions("on".equals(req.getParameter("uterineContractions")));
        mr.setRiskFlagsJson(req.getParameter("riskFlagsJson"));

        mr.setTreatmentPlan(req.getParameter("treatmentPlan"));
        if (nadStr != null && !nadStr.isBlank()) mr.setNextAppointmentDate(LocalDate.parse(nadStr));
        mr.setReferredTo(req.getParameter("referredTo"));

        // ── Lưu ─────────────────────────────────────────────────────────────
        boolean success;
        if (recordIdStr != null && !recordIdStr.isBlank()) {
            mr.setId(Integer.parseInt(recordIdStr));
            success = dao.update(mr);
        } else {
            int newId = dao.create(mr);
            success = newId > 0;
            if (success) new AppointmentDAO().updateStatus(apptId, doctorId, "completed");
        }

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId + "&saved=1");
        } else {
            error(req, resp, "Lưu hồ sơ thất bại. Vui lòng thử lại.");
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private User authenticate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return null;
        }
        return (User) s.getAttribute("user");
    }

    private void error(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws ServletException, IOException {
        req.setAttribute("errorMessage", msg);
        req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
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

    private MedicalRecord loadAppointmentInfo(int apptId) {
        MedicalRecord mr = new MedicalRecord();
        mr.setAppointmentId(apptId);
        String sql =
            "SELECT u.full_name AS patient_name, " +
            "  CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "  CONVERT(varchar, a.time_slot, 108) AS time_slot, " +
            "  a.symptoms, " +
            "  CONVERT(varchar, a.last_menstrual_period, 23) AS last_menstrual_period, " +
            "  a.pregnancy_id " +
            "FROM appointments a JOIN users u ON a.patient_id = u.id WHERE a.id = ?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, apptId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                mr.setPatientName(rs.getString("patient_name"));
                mr.setAppointmentDate(rs.getString("appointment_date"));
                mr.setTimeSlot(rs.getString("time_slot"));
                mr.setSymptoms(rs.getString("symptoms"));
                mr.setLastMenstrualPeriod(rs.getString("last_menstrual_period"));
                int pid = rs.getInt("pregnancy_id"); if (!rs.wasNull()) mr.setPregnancyId(pid);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return mr;
    }

    private Double parseDouble(HttpServletRequest req, String name) {
        try { String v = req.getParameter(name); return (v != null && !v.isBlank()) ? Double.parseDouble(v) : null; }
        catch (NumberFormatException e) { return null; }
    }

    private Integer parseInt(HttpServletRequest req, String name) {
        try { String v = req.getParameter(name); return (v != null && !v.isBlank()) ? Integer.parseInt(v) : null; }
        catch (NumberFormatException e) { return null; }
    }
}