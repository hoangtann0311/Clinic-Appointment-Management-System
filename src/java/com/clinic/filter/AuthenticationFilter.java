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
 *
 * Mapping role → URL prefix:
 *   1 = Admin       → /admin/*
 *   2 = Doctor      → /doctor/*
 *   3 = Manager     → /manager/*
 *   4 = Staff       → /staff/*
 *   5 = Patient     → /home, /patient/*
 *   6 = Sonographer → /sonographer/*
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

        // Cho phép Staff (roleId=4) truy cập phân hệ lễ tân nằm dưới /admin/reception
        if (roleId == 4 && (path.equals("/admin/reception") || path.startsWith("/admin/reception/"))) {
            chain.doFilter(request, response);
            return;
        }

        // Cho phép Sonographer (roleId=6) truy cập phân hệ siêu âm dưới /admin/sonographer
        if (roleId == 6 && (path.equals("/admin/sonographer") || path.startsWith("/admin/sonographer/"))) {
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

    @Override
    public void destroy() {
    }
}
