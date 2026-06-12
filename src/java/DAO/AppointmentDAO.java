package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Appointment;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng appointments.
 *
 * FIX 1: JOIN đúng qua bảng patients → users
 * FIX 2: COALESCE(u.full_name, pt.full_name) để chịu được patient.user_id = NULL
 * FIX 3: LOWER(status) để chịu được 'PENDING' vs 'pending'
 */
public class AppointmentDAO {

    /**
     * Lấy tất cả lịch hẹn của bác sĩ trong một ngày cụ thể.
     */
    public List<Appointment> getByDoctorAndDate(int doctorId, LocalDate date) {
        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, a.is_emergency, a.status, " +
            "       a.service_id, a.time_slot, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
            "  AND  a.appointment_date = ? " +
            "ORDER  BY a.time_slot ASC";

        return query(sql, ps -> {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
        });
    }

    /**
     * Lấy lịch hẹn của bác sĩ trong khoảng ngày, có thể lọc thêm theo trạng thái.
     */
    public List<Appointment> getByDoctorDateRange(int doctorId,
                                                   LocalDate from,
                                                   LocalDate to,
                                                   String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, a.is_emergency, a.status, " +
            "       a.service_id, a.time_slot, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
            "  AND  a.appointment_date BETWEEN ? AND ? " +
            (filterStatus ? "  AND  LOWER(a.status) = LOWER(?) " : "") +
            "ORDER  BY a.appointment_date ASC, a.time_slot ASC";

        return query(sql, ps -> {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            if (filterStatus) ps.setString(4, statusFilter);
        });
    }

    /**
     * Đếm số lịch hẹn theo từng trạng thái trong ngày.
     */
    public java.util.Map<String, Integer> countTodayByStatus(int doctorId, LocalDate date) {
        String sql =
            "SELECT LOWER(status) AS status, COUNT(*) AS cnt " +
            "FROM   appointments " +
            "WHERE  doctor_id = ? AND appointment_date = ? " +
            "GROUP  BY LOWER(status)";

        java.util.Map<String, Integer> result = new java.util.LinkedHashMap<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date != null ? date : LocalDate.now()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                result.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Cập nhật trạng thái lịch hẹn.
     */
    public boolean updateStatus(int appointmentId, int doctorId, String newStatus) {
        String sql = "UPDATE appointments SET status = ? WHERE id = ? AND doctor_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.toLowerCase());
            ps.setInt(2, appointmentId);
            ps.setInt(3, doctorId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Helper nội bộ ────────────────────────────────────────────────────────

    @FunctionalInterface
    private interface Setter {
        void set(PreparedStatement ps) throws SQLException;
    }

    private List<Appointment> query(String sql, Setter setter) {
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.set(ps);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();

        a.setId(rs.getInt("id"));
        a.setPatientId(rs.getInt("patient_id"));
        a.setDoctorId(rs.getInt("doctor_id"));

        int pregnancyId = rs.getInt("pregnancy_id");
        if (!rs.wasNull()) a.setPregnancyId(pregnancyId);

        Date apptDate = rs.getDate("appointment_date");
        if (apptDate != null) a.setAppointmentDate(apptDate.toLocalDate());

        a.setBookingSource(rs.getString("booking_source"));
        a.setSymptoms(rs.getString("symptoms"));

        Date lmp = rs.getDate("last_menstrual_period");
        if (lmp != null) a.setLastMenstrualPeriod(lmp.toLocalDate());

        a.setEmergency(rs.getBoolean("is_emergency"));

        String status = rs.getString("status");
        a.setStatus(status != null ? status.toLowerCase() : null);

        int serviceId = rs.getInt("service_id");
        if (!rs.wasNull()) a.setServiceId(serviceId);

        Time timeSlot = rs.getTime("time_slot");
        if (timeSlot != null) a.setTimeSlot(timeSlot.toLocalTime());

        a.setPatientName(rs.getString("patient_name"));

        return a;
    }
}