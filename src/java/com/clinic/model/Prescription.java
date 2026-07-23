package com.clinic.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Model ánh xạ bảng [prescriptions] + [prescription_items].
 * Một đơn thuốc gắn với một hồ sơ bệnh án (medical_record).
 */
public class Prescription {

    private int id;
    private int medicalRecordId;
    private String prescriptionCode;   // Mã đơn thuốc (tự sinh hoặc nhập tay)
    private String status;             // draft | issued | cancelled
    private LocalDateTime createdAt;
    private String purchaseDecision;   // Pending | Accepted | Declined
    private LocalDateTime purchaseDecidedAt;
    private Integer purchaseDecidedBy;

    // Danh sách thuốc trong đơn (JOIN prescription_items + medicines)
    private List<PrescriptionItem> items;

    // Trường trung gian
    private String patientName;
    private String appointmentDate;
    private int appointmentId;
    private String doctorName;
    private BigDecimal totalAmount;

    public Prescription() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMedicalRecordId() { return medicalRecordId; }
    public void setMedicalRecordId(int medicalRecordId) { this.medicalRecordId = medicalRecordId; }

    public String getPrescriptionCode() { return prescriptionCode; }
    public void setPrescriptionCode(String prescriptionCode) { this.prescriptionCode = prescriptionCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getPurchaseDecision() { return purchaseDecision; }
    public void setPurchaseDecision(String purchaseDecision) { this.purchaseDecision = purchaseDecision; }

    public LocalDateTime getPurchaseDecidedAt() { return purchaseDecidedAt; }
    public void setPurchaseDecidedAt(LocalDateTime purchaseDecidedAt) { this.purchaseDecidedAt = purchaseDecidedAt; }

    public Integer getPurchaseDecidedBy() { return purchaseDecidedBy; }
    public void setPurchaseDecidedBy(Integer purchaseDecidedBy) { this.purchaseDecidedBy = purchaseDecidedBy; }

    public List<PrescriptionItem> getItems() { return items; }
    public void setItems(List<PrescriptionItem> items) { this.items = items; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(String appointmentDate) { this.appointmentDate = appointmentDate; }

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
}
