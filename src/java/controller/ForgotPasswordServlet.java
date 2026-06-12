package controller;

import com.clinic.service.PasswordService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý quên mật khẩu.
 * GET  → hiển thị form nhập email
 * POST → xử lý gửi email đặt lại mật khẩu
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final PasswordService passwordService;

    public ForgotPasswordServlet() {
        this.passwordService = new PasswordService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Nếu đã đăng nhập, chuyển hướng về dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        // Validate email không rỗng
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("emailError", "Vui lòng nhập địa chỉ email.");
            request.setAttribute("emailValue", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Gọi service xử lý quên mật khẩu
        boolean success = passwordService.forgotPassword(email);

        if (success) {
            // Luôn hiển thị thành công để không lộ thông tin
            request.getSession().setAttribute("successMessage",
                    "Nếu email của bạn đã được đăng ký trong hệ thống, "
                    + "bạn sẽ nhận được email hướng dẫn đặt lại mật khẩu trong vài phút. "
                    + "Vui lòng kiểm tra hộp thư đến (và cả thư mục spam).");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("emailError", "Có lỗi xảy ra. Vui lòng thử lại sau.");
            request.setAttribute("emailValue", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
