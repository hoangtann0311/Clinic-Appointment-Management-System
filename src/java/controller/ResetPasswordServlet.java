package controller;

import com.clinic.model.User;
import com.clinic.service.PasswordService;
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
 * Servlet xử lý đặt lại mật khẩu từ link email.
 * GET  → hiển thị form nhập mật khẩu mới (có token trong URL)
 * POST → xử lý đặt lại mật khẩu
 */
@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordService passwordService;

    public ResetPasswordServlet() {
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

        String token = request.getParameter("token");

        // Kiểm tra token có tồn tại trong URL không
        if (token == null || token.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage",
                    "Link đặt lại mật khẩu không hợp lệ. Vui lòng gửi yêu cầu mới.");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        // Truyền token vào JSP (ẩn trong form)
        request.setAttribute("token", token.trim());
        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        Map<String, String> errors = new HashMap<>();
        User user = passwordService.resetPassword(token, newPassword, confirmPassword, errors);

        if (user == null) {
            // Đặt lại mật khẩu thất bại
            request.setAttribute("token", token);
            request.setAttribute("errors", errors);

            // Nếu token không hợp lệ hoặc hết hạn, chuyển về trang quên mật khẩu
            if (errors.containsKey("token")) {
                request.getSession().setAttribute("errorMessage", errors.get("token"));
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return;
            }

            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Đặt lại mật khẩu thành công
        request.getSession().setAttribute("successMessage",
                "Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
