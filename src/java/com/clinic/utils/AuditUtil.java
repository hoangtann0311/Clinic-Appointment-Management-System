package com.clinic.utils;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Tiện ích ghi nhật ký hoạt động (Audit Log) tập trung cho toàn hệ thống.
 *
 * <p><b>Nguyên tắc:</b>
 * <ul>
 *   <li>Gọi từ Service layer — KHÔNG gọi từ Controller hay JSP.</li>
 *   <li>Ghi log đồng bộ nhưng nhẹ — chỉ INSERT 1 dòng, không query nặng.</li>
 *   <li>Không throw exception — nếu ghi log lỗi, chỉ in ra stderr, không làm
 *       hỏng nghiệp vụ chính.</li>
 *   <li>Tự động trích xuất IP address từ HttpServletRequest.</li>
 * </ul>
 *
 * <p><b>Cách dùng:</b>
 * <pre>{@code
 *   // Trong Service (có HttpServletRequest request):
 *   AuditUtil.log(request, "Cập nhật giá dịch vụ Siêu âm 4D từ 200k → 250k",
 *                 "services", "200000", "250000");
 *
 *   // Trong Service (có User object, không có request):
 *   AuditUtil.log(user.getId(), "Hệ thống tự động tạo lịch trình bác sĩ",
 *                 "doctor_schedules", null, null, "127.0.0.1");
 * }</pre>
 */
public class AuditUtil {

    private AuditUtil() {
        // Singleton — không cho khởi tạo
    }

    // ──────────────────────────────────────────────
    // PUBLIC API — gọi từ Service
    // ──────────────────────────────────────────────

    /**
     * Ghi audit log với đầy đủ thông tin từ HttpServletRequest.
     * Tự động trích xuất user từ session và IP từ request.
     *
     * @param request   HttpServletRequest (để lấy user + IP)
     * @param action    mô tả hành động bằng tiếng Việt (VD: "Tạo mới dịch vụ Siêu âm 4D")
     * @param tableName bảng bị tác động (VD: "services", "users", "medicines")
     * @param oldValue  giá trị cũ (có thể null)
     * @param newValue  giá trị mới (có thể null)
     */
    public static void log(jakarta.servlet.http.HttpServletRequest request,
                           String action, String tableName,
                           String oldValue, String newValue) {
        Integer userId = null;
        String ip = getClientIp(request);

        try {
            Object userObj = request.getSession(false) != null
                    ? request.getSession(false).getAttribute("user") : null;
            if (userObj instanceof User) {
                userId = ((User) userObj).getId();
            }
        } catch (Exception e) {
            // Session không hợp lệ → userId giữ null
        }

        insert(userId, action, tableName, oldValue, newValue, ip);
    }

    /**
     * Ghi audit log với userId và IP chỉ định (dùng khi không có request).
     *
     * @param userId    ID của user thực hiện (có thể null nếu là hệ thống)
     * @param action    mô tả hành động
     * @param tableName bảng bị tác động
     * @param oldValue  giá trị cũ (có thể null)
     * @param newValue  giá trị mới (có thể null)
     * @param ipAddress địa chỉ IP (có thể null)
     */
    public static void log(Integer userId, String action, String tableName,
                           String oldValue, String newValue, String ipAddress) {
        insert(userId, action, tableName, oldValue, newValue, ipAddress);
    }

    /**
     * Ghi audit log nhanh — chỉ cần action và tableName.
     *
     * @param request   HttpServletRequest
     * @param action    mô tả hành động
     * @param tableName bảng bị tác động
     */
    public static void log(jakarta.servlet.http.HttpServletRequest request,
                           String action, String tableName) {
        log(request, action, tableName, null, null);
    }

    /**
     * Ghi audit log cho thao tác UPDATE — tự động format old/new value.
     *
     * @param request    HttpServletRequest
     * @param action     mô tả hành động (VD: "Cập nhật giá dịch vụ")
     * @param tableName  bảng bị tác động
     * @param fieldName  tên trường thay đổi (VD: "price")
     * @param oldValue   giá trị cũ
     * @param newValue   giá trị mới
     */
    public static void logUpdate(jakarta.servlet.http.HttpServletRequest request,
                                 String action, String tableName,
                                 String fieldName, String oldValue, String newValue) {
        String oldJson = "{\"" + fieldName + "\":\"" + (oldValue != null ? oldValue : "") + "\"}";
        String newJson = "{\"" + fieldName + "\":\"" + (newValue != null ? newValue : "") + "\"}";
        log(request, action, tableName, oldJson, newJson);
    }

    /**
     * Ghi audit log cho hệ thống tự động (không có user).
     *
     * @param action    mô tả hành động
     * @param tableName bảng bị tác động
     * @param newValue  giá trị mới (có thể null)
     */
    public static void logSystem(String action, String tableName, String newValue) {
        insert(null, "[HỆ THỐNG] " + action, tableName, null, newValue, "127.0.0.1");
    }

    // ──────────────────────────────────────────────
    // PRIVATE — thực hiện INSERT
    // ──────────────────────────────────────────────

    private static void insert(Integer userId, String action, String tableName,
                               String oldValue, String newValue, String ipAddress) {
        String sql = "INSERT INTO audit_logs (user_id, action, table_name, old_value, new_value, ip_address, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setNString(2, action);
            ps.setNString(3, tableName);
            ps.setNString(4, oldValue);
            ps.setNString(5, newValue);
            ps.setString(6, ipAddress);
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));

            ps.executeUpdate();
        } catch (SQLException e) {
            // Ghi log lỗi nhưng KHÔNG throw — không làm hỏng nghiệp vụ chính
            System.err.println("[AuditUtil] Lỗi ghi audit log: " + e.getMessage());
            System.err.println("  Action: " + action);
            System.err.println("  Table: " + tableName);
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { /* ignore */ }
            }
            DatabaseConfig.closeConnection(conn);
        }
    }

    /**
     * Trích xuất địa chỉ IP thực của client từ request.
     * Xử lý cả trường hợp đứng sau proxy/load balancer (X-Forwarded-For).
     */
    private static String getClientIp(jakarta.servlet.http.HttpServletRequest request) {
        if (request == null) return "unknown";

        // Kiểm tra header X-Forwarded-For (khi chạy sau proxy/load balancer)
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()
                && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            // X-Forwarded-For có thể chứa nhiều IP, lấy IP đầu tiên (client gốc)
            int commaIdx = xForwardedFor.indexOf(',');
            return commaIdx > 0 ? xForwardedFor.substring(0, commaIdx).trim() : xForwardedFor.trim();
        }

        // Fallback về địa chỉ IP trực tiếp
        String remoteAddr = request.getRemoteAddr();
        return (remoteAddr != null && !remoteAddr.isEmpty()) ? remoteAddr : "unknown";
    }
}
