package com.clinic.model;

import java.io.Serializable;

/**
 * Entity class ánh xạ bảng roles.
 */
public class Role implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String roleName;
    private String description;

    public Role() {
    }

    public Role(int id, String roleName) {
        this.id = id;
        this.roleName = roleName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleNameDisplay() {
        if (roleName == null) {
            switch (id) {
                case 1: return "Quản trị viên";
                case 2: return "Bác sĩ lâm sàng";
                case 3: return "Quản lý";
                case 4: return "Nhân viên lễ tân";
                case 5: return "Bệnh nhân";
                case 6: return "Bác sĩ siêu âm";
                default: return "—";
            }
        }
        switch (roleName.trim()) {
            case "Admin":       return "Quản trị viên";
            case "Doctor":      return "Bác sĩ lâm sàng";
            case "Manager":     return "Quản lý";
            case "Staff":       return "Nhân viên lễ tân";
            case "Patient":     return "Bệnh nhân";
            case "Sonographer": return "Bác sĩ siêu âm";
            default:            return roleName;
        }
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Role{" +
                "id=" + id +
                ", roleName='" + roleName + '\'' +
                '}';
    }
}
