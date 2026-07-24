package com.clinic.service;

import com.clinic.dao.*;
import com.clinic.config.DBContext;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;
import com.clinic.model.*;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.StaffValidator;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.clinic.config.DatabaseConfig;
import java.time.LocalDate;
import java.util.*;

public class StaffReceptionService {

    private final PatientDAO patientDAO = new PatientDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final DoctorScheduleDAO doctorScheduleDAO = new DoctorScheduleDAO();
    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAO();

    public StaffReceptionService() {
    }

    // --- Patient Management ---
    public List<Patient> getAllPatients() {
        return patientDAO.getAllPatients();
    }
    
    public Patient findPatientByPhone(String phone) {
        return patientDAO.findPatientByPhone(phone);
    }

    public Patient createPatient(String name, String phone, String dob) {
        LocalDate birthDate = dob == null || dob.isEmpty()
                ? LocalDate.of(1995, 1, 1)
                : LocalDate.parse(dob);

        LocalDate today = LocalDate.now();

        if (birthDate.isAfter(today)) {
            throw new IllegalArgumentException("Ngày sinh sản phụ không được lớn hơn ngày hiện tại.");
        }

        Patient newPatient = patientDAO.createPatient(name, phone, birthDate);

        if (newPatient != null) {
            auditLogDAO.logAction(
                    "Tạo mới hồ sơ bệnh nhân " + name,
                    "Staff",
                    "patients",
                    "-",
                    String.valueOf(newPatient.getId())
            );
        }

        return newPatient;
    }

    // --- Doctor & Services Management ---
    public List<Doctor> getAllDoctors() {
        return doctorDAO.getAllDoctors();
    }

    public Doctor findDoctorById(String id) {
        try {
            return doctorDAO.findDoctorById(Integer.parseInt(id));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public List<ServiceItem> getAllServices() {
        return serviceDAO.getAllServices();
    }

    /** Read-only approved duty roster for reception staff. */
    public List<DoctorSchedule> getApprovedDoctorSchedules(LocalDate date) {
        LocalDate selectedDate = date != null ? date : LocalDate.now();
        List<DoctorSchedule> schedules = doctorScheduleDAO.findAll(
                0, 200, "APPROVED", null,
                java.sql.Date.valueOf(selectedDate), java.sql.Date.valueOf(selectedDate));
        for (DoctorSchedule schedule : schedules) {
            schedule.setBookedSlotCount(timeSlotDAO.countBookedSlots(schedule.getId()));
        }
        return schedules;
    }

    /** Read-only slot board. Non-available slots are intentionally not actionable. */
    public List<TimeSlot> getDoctorSlotsForReception(LocalDate date) {
        LocalDate selectedDate = date != null ? date : LocalDate.now();
        return timeSlotDAO.findByDateForReception(java.sql.Date.valueOf(selectedDate));
    }

    public ServiceItem findServiceById(String id) {
        try {
            return serviceDAO.findServiceById(Integer.parseInt(id));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // --- Gestational Age Calculator ---
    public String calculateGestationalAge(LocalDate lmp, LocalDate appointmentDate) {
        return AppointmentDAO.calculateGestationalAge(lmp, appointmentDate);
    }

    // --- Booking Logic (Manual Booking UC11) ---
    public Appointment createManualBooking(String name, String phone, String dob, String doctorId, String serviceId,
                                           String appDateStr, String slot, String symptoms, String lmpStr, boolean isEmergency) {

        // 1. Validate dữ liệu đầu vào
        List<String> errors = StaffValidator.validateBooking(
                name, phone, dob, doctorId, serviceId, appDateStr, slot, symptoms, lmpStr, false
        );

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("|", errors));
        }

        // 2. Parse dữ liệu
        LocalDate appDate = LocalDate.parse(appDateStr);
        LocalDate lmp = StaffValidator.isEmpty(lmpStr) ? null : LocalDate.parse(lmpStr);

        // 3. Kiểm tra bác sĩ và dịch vụ có tồn tại không
        Doctor doctor = findDoctorById(doctorId);
        if (doctor == null) {
            throw new IllegalArgumentException("Bác sĩ không tồn tại.");
        }

        ServiceItem service = findServiceById(serviceId);
        if (service == null) {
            throw new IllegalArgumentException("Dịch vụ không tồn tại.");
        }

        // 5. Kiểm tra trùng khung giờ.
        boolean slotBooked = appointmentDAO.isSlotBooked(
                null,
                doctor.getId(),
                appDate,
                slot
        );
        if (slotBooked) {
            throw new IllegalArgumentException("Khung giờ này đã có bệnh nhân đặt. Vui lòng chọn giờ khác.");
        }

        // 6. Tìm hoặc tạo bệnh nhân
        Patient patient = findPatientByPhone(phone);

        if (patient == null) {
            patient = createPatient(name, phone, dob);
        }

        if (patient == null) {
            throw new IllegalArgumentException("Không thể tạo hồ sơ bệnh nhân.");
        }

        // Tìm slotId tương ứng trong time_slots
        java.sql.Time startTime = null;
        if (slot != null && slot.contains("-")) {
            try {
                String startPart = slot.split("-")[0].trim();
                startTime = java.sql.Time.valueOf(java.time.LocalTime.parse(startPart));
            } catch (Exception ignored) {}
        }

        Integer foundSlotId = null;
        if (startTime != null) {
            String findSlotSql = "SELECT id FROM time_slots WHERE doctor_id = ? AND work_date = ? AND start_time = CAST(? AS time) AND status = 'AVAILABLE'";
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(findSlotSql)) {
                ps.setInt(1, doctor.getId());
                ps.setDate(2, java.sql.Date.valueOf(appDate));
                ps.setTime(3, startTime);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        foundSlotId = rs.getInt("id");
                    }
                }
            } catch (SQLException e) {
                System.err.println("[StaffReceptionService] Lỗi khi tìm time_slot cho manual booking: " + e.getMessage());
            }
        }

        // UI data can be forged. A normal booking must always resolve to an
        // approved, currently available time_slot on the doctor's roster.
        if (foundSlotId == null) {
            throw new IllegalArgumentException(
                    "Khung giờ đã hết chỗ hoặc không thuộc lịch làm việc đã được xác nhận của bác sĩ. Vui lòng chọn lại."
            );
        }

        // 7. Tính tuổi thai
        String gestationalAge = calculateGestationalAge(lmp, appDate);

        // 8. Tạo lịch hẹn
        String status = "Pending";
        String finalSlot = slot;

        Appointment appointment = new Appointment(
                0,
                patient,
                doctor,
                service,
                appDate,
                finalSlot,
                symptoms,
                lmp,
                gestationalAge,
                false,
                status
        );

        if (foundSlotId != null) appointment.setSlotId(foundSlotId);

        // 9. Lưu lịch hẹn và giữ slot trong cùng một transaction để tránh đặt trùng.
        int patientUserId = getUserIdForPatient(patient.getId());
        appointment = appointmentDAO.createStaffAppointmentWithHeldSlot(
                appointment,
                foundSlotId,
                patientUserId > 0 ? patientUserId : null
        );
        if (appointment == null) {
            throw new IllegalArgumentException("Khung giờ vừa được người khác chọn. Vui lòng tải lại và chọn slot khác.");
        }

        // 10. Tạo hóa đơn PRE_EXAM (trả trước dùng sau)
        if (appointment != null) {
            Invoice preExamInvoice = new Invoice();
            preExamInvoice.setAppointmentId(appointment.getId());
            preExamInvoice.setTotalAmount(java.math.BigDecimal.valueOf(service.getPrice()));
            preExamInvoice.setStatus("Unpaid");
            preExamInvoice.setInvoiceType("PRE_EXAM");
            invoiceDAO.insert(preExamInvoice);
        }

        // 11. Ghi log và gửi thông báo giả lập Zalo
        if (appointment != null) {
            auditLogDAO.logAction(
                    "Tạo lịch hẹn thủ công cho " + patient.getFullName(),
                    "Staff",
                    "appointments",
                    "-",
                    String.valueOf(appointment.getId())
            );

            sendNotification(
                    patient,
                    "Lịch hẹn khám của bạn đã được tạo vào ngày " + appDateStr + ", khung giờ " + slot + "."
            );
        }

        return appointment;
    }

    public List<Appointment> getSmartQueue() {
        List<Appointment> result = new ArrayList<>();
        LocalDate today = LocalDate.now();
        java.time.LocalTime nowTime = java.time.LocalTime.now();

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            // Tự động chuyển đổi NoShow đối với các lịch hẹn Confirmed quá hạn 30 phút
            if ("Confirmed".equalsIgnoreCase(appointment.getStatus())) {
                boolean markNoShow = false;
                if (appointment.getAppointmentDate() != null) {
                    if (appointment.getAppointmentDate().isBefore(today)) {
                        markNoShow = true;
                    } else if (appointment.getAppointmentDate().equals(today)) {
                        String slot = appointment.getTimeSlot();
                        if (slot != null && !slot.trim().isEmpty()) {
                            try {
                                String startTimeStr = extractSlotStart(slot);
                                if (startTimeStr != null) {
                                    java.time.LocalTime startTime = java.time.LocalTime.parse(startTimeStr);
                                    if (nowTime.isAfter(startTime.plusMinutes(30))) {
                                        markNoShow = true;
                                    }
                                }
                            } catch (Exception e) {
                                // Bỏ qua nếu lỗi định dạng time slot
                            }
                        }
                    }
                }
                
                if (markNoShow) {
                    appointment.setStatus("NoShow");
                    appointmentDAO.updateStatus(appointment.getId(), "NoShow");
                    
                    // Ghi log hoạt động hệ thống
                    auditLogDAO.logAction(
                            "Tự động chuyển NoShow (quá giờ khám 30 phút)",
                            "System",
                            "appointments",
                            "Confirmed -> NoShow",
                            String.valueOf(appointment.getId())
                    );
                }
            }

            if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
                    && !"NoShow".equalsIgnoreCase(appointment.getStatus())) {
                result.add(appointment);
            }
        }

        result.sort((a1, a2) -> {
            int score1 = getStatusPriorityScore(a1.getStatus());
            int score2 = getStatusPriorityScore(a2.getStatus());

            if (score1 != score2) {
                return Integer.compare(score1, score2);
            }

            if (a1.isEmergency() != a2.isEmergency()) {
                return a1.isEmergency() ? -1 : 1;
            }

            return Integer.compare(a1.getId(), a2.getId());
        });

        return result;
    }

    private int getStatusPriorityScore(String status) {
        if (status == null) return 9;

        String normalizedStatus = status.trim().toUpperCase();

        switch (normalizedStatus) {
            case "INPROGRESS": return 1;
            case "WAITING": return 2;
            case "CONFIRMED": return 3;
            case "PENDING": return 4;
            case "SUCCESS":
            case "COMPLETED": return 5;
            case "CANCELLED": return 6;
            case "NOSHOW": return 7;
            default: return 9;
        }
    }

    public void checkInPatient(String id) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);

            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }

            if (apt.getAppointmentDate() == null || !apt.getAppointmentDate().equals(LocalDate.now())) {
                throw new IllegalArgumentException("Chỉ được check-in lịch hẹn trong ngày hôm nay.");
            }

            if ("Cancelled".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã bị hủy, không thể check-in.");
            }

            if ("SUCCESS".equalsIgnoreCase(apt.getStatus())
                    || "Completed".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã hoàn thành, không thể check-in.");
            }

            if ("InProgress".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Ca khám đang xử lý, không thể check-in lại.");
            }

            if ("Waiting".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Bệnh nhân đã check-in rồi.");
            }

// Chỉ lịch thường mới bắt buộc thanh toán PRE_EXAM trước khi check-in
            if (!appointmentDAO.isPreExamPaid(appointmentId)) {
                throw new IllegalArgumentException(
                        "Bệnh nhân chưa thanh toán hóa đơn trước khám PRE_EXAM, không thể check-in."
                );
            }

            int nextNum = appointmentDAO.getNextNormalQueueNumber(apt.getAppointmentDate());
            String queueNum = "STT-" + String.format("%02d", nextNum);

            appointmentDAO.updateCheckIn(appointmentId, "Waiting", queueNum);

            auditLogDAO.logAction(
                    "Check-in bệnh nhân, cấp số " + queueNum,
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "Waiting"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    public void markPriority(String id, String reason, int userId, String ipAddress) {
        int appointmentId = parseAppointmentId(id);
        String normalizedReason = reason == null ? "" : reason.trim();
        if (normalizedReason.length() < 5 || normalizedReason.length() > 500) {
            throw new IllegalArgumentException(
                    "Lý do ưu tiên phải từ 5 đến 500 ký tự.");
        }

        Appointment appointment = appointmentDAO.findAppointmentById(appointmentId);
        if (appointment == null) {
            throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
        }
        if (!"Waiting".equalsIgnoreCase(appointment.getStatus())) {
            throw new IllegalArgumentException(
                    "Chỉ ca đã check-in và đang chờ khám mới được đánh dấu ưu tiên.");
        }
        if (appointment.isEmergency()) {
            throw new IllegalArgumentException("Ca khám này đã được đánh dấu ưu tiên.");
        }
        if (!appointmentDAO.markPriority(appointmentId, userId, normalizedReason)) {
            throw new IllegalArgumentException(
                    "Không thể đánh dấu ưu tiên vì hàng đợi vừa thay đổi.");
        }

        AuditUtil.log(userId,
                "Đánh dấu ưu tiên lịch khám #" + appointmentId
                        + " - Lý do: " + normalizedReason,
                "appointments", "is_emergency=0",
                "is_emergency=1; reason=" + normalizedReason, ipAddress);
    }

    public void clearPriority(String id, int userId, String ipAddress) {
        int appointmentId = parseAppointmentId(id);
        Appointment appointment = appointmentDAO.findAppointmentById(appointmentId);
        if (appointment == null) {
            throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
        }
        if (!appointment.isEmergency()) {
            throw new IllegalArgumentException("Ca khám này không còn ở mức ưu tiên.");
        }
        if (!("Waiting".equalsIgnoreCase(appointment.getStatus())
                || "InProgress".equalsIgnoreCase(appointment.getStatus()))) {
            throw new IllegalArgumentException(
                    "Chỉ có thể bỏ ưu tiên khi ca đang chờ hoặc đang khám.");
        }
        if (!appointmentDAO.clearPriority(appointmentId)) {
            throw new IllegalArgumentException(
                    "Không thể bỏ ưu tiên vì hàng đợi vừa thay đổi.");
        }

        AuditUtil.log(userId,
                "Bỏ ưu tiên lịch khám #" + appointmentId,
                "appointments",
                "is_emergency=1; reason=" + appointment.getPriorityReason(),
                "is_emergency=0", ipAddress);
    }

    private int parseAppointmentId(String id) {
        try {
            int appointmentId = Integer.parseInt(id);
            if (appointmentId <= 0) throw new NumberFormatException();
            return appointmentId;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    private void sendNotification(Patient patient, String content) {
        if (patient == null) return;
        String sql = "INSERT INTO notifications (user_id, title, content, channel, is_read, created_at) VALUES (?, ?, ?, 'System', 0, GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int userId = getUserIdForPatient(patient.getId());
            if (userId > 0) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, patient.getFullName());
            ps.setString(3, content);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int getUserIdForPatient(int patientId) {
        String sql = "SELECT user_id FROM patients WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("user_id");
                    return rs.wasNull() ? 0 : uid;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, String>> getSystemNotifications() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT title, content, created_at FROM notifications WHERE channel = 'System' ORDER BY id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                java.sql.Timestamp ts = rs.getTimestamp("created_at");
                map.put("time", ts != null ? ts.toString() : java.time.LocalDateTime.now().toString());
                map.put("name", rs.getString("title"));
                map.put("content", rs.getString("content"));
                map.put("phone", "");
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public int getWidgetTodayAppointments() {
        int count = 0;

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
                    && !"NoShow".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }

        return count;
    }

    public int getWidgetWaitingQueue() {
        int count = 0;

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if ("Waiting".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }

        return count;
    }

    public void cancelAppointment(String id) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);

            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }

            if ("Cancelled".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã bị hủy trước đó.");
            }

            if ("SUCCESS".equalsIgnoreCase(apt.getStatus())
                    || "Completed".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã hoàn thành, không thể hủy.");
            }

            if ("InProgress".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Ca khám đang xử lý, không thể hủy.");
            }

            if ("Waiting".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Bệnh nhân đã check-in, không thể hủy lịch bằng thao tác thường.");
            }

            // A paid appointment cannot be silently cancelled because its
            // receipt must remain auditable and requires a separate refund
            // decision. Unpaid/pending receipts are voided by the DAO
            // transaction together with slot release.
            if (appointmentDAO.isPreExamPaid(appointmentId)) {
                throw new IllegalArgumentException(
                        "Lịch hẹn đã thanh toán. Không thể hủy trực tiếp; cần xử lý hoàn tiền theo quy trình quản lý."
                );
            }

            boolean success = appointmentDAO.cancelAppointmentAndReleaseSlot(appointmentId, 0, "Lễ tân hủy lịch hẹn");
            if (!success) {
                throw new IllegalArgumentException("Không thể hủy lịch hẹn hoặc lịch đã hoàn thành/đang khám.");
            }

            auditLogDAO.logAction(
                    "Hủy lịch hẹn của " + apt.getPatientName(),
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "Cancelled"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    public Appointment findAppointmentById(int id) {
        return appointmentDAO.findAppointmentById(id);
    }

    public void updateAppointment(int id, String doctorId, String serviceId, String appDateStr, String slot, String symptoms, String lmpStr) {
        Appointment apt = appointmentDAO.findAppointmentById(id);

        if (apt == null) {
            throw new IllegalArgumentException("Không tìm thấy lịch hẹn cần sửa.");
        }

        if ("Cancelled".equalsIgnoreCase(apt.getStatus())
                || "SUCCESS".equalsIgnoreCase(apt.getStatus())
                || "Completed".equalsIgnoreCase(apt.getStatus())
                || "InProgress".equalsIgnoreCase(apt.getStatus())
                || "Waiting".equalsIgnoreCase(apt.getStatus())
                || !"Pending".equalsIgnoreCase(apt.getStatus())) {
            throw new IllegalArgumentException("Không thể sửa lịch hẹn ở trạng thái " + apt.getStatus() + ".");
        }

        Invoice preInvoice = new InvoiceDAO().getByAppointmentIdAndType(id, "PRE_EXAM");
        if (preInvoice != null && !"Unpaid".equalsIgnoreCase(preInvoice.getStatus())) {
            throw new IllegalArgumentException(
                    "Lịch đã có yêu cầu thanh toán. Không thể đổi bác sĩ, dịch vụ hoặc slot sau khi bệnh nhân đã gửi thanh toán."
            );
        }

        String patientName = apt.getPatient() != null ? apt.getPatient().getFullName() : apt.getPatientName();
        String patientPhone = apt.getPatient() != null ? apt.getPatient().getPhone() : "";

        List<String> errors = StaffValidator.validateBooking(
                patientName,
                patientPhone,
                null,
                doctorId,
                serviceId,
                appDateStr,
                slot,
                symptoms,
                lmpStr,
                false
        );

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("|", errors));
        }

        Doctor doctor = findDoctorById(doctorId);
        ServiceItem service = findServiceById(serviceId);
        if (doctor == null || service == null) {
            throw new IllegalArgumentException("Bác sĩ hoặc dịch vụ không còn hoạt động.");
        }
        LocalDate appDate = LocalDate.parse(appDateStr);
        LocalDate lmp = StaffValidator.isEmpty(lmpStr) ? null : LocalDate.parse(lmpStr);
        String gestationalAge = calculateGestationalAge(lmp, appDate);

        Integer targetSlotId = findAvailableOrCurrentSlot(
                doctor.getId(), appDate, slot, apt.getSlotId());
        if (targetSlotId == null) {
            throw new IllegalArgumentException(
                    "Khung giờ đã hết chỗ hoặc không thuộc lịch làm việc đã được xác nhận của bác sĩ. Vui lòng chọn lại."
            );
        }

        apt.setDoctor(doctor);
        apt.setService(service);
        apt.setAppointmentDate(appDate);
        apt.setTimeSlot(slot);
        apt.setSymptoms(symptoms);
        apt.setLastMenstrualPeriod(lmp);
        apt.setGestationalAge(gestationalAge);

        int patientUserId = apt.getPatient() != null ? getUserIdForPatient(apt.getPatient().getId()) : 0;
        boolean updated = appointmentDAO.updatePendingStaffAppointmentWithSlot(
                apt,
                targetSlotId,
                patientUserId > 0 ? patientUserId : null,
                java.math.BigDecimal.valueOf(service.getPrice())
        );
        if (!updated) {
            throw new IllegalArgumentException("Slot vừa thay đổi trạng thái hoặc lịch hẹn không còn được phép sửa. Vui lòng tải lại trang.");
        }

        auditLogDAO.logAction(
                "Thay đổi thông tin lịch hẹn khám bệnh án #" + id + " cho sản phụ " + apt.getPatientName(),
                "Staff",
                "appointments",
                "-",
                String.valueOf(id)
        );
    }

    private Integer findAvailableOrCurrentSlot(int doctorId, LocalDate workDate, String slot, Integer currentSlotId) {
        if (slot == null || !slot.contains("-")) return null;
        try {
            java.time.LocalTime start = java.time.LocalTime.parse(slot.split("-")[0].trim());
            String sql = "SELECT id FROM time_slots WHERE doctor_id = ? AND work_date = ? AND start_time = CAST(? AS time) "
                    + "AND (status = 'AVAILABLE' OR (id = ? AND status IN ('HELD', 'WAITING_VERIFICATION')))";
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, doctorId);
                ps.setDate(2, java.sql.Date.valueOf(workDate));
                ps.setTime(3, java.sql.Time.valueOf(start));
                if (currentSlotId != null) {
                    ps.setInt(4, currentSlotId);
                } else {
                    ps.setInt(4, -1);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt("id") : null;
                }
            }
        } catch (Exception e) {
            return null;
        }
    }

    private boolean isStatus(String actualStatus, String expectedStatus) {
        return actualStatus != null && actualStatus.equalsIgnoreCase(expectedStatus);
    }

    private boolean isTodayAppointment(Appointment appointment) {
        return appointment.getAppointmentDate() != null
                && appointment.getAppointmentDate().equals(LocalDate.now());
    }

    public void mockPayPreExamInvoice(String id) {
        try {
            int appointmentId = Integer.parseInt(id);

            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);
            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }

            if (!"Pending".equalsIgnoreCase(apt.getStatus())
                    && !"Confirmed".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Chỉ có thể thanh toán trước khám cho lịch đang Pending hoặc Confirmed.");
            }

            String sqlUpdate = "UPDATE invoices " +
                    "SET status = 'Paid', transaction_code = ? " +
                    "WHERE appointment_id = ? AND invoice_type = 'PRE_EXAM'";

            String sqlInsert = "INSERT INTO invoices (appointment_id, invoice_type, total_amount, status, transaction_code) " +
                    "SELECT ?, 'PRE_EXAM', ?, 'Paid', ? " +
                    "WHERE NOT EXISTS ( " +
                    "   SELECT 1 FROM invoices WHERE appointment_id = ? AND invoice_type = 'PRE_EXAM' " +
                    ")";

            String transactionCode = "MOCK_PAID_" + appointmentId;

            try (Connection conn = DBContext.getConnection()) {
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setString(1, transactionCode);
                    ps.setInt(2, appointmentId);
                    ps.executeUpdate();
                }

                double amount = apt.getService() != null ? apt.getService().getPrice() : 250000;

                try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                    ps.setInt(1, appointmentId);
                    ps.setDouble(2, amount);
                    ps.setString(3, transactionCode);
                    ps.setInt(4, appointmentId);
                    ps.executeUpdate();
                }
            }

            appointmentDAO.confirmAppointmentAfterPreExamPaid(appointmentId);

            auditLogDAO.logAction(
                    "Mô phỏng thanh toán hóa đơn PRE_EXAM cho lịch hẹn #" + appointmentId,
                    "Payment Mock",
                    "invoices",
                    "Unpaid",
                    "Paid"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new IllegalArgumentException("Không thể cập nhật thanh toán PRE_EXAM.");
        }
    }

    public List<Appointment> getSmartQueueByDate(LocalDate date) {
        List<Appointment> result = new ArrayList<>();
        java.time.LocalTime nowTime = java.time.LocalTime.now();
        LocalDate today = LocalDate.now();

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            // Tự động chuyển NoShow cho lịch Confirmed quá hạn 30 phút
            if ("Confirmed".equalsIgnoreCase(appointment.getStatus())
                    && appointment.getAppointmentDate() != null
                    && !appointment.getAppointmentDate().isAfter(today)) {
                boolean markNoShow = false;
                if (appointment.getAppointmentDate().isBefore(today)) {
                    markNoShow = true;
                } else if (appointment.getAppointmentDate().equals(today)) {
                    String slot = appointment.getTimeSlot();
                    if (slot != null && !slot.trim().isEmpty()) {
                        try {
                            String startTimeStr = extractSlotStart(slot);
                            if (startTimeStr != null) {
                                java.time.LocalTime startTime = java.time.LocalTime.parse(startTimeStr);
                                if (nowTime.isAfter(startTime.plusMinutes(30))) {
                                    markNoShow = true;
                                }
                            }
                        } catch (Exception ignored) { }
                    }
                }
                if (markNoShow) {
                    appointment.setStatus("NoShow");
                    appointmentDAO.updateStatus(appointment.getId(), "NoShow");
                    auditLogDAO.logAction("Tự động chuyển NoShow (quá giờ khám 30 phút)",
                            "System", "appointments", "Confirmed -> NoShow",
                            String.valueOf(appointment.getId()));
                    continue;
                }
            }

            if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
                    && !"NoShow".equalsIgnoreCase(appointment.getStatus())
                    && appointment.getAppointmentDate() != null
                    && appointment.getAppointmentDate().equals(date)) {
                result.add(appointment);
            }
        }

        result.sort((a1, a2) -> {
            int score1 = getStatusPriorityScore(a1.getStatus());
            int score2 = getStatusPriorityScore(a2.getStatus());
            if (score1 != score2) return Integer.compare(score1, score2);
            if (a1.isEmergency() != a2.isEmergency()) return a1.isEmergency() ? -1 : 1;
            return Integer.compare(a1.getId(), a2.getId());
        });
        return result;
    }

    /** Tách giờ bắt đầu từ time_slot, hỗ trợ cả "08:00-08:20" và "08:00 - 08:20" */
    private String extractSlotStart(String slot) {
        if (slot == null || slot.isBlank()) return null;
        // Thử tách bằng " - " (có spaces) trước, rồi "-" (không spaces)
        String[] parts = slot.contains(" - ") ? slot.split(" - ") : slot.split("-");
        return parts.length > 0 ? parts[0].trim() : null;
    }

    public int getWidgetAppointmentsByDate(LocalDate date) {
        int count = 0;
        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if (appointment.getAppointmentDate() != null
                    && appointment.getAppointmentDate().equals(date)
                    && !"Cancelled".equalsIgnoreCase(appointment.getStatus())
                    && !"NoShow".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }
        return count;
    }

    public int getWidgetWaitingQueueByDate(LocalDate date) {
        int count = 0;
        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if (appointment.getAppointmentDate() != null
                    && appointment.getAppointmentDate().equals(date)
                    && "Waiting".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }
        return count;
    }

    /** Đếm số bệnh nhân đang chờ/có lịch của mỗi bác sĩ trong hôm nay */
    public Map<Integer, Integer> getDoctorWorkloadToday() {
        Map<Integer, Integer> workload = new HashMap<>();
        for (Appointment apt : appointmentDAO.getAllAppointments()) {
            if (apt.getAppointmentDate() != null
                    && apt.getAppointmentDate().equals(LocalDate.now())
                    && apt.getDoctorId() > 0
                    && !"Cancelled".equalsIgnoreCase(apt.getStatus())
                    && !"NoShow".equalsIgnoreCase(apt.getStatus())
                    && !"SUCCESS".equalsIgnoreCase(apt.getStatus())
                    && !"Completed".equalsIgnoreCase(apt.getStatus())) {
                workload.merge(apt.getDoctorId(), 1, Integer::sum);
            }
        }
        return workload;
    }

    // --- Invoice & Payment Confirmation (UC16) ---
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    public List<Invoice> getInvoices(int page, int pageSize, String search, String status, String type, String date) {
        int offset = (page - 1) * pageSize;
        return invoiceDAO.getAllInvoices(offset, pageSize, search, status, type, date);
    }

    public int countInvoices(String search, String status, String type, String date) {
        return invoiceDAO.countAllInvoices(search, status, type, date);
    }

    public Invoice getInvoiceById(int id) {
        return invoiceDAO.getById(id);
    }

    public boolean confirmPayment(int invoiceId, String paymentMethod, String transactionCode, String paymentNote, int confirmedBy) {
        Invoice invoice = invoiceDAO.getById(invoiceId);
        if (invoice == null) {
            throw new IllegalArgumentException("Không tìm thấy hóa đơn cần thanh toán.");
        }

        if ("Paid".equalsIgnoreCase(invoice.getStatus())) {
            throw new IllegalArgumentException("Hóa đơn này đã được thanh toán trước đó.");
        }

        // Nhân viên chỉ xác nhận yêu cầu mà bệnh nhân đã gửi.
        // Hóa đơn Unpaid phải được bệnh nhân chọn phương thức thanh toán trước.
        if (!"PendingConfirmation".equalsIgnoreCase(invoice.getStatus())) {
            throw new IllegalArgumentException("Yêu cầu thanh toán chưa ở trạng thái chờ nhân viên xác nhận.");
        }

        // The chosen method is immutable after the patient sends the request.
        // Never trust the method posted by the staff form; use the invoice.
        if (invoice.getPaymentMethod() == null || invoice.getPaymentMethod().trim().isEmpty()) {
            throw new IllegalArgumentException("Hóa đơn chưa có phương thức thanh toán do bệnh nhân chọn.");
        }
        paymentMethod = invoice.getPaymentMethod().trim();
        if (!"Cash".equalsIgnoreCase(paymentMethod) && !"BankTransfer".equalsIgnoreCase(paymentMethod)) {
            throw new IllegalArgumentException("Phương thức thanh toán trên hóa đơn không hợp lệ.");
        }

        String patientReference = firstNonBlank(null, invoice.getTransactionCode());
        // A receipt code belongs to the staff approval event.  It is generated
        // for both methods so Manager revenue/audit always has a stable key.
        String finalTxCode = createReceiptCode(paymentMethod, invoiceId);
        String finalPaymentNote = appendPatientReference(paymentNote, patientReference, finalTxCode);
        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        boolean success;
        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                success = invoiceDAO.updatePaymentStatus(conn, invoiceId, "Paid", paymentMethod,
                        finalTxCode, finalPaymentNote, confirmedBy, now);

                if (success && "PRESCRIPTION".equalsIgnoreCase(invoice.getInvoiceType())) {
                    success = invoiceDAO.deductPrescriptionStock(conn, invoiceId);
                    if (!success) {
                        throw new IllegalArgumentException(
                                "Không thể xác nhận: thuốc trong đơn không còn đủ tồn kho.");
                    }
                }

                if (success && "PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType())
                        && invoice.getAppointmentId() != null) {
                    success = appointmentDAO.confirmPreExamPayment(conn, invoice.getAppointmentId());
                }

                if (success) {
                    conn.commit();
                } else {
                    conn.rollback();
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } catch (RuntimeException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể xác nhận thanh toán một cách an toàn.", e);
        }
        
        if (success) {
            // Thông báo cho bệnh nhân
            notifyPatientPaymentConfirmed(invoice);

            // Ghi audit log
            auditLogDAO.logAction(
                    "Xác nhận thanh toán hóa đơn " + invoice.getInvoiceType() + " #" + invoiceId + " (" + paymentMethod + ")",
                    "Staff",
                    "invoices",
                    invoice.getStatus(),
                    "Paid"
            );
        }

        return success;
    }

    private String createReceiptCode(String paymentMethod, int invoiceId) {
        String prefix = "BankTransfer".equalsIgnoreCase(paymentMethod) ? "BT" : "CASH";
        String date = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE);
        return prefix + "-" + date + "-HD" + invoiceId;
    }

    private String firstNonBlank(String first, String second) {
        if (first != null && !first.trim().isEmpty()) {
            return first.trim();
        }
        return second == null ? "" : second.trim();
    }

    private String appendPatientReference(String note, String patientReference, String receiptCode) {
        String normalizedNote = note == null ? "" : note.trim();
        if (patientReference.isEmpty() || patientReference.equals(receiptCode)) {
            return normalizedNote;
        }
        String referenceNote = "Mã tham chiếu bệnh nhân: " + patientReference;
        return normalizedNote.isEmpty() ? referenceNote : normalizedNote + " | " + referenceNote;
    }

    private void notifyPatientPaymentConfirmed(Invoice invoice) {
        if (invoice.getAppointmentId() == null) return;
        Appointment apt = appointmentDAO.findAppointmentById(invoice.getAppointmentId());
        if (apt == null || apt.getPatient() == null) return;

        String typeLabel = "PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType()) ? "trước khám (phí khám)"
                : "POST_EXAM".equalsIgnoreCase(invoice.getInvoiceType()) ? "sau khám (siêu âm)"
                : "PRESCRIPTION".equalsIgnoreCase(invoice.getInvoiceType()) ? "đơn thuốc" : "dịch vụ";

        String title = "💰 Xác nhận thanh toán thành công";
        String content = "Thanh toán hóa đơn " + typeLabel + " (HĐ-" + invoice.getId() + ") trị giá " 
                + new java.text.DecimalFormat("#,###").format(invoice.getTotalAmount()) + "đ đã được xác nhận. ";
        if ("PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType())) {
            content += "Lịch hẹn của bạn đã được xác nhận thành công.";
        }

        sendNotification(apt.getPatient(), content);

        int patientUserId = getUserIdForPatient(apt.getPatient().getId());
        if (patientUserId > 0) {
            new com.clinic.dao.NotificationDAO().create(patientUserId, title, content);
        }
    }

}
