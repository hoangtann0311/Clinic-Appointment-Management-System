package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.MedicalRecord;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng medical_records — chuyên khoa Phụ Sản.
 * Vị trí: src/java/DAO/MedicalRecordDAO.java
 */
public class MedicalRecordDAO {

    // ────────────────────────────────────────────────────────────────────────
    // SELECT
    // ────────────────────────────────────────────────────────────────────────

    private static final String BASE_SELECT =
        "SELECT mr.id, mr.appointment_id, mr.clinical_notes, mr.final_diagnosis, mr.created_at, mr.status, " +
        "  mr.weight_kg, mr.blood_pressure, mr.pulse_bpm, mr.temperature_c, mr.height_cm, " +
        "  mr.gestational_age_weeks, mr.gestational_age_days, mr.fundal_height_cm, " +
        "  mr.fetal_heart_rate, mr.fetal_presentation, mr.fetal_position, mr.fetal_movement, " +
        "  mr.cervical_dilation_cm, mr.cervical_effacement, mr.amniotic_fluid, mr.presentation_station, " +
        "  mr.edema, mr.proteinuria, mr.vaginal_bleeding, mr.uterine_contractions, mr.risk_flags_json, " +
        "  mr.treatment_plan, mr.next_appointment_date, mr.referred_to, " +
        "  pt.full_name AS patient_name, " +
        "  pt.phone_number AS patient_phone, " +
        "  CONVERT(varchar, pt.date_of_birth, 23)            AS patient_dob, " +
        "  a.patient_id AS patient_id, " +
        "  CONVERT(varchar, a.appointment_date, 23)          AS appointment_date, " +
        "  CONVERT(varchar, a.time_slot, 108)                AS time_slot, " +
        "  a.symptoms, " +
        "  CONVERT(varchar, a.last_menstrual_period, 23)     AS last_menstrual_period, " +
        "  a.pregnancy_id " +
        "FROM medical_records mr " +
        "JOIN appointments a ON mr.appointment_id = a.id " +
        "JOIN patients pt    ON a.patient_id = pt.id ";

    public MedicalRecord getByAppointmentId(int appointmentId) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(BASE_SELECT + "WHERE mr.appointment_id = ?")) {
            ps.setInt(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public MedicalRecord getById(int recordId) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(BASE_SELECT + "WHERE mr.id = ?")) {
            ps.setInt(1, recordId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Lấy chi tiết hồ sơ bệnh án theo ID và Patient ID (Chống IDOR trực tiếp từ SQL query).
     */
    public MedicalRecord getByIdAndPatientId(int recordId, int patientId) {
        if (recordId <= 0 || patientId <= 0) return null;
        String sql = BASE_SELECT + "WHERE mr.id = ? AND a.patient_id = ? "
                + "AND (mr.status IS NULL OR LOWER(LTRIM(RTRIM(mr.status))) = 'final') "
                + "AND UPPER(LTRIM(RTRIM(ISNULL(a.status, '')))) IN ('SUCCESS', 'COMPLETED')";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setInt(2, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<MedicalRecord> getByDoctorId(int doctorId, String keyword) {
        boolean hasKw = keyword != null && !keyword.isBlank();
        String sql = BASE_SELECT + "WHERE a.doctor_id = ? " +
            (hasKw ? "AND (pt.full_name LIKE ? OR mr.final_diagnosis LIKE ?) " : "") +
            "ORDER BY mr.created_at DESC";

        List<MedicalRecord> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            if (hasKw) { String lk = "%" + keyword.trim() + "%"; ps.setString(2, lk); ps.setString(3, lk); }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<MedicalRecord> getByDoctorId(int doctorId) { return getByDoctorId(doctorId, null); }

    public List<MedicalRecord> getByPatientId(int patientId) {
        String sql = BASE_SELECT + "WHERE a.patient_id = ? ORDER BY mr.created_at DESC";
        List<MedicalRecord> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<MedicalRecord> getReleasedByPatientId(int patientId) {
        String sql = BASE_SELECT + "WHERE a.patient_id = ? "
                + "AND LOWER(LTRIM(RTRIM(ISNULL(mr.status, '')))) = 'final' "
                + "AND UPPER(LTRIM(RTRIM(ISNULL(a.status, '')))) IN ('SUCCESS', 'COMPLETED') "
                + "ORDER BY mr.created_at DESC";
        List<MedicalRecord> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<MedicalRecord> getClinicalHistoryForDoctor(int patientId, int doctorId) {
        String sql = BASE_SELECT + "WHERE a.patient_id = ? AND (a.doctor_id = ? OR ("
                + "LOWER(LTRIM(RTRIM(ISNULL(mr.status, '')))) = 'final' "
                + "AND UPPER(LTRIM(RTRIM(ISNULL(a.status, '')))) IN ('SUCCESS', 'COMPLETED'))) "
                + "ORDER BY mr.created_at DESC";
        List<MedicalRecord> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setInt(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean appointmentBelongsToDoctor(int apptId, int doctorId) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM appointments WHERE id = ? AND doctor_id = ?")) {
            ps.setInt(1, apptId); ps.setInt(2, doctorId);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean recordBelongsToDoctor(int recordId, int doctorId) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM medical_records mr JOIN appointments a ON mr.appointment_id = a.id " +
                "WHERE mr.id = ? AND a.doctor_id = ?")) {
            ps.setInt(1, recordId); ps.setInt(2, doctorId);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean hasBlockingUltrasoundOrdersForAppointment(int appointmentId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return hasBlockingUltrasoundOrdersForAppointment(conn, appointmentId);
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    public boolean hasBlockingUltrasoundOrdersForAppointment(Connection conn, int appointmentId)
            throws SQLException {
        String sql = "SELECT 1 FROM test_orders o WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN medical_records mr ON mr.id = o.medical_record_id "
                + "WHERE mr.appointment_id = ? "
                + "AND LOWER(LTRIM(RTRIM(ISNULL(o.status, '')))) NOT IN ('confirmed', 'cancelled')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // INSERT
    // ────────────────────────────────────────────────────────────────────────

    public int create(MedicalRecord mr) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return create(conn, mr);
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    public int create(Connection conn, MedicalRecord mr) throws SQLException {
        String sql =
            "INSERT INTO medical_records (" +
            "  appointment_id, clinical_notes, final_diagnosis, created_at, " +
            "  weight_kg, blood_pressure, pulse_bpm, temperature_c, height_cm, " +
            "  gestational_age_weeks, gestational_age_days, fundal_height_cm, " +
            "  fetal_heart_rate, fetal_presentation, fetal_position, fetal_movement, " +
            "  cervical_dilation_cm, cervical_effacement, amniotic_fluid, presentation_station, " +
            "  edema, proteinuria, vaginal_bleeding, uterine_contractions, risk_flags_json, " +
            "  treatment_plan, next_appointment_date, referred_to, status" +
            ") VALUES (?,?,?,?,  ?,?,?,?,?,  ?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?,?,  ?,?,?,?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindParams(ps, mr, true, true);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    // ────────────────────────────────────────────────────────────────────────
    // UPDATE
    // ────────────────────────────────────────────────────────────────────────

    public boolean update(MedicalRecord mr) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return update(conn, mr);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Connection conn, MedicalRecord mr) throws SQLException {
        String sql =
            "UPDATE medical_records SET " +
            "  clinical_notes=?, final_diagnosis=?, " +
            "  weight_kg=?, blood_pressure=?, pulse_bpm=?, temperature_c=?, height_cm=?, " +
            "  gestational_age_weeks=?, gestational_age_days=?, fundal_height_cm=?, " +
            "  fetal_heart_rate=?, fetal_presentation=?, fetal_position=?, fetal_movement=?, " +
            "  cervical_dilation_cm=?, cervical_effacement=?, amniotic_fluid=?, presentation_station=?, " +
            "  edema=?, proteinuria=?, vaginal_bleeding=?, uterine_contractions=?, risk_flags_json=?, " +
            "  treatment_plan=?, next_appointment_date=?, referred_to=?, status=? " +
            "WHERE id=? AND appointment_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            bindParams(ps, mr, false, true);
            ps.setInt(28, mr.getId());
            ps.setInt(29, mr.getAppointmentId());
            return ps.executeUpdate() > 0;
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    /**
     * Bind tất cả tham số.
     * @param includeApptId true khi INSERT (có cột appointment_id + created_at đầu tiên)
     */
    private void bindParams(PreparedStatement ps, MedicalRecord mr, boolean includeApptId, boolean includeStatus) throws SQLException {
        int i = 1;
        if (includeApptId) {
            ps.setInt(i++, mr.getAppointmentId());
        }
        ps.setString(i++, mr.getClinicalNotes());
        ps.setString(i++, mr.getFinalDiagnosis());
        if (includeApptId) {
            ps.setTimestamp(i++, Timestamp.valueOf(LocalDateTime.now()));
        }
        // Sinh hiệu mẹ
        setDoubleOrNull(ps, i++, mr.getWeightKg());
        ps.setString(i++, mr.getBloodPressure());
        setIntOrNull(ps, i++, mr.getPulseBpm());
        setDoubleOrNull(ps, i++, mr.getTemperatureC());
        setDoubleOrNull(ps, i++, mr.getHeightCm());
        // Thai kỳ
        setIntOrNull(ps, i++, mr.getGestationalAgeWeeks());
        setIntOrNull(ps, i++, mr.getGestationalAgeDays());
        setDoubleOrNull(ps, i++, mr.getFundalHeightCm());
        setIntOrNull(ps, i++, mr.getFetalHeartRate());
        ps.setString(i++, mr.getFetalPresentation());
        ps.setString(i++, mr.getFetalPosition());
        ps.setString(i++, mr.getFetalMovement());
        // Khám sản khoa
        setDoubleOrNull(ps, i++, mr.getCervicalDilationCm());
        ps.setString(i++, mr.getCervicalEffacement());
        ps.setString(i++, mr.getAmnioticFluid());
        ps.setString(i++, mr.getPresentationStation());
        // Dấu hiệu nguy hiểm
        ps.setString(i++, mr.getEdema());
        ps.setString(i++, mr.getProteinuria());
        setBoolOrNull(ps, i++, mr.getVaginalBleeding());
        setBoolOrNull(ps, i++, mr.getUterineContractions());
        ps.setString(i++, mr.getRiskFlagsJson());
        // Kế hoạch
        ps.setString(i++, mr.getTreatmentPlan());
        if (mr.getNextAppointmentDate() != null) {
            ps.setDate(i++, Date.valueOf(mr.getNextAppointmentDate()));
        } else { ps.setNull(i++, Types.DATE); }
        ps.setString(i++, mr.getReferredTo());
        if (includeStatus) {
            ps.setString(i++, mr.getStatus() != null ? mr.getStatus() : "final");
        }
    }

    private void setDoubleOrNull(PreparedStatement ps, int idx, Double val) throws SQLException {
        if (val != null) ps.setDouble(idx, val); else ps.setNull(idx, Types.DECIMAL);
    }
    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null) ps.setInt(idx, val); else ps.setNull(idx, Types.INTEGER);
    }
    private void setBoolOrNull(PreparedStatement ps, int idx, Boolean val) throws SQLException {
        if (val != null) ps.setBoolean(idx, val); else ps.setNull(idx, Types.BIT);
    }

    private MedicalRecord mapRow(ResultSet rs) throws SQLException {
        MedicalRecord mr = new MedicalRecord();
        mr.setId(rs.getInt("id"));
        mr.setAppointmentId(rs.getInt("appointment_id"));
        mr.setClinicalNotes(rs.getString("clinical_notes"));
        mr.setFinalDiagnosis(rs.getString("final_diagnosis"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) mr.setCreatedAt(ts.toLocalDateTime());

        // Sinh hiệu mẹ
        double w = rs.getDouble("weight_kg"); if (!rs.wasNull()) mr.setWeightKg(w);
        mr.setBloodPressure(rs.getString("blood_pressure"));
        int pulse = rs.getInt("pulse_bpm"); if (!rs.wasNull()) mr.setPulseBpm(pulse);
        double temp = rs.getDouble("temperature_c"); if (!rs.wasNull()) mr.setTemperatureC(temp);
        double h = rs.getDouble("height_cm"); if (!rs.wasNull()) mr.setHeightCm(h);

        // Thai kỳ
        int gaw = rs.getInt("gestational_age_weeks"); if (!rs.wasNull()) mr.setGestationalAgeWeeks(gaw);
        int gad = rs.getInt("gestational_age_days"); if (!rs.wasNull()) mr.setGestationalAgeDays(gad);
        double fh = rs.getDouble("fundal_height_cm"); if (!rs.wasNull()) mr.setFundalHeightCm(fh);
        int fhr = rs.getInt("fetal_heart_rate"); if (!rs.wasNull()) mr.setFetalHeartRate(fhr);
        mr.setFetalPresentation(rs.getString("fetal_presentation"));
        mr.setFetalPosition(rs.getString("fetal_position"));
        mr.setFetalMovement(rs.getString("fetal_movement"));

        // Khám sản khoa
        double cd = rs.getDouble("cervical_dilation_cm"); if (!rs.wasNull()) mr.setCervicalDilationCm(cd);
        mr.setCervicalEffacement(rs.getString("cervical_effacement"));
        mr.setAmnioticFluid(rs.getString("amniotic_fluid"));
        mr.setPresentationStation(rs.getString("presentation_station"));

        // Dấu hiệu nguy hiểm
        mr.setEdema(rs.getString("edema"));
        mr.setProteinuria(rs.getString("proteinuria"));
        boolean vb = rs.getBoolean("vaginal_bleeding"); if (!rs.wasNull()) mr.setVaginalBleeding(vb);
        boolean uc = rs.getBoolean("uterine_contractions"); if (!rs.wasNull()) mr.setUterineContractions(uc);
        mr.setRiskFlagsJson(rs.getString("risk_flags_json"));

        // Kế hoạch
        mr.setTreatmentPlan(rs.getString("treatment_plan"));
        Date nad = rs.getDate("next_appointment_date");
        if (nad != null) mr.setNextAppointmentDate(nad.toLocalDate());
        mr.setReferredTo(rs.getString("referred_to"));
        // Status — đọc an toàn, nếu cột chưa tồn tại thì dùng mặc định "final"
        try { mr.setStatus(rs.getString("status")); } catch (SQLException ignored) { mr.setStatus("final"); }

        // JOIN fields
        try { mr.setPatientId(rs.getInt("patient_id")); } catch (SQLException ignored) {}
        mr.setPatientName(rs.getString("patient_name"));
        try { mr.setPatientPhone(rs.getString("patient_phone")); } catch (SQLException ignored) {}
        try { mr.setPatientDob(rs.getString("patient_dob")); } catch (SQLException ignored) {}
        mr.setAppointmentDate(rs.getString("appointment_date"));
        mr.setTimeSlot(rs.getString("time_slot"));
        mr.setSymptoms(rs.getString("symptoms"));
        mr.setLastMenstrualPeriod(rs.getString("last_menstrual_period"));
        int pid = rs.getInt("pregnancy_id"); if (!rs.wasNull()) mr.setPregnancyId(pid);

        return mr;
    }

    // ── Dashboard helpers ────────────────────────────────────────────────────

    /**
     * Đếm tổng số hồ sơ bệnh án mà bác sĩ đã tạo.
     */
    public int countByDoctorId(int doctorId) {
        String sql =
            "SELECT COUNT(*) FROM medical_records mr " +
            "JOIN appointments a ON mr.appointment_id = a.id " +
            "WHERE a.doctor_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    /**
     * Lấy N hồ sơ bệnh án gần nhất của bác sĩ (dùng cho dashboard).
     */
    public List<MedicalRecord> getRecentByDoctorId(int doctorId, int limit) {
        String sql = BASE_SELECT +
            "WHERE a.doctor_id = ? " +
            "ORDER BY mr.created_at DESC " +
            "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        List<MedicalRecord> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }


}
