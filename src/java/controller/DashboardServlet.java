package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Servlet xử lý các trang dashboard theo role.
 * Hiển thị dashboard tương ứng cho từng vai trò người dùng.
 */
@WebServlet(urlPatterns = {
    "/admin/dashboard",
    "/manager/dashboard",
    "/staff/dashboard",
    "/home",
    "/sonographer/dashboard"
})
public class DashboardServlet extends HttpServlet {

    /** Tên hiển thị tương ứng với roleId */
    private static final Map<Integer, String> ROLE_NAMES = new LinkedHashMap<>();
    static {
        ROLE_NAMES.put(1, "Quản Trị Viên");
        ROLE_NAMES.put(2, "Bác Sĩ");
        ROLE_NAMES.put(3, "Quản Lý");
        ROLE_NAMES.put(4, "Nhân Viên");
        ROLE_NAMES.put(5, "Bệnh Nhân");
        ROLE_NAMES.put(6, "Kỹ Thuật Viên Siêu Âm");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int roleId = user.getRoleId();
        String roleName = ROLE_NAMES.getOrDefault(roleId, "Người Dùng");

        request.setAttribute("roleName", roleName);
        request.setAttribute("dashboardTitle", "Dashboard " + roleName);

        // Route đến dashboard JSP tương ứng với role
        String targetJsp;
        switch (roleId) {
            case 1: // Admin → giao diện admin riêng với sidebar layout
                loadAdminDashboardData(request);
                targetJsp = "/views/admin/dashboard.jsp";
                break;
            default: // Các role khác giữ nguyên giao diện chung
                targetJsp = "/views/home/dashboard.jsp";
                break;
        }

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    /**
     * Load dữ liệu thống kê cho Admin Dashboard từ database.
     * Gọi DashboardService để lấy số liệu thực thay vì hardcode.
     */
    private void loadAdminDashboardData(HttpServletRequest request) {
        DashboardService dashboardService = new DashboardService();

        // Thống kê tổng quan
        request.setAttribute("totalUsers", dashboardService.getTotalUsers());
        request.setAttribute("totalDoctors", dashboardService.getTotalDoctors());
        request.setAttribute("totalAppointmentsToday", dashboardService.getTotalAppointmentsToday());
        request.setAttribute("monthlyRevenue", dashboardService.getMonthlyRevenue());

        // Danh sách người dùng mới nhất (5 người)
        request.setAttribute("recentUsers", dashboardService.getRecentUsers(5));
    }
}