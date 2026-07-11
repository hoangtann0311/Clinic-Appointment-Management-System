package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.DashboardService;
import com.clinic.service.MedicineService;
import com.clinic.service.ServiceService;
import com.clinic.service.ServiceStatisticsService;
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

        // Ngày hiện tại cho hiển thị
        LocalDate today = LocalDate.now();
        request.setAttribute("todayDisplay",
                today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));

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
<<<<<<< HEAD:src/java/com/clinic/controller/DashboardServlet.java
=======

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
>>>>>>> origin/hieupt:src/java/controller/DashboardServlet.java
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

    /**
     * Load dữ liệu thống kê cho Manager Dashboard.
     * Manager tập trung vào quản lý dịch vụ, thuốc, biểu giá và thống kê dịch vụ.
     */
    private void loadManagerDashboardData(HttpServletRequest request) {
        try {
            MedicineService medicineService = new MedicineService();
            ServiceService serviceService = new ServiceService();
            ServiceStatisticsService statsService = new ServiceStatisticsService();

            // Tổng số dịch vụ và thuốc
            request.setAttribute("totalServices", serviceService.getTotalServices(null, null));
            request.setAttribute("totalMedicines", medicineService.getTotalMedicines(null, null));

            // Số dịch vụ và thuốc đang active
            request.setAttribute("activeServicesCount", serviceService.getTotalServices(null, true));
            request.setAttribute("activeMedicinesCount", medicineService.getTotalMedicines(null, true));

            // ─── Widget "Top Dịch Vụ Hôm Nhất" — 5 dịch vụ có lượt sử dụng cao nhất ───
            request.setAttribute("topServicesToday", statsService.getTopServicesByUsage(5));

            // ─── Widget "Cảnh Báo Tồn Kho" — thuốc sắp hết (stock ≤ 10) ───
            request.setAttribute("lowStockMedicines", medicineService.getLowStockMedicines(10, 5));

            // ─── Doanh thu hôm qua cho KPI card so sánh ───
            double revenueYesterday = statsService.getTotalRevenueYesterday();
            double revenueGrowthRate = statsService.getRevenueGrowthRate();
            request.setAttribute("revenueYesterdayFormatted",
                    ServiceStatisticsService.formatCurrency(revenueYesterday));
            request.setAttribute("revenueGrowthRate", revenueGrowthRate);
            request.setAttribute("revenueGrowthFormatted",
                    ServiceStatisticsService.formatGrowthPercent(revenueGrowthRate));

            // ─── Thống kê dịch vụ (Service Statistics KPI cho Manager Dashboard) ───
            int totalUsageToday = statsService.getTotalUsageToday();
            double totalRevenueToday = statsService.getTotalRevenueToday();
            double usageGrowthRate = statsService.getUsageGrowthRate();
            String topServiceName = statsService.getTopServiceName();
            int topServiceUsage = statsService.getTopServiceUsage();
            int servicesUsedToday = statsService.getServicesUsedToday();

            request.setAttribute("totalUsageToday", totalUsageToday);
            request.setAttribute("totalRevenueTodayFormatted",
                    ServiceStatisticsService.formatCurrency(totalRevenueToday));
            request.setAttribute("usageGrowthRate", usageGrowthRate);
            request.setAttribute("usageGrowthFormatted",
                    ServiceStatisticsService.formatGrowthPercent(usageGrowthRate));
            request.setAttribute("topServiceName", topServiceName);
            request.setAttribute("topServiceUsage", topServiceUsage);
            request.setAttribute("servicesUsedToday", servicesUsedToday);
        } catch (Exception e) {
            System.err.println("DashboardServlet: Lỗi loadManagerDashboardData - " + e.getMessage());
            e.printStackTrace();
        }
    }
}
