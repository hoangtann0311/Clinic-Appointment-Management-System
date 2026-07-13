package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.AuditLog;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng audit_logs — nhật ký hoạt động.
 * Hỗ trợ filter đa chiều: tìm kiếm, module (table_name), user, khoảng thời gian.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class AuditLogDAO {

    public void logAction(String action, String actor, String tableName, String oldValue, String newValue) {
        String sql = "INSERT INTO audit_logs " +
                "(user_id, action, table_name, old_value, new_value, ip_address, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setNull(1, java.sql.Types.INTEGER);
            ps.setString(2, action);
            ps.setString(3, tableName);
            ps.setString(4, oldValue);
            ps.setString(5, newValue);
            ps.setString(6, actor);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy danh sách audit log có phân trang + filter.
     *
     * @param offset     vị trí bắt đầu (phân trang)
     * @param pageSize   số bản ghi mỗi trang
     * @param search     từ khoá tìm kiếm (tìm trong action, user_name)
     * @param tableName  lọc theo bảng bị tác động (có thể null)
     * @param userId     lọc theo người thực hiện (có thể null)
     * @param dateFrom   lọc từ ngày (có thể null)
     * @param dateTo     lọc đến ngày (có thể null)
     * @return danh sách AuditLog, được JOIN với users và roles để lấy tên hiển thị
     */
    public List<AuditLog> findAll(int offset, int pageSize,
                                   String search, String tableName,
                                   Integer userId, Integer roleId,
                                   LocalDate dateFrom, LocalDate dateTo) {
        StringBuilder sql = new StringBuilder(
            "SELECT al.id, al.user_id, al.action, al.table_name, "
            + "al.old_value, al.new_value, al.ip_address, al.created_at, "
            + "ISNULL(u.full_name, N'Hệ Thống') AS user_name, "
            + "ISNULL(r.role_name, N'—') AS role_name "
            + "FROM audit_logs al "
            + "LEFT JOIN users u ON al.user_id = u.id "
            + "LEFT JOIN roles r ON u.role_id = r.id "
            + "WHERE 1=1 ");

        // Build WHERE clauses
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (al.action LIKE ? OR ISNULL(u.full_name, N'') LIKE ?) ");
        }
        if (tableName != null && !tableName.trim().isEmpty()) {
            sql.append("AND al.table_name = ? ");
        }
        if (userId != null && userId > 0) {
            sql.append("AND al.user_id = ? ");
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
        }
        if (dateFrom != null) {
            sql.append("AND al.created_at >= ? ");
        }
        if (dateTo != null) {
            sql.append("AND al.created_at < ? ");
        }

        sql.append("ORDER BY al.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<AuditLog> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;

            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setNString(idx++, like);
                ps.setNString(idx++, like);
            }
            if (tableName != null && !tableName.trim().isEmpty()) {
                ps.setNString(idx++, tableName.trim());
            }
            if (userId != null && userId > 0) {
                ps.setInt(idx++, userId);
            }
            if (roleId != null && roleId > 0) {
                ps.setInt(idx++, roleId);
            }
            if (dateFrom != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(dateFrom.atStartOfDay()));
            }
            if (dateTo != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(dateTo.plusDays(1).atStartOfDay()));
            }

            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] findAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Đếm tổng số bản ghi audit log với filter tương ứng (dùng cho phân trang).
     */
    public int countAll(String search, String tableName,
                        Integer userId, Integer roleId,
                        LocalDate dateFrom, LocalDate dateTo) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) AS total FROM audit_logs al "
            + "LEFT JOIN users u ON al.user_id = u.id "
            + "WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (al.action LIKE ? OR ISNULL(u.full_name, N'') LIKE ?) ");
        }
        if (tableName != null && !tableName.trim().isEmpty()) {
            sql.append("AND al.table_name = ? ");
        }
        if (userId != null && userId > 0) {
            sql.append("AND al.user_id = ? ");
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
        }
        if (dateFrom != null) {
            sql.append("AND al.created_at >= ? ");
        }
        if (dateTo != null) {
            sql.append("AND al.created_at < ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;

            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setNString(idx++, like);
                ps.setNString(idx++, like);
            }
            if (tableName != null && !tableName.trim().isEmpty()) {
                ps.setNString(idx++, tableName.trim());
            }
            if (userId != null && userId > 0) {
                ps.setInt(idx++, userId);
            }
            if (roleId != null && roleId > 0) {
                ps.setInt(idx++, roleId);
            }
            if (dateFrom != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(dateFrom.atStartOfDay()));
            }
            if (dateTo != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(dateTo.plusDays(1).atStartOfDay()));
            }

            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] countAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Tìm một audit log theo id (dùng cho xem chi tiết).
     */
    public AuditLog findById(int id) {
        String sql = "SELECT al.id, al.user_id, al.action, al.table_name, "
                   + "al.old_value, al.new_value, al.ip_address, al.created_at, "
                   + "ISNULL(u.full_name, N'Hệ Thống') AS user_name, "
                   + "ISNULL(r.role_name, N'—') AS role_name "
                   + "FROM audit_logs al "
                   + "LEFT JOIN users u ON al.user_id = u.id "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "WHERE al.id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Lấy danh sách các bảng (table_name) distinct đã từng được audit.
     * Dùng cho filter dropdown "Module".
     */
    public List<String> getDistinctTables() {
        String sql = "SELECT DISTINCT table_name FROM audit_logs "
                   + "WHERE table_name IS NOT NULL "
                   + "ORDER BY table_name";

        List<String> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("table_name"));
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] getDistinctTables ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Lấy danh sách user đã từng có hành động trong audit log.
     * Dùng cho filter dropdown "Người dùng".
     */
    public List<AuditLog> getDistinctUsers() {
        String sql = "SELECT DISTINCT al.user_id, ISNULL(u.full_name, N'Hệ Thống') AS user_name "
                   + "FROM audit_logs al "
                   + "LEFT JOIN users u ON al.user_id = u.id "
                   + "ORDER BY user_name";

        List<AuditLog> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                AuditLog log = new AuditLog();
                int uid = rs.getInt("user_id");
                log.setUserId(rs.wasNull() ? null : uid);
                log.setUserName(rs.getString("user_name"));
                list.add(log);
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] getDistinctUsers ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Lấy tất cả vai trò từ bảng roles — dùng cho filter dropdown "Vai trò".
     * Trả về đầy đủ 7 role (Admin, Doctor, Manager, Staff, Patient, Sonographer, Lab Technician).
     */
    public List<AuditLog> getAllRoles() {
        String sql = "SELECT id, role_name FROM roles ORDER BY id";

        List<AuditLog> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setUserId(rs.getInt("id"));         // tạm dùng userId field để chứa role_id
                log.setUserName(rs.getString("role_name")); // tạm dùng userName field để chứa role_name
                list.add(log);
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] getAllRoles ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Xoá các audit log cũ hơn N ngày.
     *
     * @param retentionDays số ngày giữ lại (xoá những bản ghi cũ hơn)
     * @return số bản ghi đã xoá
     */
    public int deleteOlderThan(int retentionDays) {
        String sql = "DELETE FROM audit_logs WHERE created_at < DATEADD(DAY, -?, GETDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, retentionDays);
            int deleted = ps.executeUpdate();
            if (deleted > 0) {
                System.out.println("[AuditLogDAO] Đã xoá " + deleted + " audit log cũ hơn " + retentionDays + " ngày.");
            }
            return deleted;
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] deleteOlderThan ERROR: " + e.getMessage());
            return 0;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ── Helper ──

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));

        int uid = rs.getInt("user_id");
        log.setUserId(rs.wasNull() ? null : uid);

        log.setAction(rs.getString("action"));
        log.setTableName(rs.getString("table_name"));
        log.setOldValue(rs.getString("old_value"));
        log.setNewValue(rs.getString("new_value"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setCreatedAt(rs.getTimestamp("created_at"));

        // Transient — hiển thị
        try { log.setUserName(rs.getString("user_name")); } catch (SQLException e) { log.setUserName("—"); }
        try { log.setRoleName(rs.getString("role_name")); } catch (SQLException e) { log.setRoleName("—"); }

        return log;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { /* ignore */ } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { /* ignore */ } }
        DatabaseConfig.closeConnection(conn);
    }
}
