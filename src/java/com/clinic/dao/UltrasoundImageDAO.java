package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.UltrasoundImage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng ultrasound_images — ảnh siêu âm.
 * Hỗ trợ thêm mới, truy vấn theo test_order, tìm theo id và xoá.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class UltrasoundImageDAO {

    /**
     * Thêm mới một bản ghi ảnh siêu âm.
     *
     * @param image đối tượng UltrasoundImage đã được thiết lập đầy đủ thông tin
     * @return true nếu insert thành công, false nếu thất bại
     */
    public boolean insert(UltrasoundImage image) {
        String sql = "INSERT INTO ultrasound_images (test_order_id, original_filename, stored_filename, "
                   + "file_path, file_size, content_type, uploaded_by, uploaded_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, image.getTestOrderId());
            ps.setNString(2, image.getOriginalFilename());
            ps.setNString(3, image.getStoredFilename());
            ps.setNString(4, image.getFilePath());
            ps.setLong(5, image.getFileSize());
            ps.setString(6, image.getContentType());
            if (image.getUploadedBy() != null) {
                ps.setInt(7, image.getUploadedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(8, image.getUploadedAt() != null
                    ? image.getUploadedAt()
                    : new Timestamp(System.currentTimeMillis()));

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] insert ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Lấy danh sách ảnh siêu âm theo test_order_id.
     *
     * @param testOrderId ID của test_order
     * @return danh sách UltrasoundImage, sắp xếp theo uploaded_at DESC
     */
    public List<UltrasoundImage> findByTestOrderId(int testOrderId) {
        String sql = "SELECT ui.id, ui.test_order_id, ui.original_filename, ui.stored_filename, "
                   + "ui.file_path, ui.file_size, ui.content_type, ui.uploaded_by, ui.uploaded_at, "
                   + "ISNULL(u.full_name, N'—') AS uploader_name, "
                   + "ISNULL(r.role_name, N'—') AS uploader_role "
                   + "FROM ultrasound_images ui "
                   + "LEFT JOIN users u ON ui.uploaded_by = u.id "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "WHERE ui.test_order_id = ? "
                   + "ORDER BY ui.uploaded_at DESC";

        List<UltrasoundImage> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, testOrderId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] findByTestOrderId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tìm một ảnh siêu âm theo id.
     *
     * @param id ID của ảnh
     * @return UltrasoundImage hoặc null nếu không tìm thấy
     */
    public UltrasoundImage findById(int id) {
        String sql = "SELECT ui.id, ui.test_order_id, ui.original_filename, ui.stored_filename, "
                   + "ui.file_path, ui.file_size, ui.content_type, ui.uploaded_by, ui.uploaded_at, "
                   + "ISNULL(u.full_name, N'—') AS uploader_name, "
                   + "ISNULL(r.role_name, N'—') AS uploader_role "
                   + "FROM ultrasound_images ui "
                   + "LEFT JOIN users u ON ui.uploaded_by = u.id "
                   + "LEFT JOIN roles r ON u.role_id = r.id "
                   + "WHERE ui.id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Xoá một bản ghi ảnh siêu âm theo id.
     *
     * @param id ID của ảnh cần xoá
     * @return true nếu xoá thành công
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM ultrasound_images WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] delete ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Đếm số lượng ảnh đã upload cho một test_order.
     *
     * @param testOrderId ID của test_order
     * @return số lượng ảnh
     */
    public int countByTestOrderId(int testOrderId) {
        String sql = "SELECT COUNT(*) AS total FROM ultrasound_images WHERE test_order_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, testOrderId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] countByTestOrderId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    // ── Helper ──

    private UltrasoundImage mapRow(ResultSet rs) throws SQLException {
        UltrasoundImage img = new UltrasoundImage();
        img.setId(rs.getInt("id"));
        img.setTestOrderId(rs.getInt("test_order_id"));
        img.setOriginalFilename(rs.getString("original_filename"));
        img.setStoredFilename(rs.getString("stored_filename"));
        img.setFilePath(rs.getString("file_path"));
        img.setFileSize(rs.getLong("file_size"));
        img.setContentType(rs.getString("content_type"));

        int uid = rs.getInt("uploaded_by");
        img.setUploadedBy(rs.wasNull() ? null : uid);

        img.setUploadedAt(rs.getTimestamp("uploaded_at"));

        // Transient fields — hiển thị
        try { img.setUploaderName(rs.getString("uploader_name")); } catch (SQLException e) { img.setUploaderName("—"); }
        try { img.setUploaderRole(rs.getString("uploader_role")); } catch (SQLException e) { img.setUploaderRole("—"); }

        return img;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { /* ignore */ } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { /* ignore */ } }
        DatabaseConfig.closeConnection(conn);
    }
}
