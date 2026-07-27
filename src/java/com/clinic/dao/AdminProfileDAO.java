package com.clinic.dao;

import com.clinic.config.DatabaseConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * DAO hẹp cho trang Hồ Sơ Cá Nhân của Quản trị viên.
 *
 * <p>Chỉ có duy nhất một câu UPDATE, tác động đúng MỘT cột mà quản trị viên được
 * phép tự sửa ({@code full_name}) cộng thêm {@code updated_at}.
 *
 * <p><b>Lý do tồn tại:</b> {@link UserDAO#update(com.clinic.model.User)} có chứa
 * {@code role_id = ?} và {@code status = ?} trong câu UPDATE. Dù trang hồ sơ ghi
 * lại đúng giá trị vừa đọc từ CSDL (nên không đổi gì), câu lệnh vẫn nhắc tới cột
 * vai trò. Lớp này bảo đảm cột {@code role_id} KHÔNG BAO GIỜ xuất hiện trong câu
 * UPDATE phát sinh từ trang hồ sơ — không thể leo thang quyền qua đường này,
 * kể cả khi có lỗi lập trình ở tầng trên.
 *
 * <p><b>Email và số điện thoại nay là trường CHỈ-XEM</b> nên đã được gỡ khỏi câu
 * UPDATE. Nhờ vậy lớp này không còn cần tới cơ chế mã hoá ENCRYPTBYPASSPHRASE.
 *
 * <p>Tái sử dụng {@link DatabaseConfig} để lấy kết nối — không tự viết lớp kết nối mới.
 */
public class AdminProfileDAO {

    // Không còn cần mã hoá: email và phone nay là trường CHỈ-XEM,
    // câu UPDATE của lớp này chỉ còn cột full_name (kiểu nvarchar thường).

    /**
     * Cập nhật đúng MỘT trường mà quản trị viên được phép tự sửa: họ tên.
     *
     * <p>Email, số điện thoại và vai trò đều là trường CHỈ-XEM trên trang hồ sơ, nên
     * KHÔNG có mặt trong câu lệnh này. Cùng với việc servlet không gọi
     * {@code getParameter} cho chúng, đây là lớp khoá thứ hai: kể cả khi tầng trên có
     * lỗi lập trình cũng không có đường nào sửa được ba trường đó từ trang hồ sơ.
     *
     * <p>Cũng không có role_id, status, username, is_deleted hay password_hash.
     *
     * @param userId   id người dùng (LUÔN lấy từ session ở tầng servlet)
     * @param fullName họ tên mới (đã validate, không null)
     * @return true nếu có đúng 1 dòng được cập nhật
     */
    public boolean updateBasicInfo(int userId, String fullName) {
        String sql = "UPDATE users SET full_name = ?, "
                   + "updated_at = GETDATE() "
                   + "WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, fullName);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AdminProfileDAO] updateBasicInfo ERROR: " + e.getMessage());
            return false;
        } finally {
            if (ps != null) {
                try {
                    ps.close();
                } catch (SQLException e) {
                    System.err.println("[AdminProfileDAO] Lỗi đóng PreparedStatement: " + e.getMessage());
                }
            }
            DatabaseConfig.closeConnection(conn);
        }
    }
}
