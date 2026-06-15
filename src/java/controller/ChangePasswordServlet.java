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
 * Servlet xử lý đổi mật khẩu cho người dùng đã đăng nhập.
 * GET  → hiển thị form đổi mật khẩu
 * POST → xử lý đổi mật khẩu
 */
@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final PasswordService passwordService;

    public ChangePasswordServlet() {
        this.passwordService = new PasswordService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Nếu chưa đăng nhập, chuyển về login với thông báo
        if (session == null || session.getAttribute("user") == null) {
            session = request.getSession(true);
            session.setAttribute("successMessage",
                    "Vui lòng đăng nhập để đổi mật khẩu.");
            session.setAttribute("redirectAfterLogin", "/change-password");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        Map<String, String> errors = new HashMap<>();
        boolean success = passwordService.changePassword(
                currentUser.getId(), oldPassword, newPassword, confirmPassword, errors);

        if (!success) {
            // Đổi mật khẩu thất bại
            request.setAttribute("errors", errors);
            // Giữ lại các giá trị đã nhập (trừ mật khẩu)
            request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
            return;
        }

        // Đổi mật khẩu thành công
        session.setAttribute("successMessage",
                "Đổi mật khẩu thành công! Vui lòng sử dụng mật khẩu mới cho lần đăng nhập sau.");
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
