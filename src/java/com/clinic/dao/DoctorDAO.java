package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng doctors — tra cứu thông tin bác sĩ.
 */
public class DoctorDAO {

    /**
     * Lấy tất cả bác sĩ, sắp xếp theo tên.
     */
    public List<Doctor> findAll() {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d ORDER BY d.full_name";

        List<Doctor> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tìm bác sĩ theo id.
     */
    public Doctor findById(int id) {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d WHERE d.id = ?";

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
            System.err.println("[DoctorDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm bác sĩ theo user_id (liên kết với bảng users).
     */
    public Doctor findByUserId(int userId) {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d WHERE d.user_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findByUserId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Thêm bác sĩ mới vào bảng doctors.
     * Được gọi tự động khi tạo user có role_id = 2 (Bác Sĩ).
     *
     * @param doctor đối tượng Doctor cần thêm (không có id)
     * @return id của bác sĩ vừa tạo, -1 nếu thất bại
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

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
