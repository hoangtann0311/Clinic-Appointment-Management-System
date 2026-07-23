package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.UltrasoundImage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng ultrasound_images.
 */
public class UltrasoundImageDAO {

    private static volatile Boolean dimensionColumnsSupported;

    /** Inserts image metadata on the caller's transaction. */
    public int insert(Connection conn, UltrasoundImage img) throws SQLException {
        boolean dimensions = supportsDimensionColumns();
        String sql = dimensions
                ? "INSERT INTO ultrasound_images (test_order_id, original_filename, stored_filename, file_path, file_size, content_type, uploaded_by, uploaded_at, image_width, image_height) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                : "INSERT INTO ultrasound_images (test_order_id, original_filename, stored_filename, file_path, file_size, content_type, uploaded_by, uploaded_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, img.getTestOrderId());
            ps.setString(2, img.getOriginalFilename());
            ps.setString(3, img.getStoredFilename());
            ps.setString(4, img.getFilePath());
            ps.setLong(5, img.getFileSize());
            ps.setString(6, img.getContentType());
            ps.setInt(7, img.getUploadedBy());
            if (img.getUploadedAt() != null) {
                ps.setTimestamp(8, img.getUploadedAt());
            } else {
                ps.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
            }
            if (dimensions) {
                if (img.getImageWidth() == null) ps.setNull(9, Types.INTEGER); else ps.setInt(9, img.getImageWidth());
                if (img.getImageHeight() == null) ps.setNull(10, Types.INTEGER); else ps.setInt(10, img.getImageHeight());
            }

            if (ps.executeUpdate() == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("Không lấy được ID ảnh siêu âm.");
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public List<UltrasoundImage> getByTestOrderId(int testOrderId) {
        String sql = "SELECT ui.*, u.full_name AS uploader_name FROM ultrasound_images ui "
                   + "LEFT JOIN users u ON ui.uploaded_by = u.id "
                   + "WHERE ui.test_order_id = ? "
                   + "ORDER BY ui.uploaded_at ASC";
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
                UltrasoundImage img = new UltrasoundImage();
                img.setId(rs.getInt("id"));
                img.setTestOrderId(rs.getInt("test_order_id"));
                img.setOriginalFilename(rs.getString("original_filename"));
                img.setStoredFilename(rs.getString("stored_filename"));
                img.setFilePath(rs.getString("file_path"));
                img.setFileSize(rs.getLong("file_size"));
                img.setContentType(rs.getString("content_type"));
                img.setUploadedBy(rs.getInt("uploaded_by"));
                img.setUploadedAt(rs.getTimestamp("uploaded_at"));
                img.setUploaderName(rs.getString("uploader_name"));
                mapDimensions(rs, img);
                list.add(img);
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] getByTestOrderId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    public UltrasoundImage getById(int id) {
        String sql = "SELECT ui.*, u.full_name AS uploader_name FROM ultrasound_images ui "
                   + "LEFT JOIN users u ON ui.uploaded_by = u.id "
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
                UltrasoundImage img = new UltrasoundImage();
                img.setId(rs.getInt("id"));
                img.setTestOrderId(rs.getInt("test_order_id"));
                img.setOriginalFilename(rs.getString("original_filename"));
                img.setStoredFilename(rs.getString("stored_filename"));
                img.setFilePath(rs.getString("file_path"));
                img.setFileSize(rs.getLong("file_size"));
                img.setContentType(rs.getString("content_type"));
                img.setUploadedBy(rs.getInt("uploaded_by"));
                img.setUploadedAt(rs.getTimestamp("uploaded_at"));
                img.setUploaderName(rs.getString("uploader_name"));
                mapDimensions(rs, img);
                return img;
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] getById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }

    public boolean updateDimensions(int id, int width, int height) {
        if (!supportsDimensionColumns() || id <= 0 || width <= 0 || height <= 0) return false;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE ultrasound_images SET image_width = ?, image_height = ? WHERE id = ? "
                             + "AND (image_width IS NULL OR image_height IS NULL)")) {
            ps.setInt(1, width);
            ps.setInt(2, height);
            ps.setInt(3, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] updateDimensions ERROR: " + e.getMessage());
            return false;
        }
    }

    private boolean supportsDimensionColumns() {
        Boolean cached = dimensionColumnsSupported;
        if (cached != null) return cached;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT CASE WHEN COL_LENGTH('dbo.ultrasound_images','image_width') IS NOT NULL "
                             + "AND COL_LENGTH('dbo.ultrasound_images','image_height') IS NOT NULL THEN 1 ELSE 0 END");
             ResultSet rs = ps.executeQuery()) {
            dimensionColumnsSupported = rs.next() && rs.getInt(1) == 1;
        } catch (SQLException e) {
            dimensionColumnsSupported = false;
        }
        return dimensionColumnsSupported;
    }

    private void mapDimensions(ResultSet rs, UltrasoundImage img) {
        try {
            int width = rs.getInt("image_width");
            img.setImageWidth(rs.wasNull() ? null : width);
            int height = rs.getInt("image_height");
            img.setImageHeight(rs.wasNull() ? null : height);
        } catch (SQLException ignored) {
            img.setImageWidth(null);
            img.setImageHeight(null);
        }
    }
}
