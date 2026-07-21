package controller;

import com.clinic.model.User;
import com.clinic.service.AuthService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet xử lý đăng ký tài khoản.
 * GET  → hiển thị form đăng ký
 * POST → xử lý đăng ký
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiển thị form đăng ký
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy tham số từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        String terms = request.getParameter("terms"); // Checkbox: "on" nếu checked, null nếu không

        Map<String, String> errors = new HashMap<>();

        // Gọi service đăng ký
        User newUser = authService.register(fullName, email, password, confirmPassword, phone, terms, errors);

        if (newUser != null) {
            // Đăng ký thành công → ghi audit log + thông báo kiểm tra email xác thực
            AuditUtil.log(null, "Đăng ký tài khoản: " + email, "users",
                    null, "fullName=" + fullName + ", phone=" + phone, request.getRemoteAddr());
            request.getSession().setAttribute("successMessage",
                    "Đăng ký tài khoản thành công! "
                    + "Vui lòng kiểm tra email (" + email + ") "
                    + "và nhấn vào link xác thực để kích hoạt tài khoản.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            // Đăng ký thất bại → giữ lại form với lỗi và dữ liệu đã nhập
            request.setAttribute("errors", errors);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}
