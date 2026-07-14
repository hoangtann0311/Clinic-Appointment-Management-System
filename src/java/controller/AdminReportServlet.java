package controller;

import com.clinic.dao.ReportDAO.DoctorPerformanceReport;
import com.clinic.dao.ReportDAO.ReportSummary;
import com.clinic.dao.ReportDAO.StatusBreakdown;
import com.clinic.model.User;
import com.clinic.service.ReportService;
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
 * Servlet xử lý trang Báo Cáo cho Admin & Manager.
 * Cung cấp dữ liệu tổng hợp: doanh thu, hiệu suất BS, top dịch vụ,
 * phân bố trạng thái, ca cấp cứu.
 *
 * <p>URL Patterns: /admin/reports, /manager/reports
 * <p>Permission required: report.view
 */
@WebServlet(urlPatterns = {"/admin/reports/", "/admin/reports",
                            "/manager/reports/", "/manager/reports"})
public class AdminReportServlet extends HttpServlet {

    private ReportService reportService;

    @Override
    public void init() throws ServletException {
        reportService = new ReportService();
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

        // ── Đọc tham số lọc khoảng ngày ──
        String dateFromStr = request.getParameter("dateFrom");
        String dateToStr = request.getParameter("dateTo");
        LocalDate today = LocalDate.now();
        LocalDate dateFrom;
        LocalDate dateTo;

        try {
            dateFrom = (dateFromStr != null && !dateFromStr.trim().isEmpty())
                    ? LocalDate.parse(dateFromStr) : today.minusDays(30);
        } catch (Exception e) {
            dateFrom = today.minusDays(30);
        }
        try {
            dateTo = (dateToStr != null && !dateToStr.trim().isEmpty())
                    ? LocalDate.parse(dateToStr) : today;
        } catch (Exception e) {
            dateTo = today;
        }

        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        // ── Tổng quan KPI ──
        ReportSummary summary = reportService.getSummary(dateFrom, dateTo);
        request.setAttribute("summary", summary);
        request.setAttribute("totalRevenueFormatted", ReportService.formatCurrency(summary.getTotalRevenue()));
        request.setAttribute("completionRateFormatted", String.format("%.1f%%", summary.getCompletionRate()));

        // ── Biểu đồ doanh thu theo ngày ──
        Map<String, Double> dailyRevenue = reportService.getDailyRevenue(dateFrom, dateTo);
        request.setAttribute("dailyRevenueLabels", dailyRevenue.keySet());
        request.setAttribute("dailyRevenueValues", dailyRevenue.values());

        // ── Phân bố trạng thái ──
        List<StatusBreakdown> statusBreakdown = reportService.getStatusBreakdown(dateFrom, dateTo);
        request.setAttribute("statusBreakdown", statusBreakdown);

        // ── Hiệu suất bác sĩ ──
        List<DoctorPerformanceReport> doctorPerformance = reportService.getDoctorPerformance(dateFrom, dateTo);
        request.setAttribute("doctorPerformance", doctorPerformance);

        // ── Top dịch vụ ──
        List<com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail> topServices =
                reportService.getTopServices(dateFrom, dateTo, 10);
        request.setAttribute("topServices", topServices);

        // ── Doanh thu 12 tháng ──
        Map<String, Double> revenue12Months = reportService.getRevenue12Months(dateTo);
        request.setAttribute("revenue12MonthsLabels", revenue12Months.keySet());
        request.setAttribute("revenue12MonthsValues", revenue12Months.values());

        // ── Filter state ──
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("dateFromFormatted", dateFrom.format(dateFmt));
        request.setAttribute("dateToFormatted", dateTo.format(dateFmt));
        request.setAttribute("today", today);
        request.setAttribute("todayDisplay", today.format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));
        request.setAttribute("roleId", roleId);

        // ── Forward đến JSP theo role ──
        String jspPath;
        switch (roleId) {
            case 1: jspPath = "/views/admin/reports/index.jsp"; break;
            case 3: jspPath = "/views/manager/reports/index.jsp"; break;
            default: response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }
        request.getRequestDispatcher(jspPath).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
