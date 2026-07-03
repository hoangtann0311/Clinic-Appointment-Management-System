package controller;

import com.clinic.model.User;
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
        boolean wasAdmin = false;

        if (session != null) {
            // Lấy thông tin user trước khi hủy session để ghi audit log
            Object userObj = session.getAttribute("user");
            User user = (userObj instanceof User) ? (User) userObj : null;
            wasAdmin = (user != null) && user.getRoleId() == 1;

            // Ghi audit log ĐĂNG XUẤT trước khi hủy session
            AuditUtil.log(request, "Đăng xuất", "users", null, null);

            session.invalidate();
        }

        // Chuyển về trang login phù hợp: Admin → /admin/login, còn lại → /login
        if (wasAdmin) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
