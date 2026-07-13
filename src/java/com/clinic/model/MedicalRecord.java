package com.clinic.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Model ánh xạ bảng [medical_records] — chuyên khoa Phụ Sản.
 */
public class MedicalRecord {

    // ── Khóa & liên kết ─────────────────────────────────────────────────────
    private int    id;
    private int    appointmentId;
    private LocalDateTime createdAt;

    // ── Ghi chú & chẩn đoán (cột cũ giữ lại) ───────────────────────────────
    private String clinicalNotes;
    private String finalDiagnosis;

    // ── Sinh hiệu mẹ ────────────────────────────────────────────────────────
    private Double  weightKg;
    private String  bloodPressure;
    private Integer pulseBpm;
    private Double  temperatureC;
    private Double  heightCm;

    // ── Thông tin thai kỳ ───────────────────────────────────────────────────
    private Integer gestationalAgeWeeks;
    private Integer gestationalAgeDays;
    private Double  fundalHeightCm;
    private Integer fetalHeartRate;
    private String  fetalPresentation;
    private String  fetalPosition;
    private String  fetalMovement;

    // ── Khám sản khoa ───────────────────────────────────────────────────────
    private Double  cervicalDilationCm;
    private String  cervicalEffacement;
    private String  amnioticFluid;
    private String  presentationStation;

    // ── Dấu hiệu nguy hiểm ──────────────────────────────────────────────────
    private String  edema;
    private String  proteinuria;
    private Boolean vaginalBleeding;
    private Boolean uterineContractions;
    private String  riskFlagsJson;

    // ── Kế hoạch điều trị ───────────────────────────────────────────────────
    private String    treatmentPlan;
    private LocalDate nextAppointmentDate;
    private String    referredTo;
    private String    status;   // 'draft' = đang chờ XN, 'final' = hoàn tất

    // ── Trường JOIN (không lưu DB) ──────────────────────────────────────────
    private String  patientName;
    private String  appointmentDate;
    private String  timeSlot;
    private String  symptoms;
    private String  lastMenstrualPeriod;
    private Integer pregnancyId;

    public MedicalRecord() {}

    // ── Getters / Setters ────────────────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int v) { this.appointmentId = v; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    public String getClinicalNotes() { return clinicalNotes; }
    public void setClinicalNotes(String v) { this.clinicalNotes = v; }

    public String getFinalDiagnosis() { return finalDiagnosis; }
    public void setFinalDiagnosis(String v) { this.finalDiagnosis = v; }

    public Double getWeightKg() { return weightKg; }
    public void setWeightKg(Double v) { this.weightKg = v; }

    public String getBloodPressure() { return bloodPressure; }
    public void setBloodPressure(String v) { this.bloodPressure = v; }

    public Integer getPulseBpm() { return pulseBpm; }
    public void setPulseBpm(Integer v) { this.pulseBpm = v; }

    public Double getTemperatureC() { return temperatureC; }
    public void setTemperatureC(Double v) { this.temperatureC = v; }

    public Double getHeightCm() { return heightCm; }
    public void setHeightCm(Double v) { this.heightCm = v; }

    public Integer getGestationalAgeWeeks() { return gestationalAgeWeeks; }
    public void setGestationalAgeWeeks(Integer v) { this.gestationalAgeWeeks = v; }

    public Integer getGestationalAgeDays() { return gestationalAgeDays; }
    public void setGestationalAgeDays(Integer v) { this.gestationalAgeDays = v; }

    public Double getFundalHeightCm() { return fundalHeightCm; }
    public void setFundalHeightCm(Double v) { this.fundalHeightCm = v; }

    public Integer getFetalHeartRate() { return fetalHeartRate; }
    public void setFetalHeartRate(Integer v) { this.fetalHeartRate = v; }

    public String getFetalPresentation() { return fetalPresentation; }
    public void setFetalPresentation(String v) { this.fetalPresentation = v; }

    public String getFetalPosition() { return fetalPosition; }
    public void setFetalPosition(String v) { this.fetalPosition = v; }

    public String getFetalMovement() { return fetalMovement; }
    public void setFetalMovement(String v) { this.fetalMovement = v; }

    public Double getCervicalDilationCm() { return cervicalDilationCm; }
    public void setCervicalDilationCm(Double v) { this.cervicalDilationCm = v; }

    public String getCervicalEffacement() { return cervicalEffacement; }
    public void setCervicalEffacement(String v) { this.cervicalEffacement = v; }

    public String getAmnioticFluid() { return amnioticFluid; }
    public void setAmnioticFluid(String v) { this.amnioticFluid = v; }

    public String getPresentationStation() { return presentationStation; }
    public void setPresentationStation(String v) { this.presentationStation = v; }

    public String getEdema() { return edema; }
    public void setEdema(String v) { this.edema = v; }

    public String getProteinuria() { return proteinuria; }
    public void setProteinuria(String v) { this.proteinuria = v; }

    public Boolean getVaginalBleeding() { return vaginalBleeding; }
    public void setVaginalBleeding(Boolean v) { this.vaginalBleeding = v; }

    public Boolean getUterineContractions() { return uterineContractions; }
    public void setUterineContractions(Boolean v) { this.uterineContractions = v; }

    public String getRiskFlagsJson() { return riskFlagsJson; }
    public void setRiskFlagsJson(String v) { this.riskFlagsJson = v; }

    public String getTreatmentPlan() { return treatmentPlan; }
    public void setTreatmentPlan(String v) { this.treatmentPlan = v; }

    public LocalDate getNextAppointmentDate() { return nextAppointmentDate; }
    public void setNextAppointmentDate(LocalDate v) { this.nextAppointmentDate = v; }

    public String getReferredTo() { return referredTo; }
    public void setReferredTo(String v) { this.referredTo = v; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public boolean isDraft()  { return "draft".equals(status); }
    public boolean isFinal()  { return status == null || "final".equals(status); }

    public String getPatientName() { return patientName; }
    public void setPatientName(String v) { this.patientName = v; }

    public String getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(String v) { this.appointmentDate = v; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String v) { this.timeSlot = v; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String v) { this.symptoms = v; }

    public String getLastMenstrualPeriod() { return lastMenstrualPeriod; }
    public void setLastMenstrualPeriod(String v) { this.lastMenstrualPeriod = v; }

    public Integer getPregnancyId() { return pregnancyId; }
    public void setPregnancyId(Integer v) { this.pregnancyId = v; }

    /** Tiện ích: hiển thị tuổi thai */
    public String getGestationalAgeDisplay() {
        if (gestationalAgeWeeks == null) return "—";
        String s = gestationalAgeWeeks + " tuần";
        if (gestationalAgeDays != null && gestationalAgeDays > 0)
            s += " " + gestationalAgeDays + " ngày";
        return s;
    }

    /** Tiện ích: có dấu hiệu nguy hiểm không */
    public boolean hasRisk() {
        return Boolean.TRUE.equals(vaginalBleeding)
            || Boolean.TRUE.equals(uterineContractions)
            || "Toàn thân".equals(edema)
            || "3+".equals(proteinuria)
            || "2+".equals(proteinuria);
    }
}