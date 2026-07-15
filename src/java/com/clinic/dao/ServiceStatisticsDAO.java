package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Service;

import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO thống kê dịch vụ y tế cho Manager Dashboard.
 * Tổng hợp dữ liệu từ lịch hẹn, hóa đơn và chỉ định dịch vụ
 * để tính toán số lượt sử dụng, doanh thu và tốc độ tăng trưởng.
 *
 * Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class ServiceStatisticsDAO {

    // ═══════════════════════════════════════════════════════════
    // KPI — TỔNG QUAN HÔM NAY
    // ═══════════════════════════════════════════════════════════

    /**
     * Tổng số lượt sử dụng dịch vụ trong ngày hôm nay.
     * Đếm appointment có service_id không null trong hôm nay.
     */
    public int getTotalUsageToday() {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE service_id IS NOT NULL "
                   + "AND appointment_date = CAST(GETDATE() AS DATE)";
        return executeCount(sql);
    }

    /**
     * Tổng số lượt sử dụng dịch vụ ngày hôm qua.
     * Dùng để tính tốc độ tăng trưởng.
     */
    public int getTotalUsageYesterday() {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE service_id IS NOT NULL "
                   + "AND appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))";
        return executeCount(sql);
    }

    /**
     * Tổng doanh thu từ dịch vụ trong ngày hôm nay (VND).
     * Tính từ invoice_items có item_type = 'service' + invoice đã thanh toán.
     */
    public double getTotalRevenueToday() {
        String sql = "SELECT ISNULL(SUM(ii.subtotal), 0) AS total "
                   + "FROM invoice_items ii "
                   + "INNER JOIN invoices i ON ii.invoice_id = i.id "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE ii.item_type = 'service' "
                   + "AND i.status = 'paid' "
                   + "AND a.appointment_date = CAST(GETDATE() AS DATE)";
        return executeSum(sql);
    }

    /**
     * Tổng doanh thu từ dịch vụ ngày hôm qua.
     */
    public double getTotalRevenueYesterday() {
        String sql = "SELECT ISNULL(SUM(ii.subtotal), 0) AS total "
                   + "FROM invoice_items ii "
                   + "INNER JOIN invoices i ON ii.invoice_id = i.id "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE ii.item_type = 'service' "
                   + "AND i.status = 'paid' "
                   + "AND a.appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))";
        return executeSum(sql);
    }

    /**
     * Số dịch vụ đang hoạt động.
     */
    public int countActiveServices() {
        String sql = "SELECT COUNT(*) AS total FROM services WHERE is_active = 1";
        return executeCount(sql);
    }

    /**
     * Số dịch vụ có ít nhất 1 lượt sử dụng hôm nay.
     */
    public int countServicesUsedToday() {
        String sql = "SELECT COUNT(DISTINCT service_id) AS total FROM appointments "
                   + "WHERE service_id IS NOT NULL "
                   + "AND appointment_date = CAST(GETDATE() AS DATE)";
        return executeCount(sql);
    }

    // ═══════════════════════════════════════════════════════════
    // KPI — LỌC THEO KHOẢNG NGÀY (TỪ NGÀY → ĐẾN NGÀY)
    // ═══════════════════════════════════════════════════════════

    /**
     * Tổng số lượt sử dụng dịch vụ trong khoảng ngày [from, to].
     */
    public int getTotalUsageByDateRange(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE service_id IS NOT NULL "
                   + "AND appointment_date >= ? AND appointment_date <= ?";
        return executeCountWithDates(sql, from, to);
    }

    /**
     * Tổng doanh thu dịch vụ trong khoảng ngày [from, to] (VND).
     */
    public double getTotalRevenueByDateRange(LocalDate from, LocalDate to) {
        String sql = "SELECT ISNULL(SUM(ii.subtotal), 0) AS total "
                   + "FROM invoice_items ii "
                   + "INNER JOIN invoices i ON ii.invoice_id = i.id "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE ii.item_type = 'service' "
                   + "AND i.status = 'paid' "
                   + "AND a.appointment_date >= ? AND a.appointment_date <= ?";
        return executeSumWithDates(sql, from, to);
    }

    /**
     * Số dịch vụ khác nhau được sử dụng trong khoảng ngày [from, to].
     */
    public int countServicesUsedInDateRange(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(DISTINCT service_id) AS total FROM appointments "
                   + "WHERE service_id IS NOT NULL "
                   + "AND appointment_date >= ? AND appointment_date <= ?";
        return executeCountWithDates(sql, from, to);
    }

    /**
     * Dịch vụ được sử dụng nhiều nhất trong khoảng ngày.
     */
    public ServiceStatDetail getTopServiceByDateRange(LocalDate from, LocalDate to) {
        List<ServiceStatDetail> list = getTopServicesByUsageDateRange(1, from, to);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Top N dịch vụ có lượt sử dụng cao nhất trong khoảng ngày [from, to].
     */
    public List<ServiceStatDetail> getTopServicesByUsageDateRange(int limit, LocalDate from, LocalDate to) {
        // Bọc subquery để lọc bỏ service có usage_today = 0 trong khoảng ngày.
        // Đồng nhất với getDoctorPerformance(range) và getUltrasoundStats(range):
        //   nếu khoảng ngày không có dữ liệu → trả về list rỗng.
        String sql =
            "SELECT * FROM ("
            + "SELECT TOP (?) "
            + "  s.id AS service_id, "
            + "  s.service_code, "
            + "  s.service_name, "
            + "  ISNULL(s.price, 0) AS price, "
            + "  ISNULL(sc.category_name, N'Chưa phân nhóm') AS category_name, "
            + "  sc.icon AS category_icon, "
            + "  ISNULL(usage_stats.cnt, 0) AS usage_today, "
            + "  0 AS usage_yesterday, "
            + "  ISNULL(usage_stats.rev, 0) AS revenue_today, "
            + "  0 AS revenue_yesterday, "
            + "  ISNULL((SELECT COUNT(*) FROM appointments a2 WHERE a2.service_id = s.id), 0) AS total_usage "
            + "FROM services s "
            + "LEFT JOIN service_categories sc ON sc.id = s.category_id "
            + "LEFT JOIN ("
            + "  SELECT a.service_id, COUNT(*) AS cnt, ISNULL(SUM(ii.subtotal), 0) AS rev "
            + "  FROM appointments a "
            + "  LEFT JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid' "
            + "  LEFT JOIN invoice_items ii ON ii.invoice_id = i.id AND ii.item_type = 'service' AND ii.item_id = a.service_id "
            + "  WHERE a.appointment_date >= ? AND a.appointment_date <= ? "
            + "  GROUP BY a.service_id "
            + ") usage_stats ON usage_stats.service_id = s.id "
            + "WHERE s.is_active = 1 "
            + "ORDER BY usage_today DESC"
            + ") filtered WHERE usage_today > 0";

        List<ServiceStatDetail> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceStatDetail d = new ServiceStatDetail();
                d.serviceId = rs.getInt("service_id");
                d.serviceCode = rs.getString("service_code");
                d.serviceName = rs.getString("service_name");
                d.price = rs.getDouble("price");
                d.categoryName = rs.getString("category_name");
                try { d.categoryIcon = rs.getString("category_icon"); } catch (SQLException e) { d.categoryIcon = null; }
                d.usageToday = rs.getInt("usage_today");
                d.usageYesterday = 0;
                d.revenueToday = rs.getDouble("revenue_today");
                d.revenueYesterday = 0;
                d.totalUsage = rs.getInt("total_usage");
                list.add(d);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getTopServicesByUsageDateRange ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tổng lượt sử dụng trong khoảng trước đó (cùng độ dài, dùng cho so sánh tăng trưởng).
     * Ví dụ: from=2026-06-15, to=2026-06-22 (8 ngày) → prevFrom=2026-06-07, prevTo=2026-06-14
     */
    public int getTotalUsagePreviousPeriod(LocalDate from, LocalDate to) {
        long days = to.toEpochDay() - from.toEpochDay() + 1;
        LocalDate prevTo = from.minusDays(1);
        LocalDate prevFrom = prevTo.minusDays(days - 1);
        return getTotalUsageByDateRange(prevFrom, prevTo);
    }

    /**
     * Tổng doanh thu trong khoảng trước đó (cùng độ dài, dùng cho so sánh tăng trưởng).
     */
    public double getTotalRevenuePreviousPeriod(LocalDate from, LocalDate to) {
        long days = to.toEpochDay() - from.toEpochDay() + 1;
        LocalDate prevTo = from.minusDays(1);
        LocalDate prevFrom = prevTo.minusDays(days - 1);
        return getTotalRevenueByDateRange(prevFrom, prevTo);
    }

    // ═══════════════════════════════════════════════════════════
    // CHI TIẾT THEO TỪNG DỊCH VỤ — BẢNG THỐNG KÊ
    // ═══════════════════════════════════════════════════════════

    /**
     * DTO cho dữ liệu thống kê chi tiết từng dịch vụ.
     * Bao gồm: lượt sử dụng hôm nay, hôm qua, doanh thu hôm nay, tốc độ tăng trưởng.
     */
    public static class ServiceStatDetail {
        private int serviceId;
        private String serviceCode;
        private String serviceName;
        private String categoryName;
        private String categoryIcon;
        private double price;
        private int usageToday;
        private int usageYesterday;
        private double revenueToday;
        private double revenueYesterday;
        private int totalUsage;        // tổng lượt sử dụng từ trước đến nay

        public int getServiceId() { return serviceId; }
        public void setServiceId(int serviceId) { this.serviceId = serviceId; }
        public String getServiceCode() { return serviceCode; }
        public void setServiceCode(String serviceCode) { this.serviceCode = serviceCode; }
        public String getServiceName() { return serviceName; }
        public void setServiceName(String serviceName) { this.serviceName = serviceName; }
        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
        public String getCategoryIcon() { return categoryIcon; }
        public void setCategoryIcon(String categoryIcon) { this.categoryIcon = categoryIcon; }
        public double getPrice() { return price; }
        public void setPrice(double price) { this.price = price; }
        public int getUsageToday() { return usageToday; }
        public void setUsageToday(int usageToday) { this.usageToday = usageToday; }
        public int getUsageYesterday() { return usageYesterday; }
        public void setUsageYesterday(int usageYesterday) { this.usageYesterday = usageYesterday; }
        public double getRevenueToday() { return revenueToday; }
        public void setRevenueToday(double revenueToday) { this.revenueToday = revenueToday; }
        public double getRevenueYesterday() { return revenueYesterday; }
        public void setRevenueYesterday(double revenueYesterday) { this.revenueYesterday = revenueYesterday; }
        public int getTotalUsage() { return totalUsage; }
        public void setTotalUsage(int totalUsage) { this.totalUsage = totalUsage; }

        /** Phần trăm thay đổi lượt sử dụng: hôm nay so với hôm qua. */
        public double getUsageGrowthPercent() {
            if (usageYesterday == 0 && usageToday == 0) return 0;
            if (usageYesterday == 0) return 100.0; // từ 0 → có sử dụng
            return ((double)(usageToday - usageYesterday) / usageYesterday) * 100.0;
        }

        /** Phần trăm thay đổi doanh thu: hôm nay so với hôm qua. */
        public double getRevenueGrowthPercent() {
            if (revenueYesterday == 0 && revenueToday == 0) return 0;
            if (revenueYesterday == 0) return 100.0;
            return ((revenueToday - revenueYesterday) / revenueYesterday) * 100.0;
        }

        /** Trạng thái tăng trưởng: "up" | "down" | "stable". */
        public String getGrowthTrend() {
            double pct = getUsageGrowthPercent();
            if (pct > 5) return "up";
            if (pct < -5) return "down";
            return "stable";
        }
    }

    /**
     * Lấy danh sách thống kê chi tiết tất cả dịch vụ đang hoạt động,
     * bao gồm số lượt sử dụng hôm nay, hôm qua, doanh thu, và tổng lượt sử dụng.
     */
    public List<ServiceStatDetail> getAllServiceStats() {
        String sql =
            "SELECT "
            + "  s.id AS service_id, "
            + "  s.service_code, "
            + "  s.service_name, "
            + "  ISNULL(s.price, 0) AS price, "
            + "  ISNULL(sc.category_name, N'Chưa phân nhóm') AS category_name, "
            + "  sc.icon AS category_icon, "
            // Lượt sử dụng hôm nay
            + "  (SELECT COUNT(*) FROM appointments a "
            + "     WHERE a.service_id = s.id "
            + "     AND a.appointment_date = CAST(GETDATE() AS DATE)) AS usage_today, "
            // Lượt sử dụng hôm qua
            + "  (SELECT COUNT(*) FROM appointments a "
            + "     WHERE a.service_id = s.id "
            + "     AND a.appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))) AS usage_yesterday, "
            // Doanh thu hôm nay (từ invoice_items đã thanh toán)
            + "  ISNULL((SELECT SUM(ii.subtotal) FROM invoice_items ii "
            + "     INNER JOIN invoices i ON ii.invoice_id = i.id "
            + "     INNER JOIN appointments a ON i.appointment_id = a.id "
            + "     WHERE ii.item_type = 'service' AND ii.item_id = s.id "
            + "     AND i.status = 'paid' "
            + "     AND a.appointment_date = CAST(GETDATE() AS DATE)), 0) AS revenue_today, "
            // Doanh thu hôm qua
            + "  ISNULL((SELECT SUM(ii.subtotal) FROM invoice_items ii "
            + "     INNER JOIN invoices i ON ii.invoice_id = i.id "
            + "     INNER JOIN appointments a ON i.appointment_id = a.id "
            + "     WHERE ii.item_type = 'service' AND ii.item_id = s.id "
            + "     AND i.status = 'paid' "
            + "     AND a.appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))), 0) AS revenue_yesterday, "
            // Tổng lượt sử dụng từ trước đến nay
            + "  (SELECT COUNT(*) FROM appointments a WHERE a.service_id = s.id) AS total_usage "
            + "FROM services s "
            + "LEFT JOIN service_categories sc ON sc.id = s.category_id "
            + "WHERE s.is_active = 1 "
            + "ORDER BY usage_today DESC, revenue_today DESC";

        List<ServiceStatDetail> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceStatDetail d = new ServiceStatDetail();
                d.serviceId = rs.getInt("service_id");
                d.serviceCode = rs.getString("service_code");
                d.serviceName = rs.getString("service_name");
                d.price = rs.getDouble("price");
                d.categoryName = rs.getString("category_name");
                try { d.categoryIcon = rs.getString("category_icon"); } catch (SQLException e) { d.categoryIcon = null; }
                d.usageToday = rs.getInt("usage_today");
                d.usageYesterday = rs.getInt("usage_yesterday");
                d.revenueToday = rs.getDouble("revenue_today");
                d.revenueYesterday = rs.getDouble("revenue_yesterday");
                d.totalUsage = rs.getInt("total_usage");
                list.add(d);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getAllServiceStats ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════
    // TOP / BOTTOM DỊCH VỤ
    // ═══════════════════════════════════════════════════════════

    /**
     * Lấy top N dịch vụ có lượt sử dụng cao nhất hôm nay.
     */
    public List<ServiceStatDetail> getTopServicesByUsageToday(int limit) {
        List<ServiceStatDetail> all = getAllServiceStats();
        // Đã sắp xếp theo usage_today DESC từ SQL, chỉ cần lấy limit
        if (all.size() <= limit) return all;
        return all.subList(0, limit);
    }

    /**
     * Lấy top N dịch vụ có doanh thu cao nhất hôm nay.
     */
    public List<ServiceStatDetail> getTopServicesByRevenueToday(int limit) {
        List<ServiceStatDetail> all = getAllServiceStats();
        // Sắp xếp lại theo revenue_today DESC
        all.sort((a, b) -> Double.compare(b.getRevenueToday(), a.getRevenueToday()));
        if (all.size() <= limit) return all;
        return all.subList(0, limit);
    }

    /**
     * Lấy các dịch vụ có hiệu suất thấp (lượt sử dụng hôm nay = 0, đang hoạt động).
     */
    public List<ServiceStatDetail> getLowPerformingServices() {
        String sql =
            "SELECT "
            + "  s.id AS service_id, "
            + "  s.service_code, "
            + "  s.service_name, "
            + "  ISNULL(s.price, 0) AS price, "
            + "  ISNULL(sc.category_name, N'Chưa phân nhóm') AS category_name, "
            + "  sc.icon AS category_icon, "
            + "  0 AS usage_today, "
            + "  (SELECT COUNT(*) FROM appointments a "
            + "     WHERE a.service_id = s.id "
            + "     AND a.appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))) AS usage_yesterday, "
            + "  0 AS revenue_today, "
            + "  0 AS revenue_yesterday, "
            + "  ISNULL((SELECT COUNT(*) FROM appointments a WHERE a.service_id = s.id), 0) AS total_usage "
            + "FROM services s "
            + "LEFT JOIN service_categories sc ON sc.id = s.category_id "
            + "WHERE s.is_active = 1 "
            + "AND NOT EXISTS ("
            + "  SELECT 1 FROM appointments a "
            + "  WHERE a.service_id = s.id "
            + "  AND a.appointment_date = CAST(GETDATE() AS DATE)"
            + ") "
            + "ORDER BY total_usage ASC";

        List<ServiceStatDetail> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceStatDetail d = new ServiceStatDetail();
                d.serviceId = rs.getInt("service_id");
                d.serviceCode = rs.getString("service_code");
                d.serviceName = rs.getString("service_name");
                d.price = rs.getDouble("price");
                d.categoryName = rs.getString("category_name");
                try { d.categoryIcon = rs.getString("category_icon"); } catch (SQLException e) { d.categoryIcon = null; }
                d.usageToday = 0;
                d.usageYesterday = rs.getInt("usage_yesterday");
                d.revenueToday = 0;
                d.revenueYesterday = 0;
                d.totalUsage = rs.getInt("total_usage");
                list.add(d);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getLowPerformingServices ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════
    // BIỂU ĐỒ — DỮ LIỆU THEO THỜI GIAN
    // ═══════════════════════════════════════════════════════════

    /**
     * Tổng doanh thu dịch vụ 7 ngày gần nhất (theo ngày).
     * Trả về Map<ngày (dd/MM), doanh thu>.
     */
    public Map<String, Double> getRevenueLast7Days() {
        return getRevenueLast7Days(LocalDate.now());
    }

    /**
     * Doanh thu dịch vụ 7 ngày, kết thúc tại endDate.
     */
    public Map<String, Double> getRevenueLast7Days(LocalDate endDate) {
        String sql =
            "SELECT a.appointment_date, ISNULL(SUM(ii.subtotal), 0) AS total "
            + "FROM invoice_items ii "
            + "INNER JOIN invoices i ON ii.invoice_id = i.id "
            + "INNER JOIN appointments a ON i.appointment_id = a.id "
            + "WHERE ii.item_type = 'service' "
            + "AND i.status = 'paid' "
            + "AND a.appointment_date >= ? "
            + "AND a.appointment_date <= ? "
            + "GROUP BY a.appointment_date "
            + "ORDER BY a.appointment_date";

        LocalDate startDate = endDate.minusDays(6);
        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (LocalDate d = startDate; !d.isAfter(endDate); d = d.plusDays(1)) {
            result.put(d.format(fmt), 0.0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(startDate));
            ps.setDate(2, java.sql.Date.valueOf(endDate));
            rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date date = rs.getDate("appointment_date");
                double total = rs.getDouble("total");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, total);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getRevenueLast7Days ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Tổng lượt sử dụng dịch vụ 7 ngày gần nhất (theo ngày).
     * Trả về Map<ngày (dd/MM), số lượt>.
     */
    public Map<String, Integer> getUsageLast7Days() {
        String sql =
            "SELECT appointment_date, COUNT(*) AS cnt "
            + "FROM appointments "
            + "WHERE service_id IS NOT NULL "
            + "AND appointment_date >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) "
            + "AND appointment_date <= CAST(GETDATE() AS DATE) "
            + "GROUP BY appointment_date "
            + "ORDER BY appointment_date";

        Map<String, Integer> result = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 6; i >= 0; i--) {
            result.put(today.minusDays(i).format(fmt), 0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date date = rs.getDate("appointment_date");
                int count = rs.getInt("cnt");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, count);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getUsageLast7Days ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Doanh thu dịch vụ 12 tháng gần nhất (theo tháng).
     * Trả về Map<tháng (MM/yyyy), doanh thu>.
     */
    public Map<String, Double> getRevenueLast12Months() {
        return getRevenueLast12Months(LocalDate.now());
    }

    /**
     * Doanh thu dịch vụ 12 tháng, kết thúc tại endDate.
     */
    public Map<String, Double> getRevenueLast12Months(LocalDate endDate) {
        String sql =
            "SELECT YEAR(a.appointment_date) AS yr, MONTH(a.appointment_date) AS mth, "
            + "ISNULL(SUM(ii.subtotal), 0) AS total "
            + "FROM invoice_items ii "
            + "INNER JOIN invoices i ON ii.invoice_id = i.id "
            + "INNER JOIN appointments a ON i.appointment_id = a.id "
            + "WHERE ii.item_type = 'service' "
            + "AND i.status = 'paid' "
            + "AND a.appointment_date >= ? "
            + "AND a.appointment_date <= ? "
            + "GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date) "
            + "ORDER BY yr, mth";

        LocalDate startMonth = endDate.minusMonths(11).withDayOfMonth(1);
        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM/yyyy");
        for (LocalDate d = startMonth; !d.isAfter(endDate); d = d.plusMonths(1)) {
            result.put(d.format(fmt), 0.0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(startMonth));
            ps.setDate(2, java.sql.Date.valueOf(endDate));
            rs = ps.executeQuery();
            while (rs.next()) {
                int yr = rs.getInt("yr");
                int mth = rs.getInt("mth");
                double total = rs.getDouble("total");
                String key = String.format("%02d/%d", mth, yr);
                result.put(key, total);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getRevenueLast12Months ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Lượt sử dụng 7 ngày gần nhất cho MỘT dịch vụ cụ thể.
     * Trả về Map<ngày (dd/MM), số lượt>.
     */
    public Map<String, Integer> getServiceDailyUsage7Days(int serviceId) {
        String sql =
            "SELECT appointment_date, COUNT(*) AS cnt "
            + "FROM appointments "
            + "WHERE service_id = ? "
            + "AND appointment_date >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) "
            + "AND appointment_date <= CAST(GETDATE() AS DATE) "
            + "GROUP BY appointment_date "
            + "ORDER BY appointment_date";

        Map<String, Integer> result = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 6; i >= 0; i--) {
            result.put(today.minusDays(i).format(fmt), 0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, serviceId);
            rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date date = rs.getDate("appointment_date");
                int count = rs.getInt("cnt");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, count);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getServiceDailyUsage7Days ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════
    // BIỂU ĐỒ — DOANH THU THEO NHÓM DỊCH VỤ
    // ═══════════════════════════════════════════════════════════

    /**
     * DTO cho thống kê doanh thu theo nhóm dịch vụ.
     */
    public static class CategoryRevenueStat {
        private int categoryId;
        private String categoryName;
        private String categoryIcon;
        private int serviceCount;
        private int totalBookings;
        private double totalRevenue;

        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
        public String getCategoryIcon() { return categoryIcon; }
        public void setCategoryIcon(String categoryIcon) { this.categoryIcon = categoryIcon; }
        public int getServiceCount() { return serviceCount; }
        public void setServiceCount(int serviceCount) { this.serviceCount = serviceCount; }
        public int getTotalBookings() { return totalBookings; }
        public void setTotalBookings(int totalBookings) { this.totalBookings = totalBookings; }
        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
    }

    /**
     * Phân bổ doanh thu theo nhóm dịch vụ (dùng cho biểu đồ tròn).
     * Tính tổng doanh thu từ invoice_items theo từng category.
     */
    public List<CategoryRevenueStat> getCategoryRevenueBreakdown() {
        String sql =
            "SELECT "
            + "  sc.id AS category_id, "
            + "  sc.category_name, "
            + "  sc.icon AS category_icon, "
            + "  (SELECT COUNT(*) FROM services WHERE category_id = sc.id AND is_active = 1) AS service_count, "
            + "  ISNULL(SUM(booking_stats.total_bookings), 0) AS total_bookings, "
            + "  ISNULL(SUM(booking_stats.total_revenue), 0) AS total_revenue "
            + "FROM service_categories sc "
            + "LEFT JOIN ("
            + "  SELECT s.category_id, "
            + "    COUNT(DISTINCT a.id) AS total_bookings, "
            + "    ISNULL(SUM(ii.subtotal), 0) AS total_revenue "
            + "  FROM services s "
            + "  LEFT JOIN appointments a ON a.service_id = s.id "
            + "  LEFT JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid' "
            + "  LEFT JOIN invoice_items ii ON ii.invoice_id = i.id AND ii.item_type = 'service' AND ii.item_id = s.id "
            + "  WHERE s.is_active = 1 "
            + "  GROUP BY s.category_id "
            + ") booking_stats ON booking_stats.category_id = sc.id "
            + "WHERE sc.is_active = 1 "
            + "GROUP BY sc.id, sc.category_name, sc.icon "
            + "ORDER BY total_revenue DESC";

        List<CategoryRevenueStat> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                CategoryRevenueStat c = new CategoryRevenueStat();
                c.categoryId = rs.getInt("category_id");
                c.categoryName = rs.getString("category_name");
                try { c.categoryIcon = rs.getString("category_icon"); } catch (SQLException e) { c.categoryIcon = null; }
                c.serviceCount = rs.getInt("service_count");
                c.totalBookings = rs.getInt("total_bookings");
                c.totalRevenue = rs.getDouble("total_revenue");
                list.add(c);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getCategoryRevenueBreakdown ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Dịch vụ được sử dụng nhiều nhất hôm nay.
     * Trả về ServiceStatDetail hoặc null nếu chưa có dữ liệu.
     */
    public ServiceStatDetail getTopServiceToday() {
        List<ServiceStatDetail> list = getTopServicesByUsageToday(1);
        return list.isEmpty() ? null : list.get(0);
    }

    // ═══════════════════════════════════════════════════════════
    // TỔNG DOANH THU THEO DỊCH VỤ (dùng cho biểu đồ cột top 10)
    // ═══════════════════════════════════════════════════════════

    /**
     * Top N dịch vụ theo tổng doanh thu (mọi thời gian).
     * Dùng cho biểu đồ cột doanh thu.
     */
    public List<ServiceStatDetail> getTopServicesByTotalRevenue(int limit) {
        String sql =
            "SELECT TOP (?) "
            + "  s.id AS service_id, "
            + "  s.service_code, "
            + "  s.service_name, "
            + "  ISNULL(s.price, 0) AS price, "
            + "  ISNULL(sc.category_name, N'Chưa phân nhóm') AS category_name, "
            + "  sc.icon AS category_icon, "
            + "  0 AS usage_today, 0 AS usage_yesterday, 0 AS revenue_today, 0 AS revenue_yesterday, "
            + "  ISNULL(rev.total_revenue, 0) AS total_revenue, "
            + "  ISNULL(rev.total_bookings, 0) AS total_usage "
            + "FROM services s "
            + "LEFT JOIN service_categories sc ON sc.id = s.category_id "
            + "LEFT JOIN ("
            + "  SELECT a.service_id, "
            + "    COUNT(DISTINCT a.id) AS total_bookings, "
            + "    ISNULL(SUM(ii.subtotal), 0) AS total_revenue "
            + "  FROM appointments a "
            + "  INNER JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid' "
            + "  INNER JOIN invoice_items ii ON ii.invoice_id = i.id AND ii.item_type = 'service' AND ii.item_id = a.service_id "
            + "  GROUP BY a.service_id "
            + ") rev ON rev.service_id = s.id "
            + "WHERE s.is_active = 1 "
            + "ORDER BY total_revenue DESC";

        List<ServiceStatDetail> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceStatDetail d = new ServiceStatDetail();
                d.serviceId = rs.getInt("service_id");
                d.serviceCode = rs.getString("service_code");
                d.serviceName = rs.getString("service_name");
                d.price = rs.getDouble("price");
                d.categoryName = rs.getString("category_name");
                try { d.categoryIcon = rs.getString("category_icon"); } catch (SQLException e) { d.categoryIcon = null; }
                d.totalUsage = rs.getInt("total_usage");
                d.revenueToday = rs.getDouble("total_revenue"); // Tạm dùng field revenueToday để chứa total_revenue
                d.usageToday = rs.getInt("total_usage");
                list.add(d);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] getTopServicesByTotalRevenue ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    private int executeCountWithDates(String sql, LocalDate from, LocalDate to) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] executeCountWithDates ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private double executeSumWithDates(String sql, LocalDate from, LocalDate to) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] executeSumWithDates ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0.0;
    }

    // ═══════════════════════════════════════════════════════════
    // HELPER METHODS
    // ═══════════════════════════════════════════════════════════

    private int executeCount(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] executeCount ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private double executeSum(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            System.err.println("[ServiceStatisticsDAO] executeSum ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0.0;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { /* ignore */ } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { /* ignore */ } }
        DatabaseConfig.closeConnection(conn);
    }
}
