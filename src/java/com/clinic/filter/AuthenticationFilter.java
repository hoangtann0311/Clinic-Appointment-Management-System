package com.clinic.filter;

import com.clinic.config.AuthorizationConfig;
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

/**
 * Filter xác thực (Authentication — lớp 1).
 *
 * <p><b>Business Rules:</b>
 * <ol>
 *   <li>Public paths → cho qua không cần login</li>
 *   <li>Chưa đăng nhập → redirect /login</li>
 *   <li>Đã đăng nhập nhưng tài khoản KHÔNG Active → redirect /login kèm thông báo</li>
 *   <li>Đã đăng nhập + Active → pass sang AuthorizationFilter</li>
 * </ol>
 *
 * <p>Filter này KHÔNG kiểm tra role hay permission — việc đó do AuthorizationFilter đảm nhiệm.
 *
 * @see AuthorizationFilter
 * @see AuthorizationConfig
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        System.out.println(">>> [AUTH-FILTER] Initialized — check login + Active status.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpRes = (HttpServletResponse) res;
        String ctx = httpReq.getContextPath();
        String path = normalizePath(httpReq.getRequestURI().substring(ctx.length()));

        // ── Rule 1: Public paths → pass ──
        // Sử dụng AuthorizationConfig để thống nhất định nghĩa public paths
        if (AuthorizationConfig.isPublicPath(path)) {
            chain.doFilter(req, res);
            return;
        }

        // ── Rule 2: Chưa đăng nhập → redirect /login ──
        HttpSession session = httpReq.getSession(false);
        if (session == null || session.getAttribute(AuthorizationConfig.SESSION_USER) == null) {
            httpReq.getSession(true).setAttribute(
                AuthorizationConfig.SESSION_REDIRECT_AFTER, path);
            httpRes.sendRedirect(ctx + "/login");
            return;
        }

        // ── Rule 3: Tài khoản không Active → đá ra ──
        User user = (User) session.getAttribute(AuthorizationConfig.SESSION_USER);
        if (user.getStatus() == null || !"Active".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            httpReq.getSession(true).setAttribute(
                AuthorizationConfig.SESSION_ERROR_MESSAGE,
                "Tài khoản của bạn đã bị khóa hoặc chưa được kích hoạt. "
                + "Vui lòng liên hệ quản trị viên.");
            httpRes.sendRedirect(ctx + "/login");
            return;
        }

        // ── Rule 4: OK → pass sang AuthorizationFilter ──
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }

    /**
     * Chuẩn hóa path để loại bỏ path parameters (như ;jsessionid=...)
     * mà Tomcat có thể chèn vào URL khi dùng URL rewriting.
     *
     * @param rawPath path gốc từ getRequestURI() (đã bỏ context path)
     * @return path đã chuẩn hóa, không chứa path parameters
     */
    private String normalizePath(String rawPath) {
        if (rawPath == null || rawPath.isEmpty()) {
            return rawPath;
        }
        int semicolonIdx = rawPath.indexOf(';');
        if (semicolonIdx >= 0) {
            return rawPath.substring(0, semicolonIdx);
        }
        return rawPath;
    }
}
