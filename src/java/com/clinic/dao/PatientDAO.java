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

    private static final String SELECT_COLS = "id, full_name, phone_number, date_of_birth, address, cccd";

    private Patient mapRow(ResultSet rs) throws java.sql.SQLException {
        java.sql.Date dobSql = rs.getDate("date_of_birth");
        LocalDate dob = dobSql != null ? dobSql.toLocalDate() : null;
        Patient p = new Patient(rs.getInt("id"), rs.getString("full_name"),
                rs.getString("phone_number"), dob);
        try { p.setAddress(rs.getString("address")); } catch (Exception ignored) {}
        try { p.setCccd(rs.getString("cccd")); } catch (Exception ignored) {}
        return p;
    }

    public List<Patient> getAllPatients() {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT " + SELECT_COLS + " FROM patients";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Patient findPatientByPhone(String phone) {
        if (phone == null) return null;
        String sql = "SELECT " + SELECT_COLS + " FROM patients WHERE phone_number = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public Patient createPatient(String fullName, String phone, LocalDate dob) {
        String sql = "INSERT INTO patients (full_name, phone_number, date_of_birth) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, java.sql.Types.DATE);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return new Patient(rs.getInt(1), fullName, phone, dob);
            }
        } catch (Exception e) {
            System.err.println("[PatientDAO] createPatient FAILED: " + e.getMessage());
        }
        return null;
    }

    public Patient findById(int id) {
        String sql = "SELECT " + SELECT_COLS + " FROM patients WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public int getPatientIdByUserId(int userId) {
        String sql = "SELECT id FROM patients WHERE user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public Patient createPatientWithUserId(String fullName, String phone, LocalDate dob, int userId) {
        String sql = "INSERT INTO patients (full_name, phone_number, date_of_birth, user_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, java.sql.Types.DATE);
            ps.setInt(4, userId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return new Patient(rs.getInt(1), fullName, phone, dob);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean updatePatient(int id, String fullName, String phone, LocalDate dob) {
        return updatePatient(id, fullName, phone, dob, null);
    }

    public boolean updatePatient(int id, String fullName, String phone, LocalDate dob, String address) {
        // Thử UPDATE có cột address — nếu lỗi (cột chưa tồn tại) thì fallback không address
        try { return updatePatientInternal(id, fullName, phone, dob, address, true); }
        catch (Exception e) {
            System.err.println("[PatientDAO] updatePatient with address failed, falling back: " + e.getMessage());
            try { return updatePatientInternal(id, fullName, phone, dob, null, false); }
            catch (Exception e2) { e2.printStackTrace(); return false; }
        }
    }

    private boolean updatePatientInternal(int id, String fullName, String phone, LocalDate dob, String address, boolean includeExtras) throws java.sql.SQLException {
        String sql = "UPDATE patients SET full_name = ?, phone_number = ?, date_of_birth = ?" +
                (includeExtras ? ", address = ?, cccd = ?" : "") + " WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, java.sql.Types.DATE);
            if (includeExtras) {
                ps.setString(4, address);
                ps.setString(5, null); // cccd handled separately
                ps.setInt(6, id);
            } else {
                ps.setInt(4, id);
            }
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePatient(int id, String fullName, String phone, LocalDate dob, String address, String cccd) {
        String sql = "UPDATE patients SET full_name = ?, phone_number = ?, date_of_birth = ?, address = ?, cccd = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (dob != null) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, java.sql.Types.DATE);
            ps.setString(4, address);
            ps.setString(5, cccd);
            ps.setInt(6, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
}
