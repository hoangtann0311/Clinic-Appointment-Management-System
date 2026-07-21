package com.clinic.service;

import com.clinic.dao.PermissionDAO;
import com.clinic.dao.RoleDAO;
import com.clinic.dao.RolePermissionDAO;
import com.clinic.model.Permission;
import com.clinic.model.Role;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Service xử lý nghiệp vụ Vai Trò & Phân Quyền.
 * Điều phối giữa RoleDAO, PermissionDAO, RolePermissionDAO.
 */
public class RoleService {

    private final RoleDAO roleDAO;
    private final PermissionDAO permissionDAO;
    private final RolePermissionDAO rolePermissionDAO;

    public RoleService() {
        this.roleDAO = new RoleDAO();
        this.permissionDAO = new PermissionDAO();
        this.rolePermissionDAO = new RolePermissionDAO();
    }

    // ──────────────────────────────────────────
    // ROLE CRUD
    // ──────────────────────────────────────────

    /** Lấy danh sách tất cả vai trò. */
    public List<Role> getAllRoles() {
        try {
            return roleDAO.findAll();
        } catch (Exception e) {
            System.err.println("[RoleService] getAllRoles ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Tìm vai trò theo ID. */
    public Role getRoleById(int id) {
        try {
            return roleDAO.findById(id);
        } catch (Exception e) {
            System.err.println("[RoleService] getRoleById ERROR: " + e.getMessage());
            return null;
        }
    }

    /** Cập nhật mô tả vai trò. */
    public boolean updateRoleDescription(int roleId, String description) {
        try {
            Role role = roleDAO.findById(roleId);
            if (role == null) return false;
            role.setDescription(description);
            return roleDAO.update(role);
        } catch (Exception e) {
            System.err.println("[RoleService] updateRoleDescription ERROR: " + e.getMessage());
            return false;
        }
    }

    // ──────────────────────────────────────────
    // PERMISSION QUERIES
    // ──────────────────────────────────────────

    /** Lấy tất cả quyền, nhóm theo module (dùng cho UI). */
    public Map<String, List<Permission>> getAllPermissionsGroupedByModule() {
        try {
            return permissionDAO.findAllGroupedByModule();
        } catch (Exception e) {
            System.err.println("[RoleService] getAllPermissionsGroupedByModule ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Lấy danh sách tất cả quyền. */
    public List<Permission> getAllPermissions() {
        try {
            return permissionDAO.findAll();
        } catch (Exception e) {
            System.err.println("[RoleService] getAllPermissions ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    // ──────────────────────────────────────────
    // ROLE-PERMISSION ASSIGNMENT
    // ──────────────────────────────────────────

    /** Lấy danh sách Permission ID được gán cho một vai trò. */
    public List<Integer> getPermissionIdsByRoleId(int roleId) {
        try {
            return rolePermissionDAO.getPermissionIdsByRoleId(roleId);
        } catch (Exception e) {
            System.err.println("[RoleService] getPermissionIdsByRoleId ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Lấy danh sách Permission objects được gán cho một vai trò. */
    public List<Permission> getPermissionsByRoleId(int roleId) {
        try {
            return rolePermissionDAO.getPermissionsByRoleId(roleId);
        } catch (Exception e) {
            System.err.println("[RoleService] getPermissionsByRoleId ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Lấy Set permission keys được gán cho một vai trò (dùng cho Auth Filter). */
    public Set<String> getPermissionKeysByRoleId(int roleId) {
        try {
            return rolePermissionDAO.getPermissionKeysByRoleId(roleId);
        } catch (Exception e) {
            System.err.println("[RoleService] getPermissionKeysByRoleId ERROR: " + e.getMessage());
            return Collections.emptySet();
        }
    }

    /** Lấy Set permission keys cho một user cụ thể (dùng khi đăng nhập). */
    public Set<String> getPermissionKeysByUserId(int userId) {
        try {
            return rolePermissionDAO.getPermissionKeysByUserId(userId);
        } catch (Exception e) {
            System.err.println("[RoleService] getPermissionKeysByUserId ERROR: " + e.getMessage());
            return Collections.emptySet();
        }
    }

    /**
     * Cập nhật toàn bộ quyền cho một vai trò.
     * Xóa quyền cũ, gán quyền mới (transaction trong DAO).
     *
     * @param roleId        ID vai trò cần cập nhật
     * @param permissionIds danh sách ID quyền mới (có thể rỗng)
     * @return true nếu thành công
     */
    public boolean updateRolePermissions(int roleId, List<Integer> permissionIds) {
        try {
            return rolePermissionDAO.assignPermissions(roleId, permissionIds);
        } catch (Exception e) {
            System.err.println("[RoleService] updateRolePermissions ERROR: " + e.getMessage());
            return false;
        }
    }
}
