package com.clinic.service;

import com.clinic.config.AuthorizationConfig;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;
import com.clinic.utils.AuditUtil;

import java.util.Objects;

/**
 * Service xử lý nghiệp vụ quản lý bệnh án (Medical Record).
 *
 * <p><b>Quy tắc nghiệp vụ:</b>
 * <ul>
 *   <li>CHỈ Doctor (roleId = 2) được phép sửa bệnh án.</li>
 *   <li>Admin và Manager KHÔNG có quyền sửa nội dung bệnh án.</li>
 *   <li>Audit Log được ghi sau khi cập nhật THÀNH CÔNG.</li>
 *   <li>Audit Log cũng ghi nhận các trường hợp THẤT BẠI (FORBIDDEN, DB_ERROR).</li>
 *   <li>CHỈ ghi log khi dữ liệu thực sự thay đổi (so sánh field-by-field).</li>
 *   <li>Lưu cả Old Value và New Value dạng JSON cho mọi field thay đổi.</li>
 * </ul>
 *
 * <p><b>Nguyên tắc:</b>
 * <ul>
 *   <li>Gọi AuditUtil từ Service layer — KHÔNG gọi từ Controller hay JSP.</li>
 *   <li>Validate role TRƯỚC khi thực hiện bất kỳ thao tác DB nào.</li>
 *   <li>So sánh field-by-field để tránh tạo audit log không có giá trị.</li>
 * </ul>
 */
public class MedicalRecordService {

    private final MedicalRecordDAO medicalRecordDAO;

    public MedicalRecordService() {
        this.medicalRecordDAO = new MedicalRecordDAO();
    }

    /**
     * Kết quả của thao tác cập nhật bệnh án.
     */
    public enum UpdateResult {
        /** Cập nhật thành công + đã ghi audit log */
        SUCCESS("Cập nhật bệnh án thành công."),
        /** Không có field nào thay đổi → không update DB, không ghi log */
        NO_CHANGE("Không có thay đổi nào được phát hiện."),
        /** Người dùng không phải Doctor → ghi audit FAILED */
        FORBIDDEN("Bạn không có quyền sửa bệnh án. Chỉ Bác sĩ mới được phép."),
        /** Bệnh án không tồn tại trong DB */
        NOT_FOUND("Không tìm thấy bệnh án."),
        /** Dữ liệu đầu vào không hợp lệ */
        VALIDATION_ERROR("Dữ liệu không hợp lệ."),
        /** Lỗi DB → ghi audit FAILED */
        DB_ERROR("Lỗi hệ thống khi cập nhật bệnh án. Vui lòng thử lại.");

        private final String message;

        UpdateResult(String message) {
            this.message = message;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSuccess() {
            return this == SUCCESS;
        }
    }

    // ══════════════════════════════════════════════════
    // PUBLIC API
    // ══════════════════════════════════════════════════

    /**
     * Lấy bệnh án theo ID.
     */
    public MedicalRecord getMedicalRecord(int id) {
        return medicalRecordDAO.findById(id);
    }

    /**
     * Lấy bệnh án theo appointment ID.
     */
    public MedicalRecord getByAppointmentId(int appointmentId) {
        return medicalRecordDAO.findByAppointmentId(appointmentId);
    }

    /**
     * Lấy tên bệnh nhân từ bệnh án.
     *
     * @param recordId ID của bệnh án
     * @return tên bệnh nhân hoặc "Không rõ" nếu không xác định được
     */
    public String getPatientName(int recordId) {
        String name = medicalRecordDAO.findPatientNameByRecordId(recordId);
        return name != null ? name : "Không rõ";
    }

    /**
     * Lấy appointment ID từ bệnh án.
     */
    public Integer getAppointmentId(int recordId) {
        return medicalRecordDAO.findAppointmentIdByRecordId(recordId);
    }

    /**
     * Cập nhật bệnh án — CHỈ Doctor (roleId = 2) được phép.
     *
     * <p><b>Flow xử lý:</b>
     * <ol>
     *   <li>Kiểm tra role: nếu không phải Doctor → FORBIDDEN + audit FAILED</li>
     *   <li>Load bản ghi cũ từ DB: nếu không tồn tại → NOT_FOUND</li>
     *   <li>So sánh field-by-field: nếu không có gì thay đổi → NO_CHANGE</li>
     *   <li>Cập nhật DB với updated_by = editor.getId()</li>
     *   <li>Thành công → audit SUCCESS | Thất bại → audit FAILED</li>
     * </ol>
     *
     * @param newRecord bệnh án với dữ liệu mới từ form
     * @param editor    người dùng đang đăng nhập (bắt buộc là Doctor)
     * @param request   HttpServletRequest để trích xuất IP cho audit log
     * @return UpdateResult kèm thông báo
     */
    public UpdateResult updateMedicalRecord(MedicalRecord newRecord, User editor,
                                             jakarta.servlet.http.HttpServletRequest request) {
        // ── 1. Role check: CHỈ Doctor (roleId = 2) ──
        if (editor == null || editor.getRoleId() != AuthorizationConfig.ROLE_DOCTOR) {
            String reason = (editor == null)
                    ? "Không có quyền: chưa đăng nhập"
                    : "Không có quyền: chỉ Doctor được sửa bệnh án (roleId=" + editor.getRoleId() + ")";

            AuditUtil.logMedicalRecordUpdateFailed(
                    request, newRecord != null ? newRecord.getId() : 0,
                    null, null, editor, reason);
            return UpdateResult.FORBIDDEN;
        }

        if (newRecord == null) {
            return UpdateResult.VALIDATION_ERROR;
        }

        // ── 2. Load bản ghi cũ ──
        MedicalRecord oldRecord = medicalRecordDAO.findById(newRecord.getId());
        if (oldRecord == null) {
            return UpdateResult.NOT_FOUND;
        }

        // ── 3. So sánh field-by-field ──
        String changesJson = buildChangesJson(oldRecord, newRecord);
        if (changesJson == null) {
            // Không có thay đổi nào
            return UpdateResult.NO_CHANGE;
        }

        // ── Metadata ──
        Integer appointmentId = oldRecord.getAppointmentId();
        String patientName = medicalRecordDAO.findPatientNameByRecordId(newRecord.getId());

        // ── 4. Set metadata cho update ──
        newRecord.setUpdatedBy(editor.getId());

        // ── 5. Cập nhật DB ──
        boolean success;
        try {
            success = medicalRecordDAO.update(newRecord);
        } catch (Exception e) {
            System.err.println("[MedicalRecordService] updateMedicalRecord ERROR: " + e.getMessage());
            // Ghi audit FAILED — lỗi DB
            AuditUtil.logMedicalRecordUpdateFailed(
                    request, newRecord.getId(), appointmentId, patientName,
                    editor, "Lỗi DB: " + e.getMessage());
            return UpdateResult.DB_ERROR;
        }

        // ── 6. Ghi audit log ──
        if (success) {
            // Tách changesJson thành oldValues và newValues riêng
            String oldValuesJson = buildOldValuesJson(oldRecord, newRecord);
            String newValuesJson = buildNewValuesJson(oldRecord, newRecord);

            AuditUtil.logMedicalRecordUpdate(
                    request, newRecord.getId(), appointmentId, patientName,
                    editor, oldValuesJson, newValuesJson);
            return UpdateResult.SUCCESS;
        } else {
            AuditUtil.logMedicalRecordUpdateFailed(
                    request, newRecord.getId(), appointmentId, patientName,
                    editor, "Lỗi SQL: UPDATE medical_records không ảnh hưởng dòng nào");
            return UpdateResult.DB_ERROR;
        }
    }

    // ══════════════════════════════════════════════════
    // PRIVATE — So sánh field-by-field
    // ══════════════════════════════════════════════════

    /**
     * So sánh từng field giữa old và new record.
     *
     * @return JSON string chứa danh sách các field đã thay đổi,
     *         hoặc null nếu không có field nào thay đổi.
     */
    private String buildChangesJson(MedicalRecord old, MedicalRecord newRec) {
        StringBuilder json = new StringBuilder("{");
        int count = 0;

        count += compareField(json, count, "clinical_notes", old.getClinicalNotes(), newRec.getClinicalNotes());
        count += compareField(json, count, "final_diagnosis", old.getFinalDiagnosis(), newRec.getFinalDiagnosis());
        count += compareField(json, count, "treatment_plan", old.getTreatmentPlan(), newRec.getTreatmentPlan());
        count += compareField(json, count, "risk_flags_json", old.getRiskFlagsJson(), newRec.getRiskFlagsJson());

        count += compareDecimal(json, count, "weight_kg", old.getWeightKg(), newRec.getWeightKg());
        count += compareField(json, count, "blood_pressure", old.getBloodPressure(), newRec.getBloodPressure());
        count += compareInt(json, count, "pulse_bpm", old.getPulseBpm(), newRec.getPulseBpm());
        count += compareDecimal(json, count, "temperature_c", old.getTemperatureC(), newRec.getTemperatureC());
        count += compareDecimal(json, count, "height_cm", old.getHeightCm(), newRec.getHeightCm());

        count += compareInt(json, count, "gestational_age_weeks", old.getGestationalAgeWeeks(), newRec.getGestationalAgeWeeks());
        count += compareInt(json, count, "gestational_age_days", old.getGestationalAgeDays(), newRec.getGestationalAgeDays());

        count += compareDecimal(json, count, "fundal_height_cm", old.getFundalHeightCm(), newRec.getFundalHeightCm());
        count += compareInt(json, count, "fetal_heart_rate", old.getFetalHeartRate(), newRec.getFetalHeartRate());
        count += compareField(json, count, "fetal_presentation", old.getFetalPresentation(), newRec.getFetalPresentation());
        count += compareField(json, count, "fetal_position", old.getFetalPosition(), newRec.getFetalPosition());
        count += compareField(json, count, "fetal_movement", old.getFetalMovement(), newRec.getFetalMovement());

        count += compareDecimal(json, count, "cervical_dilation_cm", old.getCervicalDilationCm(), newRec.getCervicalDilationCm());
        count += compareField(json, count, "cervical_effacement", old.getCervicalEffacement(), newRec.getCervicalEffacement());
        count += compareField(json, count, "amniotic_fluid", old.getAmnioticFluid(), newRec.getAmnioticFluid());
        count += compareField(json, count, "presentation_station", old.getPresentationStation(), newRec.getPresentationStation());

        count += compareField(json, count, "edema", old.getEdema(), newRec.getEdema());
        count += compareField(json, count, "proteinuria", old.getProteinuria(), newRec.getProteinuria());
        count += compareBool(json, count, "vaginal_bleeding", old.getVaginalBleeding(), newRec.getVaginalBleeding());
        count += compareBool(json, count, "uterine_contractions", old.getUterineContractions(), newRec.getUterineContractions());

        count += compareDate(json, count, "next_appointment_date", old.getNextAppointmentDate(), newRec.getNextAppointmentDate());
        count += compareField(json, count, "referred_to", old.getReferredTo(), newRec.getReferredTo());

        count += compareField(json, count, "status", old.getStatus(), newRec.getStatus());

        if (count == 0) {
            return null;
        }
        json.append("}");
        return json.toString();
    }

    /**
     * Build JSON chỉ chứa old values của các field đã thay đổi.
     */
    private String buildOldValuesJson(MedicalRecord old, MedicalRecord newRec) {
        return buildValuesJson(old, newRec, true);
    }

    /**
     * Build JSON chỉ chứa new values của các field đã thay đổi.
     */
    private String buildNewValuesJson(MedicalRecord old, MedicalRecord newRec) {
        return buildValuesJson(old, newRec, false);
    }

    private String buildValuesJson(MedicalRecord old, MedicalRecord newRec, boolean isOld) {
        StringBuilder json = new StringBuilder("{");
        int count = 0;

        count += appendChangedField(json, count, "clinical_notes", old.getClinicalNotes(), newRec.getClinicalNotes(), isOld);
        count += appendChangedField(json, count, "final_diagnosis", old.getFinalDiagnosis(), newRec.getFinalDiagnosis(), isOld);
        count += appendChangedField(json, count, "treatment_plan", old.getTreatmentPlan(), newRec.getTreatmentPlan(), isOld);
        count += appendChangedField(json, count, "risk_flags_json", old.getRiskFlagsJson(), newRec.getRiskFlagsJson(), isOld);

        count += appendChangedDecimal(json, count, "weight_kg", old.getWeightKg(), newRec.getWeightKg(), isOld);
        count += appendChangedField(json, count, "blood_pressure", old.getBloodPressure(), newRec.getBloodPressure(), isOld);
        count += appendChangedInt(json, count, "pulse_bpm", old.getPulseBpm(), newRec.getPulseBpm(), isOld);
        count += appendChangedDecimal(json, count, "temperature_c", old.getTemperatureC(), newRec.getTemperatureC(), isOld);
        count += appendChangedDecimal(json, count, "height_cm", old.getHeightCm(), newRec.getHeightCm(), isOld);

        count += appendChangedInt(json, count, "gestational_age_weeks", old.getGestationalAgeWeeks(), newRec.getGestationalAgeWeeks(), isOld);
        count += appendChangedInt(json, count, "gestational_age_days", old.getGestationalAgeDays(), newRec.getGestationalAgeDays(), isOld);

        count += appendChangedDecimal(json, count, "fundal_height_cm", old.getFundalHeightCm(), newRec.getFundalHeightCm(), isOld);
        count += appendChangedInt(json, count, "fetal_heart_rate", old.getFetalHeartRate(), newRec.getFetalHeartRate(), isOld);
        count += appendChangedField(json, count, "fetal_presentation", old.getFetalPresentation(), newRec.getFetalPresentation(), isOld);
        count += appendChangedField(json, count, "fetal_position", old.getFetalPosition(), newRec.getFetalPosition(), isOld);
        count += appendChangedField(json, count, "fetal_movement", old.getFetalMovement(), newRec.getFetalMovement(), isOld);

        count += appendChangedDecimal(json, count, "cervical_dilation_cm", old.getCervicalDilationCm(), newRec.getCervicalDilationCm(), isOld);
        count += appendChangedField(json, count, "cervical_effacement", old.getCervicalEffacement(), newRec.getCervicalEffacement(), isOld);
        count += appendChangedField(json, count, "amniotic_fluid", old.getAmnioticFluid(), newRec.getAmnioticFluid(), isOld);
        count += appendChangedField(json, count, "presentation_station", old.getPresentationStation(), newRec.getPresentationStation(), isOld);

        count += appendChangedField(json, count, "edema", old.getEdema(), newRec.getEdema(), isOld);
        count += appendChangedField(json, count, "proteinuria", old.getProteinuria(), newRec.getProteinuria(), isOld);
        count += appendChangedBool(json, count, "vaginal_bleeding", old.getVaginalBleeding(), newRec.getVaginalBleeding(), isOld);
        count += appendChangedBool(json, count, "uterine_contractions", old.getUterineContractions(), newRec.getUterineContractions(), isOld);

        count += appendChangedDate(json, count, "next_appointment_date", old.getNextAppointmentDate(), newRec.getNextAppointmentDate(), isOld);
        count += appendChangedField(json, count, "referred_to", old.getReferredTo(), newRec.getReferredTo(), isOld);

        count += appendChangedField(json, count, "status", old.getStatus(), newRec.getStatus(), isOld);

        json.append("}");
        return json.toString();
    }

    // ── Compare helpers — trả về 1 nếu có thay đổi, 0 nếu không ──

    private int compareField(StringBuilder json, int count, String fieldName,
                              String oldVal, String newVal) {
        String oldTrimmed = (oldVal != null) ? oldVal.trim() : "";
        String newTrimmed = (newVal != null) ? newVal.trim() : "";
        if (!oldTrimmed.equals(newTrimmed)) {
            if (count > 0) json.append(",");
            json.append("\"").append(fieldName).append("\":{");
            json.append("\"old\":\"").append(escapeJson(oldTrimmed)).append("\",");
            json.append("\"new\":\"").append(escapeJson(newTrimmed)).append("\"}");
            return 1;
        }
        return 0;
    }

    private int compareInt(StringBuilder json, int count, String fieldName,
                            Integer oldVal, Integer newVal) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            json.append("\"").append(fieldName).append("\":{");
            json.append("\"old\":").append(oldVal != null ? String.valueOf(oldVal) : "null").append(",");
            json.append("\"new\":").append(newVal != null ? String.valueOf(newVal) : "null").append("}");
            return 1;
        }
        return 0;
    }

    private int compareDecimal(StringBuilder json, int count, String fieldName,
                                java.math.BigDecimal oldVal, java.math.BigDecimal newVal) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            json.append("\"").append(fieldName).append("\":{");
            json.append("\"old\":").append(oldVal != null ? oldVal.toPlainString() : "null").append(",");
            json.append("\"new\":").append(newVal != null ? newVal.toPlainString() : "null").append("}");
            return 1;
        }
        return 0;
    }

    private int compareBool(StringBuilder json, int count, String fieldName,
                             Boolean oldVal, Boolean newVal) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            json.append("\"").append(fieldName).append("\":{");
            json.append("\"old\":").append(oldVal != null ? oldVal.toString() : "null").append(",");
            json.append("\"new\":").append(newVal != null ? newVal.toString() : "null").append("}");
            return 1;
        }
        return 0;
    }

    private int compareDate(StringBuilder json, int count, String fieldName,
                             java.sql.Date oldVal, java.sql.Date newVal) {
        String oldStr = oldVal != null ? oldVal.toString() : "";
        String newStr = newVal != null ? newVal.toString() : "";
        if (!oldStr.equals(newStr)) {
            if (count > 0) json.append(",");
            json.append("\"").append(fieldName).append("\":{");
            json.append("\"old\":\"").append(oldStr).append("\",");
            json.append("\"new\":\"").append(newStr).append("\"}");
            return 1;
        }
        return 0;
    }

    // ── Append helpers — trả về 1 nếu field có thay đổi ──

    private int appendChangedField(StringBuilder json, int count, String fieldName,
                                    String oldVal, String newVal, boolean isOld) {
        String oldTrimmed = (oldVal != null) ? oldVal.trim() : "";
        String newTrimmed = (newVal != null) ? newVal.trim() : "";
        if (!oldTrimmed.equals(newTrimmed)) {
            if (count > 0) json.append(",");
            String val = isOld ? oldTrimmed : newTrimmed;
            json.append("\"").append(fieldName).append("\":\"").append(escapeJson(val)).append("\"");
            return 1;
        }
        return 0;
    }

    private int appendChangedInt(StringBuilder json, int count, String fieldName,
                                  Integer oldVal, Integer newVal, boolean isOld) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            Integer val = isOld ? oldVal : newVal;
            json.append("\"").append(fieldName).append("\":").append(val != null ? String.valueOf(val) : "null");
            return 1;
        }
        return 0;
    }

    private int appendChangedDecimal(StringBuilder json, int count, String fieldName,
                                      java.math.BigDecimal oldVal, java.math.BigDecimal newVal, boolean isOld) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            java.math.BigDecimal val = isOld ? oldVal : newVal;
            json.append("\"").append(fieldName).append("\":").append(val != null ? val.toPlainString() : "null");
            return 1;
        }
        return 0;
    }

    private int appendChangedBool(StringBuilder json, int count, String fieldName,
                                   Boolean oldVal, Boolean newVal, boolean isOld) {
        if (!Objects.equals(oldVal, newVal)) {
            if (count > 0) json.append(",");
            Boolean val = isOld ? oldVal : newVal;
            json.append("\"").append(fieldName).append("\":").append(val != null ? val.toString() : "null");
            return 1;
        }
        return 0;
    }

    private int appendChangedDate(StringBuilder json, int count, String fieldName,
                                   java.sql.Date oldVal, java.sql.Date newVal, boolean isOld) {
        String oldStr = oldVal != null ? oldVal.toString() : "";
        String newStr = newVal != null ? newVal.toString() : "";
        if (!oldStr.equals(newStr)) {
            if (count > 0) json.append(",");
            String val = isOld ? oldStr : newStr;
            json.append("\"").append(fieldName).append("\":\"").append(val).append("\"");
            return 1;
        }
        return 0;
    }

    /**
     * Escape ký tự đặc biệt cho JSON string value.
     */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
