package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.MedicalRecord;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng medical_records — hồ sơ bệnh án.
 * Hỗ trợ CRUD: findById, findByAppointmentId, insert, update.
 *
 * <p>Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class MedicalRecordDAO {

    /**
     * Tìm medical record theo ID.
     */
    public MedicalRecord findById(int id) {
        String sql = "SELECT id, appointment_id, clinical_notes, final_diagnosis, "
                   + "created_at, updated_at, updated_by "
                   + "FROM medical_records WHERE id = ?";

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
            System.err.println("[MedicalRecordDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm medical record theo appointment ID.
     * Mỗi appointment chỉ có tối đa 1 medical record.
     */
    public MedicalRecord findByAppointmentId(int appointmentId) {
        String sql = "SELECT id, appointment_id, clinical_notes, final_diagnosis, "
                   + "created_at, updated_at, updated_by "
                   + "FROM medical_records WHERE appointment_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] findByAppointmentId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Lấy danh sách medical record của bệnh nhân (qua patient_id → appointments).
     */
    public List<MedicalRecord> findByPatientId(int patientId) {
        String sql = "SELECT mr.id, mr.appointment_id, mr.clinical_notes, mr.final_diagnosis, "
                   + "mr.created_at, mr.updated_at, mr.updated_by "
                   + "FROM medical_records mr "
                   + "INNER JOIN appointments a ON mr.appointment_id = a.id "
                   + "WHERE a.patient_id = ? "
                   + "ORDER BY mr.created_at DESC";

        List<MedicalRecord> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] findByPatientId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tạo mới medical record.
     * @return ID của bản ghi vừa tạo (dùng SCOPE_IDENTITY()).
     */
    public int insert(MedicalRecord record) {
        String sql = "INSERT INTO medical_records (appointment_id, clinical_notes, final_diagnosis, created_at) "
                   + "OUTPUT INSERTED.id "
                   + "VALUES (?, ?, ?, GETDATE())";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            if (record.getAppointmentId() != null) {
                ps.setInt(1, record.getAppointmentId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setNString(2, record.getClinicalNotes());
            ps.setNString(3, record.getFinalDiagnosis());
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] insert ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }

    /**
     * Cập nhật medical record (chỉ clinical_notes + final_diagnosis).
     * Tự động cập nhật updated_at = GETDATE().
     * @return true nếu update thành công.
     */
    public boolean update(MedicalRecord record) {
        String sql = "UPDATE medical_records SET "
                   + "clinical_notes = ?, final_diagnosis = ?, "
                   + "updated_at = GETDATE(), updated_by = ? "
                   + "WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setNString(1, record.getClinicalNotes());
            ps.setNString(2, record.getFinalDiagnosis());
            if (record.getUpdatedBy() != null) {
                ps.setInt(3, record.getUpdatedBy());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, record.getId());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] update ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, null);
        }
        return false;
    }

    /**
     * Kiểm tra appointment đã có medical record chưa.
     */
    public boolean existsByAppointmentId(int appointmentId) {
        String sql = "SELECT COUNT(*) AS total FROM medical_records WHERE appointment_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] existsByAppointmentId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    // ── Private helpers ──

    private MedicalRecord mapRow(ResultSet rs) throws SQLException {
        MedicalRecord mr = new MedicalRecord();
        mr.setId(rs.getInt("id"));
        int apptId = rs.getInt("appointment_id");
        mr.setAppointmentId(rs.wasNull() ? null : apptId);
        mr.setClinicalNotes(rs.getString("clinical_notes"));
        mr.setFinalDiagnosis(rs.getString("final_diagnosis"));
        try { mr.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { /* cột có thể không tồn tại */ }
        try { mr.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { /* bỏ qua */ }
        try {
            int updatedBy = rs.getInt("updated_by");
            mr.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        } catch (SQLException e) { /* bỏ qua */ }
        return mr;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { /* ignore */ } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { /* ignore */ } }
        DatabaseConfig.closeConnection(conn);
    }
}
