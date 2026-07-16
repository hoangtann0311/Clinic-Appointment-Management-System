package com.clinic.filter;

import com.clinic.config.AuthorizationConfig;
import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Filter phân quyền (Authorization — lớp 2).
 * Chạy SAU AuthenticationFilter. TẤT CẢ role đều phải qua filter này.
 *
 * <h2>NGHIỆP VỤ (7 yêu cầu)</h2>
 * <ol>
 *   <li><b>Tất cả người dùng</b> (Admin, Manager, Doctor, Staff, Sonographer, Patient)
 *       đều phải đi qua AuthenticationFilter và AuthorizationFilter.</li>
 *   <li><b>Whitelist theo Role</b> — mỗi Role chỉ được truy cập các URL nằm trong
 *       Whitelist đã cấu hình ({@link AuthorizationConfig#URL_PERMISSIONS}).</li>
 *   <li><b>Default Deny</b> — mọi URL không nằm trong Whitelist sẽ mặc định bị từ chối.</li>
 *   <li><b>Active + Session</b> — chỉ cho phép truy cập khi tài khoản ở trạng thái
 *       Active và phiên đăng nhập còn hiệu lực.</li>
 *   <li><b>HTTP 403</b> — mọi yêu cầu bị từ chối trả về HTTP 403 Forbidden
 *       hoặc chuyển đến trang Access Denied.</li>
 *   <li><b>Audit Log đầy đủ</b> — tất cả các lần truy cập (thành công hoặc bị từ chối)
 *       vào các chức năng quan trọng đều được ghi vào Audit Log với thông tin:
 *       người dùng, vai trò, URL, hành động, thời gian, địa chỉ IP và kết quả xử lý.</li>
 *   <li><b>Đồng bộ Session</b> — khi vai trò hoặc quyền của người dùng thay đổi,
 *       hệ thống cập nhật lại Session hoặc yêu cầu đăng nhập lại.</li>
 * </ol>
 *
 * <h2>Kiến trúc</h2>
 * <pre>
 * Request → EncodingFilter → AuthenticationFilter → AuthorizationFilter → Controller
 *                                                         │
 *                                          ┌──────────────┼──────────────┐
 *                                          ▼              ▼              ▼
 *                                     Public Path    Role Zone      Permission
 *                                     → Pass         Check          Check
 *                                                    │              │
 *                                                    ▼              ▼
 *                                               Default Deny    Audit Log
 *                                               → 403           (success/denied)
 * </pre>
 *
 * @see AuthorizationConfig
 * @see AuthenticationFilter
 */
@WebFilter("/*")
public class AuthorizationFilter implements Filter {

    /**
     * Global permissions version — dùng để phát hiện thay đổi quyền.
     * Mỗi khi Admin cập nhật role permissions hoặc thay đổi role của user,
     * version này được tăng lên. Filter so sánh version trong session với
     * version toàn cục để biết khi nào cần reload permissions.
     */
    public static final AtomicLong GLOBAL_PERMISSIONS_VERSION = new AtomicLong(0);

    /**
     * Bump global version — gọi từ AdminRoleServlet hoặc AdminUserServlet
     * khi có thay đổi về phân quyền hoặc vai trò.
     */
    public static void bumpPermissionsVersion() {
        long newVersion = GLOBAL_PERMISSIONS_VERSION.incrementAndGet();
        System.out.println(">>> [AUTHZ] Global permissions version bumped → " + newVersion);
    }

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        // Lưu version vào ServletContext để các component khác có thể đọc
        ServletContext ctx = cfg.getServletContext();
        ctx.setAttribute(AuthorizationConfig.APP_PERMISSIONS_VERSION,
                         GLOBAL_PERMISSIONS_VERSION);
        System.out.println(">>> [AUTHZ-FILTER] Initialized — Default Deny, Whitelist, Session Sync.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpRes = (HttpServletResponse) res;
        String ctx = httpReq.getContextPath();
        String path = normalizePath(httpReq.getRequestURI().substring(ctx.length()));

        // ── YÊU CẦU 1 & 2: Public paths → pass (đã được AuthFilter xử lý trước) ──
        if (AuthorizationConfig.isPublicPath(path)) {
            chain.doFilter(req, res);
            return;
        }

        // ── Session check — nếu không có user thì pass (đã bị AuthFilter chặn) ──
        HttpSession session = httpReq.getSession(false);
        if (session == null || session.getAttribute(AuthorizationConfig.SESSION_USER) == null) {
            chain.doFilter(req, res);
            return;
        }

        User user = (User) session.getAttribute(AuthorizationConfig.SESSION_USER);
        int roleId = user.getRoleId();

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 4: Kiểm tra trạng thái Active
        // (AuthFilter cũng kiểm tra, nhưng AuthorizationFilter kiểm tra
        //  lại để đảm bảo an toàn — phòng thủ theo chiều sâu)
        // ═══════════════════════════════════════════════════════════
        if (user.getStatus() == null || !"Active".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            logAccess(httpReq, user, path, "TỪ CHỐI", "TÀI KHOẢN KHÔNG HOẠT ĐỘNG");
            httpRes.sendRedirect(ctx + "/login");
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 7: Đồng bộ Session — phát hiện thay đổi role/permission
        // ═══════════════════════════════════════════════════════════
        boolean needsSync = checkSessionSync(session, user);
        if (needsSync) {
            // Reload permissions từ database
            boolean syncOk = reloadUserPermissions(session, user);
            if (!syncOk) {
                // Role hoặc trạng thái đã thay đổi → yêu cầu đăng nhập lại
                session.invalidate();
                HttpSession newSession = httpReq.getSession(true);
                newSession.setAttribute(AuthorizationConfig.SESSION_ERROR_MESSAGE,
                    "Quyền truy cập của bạn đã được cập nhật. Vui lòng đăng nhập lại.");
                logAccess(httpReq, user, path, "TỪ CHỐI", "ĐỒNG BỘ PHIÊN THẤT BẠI");
                httpRes.sendRedirect(ctx + "/login");
                return;
            }
            // Cập nhật lại roleId từ session (có thể đã thay đổi)
            User refreshedUser = (User) session.getAttribute(AuthorizationConfig.SESSION_USER);
            if (refreshedUser != null) {
                roleId = refreshedUser.getRoleId();
            }
        }

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 2: ROLE ZONE CHECK
        // Mỗi role CHỈ được vào khu vực của mình
        // ═══════════════════════════════════════════════════════════
        if (!AuthorizationConfig.isInZone(roleId, path)) {
            logAccess(httpReq, user, path, "TỪ CHỐI", "NGOÀI KHU VỰC CHO PHÉP");
            send403(httpReq, httpRes, path,
                "Bạn không có quyền truy cập khu vực này.",
                "Role \"" + AuthorizationConfig.getRoleDisplayName(roleId)
                + "\" không được phép truy cập \"" + path + "\".");
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 2 & 3: WHITELIST + DEFAULT DENY
        // Kiểm tra URL có trong whitelist không
        // ═══════════════════════════════════════════════════════════
        String requiredPermission = AuthorizationConfig.findRequiredPermission(path);

        if (requiredPermission == null) {
            // Path KHÔNG có trong whitelist → DEFAULT DENY
            logAccess(httpReq, user, path, "TỪ CHỐI", "KHÔNG CÓ TRONG DANH SÁCH CHO PHÉP");
            send403(httpReq, httpRes, path,
                "Trang này không tồn tại hoặc không được phép truy cập.",
                "Đường dẫn \"" + path + "\" không có trong danh sách được phép.");
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 2: PERMISSION CHECK
        // Kiểm tra user có permission key tương ứng không
        // ═══════════════════════════════════════════════════════════
        @SuppressWarnings("unchecked")
        Set<String> userPermissions = (Set<String>) session.getAttribute(
            AuthorizationConfig.SESSION_PERMISSIONS);

        boolean hasPermission = (userPermissions != null && userPermissions.contains(requiredPermission));

        if (!hasPermission) {
            // Không có permission → TỪ CHỐI
            logAccess(httpReq, user, path, "TỪ CHỐI", "THIẾU QUYỀN:" + requiredPermission);
            send403(httpReq, httpRes, path,
                "Bạn không có quyền thực hiện thao tác này.",
                "Yêu cầu quyền: <code>" + requiredPermission + "</code>.");
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // YÊU CẦU 6: Audit Log — truy cập THÀNH CÔNG vào critical path
        // ═══════════════════════════════════════════════════════════
        if (AuthorizationConfig.isCriticalPath(path)) {
            logAccess(httpReq, user, path, "THÀNH CÔNG", null);
        }

        // ── PASS — user được phép truy cập ──
        chain.doFilter(req, res);
    }

    // ═══════════════════════════════════════════════════════════
    // YÊU CẦU 7: SESSION SYNC LOGIC
    // ═══════════════════════════════════════════════════════════

    /**
     * Kiểm tra xem session có cần đồng bộ lại không.
     * So sánh {@code permissionsLoadedVersion} trong session với
     * {@code GLOBAL_PERMISSIONS_VERSION} toàn cục.
     *
     * @return true nếu cần reload permissions từ database
     */
    private boolean checkSessionSync(HttpSession session, User user) {
        Long sessionVersion = (Long) session.getAttribute(
            AuthorizationConfig.SESSION_PERM_VERSION);
        long globalVersion = GLOBAL_PERMISSIONS_VERSION.get();

        // Lần đầu hoặc version session không khớp → cần sync
        if (sessionVersion == null || sessionVersion.longValue() < globalVersion) {
            System.out.println(">>> [AUTHZ] Session sync triggered for user "
                + user.getEmail() + " (session v" + sessionVersion
                + " < global v" + globalVersion + ")");
            return true;
        }
        return false;
    }

    /**
     * Reload permissions cho user từ database.
     * Đồng thời kiểm tra roleId và trạng thái của user có thay đổi không.
     *
     * @return true nếu sync thành công, false nếu user cần đăng nhập lại
     */
    private boolean reloadUserPermissions(HttpSession session, User user) {
        int userId = user.getId();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();

            // ── Query 1: Lấy role_id và status hiện tại của user ──
            String userSql = "SELECT role_id, status FROM users WHERE id = ? AND is_deleted = 0";
            ps = conn.prepareStatement(userSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                // User không còn tồn tại hoặc đã bị xóa
                System.err.println(">>> [AUTHZ] User #" + userId + " not found during sync");
                return false;
            }

            int dbRoleId = rs.getInt("role_id");
            String dbStatus = rs.getString("status");

            // ── Kiểm tra trạng thái ──
            if (dbStatus == null || !"Active".equalsIgnoreCase(dbStatus)) {
                System.err.println(">>> [AUTHZ] User #" + userId
                    + " status changed to " + dbStatus + " — force re-login");
                return false;
            }

            // ── Kiểm tra role có thay đổi không ──
            if (dbRoleId != user.getRoleId()) {
                System.out.println(">>> [AUTHZ] User #" + userId
                    + " role changed: " + user.getRoleId() + " → " + dbRoleId
                    + " — updating session");
                user.setRoleId(dbRoleId);
                user.setStatus(dbStatus);
                session.setAttribute(AuthorizationConfig.SESSION_USER, user);
                session.setAttribute(AuthorizationConfig.SESSION_ROLE_ID, dbRoleId);
            }

            // ── Cleanup ResultSet/Statement trước khi query tiếp ──
            if (rs != null) { rs.close(); rs = null; }
            if (ps != null) { ps.close(); ps = null; }

            // ── Query 2: Lấy lại danh sách permission keys ──
            String permSql = "SELECT p.permission_key FROM permissions p "
                           + "JOIN role_permissions rp ON p.id = rp.permission_id "
                           + "JOIN users u ON u.role_id = rp.role_id "
                           + "WHERE u.id = ?";
            ps = conn.prepareStatement(permSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            Set<String> permissions = new HashSet<>();
            while (rs.next()) {
                permissions.add(rs.getString("permission_key"));
            }

            // ── Cập nhật session ──
            session.setAttribute(AuthorizationConfig.SESSION_PERMISSIONS, permissions);
            session.setAttribute(AuthorizationConfig.SESSION_PERM_VERSION,
                                 GLOBAL_PERMISSIONS_VERSION.get());

            System.out.println(">>> [AUTHZ] Session synced for user " + user.getEmail()
                + " — roleId=" + dbRoleId + ", permissions=" + permissions.size());

            return true;

        } catch (SQLException e) {
            System.err.println(">>> [AUTHZ] Failed to reload permissions for user #"
                + userId + ": " + e.getMessage());
            // Nếu DB lỗi, vẫn cho phép tiếp tục với session hiện tại
            // để tránh khóa tất cả người dùng khi DB gặp sự cố
            session.setAttribute(AuthorizationConfig.SESSION_PERM_VERSION,
                                 GLOBAL_PERMISSIONS_VERSION.get());
            return true;

        } finally {
            // Đóng resources
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { /* ignore */ }
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { /* ignore */ }
            }
            DatabaseConfig.closeConnection(conn);
        }
    }

    // ═══════════════════════════════════════════════════════════
    // PATH NORMALIZATION — loại bỏ session ID và path parameters
    // ═══════════════════════════════════════════════════════════

    /**
     * Chuẩn hóa path để loại bỏ các path parameters (như ;jsessionid=...)
     * mà Tomcat có thể chèn vào URL khi dùng URL rewriting.
     *
     * <p>Ví dụ: {@code /admin/dashboard;jsessionid=ABC123} → {@code /admin/dashboard}
     *
     * <p><b>Lưu ý:</b> {@link HttpServletRequest#getRequestURI()} KHÔNG bao gồm
     * query string, nhưng CÓ BAO GỒM path parameters (phần sau dấu {@code ;}).
     * Điều này khiến cho việc so khớp whitelist bị lỗi nếu không chuẩn hóa.
     *
     * @param rawPath path gốc từ getRequestURI() (đã bỏ context path)
     * @return path đã chuẩn hóa, không chứa path parameters
     */
    private String normalizePath(String rawPath) {
        if (rawPath == null || rawPath.isEmpty()) {
            return rawPath;
        }

        // Loại bỏ path parameters: mọi thứ từ dấu ';' đầu tiên trở đi
        // Ví dụ: /admin/dashboard;jsessionid=abc → /admin/dashboard
        int semicolonIdx = rawPath.indexOf(';');
        if (semicolonIdx >= 0) {
            String normalized = rawPath.substring(0, semicolonIdx);
            if (!normalized.equals(rawPath)) {
                System.out.println(">>> [AUTHZ] Path normalized: \""
                    + rawPath + "\" → \"" + normalized + "\"");
            }
            return normalized;
        }

        return rawPath;
    }

    // ═══════════════════════════════════════════════════════════
    // YÊU CẦU 5: HTTP 403 RESPONSE
    // ═══════════════════════════════════════════════════════════

    /**
     * Trả về HTTP 403 Forbidden và forward đến trang lỗi.
     */
    private void send403(HttpServletRequest req, HttpServletResponse res,
                         String path, String title, String detail) throws IOException {
        res.setStatus(HttpServletResponse.SC_FORBIDDEN);
        req.setAttribute("errorTitle", title != null ? title : "Truy Cập Bị Từ Chối");
        req.setAttribute("errorDetail", detail != null ? detail
            : "Bạn không có quyền truy cập \"" + path + "\".");
        req.setAttribute("deniedPath", path);
        try {
            req.getRequestDispatcher("/views/errors/403.jsp").forward(req, res);
        } catch (ServletException e) {
            // Fallback nếu forward lỗi
            res.setContentType("text/plain; charset=UTF-8");
            res.getWriter().println("403 Forbidden — Access Denied");
            res.getWriter().println("Path: " + path);
            if (title != null) res.getWriter().println(title);
        }
    }

    // ═══════════════════════════════════════════════════════════
    // YÊU CẦU 6: AUDIT LOGGING
    // ═══════════════════════════════════════════════════════════

    /**
     * Ghi audit log cho truy cập (thành công hoặc bị từ chối).
     *
     * <p>Thông tin ghi log:
     * <ul>
     *   <li>Người dùng: email + userId</li>
     *   <li>Vai trò: roleId + roleName</li>
     *   <li>URL: path được yêu cầu</li>
     *   <li>Hành động: ACCESS_GRANTED hoặc ACCESS_DENIED</li>
     *   <li>Thời gian: tự động (GETDATE())</li>
     *   <li>Địa chỉ IP: trích xuất từ request</li>
     *   <li>Kết quả: SUCCESS hoặc DENIED + lý do</li>
     * </ul>
     *
     * @param request HttpServletRequest
     * @param user    user thực hiện request
     * @param path    đường dẫn được yêu cầu
     * @param result  "SUCCESS" hoặc "DENIED"
     * @param reason  lý do (nếu bị từ chối), null nếu thành công
     */
    private void logAccess(HttpServletRequest request, User user, String path,
                           String result, String reason) {
        try {
            // Action label ngắn gọn để phân loại
            String action = "TỪ CHỐI".equals(result)
                ? "TRUY CẬP BỊ TỪ CHỐI"
                : "TRUY CẬP THÀNH CÔNG";

            // Detail chứa thông tin đầy đủ: [KẾT QUẢ] user (role) → path | Lý do
            StringBuilder detail = new StringBuilder();
            detail.append("[").append(result).append("] ");
            detail.append(user.getEmail());
            detail.append(" (").append(AuthorizationConfig.getRoleDisplayName(user.getRoleId())).append(")");
            detail.append(" → ").append(path);
            if (reason != null && !reason.isEmpty()) {
                detail.append(" | Lý do: ").append(reason);
            }

            AuditUtil.log(request, action, "access_control", null, detail.toString());
        } catch (Exception e) {
            // Audit log failure không được làm hỏng request chính
            System.err.println("[AUTHZ-FILTER] Không thể ghi audit log: " + e.getMessage());
        }
    }

    @Override
    public void destroy() {
        System.out.println(">>> [AUTHZ-FILTER] Destroyed.");
    }
}
