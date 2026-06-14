package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet xử lý xác thực email khi người dùng click link trong email.
 * GET /verify-email?token=xxx
 *
 * Flow: nhận token → tìm user → xác thực (is_verified=1, status=Active)
 *       → redirect về login với thông báo thành công hoặc lỗi
 */
@WebServlet("/verify-email")
public class VerifyEmailServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        if (token == null || token.trim().isEmpty()) {
            // Không có token → redirect về login với thông báo lỗi
            request.getSession().setAttribute("errorMessage",
                    "Link xác thực không hợp lệ. Vui lòng kiểm tra lại email hoặc đăng ký lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Gọi service xác thực email
        User verifiedUser = authService.verifyEmail(token.trim());

        if (verifiedUser != null) {
            // Xác thực thành công
            request.getSession().setAttribute("successMessage",
                    "Xác thực email thành công! Tài khoản của bạn đã được kích hoạt. Vui lòng đăng nhập.");
        } else {
            // Token không tồn tại hoặc đã được sử dụng
            request.getSession().setAttribute("errorMessage",
                    "Link xác thực không hợp lệ hoặc đã hết hạn. "
                    + "Vui lòng đăng ký lại hoặc liên hệ hỗ trợ.");
        }

        // Redirect về trang login
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
