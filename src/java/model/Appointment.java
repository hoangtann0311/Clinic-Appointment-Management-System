package com.clinic.model;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Model ánh xạ bảng [appointments].
 * Bao gồm các trường từ DB + trường trung gian để hiển thị.
 */
public class Appointment {

    private int id;
    private int patientId;
    private int doctorId;
    private Integer pregnancyId;       // nullable
    private LocalDate appointmentDate;
    private String bookingSource;
    private String symptoms;
    private LocalDate lastMenstrualPeriod; // nullable
    private boolean isEmergency;
    private String status;
    private Integer serviceId;         // nullable
    private LocalTime timeSlot;

    // Trường trung gian (không map trực tiếp từ bảng appointments)
    private String patientName;        // JOIN từ users.full_name
    private String serviceName;        // JOIN từ services.name (nếu có)

    public Appointment() {}

    // ── id ──────────────────────────────────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    // ── patientId ────────────────────────────────────────────────────────────
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    // ── doctorId ─────────────────────────────────────────────────────────────
    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    // ── pregnancyId ──────────────────────────────────────────────────────────
    public Integer getPregnancyId() { return pregnancyId; }
    public void setPregnancyId(Integer pregnancyId) { this.pregnancyId = pregnancyId; }

    // ── appointmentDate ──────────────────────────────────────────────────────
    public LocalDate getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(LocalDate appointmentDate) { this.appointmentDate = appointmentDate; }

    // ── bookingSource ────────────────────────────────────────────────────────
    public String getBookingSource() { return bookingSource; }
    public void setBookingSource(String bookingSource) { this.bookingSource = bookingSource; }

    // ── symptoms ─────────────────────────────────────────────────────────────
    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    // ── lastMenstrualPeriod ──────────────────────────────────────────────────
    public LocalDate getLastMenstrualPeriod() { return lastMenstrualPeriod; }
    public void setLastMenstrualPeriod(LocalDate lastMenstrualPeriod) { this.lastMenstrualPeriod = lastMenstrualPeriod; }

    // ── isEmergency ──────────────────────────────────────────────────────────
    public boolean isEmergency() { return isEmergency; }
    public void setEmergency(boolean emergency) { isEmergency = emergency; }

    // ── status ───────────────────────────────────────────────────────────────
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // ── serviceId ────────────────────────────────────────────────────────────
    public Integer getServiceId() { return serviceId; }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }

    // ── timeSlot ─────────────────────────────────────────────────────────────
    public LocalTime getTimeSlot() { return timeSlot; }
    public void setTimeSlot(LocalTime timeSlot) { this.timeSlot = timeSlot; }

    // ── transient fields ─────────────────────────────────────────────────────
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    @Override
    public String toString() {
        return "Appointment{id=" + id
                + ", patientId=" + patientId
                + ", doctorId=" + doctorId
                + ", date=" + appointmentDate
                + ", time=" + timeSlot
                + ", status='" + status + "'}";
    }
}