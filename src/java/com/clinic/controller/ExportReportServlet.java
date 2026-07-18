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
 * Servlet xuất báo cáo CSV (Excel-compatible) cho Admin & Manager.
 * Gọi từ nút "Xuất Báo Cáo" trên Dashboard.
 *
 * <p>URL Pattern: /export/reports
 * <p>Permission required: report.view (kiểm tra qua AuthorizationFilter)
 */
@WebServlet("/export/reports")
public class ExportReportServlet extends HttpServlet {

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

        // ── Xuất CSV ──
        handleExportCsv(request, response, dateFrom, dateTo, user);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ═══════════════════════════════════════════════════════════
    // EXPORT CSV (Excel-compatible UTF-8 BOM)
    // ═══════════════════════════════════════════════════════════

    /**
     * Xuất báo cáo dạng CSV (tương thích Excel với BOM UTF-8).
     * Xuất đầy đủ: KPI tổng quan, hiệu suất bác sĩ, top dịch vụ,
     * doanh thu theo ngày, phân bố trạng thái.
     */
    private void handleExportCsv(HttpServletRequest request, HttpServletResponse response,
                                  LocalDate dateFrom, LocalDate dateTo, User user)
            throws IOException {
        String fileName = "BaoCao_CAMS_" + dateFrom + "_den_" + dateTo + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setCharacterEncoding("UTF-8");

        // Ghi audit log
        try {
            com.clinic.utils.AuditUtil.log(request,
                "Xuất báo cáo CSV: " + dateFrom + " → " + dateTo,
                "reports", null, null);
        } catch (Exception e) { /* ignore */ }

        java.io.PrintWriter out = response.getWriter();
        // BOM cho Excel nhận diện UTF-8
        out.print('﻿');

        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        // ── Section 1: KPI Tổng Quan ──
        ReportSummary summary = reportService.getSummary(dateFrom, dateTo);
        out.println("=== BAO CAO TONG QUAN ===");
        out.println("Khoang thoi gian:," + dateFrom.format(dateFmt) + " -> " + dateTo.format(dateFmt));
        out.println();
        out.println("Chi so,Gia tri");
        out.println("Tong Doanh Thu," + String.format("%.0f", summary.getTotalRevenue()));
        out.println("Tong Lich Hen," + summary.getTotalAppointments());
        out.println("Ca Hoan Thanh," + summary.getCompletedAppointments());
        out.println("Ca Cap Cuu," + summary.getEmergencyCases());
        out.println("Ca Thanh Cong," + summary.getSuccessCases());
        out.println("Ti Le Hoan Thanh," + String.format("%.1f%%", summary.getCompletionRate()));
        out.println();
        out.println();

        // ── Section 2: Doanh Thu Theo Ngay ──
        Map<String, Double> dailyRevenue = reportService.getDailyRevenue(dateFrom, dateTo);
        out.println("=== DOANH THU THEO NGAY ===");
        out.println("Ngay,Doanh Thu (VND)");
        for (Map.Entry<String, Double> entry : dailyRevenue.entrySet()) {
            out.println(entry.getKey() + "," + String.format("%.0f", entry.getValue()));
        }
        out.println();
        out.println();

        // ── Section 3: Hieu Suat Bac Si ──
        List<DoctorPerformanceReport> doctorPerf = reportService.getDoctorPerformance(dateFrom, dateTo);
        out.println("=== HIEU SUAT BAC SI ===");
        out.println("Bac Si,Chuyen Khoa,Tong Ca,Hoan Thanh,BN Duy Nhat,Ti Le HT (%),Doanh Thu (VND)");
        for (DoctorPerformanceReport doc : doctorPerf) {
            out.println("\"" + csvEscape(doc.getDoctorName()) + "\","
                + "\"" + csvEscape(doc.getSpecialization()) + "\","
                + doc.getTotalAppointments() + ","
                + doc.getCompletedAppointments() + ","
                + doc.getUniquePatients() + ","
                + String.format("%.1f", doc.getCompletionRate()) + ","
                + String.format("%.0f", doc.getTotalRevenue()));
        }
        out.println();
        out.println();

        // ── Section 4: Top Dich Vu ──
        List<com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail> topServices =
                reportService.getTopServices(dateFrom, dateTo, 20);
        out.println("=== TOP DICH VU ===");
        out.println("STT,Dich Vu,Luot Su Dung,Doanh Thu (VND)");
        int rank = 1;
        for (com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail svc : topServices) {
            out.println(rank++ + ","
                + "\"" + csvEscape(svc.getServiceName()) + "\","
                + svc.getUsageToday() + ","
                + String.format("%.0f", svc.getRevenueToday()));
        }
        out.println();
        out.println();

        // ── Section 5: Phan Bo Trang Thai ──
        List<StatusBreakdown> statusBreakdown = reportService.getStatusBreakdown(dateFrom, dateTo);
        out.println("=== PHAN BO TRANG THAI LICH HEN ===");
        out.println("Trang Thai,So Luong");
        for (StatusBreakdown sb : statusBreakdown) {
            out.println(ReportService.translateStatus(sb.getStatus()) + "," + sb.getCount());
        }
        out.println();
        out.println();

        // ── Footer ──
        out.println("\"Bao cao duoc xuat boi: " + csvEscape(user.getFullName())
            + " (" + csvEscape(user.getEmail()) + ")\",\"Ngay xuat: "
            + LocalDate.now().format(dateFmt) + "\"");
        out.println("\"(c) Clinic Appointment Management System (CAMS)\",\"\"");
    }

    /** Escape CSV field. */
    private String csvEscape(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }
}
