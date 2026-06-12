package controller;

import com.clinic.dao.DashboardDAO;
import com.clinic.model.User;
import com.clinic.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Servlet xử lý các trang dashboard theo role.
 * Hiển thị dashboard tương ứng cho từng vai trò người dùng.
 *
 * Admin Dashboard: đầy đủ 6 KPI cards, biểu đồ lịch hẹn & doanh thu,
 * bảng hiệu suất bác sĩ, lịch làm việc, thống kê siêu âm,
 * bệnh nhân mới, nhật ký hệ thống và cảnh báo.
 */
@WebServlet(urlPatterns = {
    "/admin/dashboard",
    "/doctor/dashboard",
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

        // Ngày hiện tại cho hiển thị
        LocalDate today = LocalDate.now();
        request.setAttribute("todayDisplay",
                today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));

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
     * Load toàn bộ dữ liệu thống kê cho Admin Dashboard.
     * Gọi DashboardService để lấy số liệu thực từ database.
     */
    private void loadAdminDashboardData(HttpServletRequest request) {
        DashboardService dashboardService = new DashboardService();

        // ─── 6 KPI Cards ───
        request.setAttribute("totalPatients", dashboardService.getTotalPatients());
        request.setAttribute("totalAppointmentsToday", dashboardService.getTotalAppointmentsToday());
        request.setAttribute("waitingPatients", dashboardService.getWaitingPatients());
        request.setAttribute("doctorsWorkingToday", dashboardService.getDoctorsWorkingToday());
        request.setAttribute("ultrasoundToday", dashboardService.getUltrasoundToday());
        request.setAttribute("revenueToday", dashboardService.getRevenueToday());

        // Tổng số users + doctors (legacy KPI)
        request.setAttribute("totalUsers", dashboardService.getTotalUsers());
        request.setAttribute("totalDoctors", dashboardService.getTotalDoctors());

        // ─── Biểu đồ lịch hẹn 7 ngày ───
        Map<String, Integer> apptChart = dashboardService.getAppointmentsChartData();
        request.setAttribute("apptChartLabels", apptChart.keySet());
        request.setAttribute("apptChartValues", apptChart.values());

        // ─── Biểu đồ doanh thu 12 tháng ───
        Map<String, Double> revenueChart = dashboardService.getRevenueChartData();
        request.setAttribute("revenueChartLabels", revenueChart.keySet());
        request.setAttribute("revenueChartValues", revenueChart.values());

        // ─── Bảng hiệu suất bác sĩ ───
        request.setAttribute("doctorPerformance", dashboardService.getDoctorPerformance());

        // ─── Lịch làm việc hôm nay ───
        request.setAttribute("todaySchedules", dashboardService.getTodaySchedules());

        // ─── Thống kê dịch vụ siêu âm ───
        request.setAttribute("ultrasoundStats", dashboardService.getUltrasoundStats());

        // ─── Bệnh nhân mới đăng ký ───
        request.setAttribute("recentPatients", dashboardService.getRecentPatients(8));

        // ─── Người dùng mới nhất (legacy table) ───
        request.setAttribute("recentUsers", dashboardService.getRecentUsers(5));

        // ─── Nhật ký hệ thống ───
        request.setAttribute("recentAuditLogs", dashboardService.getRecentAuditLogs(10));

        // ─── Cảnh báo hệ thống ───
        request.setAttribute("systemAlerts", dashboardService.getSystemAlerts());
    }
}
