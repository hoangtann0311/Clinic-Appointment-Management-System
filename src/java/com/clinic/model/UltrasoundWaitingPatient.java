package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * View model for one patient waiting for an ultrasound test order.
 */
public class UltrasoundWaitingPatient implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DecimalFormat MONEY_FORMATTER = new DecimalFormat("#,##0");

    private int orderId;
    private Integer medicalRecordId;
    private Integer appointmentId;
    private Integer patientId;
    private String patientName;
    private String phoneNumber;
    private Date dateOfBirth;
    private Date appointmentDate;
    private Time timeSlot;
    private Integer serviceId;
    private String serviceName;
    private BigDecimal price;
    private String doctorName;
    private String symptoms;
    private boolean emergency;
    private boolean requiresFasting;
    private boolean requiresFullBladder;
    private String status;
    private Timestamp createdAt;

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public Integer getMedicalRecordId() {
        return medicalRecordId;
    }

    public void setMedicalRecordId(Integer medicalRecordId) {
        this.medicalRecordId = medicalRecordId;
    }

    public Integer getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(Integer appointmentId) {
        this.appointmentId = appointmentId;
    }

    public Integer getPatientId() {
        return patientId;
    }

    public void setPatientId(Integer patientId) {
        this.patientId = patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public Date getAppointmentDate() {
        return appointmentDate;
    }

    public void setAppointmentDate(Date appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public Time getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(Time timeSlot) {
        this.timeSlot = timeSlot;
    }

    public Integer getServiceId() {
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }

    public boolean isEmergency() {
        return emergency;
    }

    public void setEmergency(boolean emergency) {
        this.emergency = emergency;
    }

    public boolean isRequiresFasting() {
        return requiresFasting;
    }

    public void setRequiresFasting(boolean requiresFasting) {
        this.requiresFasting = requiresFasting;
    }

    public boolean isRequiresFullBladder() {
        return requiresFullBladder;
    }

    public void setRequiresFullBladder(boolean requiresFullBladder) {
        this.requiresFullBladder = requiresFullBladder;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAppointmentDateText() {
        return appointmentDate != null ? appointmentDate.toLocalDate().format(DATE_FORMATTER) : "Chưa xếp lịch";
    }

    public String getTimeSlotText() {
        return timeSlot != null ? timeSlot.toLocalTime().format(TIME_FORMATTER) : "--:--";
    }

    public String getCreatedAtText() {
        return createdAt != null ? createdAt.toLocalDateTime().format(DATE_TIME_FORMATTER) : "Chưa rõ";
    }

    public String getDateOfBirthText() {
        return dateOfBirth != null ? dateOfBirth.toLocalDate().format(DATE_FORMATTER) : "Chưa cập nhật";
    }

    public String getAgeText() {
        if (dateOfBirth == null) {
            return "Chưa rõ tuổi";
        }
        long years = ChronoUnit.YEARS.between(dateOfBirth.toLocalDate(), LocalDate.now());
        return years >= 0 ? years + " tuổi" : "Chưa rõ tuổi";
    }

    public String getPriceText() {
        return price != null ? MONEY_FORMATTER.format(price) + " VND" : "Chưa có giá";
    }
}
