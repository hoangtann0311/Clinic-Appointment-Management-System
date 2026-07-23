package com.clinic.controller;

import com.clinic.dao.ServiceStatisticsDAO.CategoryRevenueStat;
import com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail;
import com.clinic.model.User;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Servlet Thống Kê Dịch Vụ cho Manager.
 *
 * GET → hiển thị trang thống kê dịch vụ (KPI, biểu đồ, bảng xếp hạng)
 *      Hỗ trợ lọc theo khoảng ngày: ?dateFrom=yyyy-MM-dd&dateTo=yyyy-MM-dd
 */
@WebServlet(urlPatterns = {"/manager/statistics/", "/manager/statistics"})
public class ManagerStatisticsServlet extends HttpServlet {

    private ServiceStatisticsService statsService;

    @Override
    public void init() throws ServletException {
        statsService = new ServiceStatisticsService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // AuthorizationFilter đã kiểm tra quyền — không cần check thủ công

        // ── Đọc tham số lọc khoảng ngày ──
        String dateFromStr = req.getParameter("dateFrom");
        String dateToStr = req.getParameter("dateTo");
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
            if (dateFrom == null) dateFrom = today;
            if (dateTo == null) dateTo = today;
        }

        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        req.setAttribute("dateFrom", dateFrom);
        req.setAttribute("dateTo", dateTo);
        req.setAttribute("isCustomRange", isCustomRange);
        req.setAttribute("today", today);
        req.setAttribute("dateFromFormatted", dateFrom.format(dateFmt));
        req.setAttribute("dateToFormatted", dateTo.format(dateFmt));

        if (!isCustomRange || (dateFrom.equals(today) && dateTo.equals(today))) {
            req.setAttribute("dateRangeLabel", "Hôm nay");
        } else if (dateFrom.equals(dateTo)) {
            req.setAttribute("dateRangeLabel", "Ngày " + dateFrom.format(dateFmt));
        } else {
            req.setAttribute("dateRangeLabel",
                    dateFrom.format(dateFmt) + " → " + dateTo.format(dateFmt));
        }
        req.setAttribute("todayDisplay", today.format(dateFmt));

        // ══════════════════════════════════════════════════
        // KPI TỔNG QUAN
        // ══════════════════════════════════════════════════
        int totalUsage = statsService.getTotalUsage(dateFrom, dateTo);
        double totalRevenue = statsService.getTotalRevenue(dateFrom, dateTo);
        int servicesUsed = statsService.getServicesUsed(dateFrom, dateTo);
        int activeServiceCount = statsService.getActiveServiceCount();

        double revenuePrevious;
        double revenueGrowthRate;
        if (isCustomRange) {
            long days = dateTo.toEpochDay() - dateFrom.toEpochDay() + 1;
            revenuePrevious = statsService.getTotalRevenue(
                    dateFrom.minusDays(days), dateFrom.minusDays(1));
            revenueGrowthRate = statsService.getRevenueGrowthRate(dateFrom, dateTo);
        } else {
            revenuePrevious = statsService.getTotalRevenueYesterday();
            revenueGrowthRate = statsService.getRevenueGrowthRate();
        }

        req.setAttribute("totalUsage", totalUsage);
        req.setAttribute("totalRevenue", ServiceStatisticsService.formatCurrency(totalRevenue));
        req.setAttribute("totalRevenueRaw", totalRevenue);
        req.setAttribute("servicesUsed", servicesUsed);
        req.setAttribute("activeServiceCount", activeServiceCount);
        req.setAttribute("revenueYesterdayFormatted",
                ServiceStatisticsService.formatCurrency(revenuePrevious));
        req.setAttribute("revenueGrowthRate", revenueGrowthRate);
        req.setAttribute("revenueGrowthFormatted",
                ServiceStatisticsService.formatGrowthPercent(revenueGrowthRate));

        // ══════════════════════════════════════════════════
        // BẢNG XẾP HẠNG
        // ══════════════════════════════════════════════════
        List<ServiceStatDetail> topByUsage = statsService.getTopServicesByUsage(10, dateFrom, dateTo);
        List<ServiceStatDetail> topByRevenue = statsService.getTopServicesByTotalRevenue(10);
        List<ServiceStatDetail> allServiceStats = statsService.getAllServiceStats();
        List<ServiceStatDetail> lowPerforming = statsService.getLowPerformingServices();

        req.setAttribute("topByUsage", topByUsage);
        req.setAttribute("topByRevenue", topByRevenue);
        req.setAttribute("allServiceStats", allServiceStats);
        req.setAttribute("lowPerforming", lowPerforming);

        // ══════════════════════════════════════════════════
        // DỮ LIỆU BIỂU ĐỒ
        // ══════════════════════════════════════════════════
        Map<String, Double> revenueChart = isCustomRange
                ? statsService.getDailyRevenue(dateFrom, dateTo)
                : statsService.getRevenueLast7Days();
        req.setAttribute("revenueChartLabels", new ArrayList<>(revenueChart.keySet()));
        req.setAttribute("revenueChartValues", new ArrayList<>(revenueChart.values()));

        Map<String, Integer> usageChart = statsService.getUsageLast7Days();
        req.setAttribute("usageChartLabels", new ArrayList<>(usageChart.keySet()));
        req.setAttribute("usageChartValues", new ArrayList<>(usageChart.values()));

        Map<String, Double> monthlyRevenue = statsService.getRevenueLast12Months();
        req.setAttribute("monthlyRevenueLabels", new ArrayList<>(monthlyRevenue.keySet()));
        req.setAttribute("monthlyRevenueValues", new ArrayList<>(monthlyRevenue.values()));

        List<CategoryRevenueStat> categoryBreakdown = statsService.getCategoryRevenueBreakdown();
        req.setAttribute("categoryBreakdown", categoryBreakdown);

        // Top service name for display
        req.setAttribute("topServiceName", statsService.getTopServiceName(dateFrom, dateTo));
        req.setAttribute("topServiceUsage", statsService.getTopServiceUsage(dateFrom, dateTo));

        req.getRequestDispatcher("/views/manager/statistics.jsp").forward(req, resp);
    }
}
