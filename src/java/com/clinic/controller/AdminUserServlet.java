package com.clinic.controller;

import com.clinic.model.Role;
import com.clinic.model.User;
import com.clinic.service.RoleService;
import com.clinic.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

/**
 * Servlet quản lý người dùng cho Admin — module hợp nhất.
 *
 * Tích hợp toàn bộ tính năng:
 *   - Danh sách user (phân trang + tìm kiếm + lọc role/status)
 *   - Tab filter nhanh: Tất cả | Nhân sự | Bệnh nhân
 *   - Stat cards (Tổng, Doctor, Manager, Staff, Sonographer)
 *   - CRUD: Tạo / Sửa / Xoá mềm / Khôi phục
 *   - Khoá / Mở khoá tài khoản (toggle Active ↔ Locked)
 *   - Reset mật khẩu (admin side)
 *   - Audit log cho mọi thao tác
 *
 * GET  → hiển thị danh sách + stats
 * POST → xử lý thêm / sửa / xoá / khoá-mở / reset-password / restore
 */
@WebServlet(urlPatterns = {"/admin/users/", "/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    /** Fallback cứng — dùng khi DB chưa sẵn sàng. Đồng bộ với seed data roles. */
    private static final Map<Integer, String> FALLBACK_ROLE_MAP = new LinkedHashMap<>();
    static {
        FALLBACK_ROLE_MAP.put(1, "Quản Trị Viên");
        FALLBACK_ROLE_MAP.put(2, "Bác Sĩ");
        FALLBACK_ROLE_MAP.put(3, "Quản Lý");
        FALLBACK_ROLE_MAP.put(4, "Nhân Viên");
        FALLBACK_ROLE_MAP.put(5, "Bệnh Nhân");
        FALLBACK_ROLE_MAP.put(6, "KTV Siêu Âm");
    }

    /** Role ID của Admin và Patient — không tính vào nhân sự. */
    private static final int ADMIN_ROLE_ID   = 1;
    private static final int PATIENT_ROLE_ID = 5;

    // ── Instance state ──
    private UserService userService;
    private RoleService roleService;

    /** Role map nạp từ DB lúc init. Key = role_id (Integer), Value = role_name (String). */
    private Map<Integer, String> roleMap;
    /** Chỉ các role nhân sự (không phải Admin / Patient). */
    private Map<Integer, String> staffRoleMap;
    /** Set role ID cho filter nhanh "Nhân sự". */
    private Set<Integer> staffRoleIds;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
        roleService = new RoleService();
        refreshRoleMaps();
    }

    /**
     * Nạp danh sách vai trò từ database.
     * Nếu DB lỗi → fallback về danh sách cứng.
     */
    private void refreshRoleMaps() {
        roleMap = new LinkedHashMap<>();
        staffRoleMap = new LinkedHashMap<>();
        Set<Integer> staffIds = new LinkedHashSet<>();

        try {
            List<Role> roles = roleService.getAllRoles();
            if (roles != null && !roles.isEmpty()) {
                for (Role r : roles) {
                    roleMap.put(r.getId(), r.getRoleName());
                    // Tất cả role trừ Admin và Patient đều là nhân sự
                    if (r.getId() != ADMIN_ROLE_ID && r.getId() != PATIENT_ROLE_ID) {
                        staffRoleMap.put(r.getId(), r.getRoleName());
                        staffIds.add(r.getId());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[AdminUserServlet] Không thể nạp roles từ DB, dùng fallback: " + e.getMessage());
        }

        // Fallback nếu roleMap rỗng (DB lỗi hoặc chưa có dữ liệu)
        if (roleMap.isEmpty()) {
            roleMap.putAll(FALLBACK_ROLE_MAP);
            for (Map.Entry<Integer, String> e : FALLBACK_ROLE_MAP.entrySet()) {
                if (e.getKey() != ADMIN_ROLE_ID && e.getKey() != PATIENT_ROLE_ID) {
                    staffRoleMap.put(e.getKey(), e.getValue());
                    staffIds.add(e.getKey());
                }
            }
        }

        this.staffRoleIds = Collections.unmodifiableSet(staffIds);
        System.out.println("[AdminUserServlet] Đã nạp " + roleMap.size() + " roles ("
                + staffRoleIds.size() + " nhân sự).");
    }

    // ═══════════════════════════════════════════════════════════
    // GET — Hiển thị danh sách
    // ═══════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        // Backward-compat: redirect /admin/staff/ → /admin/users/?roleGroup=staff
        if (path.startsWith("/admin/staff")) {
            resp.sendRedirect(req.getContextPath() + "/admin/users/?roleGroup=staff");
            return;
        }

        // ── Đọc tham số ──
        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String roleGroup = req.getParameter("roleGroup");   // all | staff | patients
        Integer roleFilter = parseInteger(req.getParameter("role"));
        String statusFilter = req.getParameter("status");
        boolean includeDeleted = "true".equals(req.getParameter("includeDeleted"));

        // ── Xác định danh sách role_id để lọc trong DB ──
        // roleFilter (tham số select đơn) có độ ưu tiên cao nhất
        // Nếu không có roleFilter thì dùng roleGroup
        java.util.List<Integer> roleIds = null;
        if (roleFilter != null) {
            roleIds = java.util.Collections.singletonList(roleFilter);
        } else if ("staff".equals(roleGroup)) {
            roleIds = new ArrayList<>(staffRoleIds);
        } else if ("patients".equals(roleGroup)) {
            roleIds = java.util.Collections.singletonList(PATIENT_ROLE_ID);
        }
        // roleGroup=all hoặc không có → roleIds=null → lấy tất cả role

        // ── Lấy dữ liệu từ service (đã lọc role trong DB) ──
        List<User> users = userService.getUsers(page, PAGE_SIZE, search, roleIds, statusFilter, includeDeleted);

        // ── Stats: luôn đếm user CHƯA xoá, không phụ thuộc checkbox ──
        Map<Integer, Integer> statsByRole = computeRoleStats(search, statusFilter, false);

        int countTotal   = statsByRole.values().stream().mapToInt(Integer::intValue).sum();
        int countDoctor  = statsByRole.getOrDefault(2, 0);
        int countManager = statsByRole.getOrDefault(3, 0);
        int countStaff   = statsByRole.getOrDefault(4, 0);
        int countSono    = statsByRole.getOrDefault(6, 0);
        int countPatient = statsByRole.getOrDefault(5, 0);
        int countAdmin   = statsByRole.getOrDefault(1, 0);

        // Tổng user hiển thị trong bảng hiện tại — query với roleIds đã xác định
        int totalForPaging = userService.getTotalUsers(search, roleIds, statusFilter, includeDeleted);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalForPaging / PAGE_SIZE));

        // ── Set attributes cho JSP ──
        req.setAttribute("users", users);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalUsers", totalForPaging);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("roleFilter", roleFilter);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("roleGroup", roleGroup);
        req.setAttribute("roleMap", roleMap);
        req.setAttribute("staffRoleMap", staffRoleMap);
        req.setAttribute("includeDeleted", includeDeleted);

        // Stats
        req.setAttribute("countTotal", countTotal);
        req.setAttribute("countDoctor", countDoctor);
        req.setAttribute("countManager", countManager);
        req.setAttribute("countStaffOnly", countStaff);      // "staffOnly" để tránh trùng với biến staffMembers
        req.setAttribute("countSono", countSono);
        req.setAttribute("countPatient", countPatient);
        req.setAttribute("countAdmin", countAdmin);

        // Message từ redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        // Forward tới JSP thống nhất
        req.getRequestDispatcher("/views/admin/users/index.jsp").forward(req, resp);
    }

    /**
     * Đếm số user theo từng role để hiển thị stat cards.
     * Gọi countAll cho từng role để có số liệu chính xác.
     */
    private Map<Integer, Integer> computeRoleStats(String search, String statusFilter, boolean includeDeleted) {
        Map<Integer, Integer> stats = new LinkedHashMap<>();
        // Lấy toàn bộ user rồi đếm theo role. Đơn giản và chính xác.
        try {
            // Lấy page 1 với pageSize lớn để có dữ liệu cho stats
            List<User> all = userService.getUsers(1, 9999, search, null, statusFilter, includeDeleted);
            for (User u : all) {
                int rid = u.getRoleId();
                stats.put(rid, stats.getOrDefault(rid, 0) + 1);
            }
        } catch (Exception e) {
            System.err.println("[AdminUserServlet] computeRoleStats ERROR: " + e.getMessage());
        }
        return stats;
    }

    // ═══════════════════════════════════════════════════════════
    // POST — Xử lý các action
    // ═══════════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Nếu request đến từ /admin/staff/ → redirect về users
        String path = req.getServletPath();
        if (path.startsWith("/admin/staff")) {
            resp.sendRedirect(req.getContextPath() + "/admin/users/?roleGroup=staff");
            return;
        }

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/users/";

        // Giữ lại query string của filter khi redirect
        String roleGroup = req.getParameter("roleGroup");
        String roleFilterParam = req.getParameter("role");
        String statusFilterParam = req.getParameter("status");
        String searchParam = req.getParameter("search");
        String pageParam = req.getParameter("page");
        String includeDeletedParam = req.getParameter("includeDeleted");

        // Build query string để giữ nguyên filter sau khi POST
        StringBuilder qs = new StringBuilder();
        if (roleGroup != null && !roleGroup.isEmpty()) qs.append("&roleGroup=").append(roleGroup);
        if (roleFilterParam != null && !roleFilterParam.isEmpty()) qs.append("&role=").append(roleFilterParam);
        if (statusFilterParam != null && !statusFilterParam.isEmpty()) qs.append("&status=").append(statusFilterParam);
        if (searchParam != null && !searchParam.isEmpty()) qs.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        if (pageParam != null && !pageParam.isEmpty()) qs.append("&page=").append(pageParam);
        if ("true".equals(includeDeletedParam)) qs.append("&includeDeleted=true");
        String querySuffix = qs.toString().isEmpty() ? "" : "&" + qs.toString().substring(1); // giữ leading & để nối sau ?success= / ?error=

        try {
            switch (action != null ? action : "") {

                // ── Tạo người dùng mới ──
                case "create": {
                    String fullName = req.getParameter("fullName");
                    String email = req.getParameter("email");
                    String password = req.getParameter("password");
                    String phone = req.getParameter("phone");
                    int roleId = parseInt(req.getParameter("roleId"), 5);
                    String status = req.getParameter("status");

                    Map<String, String> errors = new HashMap<>();
                    if (userService.createUser(fullName, email, password, phone, roleId, status, errors)) {
                        logAudit(req, "CREATE_USER", "Tạo người dùng: " + fullName + " (role=" + roleId + ")");
                        resp.sendRedirect(redirectUrl + "?success=created" + querySuffix);
                    } else {
                        req.setAttribute("formFullName", fullName);
                        req.setAttribute("formEmail", email);
                        req.setAttribute("formPhone", phone);
                        req.setAttribute("formRoleId", roleId);
                        req.setAttribute("formStatus", status);
                        req.setAttribute("errors", errors);
                        req.setAttribute("showAddModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                // ── Sửa người dùng (phân quyền + thông tin liên hệ) ──
                case "edit": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    int roleId = parseInt(req.getParameter("roleId"), 5);
                    String status = req.getParameter("status");
                    String email = req.getParameter("email");
                    String phone = req.getParameter("phone");

                    // Guard: admin không được tự đổi role của chính mình
                    User actor = (User) req.getSession().getAttribute("user");
                    if (actor != null && actor.getId() == userId) {
                        resp.sendRedirect(redirectUrl + "?error="
                            + java.net.URLEncoder.encode("Bạn không thể tự sửa quyền của chính mình.", "UTF-8")
                            + querySuffix);
                        return;
                    }

                    Map<String, String> errors = new HashMap<>();
                    if (userService.updateUserRoleAndStatus(userId, roleId, status, email, phone, errors)) {
                        User target = userService.getUserById(userId);
                        String targetName = target != null ? target.getFullName() : ("#" + userId);
                        logAudit(req, "EDIT_USER", "Sửa người dùng #" + userId + ": " + targetName
                                + " (role=" + roleId + ", status=" + status + ")");

                        // Nếu role bị thay đổi → bump global permissions version
                        // để AuthorizationFilter buộc user đó phải sync/re-login
                        if (target != null && target.getRoleId() != roleId) {
                            com.clinic.filter.AuthorizationFilter.bumpPermissionsVersion();
                        }
                        // Nếu status bị thay đổi → cũng bump để sync
                        if (target != null && !status.equals(target.getStatus())) {
                            com.clinic.filter.AuthorizationFilter.bumpPermissionsVersion();
                        }

                        resp.sendRedirect(redirectUrl + "?success=updated" + querySuffix);
                    } else {
                        // Load lại user info để hiển thị readonly fields khi validation fail
                        User target = userService.getUserById(userId);
                        req.setAttribute("editUserId", userId);
                        req.setAttribute("formEditFullName", target != null ? target.getFullName() : "");
                        req.setAttribute("formEditEmail", email != null ? email : (target != null ? target.getEmail() : ""));
                        req.setAttribute("formEditPhone", phone != null ? phone : (target != null ? target.getPhone() : ""));
                        req.setAttribute("formEditRoleId", roleId);
                        req.setAttribute("formEditStatus", status);
                        req.setAttribute("editErrors", errors);
                        req.setAttribute("showEditModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                // ── Xoá mềm (soft delete) ──
                case "delete": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    User target = userService.getUserById(userId);
                    String userName = target != null ? target.getFullName() : "Unknown";
                    if (userService.softDeleteUser(userId)) {
                        logAudit(req, "SOFT_DELETE_USER", "Xoá mềm người dùng #" + userId + ": " + userName);
                        resp.sendRedirect(redirectUrl + "?success=deleted" + querySuffix);
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Xoá+thất+bại" + querySuffix);
                    }
                    return;
                }

                // ── Khoá / Mở khoá (toggle status) ──
                case "toggleStatus": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    String newStatus = req.getParameter("newStatus");
                    User target = userService.getUserById(userId);
                    String actionLabel = "Locked".equals(newStatus) ? "Khoá" : "Mở khoá";
                    if (userService.updateStatus(userId, newStatus)) {
                        logAudit(req, "TOGGLE_STATUS", actionLabel + " người dùng #" + userId);
                        // Bump permissions version vì status thay đổi ảnh hưởng đến quyền truy cập
                        com.clinic.filter.AuthorizationFilter.bumpPermissionsVersion();
                        resp.sendRedirect(redirectUrl + "?success=updated" + querySuffix);
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Cập+nhật+trạng+thái+thất+bại" + querySuffix);
                    }
                    return;
                }

                // ── Reset mật khẩu (admin side) ──
                case "resetPassword": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    String newPassword = req.getParameter("newPassword");
                    String confirmPassword = req.getParameter("confirmPassword");

                    // ── Server-side validation ──
                    List<String> pwdErrors = new ArrayList<>();

                    // 1. Không được rỗng
                    if (newPassword == null || newPassword.trim().isEmpty()) {
                        pwdErrors.add("Vui lòng nhập mật khẩu mới.");
                    } else {
                        newPassword = newPassword.trim();

                        // 2. Độ dài tối thiểu
                        if (newPassword.length() < 6) {
                            pwdErrors.add("Mật khẩu phải có ít nhất 6 ký tự.");
                        }

                        // 3. Độ dài tối đa
                        if (newPassword.length() > 50) {
                            pwdErrors.add("Mật khẩu không được vượt quá 50 ký tự.");
                        }

                        // 4. Phải có ít nhất 1 chữ cái
                        if (!newPassword.matches(".*[a-zA-Z].*")) {
                            pwdErrors.add("Mật khẩu phải có ít nhất 1 chữ cái.");
                        }

                        // 5. Phải có ít nhất 1 chữ số
                        if (!newPassword.matches(".*[0-9].*")) {
                            pwdErrors.add("Mật khẩu phải có ít nhất 1 chữ số.");
                        }

                        // 6. Phải có ít nhất 1 ký tự đặc biệt
                        if (!newPassword.matches(".*[^a-zA-Z0-9].*")) {
                            pwdErrors.add("Mật khẩu phải có ít nhất 1 ký tự đặc biệt.");
                        }
                    }

                    // 4. Xác nhận mật khẩu
                    if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
                        pwdErrors.add("Vui lòng xác nhận mật khẩu mới.");
                    } else if (!confirmPassword.equals(newPassword)) {
                        pwdErrors.add("Mật khẩu xác nhận không khớp.");
                    }

                    // Nếu có lỗi → forward về JSP với modal mở
                    if (!pwdErrors.isEmpty()) {
                        User target = userService.getUserById(userId);
                        req.setAttribute("resetPwdUserId", userId);
                        req.setAttribute("resetPwdUserName", target != null ? target.getFullName() : "");
                        req.setAttribute("resetPwdErrors",
                                String.join(" ", pwdErrors));
                        req.setAttribute("showResetPwdModal", true);
                        doGet(req, resp);
                        return;
                    }

                    // Gọi service reset password
                    Map<String, String> errors = new HashMap<>();
                    if (userService.resetPassword(userId, newPassword, errors)) {
                        logAudit(req, "RESET_PASSWORD", "Reset mật khẩu cho user #" + userId);
                        resp.sendRedirect(redirectUrl + "?success=updated" + querySuffix);
                    } else {
                        User target = userService.getUserById(userId);
                        req.setAttribute("resetPwdUserId", userId);
                        req.setAttribute("resetPwdUserName", target != null ? target.getFullName() : "");
                        req.setAttribute("resetPwdErrors",
                                errors.getOrDefault("password", "Đặt lại mật khẩu thất bại."));
                        req.setAttribute("showResetPwdModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                // ── Khôi phục user đã xoá mềm ──
                case "restore": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    if (userService.updateStatus(userId, "Active")) {
                        boolean restored = restoreUser(userId);
                        if (restored) {
                            logAudit(req, "RESTORE_USER", "Khôi phục người dùng #" + userId);
                            resp.sendRedirect(redirectUrl + "?success=restored" + querySuffix);
                        } else {
                            resp.sendRedirect(redirectUrl + "?error=Khôi+phục+thất+bại" + querySuffix);
                        }
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Khôi+phục+thất+bại" + querySuffix);
                    }
                    return;
                }

                // ── Xoá vĩnh viễn (hard delete) ──
                case "hardDelete": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    User target = userService.getUserById(userId);
                    String userName = target != null ? target.getFullName() : ("#" + userId);
                    if (userService.deleteUser(userId)) {
                        logAudit(req, "HARD_DELETE_USER", "Xoá vĩnh viễn người dùng #" + userId + ": " + userName);
                        resp.sendRedirect(redirectUrl + "?success=hardDeleted" + querySuffix);
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Xoá+vĩnh+viễn+thất+bại" + querySuffix);
                    }
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl + (querySuffix.isEmpty() ? "" : "?" + querySuffix.substring(1)));
            }
        } catch (Exception e) {
            System.err.println("[AdminUserServlet] POST ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống" + querySuffix);
        }
    }

    /**
     * Khôi phục user đã bị soft delete.
     */
    private boolean restoreUser(int userId) {
        // Gọi soft delete với tham số restore = true
        // Hiện tại UserDAO chưa có method restore, ta dùng cách update trực tiếp
        // thông qua UserService. Tạm thời dùng approach: tạo method mới trong UserDAO
        // hoặc dùng update thông thường.
        //
        // Vì UserDAO.softDelete() set is_deleted=1, ta cần revert.
        // Cách đơn giản nhất: thêm method restore() vào UserDAO.
        // Ở đây ta dùng approach tạm: lấy user, nếu không tìm thấy (vì query lọc is_deleted=0)
        // thì ta không thể restore qua service hiện tại.
        //
        // Giải pháp: Thêm method trong UserDAO để restore.
        try {
            com.clinic.dao.UserDAO dao = new com.clinic.dao.UserDAO();
            return dao.restore(userId);
        } catch (Exception e) {
            System.err.println("[AdminUserServlet] restoreUser ERROR: " + e.getMessage());
            return false;
        }
    }

    // ═══════════════════════════════════════════════════════════
    // Audit Log
    // ═══════════════════════════════════════════════════════════
    private void logAudit(HttpServletRequest req, String action, String detail) {
        // Ghi audit log sử dụng AuditUtil tập trung
        com.clinic.utils.AuditUtil.log(req, detail, "users", null, null);
    }

    // ═══════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════
    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }

    private Integer parseInteger(String s) {
        if (s == null || s.isEmpty()) return null;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return null; }
    }
}
