package com.clinic.model;

import java.io.Serializable;

/**
 * Entity class ánh xạ bảng users.
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String fullName;
    private String email;
    private String username;
    private String passwordHash;
    private String phone;
    private int roleId;
    private String status;
    private String verificationToken;
    private boolean isVerified;
    private String googleId;
    private String authProvider;
    private java.sql.Timestamp createdAt;
    // Transient — không map từ DB, dùng cho hiển thị dashboard
    private String roleName;
    // Transient — ảnh đại diện lấy từ bảng vai trò cụ thể (VD: doctors.avatar_url),
    // nạp khi đăng nhập hoặc khi cập nhật hồ sơ, dùng để hiển thị ở header/sidebar chung.
    private String avatarUrl;
    // Soft delete flag
    private boolean deleted;

    public User() {
    }

    public User(String fullName, String email, String passwordHash, String phone, int roleId, String status) {
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.roleId = roleId;
        this.status = status;
    }

    // Getters và Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getVerificationToken() {
        return verificationToken;
    }

    public void setVerificationToken(String verificationToken) {
        this.verificationToken = verificationToken;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(String authProvider) {
        this.authProvider = authProvider;
    }

    public java.sql.Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(java.sql.Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleNameDisplay() {
        if (roleName == null) {
            switch (roleId) {
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

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", roleId=" + roleId +
                ", status='" + status + '\'' +
                ", authProvider='" + authProvider + '\'' +
                '}';
    }
}
