package com.clinic.controller;

import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý đăng xuất.
 * Hủy session và chuyển về trang đăng nhập.
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            // Lấy thông tin user trước khi hủy session để ghi audit log
            // Ghi audit log ĐĂNG XUẤT trước khi hủy session
            AuditUtil.log(request, "Đăng xuất", "users", null, null);

            session.invalidate();
        }

        // Mọi vai trò dùng chung một trang đăng nhập.
        // All roles return to the common login page.
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
