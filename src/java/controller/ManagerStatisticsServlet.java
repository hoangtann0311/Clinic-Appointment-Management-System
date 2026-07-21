package controller;

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
import java.util.List;
import java.util.Map;

/**
 * Servlet xử lý trang Thống Kê Dịch Vụ Y Tế cho Manager.
 * Cung cấp dữ liệu KPI, bảng thống kê và biểu đồ trực quan
 * về tình hình sử dụng dịch vụ của phòng khám sản phụ khoa.
 *
 * URL: /manager/statistics/ hoặc /manager/statistics
 */
@WebServlet(urlPatterns = {"/manager/statistics/", "/manager/statistics"})
public class ManagerStatisticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới có quyền truy cập.");
            return;
        }

        // Ngày hiện tại
        LocalDate today = LocalDate.now();
        request.setAttribute("todayDisplay",
                today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));

        // Load toàn bộ dữ liệu thống kê
        loadStatisticsData(request);

        request.getRequestDispatcher("/views/manager/statistics.jsp").forward(request, response);
    }

    /**
     * Tổng hợp toàn bộ dữ liệu thống kê dịch vụ và gán vào request attributes.
     */
    private void loadStatisticsData(HttpServletRequest request) {
        ServiceStatisticsService statsService = new ServiceStatisticsService();

        // ─── KPI CARDS ───
        int totalUsageToday = statsService.getTotalUsageToday();
        double totalRevenueToday = statsService.getTotalRevenueToday();
        double usageGrowthRate = statsService.getUsageGrowthRate();
        double revenueGrowthRate = statsService.getRevenueGrowthRate();
        int activeServiceCount = statsService.getActiveServiceCount();
        int servicesUsedToday = statsService.getServicesUsedToday();
        String topServiceName = statsService.getTopServiceName();
        int topServiceUsage = statsService.getTopServiceUsage();

        request.setAttribute("totalUsageToday", totalUsageToday);
        request.setAttribute("totalRevenueTodayFormatted", ServiceStatisticsService.formatCurrency(totalRevenueToday));
        request.setAttribute("totalRevenueToday", totalRevenueToday);
        request.setAttribute("usageGrowthRate", usageGrowthRate);
        request.setAttribute("usageGrowthFormatted", ServiceStatisticsService.formatGrowthPercent(usageGrowthRate));
        request.setAttribute("revenueGrowthRate", revenueGrowthRate);
        request.setAttribute("revenueGrowthFormatted", ServiceStatisticsService.formatGrowthPercent(revenueGrowthRate));
        request.setAttribute("activeServiceCount", activeServiceCount);
        request.setAttribute("servicesUsedToday", servicesUsedToday);
        request.setAttribute("topServiceName", topServiceName);
        request.setAttribute("topServiceUsage", topServiceUsage);

        // ─── BẢNG THỐNG KÊ CHI TIẾT ───
        List<ServiceStatDetail> allServiceStats = statsService.getAllServiceStats();
        List<ServiceStatDetail> topServicesByUsage = statsService.getTopServicesByUsage(10);
        List<ServiceStatDetail> topServicesByRevenue = statsService.getTopServicesByRevenue(10);
        List<ServiceStatDetail> lowPerformingServices = statsService.getLowPerformingServices();
        List<ServiceStatDetail> topServicesByTotalRevenue = statsService.getTopServicesByTotalRevenue(10);

        request.setAttribute("allServiceStats", allServiceStats);
        request.setAttribute("topServicesByUsage", topServicesByUsage);
        request.setAttribute("topServicesByRevenue", topServicesByRevenue);
        request.setAttribute("lowPerformingServices", lowPerformingServices);
        request.setAttribute("topServicesByTotalRevenue", topServicesByTotalRevenue);

        // ─── BIỂU ĐỒ: Doanh thu 7 ngày ───
        Map<String, Double> revenue7Days = statsService.getRevenueLast7Days();
        request.setAttribute("revenue7DaysLabels", revenue7Days.keySet());
        request.setAttribute("revenue7DaysValues", revenue7Days.values());

        // ─── BIỂU ĐỒ: Lượt sử dụng 7 ngày ───
        Map<String, Integer> usage7Days = statsService.getUsageLast7Days();
        request.setAttribute("usage7DaysLabels", usage7Days.keySet());
        request.setAttribute("usage7DaysValues", usage7Days.values());

        // ─── BIỂU ĐỒ: Doanh thu 12 tháng ───
        Map<String, Double> revenue12Months = statsService.getRevenueLast12Months();
        request.setAttribute("revenue12MonthsLabels", revenue12Months.keySet());
        request.setAttribute("revenue12MonthsValues", revenue12Months.values());

        // ─── BIỂU ĐỒ: Phân bổ doanh thu theo nhóm ───
        List<CategoryRevenueStat> categoryRevenue = statsService.getCategoryRevenueBreakdown();
        request.setAttribute("categoryRevenue", categoryRevenue);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // POST requests không được hỗ trợ trên trang thống kê (chỉ xem)
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Phương thức POST không được hỗ trợ.");
    }
}
