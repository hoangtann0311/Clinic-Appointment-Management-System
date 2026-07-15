package controller;

import com.clinic.model.User;
import com.clinic.service.AuthService;
import com.clinic.service.RoleService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Servlet xử lý đăng nhập.
 * GET  → hiển thị form đăng nhập
 * POST → xác thực và chuyển hướng theo role
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService;

    public LoginServlet() {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Nếu đã đăng nhập, chuyển thẳng về dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            response.sendRedirect(request.getContextPath() + getDashboardPath(user.getRoleId()));
            return;
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Map<String, String> errors = new HashMap<>();
        User user = authService.login(email, password, errors);

        if (user == null) {
            // Đăng nhập thất bại: giữ lại email đã nhập, hiển thị lỗi
            request.setAttribute("emailValue", email);
            request.setAttribute("errors", errors);

            // Ghi log đăng nhập thất bại
            AuditUtil.log(null, "Đăng nhập thất bại: " + (email != null ? email : "không rõ"),
                    "users", null, null, request.getRemoteAddr());

            // Lấy thông báo lỗi tổng quát hoặc lỗi theo trường
            String loginError = errors.get("login");
            if (loginError != null) {
                request.setAttribute("errorMessage", loginError);
            }
            request.setAttribute("emailError", errors.get("email"));
            request.setAttribute("passwordError", errors.get("password"));

            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập thành công: tạo session và lưu user
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        // Lưu thêm roleId để tiện kiểm tra nhanh
        session.setAttribute("roleId", user.getRoleId());

        // Nạp danh sách quyền (permission keys) vào session để Authorization Filter sử dụng
        try {
            RoleService roleService = new RoleService();
            Set<String> userPermissions = roleService.getPermissionKeysByUserId(user.getId());
            session.setAttribute("userPermissions", userPermissions);
            // Lưu version hiện tại để AuthorizationFilter phát hiện thay đổi quyền
            session.setAttribute("permissionsLoadedVersion",
                com.clinic.filter.AuthorizationFilter.GLOBAL_PERMISSIONS_VERSION.get());
            System.out.println(">>> Loaded " + userPermissions.size() + " permissions for user " + user.getEmail());
        } catch (Exception e) {
            System.err.println(">>> Failed to load permissions for user " + user.getEmail() + ": " + e.getMessage());
            session.setAttribute("userPermissions", java.util.Collections.emptySet());
            session.setAttribute("permissionsLoadedVersion", 0L);
        }

        // Ghi log đăng nhập thành công
        AuditUtil.log(request, "Đăng nhập thành công", "users",
                null, "roleId=" + user.getRoleId());

        // Chuyển hướng đến dashboard theo role
        String dashboardPath = getDashboardPath(user.getRoleId());
        response.sendRedirect(request.getContextPath() + dashboardPath);
    }

    /**
     * Trả về đường dẫn dashboard tương ứng với role.
     * Mapping:
     *   1 = Admin       → /admin/dashboard
     *   2 = Doctor      → /doctor/dashboard
     *   3 = Manager     → /manager/dashboard
     *   4 = Staff       → /staff/dashboard
     *   5 = Patient     → /home
     *   6 = Sonographer → /sonographer/dashboard
     */
    private String getDashboardPath(int roleId) {
        switch (roleId) {
            case 1: return "/admin/dashboard";
            case 2: return "/doctor/dashboard";
            case 3: return "/manager/dashboard";
            case 4: return "/staff/dashboard";
            case 5: return "/home";
            case 6: return "/sonographer/dashboard";
            default: return "/home";
        }
    }
}
