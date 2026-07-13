package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng notifications.
 */
public class NotificationDAO {

    /**
     * Lấy tất cả thông báo của 1 user, mới nhất trước (tối đa 50).
     */
    public List<Notification> getByUserId(int userId) {
        String sql =
            "SELECT TOP 50 id, user_id, title, content, channel, is_read, created_at " +
            "FROM notifications WHERE user_id = ? ORDER BY created_at DESC";
        List<Notification> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Đếm số thông báo chưa đọc của user.
     */
    public int countUnread(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    /**
     * Tạo thông báo mới cho 1 user.
     */
    public boolean create(int userId, String title, String content) {
        String sql =
            "INSERT INTO notifications (user_id, title, content, channel, is_read, created_at) " +
            "VALUES (?, ?, ?, 'system', 0, GETDATE())";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Đánh dấu 1 thông báo đã đọc.
     */
    public boolean markRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read=1 WHERE id=? AND user_id=?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Đánh dấu tất cả thông báo của user đã đọc.
     */
    public boolean markAllRead(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE notifications SET is_read=1 WHERE user_id=? AND is_read=0")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setChannel(rs.getString("channel"));
        n.setRead(rs.getBoolean("is_read"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) n.setCreatedAt(ts.toLocalDateTime());
        return n;
    }
}