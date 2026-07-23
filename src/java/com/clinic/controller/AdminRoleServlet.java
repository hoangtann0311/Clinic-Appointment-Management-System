package com.clinic.controller;

import com.clinic.config.AuthorizationConfig;
import com.clinic.model.Permission;
import com.clinic.model.Role;
import com.clinic.service.RoleService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Servlet quản lý Vai Trò & Phân Quyền cho Admin.
 * GET  → hiển thị giao diện quản lý vai trò và phân quyền
 * POST → xử lý cập nhật quyền cho vai trò
 */
@WebServlet(urlPatterns = {"/admin/roles/", "/admin/roles"})
public class AdminRoleServlet extends HttpServlet {

    private RoleService roleService;

    @Override
    public void init() throws ServletException {
        roleService = new RoleService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách vai trò
        List<Role> roles = roleService.getAllRoles();

        // Lấy tất cả quyền, nhóm theo module
        Map<String, List<Permission>> permissionsByModule = filterImplementedPermissions(
                roleService.getAllPermissionsGroupedByModule());
        Set<Integer> implementedPermissionIds = permissionsByModule.values().stream()
                .flatMap(List::stream)
                .map(Permission::getId)
                .collect(Collectors.toSet());

        // Lấy danh sách permission ID cho từng role (để đánh dấu checkbox)
        // Dùng Map<roleId, List<permissionId>>
        java.util.Map<Integer, List<Integer>> rolePermissionMap = new java.util.LinkedHashMap<>();
        for (Role role : roles) {
            List<Integer> permIds = roleService.getPermissionIdsByRoleId(role.getId()).stream()
                    .filter(implementedPermissionIds::contains)
                    .collect(Collectors.toList());
            rolePermissionMap.put(role.getId(), permIds);
        }

        // Set attributes cho JSP
        req.setAttribute("roles", roles);
        req.setAttribute("permissionsByModule", permissionsByModule);
        req.setAttribute("rolePermissionMap", rolePermissionMap);

        // Message từ redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        // Xác định tab đang active (mặc định là role đầu tiên)
        String activeTab = req.getParameter("tab");
        if (activeTab == null && !roles.isEmpty()) {
            activeTab = String.valueOf(roles.get(0).getId());
        }
        req.setAttribute("activeTab", activeTab);

        req.getRequestDispatcher("/views/admin/roles/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectBase = req.getContextPath() + "/admin/roles/";

        try {
            if ("updatePermissions".equals(action)) {
                int roleId = parseInt(req.getParameter("roleId"), -1);
                if (roleId <= 0) {
                    resp.sendRedirect(redirectBase + "?error=Vai+trò+không+hợp+lệ");
                    return;
                }

                // Đọc mảng permissionIds từ form
                String[] permIdStrs = req.getParameterValues("permissionIds");
                List<Integer> permissionIds = new ArrayList<>();
                if (permIdStrs != null) {
                    Set<Integer> implementedPermissionIds = filterImplementedPermissions(
                            roleService.getAllPermissionsGroupedByModule())
                            .values().stream()
                            .flatMap(List::stream)
                            .map(Permission::getId)
                            .collect(Collectors.toSet());
                    for (String s : permIdStrs) {
                        try {
                            int permissionId = Integer.parseInt(s);
                            if (implementedPermissionIds.contains(permissionId)) {
                                permissionIds.add(permissionId);
                            }
                        } catch (NumberFormatException ignored) {
                            // Bỏ qua giá trị không hợp lệ
                        }
                    }
                }

                boolean ok = roleService.updateRolePermissions(roleId, permissionIds);
                if (ok) {
                    Role r = roleService.getRoleById(roleId);
                    String roleName = r != null ? r.getRoleName() : ("#" + roleId);
                    AuditUtil.log(req, "Cập nhật phân quyền cho vai trò: " + roleName, "roles",
                            null, "permissions_count=" + permissionIds.size());

                    // Bump global permissions version để AuthorizationFilter
                    // phát hiện thay đổi và reload permissions cho các session đang hoạt động
                    com.clinic.filter.AuthorizationFilter.bumpPermissionsVersion();

                    resp.sendRedirect(redirectBase + "?success=updated&tab=" + roleId);
                } else {
                    resp.sendRedirect(redirectBase + "?error=Cập+nhật+phân+quyền+thất+bại&tab=" + roleId);
                }
                return;
            }

            if ("updateDescription".equals(action)) {
                int roleId = parseInt(req.getParameter("roleId"), -1);
                String description = req.getParameter("description");
                if (roleId > 0 && roleService.updateRoleDescription(roleId, description)) {
                    Role r = roleService.getRoleById(roleId);
                    String roleName = r != null ? r.getRoleName() : ("#" + roleId);
                    AuditUtil.log(req, "Cập nhật mô tả vai trò: " + roleName, "roles",
                            null, description);
                    resp.sendRedirect(redirectBase + "?success=updated&tab=" + roleId);
                } else {
                    resp.sendRedirect(redirectBase + "?error=Cập+nhật+mô+tả+thất+bại&tab=" + roleId);
                }
                return;
            }

            // Action không xác định
            resp.sendRedirect(redirectBase);

        } catch (Exception e) {
            System.err.println("AdminRoleServlet POST: " + e.getMessage());
            resp.sendRedirect(redirectBase + "?error=Lỗi+hệ+thống");
        }
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }

    private Map<String, List<Permission>> filterImplementedPermissions(
            Map<String, List<Permission>> permissionsByModule) {
        Set<String> implementedKeys = AuthorizationConfig.URL_PERMISSIONS.values().stream()
                .filter(key -> !AuthorizationConfig.AUTHENTICATED_ONLY.equals(key))
                .collect(Collectors.toSet());

        return permissionsByModule.entrySet().stream()
                .map(entry -> Map.entry(
                        entry.getKey(),
                        entry.getValue().stream()
                                .filter(permission -> implementedKeys.contains(permission.getPermissionKey()))
                                .collect(Collectors.toList())))
                .filter(entry -> !entry.getValue().isEmpty())
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (left, right) -> left,
                        java.util.LinkedHashMap::new));
    }
}

