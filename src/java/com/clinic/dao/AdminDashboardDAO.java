package com.clinic.dao;

import com.clinic.config.DatabaseConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO tổng hợp dữ liệu cho Dashboard Admin (System Administration).
 *
 * <p><b>Phạm vi nghiệp vụ:</b> Quản trị hệ thống — không tham gia vào
 * nghiệp vụ khám chữa bệnh hay vận hành phòng khám. Admin giám sát:
 * <ul>
 *   <li>Người dùng & tài khoản (số lượng, trạng thái, tăng trưởng)</li>
 *   <li>Phân quyền (Role, Permission)</li>
 *   <li>Bảo mật & giám sát (Audit Log, đăng nhập, hành vi bất thường)</li>
 *   <li>Trạng thái hệ thống (cảnh báo, lỗi)</li>
 * </ul>
 *
 * <p>Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class AdminDashboardDAO {

    // ──────────────────────────────────────────────
    // KPI: TỔNG SỐ TÀI KHOẢN
    // ──────────────────────────────────────────────

    /** Tổng số tài khoản trong hệ thống (không tính đã xóa mềm). */
    public int countTotalAccounts() {
        String sql = "SELECT COUNT(*) AS total FROM users WHERE is_deleted = 0";
        return executeCount(sql);
    }

    /** Tổng số tài khoản được tạo trong khoảng ngày. */
    public int countTotalAccounts(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE is_deleted = 0 AND created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: TÀI KHOẢN ĐANG HOẠT ĐỘNG
    // ──────────────────────────────────────────────

    /** Số tài khoản đang Active. */
    public int countActiveAccounts() {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE status = 'Active' AND is_deleted = 0";
        return executeCount(sql);
    }

    /** Số tài khoản Active trong khoảng ngày (tạo trong khoảng và hiện Active). */
    public int countActiveAccounts(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE status = 'Active' AND is_deleted = 0 "
                   + "AND created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: TÀI KHOẢN BỊ KHÓA
    // ──────────────────────────────────────────────

    /** Số tài khoản đang bị khóa. */
    public int countLockedAccounts() {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE status = 'LOCKED' AND is_deleted = 0";
        return executeCount(sql);
    }

    /** Số tài khoản bị khóa trong khoảng ngày. */
    public int countLockedAccounts(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE status = 'LOCKED' AND is_deleted = 0 "
                   + "AND created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: TÀI KHOẢN CHƯA XÁC THỰC
    // ──────────────────────────────────────────────

    /** Số tài khoản chưa xác thực email. */
    public int countUnverifiedAccounts() {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE is_verified = 0 AND status = 'PENDING_VERIFICATION' "
                   + "AND is_deleted = 0";
        return executeCount(sql);
    }

    /** Số tài khoản chưa xác thực email trong khoảng ngày. */
    public int countUnverifiedAccounts(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM users "
                   + "WHERE is_verified = 0 AND status = 'PENDING_VERIFICATION' "
                   + "AND is_deleted = 0 "
                   + "AND created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: TỔNG SỐ VAI TRÒ (ROLE)
    // ──────────────────────────────────────────────

    /** Tổng số vai trò trong hệ thống. */
    public int countRoles() {
        String sql = "SELECT COUNT(*) AS total FROM roles";
        return executeCount(sql);
    }

    /** Tổng số vai trò được tạo trong khoảng ngày. */
    public int countRoles(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM roles "
                   + "WHERE created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: TỔNG SỐ QUYỀN (PERMISSION)
    // ──────────────────────────────────────────────

    /** Tổng số quyền trong hệ thống. */
    public int countPermissions() {
        String sql = "SELECT COUNT(*) AS total FROM permissions";
        return executeCount(sql);
    }

    /** Tổng số quyền được tạo trong khoảng ngày. */
    public int countPermissions(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM permissions "
                   + "WHERE created_at >= ? AND created_at <= ?";
        return executeCount(sql, from, to);
    }

    // ──────────────────────────────────────────────
    // KPI: SỐ LƯỢT ĐĂNG NHẬP TRONG NGÀY
    // ──────────────────────────────────────────────

    /** Số lượt đăng nhập hôm nay (từ audit_logs). */
    public int countLoginsToday() {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE (action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' "
                   + "       OR action LIKE '%login%') "
                   + "AND created_at >= CAST(GETDATE() AS DATE) "
                   + "AND created_at < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))";
        return executeCount(sql);
    }

    /** Số lượt đăng nhập trong khoảng ngày. */
    public int countLogins(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE (action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' "
                   + "       OR action LIKE '%login%') "
                   + "AND created_at >= ? AND created_at < ?";
        return executeCount(sql, from, to.plusDays(1));
    }

    // ──────────────────────────────────────────────
    // KPI: SỐ BẢN GHI AUDIT LOG TRONG NGÀY
    // ──────────────────────────────────────────────

    /** Tổng số audit log hôm nay. */
    public int countAuditLogsToday() {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE created_at >= CAST(GETDATE() AS DATE) "
                   + "AND created_at < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))";
        return executeCount(sql);
    }

    /** Tổng số audit log trong khoảng ngày. */
    public int countAuditLogs(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE created_at >= ? AND created_at < ?";
        return executeCount(sql, from, to.plusDays(1));
    }

    // ──────────────────────────────────────────────
    // KPI: SỐ LƯỢT TRUY CẬP BỊ TỪ CHỐI (ACCESS_DENIED)
    // ──────────────────────────────────────────────

    /** Số lần truy cập bị từ chối hôm nay. */
    public int countAccessDeniedToday() {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE (action LIKE N'%Truy cập bị từ chối%' OR action LIKE '%ACCESS_DENIED%') "
                   + "AND created_at >= CAST(GETDATE() AS DATE) "
                   + "AND created_at < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))";
        return executeCount(sql);
    }

    /** Số lần truy cập bị từ chối trong khoảng ngày. */
    public int countAccessDenied(LocalDate from, LocalDate to) {
        String sql = "SELECT COUNT(*) AS total FROM audit_logs "
                   + "WHERE (action LIKE N'%Truy cập bị từ chối%' OR action LIKE '%ACCESS_DENIED%') "
                   + "AND created_at >= ? AND created_at < ?";
        return executeCount(sql, from, to.plusDays(1));
    }

    // ══════════════════════════════════════════════
    // CHARTS DATA
    // ══════════════════════════════════════════════

    /**
     * Biểu đồ xu hướng đăng nhập — 7 ngày gần nhất.
     * Trả về Map<ngày (dd/MM), số lượt đăng nhập>.
     */
    public Map<String, Integer> getLoginTrend7Days() {
        String sql = "SELECT CAST(created_at AS DATE) AS login_date, COUNT(*) AS cnt "
                   + "FROM audit_logs "
                   + "WHERE (action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' "
                   + "       OR action LIKE '%login%') "
                   + "AND created_at >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) "
                   + "AND created_at < DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) "
                   + "GROUP BY CAST(created_at AS DATE) "
                   + "ORDER BY login_date";

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
                java.sql.Date date = rs.getDate("login_date");
                int count = rs.getInt("cnt");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, count);
                }
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getLoginTrend7Days - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Biểu đồ xu hướng đăng nhập — khoảng ngày tùy chọn.
     */
    public Map<String, Integer> getLoginTrend(LocalDate from, LocalDate to) {
        String sql = "SELECT CAST(created_at AS DATE) AS login_date, COUNT(*) AS cnt "
                   + "FROM audit_logs "
                   + "WHERE (action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' "
                   + "       OR action LIKE '%login%') "
                   + "AND created_at >= ? AND created_at < ? "
                   + "GROUP BY CAST(created_at AS DATE) "
                   + "ORDER BY login_date";

        Map<String, Integer> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            result.put(d.format(fmt), 0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to.plusDays(1)));
            rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date date = rs.getDate("login_date");
                int count = rs.getInt("cnt");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, count);
                }
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getLoginTrend - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Biểu đồ tăng trưởng tài khoản — 12 tháng gần nhất.
     * Trả về Map<tháng (MM/yyyy), số tài khoản được tạo trong tháng đó>.
     */
    public Map<String, Integer> getAccountGrowth12Months() {
        return getAccountGrowthChart(LocalDate.now());
    }

    /**
     * Biểu đồ tăng trưởng tài khoản — 12 tháng tính đến endDate.
     */
    public Map<String, Integer> getAccountGrowthChart(LocalDate endDate) {
        String sql = "SELECT YEAR(created_at) AS yr, MONTH(created_at) AS mth, COUNT(*) AS cnt "
                   + "FROM users "
                   + "WHERE is_deleted = 0 AND created_at >= ? AND created_at <= ? "
                   + "GROUP BY YEAR(created_at), MONTH(created_at) "
                   + "ORDER BY yr, mth";

        Map<String, Integer> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM/yyyy");
        LocalDate startMonth = endDate.minusMonths(11).withDayOfMonth(1);
        for (LocalDate d = startMonth; !d.isAfter(endDate); d = d.plusMonths(1)) {
            result.put(d.format(fmt), 0);
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
                int count = rs.getInt("cnt");
                String key = String.format("%02d/%d", mth, yr);
                result.put(key, count);
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getAccountGrowthChart - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Biểu đồ phân bố vai trò — số lượng user theo từng role.
     * Trả về Map<roleName, count>.
     */
    public Map<String, Integer> getRoleDistribution() {
        String sql = "SELECT ISNULL(r.role_name, N'Chưa gán') AS role_name, COUNT(*) AS cnt "
                   + "FROM users u "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.is_deleted = 0 "
                   + "GROUP BY r.role_name "
                   + "ORDER BY cnt DESC";

        Map<String, Integer> result = new LinkedHashMap<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                result.put(rs.getString("role_name"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getRoleDistribution - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Biểu đồ phân bố vai trò trong khoảng ngày — số lượng user theo từng role
     * được tạo trong khoảng ngày.
     */
    public Map<String, Integer> getRoleDistribution(LocalDate from, LocalDate to) {
        String sql = "SELECT ISNULL(r.role_name, N'Chưa gán') AS role_name, COUNT(*) AS cnt "
                   + "FROM users u "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.is_deleted = 0 "
                   + "AND u.created_at >= ? AND u.created_at <= ? "
                   + "GROUP BY r.role_name "
                   + "ORDER BY cnt DESC";

        Map<String, Integer> result = new LinkedHashMap<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            rs = ps.executeQuery();
            while (rs.next()) {
                result.put(rs.getString("role_name"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getRoleDistribution(range) - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Biểu đồ phân loại Audit Log — đếm theo loại hành động.
     * Phân loại: LOGIN, CREATE, UPDATE, DELETE, ACCESS_DENIED, EXPORT, OTHER.
     */
    public Map<String, Integer> getAuditLogClassification() {
        return getAuditLogClassification(null, null);
    }

    /**
     * Biểu đồ phân loại Audit Log trong khoảng ngày.
     */
    public Map<String, Integer> getAuditLogClassification(LocalDate from, LocalDate to) {
        // Dùng CASE để phân loại audit log theo action
        StringBuilder sql = new StringBuilder(
            "SELECT "
            + "CASE "
            + "  WHEN action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' OR action LIKE '%login%' THEN N'Đăng Nhập' "
            + "  WHEN action LIKE N'%Truy cập bị từ chối%' OR action LIKE '%ACCESS_DENIED%' THEN N'Truy cập bị từ chối' "
            + "  WHEN action LIKE N'%tạo%' OR action LIKE N'%thêm%' OR action LIKE '%CREATE%' "
            + "       OR action LIKE N'%đăng ký%' OR action LIKE '%INSERT%' THEN N'Tạo Mới' "
            + "  WHEN action LIKE N'%sửa%' OR action LIKE N'%cập nhật%' OR action LIKE '%UPDATE%' "
            + "       OR action LIKE N'%chỉnh%' OR action LIKE '%EDIT%' THEN N'Cập Nhật' "
            + "  WHEN action LIKE N'%xoá%' OR action LIKE N'%xóa%' OR action LIKE '%DELETE%' "
            + "       OR action LIKE N'%vô hiệu%' OR action LIKE '%REMOVE%' THEN N'Xóa' "
            + "  WHEN action LIKE N'%xuất%' OR action LIKE '%EXPORT%' THEN N'Xuất Báo Cáo' "
            + "  WHEN action LIKE N'%duyệt%' OR action LIKE '%APPROVE%' THEN N'Phê Duyệt' "
            + "  WHEN action LIKE N'%khoá%' OR action LIKE N'%mở khoá%' OR action LIKE '%LOCK%' "
            + "       OR action LIKE '%UNLOCK%' THEN N'Khóa/Mở Khóa' "
            + "  ELSE N'Khác' "
            + "END AS category, "
            + "COUNT(*) AS cnt "
            + "FROM audit_logs WHERE 1=1 ");

        boolean hasDateFilter = (from != null && to != null);
        if (hasDateFilter) {
            sql.append("AND created_at >= ? AND created_at < ? ");
        }
        sql.append("GROUP BY "
                + "CASE "
                + "  WHEN action LIKE N'%đăng nhập%' OR action LIKE '%LOGIN%' OR action LIKE '%login%' THEN N'Đăng Nhập' "
                + "  WHEN action LIKE N'%Truy cập bị từ chối%' OR action LIKE '%ACCESS_DENIED%' THEN N'Truy cập bị từ chối' "
                + "  WHEN action LIKE N'%tạo%' OR action LIKE N'%thêm%' OR action LIKE '%CREATE%' "
                + "       OR action LIKE N'%đăng ký%' OR action LIKE '%INSERT%' THEN N'Tạo Mới' "
                + "  WHEN action LIKE N'%sửa%' OR action LIKE N'%cập nhật%' OR action LIKE '%UPDATE%' "
                + "       OR action LIKE N'%chỉnh%' OR action LIKE '%EDIT%' THEN N'Cập Nhật' "
                + "  WHEN action LIKE N'%xoá%' OR action LIKE N'%xóa%' OR action LIKE '%DELETE%' "
                + "       OR action LIKE N'%vô hiệu%' OR action LIKE '%REMOVE%' THEN N'Xóa' "
                + "  WHEN action LIKE N'%xuất%' OR action LIKE '%EXPORT%' THEN N'Xuất Báo Cáo' "
                + "  WHEN action LIKE N'%duyệt%' OR action LIKE '%APPROVE%' THEN N'Phê Duyệt' "
                + "  WHEN action LIKE N'%khoá%' OR action LIKE N'%mở khoá%' OR action LIKE '%LOCK%' "
                + "       OR action LIKE '%UNLOCK%' THEN N'Khóa/Mở Khóa' "
                + "  ELSE N'Khác' "
                + "END "
                + "ORDER BY cnt DESC");

        // Thứ tự hiển thị cố định cho nhất quán
        Map<String, Integer> result = new LinkedHashMap<>();
        result.put("Đăng Nhập", 0);
        result.put("Tạo Mới", 0);
        result.put("Cập Nhật", 0);
        result.put("Xóa", 0);
        result.put("Phê Duyệt", 0);
        result.put("Xuất Báo Cáo", 0);
        result.put("Khóa/Mở Khóa", 0);
        result.put("Truy cập bị từ chối", 0);
        result.put("Khác", 0);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (hasDateFilter) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                ps.setDate(2, java.sql.Date.valueOf(to.plusDays(1)));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                String category = rs.getString("category");
                int count = rs.getInt("cnt");
                result.put(category, count);
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getAuditLogClassification - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    // ══════════════════════════════════════════════
    // BẢNG: NGƯỜI DÙNG MỚI NHẤT
    // ══════════════════════════════════════════════

    /**
     * DTO cho người dùng mới đăng ký hiển thị trên Admin dashboard.
     */
    public static class RecentUser {
        private int id;
        private String fullName;
        private String email;
        private String roleName;
        private String status;
        private String createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getRoleName() { return roleName; }
        public void setRoleName(String roleName) { this.roleName = roleName; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }

    /**
     * Lấy danh sách N người dùng mới nhất (tất cả role).
     */
    public List<RecentUser> getRecentUsers(int limit) {
        return getRecentUsers(limit, null, null);
    }

    /**
     * Lấy danh sách N người dùng mới nhất trong khoảng ngày.
     */
    public List<RecentUser> getRecentUsers(int limit, LocalDate from, LocalDate to) {
        boolean hasDateFilter = (from != null && to != null);
        StringBuilder sql = new StringBuilder(
            "SELECT TOP (?) u.id, u.full_name, "
            + "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('ClinicAppKey2026!', u.email)) AS email, "
            + "ISNULL(r.role_name, N'Chưa gán') AS role_name, u.status, u.created_at "
            + "FROM users u "
            + "LEFT JOIN roles r ON u.role_id = r.id "
            + "WHERE u.is_deleted = 0 ");
        if (hasDateFilter) {
            sql.append("AND u.created_at >= ? AND u.created_at <= ? ");
        }
        sql.append("ORDER BY u.id DESC");

        List<RecentUser> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, limit);
            if (hasDateFilter) {
                ps.setDate(2, java.sql.Date.valueOf(from));
                ps.setDate(3, java.sql.Date.valueOf(to));
            }
            rs = ps.executeQuery();
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            while (rs.next()) {
                RecentUser ru = new RecentUser();
                ru.id = rs.getInt("id");
                ru.fullName = rs.getString("full_name");
                ru.email = rs.getString("email");
                ru.roleName = rs.getString("role_name");
                ru.status = rs.getString("status");
                try {
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        ru.createdAt = ts.toLocalDateTime().format(fmt);
                    }
                } catch (SQLException e) {
                    ru.createdAt = "—";
                }
                list.add(ru);
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getRecentUsers - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ══════════════════════════════════════════════
    // BẢNG: AUDIT LOG GẦN ĐÂY
    // ══════════════════════════════════════════════

    /**
     * DTO cho audit log hiển thị trên Admin dashboard.
     */
    public static class RecentAuditLog {
        private int id;
        private String userName;
        private String roleName;
        private String action;
        private String tableName;
        private String ipAddress;
        private String createdAt;
        private String actionType; // LOGIN, CREATE, UPDATE, DELETE, DENIED, EXPORT, OTHER

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getUserName() { return userName; }
        public void setUserName(String userName) { this.userName = userName; }
        public String getRoleName() { return roleName; }
        public void setRoleName(String roleName) { this.roleName = roleName; }
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        public String getTableName() { return tableName; }
        public void setTableName(String tableName) { this.tableName = tableName; }
        public String getIpAddress() { return ipAddress; }
        public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
        public String getActionType() { return actionType; }
        public void setActionType(String actionType) { this.actionType = actionType; }
    }

    /**
     * Lấy N audit log gần nhất (kèm user name, role name, IP).
     */
    public List<RecentAuditLog> getRecentAuditLogs(int limit) {
        return getRecentAuditLogs(limit, null, null);
    }

    /**
     * Lấy N audit log gần nhất trong khoảng ngày.
     */
    public List<RecentAuditLog> getRecentAuditLogs(int limit, LocalDate from, LocalDate to) {
        boolean hasDateFilter = (from != null && to != null);
        StringBuilder sql = new StringBuilder(
            "SELECT TOP (?) al.id, al.action, al.table_name, al.ip_address, al.created_at, "
            + "ISNULL(u.full_name, N'Hệ Thống') AS user_name, "
            + "ISNULL(r.role_name, N'—') AS role_name "
            + "FROM audit_logs al "
            + "LEFT JOIN users u ON al.user_id = u.id "
            + "LEFT JOIN roles r ON u.role_id = r.id "
            + "WHERE 1=1 ");
        if (hasDateFilter) {
            sql.append("AND al.created_at >= ? AND al.created_at < ? ");
        }
        sql.append("ORDER BY al.id DESC");

        List<RecentAuditLog> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, limit);
            if (hasDateFilter) {
                ps.setDate(2, java.sql.Date.valueOf(from));
                ps.setDate(3, java.sql.Date.valueOf(to.plusDays(1)));
            }
            rs = ps.executeQuery();
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            while (rs.next()) {
                RecentAuditLog log = new RecentAuditLog();
                log.id = rs.getInt("id");
                log.userName = rs.getString("user_name");
                log.roleName = rs.getString("role_name");
                log.action = rs.getString("action");
                log.tableName = rs.getString("table_name");
                log.ipAddress = rs.getString("ip_address");
                log.actionType = classifyAction(rs.getString("action"));
                try {
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        log.createdAt = ts.toLocalDateTime().format(fmt);
                    }
                } catch (SQLException e) {
                    log.createdAt = "—";
                }
                list.add(log);
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO: Lỗi getRecentAuditLogs - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ══════════════════════════════════════════════
    // CẢNH BÁO HỆ THỐNG (System Alerts)
    // ══════════════════════════════════════════════

    /**
     * DTO cho một cảnh báo hệ thống.
     */
    public static class SystemAlert {
        private String type;       // danger, warning, info, success
        private String icon;       // bootstrap icon class
        private String title;
        private String message;
        private int count;
        private String link;       // link đến trang xử lý (có thể null)

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getIcon() { return icon; }
        public void setIcon(String icon) { this.icon = icon; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }
        public String getLink() { return link; }
        public void setLink(String link) { this.link = link; }
    }

    /**
     * Lấy danh sách cảnh báo hệ thống — LIVE MODE (không lọc ngày).
     */
    public List<SystemAlert> getSystemAlerts() {
        List<SystemAlert> alerts = new ArrayList<>();

        // 1. Tài khoản bị khóa
        int locked = countLockedAccounts();
        if (locked > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "danger";
            a.icon = "bi-lock-fill";
            a.title = "Tài khoản bị khóa";
            a.message = "Có " + locked + " tài khoản đang bị khóa, cần được xem xét mở khóa.";
            a.count = locked;
            a.link = "/admin/users/?status=LOCKED";
            alerts.add(a);
        }

        // 2. Tài khoản chưa xác thực email
        int unverified = countUnverifiedAccounts();
        if (unverified > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "warning";
            a.icon = "bi-envelope-exclamation";
            a.title = "Tài khoản chưa xác thực";
            a.message = "Có " + unverified + " tài khoản đang chờ xác thực email.";
            a.count = unverified;
            a.link = "/admin/users/?status=PENDING_VERIFICATION";
            alerts.add(a);
        }

        // 3. Truy cập bị từ chối hôm nay — dấu hiệu tấn công hoặc sai permission
        int denied = countAccessDeniedToday();
        if (denied > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "warning";
            a.icon = "bi-shield-exclamation";
            a.title = "Truy cập bị từ chối";
            a.message = "Có " + denied + " lần truy cập bị từ chối trong hôm nay.";
            a.count = denied;
            a.link = "/admin/audit-logs/";
            alerts.add(a);
        }

        // 4. Tài khoản không có role (role_id NULL hoặc role không tồn tại)
        int orphanAccounts = executeCount(
            "SELECT COUNT(*) AS total FROM users u "
            + "WHERE u.is_deleted = 0 AND (u.role_id IS NULL "
            + "OR NOT EXISTS (SELECT 1 FROM roles r WHERE r.id = u.role_id))");
        if (orphanAccounts > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "danger";
            a.icon = "bi-person-x";
            a.title = "Tài khoản thiếu vai trò";
            a.message = "Có " + orphanAccounts + " tài khoản chưa được gán vai trò hợp lệ.";
            a.count = orphanAccounts;
            a.link = "/admin/users/";
            alerts.add(a);
        }

        // 5. Đăng nhập thất bại — phát hiện từ audit log
        // (nếu có ghi nhận login failure trong audit_logs)
        int failedLogins = executeCount(
            "SELECT COUNT(*) AS total FROM audit_logs "
            + "WHERE (action LIKE N'%thất bại%' OR action LIKE '%FAIL%' "
            + "       OR action LIKE N'%sai mật khẩu%' OR action LIKE '%wrong password%') "
            + "AND created_at >= CAST(GETDATE() AS DATE)");
        if (failedLogins > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "danger";
            a.icon = "bi-exclamation-triangle-fill";
            a.title = "Đăng nhập thất bại";
            a.message = "Có " + failedLogins + " lần đăng nhập thất bại trong hôm nay.";
            a.count = failedLogins;
            a.link = "/admin/audit-logs/";
            alerts.add(a);
        }

        return alerts;
    }

    /**
     * Lấy danh sách cảnh báo hệ thống — CUSTOM RANGE (lọc theo khoảng ngày).
     */
    public List<SystemAlert> getSystemAlerts(LocalDate from, LocalDate to) {
        List<SystemAlert> alerts = new ArrayList<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String rangeLabel = from.format(fmt) + " → " + to.format(fmt);

        int locked = countLockedAccounts(from, to);
        if (locked > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "danger";
            a.icon = "bi-lock-fill";
            a.title = "Tài khoản bị khóa";
            a.message = "Có " + locked + " tài khoản bị khóa trong khoảng (" + rangeLabel + ").";
            a.count = locked;
            a.link = "/admin/users/?status=LOCKED";
            alerts.add(a);
        }

        int denied = countAccessDenied(from, to);
        if (denied > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "warning";
            a.icon = "bi-shield-exclamation";
            a.title = "Truy cập bị từ chối";
            a.message = "Có " + denied + " lần truy cập bị từ chối (" + rangeLabel + ").";
            a.count = denied;
            a.link = "/admin/audit-logs/";
            alerts.add(a);
        }

        int failedLogins = executeCount(
            "SELECT COUNT(*) AS total FROM audit_logs "
            + "WHERE (action LIKE N'%thất bại%' OR action LIKE '%FAIL%' "
            + "       OR action LIKE N'%sai mật khẩu%' OR action LIKE '%wrong password%') "
            + "AND created_at >= ? AND created_at < ?", from, to.plusDays(1));
        if (failedLogins > 0) {
            SystemAlert a = new SystemAlert();
            a.type = "danger";
            a.icon = "bi-exclamation-triangle-fill";
            a.title = "Đăng nhập thất bại";
            a.message = "Có " + failedLogins + " lần đăng nhập thất bại (" + rangeLabel + ").";
            a.count = failedLogins;
            a.link = "/admin/audit-logs/";
            alerts.add(a);
        }

        return alerts;
    }

    // ══════════════════════════════════════════════
    // HELPER METHODS
    // ══════════════════════════════════════════════

    /**
     * Phân loại action thành type để hiển thị badge màu.
     */
    private String classifyAction(String action) {
        if (action == null) return "OTHER";
        String lower = action.toLowerCase();
        if (lower.contains("đăng nhập") || lower.contains("login")) return "LOGIN";
        if (lower.contains("access_denied")) return "DENIED";
        if (lower.contains("tạo") || lower.contains("thêm") || lower.contains("đăng ký")
                || lower.contains("create") || lower.contains("insert")) return "CREATE";
        if (lower.contains("sửa") || lower.contains("cập nhật") || lower.contains("chỉnh")
                || lower.contains("update") || lower.contains("edit")) return "UPDATE";
        if (lower.contains("xoá") || lower.contains("xóa") || lower.contains("vô hiệu")
                || lower.contains("delete") || lower.contains("remove") || lower.contains("deactivate")) return "DELETE";
        if (lower.contains("xuất") || lower.contains("export")) return "EXPORT";
        if (lower.contains("duyệt") || lower.contains("approve")) return "APPROVE";
        if (lower.contains("khoá") || lower.contains("mở khoá") || lower.contains("lock")
                || lower.contains("unlock") || lower.contains("toggle")) return "TOGGLE";
        return "OTHER";
    }

    private int executeCount(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO executeCount: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private int executeCount(String sql, LocalDate from, LocalDate to) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("AdminDashboardDAO executeCount(range): " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { /* ignore */ }
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) { /* ignore */ }
        }
        DatabaseConfig.closeConnection(conn);
    }
}
