package com.clinic.service;

import com.clinic.dao.*;
import com.clinic.config.DBContext;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;
import com.clinic.model.*;
import com.clinic.utils.StaffValidator;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.*;

public class StaffReceptionService {

    private final PatientDAO patientDAO = new PatientDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public StaffReceptionService() {
    }

    // --- Patient Management ---
    public List<Patient> getAllPatients() {
        return patientDAO.getAllPatients();
    }
    
    public Patient findPatientByPhone(String phone) {
        return patientDAO.findPatientByPhone(phone);
    }

    public Patient createPatient(String name, String phone, String dob, String zaloId) {
        LocalDate birthDate = dob == null || dob.isEmpty()
                ? LocalDate.of(1995, 1, 1)
                : LocalDate.parse(dob);

        LocalDate today = LocalDate.now();

        if (birthDate.isAfter(today)) {
            throw new IllegalArgumentException("Ngày sinh sản phụ không được lớn hơn ngày hiện tại.");
        }

        int age = java.time.Period.between(birthDate, today).getYears();

        if (age < 12) {
            throw new IllegalArgumentException("Tuổi sản phụ phải từ 12 tuổi trở lên để đặt lịch khám.");
        }

        if (age > 55) {
            throw new IllegalArgumentException("Tuổi sản phụ không được vượt quá 55 tuổi khi đặt lịch khám sản/phụ khoa.");
        }

        Patient newPatient = patientDAO.createPatient(
                name,
                phone,
                birthDate,
                zaloId != null && !zaloId.isEmpty() ? zaloId : "zalo_" + phone
        );

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
                name, phone, dob, doctorId, serviceId, appDateStr, slot, symptoms, lmpStr, isEmergency
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

        // 4. Tự động chuyển SOS nếu có triệu chứng đau bụng dữ dội
        boolean finalEmergency = isEmergency ||
                (symptoms != null && symptoms.toLowerCase().contains("đau bụng dữ dội"));

        // 5. Nếu không phải SOS thì kiểm tra trùng slot
        if (!finalEmergency) {
            boolean slotBooked = appointmentDAO.isSlotBooked(
                    null,
                    doctor.getId(),
                    appDate,
                    slot
            );

            if (slotBooked) {
                throw new IllegalArgumentException("Khung giờ này đã có bệnh nhân đặt. Vui lòng chọn giờ khác.");
            }
        }

        // 6. Tìm hoặc tạo bệnh nhân
        Patient patient = findPatientByPhone(phone);

        if (patient == null) {
            patient = createPatient(name, phone, dob, "zalo_" + phone);
        }

        if (patient == null) {
            throw new IllegalArgumentException("Không thể tạo hồ sơ bệnh nhân.");
        }

        // 7. Tính tuổi thai
        String gestationalAge = calculateGestationalAge(lmp, appDate);

        // 8. Tạo lịch hẹn
        String status = finalEmergency ? "Emergency_SOS" : "Pending";
        String finalSlot = finalEmergency ? "Khẩn cấp (SOS)" : slot;

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
                finalEmergency,
                status
        );

        // 9. Cấp số SOS nếu là ca cấp cứu
        if (finalEmergency) {
            int nextSosNum = appointmentDAO.getNextSosQueueNumber(appDate);
            appointment.setQueueNumber("SOS-" + String.format("%02d", nextSosNum));
        }

        // 10. Lưu lịch hẹn
        appointment = appointmentDAO.createAppointment(appointment);

        // 11. Ghi log và gửi thông báo giả lập Zalo
        if (appointment != null) {
            if (finalEmergency) {
                auditLogDAO.logAction(
                        "Kích hoạt lịch hẹn SOS",
                        "Staff",
                        "appointments",
                        "-",
                        String.valueOf(appointment.getId())
                );

                sendMockZaloMessage(
                        patient,
                        "Cảnh báo SOS đã được kích hoạt. Vui lòng đến phòng khám ngay để được hỗ trợ."
                );
            } else {
                auditLogDAO.logAction(
                        "Tạo lịch hẹn thủ công cho " + patient.getFullName(),
                        "Staff",
                        "appointments",
                        "-",
                        String.valueOf(appointment.getId())
                );

                sendMockZaloMessage(
                        patient,
                        "Lịch hẹn khám của bạn đã được tạo vào ngày " + appDateStr + ", khung giờ " + slot + "."
                );
            }
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

            if (score1 != score2) {
                return Integer.compare(score1, score2);
            }

            return Integer.compare(a1.getId(), a2.getId());
        });

        return result;
    }

    private int getStatusPriorityScore(String status) {
        if (status == null) return 9;

        String normalizedStatus = status.trim().toUpperCase();

        switch (normalizedStatus) {
            case "EMERGENCY_SOS": return 1;
            case "INPROGRESS": return 2;
            case "WAITING": return 3;
            case "CONFIRMED": return 4;
            case "PENDING": return 5;
            case "SUCCESS": return 6;
            case "CANCELLED": return 7;
            case "NOSHOW": return 8;
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

            if ("SUCCESS".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã hoàn thành, không thể check-in.");
            }

            if ("InProgress".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Ca khám đang xử lý, không thể check-in lại.");
            }

            if ("Waiting".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Bệnh nhân đã check-in rồi.");
            }

            if ("Emergency_SOS".equalsIgnoreCase(apt.getStatus())) {
                appointmentDAO.updateStatus(appointmentId, "InProgress");

                auditLogDAO.logAction(
                        "Điều phối ca SOS vào phòng khám",
                        "Staff",
                        "appointments",
                        "Emergency_SOS",
                        "InProgress"
                );

                return;
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

    // --- SOS Alerts (UC15) ---
    public void activateEmergencySosManual(String name, String phone, String symptoms) {
        // 1. Validate dữ liệu SOS
        List<String> errors = StaffValidator.validateSos(name, phone, symptoms);

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(String.join("|", errors));
        }

        name = name.trim();
        phone = phone.trim();
        symptoms = symptoms.trim();

        // 2. Không cho tạo trùng SOS đang hoạt động cùng số điện thoại
        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if ("Emergency_SOS".equalsIgnoreCase(appointment.getStatus())
                    && appointment.getPatient() != null
                    && phone.equals(appointment.getPatient().getPhone())) {
                throw new IllegalArgumentException("Bệnh nhân này đang có một ca SOS đang hoạt động.");
            }
        }

        // 3. Tìm hoặc tạo bệnh nhân
        Patient patient = findPatientByPhone(phone);

        if (patient == null) {
            patient = createPatient(name, phone, "1998-01-01", "zalo_" + phone);
        }

        if (patient == null) {
            throw new IllegalArgumentException("Không thể tạo hồ sơ bệnh nhân cho ca SOS.");
        }

        // 4. Lấy bác sĩ và dịch vụ mặc định
        List<Doctor> doctors = doctorDAO.getAllDoctors();
        Doctor doctor = doctors.isEmpty() ? null : doctors.get(0);

        List<ServiceItem> services = serviceDAO.getAllServices();
        ServiceItem service = services.isEmpty() ? null : services.get(0);

        if (doctor == null) {
            throw new IllegalArgumentException("Chưa có bác sĩ nào trong hệ thống để điều phối ca SOS.");
        }

        if (service == null) {
            throw new IllegalArgumentException("Chưa có dịch vụ nào trong hệ thống để tạo ca SOS.");
        }

        // 5. Tạo appointment SOS
        Appointment appointment = new Appointment(
                0,
                patient,
                doctor,
                service,
                LocalDate.now(),
                "Khẩn cấp (SOS)",
                symptoms,
                null,
                "Không xác định",
                true,
                "Emergency_SOS"
        );

        LocalDate today = LocalDate.now();

        int nextSosNum = appointmentDAO.getNextSosQueueNumber(today);
        appointment.setQueueNumber("SOS-" + String.format("%02d", nextSosNum));

        appointment = appointmentDAO.createAppointment(appointment);

        if (appointment != null) {
            auditLogDAO.logAction(
                    "BÁO ĐỘNG ĐỎ: Lễ tân kích hoạt SOS khẩn cấp tại quầy",
                    "Staff",
                    "appointments",
                    "-",
                    String.valueOf(appointment.getId())
            );

            sendMockZaloMessage(
                    patient,
                    "Hệ thống CAMS: Báo động SOS khẩn cấp của bạn đã được kích hoạt. Bác sĩ đang chờ tiếp nhận."
            );
        }
    }

    public void dismissSosAlarm(String id) {
        try {
            int appointmentId = Integer.parseInt(id);
            Appointment apt = appointmentDAO.findAppointmentById(appointmentId);

            if (apt == null) {
                throw new IllegalArgumentException("Không tìm thấy ca SOS.");
            }

            if (!"Emergency_SOS".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Chỉ ca Emergency_SOS mới được tắt cảnh báo.");
            }

            appointmentDAO.updateStatus(appointmentId, "InProgress");

            auditLogDAO.logAction(
                    "Tắt cảnh báo SOS và bắt đầu tiếp nhận ca #" + id,
                    "Staff",
                    "appointments",
                    "Emergency_SOS",
                    "InProgress"
            );

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã ca SOS không hợp lệ.");
        }
    }

    // --- Simulated Zalo Server Webhook persisted to database ---
    private void sendMockZaloMessage(Patient patient, String content) {
        if (patient == null) return;
        String sql = "INSERT INTO notifications (user_id, title, content, channel, is_read, created_at) VALUES (?, ?, ?, 'Zalo', 0, GETDATE())";
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

    public List<Map<String, String>> getZaloNotifications() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT title, content, created_at FROM notifications WHERE channel = 'Zalo' ORDER BY id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                java.sql.Timestamp ts = rs.getTimestamp("created_at");
                map.put("time", ts != null ? ts.toString() : java.time.LocalDateTime.now().toString());
                map.put("name", rs.getString("title"));
                map.put("content", rs.getString("content"));
                map.put("zaloId", "zalo_" + rs.getString("title"));
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
            if ("Waiting".equalsIgnoreCase(appointment.getStatus())
                    || "Emergency_SOS".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }

        return count;
    }

    public int getWidgetActiveSos() {
        int count = 0;

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if ("Emergency_SOS".equalsIgnoreCase(appointment.getStatus())) {
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

            if ("SUCCESS".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Lịch hẹn đã hoàn thành, không thể hủy.");
            }

            if ("InProgress".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Ca khám đang xử lý, không thể hủy.");
            }

            if ("Waiting".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Bệnh nhân đã check-in, không thể hủy lịch bằng thao tác thường.");
            }

            if ("Emergency_SOS".equalsIgnoreCase(apt.getStatus())) {
                throw new IllegalArgumentException("Ca SOS khẩn cấp không thể hủy bằng thao tác thường.");
            }

            appointmentDAO.updateStatus(appointmentId, "Cancelled");

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
                || "InProgress".equalsIgnoreCase(apt.getStatus())
                || "Waiting".equalsIgnoreCase(apt.getStatus())) {
            throw new IllegalArgumentException("Không thể sửa lịch hẹn ở trạng thái " + apt.getStatus() + ".");
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
        LocalDate appDate = LocalDate.parse(appDateStr);
        LocalDate lmp = StaffValidator.isEmpty(lmpStr) ? null : LocalDate.parse(lmpStr);
        String gestationalAge = calculateGestationalAge(lmp, appDate);

        apt.setDoctor(doctor);
        apt.setService(service);
        apt.setAppointmentDate(appDate);
        apt.setTimeSlot(slot);
        apt.setSymptoms(symptoms);
        apt.setLastMenstrualPeriod(lmp);
        apt.setGestationalAge(gestationalAge);

        appointmentDAO.updateAppointmentDetails(apt);

        auditLogDAO.logAction(
                "Thay đổi thông tin lịch hẹn khám bệnh án #" + id + " cho sản phụ " + apt.getPatientName(),
                "Staff",
                "appointments",
                "-",
                String.valueOf(id)
        );
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

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
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

            if (score1 != score2) {
                return Integer.compare(score1, score2);
            }

            return Integer.compare(a1.getId(), a2.getId());
        });

        return result;
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

    public int getWidgetActiveSosByDate(LocalDate date) {
        int count = 0;

        for (Appointment appointment : appointmentDAO.getAllAppointments()) {
            if (appointment.getAppointmentDate() != null
                    && appointment.getAppointmentDate().equals(date)
                    && "Emergency_SOS".equalsIgnoreCase(appointment.getStatus())) {
                count++;
            }
        }

        return count;
    }
}
