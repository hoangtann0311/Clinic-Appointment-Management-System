package controller;

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
            // Lấy thông tin user trước khi hủy session
            Object user = session.getAttribute("user");
            String email = (user instanceof com.clinic.model.User)
                    ? ((com.clinic.model.User) user).getEmail() : "unknown";
            wasAdmin = (user instanceof com.clinic.model.User)
                    && ((com.clinic.model.User) user).getRoleId() == 1;

            session.invalidate();
            System.out.println(">>> User logged out: " + email);
        }

        // Chuyển về trang login phù hợp: Admin → /admin/login, còn lại → /login
        if (wasAdmin) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
