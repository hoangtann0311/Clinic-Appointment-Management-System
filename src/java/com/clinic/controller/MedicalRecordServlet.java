package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.dao.TestOrderDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();
    private final TestOrderDAO testOrderDAO = new TestOrderDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

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

            // Đơn thuốc đã có (nếu hồ sơ đã từng được lưu và đã kê đơn trước đó)
            Prescription prescription = null;
            if (record.getId() > 0) {
                prescription = prescriptionDAO.getByMedicalRecordId(record.getId());
            }

            req.setAttribute("record",       record);
            req.setAttribute("apptId",       apptId);
            req.setAttribute("doctorName",   user.getFullName());
            req.setAttribute("mode",         "form");
            req.setAttribute("prescription", prescription);
            req.setAttribute("medicines",    prescriptionDAO.getAllMedicines());
            req.setAttribute("labServices",        serviceDAO.findByCategoryId(3));
            req.setAttribute("ultrasoundServices", serviceDAO.findByCategoryId(2));
            if (record.getId() > 0) {
                req.setAttribute("testOrders", testOrderDAO.getByMedicalRecordId(record.getId()));
            }
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
            errorOnPost(req, resp, apptId, user.getFullName(), "Chẩn đoán không được để trống."); return;
        }
        if (finalDiagnosis.trim().length() > 1000) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Chẩn đoán không được vượt quá 1000 ký tự."); return;
        }

        // Validate sinh hiệu (chỉ khi có nhập)
        Double weightKg = parseDouble(req, "weightKg");
        if (weightKg != null && (weightKg < 20 || weightKg > 300)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Cân nặng không hợp lệ (phải từ 20–300 kg)."); return;
        }
        Double heightCm = parseDouble(req, "heightCm");
        if (heightCm != null && (heightCm < 100 || heightCm > 250)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Chiều cao không hợp lệ (phải từ 100–250 cm)."); return;
        }
        String bloodPressure = req.getParameter("bloodPressure");
        if (bloodPressure != null && !bloodPressure.isBlank()) {
            if (!bloodPressure.matches("^\\d{2,3}/\\d{2,3}$")) {
                errorOnPost(req, resp, apptId, user.getFullName(), "Huyết áp không đúng định dạng (vd: 120/80)."); return;
            }
            String[] parts = bloodPressure.split("/");
            int systolic = Integer.parseInt(parts[0]), diastolic = Integer.parseInt(parts[1]);
            if (systolic < 50 || systolic > 250 || diastolic < 30 || diastolic > 150) {
                errorOnPost(req, resp, apptId, user.getFullName(), "Huyết áp ngoài phạm vi hợp lệ (tâm thu 50–250, tâm trương 30–150)."); return;
            }
        }
        Integer pulseBpm = parseInt(req, "pulseBpm");
        if (pulseBpm != null && (pulseBpm < 30 || pulseBpm > 250)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Mạch không hợp lệ (phải từ 30–250 bpm)."); return;
        }
        Double temperatureC = parseDouble(req, "temperatureC");
        if (temperatureC != null && (temperatureC < 34.0 || temperatureC > 43.0)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Nhiệt độ không hợp lệ (phải từ 34.0–43.0 °C)."); return;
        }

        // Validate thai nhi
        Integer gestWeeks = parseInt(req, "gestationalAgeWeeks");
        if (gestWeeks != null && (gestWeeks < 4 || gestWeeks > 44)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Tuổi thai (tuần) không hợp lệ (phải từ 4–44)."); return;
        }
        Integer gestDays = parseInt(req, "gestationalAgeDays");
        if (gestDays != null && (gestDays < 0 || gestDays > 6)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Ngày lẻ tuổi thai không hợp lệ (phải từ 0–6)."); return;
        }
        Integer fetalHR = parseInt(req, "fetalHeartRate");
        if (fetalHR != null && (fetalHR < 60 || fetalHR > 220)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Nhịp tim thai không hợp lệ (phải từ 60–220 bpm)."); return;
        }
        Double fundalHeight = parseDouble(req, "fundalHeightCm");
        if (fundalHeight != null && (fundalHeight < 5 || fundalHeight > 50)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Chiều cao tử cung không hợp lệ (phải từ 5–50 cm)."); return;
        }

        // Validate độ mở CTC
        Double cervDilation = parseDouble(req, "cervicalDilationCm");
        if (cervDilation != null && (cervDilation < 0 || cervDilation > 10)) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Độ mở CTC không hợp lệ (phải từ 0–10 cm)."); return;
        }

        // Validate ngày tái khám
        String nadStr = req.getParameter("nextAppointmentDate");
        if (nadStr != null && !nadStr.isBlank()) {
            try {
                LocalDate nad = LocalDate.parse(nadStr);
                if (nad.isBefore(LocalDate.now())) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "Ngày tái khám phải từ hôm nay trở đi."); return;
                }
            } catch (Exception e) {
                errorOnPost(req, resp, apptId, user.getFullName(), "Ngày tái khám không đúng định dạng."); return;
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

        // ── Đọc & validate đơn thuốc kèm theo (tùy chọn) ──────────────────────
        // Bác sĩ có thể kê đơn thuốc ngay trong lúc tạo/cập nhật hồ sơ bệnh án.
        String[] medicineIds = req.getParameterValues("medicineId[]");
        String[] medQuantities = req.getParameterValues("quantity[]");
        String[] medDosages = req.getParameterValues("dosage[]");

        List<PrescriptionItem> prescriptionItems = new ArrayList<>();
        if (medicineIds != null) {
            Set<String> seenMedicineIds = new HashSet<>();
            for (int i = 0; i < medicineIds.length; i++) {
                String midStr = medicineIds[i] == null ? "" : medicineIds[i].trim();
                if (midStr.isEmpty()) continue; // dòng chưa chọn thuốc, bỏ qua

                int medicineId;
                try {
                    medicineId = Integer.parseInt(midStr);
                    if (medicineId <= 0) throw new NumberFormatException();
                } catch (NumberFormatException e) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "ID thuốc không hợp lệ ở dòng " + (i + 1) + "."); return;
                }

                if (!seenMedicineIds.add(midStr)) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "Đơn thuốc có thuốc bị trùng lặp. Vui lòng kiểm tra lại."); return;
                }

                int quantity;
                try {
                    quantity = Integer.parseInt(medQuantities[i].trim());
                    if (quantity < 1 || quantity > 9999) throw new NumberFormatException();
                } catch (Exception e) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "Số lượng thuốc không hợp lệ ở dòng " + (i + 1) + " (phải từ 1–9999)."); return;
                }

                String dosage = (medDosages != null && i < medDosages.length && medDosages[i] != null)
                        ? medDosages[i].trim() : "";
                if (dosage.length() > 500) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "Liều dùng quá dài ở dòng " + (i + 1) + " (tối đa 500 ký tự)."); return;
                }

                PrescriptionItem item = new PrescriptionItem();
                item.setMedicineId(medicineId);
                item.setQuantity(quantity);
                item.setDosage(dosage);
                prescriptionItems.add(item);
            }

            if (!prescriptionItems.isEmpty()) {
                Set<Integer> idsToCheck = new HashSet<>();
                for (PrescriptionItem item : prescriptionItems) idsToCheck.add(item.getMedicineId());
                if (!prescriptionDAO.allMedicineIdsValid(idsToCheck)) {
                    errorOnPost(req, resp, apptId, user.getFullName(), "Một hoặc nhiều thuốc đã chọn không còn khả dụng. Vui lòng tải lại trang và chọn lại.");
                    return;
                }
            }
        }

        // ── Đọc action: draft = chỉ định XN rồi chờ, final = lưu chính thức ──
        String submitAction = req.getParameter("submitAction");
        boolean isDraft = "draft".equals(submitAction);

        // ── Lưu hồ sơ ───────────────────────────────────────────────────────
        boolean success;
        int finalRecordId;
        if (recordIdStr != null && !recordIdStr.isBlank()) {
            finalRecordId = Integer.parseInt(recordIdStr);
            mr.setId(finalRecordId);
            mr.setStatus(isDraft ? "draft" : "final");
            success = dao.update(mr);
        } else {
            mr.setStatus(isDraft ? "draft" : "final");
            finalRecordId = dao.create(mr);
            success = finalRecordId > 0;
            if (success && !isDraft) {
                new AppointmentDAO().updateStatus(apptId, doctorId, "completed");
            }
        }

        // ── Lưu đơn thuốc kèm theo ──────────────────────────────────────────
        if (success && !prescriptionItems.isEmpty()) {
            Prescription existing = prescriptionDAO.getByMedicalRecordId(finalRecordId);
            if (existing != null) {
                prescriptionDAO.replaceItems(existing.getId(), prescriptionItems);
            } else {
                String code = "RX-" + LocalDateTime.now()
                        .format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
                int newPrescriptionId = prescriptionDAO.create(finalRecordId, code);
                if (newPrescriptionId > 0) {
                    prescriptionDAO.replaceItems(newPrescriptionId, prescriptionItems);
                }
            }
        }

        // ── Tạo chỉ định xét nghiệm ─────────────────────────────────────────
        if (success) {
            String[] labSids = req.getParameterValues("labServiceIds");
            if (labSids != null && labSids.length > 0) {
                java.util.List<Integer> labIds = new java.util.ArrayList<>();
                for (String s : labSids) {
                    try { labIds.add(Integer.parseInt(s)); } catch (NumberFormatException ignored) {}
                }
                if (!labIds.isEmpty()) testOrderDAO.createBatch(finalRecordId, doctorId, labIds);
            }
        }

        if (!success) {
            errorOnPost(req, resp, apptId, user.getFullName(), "Lưu hồ sơ thất bại. Vui lòng thử lại.");
            return;
        }

        if (isDraft) {
            // Chuyển sang trang xét nghiệm để chờ kết quả KTV
            resp.sendRedirect(req.getContextPath() + "/doctor/lab-orders?recordId=" + finalRecordId + "&fromDraft=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId + "&saved=1");
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

    /**
     * Dùng trong doPost khi đã biết apptId: nạp lại đầy đủ context
     * (record, mode, medicines, prescription) trước khi forward về form,
     * để trang không bị lỗi do thiếu attribute khi có lỗi validate.
     */
    private void errorOnPost(HttpServletRequest req, HttpServletResponse resp,
                              int apptId, String doctorName, String msg)
            throws ServletException, IOException {
        MedicalRecord record = dao.getByAppointmentId(apptId);
        if (record == null) record = loadAppointmentInfo(apptId);

        Prescription prescription = null;
        if (record.getId() > 0) {
            prescription = prescriptionDAO.getByMedicalRecordId(record.getId());
        }

        req.setAttribute("record",       record);
        req.setAttribute("apptId",       apptId);
        req.setAttribute("doctorName",   doctorName);
        req.setAttribute("mode",              "form");
        req.setAttribute("prescription",      prescription);
        req.setAttribute("medicines",         prescriptionDAO.getAllMedicines());
        req.setAttribute("labServices",        serviceDAO.findByCategoryId(3));
        req.setAttribute("ultrasoundServices", serviceDAO.findByCategoryId(2));
        req.setAttribute("errorMessage",      msg);
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