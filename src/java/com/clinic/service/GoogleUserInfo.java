package com.clinic.service;

/**
 * Thông tin người dùng trích xuất từ Google ID token sau khi xác thực thành công.
 */
public class GoogleUserInfo {

    private final String googleId;   // Google user ID (sub claim)
    private final String email;      // Email Google
    private final String name;       // Tên hiển thị
    private final String picture;    // URL ảnh đại diện

    public GoogleUserInfo(String googleId, String email, String name, String picture) {
        this.googleId = googleId;
        this.email = email;
        this.name = name;
        this.picture = picture;
    }

    public String getGoogleId() {
        return googleId;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public String getPicture() {
        return picture;
    }

    @Override
    public String toString() {
        return "GoogleUserInfo{" +
                "googleId='" + googleId + '\'' +
                ", email='" + email + '\'' +
                ", name='" + name + '\'' +
                '}';
    }
}
