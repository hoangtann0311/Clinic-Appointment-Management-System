package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng permissions.
 * Đại diện cho một quyền (permission) trong hệ thống phân quyền.
 */
public class Permission implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String permissionKey;
    private String permissionName;
    private String module;
    private String description;
    private Timestamp createdAt;

    public Permission() {
    }

    public Permission(int id, String permissionKey, String permissionName,
                      String module, String description) {
        this.id = id;
        this.permissionKey = permissionKey;
        this.permissionName = permissionName;
        this.module = module;
        this.description = description;
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPermissionKey() {
        return permissionKey;
    }

    public void setPermissionKey(String permissionKey) {
        this.permissionKey = permissionKey;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Permission{" +
                "id=" + id +
                ", permissionKey='" + permissionKey + '\'' +
                ", permissionName='" + permissionName + '\'' +
                ", module='" + module + '\'' +
                '}';
    }
}
