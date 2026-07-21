package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;
import com.clinic.model.Service;
import com.clinic.model.User;
import com.clinic.utils.NotificationHelper;

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
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

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
            boolean canEditRecord = new AppointmentDAO().isConsultationInProgress(apptId, doctorId);

            populateFormAttributes(req, record, apptId, doctorId, canEditRecord, null, null);
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

        AppointmentDAO appointmentDAO = new AppointmentDAO();
        if (!appointmentDAO.isConsultationInProgress(apptId, doctorId)) {
            errorOnPost(req, resp, apptId, null, null,
                    "Chỉ có thể cập nhật bệnh án khi ca khám đang ở trạng thái Đang khám.");
            return;
        }

        // Load info ca khám để lấy appointmentDate chuẩn
        MedicalRecord baseInfo = loadAppointmentInfo(apptId);
        if (baseInfo == null || baseInfo.getAppointmentDate() == null || baseInfo.getAppointmentDate().isBlank()) {
            errorOnPost(req, resp, apptId, null, null, "Ngày khám của lịch hẹn không hợp lệ. Không thể tính tuổi thai."); return;
        }

        LocalDate apptDate;
        try {
            apptDate = LocalDate.parse(baseInfo.getAppointmentDate().trim(), java.time.format.DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (java.time.format.DateTimeParseException e) {
            errorOnPost(req, resp, apptId, null, null, "Ngày khám của lịch hẹn không hợp lệ. Không thể tính tuổi thai."); return;
        }

        // Đọc action sớm để quyết định validate bắt buộc
        String submitAction = req.getParameter("submitAction");
        boolean isDraftEarly = "draft".equals(submitAction);
        boolean isFinalEarly = "final".equals(submitAction);

        // Đọc thông tin từ form trước để có thể giữ nguyên dữ liệu nếu xảy ra lỗi
        MedicalRecord mr = new MedicalRecord();
        mr.setAppointmentId(apptId);
        if (recordIdStr != null && !recordIdStr.isBlank()) {
            try { mr.setId(Integer.parseInt(recordIdStr.trim())); } catch (Exception ignored) {}
        }

        String finalDiagnosis = req.getParameter("finalDiagnosis");
        mr.setFinalDiagnosis(finalDiagnosis != null ? finalDiagnosis.trim() : "");
        mr.setClinicalNotes(req.getParameter("clinicalNotes"));

        ParseFieldResult<Double> weightRes = parseDoubleField(req, "weightKg");
        ParseFieldResult<Double> heightRes = parseDoubleField(req, "heightCm");
        mr.setWeightKg(weightRes.value);
        mr.setHeightCm(heightRes.value);

        ParseFieldResult<Integer> sysRes = parseIntField(req, "systolicBP");
        ParseFieldResult<Integer> diaRes = parseIntField(req, "diastolicBP");
        String bloodPressure = null;

        ParseFieldResult<Integer> pulseRes = parseIntField(req, "pulseBpm");
        ParseFieldResult<Double> tempRes = parseDoubleField(req, "temperatureC");
        mr.setPulseBpm(pulseRes.value);
        mr.setTemperatureC(tempRes.value);

        ParseFieldResult<Integer> gestWeeksRes = parseIntField(req, "gestationalAgeWeeks");
        ParseFieldResult<Integer> gestDaysRes = parseIntField(req, "gestationalAgeDays");
        mr.setGestationalAgeWeeks(gestWeeksRes.value);
        mr.setGestationalAgeDays(gestDaysRes.value);

        ParseFieldResult<Double> fundalRes = parseDoubleField(req, "fundalHeightCm");
        ParseFieldResult<Integer> fetalHRRes = parseIntField(req, "fetalHeartRate");
        mr.setFundalHeightCm(fundalRes.value);
        mr.setFetalHeartRate(fetalHRRes.value);

        mr.setFetalPresentation(req.getParameter("fetalPresentation"));
        mr.setFetalPosition(req.getParameter("fetalPosition"));
        mr.setFetalMovement(req.getParameter("fetalMovement"));

        boolean enableLaborExam = "on".equals(req.getParameter("enableLaborExamToggle"))
                               || "1".equals(req.getParameter("enableLaborExamToggle"));

        ParseFieldResult<Double> cervDilationRes = parseDoubleField(req, "cervicalDilationCm");
        if (enableLaborExam) {
            mr.setCervicalDilationCm(cervDilationRes.value);
            mr.setCervicalEffacement(req.getParameter("cervicalEffacement"));
            mr.setPresentationStation(req.getParameter("presentationStation"));
            mr.setAmnioticFluid(req.getParameter("amnioticFluid"));
        } else {
            MedicalRecord existingDB = dao.getByAppointmentId(apptId);
            if (existingDB != null) {
                mr.setCervicalDilationCm(existingDB.getCervicalDilationCm());
                mr.setCervicalEffacement(existingDB.getCervicalEffacement());
                mr.setPresentationStation(existingDB.getPresentationStation());
                mr.setAmnioticFluid(existingDB.getAmnioticFluid());
            }
        }

        mr.setEdema(req.getParameter("edema"));
        mr.setProteinuria(req.getParameter("proteinuria"));
        mr.setVaginalBleeding("on".equals(req.getParameter("vaginalBleeding")));
        mr.setUterineContractions("on".equals(req.getParameter("uterineContractions")));
        mr.setRiskFlagsJson(req.getParameter("riskFlagsJson"));

        mr.setTreatmentPlan(req.getParameter("treatmentPlan"));
        String nadStr = req.getParameter("nextAppointmentDate");
        if (nadStr != null && !nadStr.isBlank()) {
            try { mr.setNextAppointmentDate(LocalDate.parse(nadStr.trim())); } catch (Exception ignored) {}
        }
        mr.setReferredTo(req.getParameter("referredTo"));

        // ── Đọc danh sách đơn thuốc từ form ─────────────────────────────────
        String[] medicineIds = req.getParameterValues("medicineId[]");
        String[] medQuantities = req.getParameterValues("quantity[]");
        String[] medDosages = req.getParameterValues("dosage[]");
        List<PrescriptionItem> prescriptionItems = new ArrayList<>();

        if (medicineIds != null) {
            Set<String> seenMedicineIds = new HashSet<>();
            for (int i = 0; i < medicineIds.length; i++) {
                String midStr = medicineIds[i] == null ? "" : medicineIds[i].trim();
                if (midStr.isEmpty()) continue;

                int medicineId;
                try {
                    medicineId = Integer.parseInt(midStr);
                    if (medicineId <= 0) throw new NumberFormatException();
                } catch (NumberFormatException e) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "ID thuốc không hợp lệ ở dòng " + (i + 1) + "."); return;
                }

                if (!seenMedicineIds.add(midStr)) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Đơn thuốc có thuốc bị trùng lặp ở dòng " + (i + 1) + "."); return;
                }

                String qtyStr = (medQuantities != null && i < medQuantities.length) ? medQuantities[i] : null;
                if (qtyStr == null || qtyStr.trim().isEmpty()) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Vui lòng nhập số lượng thuốc ở dòng " + (i + 1) + "."); return;
                }

                int quantity;
                try {
                    quantity = Integer.parseInt(qtyStr.trim());
                    if (quantity < 1 || quantity > 9999) throw new NumberFormatException();
                } catch (NumberFormatException e) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Số lượng thuốc ở dòng " + (i + 1) + " không đúng định dạng số (1–9999)."); return;
                }

                String rawDosage = (medDosages != null && i < medDosages.length) ? medDosages[i] : null;
                if (rawDosage == null || rawDosage.isBlank()) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Liều dùng và hướng dẫn không được để trống ở dòng " + (i + 1) + "."); return;
                }
                String dosage = rawDosage.trim();
                if (dosage.length() > 500) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Liều dùng quá dài ở dòng " + (i + 1) + " (tối đa 500 ký tự)."); return;
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
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Một hoặc nhiều thuốc đã chọn không còn khả dụng.");
                    return;
                }
            }
        }

        if (!isDraftEarly && !isFinalEarly) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems,
                    "Thao tác lưu hồ sơ không hợp lệ. Vui lòng chọn Lưu nháp hoặc Chốt hồ sơ.");
            return;
        }

        // ── Validate backend & Format checks ─────────────────────────────────
        if (isFinalEarly && (mr.getFinalDiagnosis() == null || mr.getFinalDiagnosis().isBlank())) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chẩn đoán không được để trống khi chốt hồ sơ."); return;
        }
        if (mr.getFinalDiagnosis() != null && mr.getFinalDiagnosis().length() > 1000) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chẩn đoán không được vượt quá 1000 ký tự."); return;
        }

        // Validate Định dạng số sai (Point 1)
        if (weightRes.invalidFormat) { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Cân nặng không đúng định dạng số."); return; }
        if (heightRes.invalidFormat) { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chiều cao không đúng định dạng số."); return; }
        if (pulseRes.invalidFormat)  { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Mạch không đúng định dạng số."); return; }
        if (tempRes.invalidFormat)   { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Nhiệt độ không đúng định dạng số."); return; }
        if (gestWeeksRes.invalidFormat) { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Tuổi thai (tuần) không đúng định dạng số."); return; }
        if (gestDaysRes.invalidFormat)  { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày lẻ tuổi thai không đúng định dạng số."); return; }
        if (fundalRes.invalidFormat) { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chiều cao tử cung không đúng định dạng số."); return; }
        if (fetalHRRes.invalidFormat){ errorOnPost(req, resp, apptId, mr, prescriptionItems, "Nhịp tim thai không đúng định dạng số."); return; }
        if (enableLaborExam && cervDilationRes.invalidFormat) { errorOnPost(req, resp, apptId, mr, prescriptionItems, "Độ mở CTC không đúng định dạng số."); return; }

        // Validate Huyết áp (không tin bloodPressure param, chỉ nhận sysBP & diaBP)
        if (sysRes.invalidFormat || diaRes.invalidFormat) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Huyết áp tâm thu và tâm trương phải là số nguyên hợp lệ."); return;
        }
        if (sysRes.value != null || diaRes.value != null) {
            if (sysRes.value == null || diaRes.value == null) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Vui lòng nhập đầy đủ cả Huyết áp tâm thu và Huyết áp tâm trương."); return;
            }
            if (sysRes.value < 50 || sysRes.value > 250) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Huyết áp tâm thu không hợp lệ (phải từ 50–250 mmHg)."); return;
            }
            if (diaRes.value < 30 || diaRes.value > 150) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Huyết áp tâm trương không hợp lệ (phải từ 30–150 mmHg)."); return;
            }
            if (sysRes.value <= diaRes.value) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Huyết áp tâm thu phải lớn hơn Huyết áp tâm trương."); return;
            }
            bloodPressure = sysRes.value + "/" + diaRes.value;
        }
        mr.setBloodPressure(bloodPressure);

        // Validate phạm vi sinh hiệu
        if (weightRes.value != null && (weightRes.value < 20 || weightRes.value > 300)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Cân nặng không hợp lệ (phải từ 20–300 kg)."); return;
        }
        if (heightRes.value != null && (heightRes.value < 100 || heightRes.value > 250)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chiều cao không hợp lệ (phải từ 100–250 cm)."); return;
        }
        if (pulseRes.value != null && (pulseRes.value < 30 || pulseRes.value > 250)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Mạch không hợp lệ (phải từ 30–250 bpm)."); return;
        }
        if (tempRes.value != null && (tempRes.value < 34.0 || tempRes.value > 43.0)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Nhiệt độ không hợp lệ (phải từ 34.0–43.0 °C)."); return;
        }

        // Validate Tuổi thai & LMP (Point 2: Tính theo apptDate)
        Integer gestWeeks = gestWeeksRes.value;
        Integer gestDays = gestDaysRes.value;
        if (gestWeeks != null && (gestWeeks < 0 || gestWeeks > 44)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Tuổi thai (tuần) không hợp lệ (phải từ 0–44 tuần)."); return;
        }
        if (gestDays != null && (gestDays < 0 || gestDays > 6)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày lẻ tuổi thai không hợp lệ (phải từ 0–6 ngày)."); return;
        }
        if (fetalHRRes.value != null && (fetalHRRes.value < 60 || fetalHRRes.value > 220)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Nhịp tim thai không hợp lệ (phải từ 60–220 bpm)."); return;
        }
        if (fundalRes.value != null && (fundalRes.value < 5 || fundalRes.value > 50)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Chiều cao tử cung không hợp lệ (phải từ 5–50 cm)."); return;
        }

        // Kiểm tra LMP và tự tính lại theo apptDate
        String lmpStr = req.getParameter("lastMenstrualPeriod");
        if (lmpStr == null || lmpStr.isBlank()) {
            lmpStr = baseInfo.getLastMenstrualPeriod();
        }

        if (lmpStr != null && !lmpStr.isBlank()) {
            try {
                LocalDate lmp = LocalDate.parse(lmpStr.trim());
                if (lmp.isAfter(apptDate)) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems,
                            "Ngày kinh cuối (LMP) không được sau ngày khám của lịch hẹn (" + baseInfo.getAppointmentDate() + ").");
                    return;
                }
                long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(lmp, apptDate);
                if (daysBetween >= 0 && gestWeeksRes.value == null) {
                    gestWeeks = (int)(daysBetween / 7);
                    gestDays = (int)(daysBetween % 7);
                    mr.setGestationalAgeWeeks(gestWeeks);
                    mr.setGestationalAgeDays(gestDays);
                }
            } catch (Exception e) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày kinh cuối (LMP) không đúng định dạng YYYY-MM-DD."); return;
            }
        }

        // Validate độ mở CTC (chỉ khi switch bật)
        if (enableLaborExam && cervDilationRes.value != null && (cervDilationRes.value < 0 || cervDilationRes.value > 10)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Độ mở CTC không hợp lệ (phải từ 0–10 cm)."); return;
        }

        // Validate ngày tái khám
        if (nadStr != null && !nadStr.isBlank()) {
            try {
                LocalDate nad = LocalDate.parse(nadStr.trim());
                if (nad.isBefore(LocalDate.now())) {
                    errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày tái khám phải từ hôm nay trở đi."); return;
                }
                mr.setNextAppointmentDate(nad);
            } catch (Exception e) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày tái khám không đúng định dạng."); return;
            }
        }

        boolean isDraft = isDraftEarly;

        // ── Lưu hồ sơ ───────────────────────────────────────────────────────
        boolean success;
        int finalRecordId;
        if (mr.getId() > 0) {
            finalRecordId = mr.getId();
            mr.setStatus(isDraft ? "draft" : "final");
            success = dao.update(mr);
            if (success && !isDraft) {
                appointmentDAO.completeConsultation(apptId, doctorId);
            }
        } else {
            mr.setStatus(isDraft ? "draft" : "final");
            finalRecordId = dao.create(mr);
            success = finalRecordId > 0;
            if (success && !isDraft) {
                appointmentDAO.completeConsultation(apptId, doctorId);
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

        // ── BR §4.8: Tự động tạo / cập nhật hóa đơn thuốc PRESCRIPTION khi hoàn thành khám ──
        if (success && !isDraft && !prescriptionItems.isEmpty()) {
            try {
                java.math.BigDecimal totalMedAmount = calculatePrescriptionTotal(prescriptionItems);
                if (totalMedAmount.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    handlePrescriptionInvoice(apptId, totalMedAmount);
                }
            } catch (Exception ex) {
                // Không để lỗi hóa đơn chặn luồng chính — log để theo dõi.
                System.err.println("[MedicalRecordServlet] upsertPrescriptionInvoice failed: " + ex.getMessage());
            }
        }



        if (!success) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Lưu hồ sơ thất bại. Vui lòng thử lại.");
            return;
        }

        // ── Bắn thông báo cập nhật hồ sơ bệnh án cho bệnh nhân khi lưu final ────
        if (!isDraft) {
            try {
                com.clinic.utils.NotificationHelper.medicalRecordUpdated(finalRecordId, mr.getFinalDiagnosis());
            } catch (Exception ex) {
                System.err.println("[MedicalRecordServlet] Gửi thông báo cập nhật bệnh án thất bại: " + ex.getMessage());
            }
        }

        // ── Loại 5: Thông báo dấu hiệu nguy cơ khi lưu final ─────────────────
        if (!isDraft) {
            try {
                boolean hasRisk = Boolean.TRUE.equals(mr.getVaginalBleeding())
                               || Boolean.TRUE.equals(mr.getUterineContractions())
                               || (mr.getRiskFlagsJson() != null && !mr.getRiskFlagsJson().isBlank()
                                   && !mr.getRiskFlagsJson().equals("[]"));
                if (hasRisk) {
                    // Lấy tên bệnh nhân từ appointment
                    String[] apptInfo = NotificationHelper.getApptInfo(apptId);
                    String patientName = apptInfo != null ? apptInfo[0] : "bệnh nhân";

                    // Gom danh sách dấu hiệu
                    java.util.List<String> flags = new java.util.ArrayList<>();
                    if (Boolean.TRUE.equals(mr.getVaginalBleeding()))      flags.add("chảy máu âm đạo");
                    if (Boolean.TRUE.equals(mr.getUterineContractions()))   flags.add("co thắt tử cung");
                    if (mr.getRiskFlagsJson() != null
                            && !mr.getRiskFlagsJson().isBlank()
                            && !mr.getRiskFlagsJson().equals("[]")) {
                        flags.add("dấu hiệu khác (xem hồ sơ)");
                    }

                    NotificationHelper.riskFlagAlert(
                        user.getId(), finalRecordId, patientName,
                        String.join(", ", flags));
                }
            } catch (Exception ignored) {}
        }

        if (isDraft) {
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId + "&saved=1&draft=1");
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

    private void errorOnPost(HttpServletRequest req, HttpServletResponse resp,
                              int apptId, MedicalRecord formRecord, List<PrescriptionItem> items, String msg)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        Integer doctorId = getDoctorId(user != null ? user.getId() : 0);
        boolean canEditRecord = doctorId != null && new AppointmentDAO().isConsultationInProgress(apptId, doctorId);

        MedicalRecord recordToRender = formRecord;
        MedicalRecord baseInfo = loadAppointmentInfo(apptId);
        if (baseInfo != null && recordToRender != null) {
            if (recordToRender.getPatientName() == null) recordToRender.setPatientName(baseInfo.getPatientName());
            if (recordToRender.getAppointmentDate() == null) recordToRender.setAppointmentDate(baseInfo.getAppointmentDate());
            if (recordToRender.getTimeSlot() == null) recordToRender.setTimeSlot(baseInfo.getTimeSlot());
            if (recordToRender.getSymptoms() == null) recordToRender.setSymptoms(baseInfo.getSymptoms());
            if (recordToRender.getLastMenstrualPeriod() == null) recordToRender.setLastMenstrualPeriod(baseInfo.getLastMenstrualPeriod());
        }

        Prescription prescription = null;
        if (items != null && !items.isEmpty()) {
            prescription = new Prescription();
            prescription.setItems(items);
        }

        populateFormAttributes(req, recordToRender, apptId, doctorId != null ? doctorId : 0, canEditRecord, prescription, msg);
        req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
    }

    private void populateFormAttributes(HttpServletRequest req, MedicalRecord record,
                                        int apptId, int doctorId, boolean canEditRecord,
                                        Prescription formPrescription, String errorMsg) {
        AppointmentDAO appointmentDAO = new AppointmentDAO();

        String sysBP = req.getParameter("systolicBP");
        String diaBP = req.getParameter("diastolicBP");
        if ((sysBP != null && !sysBP.isBlank()) || (diaBP != null && !diaBP.isBlank())) {
            req.setAttribute("systolicBP", sysBP);
            req.setAttribute("diastolicBP", diaBP);
        } else if (record != null && record.getBloodPressure() != null && record.getBloodPressure().contains("/")) {
            String[] parts = record.getBloodPressure().split("/");
            if (parts.length == 2) {
                req.setAttribute("systolicBP", parts[0].trim());
                req.setAttribute("diastolicBP", parts[1].trim());
            }
        }

        Prescription prescription = null;
        if (record != null && record.getId() > 0) {
            prescription = prescriptionDAO.getByMedicalRecordId(record.getId());
        }

        List<Service> allUltrasound = serviceDAO.findUltrasoundServices();
        List<Service> bookedUltrasound = new ArrayList<>();
        List<Service> additionalUltrasound = new ArrayList<>();
        for (Service s : allUltrasound) {
            if (appointmentDAO.hasBookedService(apptId, s.getId())) {
                bookedUltrasound.add(s);
            } else {
                additionalUltrasound.add(s);
            }
        }

        User user = (User) req.getSession().getAttribute("user");
        String doctorName = user != null ? user.getFullName() : "";

        req.setAttribute("record", record);
        req.setAttribute("apptId", apptId);
        req.setAttribute("doctorName", doctorName);
        req.setAttribute("mode", "form");
        req.setAttribute("canEditRecord", canEditRecord);
        req.setAttribute("prescription", prescription);
        req.setAttribute("medicines", prescriptionDAO.getAllMedicines());
        req.setAttribute("ultrasoundServices", allUltrasound);
        req.setAttribute("bookedUltrasoundServices", bookedUltrasound);
        req.setAttribute("additionalUltrasoundServices", additionalUltrasound);
        if (errorMsg != null) {
            req.setAttribute("errorMessage", errorMsg);
        }
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
            "SELECT pt.full_name AS patient_name, " +
            "  CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "  CONVERT(varchar, a.time_slot, 108) AS time_slot, " +
            "  a.symptoms, " +
            "  CONVERT(varchar, a.last_menstrual_period, 23) AS last_menstrual_period, " +
            "  a.pregnancy_id " +
            "FROM appointments a JOIN patients pt ON a.patient_id = pt.id WHERE a.id = ?";
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

    private static class ParseFieldResult<T> {
        final T value;
        final boolean invalidFormat;
        ParseFieldResult(T value, boolean invalidFormat) {
            this.value = value;
            this.invalidFormat = invalidFormat;
        }
    }

    private ParseFieldResult<Integer> parseIntField(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.trim().isEmpty()) {
            return new ParseFieldResult<>(null, false);
        }
        try {
            return new ParseFieldResult<>(Integer.parseInt(v.trim()), false);
        } catch (NumberFormatException e) {
            return new ParseFieldResult<>(null, true);
        }
    }

    private ParseFieldResult<Double> parseDoubleField(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.trim().isEmpty()) {
            return new ParseFieldResult<>(null, false);
        }
        try {
            return new ParseFieldResult<>(Double.parseDouble(v.trim()), false);
        } catch (NumberFormatException e) {
            return new ParseFieldResult<>(null, true);
        }
    }

    private Double parseDouble(HttpServletRequest req, String name) {
        return parseDoubleField(req, name).value;
    }

    private Integer parseInt(HttpServletRequest req, String name) {
        return parseIntField(req, name).value;
    }

    /**
     * Tính tổng tiền đơn thuốc dựa trên số lượng × đơn giá trong bảng medicines.
     * Truy vấn DB để lấy giá hiện tại của từng loại thuốc.
     *
     * @param items danh sách thuốc trong đơn
     * @return tổng tiền BigDecimal (>= 0)
     */
    private java.math.BigDecimal calculatePrescriptionTotal(List<PrescriptionItem> items) {
        if (items == null || items.isEmpty()) return java.math.BigDecimal.ZERO;

        java.math.BigDecimal total = java.math.BigDecimal.ZERO;
        StringBuilder placeholders = new StringBuilder();
        java.util.Map<Integer, Integer> qtyMap = new java.util.LinkedHashMap<>();
        for (PrescriptionItem item : items) {
            int mid = item.getMedicineId();
            if (!qtyMap.containsKey(mid)) {
                if (placeholders.length() > 0) placeholders.append(',');
                placeholders.append('?');
            }
            qtyMap.put(mid, qtyMap.getOrDefault(mid, 0) + item.getQuantity());
        }

        String sql = "SELECT id, price FROM medicines WHERE id IN (" + placeholders + ")";
        try (java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (int mid : qtyMap.keySet()) ps.setInt(idx++, mid);
            java.sql.ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int mid = rs.getInt("id");
                java.math.BigDecimal price = rs.getBigDecimal("price");
                if (price != null && qtyMap.containsKey(mid)) {
                    total = total.add(price.multiply(new java.math.BigDecimal(qtyMap.get(mid))));
                }
            }
        } catch (Exception e) {
            System.err.println("[MedicalRecordServlet] calculatePrescriptionTotal error: " + e.getMessage());
        }
        return total;
    }

    /**
     * Keeps an already paid/declined prescription invoice immutable. If the
     * prescription is increased afterwards, only the difference becomes a new
     * unpaid invoice; otherwise the current unpaid invoice is updated in place.
     */
    private void handlePrescriptionInvoice(int appointmentId, java.math.BigDecimal newTotal) {
        if (newTotal == null) {
            newTotal = java.math.BigDecimal.ZERO;
        }

        com.clinic.model.Invoice existing = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRESCRIPTION");
        if (existing == null) {
            invoiceDAO.upsertPrescriptionInvoice(appointmentId, newTotal);
            return;
        }

        String status = existing.getStatus() == null ? "" : existing.getStatus();
        if ("Paid".equalsIgnoreCase(status) || "DeclinedPurchase".equalsIgnoreCase(status)) {
            java.math.BigDecimal oldTotal = existing.getTotalAmount() == null
                    ? java.math.BigDecimal.ZERO : existing.getTotalAmount();
            java.math.BigDecimal difference = newTotal.subtract(oldTotal);
            if (difference.compareTo(java.math.BigDecimal.ZERO) <= 0) {
                return;
            }
            com.clinic.model.Invoice newInvoice = new com.clinic.model.Invoice();
            newInvoice.setAppointmentId(appointmentId);
            newInvoice.setTotalAmount(difference);
            newInvoice.setStatus("Unpaid");
            newInvoice.setInvoiceType("PRESCRIPTION");
            newInvoice.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            invoiceDAO.insert(newInvoice);
            return;
        }

        invoiceDAO.upsertPrescriptionInvoice(appointmentId, newTotal);
    }
}
