package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class ReviewDAO {

    public boolean insert(Review review) {
        String sql = "INSERT INTO reviews (appointment_id, rating, comment, created_at) VALUES (?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getAppointmentId());
            ps.setInt(2, review.getRating());
            ps.setString(3, review.getComment());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Review getByAppointmentId(int appointmentId) {
        String sql = "SELECT id, appointment_id, rating, comment, created_at FROM reviews WHERE appointment_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review review = new Review();
                    review.setId(rs.getInt("id"));
                    review.setAppointmentId(rs.getInt("appointment_id"));
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    review.setCreatedAt(rs.getTimestamp("created_at"));
                    return review;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean hasReviewed(int appointmentId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE appointment_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Batch: kiểm tra đã đánh giá cho nhiều appointment. */
    public java.util.Map<Integer, Boolean> batchHasReviewed(java.util.List<Integer> apptIds) {
        java.util.Map<Integer, Boolean> result = new java.util.HashMap<>();
        if (apptIds == null || apptIds.isEmpty()) return result;
        for (int id : apptIds) result.put(id, false);

        StringBuilder ph = new StringBuilder();
        for (int i = 0; i < apptIds.size(); i++) { if (i > 0) ph.append(","); ph.append("?"); }
        String sql = "SELECT appointment_id FROM reviews WHERE appointment_id IN (" + ph + ")";
        try (java.sql.Connection conn = DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < apptIds.size(); i++) ps.setInt(i + 1, apptIds.get(i));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.put(rs.getInt("appointment_id"), true);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("[ReviewDAO] batchHasReviewed ERROR: " + e.getMessage());
        }
        return result;
    }
}
