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
            case 3: // Manager → giao diện manager với theme Teal/Emerald
                loadManagerDashboardData(request);
                targetJsp = "/views/manager/dashboard.jsp";
                break;
            default: // Các role khác giữ nguyên giao diện chung
                targetJsp = "/views/home/dashboard.jsp";
                break;
        }

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    /**
     * Load dữ liệu thống kê cho Manager Dashboard.
     * Manager tập trung vào quản lý dịch vụ, thuốc, biểu giá và thống kê dịch vụ.
     * Hỗ trợ lọc theo khoảng ngày (dateFrom → dateTo).
     */
    private void loadManagerDashboardData(HttpServletRequest request) {
        com.clinic.service.MedicineService medicineService = new com.clinic.service.MedicineService();
        com.clinic.service.ServiceService serviceService = new com.clinic.service.ServiceService();
        com.clinic.service.ServiceStatisticsService statsService = new com.clinic.service.ServiceStatisticsService();

        // ── Đọc tham số lọc khoảng ngày ──
        String dateFromStr = request.getParameter("dateFrom");
        String dateToStr = request.getParameter("dateTo");
        LocalDate dateFrom = null;
        LocalDate dateTo = null;
        LocalDate today = LocalDate.now();

        try {
            if (dateFromStr != null && !dateFromStr.trim().isEmpty()) {
                dateFrom = LocalDate.parse(dateFromStr);
            }
        } catch (Exception e) {
            dateFrom = null;
        }
        try {
            if (dateToStr != null && !dateToStr.trim().isEmpty()) {
                dateTo = LocalDate.parse(dateToStr);
            }
        } catch (Exception e) {
            dateTo = null;
        }

        // Nếu không có tham số, mặc định là hôm nay
        boolean isCustomRange = (dateFrom != null || dateTo != null);
        if (!isCustomRange) {
            dateFrom = today;
            dateTo = today;
        } else {
            // Nếu chỉ có 1 trong 2, mặc định cái còn lại = hôm nay
            if (dateFrom == null) dateFrom = today;
            if (dateTo == null) dateTo = today;
        }

        // ── Truyền ngày cho JSP ──
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("isCustomRange", isCustomRange);
        request.setAttribute("today", today);

        // Tổng số dịch vụ và thuốc — lọc theo ngày tạo nếu có date filter
        LocalDate countMaxDate = isCustomRange ? dateTo : null;
        request.setAttribute("totalServices", serviceService.getTotalServices(null, null, countMaxDate));
        request.setAttribute("totalMedicines", medicineService.getTotalMedicines(null, null, countMaxDate));

        // Số dịch vụ và thuốc đang active — lọc theo ngày tạo nếu có date filter
        request.setAttribute("activeServicesCount", serviceService.getTotalServices(null, true, countMaxDate));
        request.setAttribute("activeMedicinesCount", medicineService.getTotalMedicines(null, true, countMaxDate));

        // ─── Widget "Top Dịch Vụ" — 5 dịch vụ có lượt sử dụng cao nhất trong khoảng ngày ───
        request.setAttribute("topServicesToday", statsService.getTopServicesByUsage(5, dateFrom, dateTo));

        // ─── Widget "Cảnh Báo Tồn Kho" — thuốc sắp hết (stock ≤ 10) ───
        request.setAttribute("lowStockMedicines", medicineService.getLowStockMedicines(10, 5));

        // ─── Doanh thu khoảng trước cho KPI card so sánh ───
        double revenuePrevious;
        double revenueGrowthRate;
        if (isCustomRange) {
            revenuePrevious = statsService.getTotalRevenue(
                    statsDAO_prevFrom(dateFrom, dateTo),
                    statsDAO_prevTo(dateFrom, dateTo));
            revenueGrowthRate = statsService.getRevenueGrowthRate(dateFrom, dateTo);
        } else {
            revenuePrevious = statsService.getTotalRevenueYesterday();
            revenueGrowthRate = statsService.getRevenueGrowthRate();
        }
        request.setAttribute("revenueYesterdayFormatted",
                com.clinic.service.ServiceStatisticsService.formatCurrency(revenuePrevious));
        request.setAttribute("revenueGrowthRate", revenueGrowthRate);
        request.setAttribute("revenueGrowthFormatted",
                com.clinic.service.ServiceStatisticsService.formatGrowthPercent(revenueGrowthRate));

        // ─── Thống kê dịch vụ (Service Statistics KPI) — theo khoảng ngày ───
        int totalUsage = statsService.getTotalUsage(dateFrom, dateTo);
        double totalRevenue = statsService.getTotalRevenue(dateFrom, dateTo);
        double usageGrowthRate = statsService.getUsageGrowthRate(dateFrom, dateTo);
        String topServiceName = statsService.getTopServiceName(dateFrom, dateTo);
        int topServiceUsage = statsService.getTopServiceUsage(dateFrom, dateTo);
        int servicesUsed = statsService.getServicesUsed(dateFrom, dateTo);

        request.setAttribute("totalUsageToday", totalUsage);
        request.setAttribute("totalRevenueTodayFormatted",
                com.clinic.service.ServiceStatisticsService.formatCurrency(totalRevenue));
        request.setAttribute("usageGrowthRate", usageGrowthRate);
        request.setAttribute("usageGrowthFormatted",
                com.clinic.service.ServiceStatisticsService.formatGrowthPercent(usageGrowthRate));
        request.setAttribute("topServiceName", topServiceName);
        request.setAttribute("topServiceUsage", topServiceUsage);
        request.setAttribute("servicesUsedToday", servicesUsed);

        // ─── Dữ liệu cho hiển thị khoảng ngày ───
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        request.setAttribute("dateFromFormatted", dateFrom.format(dateFmt));
        request.setAttribute("dateToFormatted", dateTo.format(dateFmt));

        // Label cho khoảng ngày
        if (!isCustomRange || (dateFrom.equals(today) && dateTo.equals(today))) {
            request.setAttribute("dateRangeLabel", "Hôm nay");
        } else if (dateFrom.equals(dateTo)) {
            request.setAttribute("dateRangeLabel", "Ngày " + dateFrom.format(dateFmt));
        } else {
            request.setAttribute("dateRangeLabel",
                    dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt));
        }
    }

    /** Tính ngày bắt đầu của khoảng trước đó (so sánh tăng trưởng). */
    private LocalDate statsDAO_prevFrom(LocalDate from, LocalDate to) {
        long days = to.toEpochDay() - from.toEpochDay() + 1;
        return from.minusDays(days);
    }

    /** Tính ngày kết thúc của khoảng trước đó (so sánh tăng trưởng). */
    private LocalDate statsDAO_prevTo(LocalDate from, LocalDate to) {
        return from.minusDays(1);
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
