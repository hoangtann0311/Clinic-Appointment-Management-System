package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.User;
import com.clinic.service.AdminDashboardService;
import com.clinic.service.DashboardService;
import com.clinic.service.PatientBookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
        ROLE_NAMES.put(6, "Bác sĩ siêu âm");
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
        request.setAttribute("dashboardTitle", "Tổng Quan " + roleName);

        // Ngày hiện tại cho hiển thị
        LocalDate today = LocalDate.now();
        request.setAttribute("todayDisplay",
                today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));

        // Route đến dashboard JSP tương ứng với role
        String path = request.getRequestURI().substring(request.getContextPath().length());

        switch (roleId) {
            case 1:
                if (!"/admin/dashboard".equals(path)) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                }
                loadAdminDashboardData(request);
                request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
                break;
            case 2:
                response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
                break;
            case 3:
                if (!"/manager/dashboard".equals(path)) {
                    response.sendRedirect(request.getContextPath() + "/manager/dashboard");
                    return;
                }
                loadManagerDashboardData(request);
                request.getRequestDispatcher("/views/manager/dashboard.jsp").forward(request, response);
                break;
            case 4:
                response.sendRedirect(request.getContextPath() + "/admin/reception");
                break;
            case 6:
                loadSonographerDashboardData(request);
                request.getRequestDispatcher("/views/sonographer/dashboard.jsp").forward(request, response);
                break;
            case 5:
            default:
                loadPatientDashboardData(request, user.getId());
                request.getRequestDispatcher("/views/home/dashboard.jsp").forward(request, response);
                break;
        }
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
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
            LocalDate swap = dateFrom;
            dateFrom = dateTo;
            dateTo = swap;
        }
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

        // ─── KPI dịch vụ cốt lõi — theo khoảng ngày ───
        int totalUsage = statsService.getTotalUsage(dateFrom, dateTo);
        double totalRevenue = statsService.getTotalRevenue(dateFrom, dateTo);

        request.setAttribute("totalUsageToday", totalUsage);
        request.setAttribute("totalRevenueTodayFormatted",
                com.clinic.service.ServiceStatisticsService.formatCurrency(totalRevenue));

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

        // Revenue KPI label — phản ánh đúng khoảng ngày đã chọn
        String kpiLabel;
        if (!isCustomRange || (dateFrom.equals(today) && dateTo.equals(today))) {
            kpiLabel = "Doanh Thu Hôm Nay";
        } else if (dateFrom.equals(dateTo)) {
            kpiLabel = "Doanh Thu (Ngày " + dateFrom.format(dateFmt) + ")";
        } else {
            kpiLabel = "Doanh Thu (" + dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt) + ")";
        }
        request.setAttribute("revenueKpiLabel", kpiLabel);

        DashboardService dashboardService = new DashboardService();

        int totalPatients = isCustomRange
                ? dashboardService.getTotalPatients(dateFrom, dateTo)
                : dashboardService.getTotalPatients();
        int totalAppointments = isCustomRange
                ? dashboardService.getTotalAppointments(dateFrom, dateTo)
                : dashboardService.getTotalAppointments();
        int waitingPatients = isCustomRange
                ? dashboardService.getWaitingPatients(dateFrom, dateTo)
                : dashboardService.getWaitingPatients();
        int doctorsWorking = isCustomRange
                ? dashboardService.getDoctorsWorking(dateTo)
                : dashboardService.getDoctorsWorkingToday();
        int ultrasoundCases = isCustomRange
                ? dashboardService.getUltrasound(dateFrom, dateTo)
                : dashboardService.getUltrasoundAll();
        double revenueRaw = isCustomRange
                ? dashboardService.getRevenueRaw(dateFrom, dateTo)
                : dashboardService.getRevenueAllRaw();
        int completedCases = isCustomRange
                ? dashboardService.getSuccessfulCases(dateFrom, dateTo)
                : dashboardService.getSuccessfulCasesAll();
        int newPatients = isCustomRange
                ? dashboardService.getTotalPatients(dateFrom, dateTo)
                : dashboardService.getTotalPatients(today, today);

        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("waitingPatients", waitingPatients);
        request.setAttribute("doctorsWorking", doctorsWorking);
        request.setAttribute("ultrasoundCases", ultrasoundCases);
        request.setAttribute("revenue", DashboardService.formatCurrency(revenueRaw));
        request.setAttribute("completedCases", completedCases);
        request.setAttribute("newPatients", newPatients);

        // Doanh thu (từ ServiceStatisticsService — đồng bộ với biểu đồ, theo khoảng ngày)
        request.setAttribute("revenueToday",
                com.clinic.service.ServiceStatisticsService.formatCurrency(totalRevenue));

        // Biểu đồ doanh thu 7 ngày
        Map<String, Double> revenueChart = isCustomRange
                ? statsService.getDailyRevenue(dateFrom, dateTo)
                : statsService.getRevenueLast7Days();
        request.setAttribute("mgrRevenueChartLabels", revenueChart.keySet());
        request.setAttribute("mgrRevenueChartValues", revenueChart.values());

        // Biểu đồ doanh thu 30 ngày
        Map<String, Double> revenue30 = statsService.getDailyRevenue(today.minusDays(29), today);
        request.setAttribute("mgrRevenue30Labels", new ArrayList<>(revenue30.keySet()));
        request.setAttribute("mgrRevenue30Values", new ArrayList<>(revenue30.values()));

        request.setAttribute("todaySchedules", isCustomRange
                ? dashboardService.getSchedules(dateTo)
                : dashboardService.getTodaySchedules());

        // ─── Thống kê dịch vụ (theo khoảng ngày) ───
        request.setAttribute("topServicesByUsage", statsService.getTopServicesByUsage(8, dateFrom, dateTo));
        request.setAttribute("topServicesByRevenue", isCustomRange
                ? statsService.getTopServicesByTotalRevenue(8, dateFrom, dateTo)
                : statsService.getTopServicesByTotalRevenue(8));
        request.setAttribute("categoryRevenueBreakdown", statsService.getCategoryRevenueBreakdown());
        Map<String, Integer> usageDays = isCustomRange
                ? statsService.getDailyUsage(dateFrom, dateTo)
                : statsService.getUsageLast7Days();
        request.setAttribute("serviceUsageLast7DaysLabels", new ArrayList<>(usageDays.keySet()));
        request.setAttribute("serviceUsageLast7DaysValues", new ArrayList<>(usageDays.values()));

        // ─── Dữ liệu biểu đồ lịch hẹn ───
        Map<String, Integer> apptTrend = isCustomRange
                ? dashboardService.getAppointmentsChartData(dateFrom, dateTo)
                : dashboardService.getAppointmentsChartData();
        request.setAttribute("mgrApptChartLabels", new ArrayList<>(apptTrend.keySet()));
        request.setAttribute("mgrApptChartValues", new ArrayList<>(apptTrend.values()));

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
        AdminDashboardService adminDashboardService = new AdminDashboardService();
        LocalDate today = LocalDate.now();
        LocalDate dateFrom = parseDashboardDate(request.getParameter("dateFrom"));
        LocalDate dateTo = parseDashboardDate(request.getParameter("dateTo"));

        if (dateFrom != null && dateFrom.isAfter(today)) {
            dateFrom = today;
        }
        if (dateTo != null && dateTo.isAfter(today)) {
            dateTo = today;
        }
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
            LocalDate swap = dateFrom;
            dateFrom = dateTo;
            dateTo = swap;
        }

        boolean isCustomRange = dateFrom != null || dateTo != null;
        if (dateFrom == null) {
            dateFrom = today;
        }
        if (dateTo == null) {
            dateTo = today;
        }

        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String dateRangeLabel = dateFrom.equals(dateTo)
                ? "Ngày " + dateFrom.format(dateFormatter)
                : dateFrom.format(dateFormatter) + " → " + dateTo.format(dateFormatter);

        request.setAttribute("today", today);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("isCustomRange", isCustomRange);
        request.setAttribute("dateRangeLabel", dateRangeLabel);
        request.setAttribute("subtitleDisplay", isCustomRange ? dateRangeLabel : "Hôm nay");

        // totalAccounts: tài khoản MỚI TẠO trong khoảng (có ý nghĩa time-bound)
        request.setAttribute("totalAccounts", isCustomRange
                ? adminDashboardService.getTotalAccounts(dateFrom, dateTo)
                : adminDashboardService.getTotalAccounts());

        // activeAccounts: người dùng THỰC SỰ HOẠT ĐỘNG (có login) trong khoảng
        request.setAttribute("activeAccounts", isCustomRange
                ? adminDashboardService.getActiveUsersInRange(dateFrom, dateTo)
                : adminDashboardService.getActiveAccounts());

        // lockedAccounts & unverifiedAccounts: trạng thái HIỆN TẠI (không phụ thuộc khoảng ngày)
        request.setAttribute("lockedAccounts", adminDashboardService.getLockedAccounts());
        request.setAttribute("unverifiedAccounts", adminDashboardService.getUnverifiedAccounts());

        // loginsToday & auditLogsToday & accessDenied: sự kiện trong khoảng
        request.setAttribute("loginsToday", isCustomRange
                ? adminDashboardService.getLogins(dateFrom, dateTo)
                : adminDashboardService.getLoginsToday());
        request.setAttribute("auditLogsToday", isCustomRange
                ? adminDashboardService.getAuditLogs(dateFrom, dateTo)
                : adminDashboardService.getAuditLogsToday());
        request.setAttribute("accessDeniedToday", isCustomRange
                ? adminDashboardService.getAccessDenied(dateFrom, dateTo)
                : adminDashboardService.getAccessDeniedToday());

        Map<String, Integer> loginTrend = isCustomRange
                ? adminDashboardService.getLoginTrend(dateFrom, dateTo)
                : adminDashboardService.getLoginTrend7Days();
        Map<String, Integer> accountGrowth = isCustomRange
                ? adminDashboardService.getAccountGrowthByDay(dateFrom, dateTo)
                : adminDashboardService.getAccountGrowth12Months();
        Map<String, Integer> roleDistribution = isCustomRange
                ? adminDashboardService.getRoleDistribution(dateFrom, dateTo)
                : adminDashboardService.getRoleDistribution();
        Map<String, Integer> auditClassification = isCustomRange
                ? adminDashboardService.getAuditLogClassification(dateFrom, dateTo)
                : adminDashboardService.getAuditLogClassification();

        request.setAttribute("loginTrendLabels", loginTrend.keySet());
        request.setAttribute("loginTrendValues", loginTrend.values());
        request.setAttribute("accountGrowthLabels", accountGrowth.keySet());
        request.setAttribute("accountGrowthValues", accountGrowth.values());
        request.setAttribute("roleDistributionLabels", roleDistribution.keySet());
        request.setAttribute("roleDistributionValues", roleDistribution.values());
        request.setAttribute("auditClassLabels", auditClassification.keySet());
        request.setAttribute("auditClassValues", auditClassification.values());
        request.setAttribute("hasLoginTrendData", loginTrend.values().stream().anyMatch(value -> value > 0));
        request.setAttribute("hasAccountGrowthData", accountGrowth.values().stream().anyMatch(value -> value > 0));
        request.setAttribute("hasRoleDistData", roleDistribution.values().stream().anyMatch(value -> value > 0));
        request.setAttribute("hasAuditClassData", auditClassification.values().stream().anyMatch(value -> value > 0));

        request.setAttribute("recentUsers", isCustomRange
                ? adminDashboardService.getRecentUsers(10, dateFrom, dateTo)
                : adminDashboardService.getRecentUsers(10));
        request.setAttribute("recentAuditLogs", isCustomRange
                ? adminDashboardService.getRecentAuditLogs(10, dateFrom, dateTo)
                : adminDashboardService.getRecentAuditLogs(10));
        request.setAttribute("systemAlerts", isCustomRange
                ? adminDashboardService.getSystemAlerts(dateFrom, dateTo)
                : adminDashboardService.getSystemAlerts());
    }

    private LocalDate parseDashboardDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value);
        } catch (RuntimeException ignored) {
            return null;
        }
    }
    private void loadSonographerDashboardData(HttpServletRequest request) {
        com.clinic.service.UltrasoundOrderService orderService = new com.clinic.service.UltrasoundOrderService();

        String dateParameter = request.getParameter("date");
        LocalDate selectedDate = parseDashboardDate(dateParameter);
        if (selectedDate == null) {
            selectedDate = LocalDate.now();
        }

        String filterDate = selectedDate.toString();
        int pending = orderService.countOrders(null, "Pending", filterDate, null);
        int inProgress = orderService.countOrders(null, "InProgress", filterDate, null);
        int uploaded = orderService.countOrders(null, "Uploaded", filterDate, null);
        int completed = orderService.countOrders(null, "Completed", filterDate, null)
                + orderService.countOrders(null, "confirmed", filterDate, null);
        int emergency = orderService.countOrders(null, null, filterDate, true);

        List<com.clinic.model.UltrasoundWaitingPatient> recentOrders =
                orderService.getOrders(1, 10, null, null, filterDate, null, "createdAt", "desc");

        request.setAttribute("totalPending", pending);
        request.setAttribute("totalInProgress", inProgress);
        request.setAttribute("totalUploaded", uploaded);
        request.setAttribute("totalCompletedToday", completed);
        request.setAttribute("totalEmergencyToday", emergency);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("selectedDate", filterDate);
        request.setAttribute("displayDate",
                selectedDate.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));
        request.setAttribute("currentDisplayDate", LocalDate.now().toString());
    }

    private void loadPatientDashboardData(HttpServletRequest request, int userId) {
        try {
            PatientBookingService bookingService = new PatientBookingService();
            List<Appointment> appointments = bookingService.getMyAppointments(userId);
            LocalDate today = LocalDate.now();

            List<Appointment> upcoming = appointments.stream()
                    .filter(appointment -> {
                        String status = appointment.getStatus();
                        return ("Pending".equals(status) || "Confirmed".equals(status)
                                || "Waiting".equals(status))
                                && appointment.getAppointmentDate() != null
                                && !appointment.getAppointmentDate().isBefore(today);
                    })
                    .sorted((left, right) -> {
                        if (left.getAppointmentDate() == null) {
                            return 1;
                        }
                        if (right.getAppointmentDate() == null) {
                            return -1;
                        }
                        return left.getAppointmentDate().compareTo(right.getAppointmentDate());
                    })
                    .collect(Collectors.toList());

            request.setAttribute("upcomingAppts", upcoming);
            request.setAttribute("upcomingAppointment", upcoming.isEmpty() ? null : upcoming.get(0));
        } catch (Exception e) {
            request.setAttribute("upcomingAppts", List.of());
            request.setAttribute("upcomingAppointment", null);
        }
    }

}
