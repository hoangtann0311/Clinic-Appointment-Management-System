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
     * Ghi audit log cho kiểm soát truy cập (Authorization).
     * Dành riêng cho AuthorizationFilter — ghi lại mọi lần truy cập
     * thành công hoặc bị từ chối vào các chức năng quan trọng.
     *
     * <p>Thông tin được ghi:
     * <ul>
     *   <li>Người dùng: email + userId</li>
     *   <li>Vai trò: roleName</li>
     *   <li>URL: path được yêu cầu</li>
     *   <li>Hành động: ACCESS_GRANTED hoặc ACCESS_DENIED</li>
     *   <li>Kết quả: SUCCESS hoặc DENIED + lý do</li>
     *   <li>Thời gian: tự động (GETDATE())</li>
     *   <li>Địa chỉ IP: trích xuất từ request</li>
     * </ul>
     *
     * @param request   HttpServletRequest (để lấy user + IP)
     * @param userEmail email của người dùng
     * @param roleName  tên vai trò (VD: "Admin", "Doctor")
     * @param path      đường dẫn được yêu cầu (VD: "/admin/users/")
     * @param result    kết quả: "SUCCESS" hoặc "DENIED"
     * @param reason    lý do (nếu bị từ chối), null nếu thành công
     */
    public static void logAccess(jakarta.servlet.http.HttpServletRequest request,
                                  String userEmail, String roleName, String path,
                                  String result, String reason) {
        StringBuilder detail = new StringBuilder();
        detail.append("[").append(result).append("] ");
        detail.append(userEmail);
        detail.append(" (").append(roleName).append(")");
        detail.append(" → ").append(path);
        if (reason != null && !reason.isEmpty()) {
            detail.append(" | Lý do: ").append(reason);
        }
        log(request, detail.toString(), "access_control", null, null);
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
    // ULTRASOUND IMAGE UPLOAD — audit log chuyên biệt
    // ──────────────────────────────────────────────

    /**
     * Ghi audit log khi upload ảnh siêu âm THÀNH CÔNG.
     * <p>
     * Thông tin được ghi:
     * <ul>
     *   <li>Người thực hiện: tự động từ session</li>
     *   <li>Hành động: UPLOAD_ULTRASOUND_IMAGE</li>
     *   <li>Bảng: ultrasound_images</li>
     *   <li>Kết quả: SUCCESS</li>
     *   <li>new_value: JSON chứa patient_id, appointment_id, test_order_id,
     *       image_count, danh sách tên file</li>
     * </ul>
     *
     * @param request       HttpServletRequest (để lấy user + IP)
     * @param patientId     ID bệnh nhân
     * @param patientName   tên bệnh nhân
     * @param appointmentId ID lịch hẹn
     * @param testOrderId   ID test_order
     * @param imageCount    số lượng ảnh được upload
     * @param filenames     danh sách tên file gốc, phân cách bởi dấu phẩy
     */
    public static void logUltrasoundUpload(jakarta.servlet.http.HttpServletRequest request,
                                           int patientId, String patientName,
                                           int appointmentId, int testOrderId,
                                           int imageCount, String filenames) {
        Integer userId = null;
        String ip = getClientIp(request);
        String userAgent = request != null ? request.getHeader("User-Agent") : null;

        try {
            Object userObj = request.getSession(false) != null
                    ? request.getSession(false).getAttribute("user") : null;
            if (userObj instanceof User) {
                userId = ((User) userObj).getId();
            }
        } catch (Exception e) {
            // Session không hợp lệ → userId giữ null
        }

        // Tạo action mô tả bằng tiếng Việt
        String action = "Tải lên " + imageCount + " ảnh siêu âm cho bệnh nhân "
                      + patientName + " (ID: " + patientId + ")"
                      + ", lịch hẹn #" + appointmentId
                      + ", test_order #" + testOrderId;

        // Tạo new_value JSON chứa thông tin chi tiết
        String newValue = buildUltrasoundUploadJson(patientId, patientName,
                appointmentId, testOrderId, imageCount, filenames,
                "SUCCESS", null, userAgent);

        insert(userId, action, "ultrasound_images", null, newValue, ip);
    }

    /**
     * Ghi audit log khi upload ảnh siêu âm THẤT BẠI.
     * <p>
     * Ghi lại nguyên nhân thất bại để phục vụ kiểm tra và xử lý sau này.
     *
     * @param request       HttpServletRequest (để lấy user + IP)
     * @param patientId     ID bệnh nhân (có thể 0 nếu chưa xác định được)
     * @param patientName   tên bệnh nhân (có thể null)
     * @param appointmentId ID lịch hẹn (có thể 0)
     * @param testOrderId   ID test_order (có thể 0)
     * @param filenames     danh sách tên file gốc (có thể null)
     * @param errorReason   nguyên nhân thất bại (VD: "Định dạng file không hợp lệ: .exe")
     */
    public static void logUltrasoundUploadFailed(jakarta.servlet.http.HttpServletRequest request,
                                                  int patientId, String patientName,
                                                  int appointmentId, int testOrderId,
                                                  String filenames, String errorReason) {
        Integer userId = null;
        String ip = getClientIp(request);
        String userAgent = request != null ? request.getHeader("User-Agent") : null;

        try {
            Object userObj = request.getSession(false) != null
                    ? request.getSession(false).getAttribute("user") : null;
            if (userObj instanceof User) {
                userId = ((User) userObj).getId();
            }
        } catch (Exception e) {
            // Session không hợp lệ → userId giữ null
        }

        // Tạo action mô tả bằng tiếng Việt
        String action = "Tải lên ảnh siêu âm THẤT BẠI"
                      + (patientName != null ? " cho bệnh nhân " + patientName : "")
                      + (patientId > 0 ? " (ID: " + patientId + ")" : "")
                      + (appointmentId > 0 ? ", lịch hẹn #" + appointmentId : "")
                      + (testOrderId > 0 ? ", test_order #" + testOrderId : "");

        // Tạo new_value JSON chứa thông tin chi tiết + nguyên nhân lỗi
        String newValue = buildUltrasoundUploadJson(
                patientId, patientName, appointmentId, testOrderId,
                0, filenames, "FAILED", errorReason, userAgent);

        insert(userId, action, "ultrasound_images", null, newValue, ip);
    }

    /**
     * Xây dựng chuỗi JSON cho audit log ultrasound upload.
     * Định dạng có cấu trúc, dễ parse khi cần truy vết.
     */
    private static String buildUltrasoundUploadJson(int patientId, String patientName,
                                                     int appointmentId, int testOrderId,
                                                     int imageCount, String filenames,
                                                     String result, String errorReason,
                                                     String userAgent) {
        StringBuilder json = new StringBuilder("{");
        json.append("\"result\":\"").append(result).append("\"");
        if (patientId > 0) {
            json.append(",\"patient_id\":").append(patientId);
        }
        if (patientName != null && !patientName.isEmpty()) {
            json.append(",\"patient_name\":\"").append(escapeJson(patientName)).append("\"");
        }
        if (appointmentId > 0) {
            json.append(",\"appointment_id\":").append(appointmentId);
        }
        if (testOrderId > 0) {
            json.append(",\"test_order_id\":").append(testOrderId);
        }
        if (result.equals("SUCCESS")) {
            json.append(",\"image_count\":").append(imageCount);
        }
        if (filenames != null && !filenames.isEmpty()) {
            json.append(",\"filenames\":\"").append(escapeJson(filenames)).append("\"");
        }
        if (errorReason != null && !errorReason.isEmpty()) {
            json.append(",\"error_reason\":\"").append(escapeJson(errorReason)).append("\"");
        }
        if (userAgent != null && !userAgent.isEmpty()) {
            // Cắt ngắn User-Agent nếu quá dài (tránh JSON quá lớn)
            String ua = userAgent.length() > 300 ? userAgent.substring(0, 300) + "..." : userAgent;
            json.append(",\"user_agent\":\"").append(escapeJson(ua)).append("\"");
        }
        json.append("}");
        return json.toString();
    }

    /**
     * Escape ký tự đặc biệt trong chuỗi JSON.
     */
    private static String escapeJson(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
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
