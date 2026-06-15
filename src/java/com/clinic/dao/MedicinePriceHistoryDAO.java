package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.MedicinePriceHistory;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng medicine_price_history — lịch sử điều chỉnh giá thuốc.
 */
public class MedicinePriceHistoryDAO {

    /** Ghi nhận một lần thay đổi giá thuốc. */
    public void insert(int medicineId, BigDecimal oldPrice,
                       BigDecimal newPrice, String changeReason, Integer changedBy) {
        String sql = "INSERT INTO medicine_price_history (medicine_id, old_price, new_price, change_reason, changed_by) "
                   + "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, medicineId);
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
            System.err.println("[MedicinePriceHistoryDAO] insert ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Lấy lịch sử giá của một thuốc (mới nhất trước). */
    public List<MedicinePriceHistory> findByMedicineId(int medicineId) {
        String sql = "SELECT mph.id, mph.medicine_id, mph.old_price, mph.new_price, "
                   + "mph.change_reason, mph.changed_by, mph.created_at, "
                   + "m.name AS medicine_name, m.medicine_code, "
                   + "u.full_name AS changed_by_name "
                   + "FROM medicine_price_history mph "
                   + "JOIN medicines m ON m.id = mph.medicine_id "
                   + "LEFT JOIN users u ON u.id = mph.changed_by "
                   + "WHERE mph.medicine_id = ? "
                   + "ORDER BY mph.created_at DESC";

        List<MedicinePriceHistory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, medicineId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid object name") || msg.contains("invalid column")) {
                System.err.println("[MedicinePriceHistoryDAO] Table not yet migrated: " + msg);
            } else {
                System.err.println("[MedicinePriceHistoryDAO] findByMedicineId ERROR: " + msg);
            }
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Lấy tất cả lịch sử giá thuốc (phân trang). */
    public List<MedicinePriceHistory> findAll(int offset, int pageSize) {
        String sql = "SELECT mph.id, mph.medicine_id, mph.old_price, mph.new_price, "
                   + "mph.change_reason, mph.changed_by, mph.created_at, "
                   + "m.name AS medicine_name, m.medicine_code, "
                   + "u.full_name AS changed_by_name "
                   + "FROM medicine_price_history mph "
                   + "JOIN medicines m ON m.id = mph.medicine_id "
                   + "LEFT JOIN users u ON u.id = mph.changed_by "
                   + "ORDER BY mph.created_at DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<MedicinePriceHistory> list = new ArrayList<>();
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
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid object name") || msg.contains("invalid column")) {
                System.err.println("[MedicinePriceHistoryDAO] Table not yet migrated: " + msg);
            } else {
                System.err.println("[MedicinePriceHistoryDAO] findAll ERROR: " + msg);
            }
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Đếm tổng số bản ghi lịch sử giá thuốc. */
    public int countAll() {
        String sql = "SELECT COUNT(*) AS total FROM medicine_price_history";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[MedicinePriceHistoryDAO] countAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private MedicinePriceHistory mapRow(ResultSet rs) throws SQLException {
        MedicinePriceHistory mph = new MedicinePriceHistory();
        mph.setId(rs.getInt("id"));
        mph.setMedicineId(rs.getInt("medicine_id"));
        mph.setOldPrice(rs.getBigDecimal("old_price"));
        mph.setNewPrice(rs.getBigDecimal("new_price"));
        mph.setCreatedAt(rs.getTimestamp("created_at"));
        try { mph.setChangeReason(rs.getString("change_reason")); } catch (SQLException e) { mph.setChangeReason(null); }
        try { mph.setChangedBy(rs.getInt("changed_by")); } catch (SQLException e) { mph.setChangedBy(null); }
        try { mph.setMedicineName(rs.getString("medicine_name")); } catch (SQLException e) { mph.setMedicineName(null); }
        try { mph.setMedicineCode(rs.getString("medicine_code")); } catch (SQLException e) { mph.setMedicineCode(null); }
        try { mph.setChangedByName(rs.getString("changed_by_name")); } catch (SQLException e) { mph.setChangedByName(null); }
        return mph;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
