package com.clinic.model;

import java.io.Serializable;

/**
 * Dữ liệu trang Hồ Sơ Cá Nhân của những vai trò KHÔNG có bảng mở rộng riêng —
 * toàn bộ nằm ở bảng {@code users}: Nhân viên lễ tân (role_id = 4) và
 * Quản lý (role_id = 3).
 *
 * <p><b>Vì sao không dùng thẳng {@link User}:</b> {@code User} là model dùng khắp
 * hệ thống (đăng nhập, session, quản lý người dùng, dashboard…). Thêm hai trường
 * {@code department} / {@code jobTitle} vào đó sẽ lan ra mọi nơi đang đọc
 * {@code User}. Lớp này chỉ phục vụ trang hồ sơ nên phạm vi ảnh hưởng bằng không.
 *
 * <p><b>Email không có setter</b>: đây là trường chỉ-xem trên trang hồ sơ, và
 * {@code UserProfileDAO} cũng không có cột này trong câu UPDATE. Cùng lý do với
 * {@code department} và {@code jobTitle}.
 */
public class UserProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    private int userId;

    /** Sửa được. */
    private String fullName;

    /** Sửa được. */
    private String phone;

    /** Chỉ xem — đã giải mã từ cột varbinary. */
    private final String email;

    /** Chỉ xem — bộ phận. Nhân viên và Quản lý dùng chung cột users.department. */
    private final String department;

    /** Chỉ xem — chức danh. Chỉ Nhân viên hiển thị trường này. */
    private final String jobTitle;

    public UserProfile(int userId, String fullName, String email, String phone,
                       String department, String jobTitle) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.department = department;
        this.jobTitle = jobTitle;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = (fullName != null) ? fullName.trim() : null;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public String getDepartment() {
        return department;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    @Override
    public String toString() {
        return "UserProfile{userId=" + userId + ", fullName='" + fullName + "'}";
    }
}
