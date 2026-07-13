package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Pregnancy;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng pregnancies — theo dõi thai kỳ của bệnh nhân.
 */
public class PregnancyDAO {

    private static final String BASE_SELECT =
        "SELECT p.id, p.patient_id, p.start_date, p.estimated_due_date, p.actual_delivery_date, " +
        "       p.pregnancy_status, p.fetus_count, p.notes, " +
        "       u.full_name AS patient_name, " +
        "       (SELECT COUNT(*) FROM appointments a WHERE a.pregnancy_id = p.id) AS visit_count " +
        "FROM pregnancies p " +
        "LEFT JOIN users u ON u.id = p.patient_id ";

    // ────────────────────────────────────────────────────────────────────────
    // SELECT
    // ────────────────────────────────────────────────────────────────────────

    public Pregnancy getById(int id) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(BASE_SELECT + "WHERE p.id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** Tất cả thai kỳ của 1 bệnh nhân, mới nhất trước. */
    public List<Pregnancy> getByPatientId(int patientId) {
        String sql = BASE_SELECT + "WHERE p.patient_id = ? ORDER BY p.start_date DESC";
        List<Pregnancy> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Thai kỳ đang "active" (chưa sinh) gần nhất của 1 bệnh nhân, dùng để gợi ý gắn appointment mới vào. */
    public Pregnancy getActiveByPatientId(int patientId) {
        String sql = BASE_SELECT +
            "WHERE p.patient_id = ? AND (p.pregnancy_status IS NULL OR p.pregnancy_status = 'active') " +
            "ORDER BY p.start_date DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Kiểm tra thai kỳ này có thuộc về bệnh nhân mà bác sĩ này đang điều trị không
     * (tức là bác sĩ đã từng có ít nhất 1 appointment với bệnh nhân của thai kỳ đó).
     * Dùng để chặn bác sĩ xem thai kỳ của bệnh nhân không liên quan.
     */
    public boolean pregnancyVisibleToDoctor(int pregnancyId, int doctorId) {
        String sql =
            "SELECT 1 FROM pregnancies p " +
            "WHERE p.id = ? AND EXISTS (" +
            "  SELECT 1 FROM appointments a WHERE a.patient_id = p.patient_id AND a.doctor_id = ?" +
            ")";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pregnancyId);
            ps.setInt(2, doctorId);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Danh sách hồ sơ bệnh án (medical_records) thuộc về 1 thai kỳ,
     * sắp xếp theo thời gian khám tăng dần — dùng vẽ timeline thai kỳ.
     */
    public List<java.util.Map<String, Object>> getTimelineByPregnancyId(int pregnancyId) {
        String sql =
            "SELECT mr.id AS record_id, mr.created_at, mr.final_diagnosis, " +
            "       mr.weight_kg, mr.blood_pressure, mr.fundal_height_cm, mr.fetal_heart_rate, " +
            "       mr.gestational_age_weeks, mr.gestational_age_days, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       a.id AS appointment_id, doc_u.full_name AS doctor_name " +
            "FROM medical_records mr " +
            "JOIN appointments a   ON mr.appointment_id = a.id " +
            "JOIN doctors doc      ON a.doctor_id = doc.id " +
            "JOIN users doc_u      ON doc.user_id = doc_u.id " +
            "WHERE a.pregnancy_id = ? " +
            "ORDER BY mr.created_at ASC";

        List<java.util.Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pregnancyId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.HashMap<>();
                row.put("recordId", rs.getInt("record_id"));
                row.put("appointmentId", rs.getInt("appointment_id"));
                row.put("appointmentDate", rs.getString("appointment_date"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                row.put("finalDiagnosis", rs.getString("final_diagnosis"));
                row.put("doctorName", rs.getString("doctor_name"));

                double w = rs.getDouble("weight_kg");
                row.put("weightKg", rs.wasNull() ? null : w);
                row.put("bloodPressure", rs.getString("blood_pressure"));
                double fh = rs.getDouble("fundal_height_cm");
                row.put("fundalHeightCm", rs.wasNull() ? null : fh);
                int fhr = rs.getInt("fetal_heart_rate");
                row.put("fetalHeartRate", rs.wasNull() ? null : fhr);
                int gaw = rs.getInt("gestational_age_weeks");
                row.put("gestationalAgeWeeks", rs.wasNull() ? null : gaw);
                int gad = rs.getInt("gestational_age_days");
                row.put("gestationalAgeDays", rs.wasNull() ? null : gad);

                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ────────────────────────────────────────────────────────────────────────
    // INSERT / UPDATE
    // ────────────────────────────────────────────────────────────────────────

    public int create(Pregnancy p) {
        String sql =
            "INSERT INTO pregnancies (patient_id, start_date, estimated_due_date, " +
            "  actual_delivery_date, pregnancy_status, fetus_count, notes) " +
            "VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getPatientId());
            ps.setDate(2, p.getStartDate() != null ? Date.valueOf(p.getStartDate()) : null);
            ps.setDate(3, p.getEstimatedDueDate() != null ? Date.valueOf(p.getEstimatedDueDate()) : null);
            ps.setDate(4, p.getActualDeliveryDate() != null ? Date.valueOf(p.getActualDeliveryDate()) : null);
            ps.setString(5, p.getPregnancyStatus() != null ? p.getPregnancyStatus() : "active");
            if (p.getFetusCount() != null) ps.setInt(6, p.getFetusCount()); else ps.setNull(6, Types.INTEGER);
            ps.setString(7, p.getNotes());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    public boolean update(Pregnancy p) {
        String sql =
            "UPDATE pregnancies SET start_date=?, estimated_due_date=?, actual_delivery_date=?, " +
            "  pregnancy_status=?, fetus_count=?, notes=? WHERE id=?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, p.getStartDate() != null ? Date.valueOf(p.getStartDate()) : null);
            ps.setDate(2, p.getEstimatedDueDate() != null ? Date.valueOf(p.getEstimatedDueDate()) : null);
            ps.setDate(3, p.getActualDeliveryDate() != null ? Date.valueOf(p.getActualDeliveryDate()) : null);
            ps.setString(4, p.getPregnancyStatus());
            if (p.getFetusCount() != null) ps.setInt(5, p.getFetusCount()); else ps.setNull(5, Types.INTEGER);
            ps.setString(6, p.getNotes());
            ps.setInt(7, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** Gắn 1 appointment vào 1 thai kỳ (appointments.pregnancy_id). */
    public boolean linkAppointment(int appointmentId, int pregnancyId) {
        String sql = "UPDATE appointments SET pregnancy_id = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pregnancyId);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private Pregnancy mapRow(ResultSet rs) throws SQLException {
        Pregnancy p = new Pregnancy();
        p.setId(rs.getInt("id"));
        int patientId = rs.getInt("patient_id");
        if (!rs.wasNull()) p.setPatientId(patientId);

        Date sd = rs.getDate("start_date");
        if (sd != null) p.setStartDate(sd.toLocalDate());
        Date edd = rs.getDate("estimated_due_date");
        if (edd != null) p.setEstimatedDueDate(edd.toLocalDate());
        Date add = rs.getDate("actual_delivery_date");
        if (add != null) p.setActualDeliveryDate(add.toLocalDate());

        p.setPregnancyStatus(rs.getString("pregnancy_status"));
        int fc = rs.getInt("fetus_count");
        if (!rs.wasNull()) p.setFetusCount(fc);
        p.setNotes(rs.getString("notes"));

        p.setPatientName(rs.getString("patient_name"));
        p.setVisitCount(rs.getInt("visit_count"));
        return p;
    }
}