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
}
