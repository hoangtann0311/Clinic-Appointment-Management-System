package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng medical_records — hồ sơ bệnh án.
 * Mỗi appointment có thể có 0 hoặc 1 medical record.
 */
public class MedicalRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Integer appointmentId;    // FK → appointments.id
    private String clinicalNotes;     // ghi chú lâm sàng (NVARCHAR(MAX))
    private String finalDiagnosis;    // chuẩn đoán cuối cùng (NVARCHAR(MAX))
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer updatedBy;        // FK → users.id (bác sĩ sửa)

    public MedicalRecord() {
    }

    // ── Getters & Setters ──

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }

    public String getClinicalNotes() { return clinicalNotes; }
    public void setClinicalNotes(String clinicalNotes) { this.clinicalNotes = clinicalNotes; }

    public String getFinalDiagnosis() { return finalDiagnosis; }
    public void setFinalDiagnosis(String finalDiagnosis) { this.finalDiagnosis = finalDiagnosis; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "id=" + id +
                ", appointmentId=" + appointmentId +
                ", finalDiagnosis='" + finalDiagnosis + '\'' +
                '}';
    }
}
