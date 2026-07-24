package com.clinic.controller;

import com.clinic.config.GoogleConfig;
import com.clinic.model.User;
import com.clinic.service.GoogleAuthException;
import com.clinic.service.GoogleAuthService;
import com.clinic.service.GoogleUserInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý server-side OAuth 2.0 flow cho Google Login.
 *
 * Flow:
 * 1. GET /google-login-server → redirect user đến Google authorization endpoint
 * 2. User approve → Google redirect về GET /google-login-server?code=xxx
 * 3. Servlet đổi code lấy ID token → verify → login → redirect dashboard
 *
 * Ưu điểm so với client-side GIS flow:
 * - Không phụ thuộc vào "Authorized JavaScript origins" trong Google Cloud Console
 * - Chỉ cần redirect URI được registered (linh hoạt hơn với nhiều port)
 * - Hoạt động trên mọi host/port miễn là redirect URI được thêm vào Console
 *
 * Cách cấu hình Google Cloud Console:
 * - Vào "APIs & Services" → "Credentials" → OAuth 2.0 Client ID
 * - Thêm "Authorized redirect URIs" cho TẤT CẢ các port bạn dùng:
 *     http://localhost:8080/ClinicAppointmentManagementSystem/google-login-server
 *     http://localhost:8081/ClinicAppointmentManagementSystem/google-login-server
 *     (với từng context path tương ứng)
 */
@WebServlet("/google-login-server")
public class GoogleServerLoginServlet extends HttpServlet {

    private GoogleAuthService googleAuthService;

    @Override
    public void init() throws ServletException {
        this.googleAuthService = new GoogleAuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra xem đây là callback từ Google (có code) hay là request bắt đầu flow
        String code = request.getParameter("code");
        String error = request.getParameter("error");

        if (error != null) {
            // User từ chối hoặc có lỗi từ Google
            request.getSession().setAttribute("errorMessage",
                    "Đăng nhập Google bị hủy hoặc có lỗi: " + error);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (code == null || code.isEmpty()) {
            // Bắt đầu OAuth flow → redirect đến Google
            if (!GoogleConfig.isConfigured()) {
                request.getSession().setAttribute("errorMessage",
                        "Google Login chưa được cấu hình trên máy chủ.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Tạo redirect URI động dựa trên request hiện tại
            String redirectUri = buildRedirectUri(request);
            String authUrl = GoogleAuthService.buildAuthorizationUrl(redirectUri);

            System.out.println(">>> Google server-side login: redirecting to Google...");
            System.out.println(">>> Redirect URI: " + redirectUri);
            response.sendRedirect(authUrl);
            return;
        }

        // Callback từ Google với authorization code
        try {
            // Tạo redirect URI (phải giống hệt lúc gửi request)
            String redirectUri = buildRedirectUri(request);

            // Đổi code lấy GoogleUserInfo
            GoogleUserInfo googleInfo = googleAuthService.exchangeAuthCode(code, redirectUri);

            // Đăng nhập hoặc tạo user
            User user = googleAuthService.loginWithGoogle(googleInfo);

            // Tạo session
            HttpSession session = request.getSession(true);

            // Nạp ảnh đại diện từ bảng vai trò cụ thể (hiện chỉ có doctors.avatar_url)
            if (user.getRoleId() == 2) {
                com.clinic.model.Doctor doctor = new com.clinic.dao.DoctorDAO().findByUserId(user.getId());
                if (doctor != null) {
                    user.setAvatarUrl(doctor.getAvatarUrl());
                }
            }

            session.setAttribute("user", user);
            session.setAttribute("roleId", user.getRoleId());

            // Nạp permissions vào session
            try {
                com.clinic.service.RoleService roleService = new com.clinic.service.RoleService();
                java.util.Set<String> perms = roleService.getPermissionKeysByUserId(user.getId());
                session.setAttribute("userPermissions", perms);
                System.out.println(">>> Loaded " + perms.size() + " permissions for " + user.getEmail());
            } catch (Exception ex) {
                session.setAttribute("userPermissions", java.util.Collections.emptySet());
                System.err.println(">>> Failed to load permissions: " + ex.getMessage());
            }

            System.out.println(">>> Google server-side login success: " + user.getEmail()
                    + " (roleId=" + user.getRoleId() + ", id=" + user.getId() + ")");

            // Redirect đến dashboard
            String dashboardPath = getDashboardPath(user.getRoleId());
            response.sendRedirect(request.getContextPath() + dashboardPath);

        } catch (GoogleAuthException e) {
            System.err.println(">>> Google server-side login: " + e.getMessage());
            // Nếu là pending verification → hiển thị dạng thông báo thông thường (successMessage)
            // Nếu là lỗi thật → hiển thị errorMessage
            String msg = e.getMessage();
            if (msg != null && msg.contains("xác nhận email")) {
                request.getSession().setAttribute("successMessage", msg);
            } else {
                request.getSession().setAttribute("errorMessage", msg);
            }
            response.sendRedirect(request.getContextPath() + "/login");
        } catch (Exception e) {
            System.err.println(">>> Google server-side login unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage",
                    "Đã xảy ra lỗi trong quá trình đăng nhập Google. Vui lòng thử lại sau.");
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Không hỗ trợ POST — forward sang GET
        doGet(request, response);
    }

    /**
     * Tạo redirect URI động từ request hiện tại.
     * VD: http://localhost:8080/ClinicAppointmentManagementSystem/google-login-server
     */
    private String buildRedirectUri(HttpServletRequest request) {
        String scheme = request.getScheme();           // http hoặc https
        String serverName = request.getServerName();   // localhost
        int serverPort = request.getServerPort();      // 8080
        String contextPath = request.getContextPath(); // /ClinicAppointmentManagementSystem
        String servletPath = request.getServletPath(); // /google-login-server

        // Chỉ thêm port nếu không phải port mặc định
        if (("http".equals(scheme) && serverPort == 80)
                || ("https".equals(scheme) && serverPort == 443)) {
            return scheme + "://" + serverName + contextPath + servletPath;
        }
        return scheme + "://" + serverName + ":" + serverPort + contextPath + servletPath;
    }

    private String getDashboardPath(int roleId) {
        switch (roleId) {
            case 1: return "/admin/dashboard";
            case 2: return "/doctor/dashboard";
            case 3: return "/manager/dashboard";
            case 4: return "/admin/reception";
            case 5: return "/home";
            case 6: return "/sonographer/dashboard";
            default: return "/home";
        }
    }
}
