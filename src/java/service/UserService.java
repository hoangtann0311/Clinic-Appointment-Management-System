package com.clinic.service;

import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý người dùng cho Admin.
 * Bao gồm: CRUD tài khoản nhân viên, soft delete, validate.
 */
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /** Lấy danh sách user có phân trang + filter */
    public List<User> getUsers(int page, int pageSize,
                               String search, Integer roleFilter, String statusFilter,
                               boolean includeDeleted) {
        int offset = (page - 1) * pageSize;
        try {
            return userDAO.findAll(offset, pageSize, search, roleFilter, statusFilter, includeDeleted);
        } catch (Exception e) {
            System.err.println("[UserService] getUsers ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số user (để tính số trang) */
    public int getTotalUsers(String search, Integer roleFilter, String statusFilter, boolean includeDeleted) {
        try {
            return userDAO.countAll(search, roleFilter, statusFilter, includeDeleted);
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

    /** Xóa user (hard delete — giữ lại cho tương thích ngược) */
    public boolean deleteUser(int userId) {
        return userDAO.delete(userId);
    }

    /** Soft delete user — vô hiệu hóa tài khoản, giữ nguyên dữ liệu liên quan */
    public boolean softDeleteUser(int userId) {
        return userDAO.softDelete(userId);
    }

    /** Tạo user mới (admin side) */
    public boolean createUser(String fullName, String email, String username,
                              String password, String phone, int roleId, String status,
                              Map<String, String> errors) {
        // Validate cơ bản
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ tên.");
            return false;
        }
        if (fullName.trim().length() < 2) {
            errors.put("fullName", "Họ tên phải có ít nhất 2 ký tự.");
            return false;
        }
        if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.\\w{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        if (username == null || username.trim().isEmpty()) {
            errors.put("username", "Vui lòng nhập tên đăng nhập.");
            return false;
        }
        if (username.trim().length() < 4) {
            errors.put("username", "Tên đăng nhập phải có ít nhất 4 ký tự.");
            return false;
        }
        if (!username.trim().matches("^[a-zA-Z0-9_]+$")) {
            errors.put("username", "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới.");
            return false;
        }
        if (password == null || password.length() < 6) {
            errors.put("password", "Mật khẩu ít nhất 6 ký tự.");
            return false;
        }
        if (phone != null && !phone.trim().isEmpty()
                && !phone.trim().matches("^(0[3|5|7|8|9])[0-9]{8}$")) {
            errors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu 03|05|07|08|09).");
            return false;
        }
        // Kiểm tra email trùng
        if (userDAO.findByEmail(email.trim().toLowerCase()) != null) {
            errors.put("email", "Email đã tồn tại.");
            return false;
        }
        // Kiểm tra username trùng
        if (userDAO.findByUsername(username.trim().toLowerCase()) != null) {
            errors.put("username", "Tên đăng nhập đã tồn tại.");
            return false;
        }

        User u = new User();
        u.setFullName(fullName.trim());
        u.setEmail(email.trim().toLowerCase());
        u.setUsername(username.trim().toLowerCase());
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

    /** Cập nhật user (admin side — không đổi password, có thể đổi email) */
    public boolean updateUser(int userId, String fullName, String username,
                              String email, String phone, int roleId, String status,
                              Map<String, String> errors) {
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ tên.");
            return false;
        }
        if (username == null || username.trim().isEmpty()) {
            errors.put("username", "Vui lòng nhập tên đăng nhập.");
            return false;
        }

        // Load user hiện tại từ DB
        User u = userDAO.findById(userId);
        if (u == null) {
            errors.put("general", "User không tồn tại hoặc đã bị xóa.");
            return false;
        }

        // ── Validate email ──
        String newEmail = (email != null) ? email.trim().toLowerCase() : "";
        if (newEmail.isEmpty()) {
            errors.put("email", "Vui lòng nhập email.");
            return false;
        }
        if (!newEmail.matches("^[\\w.-]+@[\\w.-]+\\.\\w{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        // Kiểm tra email trùng (ngoại trừ chính nó)
        User emailOwner = userDAO.findByEmail(newEmail);
        if (emailOwner != null && emailOwner.getId() != userId) {
            errors.put("email", "Email đã được sử dụng bởi người dùng khác.");
            return false;
        }
        // Cảnh báo nếu user Google bị đổi email (Google ID vẫn giữ nguyên)
        boolean emailChanged = (u.getEmail() == null) || !newEmail.equals(u.getEmail().toLowerCase());
        if (emailChanged && "google".equalsIgnoreCase(u.getAuthProvider())) {
            // Vẫn cho phép đổi nhưng ghi log để audit
            System.out.println("[UserService] WARNING: Thay đổi email của Google user #"
                    + userId + " từ " + u.getEmail() + " sang " + newEmail);
        }

        // ── Validate username ──
        String newUsername = username.trim().toLowerCase();

        // Chỉ kiểm tra định dạng + trùng lặp username khi admin THAY ĐỔI username.
        boolean usernameChanged = (u.getUsername() == null)
                || !newUsername.equals(u.getUsername().toLowerCase());

        if (usernameChanged) {
            if (!newUsername.matches("^[a-zA-Z0-9_]+$")) {
                errors.put("username", "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới.");
                return false;
            }
            // Kiểm tra username trùng (ngoại trừ chính nó)
            User existing = userDAO.findByUsername(newUsername);
            if (existing != null && existing.getId() != userId) {
                errors.put("username", "Tên đăng nhập đã được sử dụng bởi người dùng khác.");
                return false;
            }
        }

        u.setFullName(fullName.trim());
        u.setEmail(newEmail);          // ← cho phép cập nhật email
        u.setUsername(newUsername);
        u.setPhone(phone != null ? phone.trim() : "");
        u.setRoleId(roleId);
        u.setStatus(status);
        if (!userDAO.update(u)) {
            errors.put("general", "Cập nhật thất bại — có thể có lỗi cơ sở dữ liệu. Vui lòng thử lại.");
            return false;
        }
        return true;
    }

    /** Reset mật khẩu cho user (admin side) */
    public boolean resetPassword(int userId, String newPassword, Map<String, String> errors) {
        if (newPassword == null || newPassword.length() < 6) {
            errors.put("password", "Mật khẩu ít nhất 6 ký tự.");
            return false;
        }
        return userDAO.updatePassword(userId,
                com.clinic.utils.BCryptUtil.hashPassword(newPassword));
    }

    /** Lấy user theo id */
    public User getUserById(int userId) {
        return userDAO.findById(userId);
    }

    /** Tìm user theo username */
    public User getUserByUsername(String username) {
        return userDAO.findByUsername(username);
    }
}
