package controller;

import com.clinic.model.User;
import com.clinic.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý người dùng cho Admin.
 * GET  → hiển thị danh sách user (phân trang + tìm kiếm + lọc)
 * POST → xử lý thêm / sửa / xóa / đổi trạng thái
 */
@WebServlet(urlPatterns = {"/admin/users/", "/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    // Role ID → Tên hiển thị
    public static final Map<Integer, String> ROLE_MAP = Map.of(
        1, "Admin", 2, "Doctor", 3, "Manager",
        4, "Staff", 5, "Patient", 6, "Sonographer"
    );

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đọc tham số phân trang + filter
        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        Integer roleFilter = parseInteger(req.getParameter("role"));
        String statusFilter = req.getParameter("status");

        // Lấy dữ liệu
        List<User> users = userService.getUsers(page, PAGE_SIZE, search, roleFilter, statusFilter);
        int totalUsers = userService.getTotalUsers(search, roleFilter, statusFilter);
        int totalPages = (int) Math.ceil((double) totalUsers / PAGE_SIZE);

        // Set attributes cho JSP
        req.setAttribute("users", users);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("roleFilter", roleFilter);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("roleMap", ROLE_MAP);

        // Message từ redirect (thành công/lỗi)
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/admin/users/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/users/";

        try {
            switch (action != null ? action : "") {

                case "create": {
                    String fullName = req.getParameter("fullName");
                    String email = req.getParameter("email");
                    String username = req.getParameter("username");
                    String password = req.getParameter("password");
                    String phone = req.getParameter("phone");
                    int roleId = parseInt(req.getParameter("roleId"), 5);
                    String status = req.getParameter("status");

                    System.out.println("[AdminUserServlet] create: fullName=" + fullName
                        + ", email=" + email + ", username=" + username
                        + ", phone=" + phone + ", roleId=" + roleId + ", status=" + status);

                    Map<String, String> errors = new HashMap<>();
                    if (userService.createUser(fullName, email, username, password, phone, roleId, status, errors)) {
                        resp.sendRedirect(redirectUrl + "?success=created");
                    } else {
                        // Lưu lại giá trị form để hiển thị lại trong modal
                        req.setAttribute("formFullName", fullName);
                        req.setAttribute("formEmail", email);
                        req.setAttribute("formUsername", username);
                        req.setAttribute("formPhone", phone);
                        req.setAttribute("formRoleId", roleId);
                        req.setAttribute("formStatus", status);
                        req.setAttribute("errors", errors);
                        req.setAttribute("showAddModal", true);

                        // In log lỗi để debug
                        System.out.println("[AdminUserServlet] create FAILED: " + errors);

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
                    int roleId = parseInt(req.getParameter("roleId"), 5);
                    String status = req.getParameter("status");

                    System.out.println("[AdminUserServlet] edit: userId=" + userId
                        + ", fullName=" + fullName + ", email=" + email
                        + ", username=" + username + ", phone=" + phone
                        + ", roleId=" + roleId + ", status=" + status);

                    Map<String, String> errors = new HashMap<>();
                    if (userService.updateUser(userId, fullName, username, email, phone, roleId, status, errors)) {
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

                        System.out.println("[AdminUserServlet] edit FAILED: " + errors);
                        doGet(req, resp);
                    }
                    return;
                }

                case "delete": {
                    // Sử dụng Soft Delete thay vì Hard Delete để bảo toàn dữ liệu
                    int userId = parseInt(req.getParameter("userId"), -1);
                    if (userService.softDeleteUser(userId)) {
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
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Cập+nhật+trạng+thái+thất+bại");
                    }
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("AdminUserServlet POST: " + e.getMessage());
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống");
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
