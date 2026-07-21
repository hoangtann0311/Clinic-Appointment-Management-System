package com.clinic.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

/**
 * Filter that sets UTF-8 encoding for all requests and responses.
 * Only sets text/html Content-Type for non-static resources
 * to avoid overriding MIME types of CSS, JS, images, fonts, etc.
 */
@WebFilter("/*")
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

        // Only set Content-Type for HTML requests — skip static resources (CSS, JS, images...)
        if (request instanceof HttpServletRequest) {
            HttpServletRequest req = (HttpServletRequest) request;
            String path = normalizePath(req.getRequestURI());
            if (!isStaticResource(path)) {
                response.setContentType("text/html; charset=UTF-8");
            }
        }

        chain.doFilter(request, response);
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
