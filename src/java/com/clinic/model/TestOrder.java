package com.clinic.model;

import java.time.LocalDateTime;

/**
 * Ánh xạ bảng test_orders — chỉ định xét nghiệm của bác sĩ.
 *
 * test_orders: id, medical_record_id, doctor_id, service_id, status, created_at
 */
public class TestOrder {

    public static final String STATUS_PENDING   = "pending";    // chờ lấy mẫu
    public static final String STATUS_COMPLETED = "completed";  // đã có kết quả
    public static final String STATUS_CANCELLED = "cancelled";  // hủy

    private int id;
    private int medicalRecordId;
    private int doctorId;
    private int serviceId;
    private String status;
    private LocalDateTime createdAt;

    // Trường tiện ích từ JOIN
    private String serviceName;
    private String serviceCode;
    private java.math.BigDecimal servicePrice;
    private boolean requiresFasting;



    // Trường tiện ích cho trang KTV
    private String patientName;
    private String apptDate;

    public TestOrder() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMedicalRecordId() { return medicalRecordId; }
    public void setMedicalRecordId(int medicalRecordId) { this.medicalRecordId = medicalRecordId; }

    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public String getServiceCode() { return serviceCode; }
    public void setServiceCode(String serviceCode) { this.serviceCode = serviceCode; }

    public java.math.BigDecimal getServicePrice() { return servicePrice; }
    public void setServicePrice(java.math.BigDecimal servicePrice) { this.servicePrice = servicePrice; }

    public boolean isRequiresFasting() { return requiresFasting; }
    public void setRequiresFasting(boolean requiresFasting) { this.requiresFasting = requiresFasting; }



    public boolean isPending()   { return STATUS_PENDING.equals(status); }
    public boolean isCompleted() { return STATUS_COMPLETED.equals(status); }
    public boolean isCancelled() { return STATUS_CANCELLED.equals(status); }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getApptDate() { return apptDate; }
    public void setApptDate(String apptDate) { this.apptDate = apptDate; }
}