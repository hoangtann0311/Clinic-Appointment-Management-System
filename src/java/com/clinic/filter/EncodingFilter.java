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

import java.io.IOException;
import java.time.Instant;
import java.util.UUID;

/**
 * Filter that sets UTF-8 encoding for all requests and responses.
 * Only sets text/html Content-Type for non-static resources
 * to avoid overriding MIME types of CSS, JS, images, fonts, etc.
 */
// @WebFilter("/*")
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String requestId = UUID.randomUUID().toString();
        request.setAttribute("requestId", requestId);
        if (response instanceof HttpServletResponse) {
            ((HttpServletResponse) response).setHeader("X-Request-ID", requestId);
        }

        if (request instanceof HttpServletRequest) {
            HttpServletRequest req = (HttpServletRequest) request;
            String path = normalizePath(req.getRequestURI());
            if (!isStaticResource(path)) {
                response.setContentType("text/html; charset=UTF-8");
            } else {
                if (path.endsWith(".js")) {
                    response.setContentType("application/javascript; charset=UTF-8");
                } else if (path.endsWith(".css")) {
                    response.setContentType("text/css; charset=UTF-8");
                }
            }
        }

        try {
            chain.doFilter(request, response);
        } catch (IOException | ServletException | RuntimeException ex) {
            HttpServletRequest req = request instanceof HttpServletRequest
                    ? (HttpServletRequest) request : null;
            User user = null;
            if (req != null && req.getSession(false) != null
                    && req.getSession(false).getAttribute("user") instanceof User) {
                user = (User) req.getSession(false).getAttribute("user");
            }
            System.err.printf("[%s] requestId=%s route=%s userId=%s role=%s error=%s%n",
                    Instant.now(), requestId, req == null ? "unknown" : normalizePath(req.getRequestURI()),
                    user == null ? "anonymous" : user.getId(), user == null ? "anonymous" : user.getRoleId(),
                    ex.getClass().getSimpleName());
            throw ex;
        }
    }

    /**
     * Check if the path is a static resource (CSS, JS, fonts, images...).
     * These files need their own MIME types — do not set text/html on them.
     */
    private boolean isStaticResource(String path) {
        if (path == null) return false;
        String lower = path.toLowerCase();
        return lower.endsWith(".css") || lower.endsWith(".js")
            || lower.endsWith(".png") || lower.endsWith(".jpg")
            || lower.endsWith(".jpeg") || lower.endsWith(".gif")
            || lower.endsWith(".svg") || lower.endsWith(".ico")
            || lower.endsWith(".woff") || lower.endsWith(".woff2")
            || lower.endsWith(".ttf") || lower.endsWith(".eot")
            || lower.endsWith(".webp") || lower.endsWith(".map");
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }

    /**
     * Chuẩn hóa path để loại bỏ path parameters (như ;jsessionid=...).
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
