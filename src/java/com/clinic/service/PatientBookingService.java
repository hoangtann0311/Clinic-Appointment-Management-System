package com.clinic.service;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.PatientDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.ServiceItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service cho nghiệp vụ đặt lịch khám của Patient.
 * Không còn dùng time_slots — đặt lịch trực tiếp vào doctor_schedules.
 */
public class PatientBookingService {

    private final PatientDAO patientDAO = new PatientDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    public List<Doctor> getAllDoctors() {
        return doctorDAO.getAllDoctors();
    }

    public List<Doctor> getDoctorsPaginated(String keyword, int page, int pageSize) {
        int limit = pageSize;
        int offset = (page - 1) * pageSize;
        return doctorDAO.getDoctorsPaginated(keyword, offset, limit);
    }

    public int countDoctors(String keyword) {
        return doctorDAO.countDoctors(keyword);
    }

    public List<ServiceItem> getAllServices() {
        return serviceDAO.getAllServices();
    }

    /**
     * Đặt lịch khám — scheduleId là doctor_schedules.id.
     */
    public Appointment bookAppointment(int userId, int scheduleId, String expectedTimeSlot, int serviceId,
                                        String symptoms, String lmpStr,
                                        Map<String, String> errors) {

        // 1. Tìm hoặc tạo hồ sơ bệnh nhân
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            com.clinic.model.User currentUser = new com.clinic.dao.UserDAO().findById(userId);
            if (currentUser != null) {
                com.clinic.model.Patient created = patientDAO.createPatientWithUserId(
                        currentUser.getFullName(), currentUser.getPhone(), null, userId);
                if (created != null) patientId = created.getId();
            }
        }
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân. Vui lòng liên hệ lễ tân.");
            return null;
        }

        // 2. Dịch vụ
        int actualServiceId = serviceId;
        if (actualServiceId <= 0) {
            actualServiceId = serviceDAO.getDefaultExaminationServiceId();
        }
        if (serviceDAO.findServiceById(actualServiceId) == null) {
            errors.put("general", "Hệ thống chưa cấu hình dịch vụ khám mặc định.");
            return null;
        }

        // 3. Validate triệu chứng
        if (symptoms == null || symptoms.trim().isEmpty()) {
            errors.put("symptoms", "Vui lòng nhập triệu chứng hoặc lý do khám.");
            return null;
        }
        String cleanSymptoms = symptoms.trim();
        if (cleanSymptoms.length() < 10) {
            errors.put("symptoms", "Triệu chứng/lý do khám quá ngắn. Vui lòng nhập tối thiểu 10 ký tự.");
            return null;
        }
        if (cleanSymptoms.length() > 500) {
            errors.put("symptoms", "Triệu chứng/lý do khám không được vượt quá 500 ký tự.");
            return null;
        }

        // 4. LMP
        LocalDate lmp = null;
        if (lmpStr != null && !lmpStr.isBlank()) {
            try {
                lmp = LocalDate.parse(lmpStr.trim());
            } catch (Exception e) {
                errors.put("lmp", "Ngày kinh cuối không hợp lệ.");
                return null;
            }
            if (lmp.isAfter(LocalDate.now())) {
                errors.put("lmp", "Ngày kinh cuối không được ở tương lai.");
                return null;
            }
        }

        // 5. Kiểm tra schedule tồn tại và còn chỗ
        if (!isScheduleAvailable(scheduleId)) {
            errors.put("slotId", "Ca khám này đã hết chỗ hoặc không khả dụng.");
            return null;
        }

        // 6. Kiểm tra đặt lịch trước 30 phút
        Date workDate = getScheduleWorkDate(scheduleId);
        String startTime = getScheduleStartTime(scheduleId);
        if (workDate != null && startTime != null) {
            java.time.LocalTime st = java.time.LocalTime.parse(startTime);
            java.time.LocalDateTime slotDateTime = java.time.LocalDateTime.of(workDate.toLocalDate(), st);
            if (java.time.LocalDateTime.now().plusMinutes(30).isAfter(slotDateTime)) {
                errors.put("general", "Phải đặt lịch trước giờ khám ít nhất 30 phút.");
                return null;
            }
        }

        // 7. Kiểm tra trùng lịch trong ngày
        AppointmentValidationService validationService = new AppointmentValidationService();
        int doctorId = getScheduleDoctorId(scheduleId);
        String sameDayError = validationService.validateSameDayActiveAppointment(patientId, doctorId,
                workDate != null ? workDate.toLocalDate() : null, null, false, null);
        if (sameDayError != null) {
            errors.put("general", sameDayError);
            return null;
        }

        // 8. Lấy giá từ bác sĩ (giá mặc định + kinh nghiệm)
        com.clinic.dao.DoctorDAO docDao = new com.clinic.dao.DoctorDAO();
        com.clinic.model.Doctor doctor = docDao.findById(doctorId);
        double basePrice = 200000.00;
        if (doctor != null && doctor.getExperienceYears() > 0) {
            basePrice += (doctor.getExperienceYears() * 50000.00);
        }
        
        String gestationalAge = AppointmentDAO.calculateGestationalAge(lmp,
                workDate != null ? workDate.toLocalDate() : null);

        // 9. Đặt lịch
        boolean success = appointmentDAO.bookSlotAndCreateAppointment(
                userId, patientId, scheduleId, expectedTimeSlot, actualServiceId, basePrice,
                cleanSymptoms, lmp, gestationalAge, errors);

        if (!success) return null;

        // Tìm appointment vừa tạo
        List<Appointment> appts = appointmentDAO.getByPatientId(patientId);
        for (Appointment a : appts) {
            if (a.getSlotId() != null && a.getSlotId() == scheduleId
                    && a.getStatus() != null
                    && !"Cancelled".equalsIgnoreCase(a.getStatus())
                    && !"NoShow".equalsIgnoreCase(a.getStatus())) {
                return a;
            }
        }
        return null;
    }

    public List<Appointment> getMyAppointments(int userId) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            com.clinic.model.User currentUser = new com.clinic.dao.UserDAO().findById(userId);
            if (currentUser != null) {
                com.clinic.model.Patient created = patientDAO.createPatientWithUserId(
                        currentUser.getFullName(), currentUser.getPhone(), null, userId);
                if (created != null) patientId = created.getId();
            }
        }
        if (patientId <= 0) return List.of();
        return appointmentDAO.getByPatientId(patientId);
    }

    public List<Appointment> getMyAppointmentsPaginated(int userId, String keyword, int page, int pageSize) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            com.clinic.model.User currentUser = new com.clinic.dao.UserDAO().findById(userId);
            if (currentUser != null) {
                com.clinic.model.Patient created = patientDAO.createPatientWithUserId(
                        currentUser.getFullName(), currentUser.getPhone(), null, userId);
                if (created != null) patientId = created.getId();
            }
        }
        if (patientId <= 0) return List.of();
        int offset = (page - 1) * pageSize;
        return appointmentDAO.getByPatientIdPaginated(patientId, keyword, offset, pageSize);
    }

    public int countMyAppointments(int userId, String keyword) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) return 0;
        return appointmentDAO.countByPatientId(patientId, keyword);
    }

    public boolean cancelAppointment(int userId, int appointmentId, Map<String, String> errors) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân.");
            return false;
        }

        Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
        if (appt == null) {
            errors.put("general", "Lịch hẹn không tồn tại.");
            return false;
        }
        if (appt.getPatientId() != patientId) {
            errors.put("general", "Bạn không có quyền huỷ lịch hẹn này.");
            return false;
        }

        if (appt.isPreExamPaid() || "PendingConfirmation".equalsIgnoreCase(appt.getPreExamPaymentStatus())) {
            errors.put("general", "Lịch hẹn đã thanh toán hoặc đang chờ xác nhận. Vui lòng liên hệ Hotline phòng khám để được hỗ trợ hủy lịch và hoàn tiền.");
            return false;
        }
        if (!"Pending".equalsIgnoreCase(appt.getStatus()) && !"Confirmed".equalsIgnoreCase(appt.getStatus())) {
            errors.put("general", "Chỉ có thể huỷ lịch hẹn đang ở trạng thái Chờ xác nhận hoặc Đã xác nhận.");
            return false;
        }
        if (appointmentDAO.isPreExamPaid(appointmentId)) {
            errors.put("general", "Lịch hẹn đã thanh toán. Vui lòng liên hệ lễ tân để được hỗ trợ.");
            return false;
        }

        // Time check
        if (appt.getAppointmentDate() != null && appt.getTimeSlot() != null) {
            try {
                String[] parts = appt.getTimeSlot().contains(" - ")
                        ? appt.getTimeSlot().split(" - ")[0].trim().split(":")
                        : appt.getTimeSlot().split("-")[0].trim().split(":");
                java.time.LocalTime time = java.time.LocalTime.of(
                        Integer.parseInt(parts[0]), Integer.parseInt(parts.length > 1 ? parts[1] : "0"));
                java.time.LocalDateTime apptDateTime = java.time.LocalDateTime.of(appt.getAppointmentDate(), time);
                if (apptDateTime.isBefore(java.time.LocalDateTime.now().plusMinutes(30))) {
                    errors.put("general", "Chỉ được huỷ/đổi lịch trước giờ khám tối thiểu 30 phút.");
                    return false;
                }
            } catch (Exception ignored) {}
        }

        return appointmentDAO.cancelAppointmentAndReleaseSlot(appointmentId, userId, "Bệnh nhân huỷ lịch hẹn");
    }

    public boolean rescheduleAppointment(int userId, int appointmentId, int newSlotId, String expectedTimeSlot, Map<String, String> errors) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân.");
            return false;
        }

        Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
        if (appt == null) {
            errors.put("general", "Lịch hẹn không tồn tại.");
            return false;
        }
        if (appt.getPatientId() != patientId) {
            errors.put("general", "Bạn không có quyền đổi lịch hẹn này.");
            return false;
        }
        if (!"Pending".equalsIgnoreCase(appt.getStatus()) && !"Confirmed".equalsIgnoreCase(appt.getStatus())) {
            errors.put("general", "Chỉ có thể đổi lịch hẹn đang ở trạng thái Chờ xác nhận hoặc Đã xác nhận.");
            return false;
        }
        if (appointmentDAO.isPreExamPaid(appointmentId)) {
            errors.put("general", "Lịch hẹn đã thanh toán. Vui lòng liên hệ lễ tân để được hỗ trợ đổi lịch.");
            return false;
        }

        // Time check for rescheduling
        if (appt.getAppointmentDate() != null && appt.getTimeSlot() != null) {
            try {
                String[] parts = appt.getTimeSlot().contains(" - ")
                        ? appt.getTimeSlot().split(" - ")[0].trim().split(":")
                        : appt.getTimeSlot().split("-")[0].trim().split(":");
                java.time.LocalTime time = java.time.LocalTime.of(
                        Integer.parseInt(parts[0]), Integer.parseInt(parts.length > 1 ? parts[1] : "0"));
                java.time.LocalDateTime apptDateTime = java.time.LocalDateTime.of(appt.getAppointmentDate(), time);
                if (apptDateTime.isBefore(java.time.LocalDateTime.now().plusMinutes(30))) {
                    errors.put("general", "Chỉ được đổi lịch trước giờ khám tối thiểu 30 phút.");
                    return false;
                }
            } catch (Exception ignored) {}
        }

        Integer oldSlotId = appt.getSlotId();
        if (oldSlotId == null) {
            errors.put("general", "Lịch hẹn cũ không có thông tin ca khám.");
            return false;
        }

        if (oldSlotId == newSlotId) {
            errors.put("slotId", "Ca khám mới trùng với ca khám hiện tại.");
            return false;
        }

        if (!isScheduleAvailable(newSlotId)) {
            errors.put("slotId", "Ca khám mới đã hết chỗ hoặc không khả dụng.");
            return false;
        }

        Date workDate = getScheduleWorkDate(newSlotId);
        String startTimeStr = getScheduleStartTime(newSlotId);
        if (workDate == null || startTimeStr == null) {
            errors.put("slotId", "Không tìm thấy thông tin ca khám mới.");
            return false;
        }
        
        java.sql.Time startTime = java.sql.Time.valueOf(expectedTimeSlot != null && !expectedTimeSlot.isEmpty() ? expectedTimeSlot + ":00" : startTimeStr + ":00");

        return appointmentDAO.rescheduleAppointmentTransaction(appointmentId, oldSlotId, newSlotId, userId, workDate, startTime, errors);
    }

    // ── Helpers ──

    private boolean isScheduleAvailable(int scheduleId) {
        String sql = "SELECT COUNT(*) FROM doctor_schedules WHERE id = ? AND status = 'APPROVED' AND booked_count < max_slots";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) { return false; }
    }

    private Date getScheduleWorkDate(int scheduleId) {
        String sql = "SELECT work_date FROM doctor_schedules WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDate("work_date") : null;
            }
        } catch (Exception e) { return null; }
    }

    private int getScheduleDoctorId(int scheduleId) {
        String sql = "SELECT doctor_id FROM doctor_schedules WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("doctor_id");
            }
        } catch (Exception e) { return 0; }
        return 0;
    }

    private String getScheduleStartTime(int scheduleId) {
        String sql = "SELECT s.start_time FROM doctor_schedules ds INNER JOIN shifts s ON ds.shift_id = s.id WHERE ds.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getTime("start_time").toLocalTime().toString().substring(0, 5);
            }
        } catch (Exception e) { }
        return null;
    }
}
