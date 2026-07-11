package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.GoogleAuthException;
import com.clinic.service.GoogleAuthService;
import com.clinic.service.GoogleUserInfo;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý đăng nhập bằng Google OAuth 2.0.
 *
 * Flow:
 * 1. Frontend (login.jsp) hiển thị nút "Sign in with Google"
 * 2. Google Identity Services trả về ID token (credential)
 * 3. JavaScript gửi credential lên servlet này qua AJAX POST
 * 4. Servlet xác thực token, tìm/tạo user, tạo session
 * 5. Trả về JSON {success: true, redirectUrl: "..."} hoặc {success: false, error: "..."}
 */
@WebServlet("/google-login")
public class GoogleLoginServlet extends HttpServlet {

    private GoogleAuthService googleAuthService;

    @Override
    public void init() throws ServletException {
        this.googleAuthService = new GoogleAuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Không hỗ trợ GET — chuyển hướng về trang login
        response.sendRedirect(request.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy credential (ID token) từ request
        String credential = request.getParameter("credential");

        response.setContentType("application/json; charset=UTF-8");

        if (credential == null || credential.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"error\":\"Không nhận được token đăng nhập từ Google.\"}");
            return;
        }

        try {
            // Bước 1: Xác thực token với Google
            GoogleUserInfo googleInfo = googleAuthService.verifyGoogleToken(credential);

            // Bước 2: Đăng nhập hoặc tạo user mới
            User user = googleAuthService.loginWithGoogle(googleInfo);

            // Bước 3: Tạo session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("roleId", user.getRoleId());

            // Ghi audit log
            AuditUtil.log(null, "Đăng nhập Google: " + user.getEmail(), "users",
                    null, "roleId=" + user.getRoleId(), request.getRemoteAddr());

            // Bước 4: Xác định URL redirect
            String dashboardPath = getDashboardPath(user.getRoleId());
            String redirectUrl = request.getContextPath() + dashboardPath;

            // Trả về JSON redirect URL cho frontend
            response.getWriter().write("{\"success\":true,\"redirectUrl\":\"" + redirectUrl + "\"}");

        } catch (GoogleAuthException e) {
            // Token không hợp lệ hoặc tài khoản bị khóa/vô hiệu hóa
            System.err.println(">>> Google login failed: " + e.getMessage());
            response.getWriter().write("{\"success\":false,\"error\":\""
                    + escapeJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            // Lỗi không mong đợi
            System.err.println(">>> Google login unexpected error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"error\":\""
                    + escapeJson("Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại sau.") + "\"}");
        }
    }

    /**
     * Trả về đường dẫn dashboard tương ứng với role.
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

    /**
     * Escape chuỗi để an toàn trong JSON value.
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
