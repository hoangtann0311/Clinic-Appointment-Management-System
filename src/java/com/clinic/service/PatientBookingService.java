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
     * Luồng chuẩn: Validate tập trung → Kiểm tra slot → Kiểm tra trùng lịch → Tạo lịch Pending.
     * HĐ PRE_EXAM được tạo sau khi Staff duyệt (approveAndRequestPayment).
     */
    public Appointment bookAppointment(int userId, int scheduleId, String expectedTimeSlot, int serviceId,
                                        String symptoms, String lmpStr,
                                        Map<String, String> errors) {

        // 1. Tìm hoặc tạo hồ sơ bệnh nhân từ user đang đăng nhập
        int patientId = patientDAO.getPatientIdByUserId(userId);
        com.clinic.model.User currentUser = null;
        if (patientId <= 0) {
            currentUser = new com.clinic.dao.UserDAO().findById(userId);
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

        // 2. Lấy thông tin bệnh nhân để validate
        if (currentUser == null) {
            currentUser = new com.clinic.dao.UserDAO().findById(userId);
        }
        com.clinic.model.Patient currentPatient = patientDAO.findById(patientId);
        String patientName = currentPatient != null ? currentPatient.getFullName() : "";
        String patientPhone = currentPatient != null ? currentPatient.getPhone() : "";

        // 3. Lấy thông tin schedule để có doctorId + workDate (cần cho validate)
        ScheduleInfo info = getScheduleInfo(scheduleId);
        if (info == null) {
            errors.put("slotId", "Không tìm thấy thông tin ca khám.");
            return null;
        }
        if (!info.isAvailable) {
            errors.put("slotId", "Ca khám này đã hết chỗ hoặc không khả dụng.");
            return null;
        }

        String workDateStr = info.workDate != null ? info.workDate.toLocalDate().toString() : null;
        String expectedTimeSlotLabel = expectedTimeSlot; // label hiển thị như "08:00 - 12:00"

        // 4. Validate tập trung TẤT CẢ input qua AppointmentValidationService
        //    (đồng nhất logic giữa luồng BN online và Staff tại quầy)
        AppointmentValidationService validationService = new AppointmentValidationService();
        List<String> inputErrors = validationService.validateAppointmentInput(
                patientName,
                patientPhone,
                currentPatient != null && currentPatient.getDateOfBirth() != null
                        ? currentPatient.getDateOfBirth().toString() : null,
                String.valueOf(info.doctorId),
                null, // serviceId — BN online không chọn dịch vụ
                workDateStr,
                expectedTimeSlotLabel,
                symptoms,
                lmpStr
        );

        if (!inputErrors.isEmpty()) {
            for (String err : inputErrors) {
                if (err.toLowerCase().contains("triệu chứng") || err.toLowerCase().contains("lý do khám")) {
                    errors.put("symptoms", err);
                } else if (err.toLowerCase().contains("kinh") || err.toLowerCase().contains("lmp")) {
                    errors.put("lmp", err);
                } else if (err.toLowerCase().contains("bác sĩ")) {
                    errors.put("doctorId", err);
                } else if (err.toLowerCase().contains("khung giờ") || err.toLowerCase().contains("slot")) {
                    errors.put("slotId", err);
                } else if (err.toLowerCase().contains("ngày")) {
                    errors.put("appointmentDate", err);
                } else {
                    errors.put("general", err);
                }
            }
            return null;
        }

        // 5. Dịch vụ — optional, BN không cần chọn khi đặt online.
        //    Dịch vụ cụ thể (siêu âm, xét nghiệm...) do bác sĩ chỉ định sau khi khám.
        int actualServiceId = serviceId;
        if (actualServiceId <= 0) {
            actualServiceId = serviceDAO.getDefaultExaminationServiceId();
        }

        // 6. Parse LMP để tính tuổi thai
        LocalDate lmp = null;
        if (lmpStr != null && !lmpStr.isBlank()) {
            try {
                lmp = LocalDate.parse(lmpStr.trim());
            } catch (Exception e) {
                // đã được validate ở bước 4, không throw ở đây
            }
        }

        // 7. Validate thời gian đặt lịch (ca sắp kết thúc / đã bắt đầu)
        if (info.workDate != null && info.endTime != null) {
            java.time.LocalDate wDate = info.workDate.toLocalDate();
            java.time.LocalTime et = java.time.LocalTime.parse(info.endTime);
            java.time.LocalDateTime slotEndDateTime = java.time.LocalDateTime.of(wDate, et);
            if (java.time.LocalDateTime.now().plusMinutes(30).isAfter(slotEndDateTime)) {
                errors.put("general", "Ca khám này đã sắp kết thúc hoặc đã qua, vui lòng chọn ca khác.");
                return null;
            }
            if (info.startTime != null && wDate.equals(java.time.LocalDate.now())) {
                java.time.LocalTime st = java.time.LocalTime.parse(info.startTime);
                java.time.LocalDateTime slotStartDateTime = java.time.LocalDateTime.of(wDate, st);
                if (java.time.LocalDateTime.now().isAfter(slotStartDateTime)) {
                    errors.put("general", "Ca khám này đã bắt đầu, không thể đặt lịch trực tuyến. Vui lòng đến trực tiếp quầy Lễ tân.");
                    return null;
                }
            }
        }

        // 8. Kiểm tra trùng lịch trong ngày (1 BN chỉ 1 lịch active/ngày)
        int doctorId = info.doctorId;
        LocalDate workDate = info.workDate != null ? info.workDate.toLocalDate() : null;
        String sameDayError = validationService.validateSameDayActiveAppointment(
                patientId, doctorId, workDate, null, false, null);
        if (sameDayError != null) {
            errors.put("general", sameDayError);
            return null;
        }

        // 9. Tính giá khám = giá cơ bản + thâm niên bác sĩ
        com.clinic.dao.DoctorDAO docDao = new com.clinic.dao.DoctorDAO();
        com.clinic.model.Doctor doctor = docDao.findById(doctorId);
        double basePrice = 200000.00;
        if (doctor != null && doctor.getExperienceYears() > 0) {
            basePrice += (doctor.getExperienceYears() * 50000.00);
        }

        // 10. Tính tuổi thai (nếu có LMP)
        String gestationalAge = AppointmentDAO.calculateGestationalAge(lmp, workDate);

        // 11. Tạo lịch hẹn (status = Pending, chưa có HĐ PRE_EXAM)
        //     HĐ PRE_EXAM được tạo khi Staff duyệt (approveAndRequestPayment)
        boolean success = appointmentDAO.bookSlotAndCreateAppointment(
                userId, patientId, scheduleId, expectedTimeSlot, actualServiceId, basePrice,
                symptoms.trim(), lmp, gestationalAge, errors);

        if (!success) return null;

        // 11b. Gửi thông báo + ghi audit log sau khi đặt lịch thành công
        try {
            // Thông báo cho bác sĩ về lịch hẹn mới
            int doctorUserId = com.clinic.utils.NotificationHelper.getDoctorUserId(doctorId);
            if (doctorUserId > 0) {
                com.clinic.utils.NotificationHelper.newAppointment(doctorUserId, patientName,
                        workDate != null ? workDate.toString() : "",
                        expectedTimeSlot != null ? expectedTimeSlot : "");
            }
            // Thông báo cho chính bệnh nhân
            com.clinic.dao.NotificationDAO notiDAO = new com.clinic.dao.NotificationDAO();
            notiDAO.create(userId,
                    "📅 Đặt lịch khám thành công",
                    "Bạn đã đặt lịch khám với BS. " + (doctor != null ? doctor.getFullName() : "")
                    + " vào " + (expectedTimeSlot != null ? expectedTimeSlot : "")
                    + " ngày " + (workDate != null ? workDate.toString() : "")
                    + ". Lịch hẹn đang ở trạng thái Chờ duyệt. "
                    + "Vui lòng chờ nhân viên Lễ tân duyệt lịch và đến phòng khám nộp tiền trước giờ hẹn.");
            // Ghi audit log
            com.clinic.utils.AuditUtil.log(userId,
                    "Đặt lịch khám online với BS. " + (doctor != null ? doctor.getFullName() : "")
                    + " vào ngày " + (workDate != null ? workDate.toString() : ""),
                    "appointments", "-",
                    "Pending", "127.0.0.1");
        } catch (Exception ignored) {
            // Notification/audit không được phép làm hỏng luồng chính
        }

        // 12. Tìm và trả về appointment vừa tạo
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

    public List<Appointment> getMyAppointmentsPaginated(int userId, String keyword, String status, int page, int pageSize) {
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
        return appointmentDAO.getByPatientIdPaginated(patientId, keyword, status, offset, pageSize);
    }

    public int countMyAppointments(int userId, String keyword, String status) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) return 0;
        return appointmentDAO.countByPatientId(patientId, keyword, status);
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

        // Kiểm tra trạng thái — chỉ được hủy khi chưa vào quãng khám
        String status = appt.getStatus();
        if (!("Pending".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status))) {
            if ("Waiting".equalsIgnoreCase(status) || "InProgress".equalsIgnoreCase(status)) {
                errors.put("general", "Bệnh nhân đã check-in vào hàng đợi. Đến trực tiếp quầy Lễ tân để được hỗ trợ.");
            } else {
                errors.put("general", "Chỉ có thể hủy lịch hẹn đang ở trạng thái Chờ duyệt hoặc Đã xác nhận.");
            }
            return false;
        }

        // Kiểm tra đã thanh toán chưa (chỉ dùng 1 nguồn thật từ DB)
        // BN chỉ KHÔNG được hủy khi đã nộp tiền tại quầy (PRE_EXAM = Paid)
        // Nếu còn Unpaid (chưa đến quầy) → vẫn được hủy bình thường
        if (appointmentDAO.isPreExamPaid(appointmentId)) {
            errors.put("general", "Lịch hẹn đã thanh toán tại quầy. Vui lòng liên hệ Lễ tân để được hỗ trợ hủy lịch và hoàn tiền.");
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
                if (apptDateTime.isBefore(java.time.LocalDateTime.now())) {
                    errors.put("general", "Không thể huỷ/đổi lịch khám đã qua.");
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
            String st = appt.getStatus();
            if ("Waiting".equalsIgnoreCase(st) || "InProgress".equalsIgnoreCase(st)) {
                errors.put("general", "Bệnh nhân đã check-in vào hàng đợi, không thể đổi lịch trực tuyến. Hãy đến quầy Lễ tân.");
            } else {
                errors.put("general", "Chỉ có thể đổi lịch hẹn đang ở trạng thái Chờ duyệt hoặc Đã xác nhận.");
            }
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
                if (apptDateTime.isBefore(java.time.LocalDateTime.now())) {
                    errors.put("general", "Không thể huỷ/đổi lịch khám đã qua.");
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

        // Kiểm tra thông tin ca khám (Tối ưu V6)
        ScheduleInfo info = getScheduleInfo(newSlotId);
        if (info == null) {
            errors.put("slotId", "Không tìm thấy thông tin ca khám mới.");
            return false;
        }
        if (!info.isAvailable) {
            errors.put("slotId", "Ca khám mới đã hết chỗ hoặc không khả dụng.");
            return false;
        }

        // [V2-FIX] Kiểm tra ca mới không phải là ca đã bắt đầu trong hôm nay
        if (info.workDate != null) {
            java.time.LocalDate wDate = info.workDate.toLocalDate();
            if (wDate.equals(java.time.LocalDate.now()) && info.startTime != null) {
                java.time.LocalTime st = java.time.LocalTime.parse(info.startTime);
                if (java.time.LocalDateTime.now().isAfter(java.time.LocalDateTime.of(wDate, st))) {
                    errors.put("slotId", "Ca khám này đã bắt đầu, không thể đổi lịch sang ca này. Vui lòng đến trực tiếp quầy Lễ tân.");
                    return false;
                }
                // Ca sắp kết thúc (< 30 phút)
                if (info.endTime != null) {
                    java.time.LocalTime et = java.time.LocalTime.parse(info.endTime);
                    if (java.time.LocalDateTime.now().plusMinutes(30).isAfter(java.time.LocalDateTime.of(wDate, et))) {
                        errors.put("slotId", "Ca khám này sắp kết thúc, vui lòng chọn ca khác.");
                        return false;
                    }
                }
            }
        }
        
        java.sql.Time startTime = java.sql.Time.valueOf(expectedTimeSlot != null && !expectedTimeSlot.isEmpty() ? expectedTimeSlot + ":00" : info.startTime + ":00");

        return appointmentDAO.rescheduleAppointmentTransaction(appointmentId, oldSlotId, newSlotId, userId, info.workDate, startTime, errors);
    }

    // ── Helpers ──

    private static class ScheduleInfo {
        boolean isAvailable;
        Date workDate;
        int doctorId;
        String startTime;
        String endTime;
    }

    private ScheduleInfo getScheduleInfo(int scheduleId) {
        String sql = "SELECT ds.work_date, ds.doctor_id, ds.status, ds.booked_count, ds.max_slots, s.start_time, s.end_time " +
                     "FROM doctor_schedules ds INNER JOIN shifts s ON ds.shift_id = s.id WHERE ds.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ScheduleInfo info = new ScheduleInfo();
                    info.workDate = rs.getDate("work_date");
                    info.doctorId = rs.getInt("doctor_id");
                    info.isAvailable = "APPROVED".equals(rs.getString("status")) && rs.getInt("booked_count") < rs.getInt("max_slots");
                    info.startTime = rs.getTime("start_time") != null ? rs.getTime("start_time").toLocalTime().toString().substring(0, 5) : null;
                    info.endTime = rs.getTime("end_time") != null ? rs.getTime("end_time").toLocalTime().toString().substring(0, 5) : null;
                    return info;
                }
            }
        } catch (Exception e) {}
        return null;
    }
}
