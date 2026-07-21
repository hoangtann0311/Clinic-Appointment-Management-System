package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.MedicalRecord;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng medical_records — hồ sơ bệnh án Sản khoa.
 * Hỗ trợ đầy đủ CRUD với tất cả 30+ cột chuyên khoa.
 *
 * <p>Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class MedicalRecordDAO {

    // ──────────────────────────────────────────────
    // Column list dùng chung cho tất cả SELECT
    // ──────────────────────────────────────────────
    private static final String SELECT_COLUMNS =
        "id, appointment_id, "
        + "weight_kg, blood_pressure, pulse_bpm, temperature_c, height_cm, "
        + "gestational_age_weeks, gestational_age_days, "
        + "fundal_height_cm, fetal_heart_rate, fetal_presentation, fetal_position, fetal_movement, "
        + "cervical_dilation_cm, cervical_effacement, amniotic_fluid, presentation_station, "
        + "edema, proteinuria, vaginal_bleeding, uterine_contractions, "
        + "clinical_notes, final_diagnosis, risk_flags_json, treatment_plan, "
        + "next_appointment_date, referred_to, "
        + "status, created_at, updated_at, updated_by";

    // ──────────────────────────────────────────────
    // FIND BY ID
    // ──────────────────────────────────────────────
    public MedicalRecord findById(int id) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM medical_records WHERE id = ?";

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

    // ──────────────────────────────────────────────
    // FIND BY APPOINTMENT ID
    // ──────────────────────────────────────────────
    public MedicalRecord findByAppointmentId(int appointmentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM medical_records WHERE appointment_id = ?";

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

    // ──────────────────────────────────────────────
    // FIND BY PATIENT ID
    // ──────────────────────────────────────────────
    public List<MedicalRecord> findByPatientId(int patientId) {
        String sql = "SELECT mr." + SELECT_COLUMNS.replace(", ", ", mr.")
                   + " FROM medical_records mr "
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

    // ──────────────────────────────────────────────
    // INSERT — tạo mới medical record
    // ──────────────────────────────────────────────
    public int insert(MedicalRecord record) {
        String sql = "INSERT INTO medical_records ("
                   + "appointment_id, "
                   + "weight_kg, blood_pressure, pulse_bpm, temperature_c, height_cm, "
                   + "gestational_age_weeks, gestational_age_days, "
                   + "fundal_height_cm, fetal_heart_rate, fetal_presentation, fetal_position, fetal_movement, "
                   + "cervical_dilation_cm, cervical_effacement, amniotic_fluid, presentation_station, "
                   + "edema, proteinuria, vaginal_bleeding, uterine_contractions, "
                   + "clinical_notes, final_diagnosis, risk_flags_json, treatment_plan, "
                   + "next_appointment_date, referred_to, "
                   + "status, created_at"
                   + ") OUTPUT INSERTED.id VALUES ("
                   + "?, "  // appointment_id
                   + "?, ?, ?, ?, ?, "  // vital signs (5)
                   + "?, ?, "          // gestational age (2)
                   + "?, ?, ?, ?, ?, " // fetal (5)
                   + "?, ?, ?, ?, "    // cervix & fluid (4)
                   + "?, ?, ?, ?, "    // symptoms (4)
                   + "?, ?, ?, ?, "    // diagnosis & treatment (4)
                   + "?, ?, "          // next_appointment_date, referred_to (2)
                   + "?, GETDATE()"    // status
                   + ")";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);

            int idx = 1;
            // appointment_id
            setNullableInt(ps, idx++, record.getAppointmentId());
            // vital signs
            setNullableBigDecimal(ps, idx++, record.getWeightKg());
            ps.setNString(idx++, record.getBloodPressure());
            setNullableInt(ps, idx++, record.getPulseBpm());
            setNullableBigDecimal(ps, idx++, record.getTemperatureC());
            setNullableBigDecimal(ps, idx++, record.getHeightCm());
            // gestational age
            setNullableInt(ps, idx++, record.getGestationalAgeWeeks());
            setNullableInt(ps, idx++, record.getGestationalAgeDays());
            // fetal
            setNullableBigDecimal(ps, idx++, record.getFundalHeightCm());
            setNullableInt(ps, idx++, record.getFetalHeartRate());
            ps.setNString(idx++, record.getFetalPresentation());
            ps.setNString(idx++, record.getFetalPosition());
            ps.setNString(idx++, record.getFetalMovement());
            // cervix & fluid
            setNullableBigDecimal(ps, idx++, record.getCervicalDilationCm());
            ps.setNString(idx++, record.getCervicalEffacement());
            ps.setNString(idx++, record.getAmnioticFluid());
            ps.setNString(idx++, record.getPresentationStation());
            // symptoms
            ps.setNString(idx++, record.getEdema());
            ps.setNString(idx++, record.getProteinuria());
            setNullableBoolean(ps, idx++, record.getVaginalBleeding());
            setNullableBoolean(ps, idx++, record.getUterineContractions());
            // diagnosis & treatment
            ps.setNString(idx++, record.getClinicalNotes());
            ps.setNString(idx++, record.getFinalDiagnosis());
            ps.setNString(idx++, record.getRiskFlagsJson());
            ps.setNString(idx++, record.getTreatmentPlan());
            // next_appointment_date, referred_to
            setNullableDate(ps, idx++, record.getNextAppointmentDate());
            ps.setNString(idx++, record.getReferredTo());
            // status
            ps.setString(idx++, record.getStatus() != null ? record.getStatus() : "final");

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

    // ──────────────────────────────────────────────
    // UPDATE — cập nhật toàn bộ medical record
    // ──────────────────────────────────────────────
    public boolean update(MedicalRecord record) {
        String sql = "UPDATE medical_records SET "
                   + "weight_kg = ?, blood_pressure = ?, pulse_bpm = ?, temperature_c = ?, height_cm = ?, "
                   + "gestational_age_weeks = ?, gestational_age_days = ?, "
                   + "fundal_height_cm = ?, fetal_heart_rate = ?, fetal_presentation = ?, "
                   + "fetal_position = ?, fetal_movement = ?, "
                   + "cervical_dilation_cm = ?, cervical_effacement = ?, amniotic_fluid = ?, "
                   + "presentation_station = ?, "
                   + "edema = ?, proteinuria = ?, vaginal_bleeding = ?, uterine_contractions = ?, "
                   + "clinical_notes = ?, final_diagnosis = ?, risk_flags_json = ?, treatment_plan = ?, "
                   + "next_appointment_date = ?, referred_to = ?, "
                   + "status = ?, "
                   + "updated_at = GETDATE(), updated_by = ? "
                   + "WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);

            int idx = 1;
            // vital signs (5)
            setNullableBigDecimal(ps, idx++, record.getWeightKg());
            ps.setNString(idx++, record.getBloodPressure());
            setNullableInt(ps, idx++, record.getPulseBpm());
            setNullableBigDecimal(ps, idx++, record.getTemperatureC());
            setNullableBigDecimal(ps, idx++, record.getHeightCm());
            // gestational age (2)
            setNullableInt(ps, idx++, record.getGestationalAgeWeeks());
            setNullableInt(ps, idx++, record.getGestationalAgeDays());
            // fetal (5)
            setNullableBigDecimal(ps, idx++, record.getFundalHeightCm());
            setNullableInt(ps, idx++, record.getFetalHeartRate());
            ps.setNString(idx++, record.getFetalPresentation());
            ps.setNString(idx++, record.getFetalPosition());
            ps.setNString(idx++, record.getFetalMovement());
            // cervix & fluid (4)
            setNullableBigDecimal(ps, idx++, record.getCervicalDilationCm());
            ps.setNString(idx++, record.getCervicalEffacement());
            ps.setNString(idx++, record.getAmnioticFluid());
            ps.setNString(idx++, record.getPresentationStation());
            // symptoms (4)
            ps.setNString(idx++, record.getEdema());
            ps.setNString(idx++, record.getProteinuria());
            setNullableBoolean(ps, idx++, record.getVaginalBleeding());
            setNullableBoolean(ps, idx++, record.getUterineContractions());
            // diagnosis & treatment (4)
            ps.setNString(idx++, record.getClinicalNotes());
            ps.setNString(idx++, record.getFinalDiagnosis());
            ps.setNString(idx++, record.getRiskFlagsJson());
            ps.setNString(idx++, record.getTreatmentPlan());
            // next_appointment_date, referred_to (2)
            setNullableDate(ps, idx++, record.getNextAppointmentDate());
            ps.setNString(idx++, record.getReferredTo());
            // status
            ps.setString(idx++, record.getStatus() != null ? record.getStatus() : "final");
            // updated_by
            setNullableInt(ps, idx++, record.getUpdatedBy());
            // WHERE id
            ps.setInt(idx++, record.getId());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] update ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, null);
        }
        return false;
    }

    // ──────────────────────────────────────────────
    // EXISTS CHECK
    // ──────────────────────────────────────────────
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

    // ──────────────────────────────────────────────
    // FIND PATIENT NAME (qua appointment → patients)
    // ──────────────────────────────────────────────
    public String findPatientNameByRecordId(int recordId) {
        String sql = "SELECT ISNULL(p.full_name, N'Không rõ') AS patient_name "
                   + "FROM medical_records mr "
                   + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
                   + "LEFT JOIN patients p ON a.patient_id = p.id "
                   + "WHERE mr.id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, recordId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("patient_name");
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] findPatientNameByRecordId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Lấy appointment_id từ medical record.
     */
    public Integer findAppointmentIdByRecordId(int recordId) {
        String sql = "SELECT appointment_id FROM medical_records WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, recordId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int val = rs.getInt("appointment_id");
                return rs.wasNull() ? null : val;
            }
        } catch (SQLException e) {
            System.err.println("[MedicalRecordDAO] findAppointmentIdByRecordId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    // ──────────────────────────────────────────────
    // PRIVATE HELPERS
    // ──────────────────────────────────────────────

    /**
     * Ánh xạ ResultSet → MedicalRecord (đầy đủ tất cả cột).
     */
    private MedicalRecord mapRow(ResultSet rs) throws SQLException {
        MedicalRecord mr = new MedicalRecord();

        mr.setId(rs.getInt("id"));
        int apptId = rs.getInt("appointment_id");
        mr.setAppointmentId(rs.wasNull() ? null : apptId);

        // Vital signs — dùng getBigDecimal/getInt với try-catch để an toàn
        mr.setWeightKg(getNullableBigDecimal(rs, "weight_kg"));
        mr.setBloodPressure(rs.getString("blood_pressure"));
        mr.setPulseBpm(getNullableInt(rs, "pulse_bpm"));
        mr.setTemperatureC(getNullableBigDecimal(rs, "temperature_c"));
        mr.setHeightCm(getNullableBigDecimal(rs, "height_cm"));

        // Gestational age
        mr.setGestationalAgeWeeks(getNullableInt(rs, "gestational_age_weeks"));
        mr.setGestationalAgeDays(getNullableInt(rs, "gestational_age_days"));

        // Fetal
        mr.setFundalHeightCm(getNullableBigDecimal(rs, "fundal_height_cm"));
        mr.setFetalHeartRate(getNullableInt(rs, "fetal_heart_rate"));
        mr.setFetalPresentation(rs.getString("fetal_presentation"));
        mr.setFetalPosition(rs.getString("fetal_position"));
        mr.setFetalMovement(rs.getString("fetal_movement"));

        // Cervix & fluid
        mr.setCervicalDilationCm(getNullableBigDecimal(rs, "cervical_dilation_cm"));
        mr.setCervicalEffacement(rs.getString("cervical_effacement"));
        mr.setAmnioticFluid(rs.getString("amniotic_fluid"));
        mr.setPresentationStation(rs.getString("presentation_station"));

        // Symptoms
        mr.setEdema(rs.getString("edema"));
        mr.setProteinuria(rs.getString("proteinuria"));
        mr.setVaginalBleeding(getNullableBoolean(rs, "vaginal_bleeding"));
        mr.setUterineContractions(getNullableBoolean(rs, "uterine_contractions"));

        // Diagnosis & treatment
        mr.setClinicalNotes(rs.getString("clinical_notes"));
        mr.setFinalDiagnosis(rs.getString("final_diagnosis"));
        mr.setRiskFlagsJson(rs.getString("risk_flags_json"));
        mr.setTreatmentPlan(rs.getString("treatment_plan"));

        // Next appointment & referred
        try { mr.setNextAppointmentDate(rs.getDate("next_appointment_date")); } catch (SQLException e) { /* cột có thể không tồn tại */ }
        try { mr.setReferredTo(rs.getString("referred_to")); } catch (SQLException e) { /* bỏ qua */ }

        // Status
        try { mr.setStatus(rs.getString("status")); } catch (SQLException e) { mr.setStatus("final"); }

        // Meta
        try { mr.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { /* bỏ qua */ }
        try { mr.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { /* bỏ qua */ }
        try {
            int updatedBy = rs.getInt("updated_by");
            mr.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        } catch (SQLException e) { /* bỏ qua */ }

        return mr;
    }

    // ── Null-safe helpers cho ResultSet ──

    private BigDecimal getNullableBigDecimal(ResultSet rs, String column) {
        try {
            BigDecimal val = rs.getBigDecimal(column);
            return rs.wasNull() ? null : val;
        } catch (SQLException e) {
            return null;
        }
    }

    private Integer getNullableInt(ResultSet rs, String column) {
        try {
            int val = rs.getInt(column);
            return rs.wasNull() ? null : val;
        } catch (SQLException e) {
            return null;
        }
    }

    private Boolean getNullableBoolean(ResultSet rs, String column) {
        try {
            boolean val = rs.getBoolean(column);
            return rs.wasNull() ? null : val;
        } catch (SQLException e) {
            return null;
        }
    }

    // ── Null-safe helpers cho PreparedStatement ──

    private void setNullableInt(PreparedStatement ps, int idx, Integer value) throws SQLException {
        if (value != null) {
            ps.setInt(idx, value);
        } else {
            ps.setNull(idx, Types.INTEGER);
        }
    }

    private void setNullableBigDecimal(PreparedStatement ps, int idx, BigDecimal value) throws SQLException {
        if (value != null) {
            ps.setBigDecimal(idx, value);
        } else {
            ps.setNull(idx, Types.DECIMAL);
        }
    }

    private void setNullableBoolean(PreparedStatement ps, int idx, Boolean value) throws SQLException {
        if (value != null) {
            ps.setBoolean(idx, value);
        } else {
            ps.setNull(idx, Types.BIT);
        }
    }

    private void setNullableDate(PreparedStatement ps, int idx, Date value) throws SQLException {
        if (value != null) {
            ps.setDate(idx, value);
        } else {
            ps.setNull(idx, Types.DATE);
        }
    }

    // ── Resource cleanup ──

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { /* ignore */ } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { /* ignore */ } }
        DatabaseConfig.closeConnection(conn);
    }
}
