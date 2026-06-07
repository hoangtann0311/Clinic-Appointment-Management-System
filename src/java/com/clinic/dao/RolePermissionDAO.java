package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Permission;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Data Access Object cho bảng role_permissions (junction table).
 * Quản lý việc gán quyền cho vai trò.
 */
public class RolePermissionDAO {

    /**
     * Lấy danh sách permission ID được gán cho một vai trò.
     */
    public List<Integer> getPermissionIdsByRoleId(int roleId) {
        String sql = "SELECT permission_id FROM role_permissions WHERE role_id = ? ORDER BY permission_id";
        List<Integer> ids = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
            rs = ps.executeQuery();
            while (rs.next()) {
                ids.add(rs.getInt("permission_id"));
            }
        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.getPermissionIdsByRoleId: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return ids;
    }

    /**
     * Lấy danh sách Permission objects được gán cho một vai trò.
     */
    public List<Permission> getPermissionsByRoleId(int roleId) {
        String sql = "SELECT p.id, p.permission_key, p.permission_name, p.module, p.description, p.created_at "
                   + "FROM permissions p "
                   + "JOIN role_permissions rp ON p.id = rp.permission_id "
                   + "WHERE rp.role_id = ? "
                   + "ORDER BY p.module, p.id";
        List<Permission> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Permission p = new Permission();
                p.setId(rs.getInt("id"));
                p.setPermissionKey(rs.getString("permission_key"));
                p.setPermissionName(rs.getString("permission_name"));
                p.setModule(rs.getString("module"));
                p.setDescription(rs.getString("description"));
                try { p.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { p.setCreatedAt(null); }
                list.add(p);
            }
        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.getPermissionsByRoleId: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Lấy Set các permission key được gán cho một vai trò.
     * Dùng cho AuthenticationFilter — tra cứu nhanh.
     */
    public Set<String> getPermissionKeysByRoleId(int roleId) {
        String sql = "SELECT p.permission_key FROM permissions p "
                   + "JOIN role_permissions rp ON p.id = rp.permission_id "
                   + "WHERE rp.role_id = ?";
        Set<String> keys = new HashSet<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
            rs = ps.executeQuery();
            while (rs.next()) {
                keys.add(rs.getString("permission_key"));
            }
        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.getPermissionKeysByRoleId: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return keys;
    }

    /**
     * Gán danh sách quyền mới cho một vai trò.
     * Thực hiện trong transaction: xóa tất cả quyền cũ → chèn quyền mới.
     *
     * @param roleId        ID của vai trò
     * @param permissionIds danh sách ID quyền cần gán (có thể rỗng để xóa hết)
     * @return true nếu thành công
     */
    public boolean assignPermissions(int roleId, List<Integer> permissionIds) {
        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // Xóa tất cả quyền hiện tại của role
            psDelete = conn.prepareStatement("DELETE FROM role_permissions WHERE role_id = ?");
            psDelete.setInt(1, roleId);
            psDelete.executeUpdate();

            // Chèn quyền mới
            if (permissionIds != null && !permissionIds.isEmpty()) {
                psInsert = conn.prepareStatement(
                    "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)");
                for (int permId : permissionIds) {
                    psInsert.setInt(1, roleId);
                    psInsert.setInt(2, permId);
                    psInsert.addBatch();
                }
                psInsert.executeBatch();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.assignPermissions: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return false;
        } finally {
            if (psDelete != null) { try { psDelete.close(); } catch (SQLException e) { } }
            if (psInsert != null) { try { psInsert.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Xóa tất cả quyền của một vai trò.
     */
    public boolean removeAllForRole(int roleId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.removeAllForRole: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Lấy Set các permission key cho một user cụ thể.
     * JOIN users → role_permissions → permissions.
     * Dùng khi đăng nhập để load quyền vào session.
     */
    public Set<String> getPermissionKeysByUserId(int userId) {
        String sql = "SELECT p.permission_key FROM permissions p "
                   + "JOIN role_permissions rp ON p.id = rp.permission_id "
                   + "JOIN users u ON u.role_id = rp.role_id "
                   + "WHERE u.id = ?";
        Set<String> keys = new HashSet<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                keys.add(rs.getString("permission_key"));
            }
        } catch (SQLException e) {
            System.err.println("RolePermissionDAO.getPermissionKeysByUserId: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return keys;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
