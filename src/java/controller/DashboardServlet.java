package controller;

import com.clinic.dao.DashboardDAO;
import com.clinic.model.User;
import com.clinic.service.AdminDashboardService;
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
import java.util.List;
import java.util.Map;

import com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail;
import com.clinic.service.ServiceStatisticsService;

/**
 * Servlet xử lý các trang dashboard theo role.
 *
 * <h2>Phân tách nghiệp vụ (v2.0)</h2>
 * <ul>
 *   <li><b>Admin (roleId=1)</b> — System Administration:
 *       Quản lý tài khoản, vai trò, quyền, audit log, bảo mật, giám sát hệ thống.</li>
 *   <li><b>Manager (roleId=3)</b> — Business Operations:
 *       Quản lý vận hành phòng khám: bệnh nhân, lịch hẹn, bác sĩ, doanh thu,
 *       dịch vụ, siêu âm, cấp cứu, tỉ lệ hoàn thành.</li>
 *   <li><b>Khác</b> — Doctor, Staff, Patient, Sonographer: dashboard riêng.</li>
 * </ul>
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
            case 1: // Admin → System Administration Dashboard
                loadAdminDashboardData(request);
                targetJsp = "/views/admin/dashboard.jsp";
                break;
            case 3: // Manager → Business Operations Dashboard
                loadManagerDashboardData(request);
                targetJsp = "/views/manager/dashboard.jsp";
                break;
            default: // Các role khác giữ nguyên giao diện chung
                targetJsp = "/views/home/dashboard.jsp";
                break;
        }

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    // ═══════════════════════════════════════════════════════════════
    // ADMIN DASHBOARD — System Administration
    // ═══════════════════════════════════════════════════════════════

    /**
     * Load dữ liệu cho Admin Dashboard (Quản trị hệ thống).
     *
     * <p><b>KPIs:</b> Tổng tài khoản, Active, Locked, Unverified,
     * Tổng Role, Tổng Permission, Đăng nhập hôm nay, Audit Log hôm nay.
     *
     * <p><b>Charts:</b> Xu hướng đăng nhập, Tăng trưởng tài khoản,
     * Phân bố vai trò, Phân loại Audit Log.
     *
     * <p><b>Alerts:</b> Tài khoản bị khóa, chưa xác thực,
     * truy cập bị từ chối, đăng nhập thất bại.
     */
    private void loadAdminDashboardData(HttpServletRequest request) {
        AdminDashboardService adminService = new AdminDashboardService();

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
        } catch (Exception e) { dateFrom = null; }
        try {
            if (dateToStr != null && !dateToStr.trim().isEmpty()) {
                dateTo = LocalDate.parse(dateToStr);
            }
        } catch (Exception e) { dateTo = null; }

        boolean isCustomRange = (dateFrom != null || dateTo != null);
        if (!isCustomRange) {
            dateFrom = today;
            dateTo = today;
        } else {
            if (dateFrom == null) dateFrom = today;
            if (dateTo == null) dateTo = today;
            if (dateFrom.equals(today) && dateTo.equals(today)) {
                isCustomRange = false;
            }
        }

        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("isCustomRange", isCustomRange);
        request.setAttribute("today", today);

        // ── Subtitle ──
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        request.setAttribute("dateFromFormatted", dateFrom.format(dateFmt));
        request.setAttribute("dateToFormatted", dateTo.format(dateFmt));

        if (isCustomRange) {
            if (dateFrom.equals(dateTo)) {
                request.setAttribute("subtitleDisplay", "Ngày " + dateFrom.format(dateFmt));
            } else {
                request.setAttribute("subtitleDisplay",
                    dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt));
            }
            request.setAttribute("dateRangeLabel",
                dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt));
        } else {
            request.setAttribute("subtitleDisplay",
                today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));
            request.setAttribute("dateRangeLabel", "Hôm nay");
        }

        // ════════════════════════════════════════════
        // 8 KPI CARDS — System Administration
        // ════════════════════════════════════════════

        if (isCustomRange) {
            // Custom range: lọc theo khoảng ngày — TẤT CẢ KPI đều filter theo date
            request.setAttribute("totalAccounts", adminService.getTotalAccounts(dateFrom, dateTo));
            request.setAttribute("activeAccounts", adminService.getActiveAccounts(dateFrom, dateTo));
            request.setAttribute("lockedAccounts", adminService.getLockedAccounts(dateFrom, dateTo));
            request.setAttribute("unverifiedAccounts", adminService.getUnverifiedAccounts(dateFrom, dateTo));
            request.setAttribute("totalRoles", adminService.getTotalRoles(dateFrom, dateTo));
            request.setAttribute("totalPermissions", adminService.getTotalPermissions(dateFrom, dateTo));
            request.setAttribute("loginsToday", adminService.getLogins(dateFrom, dateTo));
            request.setAttribute("auditLogsToday", adminService.getAuditLogs(dateFrom, dateTo));
            request.setAttribute("accessDeniedCount", adminService.getAccessDenied(dateFrom, dateTo));
        } else {
            // Live mode: dữ liệu toàn hệ thống hiện tại
            request.setAttribute("totalAccounts", adminService.getTotalAccounts());
            request.setAttribute("activeAccounts", adminService.getActiveAccounts());
            request.setAttribute("lockedAccounts", adminService.getLockedAccounts());
            request.setAttribute("unverifiedAccounts", adminService.getUnverifiedAccounts());
            request.setAttribute("totalRoles", adminService.getTotalRoles());
            request.setAttribute("totalPermissions", adminService.getTotalPermissions());
            request.setAttribute("loginsToday", adminService.getLoginsToday());
            request.setAttribute("auditLogsToday", adminService.getAuditLogsToday());
            request.setAttribute("accessDeniedCount", adminService.getAccessDeniedToday());
        }

        // ════════════════════════════════════════════
        // CHARTS — System Administration
        // ════════════════════════════════════════════

        // Biểu đồ 1: Xu hướng đăng nhập (7 ngày hoặc khoảng)
        Map<String, Integer> loginTrend;
        if (isCustomRange) {
            loginTrend = adminService.getLoginTrend(dateFrom, dateTo);
        } else {
            loginTrend = adminService.getLoginTrend7Days();
        }
        request.setAttribute("loginTrendLabels", loginTrend.keySet());
        request.setAttribute("loginTrendValues", loginTrend.values());
        request.setAttribute("hasLoginTrendData",
            loginTrend.values().stream().anyMatch(v -> v > 0));

        // Biểu đồ 2: Tăng trưởng tài khoản 12 tháng
        Map<String, Integer> accountGrowth;
        if (isCustomRange) {
            accountGrowth = adminService.getAccountGrowthChart(dateTo);
        } else {
            accountGrowth = adminService.getAccountGrowth12Months();
        }
        request.setAttribute("accountGrowthLabels", accountGrowth.keySet());
        request.setAttribute("accountGrowthValues", accountGrowth.values());
        request.setAttribute("hasAccountGrowthData",
            accountGrowth.values().stream().anyMatch(v -> v > 0));

        // Biểu đồ 3: Phân bố vai trò
        Map<String, Integer> roleDistribution;
        if (isCustomRange) {
            roleDistribution = adminService.getRoleDistribution(dateFrom, dateTo);
        } else {
            roleDistribution = adminService.getRoleDistribution();
        }
        request.setAttribute("roleDistributionLabels", roleDistribution.keySet());
        request.setAttribute("roleDistributionValues", roleDistribution.values());
        request.setAttribute("hasRoleDistData", !roleDistribution.isEmpty());

        // Biểu đồ 4: Phân loại Audit Log
        Map<String, Integer> auditClassification;
        if (isCustomRange) {
            auditClassification = adminService.getAuditLogClassification(dateFrom, dateTo);
        } else {
            auditClassification = adminService.getAuditLogClassification();
        }
        request.setAttribute("auditClassLabels", auditClassification.keySet());
        request.setAttribute("auditClassValues", auditClassification.values());
        request.setAttribute("hasAuditClassData",
            auditClassification.values().stream().anyMatch(v -> v > 0));

        // ════════════════════════════════════════════
        // BẢNG: Người dùng mới nhất + Audit Log gần đây
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("recentUsers", adminService.getRecentUsers(8, dateFrom, dateTo));
            request.setAttribute("recentAuditLogs", adminService.getRecentAuditLogs(10, dateFrom, dateTo));
        } else {
            request.setAttribute("recentUsers", adminService.getRecentUsers(8));
            request.setAttribute("recentAuditLogs", adminService.getRecentAuditLogs(10));
        }

        // ════════════════════════════════════════════
        // CẢNH BÁO HỆ THỐNG
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("systemAlerts", adminService.getSystemAlerts(dateFrom, dateTo));
        } else {
            request.setAttribute("systemAlerts", adminService.getSystemAlerts());
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MANAGER DASHBOARD — Business Operations
    // ═══════════════════════════════════════════════════════════════

    /**
     * Load dữ liệu cho Manager Dashboard (Quản lý vận hành phòng khám).
     *
     * <p><b>KPIs:</b> Tổng bệnh nhân, Lịch hẹn, Đang chờ khám, Bác sĩ trực,
     * Ca siêu âm, Doanh thu, Ca cấp cứu, Ca hoàn thành, Tỉ lệ hoàn thành,
     * Bệnh nhân mới, Hóa đơn chưa thanh toán, Lịch trực chờ duyệt.
     *
     * <p><b>Charts:</b> Doanh thu theo thời gian, Lịch hẹn, Hiệu suất bác sĩ,
     * Top dịch vụ, Siêu âm, Trạng thái thanh toán.
     *
     * <p><b>Alerts:</b> Lịch hẹn chưa xác nhận, Lịch trực chờ duyệt,
     * Hóa đơn chưa thanh toán, Thuốc sắp hết, Ca cấp cứu mới.
     */
    private void loadManagerDashboardData(HttpServletRequest request) {
        DashboardService dashboardService = new DashboardService();
        com.clinic.service.MedicineService medicineService = new com.clinic.service.MedicineService();
        com.clinic.service.ServiceService serviceService = new com.clinic.service.ServiceService();
        ServiceStatisticsService statsService = new ServiceStatisticsService();

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
        } catch (Exception e) { dateFrom = null; }
        try {
            if (dateToStr != null && !dateToStr.trim().isEmpty()) {
                dateTo = LocalDate.parse(dateToStr);
            }
        } catch (Exception e) { dateTo = null; }

        boolean isCustomRange = (dateFrom != null || dateTo != null);
        if (!isCustomRange) {
            dateFrom = today;
            dateTo = today;
        } else {
            if (dateFrom == null) dateFrom = today;
            if (dateTo == null) dateTo = today;
            if (dateFrom.equals(today) && dateTo.equals(today)) {
                isCustomRange = false;
            }
        }

        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("isCustomRange", isCustomRange);
        request.setAttribute("today", today);

        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        request.setAttribute("dateFromFormatted", dateFrom.format(dateFmt));
        request.setAttribute("dateToFormatted", dateTo.format(dateFmt));

        if (!isCustomRange || (dateFrom.equals(today) && dateTo.equals(today))) {
            request.setAttribute("dateRangeLabel", "Hôm nay");
        } else if (dateFrom.equals(dateTo)) {
            request.setAttribute("dateRangeLabel", "Ngày " + dateFrom.format(dateFmt));
        } else {
            request.setAttribute("dateRangeLabel",
                    dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt));
        }

        // ════════════════════════════════════════════
        // KPI CARDS — Business Operations (10 KPIs)
        // ════════════════════════════════════════════

        if (isCustomRange) {
            // ── KPI Kinh doanh cốt lõi ──
            request.setAttribute("totalPatients", dashboardService.getTotalPatients(dateFrom, dateTo));
            request.setAttribute("totalAppointments", dashboardService.getTotalAppointments(dateFrom, dateTo));
            request.setAttribute("waitingPatients", dashboardService.getWaitingPatients(dateFrom, dateTo));
            request.setAttribute("doctorsWorking", dashboardService.getDoctorsWorking(dateTo));
            request.setAttribute("ultrasoundCases", dashboardService.getUltrasound(dateFrom, dateTo));
            request.setAttribute("revenue", dashboardService.getRevenue(dateFrom, dateTo));
            request.setAttribute("emergencyCases", dashboardService.getEmergencyCases(dateFrom, dateTo));
            request.setAttribute("completedCases", dashboardService.getSuccessfulCases(dateFrom, dateTo));

            // ── New Patients ──
            int newPatients = dashboardService.getTotalPatients(dateFrom, dateTo);
            request.setAttribute("newPatients", newPatients);

            // ── Unpaid Invoices ──
            // (sẽ được tính trong alerts)
        } else {
            // Live mode: ALL-TIME data
            request.setAttribute("totalPatients", dashboardService.getTotalPatients());
            request.setAttribute("totalAppointments", dashboardService.getTotalAppointments());
            request.setAttribute("waitingPatients", dashboardService.getWaitingPatientsAll());
            request.setAttribute("doctorsWorking", dashboardService.getDoctorsWorkingAll());
            request.setAttribute("ultrasoundCases", dashboardService.getUltrasoundAll());
            request.setAttribute("revenue", dashboardService.getRevenueAll());
            request.setAttribute("emergencyCases", dashboardService.getEmergencyCasesAll());
            request.setAttribute("completedCases", dashboardService.getSuccessfulCasesAll());
            request.setAttribute("newPatients", dashboardService.getTotalPatients());
        }

        // ── Tỉ lệ hoàn thành ──
        int completedApps;
        int totalApps;
        if (isCustomRange) {
            completedApps = dashboardService.getSuccessfulCases(dateFrom, dateTo);
            totalApps = dashboardService.getTotalAppointments(dateFrom, dateTo);
        } else {
            completedApps = dashboardService.getSuccessfulCasesAll();
            totalApps = dashboardService.getTotalAppointments();
        }
        double completionRate = totalApps > 0
            ? (double) completedApps / totalApps * 100.0 : 0.0;
        request.setAttribute("completionRate", String.format("%.1f%%", completionRate));
        request.setAttribute("completionRateRaw", completionRate);

        // ── Tỉ lệ hủy lịch (Cancellation Rate) ──
        int cancelledApps;
        if (isCustomRange) {
            cancelledApps = dashboardService.getCancelled(dateFrom, dateTo);
        } else {
            cancelledApps = dashboardService.getCancelledAll();
        }
        double cancellationRate = totalApps > 0
            ? (double) cancelledApps / totalApps * 100.0 : 0.0;
        request.setAttribute("cancelledCount", cancelledApps);
        request.setAttribute("cancellationRate", String.format("%.1f%%", cancellationRate));

        // ── Tỉ lệ cấp cứu (Emergency Rate) ──
        int emergencyApps;
        if (isCustomRange) {
            emergencyApps = dashboardService.getEmergencyCases(dateFrom, dateTo);
        } else {
            emergencyApps = dashboardService.getEmergencyCasesAll();
        }
        double emergencyRate = totalApps > 0
            ? (double) emergencyApps / totalApps * 100.0 : 0.0;
        request.setAttribute("emergencyRate", String.format("%.1f%%", emergencyRate));

        // ════════════════════════════════════════════
        // DỊCH VỤ & THUỐC (Manager's core management)
        // ════════════════════════════════════════════

        LocalDate countMaxDate = isCustomRange ? dateTo : null;
        request.setAttribute("totalServices", serviceService.getTotalServices(null, null, countMaxDate));
        request.setAttribute("totalMedicines", medicineService.getTotalMedicines(null, null, countMaxDate));
        request.setAttribute("activeServicesCount", serviceService.getTotalServices(null, true, countMaxDate));
        request.setAttribute("activeMedicinesCount", medicineService.getTotalMedicines(null, true, countMaxDate));

        // ════════════════════════════════════════════
        // THỐNG KÊ DỊCH VỤ (Service Statistics)
        // ════════════════════════════════════════════

        int totalUsage = statsService.getTotalUsage(dateFrom, dateTo);
        double totalRevenue = statsService.getTotalRevenue(dateFrom, dateTo);
        double usageGrowthRate = statsService.getUsageGrowthRate(dateFrom, dateTo);
        String topServiceName = statsService.getTopServiceName(dateFrom, dateTo);
        int topServiceUsage = statsService.getTopServiceUsage(dateFrom, dateTo);
        int servicesUsed = statsService.getServicesUsed(dateFrom, dateTo);

        request.setAttribute("totalUsageToday", totalUsage);
        request.setAttribute("totalRevenueTodayFormatted",
                ServiceStatisticsService.formatCurrency(totalRevenue));
        request.setAttribute("usageGrowthRate", usageGrowthRate);
        request.setAttribute("usageGrowthFormatted",
                ServiceStatisticsService.formatGrowthPercent(usageGrowthRate));
        request.setAttribute("topServiceName", topServiceName);
        request.setAttribute("topServiceUsage", topServiceUsage);
        request.setAttribute("servicesUsedToday", servicesUsed);

        // ── So sánh doanh thu kỳ trước ──
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
                ServiceStatisticsService.formatCurrency(revenuePrevious));
        request.setAttribute("revenueGrowthRate", revenueGrowthRate);
        request.setAttribute("revenueGrowthFormatted",
                ServiceStatisticsService.formatGrowthPercent(revenueGrowthRate));

        // ════════════════════════════════════════════
        // TOP DỊCH VỤ
        // ════════════════════════════════════════════

        request.setAttribute("topServicesToday", statsService.getTopServicesByUsage(5, dateFrom, dateTo));

        // ════════════════════════════════════════════
        // CẢNH BÁO TỒN KHO
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("lowStockMedicines", java.util.Collections.emptyList());
        } else {
            request.setAttribute("lowStockMedicines", medicineService.getLowStockMedicines(10, 5));
        }

        // ════════════════════════════════════════════
        // BIỂU ĐỒ DOANH THU (7 ngày + 12 tháng)
        // ════════════════════════════════════════════

        Map<String, Double> mgrRevenue7Days;
        Map<String, Double> mgrRevenue12Months;
        if (isCustomRange) {
            mgrRevenue7Days = statsService.getRevenueLast7Days(dateTo);
            mgrRevenue12Months = statsService.getRevenueLast12Months(dateTo);
        } else {
            mgrRevenue7Days = statsService.getRevenueLast7Days();
            mgrRevenue12Months = statsService.getRevenueLast12Months();
        }
        request.setAttribute("mgrRevenueChartLabels", mgrRevenue7Days.keySet());
        request.setAttribute("mgrRevenueChartValues", mgrRevenue7Days.values());
        request.setAttribute("mgrRevenue12MonthsLabels", mgrRevenue12Months.keySet());
        request.setAttribute("mgrRevenue12MonthsValues", mgrRevenue12Months.values());

        // ════════════════════════════════════════════
        // BIỂU ĐỒ LỊCH HẸN (Appointments Chart)
        // ════════════════════════════════════════════

        Map<String, Integer> apptChart;
        if (isCustomRange) {
            apptChart = dashboardService.getAppointmentsChartData(dateFrom, dateTo);
        } else {
            apptChart = dashboardService.getAppointmentsChartData();
        }
        request.setAttribute("apptChartLabels", apptChart.keySet());
        request.setAttribute("apptChartValues", apptChart.values());
        request.setAttribute("hasApptData", apptChart.values().stream().anyMatch(v -> v > 0));

        // ════════════════════════════════════════════
        // BẢNG HIỆU SUẤT BÁC SĨ
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("doctorPerformance", dashboardService.getDoctorPerformance(dateFrom, dateTo));
        } else {
            request.setAttribute("doctorPerformance", dashboardService.getDoctorPerformance());
        }

        // ════════════════════════════════════════════
        // LỊCH LÀM VIỆC HÔM NAY
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("todaySchedules", dashboardService.getSchedules(dateTo));
        } else {
            request.setAttribute("todaySchedules", dashboardService.getTodaySchedules());
        }

        // ════════════════════════════════════════════
        // THỐNG KÊ SIÊU ÂM
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("ultrasoundStats", dashboardService.getUltrasoundStats(dateFrom, dateTo));
        } else {
            request.setAttribute("ultrasoundStats", dashboardService.getUltrasoundStats());
        }

        // ════════════════════════════════════════════
        // BỆNH NHÂN MỚI
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("recentPatients", dashboardService.getRecentPatients(8, dateFrom, dateTo));
        } else {
            request.setAttribute("recentPatients", dashboardService.getRecentPatients(8));
        }

        // ════════════════════════════════════════════
        // PHÂN BỐ TRẠNG THÁI LỊCH HẸN (Doughnut)
        // ════════════════════════════════════════════

        try {
            com.clinic.service.ReportService reportService = new com.clinic.service.ReportService();
            if (isCustomRange) {
                request.setAttribute("statusBreakdown",
                    reportService.getStatusBreakdown(dateFrom, dateTo));
            } else {
                request.setAttribute("statusBreakdown",
                    reportService.getStatusBreakdown());
            }
        } catch (Exception e) {
            request.setAttribute("statusBreakdown", java.util.Collections.emptyList());
        }

        // ════════════════════════════════════════════
        // CẢNH BÁO VẬN HÀNH (Operational Alerts)
        // ════════════════════════════════════════════

        if (isCustomRange) {
            request.setAttribute("operationalAlerts",
                dashboardService.getSystemAlerts(dateFrom, dateTo));
        } else {
            request.setAttribute("operationalAlerts",
                dashboardService.getSystemAlerts());
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
}
