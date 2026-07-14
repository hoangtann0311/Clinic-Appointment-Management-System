package filter;

import com.clinic.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

/**
 * Filter kiểm tra phân quyền chi tiết (lớp 2 — Authorization).
 * Chạy SAU AuthenticationFilter để kiểm tra quyền cụ thể cho từng URL pattern.
 *
 * <p><b>Nguyên tắc WHITELIST:</b> Chỉ cho phép truy cập nếu path khớp với
 * PERMISSION_REQUIRED map và user có permission key tương ứng.
 * Admin (roleId=1) tự động có tất cả quyền.
 *
 * <p><b>Khác biệt với AuthenticationFilter:</b>
 * <ul>
 *   <li>AuthenticationFilter: kiểm tra login + role prefix (/admin/*, /manager/*, ...)</li>
 *   <li>AuthorizationFilter: kiểm tra permission key cụ thể cho từng URL</li>
 * </ul>
 *
 * <p><b>PERMISSION_REQUIRED map mở rộng:</b> Bao gồm tất cả URL cần bảo vệ
 * cho Admin, Manager, Doctor, Staff, Sonographer.
 */
@WebFilter("/*")
public class AuthorizationFilter implements Filter {

    /**
     * Mapping URL pattern → permission key.
     * Mỗi URL pattern yêu cầu một permission key cụ thể.
     * Admin (roleId=1) bỏ qua kiểm tra này.
     */
    private static final Map<String, String> PERMISSION_REQUIRED = Map.ofEntries(
        // ── Admin area ──
        Map.entry("/admin/dashboard", "report.view_dashboard"),
        Map.entry("/admin/users/", "user.view"),
        Map.entry("/admin/users", "user.view"),
        Map.entry("/admin/roles/", "system.manage_roles"),
        Map.entry("/admin/roles", "system.manage_roles"),
        Map.entry("/admin/audit-logs/", "system.view_audit_logs"),
        Map.entry("/admin/audit-logs", "system.view_audit_logs"),
        Map.entry("/admin/settings/", "system.manage_settings"),
        Map.entry("/admin/settings", "system.manage_settings"),
        Map.entry("/admin/services/", "service.view"),
        Map.entry("/admin/services", "service.view"),
        Map.entry("/admin/medicines/", "medicine.view"),
        Map.entry("/admin/medicines", "medicine.view"),
        Map.entry("/admin/pricing/", "service.view"),
        Map.entry("/admin/pricing", "service.view"),
        Map.entry("/admin/staff/", "user.view"),
        Map.entry("/admin/staff", "user.view"),
        Map.entry("/admin/reports/", "report.view"),
        Map.entry("/admin/reports", "report.view"),
        Map.entry("/admin/doctors/", "user.view"),
        Map.entry("/admin/doctors", "user.view"),

        // ── Manager area ──
        Map.entry("/manager/dashboard", "report.view_dashboard"),
        Map.entry("/manager/services/", "service.view"),
        Map.entry("/manager/services", "service.view"),
        Map.entry("/manager/medicines/", "medicine.view"),
        Map.entry("/manager/medicines", "medicine.view"),
        Map.entry("/manager/pricing/", "service.view"),
        Map.entry("/manager/pricing", "service.view"),
        Map.entry("/manager/schedules/", "schedule.view"),
        Map.entry("/manager/schedules", "schedule.view"),
        Map.entry("/manager/time-slots/", "schedule.view"),
        Map.entry("/manager/time-slots", "schedule.view"),
        Map.entry("/manager/statistics/", "service.view"),
        Map.entry("/manager/statistics", "service.view"),
        Map.entry("/manager/reports/", "report.view"),
        Map.entry("/manager/reports", "report.view"),

        // ── Doctor area ──
        Map.entry("/doctor/dashboard", "report.view_dashboard"),
        Map.entry("/doctor/medical-records/", "medical_record.edit"),
        Map.entry("/doctor/medical-records", "medical_record.edit"),
        Map.entry("/doctor/prescriptions/", "prescription.view"),

        // ── Staff area ──
        Map.entry("/staff/dashboard", "report.view_dashboard"),
        Map.entry("/staff/appointments/", "appointment.view"),
        Map.entry("/staff/appointments", "appointment.view"),
        Map.entry("/staff/payments/", "payment.view"),
        Map.entry("/staff/payments", "payment.view"),

        // ── Sonographer area ──
        Map.entry("/sonographer/dashboard", "ultrasound.view"),
        Map.entry("/sonographer/upload", "ultrasound.upload"),
        Map.entry("/sonographer/upload/", "ultrasound.upload"),

        // ── Patient / Home ──
        Map.entry("/home", "report.view_dashboard"),
        Map.entry("/patient/appointments/", "appointment.view"),
        Map.entry("/patient/appointments", "appointment.view")
    );

    /** Các path KHÔNG yêu cầu kiểm tra permission (public resources). */
    private static final Set<String> UNPROTECTED_PREFIXES = Set.of(
        "/assets/",
        "/views/auth/",
        "/views/common/",
        "/views/errors/",
        "/login",
        "/admin/login",
        "/register",
        "/verify-email",
        "/forgot-password",
        "/reset-password",
        "/change-password",
        "/google-login",
        "/google-login-server",
        "/logout"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println(">>> AuthorizationFilter initialized (permission-based whitelist).");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // ── Cho phép truy cập public resources không cần kiểm tra ──
        if (isUnprotected(path)) {
            chain.doFilter(request, response);
            return;
        }

        // ── Kiểm tra session ──
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // Chưa đăng nhập → AuthenticationFilter sẽ xử lý redirect
            chain.doFilter(request, response);
            return;
        }

        User user = (User) session.getAttribute("user");
        int roleId = user.getRoleId();

        // ── Admin (roleId=1) có toàn quyền ──
        if (roleId == 1) {
            chain.doFilter(request, response);
            return;
        }

        // ── Lấy permission keys từ session ──
        @SuppressWarnings("unchecked")
        Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");

        // ── Kiểm tra path có yêu cầu permission cụ thể không ──
        String requiredPermission = getRequiredPermission(path);

        if (requiredPermission == null) {
            // Path không có trong PERMISSION_REQUIRED map
            // WHITELIST approach: từ chối truy cập (an toàn hơn là cho phép mặc định)
            sendForbidden(httpRequest, httpResponse,
                    "Đường Dẫn Không Được Phép",
                    "Đường dẫn \"" + path + "\" không được định nghĩa trong danh sách "
                    + "phân quyền. Vui lòng liên hệ quản trị viên.");
            return;
        }

        // ── Kiểm tra user có permission key cần thiết không ──
        if (userPermissions != null && userPermissions.contains(requiredPermission)) {
            chain.doFilter(request, response);
            return;
        }

        // ── Không có quyền → 403 ──
        sendForbidden(httpRequest, httpResponse,
                "Không Có Quyền Truy Cập",
                "Bạn không có quyền \"" + requiredPermission + "\" cần thiết "
                + "để truy cập trang này. Vui lòng liên hệ quản trị viên.");
    }

    /**
     * Trả về permission key cần thiết cho một path.
     * Duyệt PERMISSION_REQUIRED map, tìm entry khớp với path.
     *
     * @param path đường dẫn request (đã bỏ context path)
     * @return permission key nếu tìm thấy, null nếu không yêu cầu quyền đặc biệt
     */
    private String getRequiredPermission(String path) {
        for (Map.Entry<String, String> entry : PERMISSION_REQUIRED.entrySet()) {
            if (path.equals(entry.getKey()) || path.startsWith(entry.getKey())) {
                return entry.getValue();
            }
        }
        return null;
    }

    /**
     * Kiểm tra path có phải là public (không yêu cầu kiểm tra permission).
     */
    private boolean isUnprotected(String path) {
        // Root path
        if (path.equals("/") || path.isEmpty()) {
            return true;
        }
        // Path chính xác
        for (String p : UNPROTECTED_PREFIXES) {
            if (path.equals(p)) {
                return true;
            }
        }
        // Path bắt đầu bằng prefix
        for (String prefix : UNPROTECTED_PREFIXES) {
            if (path.startsWith(prefix) && !prefix.equals("/login") && !prefix.equals("/admin/login")) {
                return true;
            }
        }
        // Các file tĩnh
        if (path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".png") || path.endsWith(".jpg")
                || path.endsWith(".svg") || path.endsWith(".ico")
                || path.endsWith(".woff2") || path.endsWith(".woff")
                || path.endsWith(".jsp")) {
            return true;
        }
        return false;
    }

    /**
     * Trả về HTTP 403 Forbidden với thông báo lỗi.
     */
    private void sendForbidden(HttpServletRequest request, HttpServletResponse response,
                               String title, String detail) throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        request.setAttribute("errorTitle", title);
        request.setAttribute("errorDetail", detail);
        request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
    }

    @Override
    public void destroy() {
    }
}
