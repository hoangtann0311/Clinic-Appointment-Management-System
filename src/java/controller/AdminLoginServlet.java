package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet xử lý đăng nhập cho Admin (Quản Trị Viên).
 * Chỉ chấp nhận tài khoản có roleId = 1 (Admin).
 *
 * GET  → hiển thị form đăng nhập admin
 * POST → xác thực, kiểm tra role Admin, chuyển hướng đến admin dashboard
 */
@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    private final AuthService authService;

    public AdminLoginServlet() {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Nếu đã đăng nhập, kiểm tra role
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if (user.getRoleId() == 1) {
                // Đã là Admin → chuyển thẳng vào dashboard
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                // Không phải Admin → đăng xuất và yêu cầu đăng nhập lại
                session.invalidate();
                request.getSession(true).setAttribute("errorMessage",
                        "Vui lòng đăng nhập bằng tài khoản Quản Trị Viên.");
                response.sendRedirect(request.getContextPath() + "/admin/login");
            }
            return;
        }

        // Hiển thị form đăng nhập admin
        request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Map<String, String> errors = new HashMap<>();
        // Sửa thành:
        User user = authService.login(email, password, errors);

        if (user == null) {
            // Đăng nhập thất bại
            request.setAttribute("emailValue", email);
            request.setAttribute("errors", errors);

            String loginError = errors.get("login");
            if (loginError != null) {
                request.setAttribute("errorMessage", loginError);
            }
            request.setAttribute("emailError", errors.get("email"));
            request.setAttribute("passwordError", errors.get("password"));

            request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
            return;
        }

        // Kiểm tra role Admin (roleId = 1)
        if (user.getRoleId() != 1) {
            request.setAttribute("emailValue", email);
            request.setAttribute("errorMessage",
                    "Tài khoản này không có quyền truy cập quản trị. "
                    + "Vui lòng sử dụng tài khoản Quản Trị Viên.");
            request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập thành công với quyền Admin
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("roleId", user.getRoleId());

        System.out.println(">>> Admin logged in: " + user.getEmail()
                + " (roleId=" + user.getRoleId() + ", id=" + user.getId() + ")");

        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }
}
