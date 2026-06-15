package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Data Access Object cho bảng users.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class UserDAO {

    // Cache xem các cột migration có tồn tại không để tránh query lỗi lặp lại
    private static Boolean hasCreatedAtColumn = null;
    private static Boolean hasIsVerifiedColumn = null;
    private static Boolean hasAuthProviderColumn = null;

    /**
     * Tìm user theo email.
     * @param email email cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByEmail(String email) {
        String sql = "SELECT id, full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE email = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo email: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Thêm user mới vào database.
     * @param user đối tượng User cần thêm (không có id)
     * @return id của user vừa tạo
     */
    public int insert(User user) {
        String sql = "INSERT INTO users (full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getPhone());
            ps.setInt(5, user.getRoleId());
            ps.setString(6, user.getStatus());
            ps.setString(7, user.getVerificationToken());
            ps.setBoolean(8, user.isVerified());
            ps.setString(9, user.getGoogleId());
            ps.setString(10, user.getAuthProvider());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new RuntimeException("Thêm user thất bại - không có dòng nào được tạo");
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new RuntimeException("Thêm user thất bại - không lấy được ID");

        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm user: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi thêm user", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Ánh xạ ResultSet sang User entity.
     */
    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setPhone(rs.getString("phone"));
        user.setRoleId(rs.getInt("role_id"));
        user.setStatus(rs.getString("status"));
        user.setVerificationToken(rs.getString("verification_token"));
        user.setVerified(rs.getBoolean("is_verified"));
        user.setGoogleId(rs.getString("google_id"));
        user.setAuthProvider(rs.getString("auth_provider"));
        // Đọc created_at (có thể null nếu migration chưa chạy)
        try {
            user.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            // Cột created_at chưa tồn tại — bỏ qua
            user.setCreatedAt(null);
        }
        return user;
    }

    /**
     * Tìm user theo verification token.
     * @param token verification token cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByVerificationToken(String token) {
        String sql = "SELECT id, full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE verification_token = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo verification token: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user theo token", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Xác thực email cho user: đặt is_verified = 1, xóa token, chuyển status sang Active.
     * @param userId id của user cần xác thực
     * @return true nếu cập nhật thành công
     */
    public boolean verifyUser(int userId) {
        String sql = "UPDATE users SET is_verified = 1, verification_token = NULL, "
                   + "status = ? WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, com.clinic.model.enums.UserStatus.ACTIVE.getValue());
            ps.setInt(2, userId);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi xác thực user: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi xác thực user", e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Tìm user theo số điện thoại.
     * @param phone số điện thoại cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByPhone(String phone) {
        String sql = "SELECT id, full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE phone = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, phone);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo số điện thoại: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user theo số điện thoại", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm user theo id.
     * @param userId id của user cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findById(int userId) {
        String sql = "SELECT id, full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo id: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user theo id", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Cập nhật mật khẩu cho user.
     * @param userId id của user
     * @param newPasswordHash mật khẩu mới đã được hash bằng BCrypt
     * @return true nếu cập nhật thành công
     */
    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi cập nhật mật khẩu: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi cập nhật mật khẩu", e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Tìm user theo Google ID.
     * @param googleId Google user ID (sub claim từ ID token)
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByGoogleId(String googleId) {
        String sql = "SELECT id, full_name, email, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE google_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, googleId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo google_id: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user theo google_id", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Liên kết Google ID với user hiện có (khi email trùng khớp).
     * Cập nhật google_id và auth_provider = 'google'.
     * @param userId id của user cần liên kết
     * @param googleId Google user ID
     * @return true nếu cập nhật thành công
     */
    public boolean updateGoogleId(int userId, String googleId) {
        String sql = "UPDATE users SET google_id = ?, auth_provider = 'google' WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, googleId);
            ps.setInt(2, userId);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi cập nhật google_id: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi cập nhật google_id", e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ============================================================
    // CÁC PHƯƠNG THỨC CRUD — DÙNG CHO QUẢN LÝ USER
    // ============================================================

    /**
     * Lấy danh sách user có phân trang + tìm kiếm + lọc.
     * JOIN roles để lấy role_name.
     * Tự động fallback nếu cột migration (created_at, is_verified, auth_provider) chưa tồn tại.
     */
    public java.util.List<User> findAll(int offset, int pageSize,
                                         String search, Integer roleFilter, String statusFilter) {
        // Thử query đầy đủ trước, nếu lỗi cột thì fallback
        try {
            return findAllInternal(offset, pageSize, search, roleFilter, statusFilter, true);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column") ||
                msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] Falling back to base columns query: " + msg);
                try {
                    return findAllInternal(offset, pageSize, search, roleFilter, statusFilter, false);
                } catch (SQLException e2) {
                    System.err.println("[UserDAO] findAll fallback also failed: " + e2.getMessage());
                    throw new RuntimeException("Lỗi database khi lấy danh sách users", e2);
                }
            }
            System.err.println("[UserDAO] findAll error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy danh sách users", e);
        }
    }

    /**
     * Internal: thực thi query với hoặc không có cột migration.
     */
    private java.util.List<User> findAllInternal(int offset, int pageSize,
                                                  String search, Integer roleFilter,
                                                  String statusFilter, boolean fullColumns)
            throws SQLException {
        // Chọn cột: fullColumns=true dùng đủ cột, false dùng cột cơ bản (luôn tồn tại)
        String columns;
        if (fullColumns) {
            columns = "u.id, u.full_name, u.email, u.phone, u.role_id, u.status, "
                    + "u.created_at, u.is_verified, u.auth_provider, r.role_name";
        } else {
            columns = "u.id, u.full_name, u.email, u.phone, u.role_id, u.status, "
                    + "r.role_name";
        }
        StringBuilder sql = new StringBuilder("SELECT ").append(columns)
            .append(" FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?) ");
        }
        if (roleFilter != null && roleFilter > 0) {
            sql.append("AND u.role_id = ? ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND u.status = ? ");
        }
        sql.append("ORDER BY u.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        java.util.List<User> users = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (roleFilter != null && roleFilter > 0) {
                ps.setInt(idx++, roleFilter);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter.trim());
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
            rs = ps.executeQuery();
            while (rs.next()) {
                users.add(mapRowWithRole(rs, fullColumns));
            }
        } finally {
            closeResources(conn, ps, rs);
        }
        return users;
    }

    /**
     * Đếm tổng số user (có filter) — dùng cho phân trang.
     */
    public int countAll(String search, Integer roleFilter, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM users WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ");
        }
        if (roleFilter != null && roleFilter > 0) {
            sql.append("AND role_id = ? ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND status = ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (roleFilter != null && roleFilter > 0) {
                ps.setInt(idx++, roleFilter);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter.trim());
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Lỗi countAll users: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Cập nhật trạng thái user (Active/Inactive/Locked).
     */
    public boolean updateStatus(int userId, String newStatus) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateStatus: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Xóa user theo id.
     */
    public boolean delete(int userId) {
        String sql = "DELETE FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi delete user: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Cập nhật thông tin user (full_name, phone, role_id, status).
     */
    public boolean update(User user) {
        String sql = "UPDATE users SET full_name=?, phone=?, role_id=?, status=? WHERE id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setInt(3, user.getRoleId());
            ps.setString(4, user.getStatus());
            ps.setInt(5, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi update user: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Map row có kèm role_name từ JOIN */
    private User mapRowWithRole(ResultSet rs, boolean fullColumns) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRoleId(rs.getInt("role_id"));
        u.setStatus(rs.getString("status"));
        if (fullColumns) {
            try { u.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { u.setCreatedAt(null); }
            try { u.setVerified(rs.getBoolean("is_verified")); } catch (SQLException e) { u.setVerified(false); }
            try { u.setAuthProvider(rs.getString("auth_provider")); } catch (SQLException e) { u.setAuthProvider("local"); }
        }
        try { u.setRoleName(rs.getString("role_name")); } catch (SQLException e) { u.setRoleName("Unknown"); }
        return u;
    }

    // ============================================================
    // CÁC PHƯƠNG THỨC THỐNG KÊ — DÙNG CHO DASHBOARD
    // ============================================================

    /**
     * Đếm tổng số user trong hệ thống.
     * @return tổng số user, -1 nếu lỗi
     */
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) AS total FROM users";
        return executeCount(sql);
    }

    /**
     * Đếm tổng số bác sĩ (user có role_id = 2).
     * @return tổng số bác sĩ, -1 nếu lỗi
     */
    public int getTotalDoctors() {
        String sql = "SELECT COUNT(*) AS total FROM users WHERE role_id = 2";
        return executeCount(sql);
    }

    /**
     * Lấy danh sách N user mới nhất (kèm tên role).
     * JOIN với bảng roles để lấy role_name hiển thị.
     * Tự động fallback nếu cột created_at chưa tồn tại.
     * @param limit số lượng user cần lấy
     * @return danh sách User (có roleName), rỗng nếu không có dữ liệu
     */
    public java.util.List<User> getRecentUsers(int limit) {
        // Thử query đầy đủ trước, nếu lỗi cột thì fallback
        try {
            return getRecentUsersInternal(limit, true);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column") ||
                msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] getRecentUsers falling back to base columns: " + msg);
                try {
                    return getRecentUsersInternal(limit, false);
                } catch (SQLException e2) {
                    System.err.println("[UserDAO] getRecentUsers fallback also failed: " + e2.getMessage());
                    throw new RuntimeException("Lỗi database khi lấy recent users", e2);
                }
            }
            System.err.println("[UserDAO] getRecentUsers error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy recent users", e);
        }
    }

    private java.util.List<User> getRecentUsersInternal(int limit, boolean fullColumns)
            throws SQLException {
        String columns;
        if (fullColumns) {
            columns = "u.id, u.full_name, u.email, u.phone, u.role_id, u.status, "
                    + "u.created_at, r.role_name";
        } else {
            columns = "u.id, u.full_name, u.email, u.phone, u.role_id, u.status, "
                    + "r.role_name";
        }
        String sql = "SELECT TOP (?) " + columns + " "
                   + "FROM users u "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "ORDER BY u.id DESC";

        java.util.List<User> users = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setRoleId(rs.getInt("role_id"));
                user.setStatus(rs.getString("status"));
                if (fullColumns) {
                    try {
                        user.setCreatedAt(rs.getTimestamp("created_at"));
                    } catch (SQLException e) {
                        user.setCreatedAt(null);
                    }
                }
                // Lấy role_name từ JOIN
                try {
                    user.setRoleName(rs.getString("role_name"));
                } catch (SQLException e) {
                    user.setRoleName("Unknown");
                }
                users.add(user);
            }
        } finally {
            closeResources(conn, ps, rs);
        }
        return users;
    }

    /**
     * Helper: thực thi câu COUNT và trả về giá trị.
     */
    private int executeCount(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("Lỗi executeCount: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }

    /**
     * Đóng các resource database an toàn.
     */
    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.err.println("Lỗi đóng ResultSet: " + e.getMessage());
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                System.err.println("Lỗi đóng PreparedStatement: " + e.getMessage());
            }
        }
        DatabaseConfig.closeConnection(conn);
    }
}
