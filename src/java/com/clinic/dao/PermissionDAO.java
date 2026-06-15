package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Permission;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object cho bảng permissions.
 * Quản lý danh sách quyền trong hệ thống.
 */
public class PermissionDAO {

    /**
     * Lấy tất cả quyền, sắp xếp theo module rồi theo id.
     */
    public List<Permission> findAll() {
        String sql = "SELECT id, permission_key, permission_name, module, description, created_at "
                   + "FROM permissions ORDER BY module, id";
        List<Permission> list = new ArrayList<>();
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
            System.err.println("PermissionDAO.findAll: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Lấy tất cả quyền, nhóm theo module.
     * Key = tên module, Value = danh sách Permission trong module đó.
     */
    public Map<String, List<Permission>> findAllGroupedByModule() {
        List<Permission> all = findAll();
        Map<String, List<Permission>> grouped = new LinkedHashMap<>();
        for (Permission p : all) {
            grouped.computeIfAbsent(p.getModule(), k -> new ArrayList<>()).add(p);
        }
        return grouped;
    }

    /**
     * Tìm quyền theo id.
     */
    public Permission findById(int id) {
        String sql = "SELECT id, permission_key, permission_name, module, description, created_at "
                   + "FROM permissions WHERE id = ?";
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
            System.err.println("PermissionDAO.findById: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Lấy danh sách quyền theo module.
     */
    public List<Permission> findByModule(String module) {
        String sql = "SELECT id, permission_key, permission_name, module, description, created_at "
                   + "FROM permissions WHERE module = ? ORDER BY id";
        List<Permission> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, module);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("PermissionDAO.findByModule: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Ánh xạ ResultSet → Permission entity.
     */
    private Permission mapRow(ResultSet rs) throws SQLException {
        Permission p = new Permission();
        p.setId(rs.getInt("id"));
        p.setPermissionKey(rs.getString("permission_key"));
        p.setPermissionName(rs.getString("permission_name"));
        p.setModule(rs.getString("module"));
        p.setDescription(rs.getString("description"));
        try {
            p.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            p.setCreatedAt(null);
        }
        return p;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
