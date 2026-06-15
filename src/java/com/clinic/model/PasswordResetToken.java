package com.clinic.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Entity class ánh xạ bảng password_reset_tokens.
 * Dùng cho chức năng quên mật khẩu và đặt lại mật khẩu.
 */
public class PasswordResetToken implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String token;
    private LocalDateTime expiresAt;
    private boolean isUsed;
    private LocalDateTime createdAt;

    public PasswordResetToken() {
    }

    public PasswordResetToken(int userId, String token, LocalDateTime expiresAt) {
        this.userId = userId;
        this.token = token;
        this.expiresAt = expiresAt;
        this.isUsed = false;
    }

    // Getters và Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Kiểm tra token đã hết hạn chưa.
     * @return true nếu đã hết hạn
     */
    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }

    /**
     * Kiểm tra token còn hợp lệ không (chưa dùng, chưa hết hạn).
     * @return true nếu token còn hợp lệ
     */
    public boolean isValid() {
        return !isUsed && !isExpired();
    }

    @Override
    public String toString() {
        return "PasswordResetToken{" +
                "id=" + id +
                ", userId=" + userId +
                ", isUsed=" + isUsed +
                ", expiresAt=" + expiresAt +
                '}';
    }
}
