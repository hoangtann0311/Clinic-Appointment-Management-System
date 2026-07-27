package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.model.Appointment;
import com.clinic.model.ExamStage;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;
import com.clinic.model.Service;
import com.clinic.model.User;
import com.clinic.service.AppointmentStageService;
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
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AppointmentStageService stageService = new AppointmentStageService();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = authenticate(req, resp); if (user == null) return;
        Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
        if (doctorId == null) { error(req, resp, "Tài khoản chưa liên kết hồ sơ bác sĩ."); return; }

        String apptIdParam = req.getParameter("apptId");
        String patientIdParam = req.getParameter("patientId");

        if (apptIdParam != null) {
            // ── Form tạo / sửa ──────────────────────────────────────────────
            int apptId;
            try { apptId = Integer.parseInt(apptIdParam); }
            catch (NumberFormatException e) { errorWithMode(req, resp, "apptId không hợp lệ.", "patients"); return; }

            if (!dao.appointmentBelongsToDoctor(apptId, doctorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }

            try {
                MedicalRecord record = dao.getByAppointmentId(apptId);
                if (record == null) record = loadAppointmentInfo(apptId);
                boolean canEditRecord = new AppointmentDAO().isConsultationInProgress(apptId, doctorId);

                populateFormAttributes(req, record, apptId, doctorId, canEditRecord, null, null);
            } catch (Exception ex) {
                System.err.println("[MedicalRecordServlet] doGet ERROR for apptId=" + apptId + ": " + ex.getMessage());
                ex.printStackTrace();
                errorWithMode(req, resp, "Không thể tải hồ sơ bệnh án. Vui lòng thử lại sau.", "patients");
                return;
            }
            req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);

        } else if (patientIdParam != null && !patientIdParam.isBlank()) {
            // ── Lịch sử khám của một bệnh nhân ──────────────────────────────
            int patientId;
            try { patientId = Integer.parseInt(patientIdParam.trim()); }
            catch (NumberFormatException e) {
                errorWithMode(req, resp, "patientId không hợp lệ.", "patients"); return;
            }

            if (!hasAppointmentWithPatient(patientId, doctorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem thông tin bệnh nhân này.");
                return;
            }

            try {
                java.util.List<MedicalRecord> records = dao.getClinicalHistoryForDoctor(patientId, doctorId);
                String patientName = getPatientNameById(patientId);

                // Load thêm dữ liệu siêu âm & đơn thuốc cho từng record
                java.util.Map<Integer, Boolean> hasUltrasoundMap = new java.util.HashMap<>();
                java.util.Map<Integer, Boolean> ultrasoundCompletedMap = new java.util.HashMap<>();
                java.util.Map<Integer, com.clinic.model.Prescription> rxMap = new java.util.HashMap<>();
                com.clinic.dao.PrescriptionDAO prescriptionDAO = new com.clinic.dao.PrescriptionDAO();

                for (MedicalRecord rec : records) {
                    int apptId = rec.getAppointmentId();
                    boolean hasUs = dao.hasAnyUltrasoundOrderForAppointment(apptId);
                    hasUltrasoundMap.put(rec.getId(), hasUs);
                    if (hasUs) {
                        ultrasoundCompletedMap.put(rec.getId(),
                                !dao.hasBlockingUltrasoundOrdersForAppointment(apptId));
                    }
                    // Load đơn thuốc nếu record có id
                    if (rec.getId() > 0) {
                        com.clinic.model.Prescription rx = prescriptionDAO.getByMedicalRecordId(rec.getId());
                        if (rx != null && rx.getItems() != null && !rx.getItems().isEmpty()) {
                            rxMap.put(rec.getId(), rx);
                        }
                    }
                }

                req.setAttribute("records",              records);
                req.setAttribute("hasUltrasoundMap",     hasUltrasoundMap);
                req.setAttribute("ultrasoundCompletedMap", ultrasoundCompletedMap);
                req.setAttribute("rxMap",                rxMap);
                req.setAttribute("patientName", patientName);
                req.setAttribute("patientId",   patientId);
                req.setAttribute("doctorName",  user.getFullName());
                req.setAttribute("mode",        "history");
                req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
            } catch (Exception ex) {
                System.err.println("[MedicalRecordServlet] doGet ERROR for patientId=" + patientId + ": " + ex.getMessage());
                ex.printStackTrace();
                errorWithMode(req, resp, "Không thể tải lịch sử bệnh án. Vui lòng thử lại sau.", "patients");
            }

        } else {
            // ── Danh sách bệnh nhân ─────────────────────────────────────────
            try {
                String keyword = req.getParameter("keyword");
                String pageParam = req.getParameter("page");
                String dateFromParam = req.getParameter("dateFrom");
                String dateToParam = req.getParameter("dateTo");

                int page = 1;
                int pageSize = 10;
                if (pageParam != null && !pageParam.isBlank()) {
                    try { page = Integer.parseInt(pageParam.trim()); if (page < 1) page = 1; }
                    catch (NumberFormatException ignored) {}
                }

                java.time.LocalDate dateFrom = null;
                java.time.LocalDate dateTo = null;
                if (dateFromParam != null && !dateFromParam.isBlank()) {
                    try { dateFrom = java.time.LocalDate.parse(dateFromParam.trim()); }
                    catch (Exception ignored) {}
                }
                if (dateToParam != null && !dateToParam.isBlank()) {
                    try { dateTo = java.time.LocalDate.parse(dateToParam.trim()); }
                    catch (Exception ignored) {}
                }

                int offset = (page - 1) * pageSize;
                java.util.List<com.clinic.model.PatientMedicalSummary> pageSummaries =
                        dao.getPatientSummariesByDoctorId(doctorId, keyword, dateFrom, dateTo, offset, pageSize);
                int totalRecords = dao.countPatientSummariesByDoctorId(doctorId, keyword, dateFrom, dateTo);
                int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
                if (totalPages < 1) totalPages = 1;
                if (page > totalPages) page = totalPages;

                req.setAttribute("patientSummaries", pageSummaries);
                req.setAttribute("keyword",       keyword != null ? keyword : "");
                req.setAttribute("dateFrom",      dateFromParam != null ? dateFromParam : "");
                req.setAttribute("dateTo",        dateToParam != null ? dateToParam : "");
                req.setAttribute("doctorName",    user.getFullName());
                req.setAttribute("currentPage",   page);
                req.setAttribute("totalPages",    totalPages);
                req.setAttribute("totalRecords",  totalRecords);
                req.setAttribute("mode",          "patients");
                req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
            } catch (Exception ex) {
                System.err.println("[MedicalRecordServlet] doGet ERROR (patients): " + ex.getMessage());
                ex.printStackTrace();
                errorWithMode(req, resp, "Không thể tải danh sách bệnh nhân. Vui lòng thử lại sau.", "patients");
            }
        }
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = authenticate(req, resp); if (user == null) return;
        Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
        if (doctorId == null) { error(req, resp, "Tài khoản chưa liên kết hồ sơ bác sĩ."); return; }

        String apptIdStr   = req.getParameter("appointmentId");
        String recordIdStr = req.getParameter("recordId");

        if (apptIdStr == null || apptIdStr.isBlank()) { error(req, resp, "Thiếu appointmentId."); return; }
        int apptId;
        try {
            apptId = Integer.parseInt(apptIdStr.trim());
            if (apptId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "appointmentId không hợp lệ.");
            return;
        }

        if (!dao.appointmentBelongsToDoctor(apptId, doctorId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        AppointmentDAO appointmentDAO = new AppointmentDAO();
        if (!appointmentDAO.isConsultationInProgress(apptId, doctorId)) {
            errorOnPost(req, resp, apptId, null, null,
                    "Chỉ có thể cập nhật bệnh án khi ca khám đang ở trạng thái Đang khám.");
            return;
        }

        // [P5] Kiểm tra giai đoạn khám — chặn action sai bước
        ExamStage stage = stageService.getStage(apptId);
        String submitAction = req.getParameter("submitAction");
        boolean isDraft = "draft".equals(submitAction);
        boolean isFinal = "final".equals(submitAction);

        if (isFinal) {
            String blockMsg = stageService.checkActionAllowed(apptId, doctorId, "finalizeRecord");
            if (blockMsg != null) {
                errorOnPost(req, resp, apptId, null, null, blockMsg);
                return;
            }
        }

        MedicalRecord existingRecord = dao.getByAppointmentId(apptId);
        if (recordIdStr != null && !recordIdStr.isBlank()) {
            int submittedRecordId;
            try {
                submittedRecordId = Integer.parseInt(recordIdStr.trim());
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "recordId không hợp lệ.");
                return;
            }
            if (submittedRecordId > 0) {
                if (existingRecord == null || existingRecord.getId() != submittedRecordId) {
                    resp.sendError(HttpServletResponse.SC_CONFLICT,
                            "Hồ sơ đã thay đổi hoặc không thuộc lịch hẹn này. Vui lòng tải lại.");
                    return;
                }
            }
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
        // (đã khai báo isDraft, isFinal ở trên — dùng lại)
        MedicalRecord mr = new MedicalRecord();
        mr.setAppointmentId(apptId);
        if (existingRecord != null) mr.setId(existingRecord.getId());

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
            if (existingRecord != null) {
                mr.setCervicalDilationCm(existingRecord.getCervicalDilationCm());
                mr.setCervicalEffacement(existingRecord.getCervicalEffacement());
                mr.setPresentationStation(existingRecord.getPresentationStation());
                mr.setAmnioticFluid(existingRecord.getAmnioticFluid());
            }
        }

        mr.setEdema(req.getParameter("edema"));
        mr.setProteinuria(req.getParameter("proteinuria"));
        mr.setVaginalBleeding("on".equals(req.getParameter("vaginalBleeding")));
        mr.setUterineContractions("on".equals(req.getParameter("uterineContractions")));
        mr.setRiskFlagsJson(req.getParameter("riskFlagsJson"));

        mr.setTreatmentPlan(req.getParameter("treatmentPlan"));
        mr.setReferredTo(req.getParameter("referredTo"));

        // ── Đọc danh sách đơn thuốc từ form ─────────────────────────────────
        String[] medicineIds = req.getParameterValues("medicineId[]");
        if (medicineIds == null) medicineIds = req.getParameterValues("medicineId");
        String[] medQuantities = req.getParameterValues("quantity[]");
        if (medQuantities == null) medQuantities = req.getParameterValues("quantity");
        String[] medDosages = req.getParameterValues("dosage[]");
        if (medDosages == null) medDosages = req.getParameterValues("dosage");
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
                // Validate stock: từ chối nếu số lượng kê vượt tồn kho
                com.clinic.dao.MedicineDAO medicineDAO = new com.clinic.dao.MedicineDAO();
                for (PrescriptionItem item : prescriptionItems) {
                    com.clinic.model.Medicine med = medicineDAO.findById(item.getMedicineId());
                    if (med != null && item.getQuantity() > med.getStockQuantity()) {
                        errorOnPost(req, resp, apptId, mr, prescriptionItems,
                                "Thuốc \"" + med.getName() + "\" chỉ còn " + med.getStockQuantity()
                                + " " + med.getUnit() + " trong kho — không đủ " + item.getQuantity() + " để kê đơn.");
                        return;
                    }
                }
            }
        }

        if (!isDraft && !isFinal) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems,
                    "Thao tác lưu hồ sơ không hợp lệ. Vui lòng chọn Lưu nháp hoặc Chốt hồ sơ.");
            return;
        }

        // Khi chốt hồ sơ: bắt buộc bác sĩ phải ra quyết định về siêu âm
        if (isFinal) {
            boolean ultrasoundSkipped = "true".equals(req.getParameter("ultrasoundSkipped"));
            boolean hasUltrasound = dao.hasAnyUltrasoundOrderForAppointment(apptId);
            if (!hasUltrasound && !ultrasoundSkipped) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems,
                        "Vui lòng ra quyết định về siêu âm trước khi chốt hồ sơ: "
                        + "tạo Chỉ định Siêu âm hoặc tích chọn \"Không cần chỉ định siêu âm\".");
                return;
            }
        }

        // ── Validate backend & Format checks ─────────────────────────────────
        if (isFinal && (mr.getFinalDiagnosis() == null || mr.getFinalDiagnosis().isBlank())) {
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
                mr.setLastMenstrualPeriod(lmpStr.trim());
            } catch (Exception e) {
                errorOnPost(req, resp, apptId, mr, prescriptionItems, "Ngày kinh cuối (LMP) không đúng định dạng YYYY-MM-DD."); return;
            }
        }

        // Validate độ mở CTC (chỉ khi switch bật)
        if (enableLaborExam && cervDilationRes.value != null && (cervDilationRes.value < 0 || cervDilationRes.value > 10)) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, "Độ mở CTC không hợp lệ (phải từ 0–10 cm)."); return;
        }

        // Hồ sơ, đơn thuốc, hóa đơn và trạng thái lịch hẹn là một đơn vị nghiệp vụ.
        // Chỉ commit khi toàn bộ các bước đều thành công.
        boolean success = false;
        int finalRecordId = -1;
        String transactionError = "Lưu hồ sơ thất bại. Vui lòng thử lại.";
        mr.setStatus(isDraft ? "draft" : "final");
        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement lockStmt = conn.createStatement()) {
                lockStmt.execute("SET LOCK_TIMEOUT 5000");
            }
            try {
                if (!appointmentDAO.lockConsultationInProgress(conn, apptId, doctorId)) {
                    throw new SQLException("APPOINTMENT_STATE_CONFLICT");
                }
                if (mr.getLastMenstrualPeriod() != null && !mr.getLastMenstrualPeriod().isBlank()) {
                    try (PreparedStatement updateLmpPs = conn.prepareStatement(
                            "UPDATE appointments SET last_menstrual_period = ? WHERE id = ?")) {
                        updateLmpPs.setDate(1, java.sql.Date.valueOf(mr.getLastMenstrualPeriod().trim()));
                        updateLmpPs.setInt(2, apptId);
                        updateLmpPs.executeUpdate();
                    }
                }
                if (mr.getId() > 0) {
                    finalRecordId = mr.getId();
                    if (!dao.update(conn, mr)) throw new SQLException("MEDICAL_RECORD_UPDATE_CONFLICT");
                } else {
                    finalRecordId = dao.create(conn, mr);
                    if (finalRecordId <= 0) throw new SQLException("MEDICAL_RECORD_CREATE_FAILED");
                }

                Integer prescriptionId = prescriptionDAO.findIdByMedicalRecordId(conn, finalRecordId);
                if (prescriptionId != null || !prescriptionItems.isEmpty()) {
                    if (prescriptionId == null) {
                        String code = "RX-" + LocalDateTime.now()
                                .format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss-SSS"));
                        prescriptionId = prescriptionDAO.create(conn, finalRecordId, code);
                    }
                    if (prescriptionId == null || prescriptionId <= 0
                            || !prescriptionDAO.replaceItems(conn, prescriptionId, prescriptionItems)) {
                        throw new SQLException("PRESCRIPTION_SAVE_FAILED");
                    }
                }

                if (!isDraft) {
                    if (dao.hasBlockingUltrasoundOrdersForAppointment(conn, apptId)) {
                        throw new SQLException("ULTRASOUND_PENDING");
                    }
                    if (!appointmentDAO.completeConsultation(conn, apptId, doctorId)) {
                        throw new SQLException("APPOINTMENT_STATE_CONFLICT");
                    }
                }

                conn.commit();
                success = true;
            } catch (SQLException ex) {
                try { conn.rollback(); } catch (SQLException rollbackEx) { ex.addSuppressed(rollbackEx); }
                if ("ULTRASOUND_PENDING".equals(ex.getMessage())) {
                    transactionError = "Chưa thể chốt hồ sơ: còn chỉ định siêu âm chưa được Bác sĩ siêu âm xác nhận hoặc hủy hợp lệ.";
                }
                System.err.println("[MedicalRecordServlet] transaction rolled back: " + ex.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        } catch (SQLException ex) {
            System.err.println("[MedicalRecordServlet] database error: " + ex.getMessage());
        }

        if (!success) {
            errorOnPost(req, resp, apptId, mr, prescriptionItems, transactionError);
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
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId + "&finalized=1");
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
        req.setAttribute("mode", "patients");
        req.setAttribute("patientSummaries", java.util.Collections.emptyList());
        req.setAttribute("keyword", "");
        req.setAttribute("currentPage", 1);
        req.setAttribute("totalPages", 1);
        req.setAttribute("totalRecords", 0);
        User user = (User) req.getSession().getAttribute("user");
        req.setAttribute("doctorName", user != null ? user.getFullName() : "");
        req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
    }

    private void errorWithMode(HttpServletRequest req, HttpServletResponse resp,
                               String msg, String mode) throws ServletException, IOException {
        req.setAttribute("errorMessage", msg);
        req.setAttribute("mode", mode);
        if ("patients".equals(mode)) {
            req.setAttribute("patientSummaries", java.util.Collections.emptyList());
            req.setAttribute("keyword", "");
            req.setAttribute("currentPage", 1);
            req.setAttribute("totalPages", 1);
            req.setAttribute("totalRecords", 0);
            User user = (User) req.getSession().getAttribute("user");
            req.setAttribute("doctorName", user != null ? user.getFullName() : "");
        }
        req.getRequestDispatcher("/views/doctors/medical_record_form.jsp").forward(req, resp);
    }

    /** Kiểm tra bác sĩ đã từng có lịch hẹn với bệnh nhân này chưa */
    private boolean hasAppointmentWithPatient(int patientId, int doctorId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT 1 FROM appointments WHERE patient_id = ? AND doctor_id = ?")) {
            ps.setInt(1, patientId);
            ps.setInt(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Lấy tên bệnh nhân theo ID */
    private String getPatientNameById(int patientId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT full_name FROM patients WHERE id = ?")) {
            ps.setInt(1, patientId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("full_name");
        } catch (Exception e) { e.printStackTrace(); }
        return "Bệnh nhân #" + patientId;
    }

    private void errorOnPost(HttpServletRequest req, HttpServletResponse resp,
                              int apptId, MedicalRecord formRecord, List<PrescriptionItem> items, String msg)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        Integer doctorId = DoctorDAO.getDoctorIdByUserId(user != null ? user.getId() : 0);
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
        // Tránh JasperException khi record == null (vd: lỗi parse LMP sớm)
        if (record == null) {
            record = new MedicalRecord();
            record.setAppointmentId(apptId);
        }
        MedicalRecord baseInfo = loadAppointmentInfo(apptId);

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
        req.setAttribute("hasBlockingUltrasound",
                record != null && record.getId() > 0
                        && dao.hasBlockingUltrasoundOrdersForAppointment(apptId));
        // Kiểm tra xem đã có ít nhất 1 chỉ định siêu âm cho appointment này chưa
        req.setAttribute("existingUltrasoundOrders",
                dao.hasAnyUltrasoundOrderForAppointment(apptId));

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

        req.setAttribute("patientName", record != null ? record.getPatientName() : "");
        req.setAttribute("patientPhone", record != null ? record.getPatientPhone() : "");
        req.setAttribute("patientDob", record != null ? record.getPatientDob() : "");
        req.setAttribute("bookingSource", baseInfo != null ? baseInfo.getBookingSource() : "");
        req.setAttribute("record", record);
        req.setAttribute("apptId", apptId);
        req.setAttribute("doctorName", doctorName);
        req.setAttribute("mode", "form");
        // [P5] Tính stage để hiển thị trạng thái + khoá section
        try {
            com.clinic.service.AppointmentStageService stageSvc = new com.clinic.service.AppointmentStageService();
            com.clinic.model.ExamStage stage = stageSvc.getStage(apptId);
            req.setAttribute("examStage", stage);
            req.setAttribute("examStageLabel", stage.toDisplayString());
        } catch (Exception e) {
            req.setAttribute("examStageLabel", "Không xác định");
        }

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

    private MedicalRecord loadAppointmentInfo(int apptId) {
        MedicalRecord mr = new MedicalRecord();
        mr.setAppointmentId(apptId);
        String sql =
            "SELECT pt.full_name AS patient_name, " +
            "  pt.phone_number AS patient_phone, " +
            "  CONVERT(varchar, pt.date_of_birth, 23) AS patient_dob, " +
            "  CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "  a.time_slot AS time_slot, " +
            "  a.symptoms, " +
            "  a.booking_source, " +
            "  CONVERT(varchar, a.last_menstrual_period, 23) AS last_menstrual_period, " +
            "  a.pregnancy_id, " +
            "  a.patient_id " +
            "FROM appointments a JOIN patients pt ON a.patient_id = pt.id WHERE a.id = ?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, apptId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                mr.setPatientName(rs.getString("patient_name"));
                mr.setPatientPhone(rs.getString("patient_phone"));
                mr.setPatientDob(rs.getString("patient_dob"));
                mr.setAppointmentDate(rs.getString("appointment_date"));
                mr.setTimeSlot(rs.getString("time_slot"));
                mr.setSymptoms(rs.getString("symptoms"));
                mr.setBookingSource(rs.getString("booking_source"));
                mr.setLastMenstrualPeriod(rs.getString("last_menstrual_period"));
                int pid = rs.getInt("pregnancy_id"); if (!rs.wasNull()) mr.setPregnancyId(pid);
                mr.setPatientId(rs.getInt("patient_id"));
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

}
