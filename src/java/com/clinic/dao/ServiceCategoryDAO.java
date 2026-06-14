package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.ServiceCategory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng service_categories — quản lý nhóm dịch vụ y tế.
 */
public class ServiceCategoryDAO {

    /** Lấy tất cả category đang hoạt động (sắp xếp theo sort_order). */
    public List<ServiceCategory> findAll() {
        String sql = "SELECT sc.id, sc.category_name, sc.description, sc.icon, "
                   + "sc.sort_order, sc.is_active, sc.created_at, sc.updated_at, "
                   + "(SELECT COUNT(*) FROM services s WHERE s.category_id = sc.id) AS service_count "
                   + "FROM service_categories sc WHERE sc.is_active = 1 ORDER BY sc.sort_order";

        List<ServiceCategory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ServiceCategoryDAO] findAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Lấy category theo id. */
    public ServiceCategory findById(int id) {
        String sql = "SELECT id, category_name, description, icon, sort_order, is_active, created_at, updated_at "
                   + "FROM service_categories WHERE id = ?";

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
            System.err.println("[ServiceCategoryDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /** Lấy tất cả category kèm thống kê. */
    public List<ServiceCategory> findAllWithStats() {
        String sql = "SELECT sc.id, sc.category_name, sc.description, sc.icon, "
                   + "sc.sort_order, sc.is_active, sc.created_at, sc.updated_at, "
                   + "COUNT(s.id) AS service_count "
                   + "FROM service_categories sc "
                   + "LEFT JOIN services s ON s.category_id = sc.id AND s.is_active = 1 "
                   + "WHERE sc.is_active = 1 "
                   + "GROUP BY sc.id, sc.category_name, sc.description, sc.icon, sc.sort_order, sc.is_active, sc.created_at, sc.updated_at "
                   + "ORDER BY sc.sort_order";

        List<ServiceCategory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceCategory cat = mapRow(rs);
                cat.setServiceCount(rs.getInt("service_count"));
                list.add(cat);
            }
        } catch (SQLException e) {
            System.err.println("[ServiceCategoryDAO] findAllWithStats ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    private ServiceCategory mapRow(ResultSet rs) throws SQLException {
        ServiceCategory cat = new ServiceCategory();
        cat.setId(rs.getInt("id"));
        cat.setCategoryName(rs.getString("category_name"));
        try { cat.setDescription(rs.getString("description")); } catch (SQLException e) { cat.setDescription(null); }
        try { cat.setIcon(rs.getString("icon")); } catch (SQLException e) { cat.setIcon(null); }
        try { cat.setSortOrder(rs.getInt("sort_order")); } catch (SQLException e) { cat.setSortOrder(0); }
        try { cat.setActive(rs.getBoolean("is_active")); } catch (SQLException e) { cat.setActive(true); }
        try { cat.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { cat.setCreatedAt(null); }
        try { cat.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { cat.setUpdatedAt(null); }
        return cat;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
