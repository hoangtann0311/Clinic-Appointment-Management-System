package com.clinic.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class Appointment {
    private int id;
    private int patientId;
    private int doctorId;
    private Integer pregnancyId; // nullable
    private LocalDate appointmentDate;
    private String bookingSource;
    private String symptoms;
    private LocalDate lastMenstrualPeriod; // nullable
    private boolean isPriority;
    private String status;
    private Integer serviceId; // nullable
    private String queueNumber; // Số thứ tự tiếp đón, e.g. "STT-02"
    private String priorityReason;
    private LocalDateTime prioritizedAt;
    private Integer prioritizedBy;
    private String prioritizedByName;
    private String preExamPaymentStatus;
    private String gestationalAge; // E.g. "10 tuần 2 ngày"
    private String timeSlot; // Giờ bắt đầu ca (HH:mm) — chỉ dùng để sắp xếp

    // Ca làm việc (join từ shifts)
    private String shiftName;  // VD: "Ca Sáng"
    private String shiftStart; // VD: "07:00"
    private String shiftEnd;   // VD: "12:00"

    // Thời điểm bệnh nhân/lễ tân đặt lịch
    private java.sql.Timestamp bookedAt;

    private Integer slotId; // nullable (= schedule_id sau khi migrate)
    private LocalDateTime createdAt;

    // Complex object associations (for receptionist / HEAD)
    private Patient patient;
    private Doctor doctor;
    private ServiceItem service;

    // Transient fields for join results (for doctor / origin/dungdi)
    private String patientName;
    private String serviceName;


    // Constructors
    public Appointment() {}

    public Appointment(int id, String patientName, String symptoms, String status) {
        this.id = id;
        this.patientName = patientName;
        this.symptoms = symptoms;
        this.status = status;
        this.appointmentDate = LocalDate.now();
        this.timeSlot = null; // sẽ được set từ schedule/shift khi lưu
    }

    public Appointment(int id, Patient patient, Doctor doctor, ServiceItem service, LocalDate appointmentDate, 
                       String timeSlot, String symptoms, LocalDate lastMenstrualPeriod, String gestationalAge, 
                       boolean isPriority, String status) {
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
        this.isPriority = isPriority;
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

    public boolean isPriority() { return isPriority; }
    public void setPriority(boolean priority) { isPriority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getServiceId() {
        if (serviceId == null && service != null) return service.getId();
        return serviceId;
    }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }

    /**
     * Trả về giờ bắt đầu ca dạng HH:mm để hiển thị.
     * Không còn logic "+20 phút" vì hệ thống đã chuyển sang ca làm việc.
     * Dùng getShiftLabel() để hiển thị đầy đủ tên ca + giờ.
     */
    public String getTimeSlot() {
        if (timeSlot == null || timeSlot.isBlank()) return "—";
        String ts = timeSlot.trim();
        // Chỉ lấy phần HH:mm (bỏ seconds nếu có)
        if (ts.matches("^\\d{1,2}:\\d{2}(:\\d{2}(\\.\\d+)?)?$")) {
            String[] parts = ts.split(":");
            try {
                int hour = Integer.parseInt(parts[0]);
                int minute = Integer.parseInt(parts[1]);
                return String.format("%02d:%02d", hour, minute);
            } catch (Exception e) {
                return ts;
            }
        }
        return ts;
    }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }
    public void setTimeSlot(LocalTime timeSlot) {
        if (timeSlot != null) {
            this.timeSlot = timeSlot.toString();
        } else {
            this.timeSlot = null;
        }
    }

    /** Trả về nhãn ca đầy đủ: "Ca Sáng (07:00–12:00)" hoặc chỉ giờ bắt đầu nếu không có thông tin shift. */
    public String getShiftLabel() {
        if (shiftName != null && !shiftName.isBlank()) {
            if (shiftStart != null && shiftEnd != null) {
                return shiftName + " (" + shiftStart + "–" + shiftEnd + ")";
            }
            return shiftName;
        }
        String ts = getTimeSlot();
        return "—".equals(ts) ? "—" : "Ca khám " + ts;
    }

    // Shift getters/setters
    public String getShiftName()  { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }
    public String getShiftStart() { return shiftStart; }
    public void setShiftStart(String shiftStart) { this.shiftStart = shiftStart; }
    public String getShiftEnd()   { return shiftEnd; }
    public void setShiftEnd(String shiftEnd) { this.shiftEnd = shiftEnd; }

    // bookedAt
    public java.sql.Timestamp getBookedAt() { return bookedAt; }
    public void setBookedAt(java.sql.Timestamp bookedAt) { this.bookedAt = bookedAt; }
    /** Đặt lúc: 09:45 27/07/2026 */
    public String getBookedAtDisplay() {
        if (bookedAt == null) return "";
        java.time.LocalDateTime ldt = bookedAt.toLocalDateTime();
        return ldt.format(DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy"));
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

    public String getPriorityReason() { return priorityReason; }
    public void setPriorityReason(String priorityReason) { this.priorityReason = priorityReason; }

    public LocalDateTime getPrioritizedAt() { return prioritizedAt; }
    public void setPrioritizedAt(LocalDateTime prioritizedAt) { this.prioritizedAt = prioritizedAt; }

    public Integer getPrioritizedBy() { return prioritizedBy; }
    public void setPrioritizedBy(Integer prioritizedBy) { this.prioritizedBy = prioritizedBy; }

    public String getPrioritizedByName() { return prioritizedByName; }
    public void setPrioritizedByName(String prioritizedByName) { this.prioritizedByName = prioritizedByName; }

    public String getPrioritizedAtText() {
        return prioritizedAt == null ? "" :
                prioritizedAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getPreExamPaymentStatus() { return preExamPaymentStatus; }
    public void setPreExamPaymentStatus(String preExamPaymentStatus) { this.preExamPaymentStatus = preExamPaymentStatus; }

    /**
     * Trả về trạng thái hiển thị tiếng Việt cho bệnh nhân — MỘT chỗ duy nhất.
     * Kết hợp appointment.status + preExamPaymentStatus để phân biệt:
     * "Đã duyệt - chưa thanh toán" vs "Đã duyệt - đã thanh toán".
     */
    public String getDisplayStatus() {
        if (status == null) return "Không xác định";
        String s = status.trim();
        if ("Pending".equalsIgnoreCase(s)) {
            return "Chờ phòng khám duyệt";
        }
        if ("Confirmed".equalsIgnoreCase(s)) {
            if ("Paid".equalsIgnoreCase(preExamPaymentStatus)) {
                return "Đã duyệt — chờ check-in";
            }
            return "Đã duyệt — chưa thanh toán";
        }
        if ("Waiting".equalsIgnoreCase(s)) {
            return "Đã check-in — đang chờ khám";
        }
        if ("InProgress".equalsIgnoreCase(s)) {
            return "Đang khám";
        }
        if ("SUCCESS".equalsIgnoreCase(s) || "Completed".equalsIgnoreCase(s)) {
            return "Đã hoàn tất";
        }
        if ("Cancelled".equalsIgnoreCase(s)) {
            return "Đã huỷ";
        }
        if ("NoShow".equalsIgnoreCase(s)) {
            return "Không đến khám";
        }
        return s;
    }

    public Integer getSlotId() { return slotId; }
    public void setSlotId(Integer slotId) { this.slotId = slotId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public String getCreatedAtText() {
        return createdAt == null ? "" :
                createdAt.format(DateTimeFormatter.ofPattern("HH:mm - dd/MM/yyyy"));
    }

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
