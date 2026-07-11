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
        String sql = "SELECT id, full_name, specialization, phone_number FROM doctors";
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
        String sql = "SELECT id, full_name, specialization, phone_number FROM doctors WHERE id = ?";
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
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d WHERE d.user_id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
<<<<<<< HEAD
     * Ánh xạ ResultSet → Doctor (Bác sĩ / manager)
=======
     * Thêm bác sĩ mới vào bảng doctors.
     * Được gọi tự động khi tạo user có role_id = 2 (Bác Sĩ).
     *
     * @param doctor đối tượng Doctor cần thêm (không có id)
     * @return id của bác sĩ vừa tạo, -1 nếu thất bại
>>>>>>> origin/hieupt
     */
    public int insert(Doctor doctor) {
        String sql = "INSERT INTO doctors (user_id, full_name, specialization, phone_number) "
                   + "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, doctor.getUserId());
            ps.setString(2, doctor.getFullName());
            ps.setString(3, doctor.getSpecialization());
            ps.setString(4, doctor.getPhoneNumber());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new RuntimeException("Thêm bác sĩ thất bại - không có dòng nào được tạo");
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int generatedId = rs.getInt(1);
                System.out.println("[DoctorDAO] insert SUCCESS: id=" + generatedId
                        + ", userId=" + doctor.getUserId() + ", fullName=" + doctor.getFullName());
                return generatedId;
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] insert ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return -1;
        } finally {
            closeResources(conn, ps, rs);
        }
    }
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        d.setFullName(rs.getString("full_name"));
        d.setSpecialization(rs.getString("specialization"));
        d.setPhoneNumber(rs.getString("phone_number"));
        return d;
    }

    /**
     * Ánh xạ ResultSet → Doctor (receptionist)
     */
    private Doctor mapRowToDoctor(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String fullName = rs.getString("full_name");
        String specialization = rs.getString("specialization");
        
        String degree = "Bác sĩ Sản phụ khoa";
        int experienceYears = 5;
        double price = 150000;
        String avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";

        if (fullName != null) {
            if (fullName.contains("Phạm Trung Hiếu")) {
                degree = "Bác sĩ Trưởng khoa (CKII)";
                experienceYears = 12;
                price = 200000;
                avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";
            } else if (fullName.contains("Nguyễn Thị Mai")) {
                degree = "Thạc sĩ, Bác sĩ Nội trú";
                experienceYears = 15;
                price = 300000;
                avatar = "https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=150&auto=format&fit=crop";
            } else if (fullName.contains("Trần Văn Khoa")) {
                degree = "Bác sĩ Chuyên khoa I";
                experienceYears = 8;
                price = 150000;
                avatar = "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=150&auto=format&fit=crop";
            }
        }

        return new Doctor(id, fullName, specialization, degree, experienceYears, price, avatar);
    }
}
