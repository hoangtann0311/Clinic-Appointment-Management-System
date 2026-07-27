package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Sonographer;
import com.clinic.utils.EncryptionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

/**
 * DAO hẹp cho trang Hồ Sơ Cá Nhân của Bác sĩ siêu âm (role_id = 6).
 *
 * <p><b>Vì sao là DAO riêng, hẹp:</b> theo đúng mẫu {@link AdminProfileDAO}. Câu UPDATE
 * ở đây chỉ liệt kê những cột người dùng được phép tự sửa. Các cột chỉ-xem KHÔNG BAO
 * GIỜ xuất hiện trong câu lệnh, nên không có đường nào từ trang hồ sơ sửa được chúng,
 * kể cả khi tầng trên có lỗi lập trình.
 *
 * <p><b>Cột được phép sửa:</b>
 * <ul>
 *   <li>{@code users.full_name}, {@code users.phone}</li>
 *   <li>{@code sonographers.specialization}, {@code degree}, {@code experience_years},
 *       {@code bio}, {@code avatar_url}, {@code qualification}</li>
 * </ul>
 *
 * <p><b>Cột KHÔNG có trong bất kỳ câu UPDATE nào của lớp này:</b>
 * {@code users.email}, {@code users.role_id}, {@code users.status},
 * {@code users.username}, {@code users.is_deleted}, {@code users.password_hash},
 * {@code sonographers.room_no}, {@code sonographers.status}.
 *
 * <p>Cột {@code users.phone} là {@code varbinary(256)} đã mã hoá bằng
 * ENCRYPTBYPASSPHRASE, nên phải mã hoá khi ghi giống hệt cách {@link UserDAO} làm.
 */
public class SonographerProfileDAO {

    /** Passphrase chỉ đọc từ cấu hình ngoài source, escape dấu nháy đơn. */
    private static final String DB_KEY =
            EncryptionUtil.getPassphrase().replace("'", "''");

    /** Dùng trong SELECT: giải mã cột phone thành NVARCHAR(20). */
    private static final String DECRYPT_PHONE =
            "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.phone)) AS phone";

    /** Dùng trong SELECT: giải mã cột email thành NVARCHAR(100). */
    private static final String DECRYPT_EMAIL =
            "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', u.email)) AS email";

    /** Dùng trong UPDATE: mã hoá giá trị lấy từ parameter. */
    private static final String ENCRYPT_PHONE_PARAM =
            "ENCRYPTBYPASSPHRASE('" + DB_KEY + "', ?)";

    // ══════════════════════════════════════════════════════════
    // ĐỌC
    // ══════════════════════════════════════════════════════════

    /**
     * Nạp phần chuyên môn theo user_id. Trả về {@code null} nếu tài khoản chưa có
     * dòng trong bảng {@code sonographers}.
     *
     * @param userId LUÔN lấy từ session ở tầng servlet
     */
    public Sonographer findByUserId(int userId) {
        String sql = "SELECT s.id, s.user_id, s.qualification, s.specialization, "
                   + "       s.degree, s.experience_years, s.bio, s.avatar_url "
                   + "FROM sonographers s WHERE s.user_id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[SonographerProfileDAO] findByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Đọc email và số điện thoại đã giải mã của chính người dùng.
     * Trả về mảng {@code [email, phone]}, phần tử có thể null.
     *
     * @param userId LUÔN lấy từ session ở tầng servlet
     */
    public String[] findContactByUserId(int userId) {
        String sql = "SELECT " + DECRYPT_EMAIL + ", " + DECRYPT_PHONE + " "
                   + "FROM users u WHERE u.id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new String[]{rs.getString("email"), rs.getString("phone")};
                }
            }
        } catch (SQLException e) {
            System.err.println("[SonographerProfileDAO] findContactByUserId ERROR: " + e.getMessage());
        }
        return new String[]{null, null};
    }

    // ══════════════════════════════════════════════════════════
    // GHI
    // ══════════════════════════════════════════════════════════

    /**
     * Lưu hồ sơ trong một giao dịch: bảo đảm có dòng {@code sonographers}, cập nhật
     * phần chuyên môn, rồi cập nhật họ tên và số điện thoại ở bảng {@code users}.
     *
     * <p>Bước bảo đảm dòng tồn tại CHỈ chạy ở luồng POST (khi người dùng bấm Lưu),
     * không bao giờ chạy ở GET — một request đọc không được phép ghi dữ liệu nghiệp vụ.
     *
     * <p>Câu INSERT dùng {@code WHERE NOT EXISTS} và dựa trên ràng buộc UNIQUE sẵn có
     * {@code UQ__sonograp__B9BE370E708195D7} trên {@code user_id}, nên hai request
     * đồng thời cũng không tạo được hai dòng.
     *
     * @param userId   LUÔN lấy từ session ở tầng servlet
     * @param profile  phần chuyên môn đã validate
     * @param fullName họ tên mới đã validate, không null
     * @param phone    số điện thoại mới, hoặc null nếu để trống
     * @return true nếu lưu thành công
     */
    public boolean saveProfile(int userId, Sonographer profile, String fullName, String phone) {

        String ensureSql =
                "INSERT INTO sonographers (user_id, status) "
              + "SELECT ?, 'Active' "
              + "WHERE NOT EXISTS (SELECT 1 FROM sonographers WHERE user_id = ?)";

        // KHÔNG có room_no, KHÔNG có status — hai cột đó ngoài phạm vi trang hồ sơ.
        String updateProfileSql =
                "UPDATE sonographers SET specialization = ?, degree = ?, experience_years = ?, "
              + "  bio = ?, avatar_url = ?, qualification = ? "
              + "WHERE user_id = ?";

        // KHÔNG có role_id, email, status, username, is_deleted, password_hash.
        String updateUserSql =
                "UPDATE users SET full_name = ?, phone = " + ENCRYPT_PHONE_PARAM + ", "
              + "  updated_at = GETDATE() "
              + "WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(ensureSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateProfileSql)) {
                ps.setString(1, profile.getSpecialization());
                ps.setString(2, profile.getDegree());
                if (profile.getExperienceYears() > 0) {
                    ps.setInt(3, profile.getExperienceYears());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setString(4, profile.getBio());
                ps.setString(5, profile.getAvatarUrl());
                ps.setString(6, profile.getQualification());
                ps.setInt(7, userId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
                ps.setString(1, fullName);
                ps.setString(2, phone);
                ps.setInt(3, userId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("[SonographerProfileDAO] rollback lỗi: " + ex.getMessage());
                }
            }
            System.err.println("[SonographerProfileDAO] saveProfile ERROR: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                    // Kết nối sắp đóng, không cần xử lý thêm.
                }
            }
            DatabaseConfig.closeConnection(conn);
        }
    }

    // ══════════════════════════════════════════════════════════
    // HELPER
    // ══════════════════════════════════════════════════════════

    private Sonographer mapRow(ResultSet rs) throws SQLException {
        Sonographer s = new Sonographer();
        s.setId(rs.getInt("id"));
        s.setUserId(rs.getInt("user_id"));
        s.setQualification(rs.getString("qualification"));
        s.setSpecialization(rs.getString("specialization"));
        s.setDegree(rs.getString("degree"));
        s.setExperienceYears(rs.getInt("experience_years"));
        s.setBio(rs.getString("bio"));
        s.setAvatarUrl(rs.getString("avatar_url"));
        return s;
    }
}
