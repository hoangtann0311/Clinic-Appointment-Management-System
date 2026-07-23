package com.clinic.service;

import com.clinic.dao.ServiceStatisticsDAO;
import com.clinic.dao.ServiceStatisticsDAO.CategoryRevenueStat;
import com.clinic.dao.ServiceStatisticsDAO.ServiceStatDetail;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ thống kê dịch vụ y tế cho Manager Dashboard.
 * Tổng hợp dữ liệu từ ServiceStatisticsDAO, tính toán KPI,
 * tốc độ tăng trưởng và định dạng dữ liệu cho biểu đồ.
 *
 * Tuân thủ kiến trúc: Controller → Service → DAO → Database
 */
public class ServiceStatisticsService {

    private final ServiceStatisticsDAO statsDAO;

    public ServiceStatisticsService() {
        this.statsDAO = new ServiceStatisticsDAO();
    }

    // ═══════════════════════════════════════════════════════════
    // KPI TỔNG QUAN — HÔM NAY (mặc định)
    // ═══════════════════════════════════════════════════════════

    /** Tổng số lượt sử dụng dịch vụ hôm nay. */
    public int getTotalUsageToday() {
        try {
            return statsDAO.getTotalUsageToday();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTotalUsageToday ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Tổng doanh thu dịch vụ hôm nay (VND). */
    public double getTotalRevenueToday() {
        try {
            return statsDAO.getTotalRevenueToday();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTotalRevenueToday ERROR: " + e.getMessage());
            return 0.0;
        }
    }

    /** Tổng doanh thu dịch vụ hôm nay — định dạng VNĐ. */
    public String getTotalRevenueTodayFormatted() {
        return formatCurrency(getTotalRevenueToday());
    }

    /** Tổng doanh thu dịch vụ hôm qua (VND). */
    public double getTotalRevenueYesterday() {
        try {
            return statsDAO.getTotalRevenueYesterday();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTotalRevenueYesterday ERROR: " + e.getMessage());
            return 0.0;
        }
    }

    /** Tổng doanh thu dịch vụ hôm qua — định dạng VNĐ. */
    public String getTotalRevenueYesterdayFormatted() {
        return formatCurrency(getTotalRevenueYesterday());
    }

    /** Số dịch vụ đang hoạt động. */
    public int getActiveServiceCount() {
        try {
            return statsDAO.countActiveServices();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getActiveServiceCount ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Số dịch vụ được sử dụng hôm nay. */
    public int getServicesUsedToday() {
        try {
            return statsDAO.countServicesUsedToday();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getServicesUsedToday ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Tốc độ tăng trưởng lượt sử dụng (%): hôm nay so với hôm qua. */
    public double getUsageGrowthRate() {
        try {
            int today = statsDAO.getTotalUsageToday();
            int yesterday = statsDAO.getTotalUsageYesterday();
            if (yesterday == 0 && today == 0) return 0;
            if (yesterday == 0) return 100.0;
            return ((double)(today - yesterday) / yesterday) * 100.0;
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getUsageGrowthRate ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Tốc độ tăng trưởng doanh thu (%): hôm nay so với hôm qua. */
    public double getRevenueGrowthRate() {
        try {
            double today = statsDAO.getTotalRevenueToday();
            double yesterday = statsDAO.getTotalRevenueYesterday();
            if (yesterday == 0 && today == 0) return 0;
            if (yesterday == 0) return 100.0;
            return ((today - yesterday) / yesterday) * 100.0;
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueGrowthRate ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Dịch vụ được sử dụng nhiều nhất hôm nay (tên). */
    public String getTopServiceName() {
        try {
            ServiceStatDetail top = statsDAO.getTopServiceToday();
            return top != null ? top.getServiceName() : "Chưa có dữ liệu";
        } catch (Exception e) {
            return "Chưa có dữ liệu";
        }
    }

    /** Số lượt sử dụng của dịch vụ top 1 hôm nay. */
    public int getTopServiceUsage() {
        try {
            ServiceStatDetail top = statsDAO.getTopServiceToday();
            return top != null ? top.getUsageToday() : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    // ═══════════════════════════════════════════════════════════
    // KPI — LỌC THEO KHOẢNG NGÀY (TỪ NGÀY → ĐẾN NGÀY)
    // ═══════════════════════════════════════════════════════════

    /** Tổng số lượt sử dụng dịch vụ trong khoảng ngày. */
    public int getTotalUsage(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getTotalUsageToday();
        try {
            return statsDAO.getTotalUsageByDateRange(from, to);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTotalUsage(range) ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Tổng doanh thu dịch vụ trong khoảng ngày (VND). */
    public double getTotalRevenue(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getTotalRevenueToday();
        try {
            return statsDAO.getTotalRevenueByDateRange(from, to);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTotalRevenue(range) ERROR: " + e.getMessage());
            return 0.0;
        }
    }

    /** Tổng doanh thu dịch vụ trong khoảng ngày — định dạng VNĐ. */
    public String getTotalRevenueFormatted(java.time.LocalDate from, java.time.LocalDate to) {
        return formatCurrency(getTotalRevenue(from, to));
    }

    /** Số dịch vụ được sử dụng trong khoảng ngày. */
    public int getServicesUsed(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getServicesUsedToday();
        try {
            return statsDAO.countServicesUsedInDateRange(from, to);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getServicesUsed(range) ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Dịch vụ được sử dụng nhiều nhất trong khoảng ngày (tên). */
    public String getTopServiceName(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getTopServiceName();
        try {
            ServiceStatDetail top = statsDAO.getTopServiceByDateRange(from, to);
            return top != null ? top.getServiceName() : "Chưa có dữ liệu";
        } catch (Exception e) {
            return "Chưa có dữ liệu";
        }
    }

    /** Số lượt sử dụng của dịch vụ top 1 trong khoảng ngày. */
    public int getTopServiceUsage(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getTopServiceUsage();
        try {
            ServiceStatDetail top = statsDAO.getTopServiceByDateRange(from, to);
            return top != null ? top.getUsageToday() : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    /** Top N dịch vụ có lượt sử dụng cao nhất trong khoảng ngày. */
    public List<ServiceStatDetail> getTopServicesByUsage(int limit, java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getTopServicesByUsage(limit);
        try {
            return statsDAO.getTopServicesByUsageDateRange(limit, from, to);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTopServicesByUsage(range) ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Tốc độ tăng trưởng lượt sử dụng (%): khoảng ngày so với khoảng trước đó. */
    public double getUsageGrowthRate(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getUsageGrowthRate();
        try {
            int current = statsDAO.getTotalUsageByDateRange(from, to);
            int previous = statsDAO.getTotalUsagePreviousPeriod(from, to);
            if (previous == 0 && current == 0) return 0;
            if (previous == 0) return 100.0;
            return ((double)(current - previous) / previous) * 100.0;
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getUsageGrowthRate(range) ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Tốc độ tăng trưởng doanh thu (%): khoảng ngày so với khoảng trước đó. */
    public double getRevenueGrowthRate(java.time.LocalDate from, java.time.LocalDate to) {
        if (from == null || to == null) return getRevenueGrowthRate();
        try {
            double current = statsDAO.getTotalRevenueByDateRange(from, to);
            double previous = statsDAO.getTotalRevenuePreviousPeriod(from, to);
            if (previous == 0 && current == 0) return 0;
            if (previous == 0) return 100.0;
            return ((current - previous) / previous) * 100.0;
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueGrowthRate(range) ERROR: " + e.getMessage());
            return 0;
        }
    }

    // ═══════════════════════════════════════════════════════════
    // BẢNG THỐNG KÊ CHI TIẾT
    // ═══════════════════════════════════════════════════════════

    /** Danh sách thống kê chi tiết tất cả dịch vụ. */
    public List<ServiceStatDetail> getAllServiceStats() {
        try {
            return statsDAO.getAllServiceStats();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getAllServiceStats ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Top N dịch vụ có lượt sử dụng cao nhất hôm nay. */
    public List<ServiceStatDetail> getTopServicesByUsage(int limit) {
        try {
            return statsDAO.getTopServicesByUsageToday(limit);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTopServicesByUsage ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Top N dịch vụ có doanh thu cao nhất hôm nay. */
    public List<ServiceStatDetail> getTopServicesByRevenue(int limit) {
        try {
            return statsDAO.getTopServicesByRevenueToday(limit);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTopServicesByRevenue ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Danh sách dịch vụ có hiệu suất thấp. */
    public List<ServiceStatDetail> getLowPerformingServices() {
        try {
            return statsDAO.getLowPerformingServices();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getLowPerformingServices ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Top N dịch vụ theo tổng doanh thu mọi thời gian. */
    public List<ServiceStatDetail> getTopServicesByTotalRevenue(int limit) {
        try {
            return statsDAO.getTopServicesByTotalRevenue(limit);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getTopServicesByTotalRevenue ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ═══════════════════════════════════════════════════════════
    // DỮ LIỆU BIỂU ĐỒ
    // ═══════════════════════════════════════════════════════════

    /** Doanh thu 7 ngày gần nhất. Map<ngày, doanh thu>. */
    public Map<String, Double> getRevenueLast7Days() {
        try {
            return statsDAO.getRevenueLast7Days();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueLast7Days ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Doanh thu 7 ngày kết thúc tại endDate. */
    public Map<String, Double> getRevenueLast7Days(LocalDate endDate) {
        try {
            return statsDAO.getRevenueLast7Days(endDate);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueLast7Days(date) ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Doanh thu theo từng ngày trong khoảng được chọn. */
    public Map<String, Double> getDailyRevenue(LocalDate startDate, LocalDate endDate) {
        try {
            return statsDAO.getDailyRevenue(startDate, endDate);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getDailyRevenue ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Lượt sử dụng 7 ngày gần nhất. Map<ngày, số lượt>. */
    public Map<String, Integer> getUsageLast7Days() {
        try {
            return statsDAO.getUsageLast7Days();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getUsageLast7Days ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Doanh thu 12 tháng gần nhất. Map<tháng, doanh thu>. */
    public Map<String, Double> getRevenueLast12Months() {
        try {
            return statsDAO.getRevenueLast12Months();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueLast12Months ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Doanh thu 12 tháng kết thúc tại endDate. */
    public Map<String, Double> getRevenueLast12Months(LocalDate endDate) {
        try {
            return statsDAO.getRevenueLast12Months(endDate);
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getRevenueLast12Months(date) ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Phân bổ doanh thu theo nhóm dịch vụ. */
    public List<CategoryRevenueStat> getCategoryRevenueBreakdown() {
        try {
            return statsDAO.getCategoryRevenueBreakdown();
        } catch (Exception e) {
            System.err.println("[ServiceStatisticsService] getCategoryRevenueBreakdown ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════

    /**
     * Format số tiền sang chuỗi VNĐ hiển thị trên KPI card.
     */
    public static String formatCurrency(double amount) {
        if (amount >= 1_000_000_000) {
            return String.format("%.2f Tỷ", amount / 1_000_000_000);
        } else if (amount >= 1_000_000) {
            return String.format("%.0f Triệu", amount / 1_000_000);
        } else if (amount >= 1_000) {
            return String.format("%,.0f", amount);
        }
        return String.format("%,.0f", amount);
    }

    /**
     * Format phần trăm tăng trưởng với dấu +/− và màu sắc.
     */
    public static String formatGrowthPercent(double percent) {
        if (percent > 0) {
            return String.format("+%.1f%%", percent);
        } else if (percent < 0) {
            return String.format("%.1f%%", percent);
        }
        return "0%";
    }
}
