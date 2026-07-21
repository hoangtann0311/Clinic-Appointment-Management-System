package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.MedicineCategory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng medicine_categories — quản lý nhóm thuốc.
 */
public class MedicineCategoryDAO {

    /** Lấy tất cả category đang hoạt động (sắp xếp theo sort_order). */
    public List<MedicineCategory> findAll() {
        String sql = "SELECT id, category_name, description, icon, sort_order, is_active, created_at, updated_at "
                   + "FROM medicine_categories WHERE is_active = 1 ORDER BY sort_order";
        List<MedicineCategory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[MedicineCategoryDAO] findAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Lấy tất cả category kèm số lượng thuốc. */
    public List<MedicineCategory> findAllWithStats() {
        String sql = "SELECT mc.id, mc.category_name, mc.description, mc.icon, "
                   + "mc.sort_order, mc.is_active, mc.created_at, mc.updated_at, "
                   + "COUNT(m.id) AS medicine_count "
                   + "FROM medicine_categories mc "
                   + "LEFT JOIN medicines m ON m.category_id = mc.id AND m.is_active = 1 "
                   + "WHERE mc.is_active = 1 "
                   + "GROUP BY mc.id, mc.category_name, mc.description, mc.icon, mc.sort_order, mc.is_active, mc.created_at, mc.updated_at "
                   + "ORDER BY mc.sort_order";
        List<MedicineCategory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                MedicineCategory mc = mapRow(rs);
                mc.setMedicineCount(rs.getInt("medicine_count"));
                list.add(mc);
            }
        } catch (SQLException e) {
            System.err.println("[MedicineCategoryDAO] findAllWithStats ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    private MedicineCategory mapRow(ResultSet rs) throws SQLException {
        MedicineCategory mc = new MedicineCategory();
        mc.setId(rs.getInt("id"));
        mc.setCategoryName(rs.getString("category_name"));
        try { mc.setDescription(rs.getString("description")); } catch (SQLException e) { mc.setDescription(null); }
        try { mc.setIcon(rs.getString("icon")); } catch (SQLException e) { mc.setIcon(null); }
        try { mc.setSortOrder(rs.getInt("sort_order")); } catch (SQLException e) { mc.setSortOrder(0); }
        try { mc.setActive(rs.getBoolean("is_active")); } catch (SQLException e) { mc.setActive(true); }
        try { mc.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { mc.setCreatedAt(null); }
        try { mc.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { mc.setUpdatedAt(null); }
        return mc;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
        if (ps != null) { try { ps.close(); } catch (SQLException e) {} }
        DatabaseConfig.closeConnection(conn);
    }
}
