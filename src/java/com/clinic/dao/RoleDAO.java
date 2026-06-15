package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Role;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng roles.
 * CRUD vai trò người dùng.
 */
public class RoleDAO {

    /**
     * Lấy tất cả vai trò, sắp xếp theo id.
     */
    public List<Role> findAll() {
        String sql = "SELECT id, role_name, description FROM roles ORDER BY id";
        List<Role> roles = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                roles.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("RoleDAO.findAll: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return roles;
    }

    /**
     * Tìm vai trò theo id.
     */
    public Role findById(int id) {
        String sql = "SELECT id, role_name, description FROM roles WHERE id = ?";
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
            System.err.println("RoleDAO.findById: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Cập nhật mô tả vai trò.
     */
    public boolean update(Role role) {
        String sql = "UPDATE roles SET role_name = ?, description = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, role.getRoleName());
            ps.setString(2, role.getDescription());
            ps.setInt(3, role.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("RoleDAO.update: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Ánh xạ ResultSet → Role entity.
     * Xử lý null-safe cho cột description (có thể null nếu migration chưa chạy).
     */
    private Role mapRow(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setId(rs.getInt("id"));
        role.setRoleName(rs.getString("role_name"));
        try {
            role.setDescription(rs.getString("description"));
        } catch (SQLException e) {
            role.setDescription(null);
        }
        return role;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
