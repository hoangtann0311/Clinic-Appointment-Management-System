package com.clinic.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Model ánh xạ bảng pregnancies — theo dõi một thai kỳ của bệnh nhân.
 * Một bệnh nhân có thể có nhiều thai kỳ (qua các năm); mỗi appointment
 * có thể gắn vào một pregnancy cụ thể (appointments.pregnancy_id).
 */
public class Pregnancy {

    private int id;
    private Integer patientId;
    private LocalDate startDate;
    private LocalDate estimatedDueDate;
    private LocalDate actualDeliveryDate;
    private String pregnancyStatus;   // VD: 'active', 'delivered', 'miscarried', 'terminated'
    private Integer fetusCount;
    private String notes;
    private LocalDateTime createdAt;   // Ngày giờ hồ sơ thai kỳ được tạo

    // Trường tiện ích từ JOIN (không có cột riêng trong bảng pregnancies)
    private String patientName;
    private int visitCount;           // số lần khám đã gắn với thai kỳ này

    public Pregnancy() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getPatientId() { return patientId; }
    public void setPatientId(Integer patientId) { this.patientId = patientId; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEstimatedDueDate() { return estimatedDueDate; }
    public void setEstimatedDueDate(LocalDate estimatedDueDate) { this.estimatedDueDate = estimatedDueDate; }

    public LocalDate getActualDeliveryDate() { return actualDeliveryDate; }
    public void setActualDeliveryDate(LocalDate actualDeliveryDate) { this.actualDeliveryDate = actualDeliveryDate; }

    public String getPregnancyStatus() { return pregnancyStatus; }
    public void setPregnancyStatus(String pregnancyStatus) { this.pregnancyStatus = pregnancyStatus; }

    public Integer getFetusCount() { return fetusCount; }
    public void setFetusCount(Integer fetusCount) { this.fetusCount = fetusCount; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    /** Chuỗi ngày giờ tạo đã format sẵn (dd/MM/yyyy HH:mm) để hiển thị trực tiếp trong JSP. */
    public String getCreatedAtFormatted() {
        if (createdAt == null) return null;
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public int getVisitCount() { return visitCount; }
    public void setVisitCount(int visitCount) { this.visitCount = visitCount; }

    /**
     * Tuổi thai hiện tại (số tuần), tính từ startDate (kỳ kinh cuối / ngày bắt đầu thai kỳ)
     * tới hôm nay. Trả về -1 nếu không có startDate.
     */
    public int getCurrentGestationalWeeks() {
        if (startDate == null) return -1;
        long days = java.time.temporal.ChronoUnit.DAYS.between(startDate, LocalDate.now());
        if (days < 0) return -1;
        return (int) (days / 7);
    }

    /** Số ngày còn lại tới ngày dự sinh (có thể âm nếu đã quá ngày dự sinh). */
    public Long getDaysUntilDueDate() {
        if (estimatedDueDate == null) return null;
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), estimatedDueDate);
    }
}