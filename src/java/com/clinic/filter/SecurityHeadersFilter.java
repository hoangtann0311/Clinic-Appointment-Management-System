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

import java.io.IOException;

/**
 * Filter thêm các Security Headers để bảo vệ ứng dụng web.
 *
 * <h2>Các header được thêm:</h2>
 * <ul>
 *   <li><b>X-Content-Type-Options: nosniff</b> — chống MIME type sniffing</li>
 *   <li><b>X-Frame-Options: DENY</b> — chống clickjacking</li>
 *   <li><b>X-XSS-Protection: 1; mode=block</b> — chống XSS reflected (legacy browsers)</li>
 *   <li><b>Referrer-Policy: strict-origin-when-cross-origin</b> — kiểm soát Referer header</li>
 *   <li><b>Permissions-Policy: camera=(), microphone=(), geolocation=()</b> — tắt API không cần</li>
 *   <li><b>Cache-Control: no-cache, no-store, must-revalidate</b> (cho trang cần bảo mật)</li>
 * </ul>
 *
 * <p>Chạy ĐẦU TIÊN trong filter chain để headers được set trước khi response được ghi.
 */
@WebFilter("/*")
public class SecurityHeadersFilter implements Filter {

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        System.out.println(">>> [SECURITY-HEADERS] Initialized — security headers active.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpRes = (HttpServletResponse) res;

        // ── Security headers cho TẤT CẢ responses ──
        httpRes.setHeader("X-Content-Type-Options", "nosniff");
        httpRes.setHeader("X-Frame-Options", "DENY");
        httpRes.setHeader("X-XSS-Protection", "1; mode=block");
        httpRes.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // Tắt các API trình duyệt không cần thiết
        httpRes.setHeader("Permissions-Policy",
            "camera=(), microphone=(), geolocation=(), interest-cohort=()");

        // ── Cache-Control cho các trang cần bảo mật ──
        String ctx = httpReq.getContextPath();
        String path = httpReq.getRequestURI().substring(ctx.length());
        if (!AuthorizationConfig.isPublicPath(path)
                && !path.startsWith("/assets/")) {
            httpRes.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
            httpRes.setHeader("Pragma", "no-cache");
            httpRes.setHeader("Expires", "0");
        }

        // ── Strict-Transport-Security (chỉ khi chạy HTTPS) ──
        // Bỏ comment dòng dưới khi deploy production với HTTPS
        // httpRes.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // No cleanup
    }
}
