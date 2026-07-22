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

    public int insert(UltrasoundImage img) {
        String sql = "INSERT INTO ultrasound_images (test_order_id, original_filename, stored_filename, file_path, file_size, content_type, uploaded_by, uploaded_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
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

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] insert ERROR: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
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
                return img;
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] getById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM ultrasound_images WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageDAO] delete ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
