package com.clinic.config;

import java.util.Map;
import java.util.Set;

/**
 * Cấu hình tập trung cho AuthorizationFilter.
 *
 * <p><b>Nguyên tắc:</b>
 * <ol>
 *   <li><b>Default Deny</b> — mọi URL không có trong whitelist đều bị từ chối</li>
 *   <li><b>Role Zone</b> — mỗi role CHỈ được truy cập vào khu vực URL của mình</li>
 *   <li><b>Permission Check</b> — trong khu vực, mỗi URL cần permission key tương ứng</li>
 *   <li><b>Audit Log</b> — mọi truy cập (thành công / bị từ chối) đều được ghi log</li>
 * </ol>
 *
 * <p><b>Cách thêm URL mới:</b> Thêm entry vào {@link #URL_PERMISSIONS} với key là
 * URL pattern và value là permission key tương ứng.
 */
public final class AuthorizationConfig {

    public static final String AUTHENTICATED_ONLY = "__authenticated__";

    private AuthorizationConfig() {
        // Utility class — không khởi tạo
    }

    // ═══════════════════════════════════════════════════════════
    // ROLE CONSTANTS
    // ═══════════════════════════════════════════════════════════
    public static final int ROLE_ADMIN       = 1;
    public static final int ROLE_DOCTOR      = 2;
    public static final int ROLE_MANAGER     = 3;
    public static final int ROLE_STAFF       = 4;
    public static final int ROLE_PATIENT     = 5;
    public static final int ROLE_SONOGRAPHER = 6;

    // ═══════════════════════════════════════════════════════════
    // ROLE → ZONE MAPPING
    // Mỗi role CHỈ được truy cập vào khu vực URL của mình.
    // Admin (roleId=1) không thể vào /manager/* dù có đủ permission.
    // ═══════════════════════════════════════════════════════════
    public static final Map<Integer, String> ROLE_ZONES = Map.of(
        ROLE_ADMIN,       "/admin",
        ROLE_DOCTOR,      "/doctor",
        ROLE_MANAGER,     "/manager",
        ROLE_STAFF,       "/staff",
        ROLE_PATIENT,     "/patient",
        ROLE_SONOGRAPHER, "/sonographer"
    );

    /**
     * Kiểm tra path có thuộc zone của role không.
     * Patient đặc biệt: còn có /home.
     */
    public static boolean isInZone(int roleId, String path) {
        if ("/change-password".equals(path)) {
            return roleId >= ROLE_ADMIN && roleId <= ROLE_SONOGRAPHER;
        }

        if (roleId == ROLE_ADMIN) {
            return path.startsWith("/admin/") && !path.startsWith("/admin/reception");
        }

        // Tệp ảnh y tế được phục vụ qua endpoint dùng chung, nhưng vẫn phải
        // giới hạn đúng các vai trò có nghiệp vụ xem ảnh.
        if ("/medical/ultrasound-image".equals(path)) {
            return roleId == ROLE_DOCTOR || roleId == ROLE_PATIENT || roleId == ROLE_SONOGRAPHER;
        }
        if ("/medical/ai-image".equals(path)) {
            return roleId == ROLE_DOCTOR || roleId == ROLE_SONOGRAPHER || roleId == ROLE_PATIENT;
        }

        if (roleId == ROLE_STAFF && path.startsWith("/admin/reception")) {
            return true;
        }

        String zone = ROLE_ZONES.get(roleId);
        if (zone == null) {
            return false;
        }

        if (roleId == ROLE_PATIENT) {
            return path.equals("/home") || path.startsWith("/patient/");
        }

        return path.equals(zone) || path.startsWith(zone + "/");
    }

    // ═══════════════════════════════════════════════════════════
    // WHITELIST: URL pattern → required permission key
    // Chỉ những URL có trong map này mới được phép truy cập.
    // Mọi URL không có trong map → DEFAULT DENY → 403.
    // ═══════════════════════════════════════════════════════════
    public static final Map<String, String> URL_PERMISSIONS = Map.ofEntries(
        // ──────────── ADMIN ZONE (/admin/*) ────────────
        Map.entry("/admin/dashboard",    "report.view_dashboard"),
        Map.entry("/admin/users",        "user.view"),
        Map.entry("/admin/users/",       "user.view"),
        Map.entry("/admin/staff",        "user.view"),
        Map.entry("/admin/staff/",       "user.view"),
        Map.entry("/admin/roles",        "system.manage_roles"),
        Map.entry("/admin/roles/",       "system.manage_roles"),
        Map.entry("/admin/audit-logs",   "system.view_audit_logs"),
        Map.entry("/admin/audit-logs/",  "system.view_audit_logs"),
        Map.entry("/admin/services",     "service.view"),
        Map.entry("/admin/services/",    "service.view"),
        Map.entry("/admin/medicines",    "medicine.view"),
        Map.entry("/admin/medicines/",   "medicine.view"),
        Map.entry("/admin/pricing",      "service.view"),
        Map.entry("/admin/pricing/",     "service.view"),

        // Module quản lý nhân sự đã được hợp nhất vào /admin/users.
        // Hai URL cũ chỉ còn dùng để chuyển hướng tương thích ngược.

        // ──────────── MANAGER ZONE (/manager/*) ────────────
        Map.entry("/manager/dashboard",     "report.view_dashboard"),
        Map.entry("/manager/services",      "service.view"),
        Map.entry("/manager/services/",     "service.view"),
        Map.entry("/manager/medicines",     "medicine.view"),
        Map.entry("/manager/medicines/",    "medicine.view"),
        Map.entry("/manager/schedules",     "schedule.view"),
        Map.entry("/manager/schedules/",    "schedule.view"),
        Map.entry("/manager/time-slots",    "schedule.view"),
        Map.entry("/manager/time-slots/",   "schedule.view"),
        Map.entry("/manager/statistics",    "report.view_dashboard"),
        Map.entry("/manager/statistics/",   "report.view_dashboard"),
        Map.entry("/manager/pricing",       "service.view"),
        Map.entry("/manager/pricing/",      "service.view"),

        // ──────────── DOCTOR ZONE (/doctor/*) ────────────
        Map.entry("/doctor/dashboard",         "report.view_dashboard"),
        Map.entry("/doctor/appointments",      "appointment.view"),
        Map.entry("/doctor/appointments/",     "appointment.view"),
        Map.entry("/doctor/medical-records",   "medical_record.edit"),
        Map.entry("/doctor/medical-records/",  "medical_record.edit"),
        Map.entry("/doctor/prescriptions",     "prescription.view"),
        Map.entry("/doctor/prescriptions/",    "prescription.view"),
        Map.entry("/doctor/prescriptions-list", "prescription.view"),
        Map.entry("/doctor/prescriptions-list/","prescription.view"),
        Map.entry("/doctor/patients",           "appointment.view"),
        Map.entry("/doctor/patients/",          "appointment.view"),
        Map.entry("/doctor/profile",            "user.view"),
        Map.entry("/doctor/profile/",           "user.view"),
        Map.entry("/doctor/schedules",          "appointment.view"),
        Map.entry("/doctor/schedules/",         "appointment.view"),
        Map.entry("/doctor/patient-history",    "medical_record.view"),
        Map.entry("/doctor/pregnancy",          "medical_record.view"),
        Map.entry("/doctor/results",            "ultrasound.view"),
        Map.entry("/doctor/ultrasound-request/create", "medical_record.edit"),

        // ──────────── STAFF ZONE (/staff/*) ────────────
        Map.entry("/staff/dashboard",      "report.view_dashboard"),
        // STAFF dùng namespace legacy /admin/reception nhưng vẫn bị khóa
        // chặt trong zone Staff. Exact route được ưu tiên trước prefix.
        Map.entry("/admin/reception",                  "appointment.view"),
        Map.entry("/admin/reception/booking",          "appointment.create"),
        Map.entry("/admin/reception/checkin",          "appointment.edit"),
        Map.entry("/admin/reception/cancel",           "appointment.cancel"),
        Map.entry("/admin/reception/priority",         "appointment.edit"),
        Map.entry("/admin/reception/edit",             "appointment.edit"),
        Map.entry("/admin/reception/doctor-schedules", "appointment.view"),
        Map.entry("/admin/reception/slots",            "appointment.view"),
        Map.entry("/admin/reception/patient-lookup",   "user.view"),
        Map.entry("/admin/reception/payments",         "payment.view"),
        Map.entry("/admin/reception/payments/",        "payment.view"),

        // ──────────── SONOGRAPHER ZONE (/sonographer/*) ────────────
        Map.entry("/sonographer/dashboard", "ultrasound.view"),
        Map.entry("/sonographer/waiting-list", "ultrasound.view"),
        Map.entry("/sonographer/waiting-list/", "ultrasound.view"),
        Map.entry("/sonographer/detail", "ultrasound.view"),
        Map.entry("/sonographer/upload", "ultrasound.upload_image"),
        Map.entry("/sonographer/upload/", "ultrasound.upload_image"),
        Map.entry("/sonographer/analyze", "ultrasound.perform"),
        Map.entry("/sonographer/ai-model", "ultrasound.view"),

        // ──────────── PATIENT ZONE (/home, /patient/*) ────────────
        Map.entry("/home",                   "appointment.view"),
        Map.entry("/patient/appointments",   "appointment.view"),
        Map.entry("/patient/appointments/",  "appointment.view"),
        Map.entry("/patient/booking",        "appointment.create"),
        Map.entry("/patient/booking/",       "appointment.create"),
        Map.entry("/patient/booking/slots",  "appointment.create"),
        Map.entry("/patient/medical-records", "medical_record.view"),
        Map.entry("/patient/invoices",       "payment.view"),
        Map.entry("/patient/prescription-decision", "payment.view"),
        Map.entry("/patient/payment",        "payment.view"),
        Map.entry("/patient/profile",        "appointment.view"),
        Map.entry("/patient/review",         "appointment.view"),

        // ──────────── SHARED AUTHENTICATED ENDPOINTS ────────────
        Map.entry("/change-password",          AUTHENTICATED_ONLY),
        Map.entry("/medical/ultrasound-image", "ultrasound.view"),
        Map.entry("/medical/ai-image",         "ultrasound.view")
    );

    // ═══════════════════════════════════════════════════════════
    // PUBLIC PATHS — không cần xác thực hay phân quyền
    // ═══════════════════════════════════════════════════════════
    public static final Set<String> PUBLIC_PATHS = Set.of(
        "/login", "/register", "/verify-email",
        "/forgot-password", "/reset-password",
        "/google-login", "/google-login-server", "/logout"
    );

    public static final Set<String> PUBLIC_PREFIXES = Set.of(
        "/assets/", "/views/auth/", "/views/common/", "/views/errors/"
    );

    /** Endpoint chỉ dành cho giao tiếp nội bộ app-to-app, tự xác thực bằng token. */
    public static final Set<String> INTERNAL_PATHS = Set.of(
        "/mock-ai-engine"
    );

    // ═══════════════════════════════════════════════════════════
    // STATIC RESOURCE EXTENSIONS — không cần phân quyền
    // ═══════════════════════════════════════════════════════════
    public static final Set<String> STATIC_EXTENSIONS = Set.of(
        ".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".ico",
        ".woff", ".woff2", ".ttf", ".eot", ".webp", ".map"
    );

    // ═══════════════════════════════════════════════════════════
    // CRITICAL PATHS — các đường dẫn quan trọng cần audit log
    // ngay cả khi truy cập thành công (ngoài các đường dẫn thông
    // thường chỉ log khi bị từ chối)
    // ═══════════════════════════════════════════════════════════
    public static final Set<String> CRITICAL_PATH_PREFIXES = Set.of(
        "/admin/users", "/admin/roles",
        "/admin/audit-logs"
    );

    // ═══════════════════════════════════════════════════════════
    // SESSION ATTRIBUTE KEYS
    // ═══════════════════════════════════════════════════════════
    public static final String SESSION_USER             = "user";
    public static final String SESSION_ROLE_ID          = "roleId";
    public static final String SESSION_PERMISSIONS      = "userPermissions";
    public static final String SESSION_PERM_VERSION     = "permissionsLoadedVersion";
    public static final String SESSION_REDIRECT_AFTER   = "redirectAfterLogin";
    public static final String SESSION_ERROR_MESSAGE    = "errorMessage";

    // ═══════════════════════════════════════════════════════════
    // APPLICATION SCOPE KEYS
    // ═══════════════════════════════════════════════════════════
    public static final String APP_PERMISSIONS_VERSION = "globalPermissionsVersion";

    // ═══════════════════════════════════════════════════════════
    // HELPER METHODS
    // ═══════════════════════════════════════════════════════════

    /**
     * Kiểm tra path có phải là public (không cần auth) không.
     */
    public static boolean isPublicPath(String path) {
        if (path == null) return false;
        if (path.equals("/") || path.isEmpty()) return true;

        // Kiểm tra exact match
        if (PUBLIC_PATHS.contains(path)) return true;

        // Kiểm tra prefix match
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) return true;
        }

        // Kiểm tra static file extension
        String lower = path.toLowerCase();
        for (String ext : STATIC_EXTENSIONS) {
            if (lower.endsWith(ext)) return true;
        }

        return false;
    }

    public static boolean isInternalPath(String path) {
        return path != null && INTERNAL_PATHS.contains(path);
    }

    /**
     * Tìm permission key cần thiết cho một path.
     * Duyệt whitelist — nếu path khớp (exact hoặc prefix) thì trả về permission key.
     *
     * @param path đường dẫn cần kiểm tra (đã bỏ context path)
     * @return permission key nếu tìm thấy, null nếu path KHÔNG có trong whitelist
     */
    public static String findRequiredPermission(String path) {
        if (path == null) return null;

        // Ưu tiên exact match
        String exact = URL_PERMISSIONS.get(path);
        if (exact != null) return exact;

        // Thử prefix match (path bắt đầu bằng key + "/" hoặc key chính là prefix)
        for (Map.Entry<String, String> entry : URL_PERMISSIONS.entrySet()) {
            String key = entry.getKey();
            // Key đã kết thúc bằng "/" → path phải bắt đầu bằng key
            if (key.endsWith("/") && path.startsWith(key)) {
                return entry.getValue();
            }
            // Key không kết thúc bằng "/" → path phải bằng key hoặc bắt đầu bằng key + "/"
            if (!key.endsWith("/") && (path.equals(key) || path.startsWith(key + "/"))) {
                return entry.getValue();
            }
        }

        return null; // Không có trong whitelist → DEFAULT DENY
    }

    /**
     * Kiểm tra path có phải là critical path (cần audit log ngay cả khi thành công).
     */
    public static boolean isCriticalPath(String path) {
        if (path == null) return false;
        for (String prefix : CRITICAL_PATH_PREFIXES) {
            if (path.startsWith(prefix)) return true;
        }
        return false;
    }

    /**
     * Trả về tên hiển thị của role cho audit log.
     */
    public static String getRoleDisplayName(int roleId) {
        return switch (roleId) {
            case ROLE_ADMIN       -> "Quản trị viên";
            case ROLE_DOCTOR      -> "Bác sĩ";
            case ROLE_MANAGER     -> "Quản lý";
            case ROLE_STAFF       -> "Nhân viên";
            case ROLE_PATIENT     -> "Bệnh nhân";
            case ROLE_SONOGRAPHER -> "Bác sĩ siêu âm";
            default               -> "Không rõ (#" + roleId + ")";
        };
    }
}
