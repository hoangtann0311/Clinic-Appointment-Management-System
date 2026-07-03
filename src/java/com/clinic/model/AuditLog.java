package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng audit_logs — nhật ký hoạt động hệ thống.
 * Ghi lại mọi thao tác CUD (Create/Update/Delete) và các sự kiện quan trọng
 * như LOGIN, LOGOUT, EXPORT... để truy vết trách nhiệm và bảo mật.
 */
public class AuditLog implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Integer userId;          // có thể NULL nếu là hệ thống
    private String action;            // mô tả hành động (VD: "Tạo mới dịch vụ Siêu âm 4D")
    private String tableName;         // bảng bị tác động (VD: services, users, medicines...)
    private String oldValue;          // giá trị cũ (JSON hoặc text)
    private String newValue;          // giá trị mới (JSON hoặc text)
    private String ipAddress;         // địa chỉ IP của người thực hiện
    private Timestamp createdAt;      // thời điểm thực hiện

    // ── Transient fields (không map từ DB, dùng để hiển thị) ──
    private String userName;          // tên người thực hiện (JOIN từ users)
    private String roleName;          // tên vai trò (JOIN từ roles)
    private String actionType;        // phân loại từ action: CREATE, UPDATE, DELETE, LOGIN...

    public AuditLog() {
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // ── Transient getters/setters ──

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    /**
     * Tự động suy đoán actionType từ nội dung action.
     * Dùng để hiển thị badge màu tương ứng.
     */
    public String getActionType() {
        if (actionType != null) return actionType;
        if (action == null) return "UNKNOWN";

        String lower = action.toLowerCase();
        if (lower.contains("tạo") || lower.contains("thêm") || lower.contains("đăng ký")
                || lower.contains("create") || lower.contains("insert")) {
            return "CREATE";
        }
        if (lower.contains("sửa") || lower.contains("cập nhật") || lower.contains("chỉnh")
                || lower.contains("update") || lower.contains("edit")) {
            return "UPDATE";
        }
        if (lower.contains("xoá") || lower.contains("xóa") || lower.contains("vô hiệu")
                || lower.contains("delete") || lower.contains("remove") || lower.contains("deactivate")) {
            return "DELETE";
        }
        if (lower.contains("đăng nhập") || lower.contains("login")) {
            return "LOGIN";
        }
        if (lower.contains("đăng xuất") || lower.contains("logout")) {
            return "LOGOUT";
        }
        if (lower.contains("xuất") || lower.contains("export")) {
            return "EXPORT";
        }
        if (lower.contains("duyệt") || lower.contains("approve")) {
            return "APPROVE";
        }
        if (lower.contains("khoá") || lower.contains("mở khoá") || lower.contains("lock")
                || lower.contains("unlock") || lower.contains("toggle")) {
            return "TOGGLE";
        }
        if (lower.contains("đổi mật khẩu") || lower.contains("change password")) {
            return "SECURITY";
        }
        return "OTHER";
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    @Override
    public String toString() {
        return "AuditLog{" +
                "id=" + id +
                ", userId=" + userId +
                ", userName='" + userName + '\'' +
                ", action='" + action + '\'' +
                ", tableName='" + tableName + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
