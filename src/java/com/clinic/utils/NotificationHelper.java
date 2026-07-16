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

    // ── Loại 1: KTV trả kết quả xét nghiệm ─────────────────────────────────
    public static void labResultReady(int doctorUserId, String serviceName, int recordId) {
        dao.create(doctorUserId,
            "🔬 Kết quả xét nghiệm đã có",
            "Xét nghiệm \"" + serviceName + "\" (hồ sơ #" + recordId + ") " +
            "đã có kết quả. Vui lòng vào xem và hoàn tất hồ sơ bệnh án.");
    }

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

    // ── Loại 4: Hồ sơ draft chờ quá 24 giờ ─────────────────────────────────
    // (Gọi từ scheduled job hoặc khi bác sĩ vào dashboard)
    public static void draftRecordReminder(int doctorUserId, int recordId,
                                           String patientName) {
        dao.create(doctorUserId,
            "⏰ Hồ sơ đang chờ kết quả XN",
            "Hồ sơ bệnh án #" + recordId + " của " + patientName +
            " đang ở trạng thái chờ kết quả xét nghiệm hơn 24 giờ. " +
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
                     "SELECT u.full_name, CONVERT(varchar,a.appointment_date,23), " +
                     "       a.time_slot, d.user_id " +
                     "FROM appointments a " +
                     "JOIN users u ON u.id = a.patient_id " +
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

    // ── Loại 6: Báo động khẩn cấp SOS từ bệnh nhân ───────────────────────────
    public static void sosAlert(int doctorUserId, String patientName, String queueNum, String symptoms) {
        dao.create(doctorUserId,
            "🚨 Báo động khẩn cấp SOS (Hàng đợi: " + queueNum + ")",
            "Bệnh nhân " + patientName + " đã kích hoạt SOS khẩn cấp! Triệu chứng: " + symptoms + ". Vui lòng chuẩn bị tiếp nhận khám.");
    }

    /**
     * Kiểm tra và tạo nhắc nhở cho các hồ sơ draft chờ > 24h.
     * Gọi mỗi khi bác sĩ vào dashboard.
     */
    public static void checkDraftReminders(int doctorId, int doctorUserId) {
        String sql =
            "SELECT mr.id, u.full_name " +
            "FROM medical_records mr " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN users u ON u.id = a.patient_id " +
            "WHERE mr.status = 'draft' " +
            "  AND a.doctor_id = ? " +
            "  AND mr.created_at < DATEADD(HOUR, -24, GETDATE()) " +
            "  AND NOT EXISTS (" +
            "    SELECT 1 FROM notifications n " +
            "    WHERE n.user_id = ? " +
            "      AND n.title LIKE N'%Hồ sơ đang chờ%' " +
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
}