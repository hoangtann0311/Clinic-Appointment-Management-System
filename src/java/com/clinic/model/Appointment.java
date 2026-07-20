package com.clinic.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class Appointment {
    private int id;
    private int patientId;
    private int doctorId;
    private Integer pregnancyId; // nullable
    private LocalDate appointmentDate;
    private String bookingSource;
    private String symptoms;
    private LocalDate lastMenstrualPeriod; // nullable
    private boolean isEmergency;
    private String status;
    private Integer serviceId; // nullable
    private String queueNumber; // STT, e.g., "SOS-01", "STT-02"
    private String preExamPaymentStatus;
    private String gestationalAge; // E.g. "10 tuần 2 ngày"
    private Integer slotId; // nullable

    // Complex object associations (for receptionist / HEAD)
    private Patient patient;
    private Doctor doctor;
    private ServiceItem service;

    // Transient fields for join results (for doctor / origin/dungdi)
    private String patientName;
    private String serviceName;
    private String timeSlot; // Stores the String representation like "08:00 - 08:20" or "Khẩn cấp (SOS)"

    // Constructors
    public Appointment() {}

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
        this.patientId = patient != null ? patient.getId() : 0;
        this.patientName = patient != null ? patient.getFullName() : "";
        this.doctor = doctor;
        this.doctorId = doctor != null ? doctor.getId() : 0;
        this.service = service;
        this.serviceId = service != null ? service.getId() : null;
        this.serviceName = service != null ? service.getName() : "";
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

    public int getPatientId() {
        if (patientId == 0 && patient != null) return patient.getId();
        return patientId;
    }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public int getDoctorId() {
        if (doctorId == 0 && doctor != null) return doctor.getId();
        return doctorId;
    }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public Integer getPregnancyId() { return pregnancyId; }
    public void setPregnancyId(Integer pregnancyId) { this.pregnancyId = pregnancyId; }

    public LocalDate getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(LocalDate appointmentDate) { this.appointmentDate = appointmentDate; }

    public String getBookingSource() { return bookingSource; }
    public void setBookingSource(String bookingSource) { this.bookingSource = bookingSource; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public LocalDate getLastMenstrualPeriod() { return lastMenstrualPeriod; }
    public void setLastMenstrualPeriod(LocalDate lastMenstrualPeriod) { this.lastMenstrualPeriod = lastMenstrualPeriod; }

    public boolean isEmergency() { return isEmergency; }
    public void setEmergency(boolean emergency) { isEmergency = emergency; }

    public String getStatus() { return status; }
    public void setStatus(String status) {
        this.status = status;
        this.isEmergency = "Emergency_SOS".equals(status);
    }

    public Integer getServiceId() {
        if (serviceId == null && service != null) return service.getId();
        return serviceId;
    }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }

    // Reconciling timeSlot
    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }
    public void setTimeSlot(LocalTime timeSlot) {
        if (timeSlot != null) {
            this.timeSlot = timeSlot.toString();
        } else {
            this.timeSlot = null;
        }
    }

    public String getPatientName() {
        if (patient != null) return patient.getFullName();
        return patientName;
    }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    /** Trả về tên bác sĩ — dùng cho EL: ${appointment.doctorName} */
    public String getDoctorName() {
        if (doctor != null) {
            String name = doctor.getFullName();
            if (name != null) {
                return name.replace("Bác sĩ ", "").replace("BS. ", "").trim();
            }
        }
        return null;
    }

    public String getServiceName() {
        if (service != null) return service.getName();
        return serviceName;
    }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) {
        this.patient = patient;
        if (patient != null) {
            this.patientId = patient.getId();
            this.patientName = patient.getFullName();
        }
    }

    public Doctor getDoctor() { return doctor; }
    public void setDoctor(Doctor doctor) {
        this.doctor = doctor;
        if (doctor != null) {
            this.doctorId = doctor.getId();
        }
    }

    public ServiceItem getService() { return service; }
    public void setService(ServiceItem service) {
        this.service = service;
        if (service != null) {
            this.serviceId = service.getId();
            this.serviceName = service.getName();
        }
    }

    public String getGestationalAge() { return gestationalAge; }
    public void setGestationalAge(String gestationalAge) { this.gestationalAge = gestationalAge; }

    public String getQueueNumber() { return queueNumber; }
    public void setQueueNumber(String queueNumber) { this.queueNumber = queueNumber; }

    public String getPreExamPaymentStatus() { return preExamPaymentStatus; }
    public void setPreExamPaymentStatus(String preExamPaymentStatus) { this.preExamPaymentStatus = preExamPaymentStatus; }

    public Integer getSlotId() { return slotId; }
    public void setSlotId(Integer slotId) { this.slotId = slotId; }

    public boolean isPreExamPaid() {
        return "Paid".equalsIgnoreCase(preExamPaymentStatus);
    }

    @Override
    public String toString() {
        return "Appointment{id=" + id
                + ", patientId=" + getPatientId()
                + ", doctorId=" + getDoctorId()
                + ", date=" + appointmentDate
                + ", time=" + timeSlot
                + ", status='" + status + "'}";
    }
}
