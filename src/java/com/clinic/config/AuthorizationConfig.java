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
     * Export paths (/export/*) được phép cho Admin và Manager.
     */
    public static boolean isInZone(int roleId, String path) {
        // Shared paths: export endpoints cho Admin & Manager
        if (path.startsWith("/export/") && (roleId == ROLE_ADMIN || roleId == ROLE_MANAGER)) {
            return true;
        }

        String zone = ROLE_ZONES.get(roleId);
        if (zone == null) return false;

        // Patient: cho phép /home và /patient/*
        if (roleId == ROLE_PATIENT) {
            return path.equals("/home") || path.startsWith("/patient/");
        }

        // Các role khác: phải bắt đầu bằng zone prefix
        return path.startsWith(zone);
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
        Map.entry("/admin/settings",     "system.manage_settings"),
        Map.entry("/admin/settings/",    "system.manage_settings"),
        Map.entry("/admin/services",     "service.view"),
        Map.entry("/admin/services/",    "service.view"),
        Map.entry("/admin/medicines",    "medicine.view"),
        Map.entry("/admin/medicines/",   "medicine.view"),
        Map.entry("/admin/pricing",      "service.view"),
        Map.entry("/admin/pricing/",     "service.view"),

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
        Map.entry("/manager/statistics",    "service.view"),
        Map.entry("/manager/statistics/",   "service.view"),

        // ──────────── EXPORT (/export/*) ────────────
        Map.entry("/export/reports",    "report.view"),

        // ──────────── DOCTOR ZONE (/doctor/*) ────────────
        Map.entry("/doctor/dashboard",         "report.view_dashboard"),
        Map.entry("/doctor/medical-records",   "medical_record.edit"),
        Map.entry("/doctor/medical-records/",  "medical_record.edit"),
        Map.entry("/doctor/prescriptions",     "prescription.view"),
        Map.entry("/doctor/prescriptions/",    "prescription.view"),

        // ──────────── STAFF ZONE (/staff/*) ────────────
        Map.entry("/staff/dashboard",      "report.view_dashboard"),
        Map.entry("/staff/appointments",   "appointment.view"),
        Map.entry("/staff/appointments/",  "appointment.view"),
        Map.entry("/staff/payments",       "payment.view"),
        Map.entry("/staff/payments/",      "payment.view"),

        // ──────────── SONOGRAPHER ZONE (/sonographer/*) ────────────
        Map.entry("/sonographer/dashboard", "ultrasound.view"),
        Map.entry("/sonographer/upload",    "ultrasound.upload"),
        Map.entry("/sonographer/upload/",   "ultrasound.upload"),

        // ──────────── PATIENT ZONE (/home, /patient/*) ────────────
        Map.entry("/home",                   "report.view_dashboard"),
        Map.entry("/patient/appointments",   "appointment.view"),
        Map.entry("/patient/appointments/",  "appointment.view")
    );

    // ═══════════════════════════════════════════════════════════
    // PUBLIC PATHS — không cần xác thực hay phân quyền
    // ═══════════════════════════════════════════════════════════
    public static final Set<String> PUBLIC_PATHS = Set.of(
        "/login", "/admin/login", "/register", "/verify-email",
        "/forgot-password", "/reset-password", "/change-password",
        "/google-login", "/google-login-server", "/logout"
    );

    public static final Set<String> PUBLIC_PREFIXES = Set.of(
        "/assets/", "/views/auth/", "/views/common/", "/views/errors/"
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
        "/admin/users", "/admin/roles", "/admin/settings",
        "/admin/audit-logs", "/export/reports",
        "/manager/statistics"
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
            case ROLE_ADMIN       -> "Admin";
            case ROLE_DOCTOR      -> "Doctor";
            case ROLE_MANAGER     -> "Manager";
            case ROLE_STAFF       -> "Staff";
            case ROLE_PATIENT     -> "Patient";
            case ROLE_SONOGRAPHER -> "Sonographer";
            default               -> "Unknown (#" + roleId + ")";
        };
    }
}
