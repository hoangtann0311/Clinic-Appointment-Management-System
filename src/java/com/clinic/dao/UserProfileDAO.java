package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.UserProfile;
import com.clinic.utils.EncryptionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DAO hẹp cho trang Hồ Sơ Cá Nhân của những vai trò chỉ có dữ liệu ở bảng
 * {@code users}: Nhân viên lễ tân (role_id = 4) và Quản lý (role_id = 3).
 *
 * <p>Theo đúng mẫu {@link AdminProfileDAO}: câu UPDATE duy nhất chỉ liệt kê
 * những cột người dùng được phép tự sửa. Cột chỉ-xem không bao giờ xuất hiện,
 * nên không có đường nào từ trang hồ sơ sửa được chúng — kể cả khi tầng trên
 * có lỗi lập trình.
 *
 * <p><b>Cột được phép sửa:</b> {@code full_name}, {@code phone}.
 *
 * <p><b>Cột KHÔNG có trong câu UPDATE:</b> {@code email}, {@code role_id},
 * {@code status}, {@code username}, {@code is_deleted}, {@code password_hash},
 * {@code department}, {@code job_title}.
 *
 * <p>Khác {@link AdminProfileDAO} ở chỗ lớp đó có {@code email} trong câu UPDATE
 * (Quản trị viên được tự đổi email). Nhân viên và Quản lý thì không, nên phải là
 * câu lệnh riêng chứ không dùng lại được.
 *
 * <p>Cột {@code email}/{@code phone} là {@code varbinary(256)} đã mã hoá bằng
 * ENCRYPTBYPASSPHRASE, xử lý giống hệt cách {@link UserDAO} làm.
 */
public class UserProfileDAO {

    /** Passphrase chỉ đọc từ cấu hình ngoài source, escape dấu nháy đơn. */
    private static final String DB_KEY =
            EncryptionUtil.getPassphrase().replace("'", "''");

    private static final String DECRYPT_EMAIL =
            "CONVERT(NVARCHAR(100), DECRYPTBYPASSPHRASE('" + DB_KEY + "', email)) AS email";

    private static final String DECRYPT_PHONE =
            "CONVERT(NVARCHAR(20), DECRYPTBYPASSPHRASE('" + DB_KEY + "', phone)) AS phone";

    private static final String ENCRYPT_PHONE_PARAM =
            "ENCRYPTBYPASSPHRASE('" + DB_KEY + "', ?)";

    /**
     * Nạp hồ sơ của chính người dùng.
     *
     * @param userId LUÔN lấy từ session ở tầng servlet, không bao giờ từ request
     * @return hồ sơ, hoặc {@code null} nếu không tìm thấy tài khoản
     */
    public UserProfile findByUserId(int userId) {
        String sql = "SELECT id, full_name, " + DECRYPT_EMAIL + ", " + DECRYPT_PHONE + ", "
                   + "       department, job_title "
                   + "FROM users WHERE id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new UserProfile(
                            rs.getInt("id"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getString("department"),
                            rs.getString("job_title"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserProfileDAO] findByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Cập nhật đúng hai trường người dùng được phép tự sửa.
     *
     * @param userId   LUÔN lấy từ session ở tầng servlet
     * @param fullName họ tên mới đã validate, không null
     * @param phone    số điện thoại mới, hoặc null nếu để trống
     * @return true nếu có đúng 1 dòng được cập nhật
     */
    /**
     * Cập nhật bộ phận và chức danh — hai trường tổ chức do QUẢN TRỊ VIÊN phân công.
     *
     * <p>Cố ý tách khỏi {@link #updateBasicInfo}: trang hồ sơ cá nhân của Nhân viên và
     * Quản lý hiển thị hai trường này ở dạng CHỈ-XEM và không bao giờ gọi hàm này.
     * Chỉ màn Quản Lý Người Dùng mới được gọi. Nhờ vậy câu UPDATE của trang hồ sơ
     * vẫn không chứa hai cột này, đúng như thiết kế đã duyệt.
     *
     * @param userId     id tài khoản cần gán
     * @param department bộ phận, hoặc null để xoá
     * @param jobTitle   chức danh, hoặc null để xoá
     * @return true nếu có đúng 1 dòng được cập nhật
     */
    public boolean updateOrgInfo(int userId, String department, String jobTitle) {
        String sql = "UPDATE users SET department = ?, job_title = ?, updated_at = GETDATE() "
                   + "WHERE id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, department);
            ps.setString(2, jobTitle);
            ps.setInt(3, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UserProfileDAO] updateOrgInfo ERROR: " + e.getMessage());
            return false;
        }
    }

    public boolean updateBasicInfo(int userId, String fullName, String phone) {
        String sql = "UPDATE users SET full_name = ?, "
                   + "phone = " + ENCRYPT_PHONE_PARAM + ", "
                   + "updated_at = GETDATE() "
                   + "WHERE id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setInt(3, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UserProfileDAO] updateBasicInfo ERROR: " + e.getMessage());
            return false;
        }
    }
}
