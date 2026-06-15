package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.PasswordResetToken;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Data Access Object cho bảng password_reset_tokens.
 * Hỗ trợ chức năng quên mật khẩu.
 */
public class PasswordResetTokenDAO {

    /**
     * Tạo token đặt lại mật khẩu mới.
     * @param token đối tượng PasswordResetToken
     * @return id của token vừa tạo
     */
    public int insert(PasswordResetToken token) {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, expires_at, is_used) "
                   + "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, token.getUserId());
            ps.setString(2, token.getToken());
            ps.setTimestamp(3, Timestamp.valueOf(token.getExpiresAt()));
            ps.setBoolean(4, token.isUsed());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new RuntimeException("Tạo token đặt lại mật khẩu thất bại");
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new RuntimeException("Tạo token thất bại - không lấy được ID");

        } catch (SQLException e) {
            System.err.println("Lỗi khi tạo password reset token: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tạo token", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Tìm token đặt lại mật khẩu theo chuỗi token.
     * @param tokenValue chuỗi token cần tìm
     * @return PasswordResetToken nếu tìm thấy, null nếu không
     */
    public PasswordResetToken findByToken(String tokenValue) {
        String sql = "SELECT id, user_id, token, expires_at, is_used, created_at "
                   + "FROM password_reset_tokens WHERE token = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, tokenValue);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToToken(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm password reset token: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm token", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Đánh dấu token đã được sử dụng.
     * @param id id của token
     * @return true nếu cập nhật thành công
     */
    public boolean markAsUsed(int id) {
        String sql = "UPDATE password_reset_tokens SET is_used = 1 WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi đánh dấu token đã dùng: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi cập nhật token", e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Hủy tất cả token chưa sử dụng của một user (dùng khi user yêu cầu reset mới).
     * @param userId id của user
     */
    public void invalidateAllTokensForUser(int userId) {
        String sql = "UPDATE password_reset_tokens SET is_used = 1 WHERE user_id = ? AND is_used = 0";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Lỗi khi hủy token cũ của user: " + e.getMessage());
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Ánh xạ ResultSet sang PasswordResetToken entity.
     */
    private PasswordResetToken mapRowToToken(ResultSet rs) throws SQLException {
        PasswordResetToken token = new PasswordResetToken();
        token.setId(rs.getInt("id"));
        token.setUserId(rs.getInt("user_id"));
        token.setToken(rs.getString("token"));

        Timestamp expiresTs = rs.getTimestamp("expires_at");
        if (expiresTs != null) {
            token.setExpiresAt(expiresTs.toLocalDateTime());
        }

        token.setUsed(rs.getBoolean("is_used"));

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            token.setCreatedAt(createdTs.toLocalDateTime());
        }

        return token;
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
