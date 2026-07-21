package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.PriceHistory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng price_history — lịch sử điều chỉnh giá dịch vụ.
 */
public class PriceHistoryDAO {

    /** Ghi nhận một lần thay đổi giá. */
    public void insert(int serviceId, java.math.BigDecimal oldPrice,
                       java.math.BigDecimal newPrice, String changeReason, Integer changedBy) {
        String sql = "INSERT INTO price_history (service_id, old_price, new_price, change_reason, changed_by) "
                   + "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, serviceId);
            if (oldPrice != null) {
                ps.setBigDecimal(2, oldPrice);
            } else {
                ps.setNull(2, Types.DECIMAL);
            }
            ps.setBigDecimal(3, newPrice);
            ps.setString(4, changeReason);
            if (changedBy != null) {
                ps.setInt(5, changedBy);
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[PriceHistoryDAO] insert ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Lấy lịch sử giá của một dịch vụ (mới nhất trước). */
    public List<PriceHistory> findByServiceId(int serviceId) {
        String sql = "SELECT ph.id, ph.service_id, ph.old_price, ph.new_price, "
                   + "ph.change_reason, ph.changed_by, ph.created_at, "
                   + "s.service_name, s.service_code, "
                   + "u.full_name AS changed_by_name "
                   + "FROM price_history ph "
                   + "JOIN services s ON s.id = ph.service_id "
                   + "LEFT JOIN users u ON u.id = ph.changed_by "
                   + "WHERE ph.service_id = ? "
                   + "ORDER BY ph.created_at DESC";

        List<PriceHistory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, serviceId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PriceHistoryDAO] findByServiceId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Lấy tất cả lịch sử giá (dùng cho báo cáo). */
    public List<PriceHistory> findAll(int offset, int pageSize) {
        String sql = "SELECT ph.id, ph.service_id, ph.old_price, ph.new_price, "
                   + "ph.change_reason, ph.changed_by, ph.created_at, "
                   + "s.service_name, s.service_code, "
                   + "u.full_name AS changed_by_name "
                   + "FROM price_history ph "
                   + "JOIN services s ON s.id = ph.service_id "
                   + "LEFT JOIN users u ON u.id = ph.changed_by "
                   + "ORDER BY ph.created_at DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<PriceHistory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PriceHistoryDAO] findAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Đếm tổng số bản ghi lịch sử giá. */
    public int countAll() {
        String sql = "SELECT COUNT(*) AS total FROM price_history";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[PriceHistoryDAO] countAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private PriceHistory mapRow(ResultSet rs) throws SQLException {
        PriceHistory ph = new PriceHistory();
        ph.setId(rs.getInt("id"));
        ph.setServiceId(rs.getInt("service_id"));
        ph.setOldPrice(rs.getBigDecimal("old_price"));
        ph.setNewPrice(rs.getBigDecimal("new_price"));
        ph.setCreatedAt(rs.getTimestamp("created_at"));
        try { ph.setChangeReason(rs.getString("change_reason")); } catch (SQLException e) { ph.setChangeReason(null); }
        try { ph.setChangedBy(rs.getInt("changed_by")); } catch (SQLException e) { ph.setChangedBy(null); }
        try { ph.setServiceName(rs.getString("service_name")); } catch (SQLException e) { ph.setServiceName(null); }
        try { ph.setServiceCode(rs.getString("service_code")); } catch (SQLException e) { ph.setServiceCode(null); }
        try { ph.setChangedByName(rs.getString("changed_by_name")); } catch (SQLException e) { ph.setChangedByName(null); }
        return ph;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
