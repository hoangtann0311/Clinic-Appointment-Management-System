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
// Force IDE compiler reload: Resolved mapping conflict
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

        String path = request.getRequestURI().substring(request.getContextPath().length());

        // Chuyển hướng / forward theo role
        switch (roleId) {
            case 1: // Admin
                if (!"/admin/dashboard".equals(path)) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                }
                loadAdminDashboardData(request);
                request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
                break;
            case 2: // Doctor
                response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
                break;
            case 3: // Manager
                if (!"/manager/dashboard".equals(path)) {
                    response.sendRedirect(request.getContextPath() + "/manager/dashboard");
                    return;
                }
                loadManagerDashboardData(request);
                request.getRequestDispatcher("/views/manager/dashboard.jsp").forward(request, response);
                break;
            case 4: // Staff
                response.sendRedirect(request.getContextPath() + "/admin/reception");
                break;
            case 6: // Sonographer
                response.sendRedirect(request.getContextPath() + "/sonographer/waiting-list");
                break;
            case 5: // Patient
            default:
                request.getRequestDispatcher("/views/home/dashboard.jsp").forward(request, response);
                break;
        }
    }

    /**
     * Load dữ liệu thống kê cho Admin Dashboard từ database.
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

    /**
     * Load dữ liệu thống kê cho Manager Dashboard từ database.
     */
    private void loadManagerDashboardData(HttpServletRequest request) {
        try {
            com.clinic.dao.ServiceDAO serviceDAO = new com.clinic.dao.ServiceDAO();
            com.clinic.dao.MedicineDAO medicineDAO = new com.clinic.dao.MedicineDAO();
            
            int totalServices = serviceDAO.countAll(null, null);
            int totalMedicines = medicineDAO.countAll(null, null);
            int activeServicesCount = serviceDAO.countActive();
            
            request.setAttribute("totalServices", totalServices);
            request.setAttribute("totalMedicines", totalMedicines);
            request.setAttribute("activeServicesCount", activeServicesCount);
            
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
            request.setAttribute("todayDisplay", "Hôm nay, " + today.format(dtf));
        } catch (Exception e) {
            System.err.println("DashboardServlet: Lỗi loadManagerDashboardData - " + e.getMessage());
            e.printStackTrace();
        }
    }
}
