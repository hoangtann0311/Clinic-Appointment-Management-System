package com.clinic.filter;

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
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Filter bảo vệ CSRF (Cross-Site Request Forgery).
 *
 * <h2>Cơ chế</h2>
 * <ol>
 *   <li>GET request → tạo CSRF token nếu chưa có, lưu vào session</li>
 *   <li>POST/PUT/DELETE request → kiểm tra CSRF token từ form/header</li>
 *   <li>Token không khớp → HTTP 403 + audit log</li>
 * </ol>
 *
 * <p><b>Miễn trừ:</b> Public paths (login, register), static resources, AJAX
 * requests có header X-Requested-With: XMLHttpRequest (được bảo vệ bởi SOP).
 *
 * <p>Chạy SAU AuthenticationFilter, TRƯỚC AuthorizationFilter.
 */
@WebFilter("/*")
public class CsrfFilter implements Filter {

    public static final String CSRF_TOKEN_ATTR = "csrfToken";
    public static final String CSRF_PARAM_NAME = "_csrf";

    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        System.out.println(">>> [CSRF-FILTER] Initialized — CSRF protection active.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpRes = (HttpServletResponse) res;
        String ctx = httpReq.getContextPath();
        String path = normalizePath(httpReq.getRequestURI().substring(ctx.length()));
        String method = httpReq.getMethod().toUpperCase();

        // ── Miễn trừ public paths ──
        if (AuthorizationConfig.isPublicPath(path)) {
            chain.doFilter(req, res);
            return;
        }

        // ── Miễn trừ AJAX requests (được bảo vệ bởi Same-Origin Policy) ──
        if ("XMLHttpRequest".equals(httpReq.getHeader("X-Requested-With"))) {
            chain.doFilter(req, res);
            return;
        }

        // ── Tạo hoặc lấy CSRF token từ session ──
        HttpSession session = httpReq.getSession(false);
        if (session == null) {
            // Không có session → pass (đã bị AuthenticationFilter chặn)
            chain.doFilter(req, res);
            return;
        }

        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (sessionToken == null) {
            sessionToken = generateToken();
            session.setAttribute(CSRF_TOKEN_ATTR, sessionToken);
        }

        // ── Đối với state-changing methods, kiểm tra token ──
        if ("POST".equals(method) || "PUT".equals(method) || "DELETE".equals(method)
                || "PATCH".equals(method)) {

            String requestToken = httpReq.getParameter(CSRF_PARAM_NAME);
            if (requestToken == null) {
                requestToken = httpReq.getHeader("X-CSRF-TOKEN");
            }

            if (requestToken == null || !sessionToken.equals(requestToken)) {
                // CSRF attack detected!
                System.err.println("[CSRF-FILTER] CSRF token mismatch for " + path
                    + " — request denied.");

                // Ghi audit log
                try {
                    com.clinic.utils.AuditUtil.log(httpReq,
                        "[Bảo mật] Xác thực token CSRF thất bại: " + path,
                        "security", null, null);
                } catch (Exception e) { /* ignore */ }

                // Trả về 403
                httpRes.setStatus(HttpServletResponse.SC_FORBIDDEN);
                try {
                    httpReq.setAttribute("errorTitle", "Yêu Cầu Không Hợp Lệ");
                    httpReq.setAttribute("errorDetail",
                        "Phiên làm việc đã hết hạn hoặc yêu cầu không hợp lệ. "
                        + "Vui lòng thử lại từ trang trước.");
                    httpReq.getRequestDispatcher("/views/errors/403.jsp").forward(httpReq, httpRes);
                } catch (ServletException e) {
                    httpRes.setContentType("text/plain; charset=UTF-8");
                    httpRes.getWriter().println("403 Forbidden — CSRF Validation Failed");
                }
                return;
            }
        }

        // ── Pass ──
        chain.doFilter(req, res);
    }

    /**
     * Tạo CSRF token ngẫu nhiên 32 bytes, mã hóa Base64 URL-safe.
     */
    public static String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /**
     * Chuẩn hóa path để loại bỏ path parameters (như ;jsessionid=...)
     * mà Tomcat có thể chèn vào URL khi dùng URL rewriting.
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

    @Override
    public void destroy() {
        // No cleanup
    }
}
