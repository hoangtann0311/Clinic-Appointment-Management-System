package com.clinic.service;

import com.clinic.dao.ReportDAO;
import com.clinic.dao.ReportDAO.DoctorPerformanceReport;
import com.clinic.dao.ReportDAO.ReportSummary;
import com.clinic.dao.ReportDAO.StatusBreakdown;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ báo cáo cho Admin & Manager.
 * Tổng hợp dữ liệu từ ReportDAO, tính toán KPI, format dữ liệu.
 *
 * <p>Tuân thủ kiến trúc: Controller → Service → DAO → Database
 */
public class ReportService {

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    /**
     * Lấy tổng quan KPI cho báo cáo.
     */
    public ReportSummary getSummary(LocalDate from, LocalDate to) {
        try {
            return reportDAO.getSummary(from, to);
        } catch (Exception e) {
            System.err.println("[ReportService] getSummary ERROR: " + e.getMessage());
            return new ReportSummary();
        }
    }

    /**
     * Doanh thu theo từng ngày trong khoảng (cho line chart).
     */
    public Map<String, Double> getDailyRevenue(LocalDate from, LocalDate to) {
        try {
            return reportDAO.getDailyRevenue(from, to);
        } catch (Exception e) {
            System.err.println("[ReportService] getDailyRevenue ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Báo cáo hiệu suất bác sĩ trong khoảng ngày.
     */
    public List<DoctorPerformanceReport> getDoctorPerformance(LocalDate from, LocalDate to) {
        try {
            return reportDAO.getDoctorPerformanceReport(from, to);
        } catch (Exception e) {
            System.err.println("[ReportService] getDoctorPerformance ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Phân bố trạng thái lịch hẹn (cho doughnut chart).
     */
    public List<StatusBreakdown> getStatusBreakdown(LocalDate from, LocalDate to) {
        try {
            return reportDAO.getStatusBreakdown(from, to);
        } catch (Exception e) {
            System.err.println("[ReportService] getStatusBreakdown ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Doanh thu 12 tháng (cho bar chart).
     */
    public Map<String, Double> getRevenue12Months(LocalDate endDate) {
        try {
            return reportDAO.getRevenueLast12Months(endDate);
        } catch (Exception e) {
            System.err.println("[ReportService] getRevenue12Months ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Top dịch vụ sử dụng nhiều nhất (reuse ServiceStatisticsService).
     */
    public List<com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail> getTopServices(
            LocalDate from, LocalDate to, int limit) {
        try {
            com.clinic.dao.ServiceStatisticsDAO statsDAO = new com.clinic.dao.ServiceStatisticsDAO();
            return statsDAO.getTopServicesByUsageDateRange(limit, from, to);
        } catch (Exception e) {
            System.err.println("[ReportService] getTopServices ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ═══════════════════════════════════════════════════════════
    // FORMAT HELPERS
    // ═══════════════════════════════════════════════════════════

    /** Format số tiền sang chuỗi VNĐ. */
    public static String formatCurrency(double amount) {
        if (amount >= 1_000_000_000) {
            return String.format("%.2f Tỷ VNĐ", amount / 1_000_000_000);
        } else if (amount >= 1_000_000) {
            return String.format("%.0f Triệu VNĐ", amount / 1_000_000);
        } else if (amount >= 1_000) {
            return String.format("%,.0f VNĐ", amount);
        }
        return String.format("%,.0f VNĐ", amount);
    }

    /** Format phần trăm. */
    public static String formatPercent(double percent) {
        if (percent > 0) return String.format("+%.1f%%", percent);
        if (percent < 0) return String.format("%.1f%%", percent);
        return "0%";
    }

    /** Map status tiếng Anh → tiếng Việt. */
    public static String translateStatus(String status) {
        if (status == null) return "Không rõ";
        switch (status.toLowerCase()) {
            case "completed":   return "Hoàn Thành";
            case "confirmed":   return "Đã Xác Nhận";
            case "pending":     return "Chờ Xác Nhận";
            case "cancelled":   return "Đã Hủy";
            case "waiting":     return "Đang Chờ";
            case "in_progress": return "Đang Khám";
            default:            return status;
        }
    }
}
