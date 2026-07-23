package com.clinic.utils;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.NotificationDAO;

import java.sql.*;

/**
 * Helper tạo thông báo cho các sự kiện trong hệ thống.
 * Tất cả logic tạo notification tập trung ở đây để dễ bảo trì.
 */
public class NotificationHelper {

    private static final NotificationDAO dao = new NotificationDAO();


    // ── Loại 2: Lịch hẹn mới được đặt với bác sĩ ───────────────────────────
    public static void newAppointment(int doctorUserId, String patientName,
                                      String appointmentDate, String timeSlot) {
        dao.create(doctorUserId,
            "📅 Lịch hẹn mới",
            "Bệnh nhân " + patientName + " vừa đặt lịch khám vào " +
            timeSlot + " ngày " + appointmentDate + ".");
    }

    // ── Loại 3a: Lịch làm việc được duyệt ──────────────────────────────────
    public static void scheduleApproved(int doctorUserId, String workDate,
                                        String startTime, String endTime) {
        dao.create(doctorUserId,
            "✅ Lịch làm việc được duyệt",
            "Ca làm việc ngày " + workDate + " (" + startTime + " – " + endTime +
            ") của bạn đã được Manager duyệt.");
    }

    // ── Loại 3b: Lịch làm việc bị từ chối ──────────────────────────────────
    public static void scheduleRejected(int doctorUserId, String workDate,
                                        String startTime, String endTime,
                                        String reason) {
        dao.create(doctorUserId,
            "❌ Lịch làm việc bị từ chối",
            "Ca làm việc ngày " + workDate + " (" + startTime + " – " + endTime +
            ") đã bị từ chối. Lý do: " + (reason != null ? reason : "không rõ") + ".");
    }

    public static void draftRecordReminder(int doctorUserId, int recordId,
                                           String patientName) {
        dao.create(doctorUserId,
            "⏰ Hồ sơ chưa hoàn tất (Draft)",
            "Hồ sơ bệnh án #" + recordId + " của " + patientName +
            " đang ở trạng thái nháp (draft) hơn 24 giờ. " +
            "Vui lòng kiểm tra và hoàn tất.");
    }

    // ── Loại 5: Bệnh nhân có dấu hiệu nguy cơ ──────────────────────────────
    public static void riskFlagAlert(int doctorUserId, int recordId,
                                     String patientName, String flags) {
        dao.create(doctorUserId,
            "⚠️ Bệnh nhân có dấu hiệu nguy cơ",
            "Hồ sơ #" + recordId + " – " + patientName +
            " có dấu hiệu cần theo dõi: " + flags + ". Vui lòng xem lại.");
    }

    // ── Loại 6: Báo bệnh nhân có chỉ định siêu âm mới ───────────────────────────
    public static int getPatientUserIdByRecord(int medicalRecordId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT p.user_id FROM medical_records mr " +
                     "JOIN appointments a ON a.id = mr.appointment_id " +
                     "JOIN patients p ON p.id = a.patient_id WHERE mr.id=?")) {
            ps.setInt(1, medicalRecordId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("user_id");
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public static String getServiceName(int serviceId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT service_name FROM services WHERE id=?")) {
            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("service_name");
        } catch (Exception e) { e.printStackTrace(); }
        return "Dịch vụ chỉ định";
    }

    public static void notifyPatientForUltrasound(int medicalRecordId, int serviceId) {
        notifyPatientForUltrasound(medicalRecordId, serviceId, false);
    }

    /**
     * Informs the patient about a new ultrasound order without implying that an
     * unpaid additional service can already be performed.
     */
    public static void notifyPatientForUltrasound(int medicalRecordId, int serviceId,
                                                  boolean requiresAdditionalPayment) {
        int patientId = getPatientUserIdByRecord(medicalRecordId);
        String serviceName = getServiceName(serviceId);
        if (patientId > 0) {
            String message = requiresAdditionalPayment
                    ? "Bác sĩ đã chỉ định siêu âm \"" + serviceName
                    + "\". Đây là dịch vụ phát sinh; vui lòng hoàn tất hóa đơn trước khi đến phòng siêu âm."
                    : "Bác sĩ đã chỉ định thực hiện siêu âm \"" + serviceName
                    + "\". Dịch vụ đã nằm trong lịch hẹn của bạn; vui lòng đến phòng siêu âm theo hướng dẫn.";
            dao.create(patientId,
                "📋 Chỉ định siêu âm mới",
                message);
        }
    }

    /** Notifies the clinical doctor after the ultrasound specialist signs a report. */
    public static void ultrasoundReportSigned(int medicalRecordId, String serviceName) {
        String sql = "SELECT d.user_id, p.full_name "
                + "FROM medical_records mr "
                + "JOIN appointments a ON a.id = mr.appointment_id "
                + "JOIN doctors d ON d.id = a.doctor_id "
                + "JOIN patients p ON p.id = a.patient_id "
                + "WHERE mr.id = ?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dao.create(rs.getInt("user_id"),
                            "Kết quả siêu âm đã sẵn sàng",
                            "Bác sĩ siêu âm đã ký kết quả "
                                    + (serviceName == null || serviceName.isBlank() ? "siêu âm" : serviceName)
                                    + " của bệnh nhân " + rs.getString("full_name")
                                    + ". Vui lòng xem kết quả để hoàn thiện hồ sơ bệnh án.");
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationHelper] ultrasoundReportSigned ERROR: " + e.getMessage());
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /** Lấy user_id của bác sĩ từ doctor.id */
    public static int getDoctorUserId(int doctorId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT user_id FROM doctors WHERE id=?")) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("user_id");
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Lấy user_id của bác sĩ từ appointment_id */
    public static int getDoctorUserIdByAppt(int appointmentId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT d.user_id FROM appointments a " +
                     "JOIN doctors d ON d.id = a.doctor_id WHERE a.id=?")) {
            ps.setInt(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("user_id");
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Lấy thông tin appointment (patientName, date, timeSlot, doctorUserId) */
    public static String[] getApptInfo(int appointmentId) {
        // [0]=patientName, [1]=appointmentDate, [2]=timeSlot, [3]=doctorUserId
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT pt.full_name, CONVERT(varchar,a.appointment_date,23), " +
                     "       a.time_slot, d.user_id " +
                     "FROM appointments a " +
                     "JOIN patients pt ON pt.id = a.patient_id " +
                     "JOIN doctors d ON d.id = a.doctor_id " +
                     "WHERE a.id=?")) {
            ps.setInt(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return new String[]{
                rs.getString(1), rs.getString(2),
                rs.getString(3), String.valueOf(rs.getInt(4))
            };
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Kiểm tra và tạo nhắc nhở cho các hồ sơ draft chờ > 24h.
     * Gọi mỗi khi bác sĩ vào dashboard.
     */
    public static void checkDraftReminders(int doctorId, int doctorUserId) {
        String sql =
            "SELECT mr.id, pt.full_name " +
            "FROM medical_records mr " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN patients pt ON pt.id = a.patient_id " +
            "WHERE mr.status = 'draft' " +
            "  AND a.doctor_id = ? " +
            "  AND mr.created_at < DATEADD(HOUR, -24, GETDATE()) " +
            "  AND NOT EXISTS (" +
            "    SELECT 1 FROM notifications n " +
            "    WHERE n.user_id = ? " +
            "      AND n.title LIKE N'%Hồ sơ chưa hoàn tất%' " +
            "      AND n.content LIKE CONCAT(N'%#', mr.id, N'%') " +
            "      AND n.created_at > DATEADD(HOUR, -24, GETDATE())" +
            "  )";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setInt(2, doctorUserId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                draftRecordReminder(doctorUserId, rs.getInt(1), rs.getString(2));
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ── Thông báo cập nhật bệnh án ──────────────────────────────────────────
    public static void medicalRecordUpdated(int medicalRecordId, String finalDiagnosis) {
        int patientUserId = getPatientUserIdByRecord(medicalRecordId);
        if (patientUserId > 0) {
            dao.create(patientUserId,
                "📝 Hồ sơ bệnh án được cập nhật",
                "Bác sĩ đã cập nhật hồ sơ bệnh án của bạn. Chẩn đoán: " + 
                (finalDiagnosis != null && !finalDiagnosis.isBlank() ? finalDiagnosis : "chưa có kết luận cuối cùng") + 
                ". Vui lòng xem chi tiết trong mục Hồ sơ bệnh án.");
        }
    }

    // ── Thông báo thanh toán thành công ─────────────────────────────────────
    public static void paymentConfirmed(int appointmentId, String invoiceType, double amount) {
        String sql = "SELECT p.user_id FROM appointments a " +
                     "JOIN patients p ON p.id = a.patient_id WHERE a.id=?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int patientUserId = rs.getInt("user_id");
                    String typeLabel = "PRE_EXAM".equalsIgnoreCase(invoiceType) ? "Phí khám" : "Phí dịch vụ phát sinh / siêu âm";
                    dao.create(patientUserId,
                        "💰 Xác nhận thanh toán thành công",
                        "Hóa đơn " + typeLabel + " trị giá " + new java.text.DecimalFormat("#,###").format(amount) + "đ của bạn đã được xác nhận thanh toán thành công.");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}
