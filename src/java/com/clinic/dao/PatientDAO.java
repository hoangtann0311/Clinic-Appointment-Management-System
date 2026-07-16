package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Patient;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {

    public List<Patient> getAllPatients() {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT id, full_name, phone_number, date_of_birth, zalo_user_id FROM patients";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.sql.Date dobSql = rs.getDate("date_of_birth");
                LocalDate dob = dobSql != null ? dobSql.toLocalDate() : null;
                list.add(new Patient(
                        rs.getInt("id"),
                        rs.getString("full_name"),
                        rs.getString("phone_number"),
                        dob,
                        rs.getString("zalo_user_id")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Patient findPatientByPhone(String phone) {
        if (phone == null) return null;
        String sql = "SELECT id, full_name, phone_number, date_of_birth, zalo_user_id FROM patients WHERE phone_number = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date dobSql = rs.getDate("date_of_birth");
                    LocalDate dob = dobSql != null ? dobSql.toLocalDate() : null;
                    return new Patient(
                            rs.getInt("id"),
                            rs.getString("full_name"),
                            rs.getString("phone_number"),
                            dob,
                            rs.getString("zalo_user_id")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Patient createPatient(String fullName, String phone, LocalDate dob, String zaloUserId) {
        String sql = "INSERT INTO patients (full_name, phone_number, date_of_birth, zalo_user_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) {
                ps.setDate(3, java.sql.Date.valueOf(dob));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, zaloUserId);
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    return new Patient(id, fullName, phone, dob, zaloUserId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy hồ sơ bệnh nhân theo patients.id.
     */
    public Patient findById(int id) {
        String sql = "SELECT id, full_name, phone_number, date_of_birth, zalo_user_id FROM patients WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date dobSql = rs.getDate("date_of_birth");
                    LocalDate dob = dobSql != null ? dobSql.toLocalDate() : null;
                    return new Patient(
                            rs.getInt("id"),
                            rs.getString("full_name"),
                            rs.getString("phone_number"),
                            dob,
                            rs.getString("zalo_user_id")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tra patients.id từ users.id (tài khoản đăng nhập của bệnh nhân).
     * Dùng để tránh nhầm lẫn users.id với patients.id khi lọc dữ liệu
     * (appointments.patient_id, pregnancies.patient_id... đều tham chiếu patients.id).
     *
     * @return patients.id, hoặc 0 nếu user này chưa có hồ sơ bệnh nhân liên kết.
     */
    public int getPatientIdByUserId(int userId) {
        String sql = "SELECT id FROM patients WHERE user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Patient createPatientWithUserId(String fullName, String phone, LocalDate dob, String zaloUserId, int userId) {
        String sql = "INSERT INTO patients (full_name, phone_number, date_of_birth, zalo_user_id, user_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) {
                ps.setDate(3, java.sql.Date.valueOf(dob));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, zaloUserId);
            ps.setInt(5, userId);
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    return new Patient(id, fullName, phone, dob, zaloUserId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePatient(int id, String fullName, String phone, LocalDate dob, String zaloUserId) {
        String sql = "UPDATE patients SET full_name = ?, phone_number = ?, date_of_birth = ?, zalo_user_id = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) {
                ps.setDate(3, java.sql.Date.valueOf(dob));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, zaloUserId);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
