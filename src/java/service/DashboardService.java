package com.clinic.service;

import com.clinic.dao.DashboardDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.User;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service tổng hợp dữ liệu cho Dashboard Admin.
 * Gọi DashboardDAO và UserDAO để lấy thống kê và danh sách hiển thị.
 *
 * Tuân thủ kiến trúc: Controller → Service → DAO → Database
 */
public class DashboardService {

    private final UserDAO userDAO;
    private final DashboardDAO dashboardDAO;

    public DashboardService() {
        this.userDAO = new UserDAO();
        this.dashboardDAO = new DashboardDAO();
    }

    // ──────────────────────────────────────────────
    // 6 KPI CARDS
    // ──────────────────────────────────────────────

    /**
     * Tổng số người dùng trong hệ thống.
     */
    public int getTotalUsers() {
        try {
            return Math.max(userDAO.getTotalUsers(), 0);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalUsers - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số người dùng được tạo trong khoảng ngày (lọc theo ngày).
     */
    public int getTotalUsers(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countUsers(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalUsers(range) - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số bác sĩ (role_id = 2).
     */
    public int getTotalDoctors() {
        try {
            return Math.max(userDAO.getTotalDoctors(), 0);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalDoctors - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số bác sĩ được tạo trong khoảng ngày (lọc theo ngày).
     */
    public int getTotalDoctors(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countDoctors(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalDoctors(range) - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số bệnh nhân (role_id = 5).
     */
    public int getTotalPatients() {
        try {
            return dashboardDAO.countPatients();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalPatients - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số bệnh nhân được tạo trong khoảng ngày (lọc theo ngày).
     */
    public int getTotalPatients(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countPatients(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalPatients(range) - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số lịch hẹn trong ngày hôm nay.
     */
    public int getTotalAppointmentsToday() {
        try {
            return dashboardDAO.countAppointmentsToday();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalAppointmentsToday - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số lịch hẹn trong khoảng ngày.
     */
    public int getTotalAppointments(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countAppointments(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTotalAppointments - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số bệnh nhân đang chờ khám hôm nay.
     */
    public int getWaitingPatients() {
        try {
            return dashboardDAO.countWaitingPatients();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getWaitingPatients - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số bệnh nhân đang chờ khám trong khoảng ngày.
     */
    public int getWaitingPatients(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countWaitingPatients(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getWaitingPatients(range) - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số bác sĩ đang làm việc hôm nay.
     */
    public int getDoctorsWorkingToday() {
        try {
            return dashboardDAO.countDoctorsWorkingToday();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getDoctorsWorkingToday - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số bác sĩ làm việc trong một ngày cụ thể.
     */
    public int getDoctorsWorking(LocalDate date) {
        try {
            return dashboardDAO.countDoctorsWorking(date);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getDoctorsWorking - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số ca siêu âm trong ngày hôm nay.
     */
    public int getUltrasoundToday() {
        try {
            return dashboardDAO.countUltrasoundToday();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getUltrasoundToday - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số ca siêu âm trong khoảng ngày.
     */
    public int getUltrasound(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.countUltrasound(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getUltrasound - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Doanh thu hôm nay (VND).
     */
    public String getRevenueToday() {
        try {
            double revenue = dashboardDAO.sumRevenueToday();
            return formatCurrency(revenue);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRevenueToday - " + e.getMessage());
            return "0 VNĐ";
        }
    }

    /**
     * Doanh thu trong khoảng ngày (VND).
     */
    public String getRevenue(LocalDate from, LocalDate to) {
        try {
            double revenue = dashboardDAO.sumRevenue(from, to);
            return formatCurrency(revenue);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRevenue - " + e.getMessage());
            return "0 VNĐ";
        }
    }

    /**
     * Doanh thu trong khoảng ngày (số thô, để tính toán).
     */
    public double getRevenueRaw(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.sumRevenue(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRevenueRaw - " + e.getMessage());
            return 0.0;
        }
    }

    // ──────────────────────────────────────────────
    // CHARTS DATA
    // ──────────────────────────────────────────────

    /**
     * Dữ liệu biểu đồ lịch hẹn 7 ngày gần nhất.
     */
    public Map<String, Integer> getAppointmentsChartData() {
        try {
            return dashboardDAO.getAppointmentsLast7Days();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getAppointmentsChartData - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Dữ liệu biểu đồ lịch hẹn theo khoảng ngày.
     */
    public Map<String, Integer> getAppointmentsChartData(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.getAppointmentsChart(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getAppointmentsChartData(range) - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Dữ liệu biểu đồ doanh thu 12 tháng gần nhất.
     */
    public Map<String, Double> getRevenueChartData() {
        try {
            return dashboardDAO.getRevenueLast12Months();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRevenueChartData - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Dữ liệu biểu đồ doanh thu 12 tháng tính đến endDate.
     */
    public Map<String, Double> getRevenueChartData(LocalDate endDate) {
        try {
            return dashboardDAO.getRevenueChart(endDate);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRevenueChartData(date) - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    // ──────────────────────────────────────────────
    // TABLES DATA
    // ──────────────────────────────────────────────

    /**
     * Danh sách hiệu suất bác sĩ.
     */
    public List<DashboardDAO.DoctorPerformance> getDoctorPerformance() {
        try {
            return dashboardDAO.getDoctorPerformance();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getDoctorPerformance - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Danh sách hiệu suất bác sĩ trong khoảng ngày.
     */
    public List<DashboardDAO.DoctorPerformance> getDoctorPerformance(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.getDoctorPerformance(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getDoctorPerformance(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Lịch làm việc hôm nay.
     */
    public List<DashboardDAO.TodaySchedule> getTodaySchedules() {
        try {
            return dashboardDAO.getTodaySchedules();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getTodaySchedules - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Lịch làm việc trong một ngày cụ thể.
     */
    public List<DashboardDAO.TodaySchedule> getSchedules(LocalDate date) {
        try {
            return dashboardDAO.getSchedules(date);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getSchedules - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Thống kê dịch vụ siêu âm.
     */
    public List<DashboardDAO.UltrasoundStat> getUltrasoundStats() {
        try {
            return dashboardDAO.getUltrasoundStats();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getUltrasoundStats - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Thống kê dịch vụ siêu âm trong khoảng ngày.
     */
    public List<DashboardDAO.UltrasoundStat> getUltrasoundStats(LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.getUltrasoundStats(from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getUltrasoundStats(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Danh sách bệnh nhân mới đăng ký.
     */
    public List<DashboardDAO.RecentPatient> getRecentPatients(int limit) {
        try {
            return dashboardDAO.getRecentPatients(limit);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRecentPatients - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Danh sách bệnh nhân mới đăng ký trong khoảng ngày.
     */
    public List<DashboardDAO.RecentPatient> getRecentPatients(int limit, LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.getRecentPatients(limit, from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRecentPatients(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Nhật ký hệ thống gần đây.
     */
    public List<DashboardDAO.AuditLogEntry> getRecentAuditLogs(int limit) {
        try {
            return dashboardDAO.getRecentAuditLogs(limit);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRecentAuditLogs - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Nhật ký hệ thống trong khoảng ngày.
     */
    public List<DashboardDAO.AuditLogEntry> getRecentAuditLogs(int limit, LocalDate from, LocalDate to) {
        try {
            return dashboardDAO.getRecentAuditLogs(limit, from, to);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRecentAuditLogs(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Danh sách cảnh báo hệ thống.
     */
    public List<DashboardDAO.Alert> getSystemAlerts() {
        try {
            return dashboardDAO.getSystemAlerts();
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getSystemAlerts - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Danh sách cảnh báo hệ thống với ngày tham chiếu.
     */
    public List<DashboardDAO.Alert> getSystemAlerts(LocalDate refDate) {
        try {
            return dashboardDAO.getSystemAlerts(refDate);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getSystemAlerts(date) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ──────────────────────────────────────────────
    // LEGACY METHODS (giữ tương thích ngược)
    // ──────────────────────────────────────────────

    /**
     * Lấy danh sách N người dùng mới nhất.
     * @deprecated Dùng getRecentUsers thay thế
     */
    @Deprecated
    public List<User> getRecentUsers(int limit) {
        try {
            return userDAO.getRecentUsers(limit);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi getRecentUsers - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Lấy doanh thu tháng hiện tại (legacy).
     * @deprecated Dùng getRevenueToday + getRevenueChartData thay thế
     */
    @Deprecated
    public String getMonthlyRevenue() {
        return getRevenueToday();
    }

    // ──────────────────────────────────────────────
    // HELPERS
    // ──────────────────────────────────────────────

    /**
     * Format số tiền sang chuỗi VNĐ.
     */
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
}
