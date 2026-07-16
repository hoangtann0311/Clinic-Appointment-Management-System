package com.clinic.dao;

import com.clinic.config.DatabaseConfig;

import com.clinic.model.Doctor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng doctors — tra cứu thông tin bác sĩ.
 */
public class DoctorDAO {

    public DoctorDAO() {
    }

    /**
     * Lấy tất cả bác sĩ, sắp xếp theo tên. (Bác sĩ dashboard / manager)
     */
    public List<Doctor> findAll() {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d ORDER BY d.full_name";

        List<Doctor> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findAll ERROR: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy tất cả bác sĩ. (Manual booking / receptionist)
     */
    public List<Doctor> getAllDoctors() {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT id, full_name, specialization, phone_number, degree, experience_years, avatar_url FROM doctors";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToDoctor(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm bác sĩ theo id (Bác sĩ dashboard / manager)
     */
    public Doctor findById(int id) {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d WHERE d.id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findById ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Tìm bác sĩ theo id (receptionist)
     */
    public Doctor findDoctorById(int id) {
        String sql = "SELECT id, full_name, specialization, phone_number, degree, experience_years, avatar_url FROM doctors WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToDoctor(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm bác sĩ theo user_id (liên kết với bảng users).
     */
    public Doctor findByUserId(int userId) {
        String sql =
            "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number, " +
            "       d.degree, d.experience_years, d.bio, d.avatar_url " +
            "FROM doctors d " +
            "WHERE d.user_id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Bác sĩ tự cập nhật hồ sơ cá nhân.
     * Chỉ cho phép sửa: full_name, specialization, phone_number, degree, experience_years, bio, avatar_url.
     * Email/username/password không được sửa ở đây.
     */
    public boolean updateProfile(Doctor d) {
        String sql =
            "UPDATE doctors SET full_name=?, specialization=?, phone_number=?, " +
            "  degree=?, experience_years=?, bio=?, avatar_url=? " +
            "WHERE id=?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getFullName());
            ps.setString(2, d.getSpecialization());
            ps.setString(3, d.getPhoneNumber());
            ps.setString(4, d.getDegree());
            if (d.getExperienceYears() >= 0) ps.setInt(5, d.getExperienceYears());
            else ps.setNull(5, java.sql.Types.INTEGER);
            ps.setString(6, d.getBio());
            ps.setString(7, d.getAvatarUrl());
            ps.setInt(8, d.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] updateProfile ERROR: " + e.getMessage());
        }
        return false;
    }

    /**
     * Ánh xạ ResultSet → Doctor (Bác sĩ / manager)
     */
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        d.setFullName(rs.getString("full_name"));
        d.setSpecialization(rs.getString("specialization"));
        d.setPhoneNumber(rs.getString("phone_number"));
        // Đọc các cột mới (nếu không tồn tại thì bỏ qua)
        try { d.setDegree(rs.getString("degree")); }         catch (SQLException ignored) {}
        try { d.setExperienceYears(rs.getInt("experience_years")); } catch (SQLException ignored) {}
        try { d.setBio(rs.getString("bio")); }               catch (SQLException ignored) {}
        try { d.setAvatarUrl(rs.getString("avatar_url")); }  catch (SQLException ignored) {}
        try { d.setEmail(rs.getString("email")); }           catch (SQLException ignored) {}
        return d;
    }

    /**
     * Ánh xạ ResultSet → Doctor (receptionist)
     */
    private Doctor mapRowToDoctor(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String fullName = rs.getString("full_name");
        String specialization = rs.getString("specialization");

        String degree = rs.getString("degree");
        if (degree == null || degree.isBlank()) degree = "Bác sĩ";

        int experienceYears = rs.getInt("experience_years"); // 0 nếu NULL hoặc chưa cập nhật
        String avatar = rs.getString("avatar_url"); // null nếu bác sĩ chưa upload ảnh — JSP tự hiện chữ cái đầu thay thế

        // Lưu ý: bảng doctors không có cột giá khám — giá thuộc về dịch vụ (services.price),
        // 1 bác sĩ có thể thực hiện nhiều dịch vụ với giá khác nhau. Để 0 thay vì bịa số liệu giả.
        double price = 0;

        return new Doctor(id, fullName, specialization, degree, experienceYears, price, avatar);
    }

    /**
     * Thêm mới bác sĩ.
     */
    public int insert(Doctor d) {
        String sql = "INSERT INTO doctors (user_id, full_name, phone_number, specialization) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getUserId());
            ps.setString(2, d.getFullName());
            ps.setString(3, d.getPhoneNumber());
            ps.setString(4, d.getSpecialization());
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] insert ERROR: " + e.getMessage());
        }
        return -1;
    }
}