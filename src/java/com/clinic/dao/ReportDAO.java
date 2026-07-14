package com.clinic.dao;

import com.clinic.config.DatabaseConfig;

import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO tổng hợp dữ liệu báo cáo cho Admin & Manager.
 * Cung cấp dữ liệu cho ReportService → AdminReportServlet.
 *
 * <p>Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class ReportDAO {

    // ═══════════════════════════════════════════════════════════
    // DTO: Tổng quan báo cáo (KPI Summary)
    // ═══════════════════════════════════════════════════════════

    /** DTO cho tổng quan KPI báo cáo. */
    public static class ReportSummary {
        private double totalRevenue;
        private int totalAppointments;
        private int completedAppointments;
        private int emergencyCases;
        private int successCases;
        private double completionRate;

        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double v) { this.totalRevenue = v; }
        public int getTotalAppointments() { return totalAppointments; }
        public void setTotalAppointments(int v) { this.totalAppointments = v; }
        public int getCompletedAppointments() { return completedAppointments; }
        public void setCompletedAppointments(int v) { this.completedAppointments = v; }
        public int getEmergencyCases() { return emergencyCases; }
        public void setEmergencyCases(int v) { this.emergencyCases = v; }
        public int getSuccessCases() { return successCases; }
        public void setSuccessCases(int v) { this.successCases = v; }
        public double getCompletionRate() { return completionRate; }
        public void setCompletionRate(double v) { this.completionRate = v; }
    }

    /** DTO cho hiệu suất bác sĩ trong báo cáo. */
    public static class DoctorPerformanceReport {
        private int doctorId;
        private String doctorName;
        private String specialization;
        private int totalAppointments;
        private int completedAppointments;
        private int uniquePatients;
        private double totalRevenue;

        public int getDoctorId() { return doctorId; }
        public void setDoctorId(int v) { this.doctorId = v; }
        public String getDoctorName() { return doctorName; }
        public void setDoctorName(String v) { this.doctorName = v; }
        public String getSpecialization() { return specialization; }
        public void setSpecialization(String v) { this.specialization = v; }
        public int getTotalAppointments() { return totalAppointments; }
        public void setTotalAppointments(int v) { this.totalAppointments = v; }
        public int getCompletedAppointments() { return completedAppointments; }
        public void setCompletedAppointments(int v) { this.completedAppointments = v; }
        public int getUniquePatients() { return uniquePatients; }
        public void setUniquePatients(int v) { this.uniquePatients = v; }
        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double v) { this.totalRevenue = v; }

        /** Tỉ lệ hoàn thành = completed / total (%). */
        public double getCompletionRate() {
            if (totalAppointments == 0) return 0;
            return (double) completedAppointments / totalAppointments * 100.0;
        }
    }

    /** DTO cho phân bố trạng thái lịch hẹn. */
    public static class StatusBreakdown {
        private String status;
        private int count;

        public String getStatus() { return status; }
        public void setStatus(String v) { this.status = v; }
        public int getCount() { return count; }
        public void setCount(int v) { this.count = v; }
    }

    // ═══════════════════════════════════════════════════════════
    // KPI TỔNG QUAN
    // ═══════════════════════════════════════════════════════════

    /**
     * Lấy tổng quan KPI cho báo cáo trong khoảng ngày.
     */
    public ReportSummary getSummary(LocalDate from, LocalDate to) {
        ReportSummary summary = new ReportSummary();

        // Tổng doanh thu
        String revenueSql =
            "SELECT ISNULL(SUM(i.total_amount), 0) AS total "
            + "FROM invoices i "
            + "INNER JOIN appointments a ON i.appointment_id = a.id "
            + "WHERE i.status = 'paid' "
            + "AND a.appointment_date >= ? AND a.appointment_date <= ?";
        summary.setTotalRevenue(executeSum(revenueSql, from, to));

        // Tổng lịch hẹn
        String apptSql =
            "SELECT COUNT(*) AS total FROM appointments "
            + "WHERE appointment_date >= ? AND appointment_date <= ?";
        summary.setTotalAppointments(executeCount(apptSql, from, to));

        // Số ca hoàn thành
        String completedSql =
            "SELECT COUNT(*) AS total FROM appointments "
            + "WHERE status = 'completed' "
            + "AND appointment_date >= ? AND appointment_date <= ?";
        summary.setCompletedAppointments(executeCount(completedSql, from, to));

        // Số ca cấp cứu
        String emergencySql =
            "SELECT COUNT(*) AS total FROM appointments "
            + "WHERE is_emergency = 1 "
            + "AND appointment_date >= ? AND appointment_date <= ?";
        summary.setEmergencyCases(executeCount(emergencySql, from, to));

        // Số ca thành công (completed + paid)
        String successSql =
            "SELECT COUNT(DISTINCT a.id) AS total FROM appointments a "
            + "INNER JOIN invoices i ON i.appointment_id = a.id "
            + "WHERE a.status = 'completed' AND i.status = 'paid' "
            + "AND a.appointment_date >= ? AND a.appointment_date <= ?";
        summary.setSuccessCases(executeCount(successSql, from, to));

        // Tỉ lệ hoàn thành
        if (summary.getTotalAppointments() > 0) {
            summary.setCompletionRate(
                (double) summary.getCompletedAppointments() / summary.getTotalAppointments() * 100.0);
        }

        return summary;
    }

    // ═══════════════════════════════════════════════════════════
    // DOANH THU THEO NGÀY (Line Chart)
    // ═══════════════════════════════════════════════════════════

    /**
     * Doanh thu theo từng ngày trong khoảng.
     * Trả về Map&lt;ngày (dd/MM), doanh thu&gt;.
     */
    public Map<String, Double> getDailyRevenue(LocalDate from, LocalDate to) {
        String sql =
            "SELECT a.appointment_date, ISNULL(SUM(i.total_amount), 0) AS daily_revenue "
            + "FROM appointments a "
            + "LEFT JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid' "
            + "WHERE a.appointment_date >= ? AND a.appointment_date <= ? "
            + "GROUP BY a.appointment_date "
            + "ORDER BY a.appointment_date";

        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        // Khởi tạo tất cả ngày với giá trị 0
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            result.put(d.format(fmt), 0.0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            rs = ps.executeQuery();
            while (rs.next()) {
                Date date = rs.getDate("appointment_date");
                double revenue = rs.getDouble("daily_revenue");
                if (date != null) {
                    result.put(date.toLocalDate().format(fmt), revenue);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO] getDailyRevenue ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════
    // HIỆU SUẤT BÁC SĨ (Doctor Performance)
    // ═══════════════════════════════════════════════════════════

    /**
     * Báo cáo hiệu suất bác sĩ trong khoảng ngày.
     * Bao gồm: tổng ca, ca hoàn thành, BN duy nhất, doanh thu.
     */
    public List<DoctorPerformanceReport> getDoctorPerformanceReport(LocalDate from, LocalDate to) {
        String sql =
            "SELECT "
            + "  d.id AS doctor_id, "
            + "  d.full_name AS doctor_name, "
            + "  ISNULL(d.specialization, N'Chưa cập nhật') AS specialization, "
            + "  COUNT(DISTINCT a.id) AS total_appointments, "
            + "  COUNT(DISTINCT CASE WHEN a.status = 'completed' THEN a.id END) AS completed_appts, "
            + "  COUNT(DISTINCT a.patient_id) AS unique_patients, "
            + "  ISNULL(SUM(i.total_amount), 0) AS total_revenue "
            + "FROM doctors d "
            + "LEFT JOIN appointments a ON a.doctor_id = d.id "
            + "  AND a.appointment_date >= ? AND a.appointment_date <= ? "
            + "LEFT JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid' "
            + "GROUP BY d.id, d.full_name, d.specialization "
            + "ORDER BY total_appointments DESC";

        List<DoctorPerformanceReport> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            rs = ps.executeQuery();
            while (rs.next()) {
                DoctorPerformanceReport dpr = new DoctorPerformanceReport();
                dpr.setDoctorId(rs.getInt("doctor_id"));
                dpr.setDoctorName(rs.getString("doctor_name"));
                dpr.setSpecialization(rs.getString("specialization"));
                dpr.setTotalAppointments(rs.getInt("total_appointments"));
                dpr.setCompletedAppointments(rs.getInt("completed_appts"));
                dpr.setUniquePatients(rs.getInt("unique_patients"));
                dpr.setTotalRevenue(rs.getDouble("total_revenue"));
                list.add(dpr);
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO] getDoctorPerformanceReport ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════
    // PHÂN BỐ TRẠNG THÁI (Doughnut Chart)
    // ═══════════════════════════════════════════════════════════

    /**
     * Phân bố trạng thái lịch hẹn trong khoảng ngày.
     */
    public List<StatusBreakdown> getStatusBreakdown(LocalDate from, LocalDate to) {
        String sql =
            "SELECT status, COUNT(*) AS cnt "
            + "FROM appointments "
            + "WHERE appointment_date >= ? AND appointment_date <= ? "
            + "GROUP BY status "
            + "ORDER BY cnt DESC";

        List<StatusBreakdown> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            rs = ps.executeQuery();
            while (rs.next()) {
                StatusBreakdown sb = new StatusBreakdown();
                sb.setStatus(rs.getString("status"));
                sb.setCount(rs.getInt("cnt"));
                list.add(sb);
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO] getStatusBreakdown ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════
    // DOANH THU THEO THÁNG (Bar Chart 12 tháng)
    // ═══════════════════════════════════════════════════════════

    /**
     * Doanh thu 12 tháng gần nhất.
     */
    public Map<String, Double> getRevenueLast12Months(LocalDate endDate) {
        String sql =
            "SELECT YEAR(a.appointment_date) AS yr, MONTH(a.appointment_date) AS mth, "
            + "ISNULL(SUM(i.total_amount), 0) AS total "
            + "FROM invoices i "
            + "INNER JOIN appointments a ON i.appointment_id = a.id "
            + "WHERE i.status = 'paid' "
            + "AND a.appointment_date >= ? AND a.appointment_date <= ? "
            + "GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date) "
            + "ORDER BY yr, mth";

        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM/yyyy");
        LocalDate startMonth = endDate.minusMonths(11).withDayOfMonth(1);
        for (LocalDate d = startMonth; !d.isAfter(endDate); d = d.plusMonths(1)) {
            result.put(d.format(fmt), 0.0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(startMonth));
            ps.setDate(2, Date.valueOf(endDate));
            rs = ps.executeQuery();
            while (rs.next()) {
                int yr = rs.getInt("yr");
                int mth = rs.getInt("mth");
                double total = rs.getDouble("total");
                result.put(String.format("%02d/%d", mth, yr), total);
            }
        } catch (SQLException e) {
            System.err.println("[ReportDAO] getRevenueLast12Months ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════
    // HELPER METHODS
    // ═══════════════════════════════════════════════════════════

    private int executeCount(String sql, LocalDate from, LocalDate to) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[ReportDAO] executeCount ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private double executeSum(String sql, LocalDate from, LocalDate to) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            System.err.println("[ReportDAO] executeSum ERROR: " + e.getMessage());
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
