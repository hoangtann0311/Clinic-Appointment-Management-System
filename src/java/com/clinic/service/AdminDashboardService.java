package com.clinic.service;

import com.clinic.dao.AdminDashboardDAO;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service tổng hợp dữ liệu cho Dashboard Admin (System Administration).
 *
 * <p><b>Phạm vi:</b> Quản trị hệ thống — không tham gia nghiệp vụ khám chữa bệnh.
 * Gọi AdminDashboardDAO để lấy thống kê và danh sách hiển thị.
 *
 * <p>Tuân thủ kiến trúc: Controller → Service → DAO → Database
 */
public class AdminDashboardService {

    private final AdminDashboardDAO adminDAO;

    public AdminDashboardService() {
        this.adminDAO = new AdminDashboardDAO();
    }

    // ──────────────────────────────────────────────
    // KPI: TÀI KHOẢN
    // ──────────────────────────────────────────────

    /** Tổng số tài khoản toàn hệ thống. */
    public int getTotalAccounts() {
        try {
            return Math.max(adminDAO.countTotalAccounts(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalAccounts - " + e.getMessage());
            return 0;
        }
    }

    /** Tổng số tài khoản trong khoảng ngày. */
    public int getTotalAccounts(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countTotalAccounts(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalAccounts(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản đang hoạt động. */
    public int getActiveAccounts() {
        try {
            return Math.max(adminDAO.countActiveAccounts(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getActiveAccounts - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Số người dùng duy nhất có hoạt động đăng nhập trong khoảng ngày.
     * Dùng cho custom range thay vì đếm theo created_at.
     */
    public int getActiveUsersInRange(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countActiveUsersInRange(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getActiveUsersInRange - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản Active trong khoảng ngày (tạo trong khoảng và hiện Active).
     *  @deprecated Dùng getActiveUsersInRange để có số liệu phản ánh hoạt động thực tế. */
    @Deprecated
    public int getActiveAccounts(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countActiveAccounts(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getActiveAccounts(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản bị khóa. */
    public int getLockedAccounts() {
        try {
            return Math.max(adminDAO.countLockedAccounts(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLockedAccounts - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản bị khóa trong khoảng ngày. */
    public int getLockedAccounts(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countLockedAccounts(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLockedAccounts(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản chưa xác thực email. */
    public int getUnverifiedAccounts() {
        try {
            return Math.max(adminDAO.countUnverifiedAccounts(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getUnverifiedAccounts - " + e.getMessage());
            return 0;
        }
    }

    /** Số tài khoản chưa xác thực email trong khoảng ngày. */
    public int getUnverifiedAccounts(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countUnverifiedAccounts(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getUnverifiedAccounts(range) - " + e.getMessage());
            return 0;
        }
    }

    // ──────────────────────────────────────────────
    // KPI: PHÂN QUYỀN
    // ──────────────────────────────────────────────

    /** Tổng số vai trò (Role). */
    public int getTotalRoles() {
        try {
            return Math.max(adminDAO.countRoles(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalRoles - " + e.getMessage());
            return 0;
        }
    }

    /** Tổng số vai trò được tạo trong khoảng ngày. */
    public int getTotalRoles(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countRoles(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalRoles(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Tổng số quyền (Permission). */
    public int getTotalPermissions() {
        try {
            return Math.max(adminDAO.countPermissions(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalPermissions - " + e.getMessage());
            return 0;
        }
    }

    /** Tổng số quyền được tạo trong khoảng ngày. */
    public int getTotalPermissions(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countPermissions(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getTotalPermissions(range) - " + e.getMessage());
            return 0;
        }
    }

    // ──────────────────────────────────────────────
    // KPI: GIÁM SÁT & BẢO MẬT
    // ──────────────────────────────────────────────

    /** Số lượt đăng nhập hôm nay. */
    public int getLoginsToday() {
        try {
            return Math.max(adminDAO.countLoginsToday(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLoginsToday - " + e.getMessage());
            return 0;
        }
    }

    /** Số lượt đăng nhập trong khoảng ngày. */
    public int getLogins(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countLogins(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLogins(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Số bản ghi audit log hôm nay. */
    public int getAuditLogsToday() {
        try {
            return Math.max(adminDAO.countAuditLogsToday(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAuditLogsToday - " + e.getMessage());
            return 0;
        }
    }

    /** Số bản ghi audit log trong khoảng ngày. */
    public int getAuditLogs(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countAuditLogs(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAuditLogs(range) - " + e.getMessage());
            return 0;
        }
    }

    /** Số lần truy cập bị từ chối hôm nay. */
    public int getAccessDeniedToday() {
        try {
            return Math.max(adminDAO.countAccessDeniedToday(), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAccessDeniedToday - " + e.getMessage());
            return 0;
        }
    }

    /** Số lần truy cập bị từ chối trong khoảng ngày. */
    public int getAccessDenied(LocalDate from, LocalDate to) {
        try {
            return Math.max(adminDAO.countAccessDenied(from, to), 0);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAccessDenied(range) - " + e.getMessage());
            return 0;
        }
    }

    // ──────────────────────────────────────────────
    // CHARTS DATA
    // ──────────────────────────────────────────────

    /** Biểu đồ xu hướng đăng nhập 7 ngày. */
    public Map<String, Integer> getLoginTrend7Days() {
        try {
            return adminDAO.getLoginTrend7Days();
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLoginTrend7Days - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ xu hướng đăng nhập theo khoảng ngày. */
    public Map<String, Integer> getLoginTrend(LocalDate from, LocalDate to) {
        try {
            return adminDAO.getLoginTrend(from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getLoginTrend - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ tăng trưởng tài khoản 12 tháng. */
    public Map<String, Integer> getAccountGrowth12Months() {
        try {
            return adminDAO.getAccountGrowth12Months();
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAccountGrowth12Months - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ tăng trưởng tài khoản theo ngày trong khoảng (7, 30 ngày...). */
    public Map<String, Integer> getAccountGrowthByDay(LocalDate from, LocalDate to) {
        try {
            return adminDAO.getAccountGrowthByDay(from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAccountGrowthByDay - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ tăng trưởng tài khoản 12 tháng tính đến endDate. */
    public Map<String, Integer> getAccountGrowthChart(LocalDate endDate) {
        try {
            return adminDAO.getAccountGrowthChart(endDate);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAccountGrowthChart - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ phân bố vai trò. */
    public Map<String, Integer> getRoleDistribution() {
        try {
            return adminDAO.getRoleDistribution();
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRoleDistribution - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ phân bố vai trò trong khoảng ngày. */
    public Map<String, Integer> getRoleDistribution(LocalDate from, LocalDate to) {
        try {
            return adminDAO.getRoleDistribution(from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRoleDistribution(range) - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ phân loại Audit Log (toàn thời gian). */
    public Map<String, Integer> getAuditLogClassification() {
        try {
            return adminDAO.getAuditLogClassification();
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAuditLogClassification - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Biểu đồ phân loại Audit Log trong khoảng ngày. */
    public Map<String, Integer> getAuditLogClassification(LocalDate from, LocalDate to) {
        try {
            return adminDAO.getAuditLogClassification(from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getAuditLogClassification(range) - " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    // ──────────────────────────────────────────────
    // BẢNG DỮ LIỆU
    // ──────────────────────────────────────────────

    /** Danh sách N người dùng mới nhất. */
    public List<AdminDashboardDAO.RecentUser> getRecentUsers(int limit) {
        try {
            return adminDAO.getRecentUsers(limit);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRecentUsers - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Danh sách N người dùng mới nhất trong khoảng ngày. */
    public List<AdminDashboardDAO.RecentUser> getRecentUsers(int limit, LocalDate from, LocalDate to) {
        try {
            return adminDAO.getRecentUsers(limit, from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRecentUsers(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Danh sách N audit log gần nhất. */
    public List<AdminDashboardDAO.RecentAuditLog> getRecentAuditLogs(int limit) {
        try {
            return adminDAO.getRecentAuditLogs(limit);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRecentAuditLogs - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Danh sách N audit log gần nhất trong khoảng ngày. */
    public List<AdminDashboardDAO.RecentAuditLog> getRecentAuditLogs(int limit, LocalDate from, LocalDate to) {
        try {
            return adminDAO.getRecentAuditLogs(limit, from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getRecentAuditLogs(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ──────────────────────────────────────────────
    // CẢNH BÁO HỆ THỐNG
    // ──────────────────────────────────────────────

    /** Danh sách cảnh báo hệ thống — LIVE MODE. */
    public List<AdminDashboardDAO.SystemAlert> getSystemAlerts() {
        try {
            return adminDAO.getSystemAlerts();
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getSystemAlerts - " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Danh sách cảnh báo hệ thống — CUSTOM RANGE. */
    public List<AdminDashboardDAO.SystemAlert> getSystemAlerts(LocalDate from, LocalDate to) {
        try {
            return adminDAO.getSystemAlerts(from, to);
        } catch (Exception e) {
            System.err.println("AdminDashboardService: Lỗi getSystemAlerts(range) - " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
