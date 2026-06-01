package com.clinic.service;

import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý người dùng cho Admin.
 * Đơn giản: gọi DAO + validate cơ bản.
 */
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /** Lấy danh sách user có phân trang + filter */
    public List<User> getUsers(int page, int pageSize,
                               String search, Integer roleFilter, String statusFilter) {
        int offset = (page - 1) * pageSize;
        try {
            return userDAO.findAll(offset, pageSize, search, roleFilter, statusFilter);
        } catch (Exception e) {
            System.err.println("[UserService] getUsers ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số user (để tính số trang) */
    public int getTotalUsers(String search, Integer roleFilter, String statusFilter) {
        try {
            return userDAO.countAll(search, roleFilter, statusFilter);
        } catch (Exception e) {
            System.err.println("[UserService] getTotalUsers ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return 0;
        }
    }

    /** Cập nhật trạng thái user */
    public boolean updateStatus(int userId, String newStatus) {
        return userDAO.updateStatus(userId, newStatus);
    }

    /** Xóa user */
    public boolean deleteUser(int userId) {
        return userDAO.delete(userId);
    }

    /** Tạo user mới (admin side) */
    public boolean createUser(String fullName, String email, String password,
                              String phone, int roleId, String status,
                              Map<String, String> errors) {
        // Validate cơ bản
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ tên.");
            return false;
        }
        if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.\\w{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        if (password == null || password.length() < 6) {
            errors.put("password", "Mật khẩu ít nhất 6 ký tự.");
            return false;
        }
        // Kiểm tra email trùng
        if (userDAO.findByEmail(email.trim().toLowerCase()) != null) {
            errors.put("email", "Email đã tồn tại.");
            return false;
        }

        User u = new User();
        u.setFullName(fullName.trim());
        u.setEmail(email.trim().toLowerCase());
        u.setPasswordHash(com.clinic.utils.BCryptUtil.hashPassword(password));
        u.setPhone(phone != null ? phone.trim() : "");
        u.setRoleId(roleId);
        u.setStatus(status != null ? status : UserStatus.ACTIVE.getValue());
        u.setVerified(true);          // admin tạo = auto verified
        u.setAuthProvider("local");

        try {
            userDAO.insert(u);
            return true;
        } catch (Exception e) {
            errors.put("general", "Lỗi khi tạo user: " + e.getMessage());
            return false;
        }
    }

    /** Cập nhật user (admin side — không đổi password) */
    public boolean updateUser(int userId, String fullName, String phone,
                              int roleId, String status,
                              Map<String, String> errors) {
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ tên.");
            return false;
        }
        User u = userDAO.findById(userId);
        if (u == null) {
            errors.put("general", "User không tồn tại.");
            return false;
        }
        u.setFullName(fullName.trim());
        u.setPhone(phone != null ? phone.trim() : "");
        u.setRoleId(roleId);
        u.setStatus(status);
        return userDAO.update(u);
    }

    /** Lấy user theo id */
    public User getUserById(int userId) {
        return userDAO.findById(userId);
    }
}
