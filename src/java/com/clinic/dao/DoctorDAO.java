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
     * Ánh xạ ResultSet → Doctor.
     */
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
