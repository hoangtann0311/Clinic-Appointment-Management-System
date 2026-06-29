package com.clinic.filter;

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
 * Filter kiểm tra xác thực và phân quyền.
 * - Chặn truy cập các trang được bảo vệ nếu chưa đăng nhập.
 * - Kiểm tra role truy cập đúng khu vực (/admin/* yêu cầu role Admin).
 * - Kiểm tra quyền chi tiết (permission keys) cho non-admin roles.
 *
 * Mapping role → URL prefix:
 *   1 = Admin       → /admin/*
 *   2 = Doctor      → /doctor/*
 *   3 = Manager     → /manager/*
 *   4 = Staff       → /staff/*
 *   5 = Patient     → /home, /patient/*
 *   6 = Sonographer → /sonographer/*
 *
 * Permission check (lớp 2 — kiểm tra quyền chi tiết):
 *   Mỗi URL pattern yêu cầu một permission key tương ứng.
 *   Admin (roleId=1) bỏ qua kiểm tra này.
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    // Các public path không yêu cầu đăng nhập
    private static final Set<String> PUBLIC_PATHS = Set.of(
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

    // Các thư mục public (assets, views công khai)
    private static final Set<String> PUBLIC_PREFIXES = Set.of(
        "/assets/",
        "/views/auth/",
        "/views/common/",
        "/views/errors/"
    );

    // Mapping role → prefix được phép truy cập
    private static final Map<Integer, String> ROLE_PREFIXES = Map.of(
        1, "/admin",
        2, "/doctor",
        3, "/manager",
        4, "/staff",
        5, "/patient",
        6, "/sonographer"
    );

    // Mapping URL pattern → permission key (lớp 2 — kiểm tra quyền chi tiết)
    // Chỉ áp dụng cho non-admin roles. Admin (roleId=1) bỏ qua.
    private static final Map<String, String> PERMISSION_REQUIRED = Map.ofEntries(
        // Quản lý người dùng
        Map.entry("/admin/users/", "user.view"),
        Map.entry("/admin/users", "user.view"),
        // Vai trò & phân quyền
        Map.entry("/admin/roles/", "system.manage_roles"),
        Map.entry("/admin/roles", "system.manage_roles"),
        // Lịch sử hoạt động
        Map.entry("/admin/audit-logs/", "system.view_audit_logs"),
        Map.entry("/admin/audit-logs", "system.view_audit_logs"),
        // Cài đặt hệ thống
        Map.entry("/admin/settings/", "system.manage_settings"),
        Map.entry("/admin/settings", "system.manage_settings"),
        // Quản lý dịch vụ
        Map.entry("/admin/services/", "service.view"),
        Map.entry("/admin/services", "service.view"),
        // Quản lý thuốc
        Map.entry("/admin/medicines/", "medicine.view"),
        Map.entry("/admin/medicines", "medicine.view"),
        // Quản lý nhân sự
        Map.entry("/admin/staff/", "user.view"),
        Map.entry("/admin/staff", "user.view"),
        // Quản lý biểu giá (dịch vụ + thuốc)
        Map.entry("/admin/pricing/", "service.view"),
        Map.entry("/admin/pricing", "service.view"),
        // Bác sĩ (dự phòng cho các module tương lai)
        Map.entry("/doctor/medical-records/", "medical_record.view"),
        Map.entry("/doctor/prescriptions/", "prescription.view"),
        // Nhân viên
        Map.entry("/staff/appointments/", "appointment.view"),
        Map.entry("/staff/payments/", "payment.view"),
        // Dashboard (tất cả role đều có quyền xem nếu có report.view_dashboard)
        Map.entry("/admin/dashboard", "report.view_dashboard"),
        Map.entry("/doctor/dashboard", "report.view_dashboard"),
        Map.entry("/manager/dashboard", "report.view_dashboard"),
        Map.entry("/staff/dashboard", "report.view_dashboard"),
        Map.entry("/sonographer/dashboard", "report.view_dashboard"),
        // Manager — quản lý biểu giá, dịch vụ, thuốc
        Map.entry("/manager/pricing/", "service.view"),
        Map.entry("/manager/pricing", "service.view"),
        Map.entry("/manager/services/", "service.view"),
        Map.entry("/manager/services", "service.view"),
        Map.entry("/manager/medicines/", "medicine.view"),
        Map.entry("/manager/medicines", "medicine.view"),
        // Manager — duyệt lịch trực & quản lý khung giờ khám
        Map.entry("/manager/schedules/", "schedule.view"),
        Map.entry("/manager/schedules", "schedule.view"),
        Map.entry("/manager/time-slots/", "schedule.view"),
        Map.entry("/manager/time-slots", "schedule.view"),
        // Manager — thống kê dịch vụ
        Map.entry("/manager/statistics/", "service.view"),
        Map.entry("/manager/statistics", "service.view")
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println(">>> AuthenticationFilter initialized.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // Cho phép truy cập các tài nguyên public
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Kiểm tra đã đăng nhập chưa
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // Chưa đăng nhập: lưu URL đích để redirect sau khi login
            httpRequest.getSession(true).setAttribute("redirectAfterLogin", path);
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }

        // Đã đăng nhập: kiểm tra phân quyền
        User user = (User) session.getAttribute("user");
        int roleId = user.getRoleId();

        // Admin (roleId=1) được truy cập tất cả
        if (roleId == 1) {
            chain.doFilter(request, response);
            return;
        }

        // Kiểm tra role có quyền truy cập path này không
        String allowedPrefix = ROLE_PREFIXES.get(roleId);
        if (allowedPrefix != null && path.startsWith(allowedPrefix)) {
            chain.doFilter(request, response);
            return;
        }

        // Path /home dành cho Patient (roleId=5)
        if (roleId == 5 && (path.equals("/home") || path.startsWith("/patient/"))) {
            chain.doFilter(request, response);
            return;
        }

        // ── Lớp 2: Kiểm tra quyền chi tiết (permission keys) ──
        // Lấy permission keys từ session (đã nạp khi login)
        Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
        if (userPermissions != null && !userPermissions.isEmpty()) {
            // Kiểm tra path có yêu cầu permission cụ thể không
            String requiredPermission = getRequiredPermission(path);
            if (requiredPermission != null) {
                if (userPermissions.contains(requiredPermission)) {
                    chain.doFilter(request, response);
                    return;
                }
                // Không có quyền: trả về 403
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                request.setAttribute("errorTitle", "Không Có Quyền Truy Cập");
                request.setAttribute("errorDetail",
                        "Bạn không có quyền \"" + requiredPermission + "\" cần thiết để truy cập trang này. "
                        + "Vui lòng liên hệ quản trị viên.");
                request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
                return;
            }
            // Path không yêu cầu permission cụ thể → cho phép truy cập
            chain.doFilter(request, response);
            return;
        }

        // Không có quyền: trả về 403
        httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
        request.setAttribute("errorTitle", "Truy Cập Bị Từ Chối");
        request.setAttribute("errorDetail",
                "Bạn không có quyền truy cập vào trang này. "
                + "Vui lòng liên hệ quản trị viên nếu bạn cần quyền truy cập.");
        request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
    }

    /**
     * Kiểm tra path có phải là public (không yêu cầu đăng nhập).
     */
    private boolean isPublicPath(String path) {
        // Path chính xác (ví dụ: /login, /register)
        if (PUBLIC_PATHS.contains(path)) {
            return true;
        }
        // Root path
        if (path.equals("/") || path.isEmpty()) {
            return true;
        }
        // Path bắt đầu bằng prefix public
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        // Các file tĩnh
        if (path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".png") || path.endsWith(".jpg")
                || path.endsWith(".svg") || path.endsWith(".ico")
                || path.endsWith(".woff2") || path.endsWith(".woff")) {
            return true;
        }
        return false;
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

    @Override
    public void destroy() {
    }
}
