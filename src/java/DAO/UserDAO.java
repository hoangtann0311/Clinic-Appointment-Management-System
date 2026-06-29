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
 *
 * LƯU Ý: Cột email và phone được mã hoá bằng ENCRYPTBYPASSPHRASE trong database.
 * Mọi query SELECT phải dùng DECRYPT_EMAIL / DECRYPT_PHONE để giải mã.
 * Mọi query INSERT/UPDATE phải dùng ENCRYPT_PLACEHOLDER để mã hoá.
 */
public class UserDAO {

    // Cache xem các cột migration có tồn tại không để tránh query lỗi lặp lại
    private static Boolean hasCreatedAtColumn = null;
    private static Boolean hasIsVerifiedColumn = null;
    private static Boolean hasAuthProviderColumn = null;

    // ============================================================
    // SQL FRAGMENTS CHO MÃ HOÁ/GIẢI MÃ EMAIL & PHONE
    // Passphrase: ClinicAppKey2026! (nên đọc từ config/biến môi trường)
    // ============================================================
    private static final String DB_KEY = "ClinicAppKey2026!";

    /** Dùng trong SELECT: giải mã cột email thành NVARCHAR(100).
     *  Dùng NVARCHAR vì JDBC setString() gửi Unicode → ENCRYPTBYPASSPHRASE mã hoá UTF-16LE.
     *  Nếu dùng VARCHAR, NULL byte giữa các ký tự sẽ hiển thị thành ký tự đặc biệt. */
    private static final String DECRYPT_EMAIL =
        "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', email)) AS email";

    /** Dùng trong SELECT: giải mã cột phone thành NVARCHAR(20) */
    private static final String DECRYPT_PHONE =
        "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', phone)) AS phone";

    /** Dùng trong INSERT/UPDATE: mã hoá giá trị từ parameter */
    private static final String ENCRYPT_EMAIL_PARAM =
        "ENCRYPTBYPASSPHRASE('" + DB_KEY + "', ?)";

    /** Dùng trong INSERT/UPDATE: mã hoá giá trị từ parameter */
    private static final String ENCRYPT_PHONE_PARAM =
        "ENCRYPTBYPASSPHRASE('" + DB_KEY + "', ?)";

    /** Dùng trong WHERE: giải mã cột email để so sánh = ? */
    private static final String WHERE_EMAIL_EQUAL =
        "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', email)) = ?";

    /** Dùng trong WHERE: giải mã cột phone để so sánh = ? */
    private static final String WHERE_PHONE_EQUAL =
        "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', phone)) = ?";

    /** Dùng trong WHERE: giải mã cột email để so sánh LIKE ? */
    private static final String WHERE_EMAIL_LIKE =
        "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', email)) LIKE ?";

    /** Dùng trong WHERE: giải mã cột phone để so sánh LIKE ? */
    private static final String WHERE_PHONE_LIKE =
        "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', phone)) LIKE ?";

    // Biến thể dùng table alias "u." cho query có JOIN
    private static final String DECRYPT_EMAIL_U =
        "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.email)) AS email";
    private static final String DECRYPT_PHONE_U =
        "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.phone)) AS phone";
    private static final String WHERE_U_EMAIL_LIKE =
        "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.email)) LIKE ?";
    private static final String WHERE_U_PHONE_LIKE =
        "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.phone)) LIKE ?";

    /**
     * Tìm user theo username.
     * @param username tên đăng nhập cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByUsername(String username) {
        String sql = "SELECT id, full_name, " + DECRYPT_EMAIL + ", username, password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider, is_deleted "
                   + "FROM users WHERE username = ? AND is_deleted = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRowToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tìm user theo username: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi tìm user theo username", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm user theo email.
     * @param email email cần tìm
     * @return User nếu tìm thấy, null nếu không tìm thấy
     */
    public User findByEmail(String email) {
        String sql = "SELECT id, full_name, " + DECRYPT_EMAIL + ", username, password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider, is_deleted "
                   + "FROM users WHERE " + WHERE_EMAIL_EQUAL + " AND is_deleted = 0";

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
        String sql = "INSERT INTO users (full_name, email, username, password_hash, phone, role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider, is_deleted) "
                   + "VALUES (?, " + ENCRYPT_EMAIL_PARAM + ", ?, ?, " + ENCRYPT_PHONE_PARAM + ", ?, ?, ?, ?, ?, ?, 0)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getUsername());
            ps.setString(4, user.getPasswordHash());
            ps.setString(5, user.getPhone());
            ps.setInt(6, user.getRoleId());
            ps.setString(7, user.getStatus());
            ps.setString(8, user.getVerificationToken());
            ps.setBoolean(9, user.isVerified());
            ps.setString(10, user.getGoogleId());
            ps.setString(11, user.getAuthProvider());

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
        // Đọc username (có thể null nếu migration chưa chạy)
        try {
            user.setUsername(rs.getString("username"));
        } catch (SQLException e) {
            user.setUsername(null);
        }
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
        String sql = "SELECT id, full_name, username, " + DECRYPT_EMAIL + ", password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE verification_token = ? AND is_deleted = 0";

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
        String sql = "SELECT id, full_name, username, " + DECRYPT_EMAIL + ", password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE " + WHERE_PHONE_EQUAL + " AND is_deleted = 0";

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
        String sql = "SELECT id, full_name, username, " + DECRYPT_EMAIL + ", password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE id = ? AND is_deleted = 0";

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
        String sql = "SELECT id, full_name, username, " + DECRYPT_EMAIL + ", password_hash, "
                   + DECRYPT_PHONE + ", role_id, status, "
                   + "verification_token, is_verified, google_id, auth_provider "
                   + "FROM users WHERE google_id = ? AND is_deleted = 0";

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
    /**
     * @param roleIds danh sách role_id cần lọc (NULL = tất cả role, rỗng = không lọc)
     */
    public java.util.List<User> findAll(int offset, int pageSize,
                                         String search, java.util.List<Integer> roleIds, String statusFilter,
                                         boolean includeDeleted) {
        // Thử query đầy đủ trước, nếu lỗi cột thì fallback
        try {
            return findAllInternal(offset, pageSize, search, roleIds, statusFilter, true, includeDeleted);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column") ||
                msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] Falling back to base columns query: " + msg);
                try {
                    return findAllInternal(offset, pageSize, search, roleIds, statusFilter, false, includeDeleted);
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
                                                  String search, java.util.List<Integer> roleIds,
                                                  String statusFilter, boolean fullColumns,
                                                  boolean includeDeleted)
            throws SQLException {
        // Chọn cột: fullColumns=true dùng đủ cột, false dùng cột cơ bản (luôn tồn tại)
        String columns;
        if (fullColumns) {
            columns = "u.id, u.full_name, " + DECRYPT_EMAIL_U + ", u.username, "
                    + DECRYPT_PHONE_U + ", u.role_id, u.status, "
                    + "u.created_at, u.is_verified, u.auth_provider, r.role_name";
        } else {
            columns = "u.id, u.full_name, " + DECRYPT_EMAIL_U + ", u.username, "
                    + DECRYPT_PHONE_U + ", u.role_id, u.status, "
                    + "r.role_name";
        }
        // Luôn select is_deleted để JSP biết user nào đã bị xoá mềm
        columns += ", u.is_deleted";

        // WHERE clause: mặc định chỉ hiện user chưa xoá (is_deleted=0),
        // khi includeDeleted=true → chỉ hiện user đã xoá (is_deleted=1)
        String whereClause = includeDeleted ? "u.is_deleted = 1" : "u.is_deleted = 0";

        StringBuilder sql = new StringBuilder("SELECT ").append(columns)
            .append(" FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE ")
            .append(whereClause).append(" ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR " + WHERE_U_EMAIL_LIKE + " OR " + WHERE_U_PHONE_LIKE + ") ");
        }
        if (roleIds != null && !roleIds.isEmpty()) {
            sql.append("AND u.role_id IN (");
            for (int i = 0; i < roleIds.size(); i++) {
                if (i > 0) sql.append(", ");
                sql.append("?");
            }
            sql.append(") ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND u.status = ? ");
        }
        sql.append("ORDER BY u.id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

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
            if (roleIds != null && !roleIds.isEmpty()) {
                for (Integer roleId : roleIds) {
                    ps.setInt(idx++, roleId);
                }
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
    public int countAll(String search, java.util.List<Integer> roleIds, String statusFilter, boolean includeDeleted) {
        // Mặc định đếm user chưa xoá, includeDeleted=true → đếm user đã xoá
        String whereClause = includeDeleted ? "is_deleted = 1" : "is_deleted = 0";
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM users WHERE " + whereClause + " ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (full_name LIKE ? OR " + WHERE_EMAIL_LIKE + " OR " + WHERE_PHONE_LIKE + ") ");
        }
        if (roleIds != null && !roleIds.isEmpty()) {
            sql.append("AND role_id IN (");
            for (int i = 0; i < roleIds.size(); i++) {
                if (i > 0) sql.append(", ");
                sql.append("?");
            }
            sql.append(") ");
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
            if (roleIds != null && !roleIds.isEmpty()) {
                for (Integer roleId : roleIds) {
                    ps.setInt(idx++, roleId);
                }
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
     * Xóa user theo id (hard delete — chỉ dùng cho dữ liệu test).
     * Nên dùng softDelete() cho môi trường production.
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
     * Soft delete user: đặt is_deleted = 1 thay vì xóa vật lý.
     * Giữ nguyên dữ liệu liên quan (bệnh án, lịch hẹn, hóa đơn...).
     * Tự động fallback nếu cột updated_at chưa được migration.
     */
    public boolean softDelete(int userId) {
        String sql = "UPDATE users SET is_deleted = 1, status = 'Inactive', updated_at = GETDATE() WHERE id = ?";
        try {
            return softDeleteInternal(userId, sql);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column")
                || msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] softDelete falling back (no updated_at column): " + msg);
                try {
                    String fallbackSql = "UPDATE users SET is_deleted = 1, status = 'Inactive' WHERE id = ?";
                    return softDeleteInternal(userId, fallbackSql);
                } catch (SQLException e2) {
                    System.err.println("[UserDAO] softDelete fallback also failed: " + e2.getMessage());
                    return false;
                }
            }
            System.err.println("Lỗi softDelete user: " + e.getMessage());
            return false;
        }
    }

    private boolean softDeleteInternal(int userId, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Khôi phục user đã bị soft delete: đặt is_deleted = 0, status = 'Active'.
     * Tự động fallback nếu cột updated_at chưa được migration.
     */
    public boolean restore(int userId) {
        String sql = "UPDATE users SET is_deleted = 0, status = 'Active', updated_at = GETDATE() WHERE id = ?";
        try {
            return restoreInternal(userId, sql);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column")
                || msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] restore falling back (no updated_at column): " + msg);
                try {
                    String fallbackSql = "UPDATE users SET is_deleted = 0, status = 'Active' WHERE id = ?";
                    return restoreInternal(userId, fallbackSql);
                } catch (SQLException e2) {
                    System.err.println("[UserDAO] restore fallback also failed: " + e2.getMessage());
                    return false;
                }
            }
            System.err.println("Lỗi restore user: " + e.getMessage());
            return false;
        }
    }

    private boolean restoreInternal(int userId, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Cập nhật thông tin user (full_name, email, phone, username, role_id, status).
     * Tự động fallback nếu cột updated_at chưa được migration.
     */
    public boolean update(User user) {
        String sql = "UPDATE users SET full_name=?, email=" + ENCRYPT_EMAIL_PARAM
                   + ", phone=" + ENCRYPT_PHONE_PARAM
                   + ", username=?, role_id=?, status=?, updated_at=GETDATE() WHERE id=?";
        // Thử query đầy đủ trước, nếu lỗi cột updated_at thì fallback
        try {
            return updateInternal(user, sql);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column")
                || msg.contains("tên cột không hợp lệ") || msg.contains("colonne non valide")) {
                System.err.println("[UserDAO] update falling back (no updated_at column): " + msg);
                try {
                    String fallbackSql = "UPDATE users SET full_name=?, email=" + ENCRYPT_EMAIL_PARAM
                                       + ", phone=" + ENCRYPT_PHONE_PARAM
                                       + ", username=?, role_id=?, status=? WHERE id=?";
                    return updateInternalFallback(user, fallbackSql);
                } catch (SQLException e2) {
                    System.err.println("[UserDAO] update fallback also failed: " + e2.getMessage());
                    return false;
                }
            }
            System.err.println("Lỗi update user: " + e.getMessage());
            return false;
        }
    }

    /** Thực thi UPDATE với query đầy đủ (có updated_at). */
    private boolean updateInternal(User user, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());       // email (mã hoá)
            ps.setString(3, user.getPhone());       // phone (mã hoá)
            ps.setString(4, user.getUsername());
            ps.setInt(5, user.getRoleId());
            ps.setString(6, user.getStatus());
            ps.setInt(7, user.getId());
            return ps.executeUpdate() > 0;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Thực thi UPDATE với query fallback (không có updated_at). */
    private boolean updateInternalFallback(User user, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());       // email (mã hoá)
            ps.setString(3, user.getPhone());       // phone (mã hoá)
            ps.setString(4, user.getUsername());
            ps.setInt(5, user.getRoleId());
            ps.setString(6, user.getStatus());
            ps.setInt(7, user.getId());
            return ps.executeUpdate() > 0;
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
        try { u.setUsername(rs.getString("username")); } catch (SQLException e) { u.setUsername(null); }
        u.setRoleId(rs.getInt("role_id"));
        u.setStatus(rs.getString("status"));
        if (fullColumns) {
            try { u.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { u.setCreatedAt(null); }
            try { u.setVerified(rs.getBoolean("is_verified")); } catch (SQLException e) { u.setVerified(false); }
            try { u.setAuthProvider(rs.getString("auth_provider")); } catch (SQLException e) { u.setAuthProvider("local"); }
        }
        try { u.setRoleName(rs.getString("role_name")); } catch (SQLException e) { u.setRoleName("Unknown"); }
        try { u.setDeleted(rs.getBoolean("is_deleted")); } catch (SQLException e) { u.setDeleted(false); }
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
            columns = "u.id, u.full_name, " + DECRYPT_EMAIL_U + ", " + DECRYPT_PHONE_U + ", u.role_id, u.status, "
                    + "u.created_at, r.role_name";
        } else {
            columns = "u.id, u.full_name, " + DECRYPT_EMAIL_U + ", " + DECRYPT_PHONE_U + ", u.role_id, u.status, "
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
