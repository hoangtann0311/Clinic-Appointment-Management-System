package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng medical_records — hồ sơ bệnh án Sản khoa.
 * Mỗi appointment có thể có 0 hoặc 1 medical record.
 *
 * <p>Bao gồm đầy đủ các trường: dấu hiệu sinh tồn, thai kỳ,
 * cổ tử cung & ối, triệu chứng, chẩn đoán & điều trị.
 */
public class MedicalRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    // ──────────── Khóa & Liên kết ────────────
    private int id;
    private Integer appointmentId;       // FK → appointments.id

    // ──────────── Dấu hiệu sinh tồn ────────────
    private BigDecimal weightKg;         // cân nặng (kg) — DECIMAL(5,1)
    private String bloodPressure;        // huyết áp — NVARCHAR(20)
    private Integer pulseBpm;            // mạch (bpm) — INT
    private BigDecimal temperatureC;     // nhiệt độ (°C) — DECIMAL(4,1)
    private BigDecimal heightCm;         // chiều cao (cm) — DECIMAL(5,1)

    // ──────────── Thai kỳ ────────────
    private Integer gestationalAgeWeeks; // tuổi thai (tuần) — INT
    private Integer gestationalAgeDays;  // tuổi thai (ngày lẻ) — INT
    private BigDecimal fundalHeightCm;   // chiều cao tử cung (cm) — DECIMAL(5,1)
    private Integer fetalHeartRate;      // nhịp tim thai (bpm) — INT
    private String fetalPresentation;    // ngôi thai — NVARCHAR(50)
    private String fetalPosition;        // vị trí thai — NVARCHAR(50)
    private String fetalMovement;        // cử động thai — NVARCHAR(50)

    // ──────────── Cổ tử cung & Ối ────────────
    private BigDecimal cervicalDilationCm; // độ mở CTC (cm) — DECIMAL(4,1)
    private String cervicalEffacement;     // độ xóa CTC — NVARCHAR(50)
    private String amnioticFluid;          // nước ối — NVARCHAR(50)
    private String presentationStation;    // lọt ngôi — NVARCHAR(50)

    // ──────────── Triệu chứng ────────────
    private String edema;                // phù — NVARCHAR(50)
    private String proteinuria;          // protein niệu — NVARCHAR(20)
    private Boolean vaginalBleeding;     // chảy máu âm đạo — BIT
    private Boolean uterineContractions; // co thắt tử cung — BIT

    // ──────────── Chẩn đoán & Điều trị ────────────
    private String clinicalNotes;        // ghi chú lâm sàng — NVARCHAR(MAX)
    private String finalDiagnosis;       // chẩn đoán cuối cùng — NVARCHAR(MAX)
    private String riskFlagsJson;        // cờ nguy cơ (JSON) — NVARCHAR(MAX)
    private String treatmentPlan;        // kế hoạch điều trị — NVARCHAR(MAX)
    private Date nextAppointmentDate;    // ngày hẹn tái khám — DATE
    private String referredTo;           // giới thiệu đến — NVARCHAR(200)

    // ──────────── Meta ────────────
    private String status;               // trạng thái — VARCHAR(20), default 'final'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer updatedBy;           // FK → users.id (bác sĩ sửa)

    public MedicalRecord() {
    }

    // ══════════════════════════════════════════════════
    // Getters & Setters
    // ══════════════════════════════════════════════════

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }

    // ── Dấu hiệu sinh tồn ──

    public BigDecimal getWeightKg() { return weightKg; }
    public void setWeightKg(BigDecimal weightKg) { this.weightKg = weightKg; }

    public String getBloodPressure() { return bloodPressure; }
    public void setBloodPressure(String bloodPressure) { this.bloodPressure = bloodPressure; }

    public Integer getPulseBpm() { return pulseBpm; }
    public void setPulseBpm(Integer pulseBpm) { this.pulseBpm = pulseBpm; }

    public BigDecimal getTemperatureC() { return temperatureC; }
    public void setTemperatureC(BigDecimal temperatureC) { this.temperatureC = temperatureC; }

    public BigDecimal getHeightCm() { return heightCm; }
    public void setHeightCm(BigDecimal heightCm) { this.heightCm = heightCm; }

    // ── Thai kỳ ──

    public Integer getGestationalAgeWeeks() { return gestationalAgeWeeks; }
    public void setGestationalAgeWeeks(Integer gestationalAgeWeeks) { this.gestationalAgeWeeks = gestationalAgeWeeks; }

    public Integer getGestationalAgeDays() { return gestationalAgeDays; }
    public void setGestationalAgeDays(Integer gestationalAgeDays) { this.gestationalAgeDays = gestationalAgeDays; }

    public BigDecimal getFundalHeightCm() { return fundalHeightCm; }
    public void setFundalHeightCm(BigDecimal fundalHeightCm) { this.fundalHeightCm = fundalHeightCm; }

    public Integer getFetalHeartRate() { return fetalHeartRate; }
    public void setFetalHeartRate(Integer fetalHeartRate) { this.fetalHeartRate = fetalHeartRate; }

    public String getFetalPresentation() { return fetalPresentation; }
    public void setFetalPresentation(String fetalPresentation) { this.fetalPresentation = fetalPresentation; }

    public String getFetalPosition() { return fetalPosition; }
    public void setFetalPosition(String fetalPosition) { this.fetalPosition = fetalPosition; }

    public String getFetalMovement() { return fetalMovement; }
    public void setFetalMovement(String fetalMovement) { this.fetalMovement = fetalMovement; }

    // ── Cổ tử cung & Ối ──

    public BigDecimal getCervicalDilationCm() { return cervicalDilationCm; }
    public void setCervicalDilationCm(BigDecimal cervicalDilationCm) { this.cervicalDilationCm = cervicalDilationCm; }

    public String getCervicalEffacement() { return cervicalEffacement; }
    public void setCervicalEffacement(String cervicalEffacement) { this.cervicalEffacement = cervicalEffacement; }

    public String getAmnioticFluid() { return amnioticFluid; }
    public void setAmnioticFluid(String amnioticFluid) { this.amnioticFluid = amnioticFluid; }

    public String getPresentationStation() { return presentationStation; }
    public void setPresentationStation(String presentationStation) { this.presentationStation = presentationStation; }

    // ── Triệu chứng ──

    public String getEdema() { return edema; }
    public void setEdema(String edema) { this.edema = edema; }

    public String getProteinuria() { return proteinuria; }
    public void setProteinuria(String proteinuria) { this.proteinuria = proteinuria; }

    public Boolean getVaginalBleeding() { return vaginalBleeding; }
    public void setVaginalBleeding(Boolean vaginalBleeding) { this.vaginalBleeding = vaginalBleeding; }

    public Boolean getUterineContractions() { return uterineContractions; }
    public void setUterineContractions(Boolean uterineContractions) { this.uterineContractions = uterineContractions; }

    // ── Chẩn đoán & Điều trị ──

    public String getClinicalNotes() { return clinicalNotes; }
    public void setClinicalNotes(String clinicalNotes) { this.clinicalNotes = clinicalNotes; }

    public String getFinalDiagnosis() { return finalDiagnosis; }
    public void setFinalDiagnosis(String finalDiagnosis) { this.finalDiagnosis = finalDiagnosis; }

    public String getRiskFlagsJson() { return riskFlagsJson; }
    public void setRiskFlagsJson(String riskFlagsJson) { this.riskFlagsJson = riskFlagsJson; }

    public String getTreatmentPlan() { return treatmentPlan; }
    public void setTreatmentPlan(String treatmentPlan) { this.treatmentPlan = treatmentPlan; }

    public Date getNextAppointmentDate() { return nextAppointmentDate; }
    public void setNextAppointmentDate(Date nextAppointmentDate) { this.nextAppointmentDate = nextAppointmentDate; }

    public String getReferredTo() { return referredTo; }
    public void setReferredTo(String referredTo) { this.referredTo = referredTo; }

    // ── Meta ──

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    // ── Tiện ích kiểm tra trạng thái ──

    public boolean isDraft() { return "draft".equalsIgnoreCase(status); }
    public boolean isFinal() { return "final".equalsIgnoreCase(status); }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "id=" + id +
                ", appointmentId=" + appointmentId +
                ", finalDiagnosis='" + finalDiagnosis + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
