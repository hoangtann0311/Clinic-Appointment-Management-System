package com.nhom3.ocss.models;

import java.time.LocalDate;

public class Appointment {
    private int id;
    private String patientName; // Backwards compatibility & convenience
    private Patient patient;
    private Doctor doctor;
    private ServiceItem service;
    private LocalDate appointmentDate;
    private String timeSlot; // E.g., "08:00 - 08:20"
    private String symptoms;
    private LocalDate lastMenstrualPeriod;
    private String gestationalAge; // E.g. "10 tuần 2 ngày"
    private boolean isEmergency;
    private String queueNumber; // STT, e.g., "SOS-01", "STT-02"
    private String status; // Pending, Confirmed, Waiting, Emergency_SOS, InProgress, SUCCESS, Cancelled, NoShow
    private String preExamPaymentStatus;

    public Appointment(int id, String patientName, String symptoms, String status) {
        this.id = id;
        this.patientName = patientName;
        this.symptoms = symptoms;
        this.status = status;
        this.isEmergency = "Emergency_SOS".equals(status);
        this.appointmentDate = LocalDate.now();
        this.timeSlot = "08:00 - 08:20";
    }

    public Appointment(int id, Patient patient, Doctor doctor, ServiceItem service, LocalDate appointmentDate, 
                       String timeSlot, String symptoms, LocalDate lastMenstrualPeriod, String gestationalAge, 
                       boolean isEmergency, String status) {
        this.id = id;
        this.patient = patient;
        this.patientName = patient != null ? patient.getFullName() : "";
        this.doctor = doctor;
        this.service = service;
        this.appointmentDate = appointmentDate;
        this.timeSlot = timeSlot;
        this.symptoms = symptoms;
        this.lastMenstrualPeriod = lastMenstrualPeriod;
        this.gestationalAge = gestationalAge;
        this.isEmergency = isEmergency;
        this.status = status;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getPatientName() { 
        if (patient != null) return patient.getFullName();
        return patientName; 
    }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { 
        this.patient = patient; 
        if (patient != null) this.patientName = patient.getFullName();
    }
    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) { this.doctor = doctor; }
    public ServiceItem getService() { return service; }
    public void setService(ServiceItem service) { this.service = service; }
    public LocalDate getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(LocalDate appointmentDate) { this.appointmentDate = appointmentDate; }
    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }
    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }
    public LocalDate getLastMenstrualPeriod() { return lastMenstrualPeriod; }
    public void setLastMenstrualPeriod(LocalDate lastMenstrualPeriod) { this.lastMenstrualPeriod = lastMenstrualPeriod; }
    public String getGestationalAge() { return gestationalAge; }
    public void setGestationalAge(String gestationalAge) { this.gestationalAge = gestationalAge; }
    public boolean isEmergency() { return isEmergency; }
    public void setEmergency(boolean emergency) { isEmergency = emergency; }
    public String getQueueNumber() { return queueNumber; }
    public void setQueueNumber(String queueNumber) { this.queueNumber = queueNumber; }
    public String getStatus() { return status; }
    public void setStatus(String status) { 
        this.status = status; 
        this.isEmergency = "Emergency_SOS".equals(status);
    }
    public String getPreExamPaymentStatus() {
        return preExamPaymentStatus;
    }

    public void setPreExamPaymentStatus(String preExamPaymentStatus) {
        this.preExamPaymentStatus = preExamPaymentStatus;
    }

    public boolean isPreExamPaid() {
        return "Paid".equalsIgnoreCase(preExamPaymentStatus);
    }
}
