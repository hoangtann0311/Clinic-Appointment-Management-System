package com.clinic.service;

import com.clinic.dao.*;
import com.clinic.config.DBContext;
import com.clinic.config.DatabaseConfig;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;
import com.clinic.model.Invoice;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.NotificationHelper;
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
    private final AppointmentValidationService validationService = new AppointmentValidationService();

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
        LocalDate birthDate = dob == null || dob.trim().isEmpty()
                ? null
                : LocalDate.parse(dob);

        if (birthDate != null && birthDate.isAfter(LocalDate.now())) {
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
        // booked_count đã được lưu trực tiếp trong doctor_schedules, không cần đếm riêng
        return schedules;
    }

    /**
     * Read-only slot board — query trực tiếp doctor_schedules + shifts.
     * Trả về List<Map> cho JSP hiển thị.
     */
    public List<Map<String, Object>> getDoctorSlotsForReception(LocalDate date) {
        LocalDate selectedDate = date != null ? date : LocalDate.now();
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ds.id, ds.doctor_id, ds.work_date, ds.max_slots, ds.booked_count, ds.status, "
                + "s.name AS shift_name, s.start_time, s.end_time, "
                + "d.full_name AS doctor_name, d.specialization AS doctor_specialization, "
                + "(SELECT STRING_AGG(p.full_name + ' (' + a.status + ')', ', ') "
                + " FROM appointments a JOIN patients p ON a.patient_id = p.id "
                + " WHERE a.schedule_id = ds.id AND a.status NOT IN ('Cancelled')) AS booked_patients "
                + "FROM doctor_schedules ds "
                + "INNER JOIN shifts s ON ds.shift_id = s.id "
                + "INNER JOIN doctors d ON d.id = ds.doctor_id "
                + "WHERE ds.work_date = ? AND ds.status = 'APPROVED' "
                + "ORDER BY d.full_name, s.start_time";
        try (java.sql.Connection conn = DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(selectedDate));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("doctorId", rs.getInt("doctor_id"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("doctorSpec", rs.getString("doctor_specialization"));
                    row.put("workDate", rs.getDate("work_date"));
                    java.sql.Time start = rs.getTime("start_time");
                    java.sql.Time end = rs.getTime("end_time");
                    row.put("startTime", start);
                    row.put("endTime", end);
                    int maxSlots = rs.getInt("max_slots");
                    int bookedCount = rs.getInt("booked_count");
                    row.put("maxSlots", maxSlots);
                    row.put("bookedCount", bookedCount);
                    String docStatus = rs.getString("status");
                    String uiStatus = "UNAVAILABLE";
                    if ("APPROVED".equalsIgnoreCase(docStatus)) {
                        uiStatus = (bookedCount < maxSlots) ? "AVAILABLE" : "BOOKED";
                    } else if ("CANCELLED".equalsIgnoreCase(docStatus)) {
                        uiStatus = "CANCELLED";
                    }
                    row.put("status", uiStatus);
                    String shiftName = rs.getString("shift_name");
                    row.put("shiftName", shiftName);
                    String timeLabel = (shiftName != null ? shiftName + " (" : "") 
                                     + (start != null ? start.toString().substring(0, 5) : "")
                                     + " - " 
                                     + (end != null ? end.toString().substring(0, 5) : "")
                                     + (shiftName != null ? ")" : "");
                    row.put("timeLabel", timeLabel);
                    row.put("available", bookedCount < maxSlots);
                    String bookedPatients = rs.getString("booked_patients");
                    row.put("bookedPatients", bookedPatients != null ? bookedPatients : "");
                    list.add(row);
                }
            }
        } catch (Exception e) {
            System.err.println("[StaffReceptionService] getDoctorSlotsForReception ERROR: " + e.getMessage());
        }
        return list;
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
                                           String appDateStr, String slot, String symptoms, String lmpStr, boolean isPriority,
                                           String address, String cccd) {
        return createManualBookingWithOverride(name, phone, dob, doctorId, serviceId, appDateStr, slot, symptoms, lmpStr, address, cccd, null, false, 0);
    }

    public Appointment createManualBookingWithOverride(String name, String phone, String dob, String doctorId, String serviceId,
                                                   String appDateStr, String slot, String symptoms, String lmpStr,
                                                   String address, String cccd, String overrideReason, boolean checkInImmediately, int staffUserId) {

        // 1. Validate dữ liệu đầu vào
        List<String> errors = validationService.validateAppointmentInput(
                name, phone, dob, doctorId, serviceId, appDateStr, slot, symptoms, lmpStr
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

        // Dịch vụ — nếu không chọn thì dùng "Khám lâm sàng" mặc định
        if (serviceId == null || serviceId.isEmpty()) {
            serviceId = String.valueOf(serviceDAO.getDefaultExaminationServiceId());
        }
        ServiceItem service = findServiceById(serviceId);
        if (service == null) {
            throw new IllegalArgumentException("Dịch vụ khám mặc định chưa được cấu hình. Vui lòng liên hệ quản trị viên.");
        }

        // 5. Tìm schedule_id tương ứng trong doctor_schedules
        Integer foundSlotId = findAvailableOrCurrentSlot(doctor.getId(), appDate, slot, null);
        if (foundSlotId == null) {
            throw new IllegalArgumentException("Ca làm việc này đã hết chỗ hoặc không tồn tại. Vui lòng chọn ca khác.");
        }

        // [V5-FIX] Nếu đặt trong ngày hôm nay: kiểm tra ca chưa kết thúc
        // Trường hợp checkInImmediately=true mà ca đã qua → sai nghiệp vụ
        // Staff có overrideReason hợp lệ → được phép bỏ qua (ví dụ: đặt bù cho ca trễ)
        if (appDate.equals(LocalDate.now()) && (overrideReason == null || overrideReason.trim().isEmpty())) {
            String shiftEndTime = getShiftEndTimeBySlotId(foundSlotId);
            if (shiftEndTime != null) {
                try {
                    java.time.LocalTime endT = java.time.LocalTime.parse(shiftEndTime);
                    java.time.LocalDateTime shiftEndDT = java.time.LocalDateTime.of(appDate, endT);
                    if (java.time.LocalDateTime.now().isAfter(shiftEndDT)) {
                        throw new IllegalArgumentException(
                            "Ca khám đã kết thúc lúc " + shiftEndTime + ". Không thể đặt lịch cho ca này. " +
                            "Nếu muốn tiếp tục, hãy nhập Lý do ngoại lệ (Override Reason).");
                    }
                } catch (java.time.format.DateTimeParseException ignored) {}
            }
        }


        // 6. Tìm hoặc tạo bệnh nhân
        Patient patient = findPatientByPhone(phone);

        if (patient == null) {
            patient = createPatient(name, phone, dob);
        }

        if (patient == null) {
            throw new IllegalArgumentException("Không thể tạo hồ sơ bệnh nhân.");
        }

        // Kiểm tra 1 bệnh nhân chỉ có 1 lịch khám ngoại trú còn hiệu lực trong cùng 1 ngày
        String sameDayError = validationService.validateSameDayActiveAppointment(patient.getId(), doctor.getId(), appDate, null, true, overrideReason);
        if (sameDayError != null) {
            throw new IllegalArgumentException(sameDayError);
        }

        // Cập nhật địa chỉ và CCCD (từ form đặt lịch thủ công)
        if ((address != null && !address.trim().isEmpty()) || (cccd != null && !cccd.trim().isEmpty())) {
            try {
                patientDAO.updatePatient(patient.getId(), patient.getFullName(), patient.getPhone(),
                        patient.getDateOfBirth(), address, cccd);
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] Không thể cập nhật address/cccd: " + e.getMessage());
            }
        }

        // 7. Tính tuổi thai
        String gestationalAge = calculateGestationalAge(lmp, appDate);

        // 8. Tính giá khám — đồng nhất với luồng online (PatientBookingService)
        double basePrice = 200000.00;
        if (doctor.getExperienceYears() > 0) {
            basePrice += (doctor.getExperienceYears() * 50000.00);
        }
        double servicePrice = service.getPrice();
        double totalAmount = basePrice + servicePrice;

        // 9. Tạo lịch hẹn
        String status = "Confirmed";
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

        // 10. Lưu lịch hẹn + base_fee trong cùng transaction
        int patientUserId = getUserIdForPatient(patient.getId());
        appointment = appointmentDAO.createStaffAppointmentWithHeldSlot(
                appointment,
                foundSlotId,
                patientUserId > 0 ? patientUserId : null,
                totalAmount
        );
        if (appointment == null) {
            throw new IllegalArgumentException("Khung giờ vừa được người khác chọn. Vui lòng tải lại và chọn slot khác.");
        }

        // 11. Tạo hóa đơn PRE_EXAM — copy từ base_fee
        if (appointment != null) {
            double price = totalAmount;
            Invoice preExamInvoice = new Invoice();
            preExamInvoice.setAppointmentId(appointment.getId());
            preExamInvoice.setTotalAmount(java.math.BigDecimal.valueOf(price));
            preExamInvoice.setStatus(checkInImmediately ? "Paid" : "Unpaid");
            preExamInvoice.setInvoiceType("PRE_EXAM");
            invoiceDAO.insert(preExamInvoice);

            if (checkInImmediately && appointment.getAppointmentDate().equals(LocalDate.now())) {
                appointmentDAO.checkInAndRenumber(appointment.getId());
            }
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
                    "Lịch hẹn khám của bạn đã được tạo vào ngày " + appDateStr + ". Bác sĩ sẽ khám theo ca làm việc, vui lòng đến đúng giờ ca."
            );
        }

        return appointment;
    }

    public List<Appointment> getSmartQueue() {
        List<Appointment> result = new ArrayList<>();
        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
                    && !"NoShow".equalsIgnoreCase(appointment.getStatus())) {
                result.add(appointment);
            }
        }
        result.sort((a1, a2) -> {
            int score1 = getStatusPriorityScore(a1.getStatus());
            int score2 = getStatusPriorityScore(a2.getStatus());
            if (score1 != score2) return Integer.compare(score1, score2);
            if (a1.isPriority() != a2.isPriority()) return a1.isPriority() ? -1 : 1;
            return Integer.compare(a1.getId(), a2.getId());
        });
        return result;
    }

    private int getStatusPriorityScore(String status) {
        if (status == null) return 9;

        String normalizedStatus = status.trim().toUpperCase();

        switch (normalizedStatus) {
            case "PENDING": return 1;    // Cần duyệt gấp — hiển thị đầu tiên
            case "INPROGRESS": return 2;
            case "WAITING": return 3;
            case "CONFIRMED": return 4;
            case "SUCCESS":
            case "COMPLETED": return 5;
            case "CANCELLED": return 6;
            case "NOSHOW": return 7;
            default: return 9;
        }
    }

    /**
     * Check-in bệnh nhân — chuyển trạng thái sang Waiting + cấp STT.
     * Đặc tả B5: HOÁ ĐƠN PRE_EXAM PHẢI ĐÃ THANH TOÁN trước khi check-in.
     * Việc xác nhận thanh toán là một hành động RIÊNG (confirmPreExamPayment).
     */
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

            if ("Pending".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException(
                        "Lịch hẹn chưa được duyệt. Vui lòng nhấn \"Duyệt & Tạo Hóa Đơn\" trước.");
            }

            // [B5] Điều kiện tiên quyết: hoá đơn PRE_EXAM PHẢI đã thanh toán
            com.clinic.dao.InvoiceDAO invoiceDAO2 = new com.clinic.dao.InvoiceDAO();
            com.clinic.model.Invoice preExamInv = invoiceDAO2.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
            if (preExamInv == null) {
                throw new IllegalArgumentException(
                        "Chưa có hóa đơn phí khám. Vui lòng duyệt lịch hẹn trước để tạo hóa đơn.");
            }
            if (!"Paid".equalsIgnoreCase(preExamInv.getStatus())) {
                throw new IllegalArgumentException(
                        "Bệnh nhân chưa thanh toán phí khám. Vui lòng xác nhận thanh toán trước khi check-in.");
            }

            // Validate thời gian check-in
            java.time.LocalTime actualStartTime = null;
            java.time.LocalTime actualEndTime = null;
            try {
                String shiftSql = "SELECT s.start_time, s.end_time FROM doctor_schedules ds "
                        + "INNER JOIN shifts s ON ds.shift_id = s.id WHERE ds.id = ?";
                try (java.sql.Connection c2 = com.clinic.config.DatabaseConfig.getConnection();
                     java.sql.PreparedStatement p2 = c2.prepareStatement(shiftSql)) {
                    p2.setInt(1, apt.getSlotId() != null ? apt.getSlotId() : 0);
                    try (java.sql.ResultSet r2 = p2.executeQuery()) {
                        if (r2.next()) {
                            java.sql.Time st = r2.getTime("start_time");
                            java.sql.Time et = r2.getTime("end_time");
                            if (st != null) actualStartTime = st.toLocalTime();
                            if (et != null) actualEndTime = et.toLocalTime();
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] Không lấy được giờ ca từ shifts: " + e.getMessage());
            }

            if (actualStartTime != null) {
                java.time.LocalDate apptDate = apt.getAppointmentDate();
                java.time.LocalDateTime apptDateTime = java.time.LocalDateTime.of(apptDate, actualStartTime);
                java.time.LocalDateTime nowDT = java.time.LocalDateTime.now();

                java.time.LocalDateTime earlyLimit = apptDateTime.minusMinutes(120);
                if (nowDT.isBefore(earlyLimit)) {
                    throw new IllegalArgumentException(
                            "Chưa đến giờ check-in. Vui lòng check-in sau "
                            + earlyLimit.toLocalTime().toString() + ".");
                }

                if (actualEndTime != null) {
                    java.time.LocalDateTime endDateTime = java.time.LocalDateTime.of(apptDate, actualEndTime);
                    if (nowDT.isAfter(endDateTime)) {
                        throw new IllegalArgumentException(
                                "Ca khám này đã kết thúc vào lúc " + actualEndTime.toString()
                                + ". Bệnh nhân đến quá muộn, không thể check-in được nữa.");
                    }
                }
            }

            // Chỉ check-in, không xác nhận thanh toán (đã làm riêng)
            if (!appointmentDAO.checkInAndRenumber(appointmentId)) {
                throw new IllegalArgumentException("Không thể check-in. Vui lòng kiểm tra lại trạng thái lịch hẹn.");
            }

            auditLogDAO.logAction(
                    "Check-in bệnh nhân, xếp hàng đợi",
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "Waiting"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    public void approveAndRequestPayment(String id, int staffUserId) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);
            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }
            if (!"Pending".equalsIgnoreCase(apt.getStatus()) && !"Confirmed".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Chỉ lịch hẹn ở trạng thái Chờ duyệt mới có thể thực hiện thao tác này.");
            }

            boolean ok = appointmentDAO.approveBookingAndEnsurePreExamInvoice(appointmentId);
            if (!ok) {
                throw new IllegalArgumentException("Không thể duyệt lịch hẹn và gửi yêu cầu thanh toán.");
            }

            auditLogDAO.logAction(
                    "Lễ tân duyệt lịch hẹn #" + appointmentId + " & gửi YCTT PRE_EXAM",
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "Confirmed"
            );
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    public void approvePostExamPayment(String id, int staffUserId) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);
            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }
            if (!"InProgress".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Chỉ ca khám đang ở trạng thái Đang khám mới có thể thực hiện thao tác này.");
            }

            com.clinic.model.Invoice invoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, "POST_EXAM");
            if (invoice == null || !"Unpaid".equalsIgnoreCase(invoice.getStatus())) {
                throw new IllegalArgumentException("Không tìm thấy hóa đơn cận lâm sàng chưa thanh toán.");
            }

            // Chống xác nhận trùng
            if ("Paid".equalsIgnoreCase(invoice.getStatus())) {
                throw new IllegalArgumentException("Hoá đơn này đã được thanh toán trước đó.");
            }

            String sql = "UPDATE invoices SET status = 'Paid', confirmed_at = GETDATE(), confirmed_by = ?, "
                    + "paid_at = GETDATE(), paid_by_user_id = ?, payment_method = 'CASH' "
                    + "WHERE id = ? AND status = 'Unpaid'";
            try (java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, staffUserId);
                ps.setInt(2, staffUserId);
                ps.setInt(3, invoice.getId());
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    throw new IllegalArgumentException("Không thể cập nhật trạng thái hóa đơn.");
                }
            } catch (java.sql.SQLException e) {
                System.err.println("[StaffReceptionService] approvePostExamPayment ERROR: " + e.getMessage());
                throw new IllegalArgumentException("Lỗi hệ thống khi cập nhật thanh toán cận lâm sàng.");
            }

            auditLogDAO.logAction(
                    "Lễ tân xác nhận thanh toán cận lâm sàng cho hóa đơn #" + invoice.getId(),
                    "Staff",
                    "invoices",
                    invoice.getStatus(),
                    "Paid"
            );

            // Gửi thông báo cho bệnh nhân
            try {
                double amount = invoice.getTotalAmount() != null ? invoice.getTotalAmount().doubleValue() : 0;
                NotificationHelper.paymentConfirmed(appointmentId, "POST_EXAM", amount);
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] Gửi TB thanh toán POST_EXAM thất bại: " + e.getMessage());
            }
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
        if (appointment.getAppointmentDate() == null || !appointment.getAppointmentDate().equals(LocalDate.now())) {
            throw new IllegalArgumentException("Chỉ được đánh dấu ưu tiên cho lịch hẹn trong ngày hôm nay.");
        }
        if (!"Waiting".equalsIgnoreCase(appointment.getStatus())) {
            throw new IllegalArgumentException(
                    "Chỉ ca đã check-in và đang chờ khám mới được đánh dấu ưu tiên.");
        }
        if (!appointmentDAO.isPreExamPaid(appointmentId)) {
            throw new IllegalArgumentException(
                    "Lịch hẹn chưa hoàn tất thanh toán trước khám (PRE_EXAM), không thể đánh dấu ưu tiên.");
        }
        if (appointment.isPriority()) {
            throw new IllegalArgumentException("Ca khám này đã được đánh dấu ưu tiên.");
        }

        // Cập nhật is_priority và xếp lại hàng đợi trong CÙNG 1 DB Transaction
        if (!appointmentDAO.markPriorityAndRenumber(appointmentId, userId, normalizedReason)) {
            throw new IllegalArgumentException(
                    "Không thể đánh dấu ưu tiên vì hàng đợi vừa thay đổi.");
        }

        AuditUtil.log(userId,
                "Đánh dấu ưu tiên tiếp nhận lịch khám #" + appointmentId
                        + " - Lý do: " + normalizedReason,
                "appointments", "is_priority=0",
                "is_priority=1; reason=" + normalizedReason, ipAddress);
    }

    public void clearPriority(String id, int userId, String ipAddress) {
        int appointmentId = parseAppointmentId(id);
        Appointment appointment = appointmentDAO.findAppointmentById(appointmentId);
        if (appointment == null) {
            throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
        }
        if (!appointment.isPriority()) {
            throw new IllegalArgumentException("Ca khám này không ở mức ưu tiên.");
        }
        if (!"Waiting".equalsIgnoreCase(appointment.getStatus())) {
            throw new IllegalArgumentException(
                    "Chỉ có thể bỏ ưu tiên khi ca đang chờ khám (Waiting).");
        }

        // Hủy is_priority và xếp lại hàng đợi trong CÙNG 1 DB Transaction
        if (!appointmentDAO.clearPriorityAndRenumber(appointmentId)) {
            throw new IllegalArgumentException(
                    "Không thể bỏ ưu tiên vì hàng đợi vừa thay đổi.");
        }

        AuditUtil.log(userId,
                "Bỏ ưu tiên tiếp nhận lịch khám #" + appointmentId,
                "appointments",
                "is_priority=1; reason=" + appointment.getPriorityReason(),
                "is_priority=0", ipAddress);
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

    public void cancelAppointment(String id, int staffUserId) {
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

            if ("NoShow".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã được đánh dấu vắng mặt, không thể hủy.");
            }

            // Nếu PRE_EXAM đã thanh toán: đánh dấu hoàn tiền trước khi hủy
            // (hoàn tiền thực tế do staff và bệnh nhân tự xử lý với nhau tại quầy)
            boolean wasRefunded = false;
            if (appointmentDAO.isPreExamPaid(appointmentId)) {
                Invoice preExamInv = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
                if (preExamInv != null && "Paid".equalsIgnoreCase(preExamInv.getStatus())) {
                    refundInvoice(preExamInv.getId(), staffUserId,
                            "Hoàn tiền do huỷ lịch hẹn #" + appointmentId + " — Staff và bệnh nhân tự xử lý tại quầy");
                    wasRefunded = true;
                }
            }

            boolean success = appointmentDAO.cancelAppointmentAndReleaseSlot(appointmentId, 0, "Lễ tân hủy lịch hẹn");
            if (!success) {
                throw new IllegalArgumentException("Không thể hủy lịch hẹn hoặc lịch đã hoàn thành/đang khám.");
            }

            auditLogDAO.logAction(
                    "Hủy lịch hẹn của " + apt.getPatientName()
                    + (wasRefunded ? " (đã hoàn tiền PRE_EXAM — Staff tự xử lý với bệnh nhân)" : ""),
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "Cancelled"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    /**
     * Đánh dấu bệnh nhân không đến (NoShow).
     * Điều kiện: lịch Confirmed/Pending của HÔM NAY, đã qua giờ kết thúc ca.
     */
    public void markNoShow(String id, int staffUserId) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);

            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }

            if (!"Pending".equalsIgnoreCase(apt.getStatus()) && !"Confirmed".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException(
                        "Chỉ có thể đánh dấu không đến cho lịch ở trạng thái Chờ duyệt hoặc Đã duyệt.");
            }

            if (apt.getAppointmentDate() == null || !apt.getAppointmentDate().equals(LocalDate.now())) {
                throw new IllegalArgumentException(
                        "Chỉ được đánh dấu không đến cho lịch hẹn trong ngày hôm nay.");
            }

            // Cảnh báo nếu PRE_EXAM đã thanh toán: cần hoàn tiền riêng (P13)
            boolean hasPaidInvoice = appointmentDAO.isPreExamPaid(appointmentId);

            if (apt.getSlotId() != null && apt.getSlotId() > 0) {
                String endTimeStr = getShiftEndTimeBySlotId(apt.getSlotId());
                if (endTimeStr != null) {
                    try {
                        java.time.LocalTime endTime = java.time.LocalTime.parse(endTimeStr);
                        java.time.LocalDateTime shiftEnd = java.time.LocalDateTime.of(LocalDate.now(), endTime);
                        if (java.time.LocalDateTime.now().isBefore(shiftEnd)) {
                            throw new IllegalArgumentException(
                                    "Ca khám chưa kết thúc (kết thúc lúc " + endTimeStr
                                    + "). Không thể đánh dấu không đến khi ca vẫn đang diễn ra.");
                        }
                    } catch (java.time.format.DateTimeParseException ignored) {}
                }
            }

            String reason = "Bệnh nhân không đến khám — Lễ tân #" + staffUserId + " đánh dấu NoShow"
                    + (hasPaidInvoice ? " — CẢNH BÁO: Hoá đơn PRE_EXAM đã thanh toán, cần xử lý hoàn tiền!" : "");
            boolean ok = appointmentDAO.markNoShowAndReleaseSlot(appointmentId, staffUserId, reason);
            if (!ok) {
                throw new IllegalArgumentException("Không thể đánh dấu không đến. Vui lòng kiểm tra lại trạng thái lịch hẹn.");
            }

            auditLogDAO.logAction(
                    "Đánh dấu không đến cho lịch hẹn #" + appointmentId + " — " + apt.getPatientName()
                    + (hasPaidInvoice ? " (có hoá đơn đã thanh toán cần hoàn tiền)" : ""),
                    "Staff",
                    "appointments",
                    apt.getStatus(),
                    "NoShow"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        }
    }

    public Appointment findAppointmentById(int id) {
        return appointmentDAO.findAppointmentById(id);
    }

    public void updateAppointment(int id, String doctorId, String serviceId, String appDateStr, String slot, Integer scheduleId, String symptoms, String lmpStr) {
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

        Integer targetSlotId = scheduleId;
        if (targetSlotId == null) {
            targetSlotId = findAvailableOrCurrentSlot(doctor.getId(), appDate, slot, apt.getSlotId());
            if (targetSlotId == null) {
                throw new IllegalArgumentException(
                        "Khung giờ đã hết chỗ hoặc không thuộc lịch làm việc đã được xác nhận của bác sĩ. Vui lòng chọn lại."
                );
            }
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

    /**
     * Tìm doctor_schedule.id phù hợp.
     * slot có thể là:
     *   - scheduleId trực tiếp (chuỗi số thuần): dùng luôn
     *   - Giờ "HH:mm": tìm ca chứa giờ này
     *   - null/rỗng: trả null
     */
    private Integer findAvailableOrCurrentSlot(int doctorId, LocalDate workDate, String slot, Integer currentSlotId) {
        if (slot == null || slot.trim().isEmpty()) return null;
        try {
            // Nếu slot là scheduleId trực tiếp
            try {
                int directId = Integer.parseInt(slot.trim());
                return directId > 0 ? directId : null;
            } catch (NumberFormatException ignored) {
                // không phải số — tiếp tục parse giờ
            }

            // Parse giờ HH:mm (bỏ phần " - HH:mm" nếu có)
            java.time.LocalTime time;
            String slotClean = slot.contains("-") ? slot.split("-")[0].trim() : slot.trim();
            time = java.time.LocalTime.parse(slotClean);

            String sql = "SELECT ds.id, s.end_time FROM doctor_schedules ds "
                    + "INNER JOIN shifts s ON ds.shift_id = s.id "
                    + "WHERE ds.doctor_id = ? AND ds.work_date = ? AND s.start_time <= CAST(? AS time) "
                    + "AND (s.end_time >= CAST(? AS time) OR s.end_time < s.start_time) "
                    + "AND (ds.status = 'APPROVED' AND COALESCE(ds.booked_count, 0) < ds.max_slots "
                    + "     OR ds.id = ?)";
            try (Connection conn = DatabaseConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, doctorId);
                ps.setDate(2, java.sql.Date.valueOf(workDate));
                ps.setTime(3, java.sql.Time.valueOf(time));
                ps.setTime(4, java.sql.Time.valueOf(time));
                ps.setInt(5, currentSlotId != null ? currentSlotId : -1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int scheduleId = rs.getInt("id");
                        java.sql.Time endTimeSql = rs.getTime("end_time");
                        if (endTimeSql != null && workDate.isEqual(LocalDate.now())) {
                            java.time.LocalTime endTime = endTimeSql.toLocalTime();
                            java.time.LocalDateTime shiftEnd = java.time.LocalDateTime.of(workDate, endTime);
                            if (java.time.LocalDateTime.now().plusMinutes(30).isAfter(shiftEnd)) {
                                throw new IllegalArgumentException("Ca làm việc sắp kết thúc (dưới 30 phút). Không thể nhận thêm bệnh nhân.");
                            }
                        }
                        return scheduleId;
                    }
                    return null;
                }
            }
        } catch (IllegalArgumentException e) {
            throw e;
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

    /** Lấy giờ kết thúc ca (HH:mm) từ schedule_id để kiểm tra ca đã qua chưa */
    private String getShiftEndTimeBySlotId(int slotId) {
        String sql = "SELECT s.end_time FROM doctor_schedules ds " +
                     "INNER JOIN shifts s ON ds.shift_id = s.id WHERE ds.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, slotId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Time t = rs.getTime("end_time");
                    return t != null ? t.toLocalTime().toString().substring(0, 5) : null;
                }
            }
        } catch (Exception e) {
            System.err.println("[StaffReceptionService] getShiftEndTimeBySlotId error: " + e.getMessage());
        }
        return null;
    }


    /**
     * Xác nhận bệnh nhân đã nộp tiền mặt tại quầy cho hoá đơn PRE_EXAM.
     * Ghi nhận đầy đủ: paid_at, paid_by_user_id, payment_method = 'CASH'.
     */
    public void confirmCashPayment(String id, int staffUserId) {
        try {
            int appointmentId = Integer.parseInt(id);

            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);
            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy lịch hẹn.");
            }

            String currentStatus = apt.getStatus();
            if (!"Confirmed".equalsIgnoreCase(currentStatus)
                    && !"Waiting".equalsIgnoreCase(currentStatus)) {
                throw new IllegalArgumentException(
                        "Chỉ có thể xác nhận thanh toán cho lịch đã được duyệt (Confirmed) hoặc đã check-in (Waiting). "
                        + "Trạng thái hiện tại: " + currentStatus + ".");
            }

            // Chống xác nhận trùng: kiểm tra PRE_EXAM chưa Paid
            Invoice preExamInv = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
            if (preExamInv != null && "Paid".equalsIgnoreCase(preExamInv.getStatus())) {
                throw new IllegalArgumentException("Hoá đơn PRE_EXAM đã được thanh toán trước đó. Không thể xác nhận trùng.");
            }

            String transactionCode = "CASH_" + appointmentId + "_" + System.currentTimeMillis();

            // Lấy amount từ base_fee (đồng bộ P1), fallback 250,000
            double amount = 250000;
            String sqlReadFee = "SELECT ISNULL(base_fee, 250000) AS fee FROM appointments WHERE id = ?";
            try (Connection connFee = DatabaseConfig.getConnection();
                 PreparedStatement psFee = connFee.prepareStatement(sqlReadFee)) {
                psFee.setInt(1, appointmentId);
                try (ResultSet rsFee = psFee.executeQuery()) {
                    if (rsFee.next()) {
                        double fee = rsFee.getDouble("fee");
                        if (fee > 0) amount = fee;
                    }
                }
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] Không đọc được base_fee: " + e.getMessage());
            }

            // Ghi đủ: paid_at, paid_by_user_id, payment_method
            String sqlUpdate = "UPDATE invoices " +
                    "SET status = 'Paid', transaction_code = ?, " +
                    "confirmed_at = GETDATE(), confirmed_by = ?, " +
                    "paid_at = GETDATE(), paid_by_user_id = ?, payment_method = 'CASH' " +
                    "WHERE appointment_id = ? AND invoice_type = 'PRE_EXAM' AND status = 'Unpaid'";

            String sqlInsert = "INSERT INTO invoices (appointment_id, invoice_type, total_amount, status, " +
                    "transaction_code, confirmed_at, confirmed_by, " +
                    "paid_at, paid_by_user_id, payment_method) " +
                    "SELECT ?, 'PRE_EXAM', ?, 'Paid', ?, GETDATE(), ?, GETDATE(), ?, 'CASH' " +
                    "WHERE NOT EXISTS ( " +
                    "   SELECT 1 FROM invoices WHERE appointment_id = ? AND invoice_type = 'PRE_EXAM' " +
                    ")";

            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                        ps.setString(1, transactionCode);
                        ps.setInt(2, staffUserId);
                        ps.setInt(3, staffUserId);
                        ps.setInt(4, appointmentId);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                        ps.setInt(1, appointmentId);
                        ps.setDouble(2, amount);
                        ps.setString(3, transactionCode);
                        ps.setInt(4, staffUserId);
                        ps.setInt(5, staffUserId);
                        ps.setInt(6, appointmentId);
                        ps.executeUpdate();
                    }
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }

            appointmentDAO.confirmAppointmentAfterPreExamPaid(appointmentId);

            auditLogDAO.logAction(
                    "Xác nhận thu tiền mặt PRE_EXAM cho lịch hẹn #" + appointmentId
                    + " — Số tiền: " + String.format("%,.0fđ", amount),
                    "Staff",
                    "invoices",
                    "Unpaid",
                    "Paid"
            );

            // Gửi thông báo cho bệnh nhân
            try {
                NotificationHelper.paymentConfirmed(appointmentId, "PRE_EXAM", amount);
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] Gửi TB thanh toán PRE_EXAM thất bại: " + e.getMessage());
            }

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã lịch hẹn không hợp lệ.");
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new IllegalArgumentException("Không thể cập nhật thanh toán PRE_EXAM.");
        }
    }

    /**
     * [P13] Hoàn tiền một hoá đơn đã thanh toán.
     * Chỉ hoàn được hoá đơn Paid, không hoàn hai lần.
     */
    public void refundInvoice(int invoiceId, int staffUserId, String reason) {
        if (reason == null || reason.trim().length() < 10 || reason.trim().length() > 500) {
            throw new IllegalArgumentException("Lý do hoàn tiền phải từ 10 đến 500 ký tự.");
        }

        Invoice invoice = invoiceDAO.getById(invoiceId);
        if (invoice == null) {
            throw new IllegalArgumentException("Không tìm thấy hoá đơn.");
        }
        if (!"Paid".equalsIgnoreCase(invoice.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể hoàn tiền cho hoá đơn đã thanh toán. Trạng thái hiện tại: " + invoice.getStatus());
        }

        String sql = "UPDATE invoices SET status = 'Refunded', refunded_at = GETDATE(), "
                + "refunded_by_user_id = ?, refund_reason = ? "
                + "WHERE id = ? AND status = 'Paid'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffUserId);
            ps.setString(2, reason.trim());
            ps.setInt(3, invoiceId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new IllegalArgumentException("Không thể hoàn tiền — hoá đơn có thể đã bị thay đổi. Vui lòng tải lại.");
            }
        } catch (SQLException e) {
            throw new IllegalArgumentException("Lỗi hệ thống khi hoàn tiền: " + e.getMessage());
        }

        auditLogDAO.logAction(
                "Hoàn tiền hoá đơn #" + invoiceId + " — Lý do: " + reason.trim(),
                "Staff",
                "invoices",
                "Paid",
                "Refunded"
        );
    }

    /** Paginated slot list — query trực tiếp doctor_schedules + shifts. */
    public List<Map<String, Object>> getDoctorSlotsForReceptionPaginated(LocalDate date, String search,
                                                                          String status, int page, int pageSize) {
        return getDoctorSlotsForReception(date); // đơn giản hóa: trả tất cả, JSP tự phân trang
    }

    public int countDoctorSlotsForReception(LocalDate date, String search, String status) {
        return getDoctorSlotsForReception(date).size();
    }

    public static class SlotPageResult {
        public List<Map<String, Object>> slots;
        public int totalPages;
        public int totalRecords;
        public int currentPage;

        public List<Map<String, Object>> getSlots() { return slots; }
        public int getTotalPages() { return totalPages; }
        public int getTotalRecords() { return totalRecords; }
        public int getCurrentPage() { return currentPage; }
    }

    public SlotPageResult getDoctorSlotsPage(LocalDate date, String search, String status,
                                              int page, int pageSize) {
        List<Map<String, Object>> allSlots = getDoctorSlotsForReception(date);
        // Lọc theo search và status
        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> s : allSlots) {
            if (status != null && !status.isEmpty()) {
                String sStatus = (String) s.get("status");
                if (!status.equalsIgnoreCase(sStatus)) continue;
            }
            if (search != null && !search.trim().isEmpty()) {
                String searchLower = search.trim().toLowerCase();
                String doctorName = String.valueOf(s.getOrDefault("doctorName", "")).toLowerCase();
                if (!doctorName.contains(searchLower)) continue;
            }
            filtered.add(s);
        }
        int totalRecords = filtered.size();
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        int from = (page - 1) * pageSize;
        int to = Math.min(from + pageSize, totalRecords);

        SlotPageResult result = new SlotPageResult();
        result.slots = from < totalRecords ? filtered.subList(from, to) : new ArrayList<>();
        result.totalRecords = totalRecords;
        result.totalPages = totalPages;
        result.currentPage = page;
        return result;
    }

    public static class QueueResult {
        public List<Appointment> appointments;
        public int totalPages;
        public int totalRecords;
        public int currentPage;
    }

    public QueueResult getSmartQueuePaginated(LocalDate date, String searchKeyword, String statusFilter, int page, int pageSize) {
        List<Appointment> allFiltered = new ArrayList<>();
        String searchLower = (searchKeyword != null) ? searchKeyword.trim().toLowerCase() : "";
        List<Appointment> all = appointmentDAO.getAppointmentsByDate(date);
        int skippedDateNull = 0, skippedDateMismatch = 0, skippedStatus = 0;
        for (Appointment appointment : all) {
            if (appointment.getAppointmentDate() == null) {
                skippedDateNull++;
                continue;
            }
            if (!appointment.getAppointmentDate().equals(date)) {
                skippedDateMismatch++;
                continue;
            }

            // Trạng thái (status)
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                if (!statusFilter.equalsIgnoreCase(appointment.getStatus())) {
                    skippedStatus++;
                    continue;
                }
            } else {
                // Khi không chọn bộ lọc cụ thể, chỉ bỏ qua các ca đã hủy hoặc bệnh nhân không đến
                if ("Cancelled".equalsIgnoreCase(appointment.getStatus())
                        || "NoShow".equalsIgnoreCase(appointment.getStatus())) {
                    skippedStatus++;
                    continue;
                }
            }

            // Từ khóa tìm kiếm (mã, sđt, tên)
            if (!searchLower.isEmpty()) {
                String ptName = appointment.getPatientName() != null ? appointment.getPatientName().toLowerCase() : "";
                String ptPhone = (appointment.getPatient() != null && appointment.getPatient().getPhone() != null) ? appointment.getPatient().getPhone().toLowerCase() : "";
                String aptCode = "APT-" + appointment.getId();
                if (!ptName.contains(searchLower) && !ptPhone.contains(searchLower) && !aptCode.toLowerCase().contains(searchLower)) {
                    continue;
                }
            }

            allFiltered.add(appointment);
        }
        System.err.println("[StaffReception] Filtered: skippedStatus=" + skippedStatus
                + " skippedDateNull=" + skippedDateNull
                + " skippedDateMismatch=" + skippedDateMismatch
                + " matched=" + allFiltered.size());
        allFiltered.sort((a1, a2) -> {
            int score1 = getStatusPriorityScore(a1.getStatus());
            int score2 = getStatusPriorityScore(a2.getStatus());
            if (score1 != score2) return Integer.compare(score1, score2);
            if (a1.isPriority() != a2.isPriority()) return a1.isPriority() ? -1 : 1;
            return Integer.compare(a1.getId(), a2.getId());
        });

        int totalRecords = allFiltered.size();
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalRecords);
        
        List<Appointment> pagedList = new ArrayList<>();
        if (fromIndex < totalRecords) {
            pagedList = allFiltered.subList(fromIndex, toIndex);
        }

        QueueResult result = new QueueResult();
        result.appointments = pagedList;
        result.totalRecords = totalRecords;
        result.totalPages = totalPages;
        result.currentPage = page;
        
        return result;
    }

    public List<Appointment> getSmartQueueByDate(LocalDate date) {
        return getSmartQueuePaginated(date, "", "", 1, 1000).appointments;
    }

    public int getWidgetAppointmentsByDate(LocalDate date) {
        List<Appointment> list = appointmentDAO.getAppointmentsByDate(date);
        int count = 0;
        for (Appointment a : list) {
            if (!"Cancelled".equalsIgnoreCase(a.getStatus())
                    && !"NoShow".equalsIgnoreCase(a.getStatus())) {
                count++;
            }
        }
        return count;
    }

    public int getWidgetWaitingQueueByDate(LocalDate date) {
        List<Appointment> list = appointmentDAO.getAppointmentsByDate(date);
        int count = 0;
        for (Appointment a : list) {
            if ("Waiting".equalsIgnoreCase(a.getStatus())) count++;
        }
        return count;
    }

    /** Phát hiện bệnh nhân đến muộn: đã quá hạn check-in (chậm nhất 15 phút trước giờ khám) mà chưa check-in */
    public java.util.Set<Integer> getLateAppointmentIds(LocalDate date) {
        java.util.Set<Integer> late = new java.util.HashSet<>();
        if (!date.equals(LocalDate.now())) return late;

        java.time.LocalTime now = java.time.LocalTime.now();
        for (Appointment apt : appointmentDAO.getAppointmentsByDate(date)) {
            String status = apt.getStatus();
            if (status == null) continue;
            // Chỉ check các trạng thái đang chờ khám (chưa check-in)
            if (!"Confirmed".equalsIgnoreCase(status) && !"Pending".equalsIgnoreCase(status)) continue;
            if (apt.getTimeSlot() == null || apt.getTimeSlot().trim().isEmpty()) continue;

            try {
                // Lấy giờ bắt đầu ca làm việc từ shift (nếu có)
                java.time.LocalTime shiftStart = null;
                if (apt.getShiftStart() != null && !apt.getShiftStart().trim().isEmpty()) {
                    try {
                        shiftStart = java.time.LocalTime.parse(apt.getShiftStart().trim());
                    } catch (Exception ignored) { }
                }

                // Chỉ kiểm tra đến muộn khi ca làm việc đã bắt đầu
                // (tránh đánh dấu muộn khi ca còn chưa tới giờ, ví dụ ca tối 19h mà mới 14h)
                if (shiftStart != null && now.isBefore(shiftStart.minusMinutes(15))) {
                    continue;
                }

                String start = apt.getTimeSlot().contains(" - ")
                        ? apt.getTimeSlot().split(" - ")[0].trim()
                        : apt.getTimeSlot().split("-")[0].trim();
                java.time.LocalTime slotTime = java.time.LocalTime.parse(start);

                // Chuẩn hóa AM/PM dựa vào shift context:
                // Nếu slotTime có vẻ là giờ sáng (0-11) nhưng shift bắt đầu từ 12h trưa trở đi,
                // thì slotTime thực chất là giờ chiều/tối → cộng thêm 12 tiếng.
                if (shiftStart != null && slotTime.getHour() < 12 && shiftStart.getHour() >= 12) {
                    slotTime = slotTime.plusHours(12);
                }

                // Bệnh nhân bị coi là muộn nếu đã qua mốc 15 phút trước giờ hẹn
                if (now.isAfter(slotTime.minusMinutes(15))) {
                    late.add(apt.getId());
                }
            } catch (Exception ignored) { }
        }
        return late;
    }

    /** Đếm số bệnh nhân đang chờ/có lịch của mỗi bác sĩ trong hôm nay */
    public Map<Integer, Integer> getDoctorWorkloadToday() {
        Map<Integer, Integer> workload = new HashMap<>();
        for (Appointment apt : appointmentDAO.getAppointmentsByDate(LocalDate.now())) {
            if (apt.getDoctorId() > 0
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

    /**
     * Tự động chuyển bệnh nhân đang chờ sang ca tiếp theo khi bác sĩ hết ca.
     * Chạy mỗi lần staff load trang reception.
     *
     * @param date Ngày cần kiểm tra (thường là hôm nay)
     * @return Số bệnh nhân đã được chuyển ca
     */
    public int autoMovePatientsToNextShift(LocalDate date) {
        if (!date.equals(LocalDate.now())) return 0; // chỉ chạy cho ngày hôm nay

        int movedCount = 0;
        java.time.LocalTime now = java.time.LocalTime.now();

        // 1. Tìm tất cả ca làm việc APPROVED trong ngày đã hết giờ
        String endedShiftsSql =
            "SELECT ds.id AS slot_id, ds.doctor_id, ds.work_date, s.start_time, s.end_time, " +
            "       d.full_name AS doctor_name, s.name AS shift_name " +
            "FROM doctor_schedules ds " +
            "JOIN shifts s ON ds.shift_id = s.id " +
            "JOIN doctors d ON ds.doctor_id = d.id " +
            "WHERE ds.status = 'APPROVED' " +
            "AND ds.work_date = ? " +
            "AND CAST(s.end_time AS time) <= CAST(? AS time) " +
            "ORDER BY s.end_time ASC";

        java.util.List<java.util.Map<String, Object>> endedShifts = new java.util.ArrayList<>();
        try (java.sql.Connection c = DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = c.prepareStatement(endedShiftsSql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
            ps.setString(2, now.toString());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("slotId", rs.getInt("slot_id"));
                    row.put("doctorId", rs.getInt("doctor_id"));
                    row.put("workDate", rs.getDate("work_date").toLocalDate());
                    row.put("endTime", rs.getTime("end_time").toLocalTime());
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("shiftName", rs.getString("shift_name"));
                    endedShifts.add(row);
                }
            }
        } catch (Exception e) {
            System.err.println("[StaffReceptionService] autoMovePatientsToNextShift ERROR (find shifts): " + e.getMessage());
            return 0;
        }

        if (endedShifts.isEmpty()) return 0;

        // 2. Với mỗi ca đã hết, tìm bệnh nhân đang chờ và chuyển sang ca tiếp theo
        for (java.util.Map<String, Object> shift : endedShifts) {
            int oldSlotId = (int) shift.get("slotId");
            int doctorId = (int) shift.get("doctorId");
            String doctorName = (String) shift.get("doctorName");
            String shiftName = (String) shift.get("shiftName");

            // Tìm bệnh nhân đang chờ trong ca này
            String waitingSql =
                "SELECT a.id, a.patient_id, p.full_name AS patient_name " +
                "FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.id " +
                "WHERE a.schedule_id = ? " +
                "AND a.status IN ('Confirmed', 'Waiting') " +
                "AND a.appointment_date = ?";

            java.util.List<java.util.Map<String, Object>> waitingPatients = new java.util.ArrayList<>();
            try (java.sql.Connection c = DatabaseConfig.getConnection();
                 java.sql.PreparedStatement ps = c.prepareStatement(waitingSql)) {
                ps.setInt(1, oldSlotId);
                ps.setDate(2, java.sql.Date.valueOf(date));
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String, Object> p = new java.util.HashMap<>();
                        p.put("apptId", rs.getInt("id"));
                        p.put("patientId", rs.getInt("patient_id"));
                        p.put("patientName", rs.getString("patient_name"));
                        waitingPatients.add(p);
                    }
                }
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] autoMovePatientsToNextShift ERROR (find patients): " + e.getMessage());
                continue;
            }

            if (waitingPatients.isEmpty()) continue;

            // Tìm ca tiếp theo của bác sĩ (cùng ngày ca sau, hoặc ngày tiếp theo)
            String nextShiftSql =
                "SELECT TOP 1 ds.id AS slot_id, ds.work_date, s.start_time, s.end_time, s.name AS shift_name " +
                "FROM doctor_schedules ds " +
                "JOIN shifts s ON ds.shift_id = s.id " +
                "WHERE ds.doctor_id = ? " +
                "AND ds.status = 'APPROVED' " +
                "AND ds.booked_count < ds.max_slots " +
                "AND (ds.work_date > ? OR (ds.work_date = ? AND s.start_time > ?)) " +
                "ORDER BY ds.work_date ASC, s.start_time ASC";

            java.util.Map<String, Object> nextShift = null;
            try (java.sql.Connection c = DatabaseConfig.getConnection();
                 java.sql.PreparedStatement ps = c.prepareStatement(nextShiftSql)) {
                ps.setInt(1, doctorId);
                ps.setDate(2, java.sql.Date.valueOf(date));
                ps.setDate(3, java.sql.Date.valueOf(date));
                ps.setString(4, now.toString());
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nextShift = new java.util.HashMap<>();
                        nextShift.put("slotId", rs.getInt("slot_id"));
                        nextShift.put("workDate", rs.getDate("work_date").toLocalDate());
                        nextShift.put("startTime", rs.getTime("start_time").toLocalTime());
                        nextShift.put("endTime", rs.getTime("end_time").toLocalTime());
                        nextShift.put("shiftName", rs.getString("shift_name"));
                    }
                }
            } catch (Exception e) {
                System.err.println("[StaffReceptionService] autoMovePatientsToNextShift ERROR (find next): " + e.getMessage());
                continue;
            }

            if (nextShift == null) {
                // Không có ca tiếp theo — bỏ qua, bệnh nhân giữ nguyên
                System.out.println("[StaffReceptionService] Bác sĩ " + doctorName
                        + " hết ca " + shiftName + " nhưng không có ca tiếp theo. "
                        + waitingPatients.size() + " bệnh nhân đang chờ sẽ không được chuyển.");
                continue;
            }

            int newSlotId = (int) nextShift.get("slotId");
            String nextShiftName = (String) nextShift.get("shiftName");
            java.time.LocalDate nextWorkDate = (java.time.LocalDate) nextShift.get("workDate");
            String nextDateLabel = nextWorkDate.equals(date) ? "hôm nay" : nextWorkDate.toString();

            // 3. Chuyển từng bệnh nhân
            for (java.util.Map<String, Object> patient : waitingPatients) {
                int apptId = (int) patient.get("apptId");
                String patientName = (String) patient.get("patientName");

                java.sql.Connection conn = null;
                try {
                    conn = DatabaseConfig.getConnection();
                    conn.setAutoCommit(false);

                    // Increment new slot
                    String incNewSql = "UPDATE doctor_schedules SET booked_count = booked_count + 1 " +
                            "WHERE id = ? AND booked_count < max_slots AND status = 'APPROVED'";
                    int newRows;
                    try (java.sql.PreparedStatement ps = conn.prepareStatement(incNewSql)) {
                        ps.setInt(1, newSlotId);
                        newRows = ps.executeUpdate();
                    }
                    if (newRows == 0) {
                        conn.rollback();
                        System.err.println("[StaffReceptionService] Không thể book slot mới #" + newSlotId + " (đã đầy)");
                        continue;
                    }

                    // Update appointment
                    String updApptSql = "UPDATE appointments SET schedule_id = ?, " +
                            "appointment_date = ? WHERE id = ? AND schedule_id = ?";
                    int apptRows;
                    try (java.sql.PreparedStatement ps = conn.prepareStatement(updApptSql)) {
                        ps.setInt(1, newSlotId);
                        ps.setDate(2, java.sql.Date.valueOf(nextWorkDate));
                        ps.setInt(3, apptId);
                        ps.setInt(4, oldSlotId);
                        apptRows = ps.executeUpdate();
                    }
                    if (apptRows == 0) {
                        conn.rollback();
                        // Rollback the slot increment
                        try (java.sql.Connection c2 = DatabaseConfig.getConnection();
                             java.sql.PreparedStatement ps2 = c2.prepareStatement(
                                     "UPDATE doctor_schedules SET booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END WHERE id = ?")) {
                            ps2.setInt(1, newSlotId);
                            ps2.executeUpdate();
                        } catch (Exception ignored) {}
                        continue;
                    }

                    // Decrement old slot
                    try (java.sql.PreparedStatement ps = conn.prepareStatement(
                            "UPDATE doctor_schedules SET booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END WHERE id = ?")) {
                        ps.setInt(1, oldSlotId);
                        ps.executeUpdate();
                    }

                    conn.commit();
                    movedCount++;

                    // Audit log
                    auditLogDAO.logAction(
                            "Hệ thống tự động chuyển BN " + patientName + " (#" + apptId + ") "
                            + "từ ca " + shiftName + " sang ca " + nextShiftName
                            + " (" + nextDateLabel + ") của BS. " + doctorName,
                            "System",
                            "appointments",
                            "Waiting",
                            "Waiting"
                    );

                    // Gửi thông báo cho bệnh nhân
                    try {
                        int patientUserId = getUserIdForPatient((int) patient.get("patientId"));
                        if (patientUserId > 0) {
                            com.clinic.utils.NotificationHelper.sendCustomNotification(patientUserId,
                                    "🔄 Lịch khám được chuyển ca tự động",
                                    "Lịch khám của bạn với BS. " + doctorName
                                    + " đã được chuyển từ ca " + shiftName
                                    + " sang ca " + nextShiftName + " (" + nextDateLabel + ")"
                                    + " do bác sĩ đã hết ca làm việc. Vui lòng kiểm tra lại giờ khám mới.");
                        }
                    } catch (Exception ignored) {}

                    System.out.println("[StaffReceptionService] Auto-move: " + patientName
                            + " (#" + apptId + ") từ " + shiftName + " → " + nextShiftName
                            + " (" + nextDateLabel + ") — BS. " + doctorName);

                } catch (Exception e) {
                    if (conn != null) try { conn.rollback(); } catch (Exception ignored) {}
                    System.err.println("[StaffReceptionService] autoMovePatientsToNextShift ERROR (move): " + e.getMessage());
                } finally {
                    if (conn != null) try { conn.setAutoCommit(true); } catch (Exception ignored) {}
                    DatabaseConfig.closeConnection(conn);
                }
            }
        }

        return movedCount;
    }



}
