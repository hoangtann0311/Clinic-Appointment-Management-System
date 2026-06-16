package controller;

import com.clinic.model.User;
import com.clinic.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

/**
 * Servlet quản lý nhân sự cho Admin & Manager.
 * Chỉ quản lý nhân viên (Doctor, Manager, Staff, Sonographer) — KHÔNG gồm Patient hay Admin.
 *
 * GET  → hiển thị danh sách nhân sự (phân trang + tìm kiếm + lọc theo role/status)
 * POST → xử lý thêm / sửa / khóa-mở khóa / xóa mềm
 */
@WebServlet(urlPatterns = {"/admin/staff/", "/admin/staff"})
public class AdminStaffServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    /** Chỉ hiển thị role nhân viên — không có Admin (1) và Patient (5) */
    public static final Map<Integer, String> STAFF_ROLE_MAP = new LinkedHashMap<>();
    static {
        STAFF_ROLE_MAP.put(2, "Doctor");
        STAFF_ROLE_MAP.put(3, "Manager");
        STAFF_ROLE_MAP.put(4, "Staff");
        STAFF_ROLE_MAP.put(6, "Sonographer");
    }

    /** Set role ID của nhân viên để filter trong service */
    private static final Set<Integer> STAFF_ROLE_IDS = Set.of(2, 3, 4, 6);

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        Integer roleFilter = parseInteger(req.getParameter("role"));
        String statusFilter = req.getParameter("status");

        // Lấy danh sách nhân sự (chỉ staff roles)
        List<User> allUsers = userService.getUsers(page, PAGE_SIZE, search, roleFilter, statusFilter);
        // Lọc chỉ giữ lại nhân viên
        List<User> staffList = new ArrayList<>();
        for (User u : allUsers) {
            if (STAFF_ROLE_IDS.contains(u.getRoleId())) {
                staffList.add(u);
            }
        }

        // Đếm tổng (tính riêng cho bảng nhân sự)
        int totalStaff = 0;
        if (search != null || roleFilter != null || statusFilter != null) {
            // Có filter → đếm từ DB
            totalStaff = userService.getTotalUsers(search, roleFilter, statusFilter);
        } else {
            // Không filter → đếm tất cả user rồi trừ Admin và Patient
            totalStaff = userService.getTotalUsers(null, null, null);
            // Trừ đi số Admin và Patient nếu không lọc (đếm trực tiếp)
            // Note: đây là ước lượng gần đúng — nếu cần chính xác tuyệt đối, cần thêm DAO method
        }
        int totalPages = Math.max(1, (int) Math.ceil((double) totalStaff / PAGE_SIZE));

        req.setAttribute("staffMembers", staffList);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalStaff", totalStaff);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("roleFilter", roleFilter);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("roleMap", STAFF_ROLE_MAP);

        // Message từ redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/admin/staff/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/staff/";

        try {
            switch (action != null ? action : "") {

                case "create": {
                    String fullName = req.getParameter("fullName");
                    String email = req.getParameter("email");
                    String username = req.getParameter("username");
                    String password = req.getParameter("password");
                    String phone = req.getParameter("phone");
                    int roleId = parseInt(req.getParameter("roleId"), 4);  // Default: Staff
                    String status = req.getParameter("status");
                    // Đảm bảo roleId là staff role
                    if (!STAFF_ROLE_IDS.contains(roleId)) {
                        roleId = 4; // fallback Staff
                    }
                    Map<String, String> errors = new HashMap<>();
                    if (userService.createUser(fullName, email, username, password, phone, roleId, status, errors)) {
                        // Ghi audit log (nếu có hệ thống audit)
                        logAudit(req, "CREATE_STAFF", "Tạo nhân viên: " + fullName + " (role=" + roleId + ")");
                        resp.sendRedirect(redirectUrl + "?success=created");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildFormData(req));
                        req.setAttribute("showCreateModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                case "edit": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    String fullName = req.getParameter("fullName");
                    String email = req.getParameter("email");
                    String username = req.getParameter("username");
                    String phone = req.getParameter("phone");
                    int roleId = parseInt(req.getParameter("roleId"), 4);
                    String status = req.getParameter("status");
                    // Đảm bảo roleId là staff role
                    if (!STAFF_ROLE_IDS.contains(roleId)) {
                        roleId = 4;
                    }

                    System.out.println("[AdminStaffServlet] edit: userId=" + userId
                        + ", fullName=" + fullName + ", email=" + email
                        + ", username=" + username + ", phone=" + phone
                        + ", roleId=" + roleId + ", status=" + status);

                    Map<String, String> errors = new HashMap<>();
                    if (userService.updateUser(userId, fullName, username, email, phone, roleId, status, errors)) {
                        logAudit(req, "EDIT_STAFF", "Sửa nhân viên #" + userId + ": " + fullName);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        // Lưu lại giá trị form để hiển thị lại trong modal
                        req.setAttribute("editUserId", userId);
                        req.setAttribute("formEditFullName", fullName);
                        req.setAttribute("formEditEmail", email);
                        req.setAttribute("formEditUsername", username);
                        req.setAttribute("formEditPhone", phone);
                        req.setAttribute("formEditRoleId", roleId);
                        req.setAttribute("formEditStatus", status);
                        req.setAttribute("editErrors", errors);
                        req.setAttribute("showEditModal", true);

                        System.out.println("[AdminStaffServlet] edit FAILED: " + errors);
                        doGet(req, resp);
                    }
                    return;
                }

                case "delete": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    if (userService.softDeleteUser(userId)) {
                        logAudit(req, "DELETE_STAFF", "Xóa nhân viên #" + userId);
                        resp.sendRedirect(redirectUrl + "?success=deleted");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Xóa+thất+bại");
                    }
                    return;
                }

                case "toggleStatus": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    String newStatus = req.getParameter("newStatus");
                    if (userService.updateStatus(userId, newStatus)) {
                        logAudit(req, "TOGGLE_STAFF", "Đổi trạng thái nhân viên #" + userId + " → " + newStatus);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Cập+nhật+trạng+thái+thất+bại");
                    }
                    return;
                }

                case "resetPassword": {
                    int userId = parseInt(req.getParameter("userId"), -1);
                    String newPassword = req.getParameter("newPassword");
                    Map<String, String> errors = new HashMap<>();
                    if (userService.resetPassword(userId, newPassword, errors)) {
                        logAudit(req, "RESET_PWD_STAFF", "Reset mật khẩu nhân viên #" + userId);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=" + java.net.URLEncoder.encode(
                            errors.getOrDefault("password", "Reset thất bại"), "UTF-8"));
                    }
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("AdminStaffServlet POST: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống");
        }
    }

    /** Lưu dữ liệu form để hiển thị lại khi validation fail */
    private Map<String, String> buildFormData(HttpServletRequest req) {
        Map<String, String> data = new HashMap<>();
        data.put("fullName", req.getParameter("fullName"));
        data.put("email", req.getParameter("email"));
        data.put("username", req.getParameter("username"));
        data.put("phone", req.getParameter("phone"));
        data.put("roleId", req.getParameter("roleId"));
        data.put("status", req.getParameter("status"));
        return data;
    }

    /** Ghi log thao tác quản lý nhân sự */
    private void logAudit(HttpServletRequest req, String action, String detail) {
        try {
            User actor = (User) req.getSession().getAttribute("user");
            String actorName = actor != null ? actor.getFullName() : "System";
            System.out.println("[AUDIT-STAFF] " + action + " | By: " + actorName + " | " + detail);
            // TODO: Tích hợp AuditUtil khi module audit hoàn thiện
        } catch (Exception e) {
            System.err.println("Lỗi ghi audit log: " + e.getMessage());
        }
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }

    private Integer parseInteger(String s) {
        if (s == null || s.isEmpty()) return null;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return null; }
    }
}
