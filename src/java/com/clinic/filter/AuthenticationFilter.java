package com.clinic.filter;

import com.clinic.config.AppConfig;
import com.clinic.config.AuthorizationConfig;
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

/**
 * Filter kiểm tra xác thực.
 * - Chặn truy cập các trang được bảo vệ nếu chưa đăng nhập.
 * Phân vùng vai trò, whitelist và permission được xử lý duy nhất tại
 * AuthorizationFilter để không tồn tại hai ma trận quyền có thể lệch nhau.
 */
// @WebFilter("/*")
public class AuthenticationFilter implements Filter {

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
        String path = normalizePath(requestURI.substring(contextPath.length()));

        // Ảnh siêu âm là dữ liệu y tế nhạy cảm. Không bao giờ cho phép tải
        // trực tiếp từ thư mục tĩnh; phải đi qua endpoint ảnh y tế để kiểm
        // tra quyền theo bệnh nhân, bác sĩ chỉ định hoặc bác sĩ phụ trách.
        if (isProtectedMedicalUpload(path) || isProtectedAiOrderOutput(path)) {
            httpResponse.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

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

        // AuthorizationFilter (chạy ngay sau filter này) là nguồn sự thật duy nhất
        // cho zone, whitelist, trạng thái tài khoản và permission chi tiết.
        chain.doFilter(request, response);
    }

    /**
     * Kiểm tra path có phải là public (không yêu cầu đăng nhập).
     */
    private boolean isPublicPath(String path) {
        return AuthorizationConfig.isPublicPath(path) || AuthorizationConfig.isInternalPath(path);
    }

    private boolean isProtectedMedicalUpload(String path) {
        String uploadDir = AppConfig.getUploadDirectory().replace('\\', '/');
        while (uploadDir.startsWith("/")) {
            uploadDir = uploadDir.substring(1);
        }
        String prefix = "/" + uploadDir;
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }

    private String normalizePath(String rawPath) {
        if (rawPath == null || rawPath.isEmpty()) return rawPath;
        int semicolon = rawPath.indexOf(';');
        return semicolon >= 0 ? rawPath.substring(0, semicolon) : rawPath;
    }

    /** Mọi output AI và ảnh gốc legacy đều là dữ liệu lâm sàng, không phải static public. */
    private boolean isProtectedAiOrderOutput(String path) {
        return path.startsWith("/uploads/ai-results/") || path.startsWith("/uploads/original/");
    }

    @Override
    public void destroy() {
    }
}
