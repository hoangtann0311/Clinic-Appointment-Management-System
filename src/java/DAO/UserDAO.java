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
