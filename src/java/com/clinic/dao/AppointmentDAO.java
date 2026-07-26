package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

public class AppointmentDAO {

    public AppointmentDAO() {
    }

    // --- Receptionist / HEAD methods ---

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.schedule_id, " +
                "a.symptoms, a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.prioritized_at, a.prioritized_by, " +
                "a.status, a.service_id, a.time_slot, a.queue_number, priority_user.full_name AS prioritized_by_name, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "COALESCE(s.service_name, (SELECT STRING_AGG(sa.service_name, N', ') FROM appointment_services aps JOIN services sa ON sa.id = aps.service_id WHERE aps.appointment_id = a.id), N'Khám thai định kỳ') AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PENDINGCONFIRMATION' " +
                "   ) THEN 'PendingConfirmation' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'CANCELLED' " +
                "   ) THEN 'Cancelled' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN users priority_user ON a.prioritized_by = priority_user.id " +
                "LEFT JOIN services s ON a.service_id = s.id";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToAppointment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Appointment findAppointmentById(int id) {
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.schedule_id, " +
                "a.symptoms, a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.prioritized_at, a.prioritized_by, " +
                "a.status, a.service_id, a.time_slot, a.queue_number, priority_user.full_name AS prioritized_by_name, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "COALESCE(s.service_name, (SELECT STRING_AGG(sa.service_name, N', ') FROM appointment_services aps JOIN services sa ON sa.id = aps.service_id WHERE aps.appointment_id = a.id), N'Khám thai định kỳ') AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PENDINGCONFIRMATION' " +
                "   ) THEN 'PendingConfirmation' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'CANCELLED' " +
                "   ) THEN 'Cancelled' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN users priority_user ON a.prioritized_by = priority_user.id " +
                "LEFT JOIN services s ON a.service_id = s.id " +
                "WHERE a.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToAppointment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Appointment createAppointment(Appointment app) {
        return createAppointment(app, app.getSlotId());
    }

    /**
     * Tạo lịch hẹn, có thể liên kết với 1 time_slot đã đặt (slotId != null).
     * Dùng cho luồng bệnh nhân tự đặt lịch qua hệ thống time_slots (Phase 9).
     * Khi slotId == null, hành vi giống hệt createAppointment(app) cũ (Staff tạo thủ công).
     */
    public Appointment createAppointment(Appointment app, Integer slotId) {
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, " +
                "last_menstrual_period, is_priority, status, service_id, time_slot, queue_number, schedule_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            if (app.getPatient() != null && app.getPatient().getId() > 0) {
                ps.setInt(1, app.getPatient().getId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            
            if (app.getDoctor() != null) {
                ps.setInt(2, app.getDoctor().getId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            
            ps.setDate(3, app.getAppointmentDate() != null ? java.sql.Date.valueOf(app.getAppointmentDate()) : java.sql.Date.valueOf(LocalDate.now()));
            ps.setString(4, slotId != null ? "WEB" : "Staff");
            ps.setString(5, app.getSymptoms());
            if (app.getLastMenstrualPeriod() != null) {
                ps.setDate(6, java.sql.Date.valueOf(app.getLastMenstrualPeriod()));
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setBoolean(7, app.isPriority());
            ps.setString(8, app.getStatus());
            
            if (app.getService() != null) {
                ps.setInt(9, app.getService().getId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            
            ps.setTime(10, parseTimeSlot(app.getTimeSlot()));
            ps.setString(11, app.getQueueNumber());

            if (slotId != null) {
                ps.setInt(12, slotId);
            } else {
                ps.setNull(12, java.sql.Types.INTEGER);
            }
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    app.setId(rs.getInt(1));
                    return app;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Checks whether a service was selected when the appointment was booked.
     * Both current appointment_services rows and legacy appointments.service_id
     * rows are supported.
     */
    public boolean hasBookedService(int appointmentId, int serviceId) {
        String sql = "SELECT 1 FROM appointments a WHERE a.id = ? "
                + "AND (a.service_id = ? OR EXISTS ("
                + "SELECT 1 FROM appointment_services aps "
                + "WHERE aps.appointment_id = a.id AND aps.service_id = ?))";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, serviceId);
            ps.setInt(3, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentDAO] hasBookedService ERROR: " + e.getMessage());
            return false;
        }
    }

    /**
     * Creates a reception booking and holds its selected slot in one database
     * transaction. This prevents two concurrent reception requests from both
     * creating appointments for the same available slot.
     */
    public boolean hasActiveAppointmentOnDate(Connection conn, int patientId, int doctorId, LocalDate date, Integer excludeApptId) throws SQLException {
        String sql = "SELECT 1 FROM appointments WITH (UPDLOCK, HOLDLOCK) " +
                     "WHERE patient_id = ? AND doctor_id = ? AND appointment_date = ? " +
                     "AND status IN ('Pending', 'Confirmed', 'Waiting', 'InProgress') " +
                     (excludeApptId != null ? "AND id <> ?" : "");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setInt(2, doctorId);
            ps.setDate(3, java.sql.Date.valueOf(date));
            if (excludeApptId != null) {
                ps.setInt(4, excludeApptId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Appointment createStaffAppointmentWithHeldSlot(Appointment app, int slotId, Integer bookedByUserId) {
        // Hold 15 phút — giống online. Staff cần xác nhận thanh toán ngay sau khi
        // bệnh nhân trả tiền. Nếu bệnh nhân chưa sẵn sàng thanh toán → không giữ slot.
        String holdSlotSql = "UPDATE doctor_schedules SET booked_count = booked_count + 1, updated_at = GETDATE() "
                + "held_until = DATEADD(MINUTE, 15, GETDATE()), updated_at = GETDATE() "
                + "WHERE id = ? AND status = 'AVAILABLE'";
        String insertSql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, "
                + "last_menstrual_period, is_priority, status, service_id, time_slot, queue_number, schedule_id) "
                + "VALUES (?, ?, ?, 'Staff', ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                if (app.getPatient() != null && app.getPatient().getId() > 0) {
                    if (hasActiveAppointmentOnDate(conn, app.getPatient().getId(), app.getDoctor().getId(), app.getAppointmentDate(), null)) {
                        conn.rollback();
                        return null;
                    }
                }

                try (PreparedStatement holdPs = conn.prepareStatement(holdSlotSql)) {
                    if (bookedByUserId != null) {
                        holdPs.setInt(1, bookedByUserId);
                    } else {
                        holdPs.setNull(1, java.sql.Types.INTEGER);
                    }
                    holdPs.setInt(2, slotId);
                    if (holdPs.executeUpdate() != 1) {
                        conn.rollback();
                        return null;
                    }
                }

                try (PreparedStatement insertPs = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    if (app.getPatient() != null && app.getPatient().getId() > 0) {
                        insertPs.setInt(1, app.getPatient().getId());
                    } else {
                        insertPs.setNull(1, java.sql.Types.INTEGER);
                    }
                    if (app.getDoctor() != null) {
                        insertPs.setInt(2, app.getDoctor().getId());
                    } else {
                        insertPs.setNull(2, java.sql.Types.INTEGER);
                    }
                    insertPs.setDate(3, java.sql.Date.valueOf(app.getAppointmentDate()));
                    insertPs.setString(4, app.getSymptoms());
                    if (app.getLastMenstrualPeriod() != null) {
                        insertPs.setDate(5, java.sql.Date.valueOf(app.getLastMenstrualPeriod()));
                    } else {
                        insertPs.setNull(5, java.sql.Types.DATE);
                    }
                    insertPs.setBoolean(6, app.isPriority());
                    insertPs.setString(7, app.getStatus());
                    if (app.getService() != null) {
                        insertPs.setInt(8, app.getService().getId());
                    } else {
                        insertPs.setNull(8, java.sql.Types.INTEGER);
                    }
                    insertPs.setTime(9, parseTimeSlot(app.getTimeSlot()));
                    insertPs.setString(10, app.getQueueNumber());
                    insertPs.setInt(11, slotId);
                    insertPs.executeUpdate();

                    try (ResultSet keys = insertPs.getGeneratedKeys()) {
                        if (!keys.next()) {
                            conn.rollback();
                            return null;
                        }
                        app.setId(keys.getInt(1));
                    }
                }
                conn.commit();
                return app;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("[AppointmentDAO] createStaffAppointmentWithHeldSlot ERROR: " + e.getMessage());
            return null;
        }
    }

    /**
     * Danh sách lịch hẹn của 1 bệnh nhân (patients.id — KHÔNG phải users.id).
     * Dùng cho trang "Lịch hẹn của tôi" của Patient.
     */
    public List<Appointment> getByPatientId(int patientId) {
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.schedule_id, " +
                "a.symptoms, a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.prioritized_at, a.prioritized_by, " +
                "a.status, a.service_id, a.time_slot, a.queue_number, priority_user.full_name AS prioritized_by_name, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "COALESCE(s.service_name, (SELECT STRING_AGG(sa.service_name, N', ') FROM appointment_services aps JOIN services sa ON sa.id = aps.service_id WHERE aps.appointment_id = a.id), N'Khám thai định kỳ') AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PENDINGCONFIRMATION' " +
                "   ) THEN 'PendingConfirmation' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'CANCELLED' " +
                "   ) THEN 'Cancelled' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN users priority_user ON a.prioritized_by = priority_user.id " +
                "LEFT JOIN services s ON a.service_id = s.id " +
                "WHERE a.patient_id = ? " +
                "ORDER BY a.appointment_date DESC, a.time_slot DESC";
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToAppointment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Appointment> getByPatientIdPaginated(int patientId, String keyword, int offset, int limit) {
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.schedule_id, " +
                "a.symptoms, a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.prioritized_at, a.prioritized_by, " +
                "a.status, a.service_id, a.time_slot, a.queue_number, priority_user.full_name AS prioritized_by_name, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "COALESCE(s.service_name, (SELECT STRING_AGG(sa.service_name, N', ') FROM appointment_services aps JOIN services sa ON sa.id = aps.service_id WHERE aps.appointment_id = a.id), N'Khám thai định kỳ') AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PENDINGCONFIRMATION' " +
                "   ) THEN 'PendingConfirmation' " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'CANCELLED' " +
                "   ) THEN 'Cancelled' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN users priority_user ON a.prioritized_by = priority_user.id " +
                "LEFT JOIN services s ON a.service_id = s.id " +
                "WHERE a.patient_id = ? ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (d.full_name LIKE ? OR s.service_name LIKE ? OR a.status LIKE ?) ";
        }
        
        sql += "ORDER BY a.appointment_date DESC, a.time_slot DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, patientId);
            int paramIndex = 2;
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToAppointment(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[AppointmentDAO] getByPatientIdPaginated ERROR: " + e.getMessage());
        }
        return list;
    }

    public int countByPatientId(int patientId, String keyword) {
        String sql = "SELECT COUNT(*) FROM appointments a " +
                     "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                     "LEFT JOIN services s ON a.service_id = s.id " +
                     "WHERE a.patient_id = ? ";
                     
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (d.full_name LIKE ? OR s.service_name LIKE ? OR a.status LIKE ?) ";
        }
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, patientId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("[AppointmentDAO] countByPatientId ERROR: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Tra schedule_id gắn với 1 appointment (để giải phóng time_slot khi huỷ lịch hẹn).
     * @return schedule_id, hoặc null nếu appointment không có slot liên kết (VD: Staff tạo thủ công).
     */
    public Integer getSlotIdByAppointmentId(int appointmentId) {
        String sql = "SELECT schedule_id FROM appointments WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int v = rs.getInt("schedule_id");
                    return rs.wasNull() ? null : v;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updateAppointmentDetails(Appointment app) {
        String sql = "UPDATE appointments SET doctor_id = ?, service_id = ?, appointment_date = ?, time_slot = ?, symptoms = ?, last_menstrual_period = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (app.getDoctor() != null) {
                ps.setInt(1, app.getDoctor().getId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            if (app.getService() != null) {
                ps.setInt(2, app.getService().getId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setDate(3, app.getAppointmentDate() != null ? java.sql.Date.valueOf(app.getAppointmentDate()) : java.sql.Date.valueOf(LocalDate.now()));
            ps.setTime(4, parseTimeSlot(app.getTimeSlot()));
            ps.setString(5, app.getSymptoms());
            if (app.getLastMenstrualPeriod() != null) {
                ps.setDate(6, java.sql.Date.valueOf(app.getLastMenstrualPeriod()));
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setInt(7, app.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Updates a still-unpaid reception booking while atomically moving its
     * reservation to the newly selected slot. The caller must already have
     * verified that the appointment is editable.
     */
    public boolean updatePendingStaffAppointmentWithSlot(Appointment app, int newSlotId,
                                                          Integer bookedByUserId,
                                                          java.math.BigDecimal preExamAmount) {
        String selectSql = "SELECT schedule_id FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ? AND status = 'Pending'";
        String claimNewSql = "UPDATE doctor_schedules SET booked_count = booked_count + 1, updated_at = GETDATE() "
                + "WHERE id = ? AND status = 'APPROVED' AND COALESCE(booked_count, 0) < max_slots";
        String releaseOldSql = "UPDATE doctor_schedules SET booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END, updated_at = GETDATE() "
                + "WHERE id = ?";
        String updateAppointmentSql = "UPDATE appointments SET doctor_id = ?, service_id = ?, appointment_date = ?, "
                + "time_slot = ?, symptoms = ?, last_menstrual_period = ?, schedule_id = ? WHERE id = ? AND status = 'Pending'";
        String updateInvoiceSql = "UPDATE invoices SET total_amount = ? WHERE appointment_id = ? "
                + "AND invoice_type = 'PRE_EXAM' AND status = 'Unpaid'";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                Integer oldSlotId = null;
                try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                    selectPs.setInt(1, app.getId());
                    try (ResultSet rs = selectPs.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        int slotVal = rs.getInt("schedule_id");
                        oldSlotId = rs.wasNull() ? null : slotVal;
                    }
                }

                if (app.getPatientId() > 0 && hasActiveAppointmentOnDate(conn, app.getPatientId(), app.getDoctor().getId(), app.getAppointmentDate(), app.getId())) {
                    conn.rollback();
                    return false;
                }

                if (oldSlotId == null || oldSlotId != newSlotId) {
                    try (PreparedStatement claimPs = conn.prepareStatement(claimNewSql)) {
                        claimPs.setInt(1, newSlotId);
                        if (claimPs.executeUpdate() != 1) {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement updatePs = conn.prepareStatement(updateAppointmentSql)) {
                    updatePs.setInt(1, app.getDoctor().getId());
                    updatePs.setInt(2, app.getService().getId());
                    updatePs.setDate(3, java.sql.Date.valueOf(app.getAppointmentDate()));
                    updatePs.setTime(4, java.sql.Time.valueOf(java.time.LocalTime.parse(app.getTimeSlot().contains("-") ? app.getTimeSlot().split("-")[0].trim() : app.getTimeSlot().trim())));
                    updatePs.setString(5, app.getSymptoms());
                    if (app.getLastMenstrualPeriod() != null) {
                        updatePs.setDate(6, java.sql.Date.valueOf(app.getLastMenstrualPeriod()));
                    } else {
                        updatePs.setNull(6, java.sql.Types.DATE);
                    }
                    updatePs.setInt(7, newSlotId);
                    updatePs.setInt(8, app.getId());
                    if (updatePs.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement invoicePs = conn.prepareStatement(updateInvoiceSql)) {
                    invoicePs.setBigDecimal(1, preExamAmount);
                    invoicePs.setInt(2, app.getId());
                    invoicePs.executeUpdate();
                }

                if (oldSlotId != null && oldSlotId != newSlotId) {
                    try (PreparedStatement releasePs = conn.prepareStatement(releaseOldSql)) {
                        releasePs.setInt(1, oldSlotId);
                        releasePs.executeUpdate();
                    }
                }

                conn.commit();
                app.setSlotId(newSlotId);
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("[AppointmentDAO] updatePendingStaffAppointmentWithSlot ERROR: " + e.getMessage());
            return false;
        }
    }

    public void updateCheckIn(int id, String status, String queueNumber) {
        String sql = "UPDATE appointments SET status = ?, queue_number = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, queueNumber);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int id, String status) {
        String sql = "UPDATE appointments SET status = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean checkInAndRenumber(int appointmentId) {
        String selectApptSql = "SELECT appointment_date, doctor_id FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ? AND status IN ('Pending', 'Confirmed')";
        String updateSql = "UPDATE appointments SET status = 'Waiting' WHERE id = ? AND status IN ('Pending', 'Confirmed') AND appointment_date = CAST(GETDATE() AS DATE)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                LocalDate apptDate = null;
                int doctorId = 0;
                try (PreparedStatement psSelect = conn.prepareStatement(selectApptSql)) {
                    psSelect.setInt(1, appointmentId);
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            apptDate = rs.getDate("appointment_date").toLocalDate();
                            doctorId = rs.getInt("doctor_id");
                        }
                    }
                }

                if (apptDate == null || doctorId <= 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, appointmentId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                renumberQueueForDoctorInTransaction(conn, apptDate, doctorId);
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[AppointmentDAO] checkInAndRenumber ERROR: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentDAO] checkInAndRenumber Conn ERROR: " + e.getMessage());
            return false;
        }
    }

    public boolean markPriorityAndRenumber(int appointmentId, int userId, String reason) {
        String selectApptSql = "SELECT appointment_date, doctor_id FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ? AND status = 'Waiting'";
        String checkPaidSql = "SELECT 1 FROM invoices WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRE_EXAM' AND UPPER(status) = 'PAID'";
        String updateSql = "UPDATE appointments SET is_priority = 1, priority_reason = ?, "
                + "prioritized_at = GETDATE(), prioritized_by = ? "
                + "WHERE id = ? AND status = 'Waiting' AND appointment_date = CAST(GETDATE() AS DATE) "
                + "AND ISNULL(is_priority, 0) = 0";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement psPaid = conn.prepareStatement(checkPaidSql)) {
                    psPaid.setInt(1, appointmentId);
                    try (ResultSet rsPaid = psPaid.executeQuery()) {
                        if (!rsPaid.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                LocalDate apptDate = null;
                int doctorId = 0;
                try (PreparedStatement psSelect = conn.prepareStatement(selectApptSql)) {
                    psSelect.setInt(1, appointmentId);
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            apptDate = rs.getDate("appointment_date").toLocalDate();
                            doctorId = rs.getInt("doctor_id");
                        }
                    }
                }

                if (apptDate == null || doctorId <= 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setNString(1, reason);
                    ps.setInt(2, userId);
                    ps.setInt(3, appointmentId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                renumberQueueForDoctorInTransaction(conn, apptDate, doctorId);
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[AppointmentDAO] markPriorityAndRenumber ERROR: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentDAO] markPriorityAndRenumber Conn ERROR: " + e.getMessage());
            return false;
        }
    }

    public boolean clearPriorityAndRenumber(int appointmentId) {
        String selectApptSql = "SELECT appointment_date, doctor_id FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ? AND status = 'Waiting'";
        String updateSql = "UPDATE appointments SET is_priority = 0 "
                + "WHERE id = ? AND status = 'Waiting' AND ISNULL(is_priority, 0) = 1";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                LocalDate apptDate = null;
                int doctorId = 0;
                try (PreparedStatement psSelect = conn.prepareStatement(selectApptSql)) {
                    psSelect.setInt(1, appointmentId);
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            apptDate = rs.getDate("appointment_date").toLocalDate();
                            doctorId = rs.getInt("doctor_id");
                        }
                    }
                }

                if (apptDate == null || doctorId <= 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, appointmentId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                renumberQueueForDoctorInTransaction(conn, apptDate, doctorId);
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[AppointmentDAO] clearPriorityAndRenumber ERROR: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentDAO] clearPriorityAndRenumber Conn ERROR: " + e.getMessage());
            return false;
        }
    }

    public boolean markPriority(int appointmentId, int userId, String reason) {
        return markPriorityAndRenumber(appointmentId, userId, reason);
    }

    public boolean clearPriority(int appointmentId) {
        return clearPriorityAndRenumber(appointmentId);
    }

    public void renumberQueueForDoctorInTransaction(Connection conn, LocalDate date, int doctorId) throws SQLException {
        String selectQueueSql = "SELECT id FROM appointments WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE appointment_date = ? AND doctor_id = ? AND status = 'Waiting' "
                + "ORDER BY ISNULL(is_priority, 0) DESC, prioritized_at ASC, time_slot ASC, id ASC";
        String updateQueueSql = "UPDATE appointments SET queue_number = ? WHERE id = ?";

        try (PreparedStatement selectPs = conn.prepareStatement(selectQueueSql)) {
            selectPs.setDate(1, java.sql.Date.valueOf(date));
            selectPs.setInt(2, doctorId);
            try (ResultSet rs = selectPs.executeQuery();
                 PreparedStatement updatePs = conn.prepareStatement(updateQueueSql)) {
                int num = 1;
                while (rs.next()) {
                    updatePs.setString(1, String.format("%02d", num++));
                    updatePs.setInt(2, rs.getInt("id"));
                    updatePs.addBatch();
                }
                updatePs.executeBatch();
            }
        }
    }

    public void renumberQueueByTimeSlot(LocalDate date) {
        String selectDoctorsSql = "SELECT DISTINCT doctor_id FROM appointments WHERE appointment_date = ? AND status = 'Waiting'";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                List<Integer> doctorIds = new ArrayList<>();
                try (PreparedStatement psDoc = conn.prepareStatement(selectDoctorsSql)) {
                    psDoc.setDate(1, java.sql.Date.valueOf(date));
                    try (ResultSet rsDoc = psDoc.executeQuery()) {
                        while (rsDoc.next()) {
                            doctorIds.add(rsDoc.getInt("doctor_id"));
                        }
                    }
                }

                for (int docId : doctorIds) {
                    renumberQueueForDoctorInTransaction(conn, date, docId);
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException(e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentDAO] renumberQueueByTimeSlot ERROR: " + e.getMessage());
        }
    }

    public int getNextNormalQueueNumber(LocalDate appointmentDate) {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(queue_number, 5, 10) AS INT)), 0) + 1 " +
                "FROM appointments " +
                "WHERE queue_number LIKE 'STT-%' " +
                "AND appointment_date = ? " +
                "AND status NOT IN ('Cancelled', 'NoShow')";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(appointmentDate));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 1;
    }


    public boolean isPreExamPaid(int appointmentId) {
        String sql = "SELECT COUNT(*) " +
                "FROM invoices " +
                "WHERE appointment_id = ? " +
                "AND UPPER(invoice_type) = 'PRE_EXAM' " +
                "AND UPPER(status) = 'PAID'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approveBookingAndEnsurePreExamInvoice(int appointmentId) {
        String sqlUpdateAppt = "UPDATE appointments SET status = 'Confirmed' WHERE id = ? AND (status = 'Pending' OR status = 'Confirmed')";
        String sqlCheckInvoice = "SELECT id FROM invoices WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRE_EXAM'";
        String sqlInsertInvoice = "INSERT INTO invoices (appointment_id, amount, status, invoice_type, created_at) " +
                "VALUES (?, ?, 'Unpaid', 'PRE_EXAM', CURRENT_TIMESTAMP)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateAppt)) {
                    ps.setInt(1, appointmentId);
                    ps.executeUpdate();
                }

                boolean hasInvoice = false;
                try (PreparedStatement ps = conn.prepareStatement(sqlCheckInvoice)) {
                    ps.setInt(1, appointmentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) hasInvoice = true;
                    }
                }

                if (!hasInvoice) {
                    double basePrice = 250000;
                    String sqlPrice = "SELECT ISNULL(ts.price, ISNULL(s.price, 250000)) AS final_price " +
                            "FROM appointments a " +
                            "LEFT JOIN doctor_schedules ds2 ON a.schedule_id = ds2.id " +
                            "LEFT JOIN services s ON a.service_id = s.id " +
                            "WHERE a.id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sqlPrice)) {
                        ps.setInt(1, appointmentId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                basePrice = rs.getDouble("final_price");
                            }
                        }
                    }
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsertInvoice)) {
                        ps.setInt(1, appointmentId);
                        ps.setDouble(2, basePrice);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }



    public void confirmAppointmentAfterPreExamPaid(int appointmentId) {
        String sql = "UPDATE appointments " +
                "SET status = 'Confirmed' " +
                "WHERE id = ? " +
                "AND status = 'Pending' " +
                "AND EXISTS ( " +
                "   SELECT 1 FROM invoices i " +
                "   WHERE i.appointment_id = appointments.id " +
                "   AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "   AND UPPER(i.status) = 'PAID' " +
                ")";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean confirmPreExamPayment(Connection conn, int appointmentId) throws SQLException {
        String apptSql = "UPDATE appointments SET status = CASE WHEN status = 'Pending' THEN 'Confirmed' ELSE status END "
                + "WHERE id = ? AND status IN ('Pending','Confirmed')";
        try (PreparedStatement ps = conn.prepareStatement(apptSql)) {
            ps.setInt(1, appointmentId);
            if (ps.executeUpdate() != 1) return false;
        }

        String slotSql = "UPDATE doctor_schedules SET booked_count = booked_count + 1, updated_at = GETDATE() "
                + "WHERE id = (SELECT schedule_id FROM appointments WHERE id = ?) "
                + "AND status IN ('HELD','WAITING_VERIFICATION','BOOKED')";
        try (PreparedStatement ps = conn.prepareStatement(slotSql)) {
            ps.setInt(1, appointmentId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Gọi khi bệnh nhân vừa gửi thông tin thanh toán (invoice chuyển sang PendingConfirmation),
     * tức là bệnh nhân đã "kịp" trong thời gian giữ chỗ 15 phút — chốt khung giờ thành
     * WAITING_VERIFICATION (không còn bị tác vụ nền tự nhả nữa), chờ nhân viên xác nhận.
     *
     * <p>Lưu ý: KHÔNG chuyển thẳng sang BOOKED ở bước này — BOOKED chỉ dành cho slot đã
     * được nhân viên xác nhận thanh toán (xem {@link #finalizeBookingAfterPaymentApproved(int)}).
     * Nhờ vậy giao diện đặt lịch của bệnh nhân khác có thể phân biệt rõ "đang chờ xác nhận"
     * và "đã đặt hẳn", thay vì hiển thị nhầm là đã kín ngay khi mới gửi thanh toán.
     */
    public boolean finalizeHoldOnPaymentSubmit(Connection conn, int appointmentId) throws SQLException {
        String sql = " -- Khong con WAITING_VERIFICATION, da xu ly qua booked_count "
                + "WHERE id = (SELECT schedule_id FROM appointments WHERE id = ?) AND status = 'HELD' "
                + "AND EXISTS (SELECT 1 FROM appointments WHERE id = ? AND status = 'Pending')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Gọi khi nhân viên xác nhận thanh toán trước khám (PRE_EXAM) — chốt khung giờ từ
     * WAITING_VERIFICATION (hoặc vẫn đang HELD) thành BOOKED chính thức.
     * Nếu chỉ khớp WAITING_VERIFICATION, khung giờ có thể bị kẹt ở HELD trong tình huống
     * nhân viên xác nhận trực tiếp, khiến bệnh nhân
     * vẫn thấy thông báo "chưa thanh toán, giữ chỗ 15 phút" dù đã được xác nhận.
     * Xem {@link com.clinic.service.StaffReceptionService#confirmPayment}.
     */
    public void finalizeBookingAfterPaymentApproved(int appointmentId) {
        String sql =
            "UPDATE doctor_schedules SET booked_count = booked_count + 1, updated_at = GETDATE() " +
            "WHERE id = (SELECT schedule_id FROM appointments WHERE id = ?) AND status IN ('WAITING_VERIFICATION', 'HELD')";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Quét toàn bộ slot đang HELD nhưng đã hết hạn giữ chỗ (15 phút) mà bệnh nhân
     * chưa gửi thông tin thanh toán — tự huỷ appointment 'Pending' tương ứng và
     * nhả slot về AVAILABLE. Được gọi định kỳ bởi SlotHoldExpiryListener.
     *
     * @return số lượng slot đã được nhả (để log).
     */
    public int releaseExpiredHolds() {
        int released = 0;
        String selectSql =
            "SELECT 0 AS id WHERE 1=0";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement selectPs = conn.prepareStatement(selectSql);
             ResultSet rs = selectPs.executeQuery()) {

            List<Integer> expiredSlotIds = new java.util.ArrayList<>();
            while (rs.next()) expiredSlotIds.add(rs.getInt("id"));

            for (int slotId : expiredSlotIds) {
                try (PreparedStatement cancelAppt = conn.prepareStatement(
                        "UPDATE appointments SET status = 'Cancelled' WHERE schedule_id = ? AND status = 'Pending'")) {
                    cancelAppt.setInt(1, slotId);
                    cancelAppt.executeUpdate();
                }
                try (PreparedStatement releaseSlot = conn.prepareStatement(
                        "UPDATE doctor_schedules SET booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END, updated_at = GETDATE() held_until = NULL, updated_at = GETDATE() " +
                        "WHERE id = ? AND status = 'HELD'")) {
                    releaseSlot.setInt(1, slotId);
                    released += releaseSlot.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return released;
    }


    // --- Doctor / origin/dungdi methods ---

    public List<Appointment> getByDoctorAndDate(int doctorId, LocalDate date) {
        return getByDoctorAndDate(doctorId, date, null);
    }

    public List<Appointment> getByDoctorAndDate(int doctorId, LocalDate date, String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        StringBuilder sql = new StringBuilder(
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.status, " +
            "       a.service_id, a.time_slot, a.schedule_id, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
            "  AND  a.appointment_date = ? ");

        if (filterStatus) {
            sql.append("  AND  a.status = ? ");
        } else {
            sql.append("  AND  a.status <> 'Pending' "); // ẩn lịch chưa được Staff xác nhận thanh toán
        }
        sql.append("ORDER  BY a.is_priority DESC, a.time_slot ASC");

        return query(sql.toString(), ps -> {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            if (filterStatus) {
                ps.setString(3, statusFilter);
            }
        });
    }

    public List<Appointment> getByDoctorDateRange(int doctorId, LocalDate from, LocalDate to, String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.status, " +
            "       a.service_id, a.time_slot, a.schedule_id, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
            "  AND  a.appointment_date BETWEEN ? AND ? " +
            "  AND  a.status <> 'Pending' " + // ẩn lịch hẹn chưa được Staff xác nhận thanh toán
            (filterStatus ? "  AND  LOWER(a.status) = LOWER(?) " : "") +
            "ORDER  BY a.appointment_date ASC, a.is_priority DESC, a.time_slot ASC";

        return query(sql, ps -> {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            if (filterStatus) ps.setString(4, statusFilter);
        });
    }

    /**
     * Lấy TẤT CẢ lịch hẹn của bác sĩ, không giới hạn theo ngày.
     * Dùng khi bác sĩ không chọn bộ lọc ngày/khoảng ngày cụ thể.
     */
    public List<Appointment> getAllByDoctor(int doctorId, String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, ISNULL(a.is_priority, 0) AS is_priority, a.priority_reason, a.status, " +
            "       a.service_id, a.time_slot, a.schedule_id, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
            "  AND  a.status <> 'Pending' " + // ẩn lịch hẹn chưa được Staff xác nhận thanh toán
            (filterStatus ? "  AND  LOWER(a.status) = LOWER(?) " : "") +
            "ORDER  BY a.appointment_date DESC, a.time_slot ASC";

        return query(sql, ps -> {
            ps.setInt(1, doctorId);
            if (filterStatus) ps.setString(2, statusFilter);
        });
    }

    public Map<String, Integer> countTodayByStatus(int doctorId, LocalDate date) {
        String sql =
            "SELECT LOWER(status) AS status, COUNT(*) AS cnt " +
            "FROM   appointments " +
            "WHERE  doctor_id = ? AND appointment_date = ? " +
            "  AND  status <> 'Pending' " + // đồng bộ với danh sách: ẩn lịch chưa được Staff xác nhận thanh toán
            "GROUP  BY LOWER(status)";

        Map<String, Integer> result = new LinkedHashMap<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date != null ? date : LocalDate.now()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String status = rs.getString("status");
                if (status != null) {
                    status = status.toLowerCase();
                    if ("completed".equals(status)) {
                        status = "success";
                    }
                    result.put(status, result.getOrDefault(status, 0) + rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Starts a consultation only after reception has checked the patient in. */
    public boolean startConsultation(int appointmentId, int doctorId) {
        String sql = "UPDATE appointments SET status = 'InProgress' "
                + "WHERE id = ? AND doctor_id = ? AND status = 'Waiting'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Protects clinical documentation from being created before check-in. */
    public boolean isConsultationInProgress(int appointmentId, int doctorId) {
        String sql = "SELECT 1 FROM appointments WHERE id = ? AND doctor_id = ? AND status = 'InProgress'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Completes a consultation. */
    public boolean completeConsultation(int appointmentId, int doctorId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return completeConsultation(conn, appointmentId, doctorId);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean completeConsultation(Connection conn, int appointmentId, int doctorId) throws SQLException {
        String sql = "UPDATE appointments SET status = 'SUCCESS', queue_number = NULL "
                + "WHERE id = ? AND doctor_id = ? AND status = 'InProgress'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Locks the consultation row using the same order as clinical child writes. */
    public boolean lockConsultationInProgress(Connection conn, int appointmentId, int doctorId)
            throws SQLException {
        String sql = "SELECT status FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && "InProgress".equalsIgnoreCase(rs.getString(1));
            }
        }
    }


    // --- Internal Helpers ---

    private Appointment mapRowToAppointment(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        
        int patientId = rs.getInt("patient_id");
        Patient patient = null;
        if (!rs.wasNull()) {
            java.sql.Date dobSql = rs.getDate("patient_dob");
            LocalDate dob = dobSql != null ? dobSql.toLocalDate() : null;
            patient = new Patient(
                    patientId,
                    rs.getString("patient_name"),
                    rs.getString("patient_phone"),
                    dob
            );
        }

        int doctorId = rs.getInt("doctor_id");
        Doctor doctor = null;
        if (!rs.wasNull()) {
            String docName = rs.getString("doctor_name");
            String spec = rs.getString("doctor_spec");
            
            String degree = "Bác sĩ Sản phụ khoa";
            int experienceYears = 5;
            String avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";

            if (docName != null) {
                if (docName.contains("Phạm Trung Hiếu")) {
                    degree = "Bác sĩ Trưởng khoa (CKII)";
                    experienceYears = 12;
                } else if (docName.contains("Nguyễn Thị Mai")) {
                    degree = "Thạc sĩ, Bác sĩ Nội trú";
                    experienceYears = 15;
                } else if (docName.contains("Trần Văn Khoa")) {
                    degree = "Bác sĩ Chuyên khoa I";
                    experienceYears = 8;
                }
            }
            doctor = new Doctor(doctorId, docName, spec, degree, experienceYears, avatar);
        }

        int serviceId = rs.getInt("service_id");
        ServiceItem service = null;
        if (!rs.wasNull()) {
            service = new ServiceItem(
                    serviceId,
                    rs.getString("service_name"),
                    rs.getDouble("service_price"),
                    rs.getInt("service_dur"),
                    rs.getBoolean("service_fasting"),
                    rs.getBoolean("service_bladder"),
                    rs.getString("service_room")
            );
        }

        java.sql.Date appDateSql = rs.getDate("appointment_date");
        LocalDate appDate = appDateSql != null ? appDateSql.toLocalDate() : null;
        
        java.sql.Date lmpSql = rs.getDate("last_menstrual_period");
        LocalDate lmp = lmpSql != null ? lmpSql.toLocalDate() : null;
        
        String gestationalAge = calculateGestationalAge(lmp, appDate);
        String status = rs.getString("status");
        
        java.sql.Time timeSql = rs.getTime("time_slot");
        String timeSlot = formatTimeSlot(timeSql, status);
        
        boolean isPriority = rs.getBoolean("is_priority");
        String queueNum = rs.getString("queue_number");
        
        Appointment app = new Appointment(
                id,
                patient,
                doctor,
                service,
                appDate,
                timeSlot,
                rs.getString("symptoms"),
                lmp,
                gestationalAge,
                isPriority,
                status
        );
        // Lịch hẹn đặt online lưu dịch vụ chọn thêm ở appointment_services, nên service_id
        // có thể NULL. Luôn giữ tên dịch vụ đã tổng hợp từ câu SELECT để giao diện không trống.
        app.setServiceName(rs.getString("service_name"));
        app.setQueueNumber(queueNum);
        try {
            app.setPriorityReason(rs.getString("priority_reason"));
            java.sql.Timestamp prioritizedAt = rs.getTimestamp("prioritized_at");
            if (prioritizedAt != null) {
                app.setPrioritizedAt(prioritizedAt.toLocalDateTime());
            }
            int prioritizedBy = rs.getInt("prioritized_by");
            if (!rs.wasNull()) {
                app.setPrioritizedBy(prioritizedBy);
            }
            app.setPrioritizedByName(rs.getString("prioritized_by_name"));
        } catch (SQLException ignored) {
            // Các truy vấn tối giản không tải metadata ưu tiên.
        }
        try {
            int slotIdVal = rs.getInt("schedule_id");
            if (!rs.wasNull()) {
                app.setSlotId(slotIdVal);
            }
        } catch (Exception ignored) {}
        try {
            app.setPreExamPaymentStatus(rs.getString("pre_exam_payment_status"));
        } catch (Exception e) {
            app.setPreExamPaymentStatus("Unpaid");
        }
        return app;
    }

    private String formatTimeSlot(java.sql.Time timeSql, String status) {
        if (timeSql == null) {
            return "08:00 - 08:20";
        }
        LocalTime start = timeSql.toLocalTime();
        LocalTime end = start.plusMinutes(20);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
        return start.format(formatter) + " - " + end.format(formatter);
    }

    private java.sql.Time parseTimeSlot(String timeSlotStr) {
        if (timeSlotStr == null || !timeSlotStr.contains("-")) {
            return java.sql.Time.valueOf(LocalTime.MIDNIGHT);
        }
        try {
            String startPart = timeSlotStr.split("-")[0].trim();
            LocalTime time = LocalTime.parse(startPart);
            return java.sql.Time.valueOf(time);
        } catch (Exception e) {
            return java.sql.Time.valueOf(LocalTime.MIDNIGHT);
        }
    }

    public static String calculateGestationalAge(LocalDate lmp, LocalDate appointmentDate) {
        if (lmp == null || appointmentDate == null) return "Chưa khai báo";
        long totalDays = ChronoUnit.DAYS.between(lmp, appointmentDate);
        if (totalDays < 0) return "LMP sau ngày hẹn";
        long weeks = totalDays / 7;
        long days = totalDays % 7;
        return weeks + " tuần " + days + " ngày";
    }

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

        String status = rs.getString("status");
        a.setStatus(status != null ? status : null);
        a.setPriority(rs.getBoolean("is_priority"));
        try {
            a.setPriorityReason(rs.getString("priority_reason"));
            Timestamp prioritizedAt = rs.getTimestamp("prioritized_at");
            if (prioritizedAt != null) a.setPrioritizedAt(prioritizedAt.toLocalDateTime());
            int prioritizedBy = rs.getInt("prioritized_by");
            if (!rs.wasNull()) a.setPrioritizedBy(prioritizedBy);
            a.setPrioritizedByName(rs.getString("prioritized_by_name"));
        } catch (SQLException ignored) {
            // Các truy vấn bác sĩ chỉ cần cờ is_priority.
        }

        int serviceId = rs.getInt("service_id");
        if (!rs.wasNull()) a.setServiceId(serviceId);

        int slotId = rs.getInt("schedule_id");
        if (!rs.wasNull()) a.setSlotId(slotId);

        Time timeSlot = rs.getTime("time_slot");
        if (timeSlot != null) {
            a.setTimeSlot(formatTimeSlot(timeSlot, status));
        }

        a.setPatientName(rs.getString("patient_name"));

        return a;
    }

    /**
     * Đặt lịch khám cho bệnh nhân — dùng trực tiếp doctor_schedules (không còn time_slots).
     * slotId ở đây chính là doctor_schedules.id.
     * Tăng booked_count nguyên tử để chống double-booking.
     */
    public boolean bookSlotAndCreateAppointment(int userId, int patientId, int scheduleId, String expectedTimeSlot, int serviceId, double basePrice, String symptoms, LocalDate lmp, String gestationalAge, java.util.Map<String, String> errors) {
        Connection conn = null;
        PreparedStatement updateSlotPs = null;
        PreparedStatement selectSlotPs = null;
        PreparedStatement insertApptPs = null;
        PreparedStatement insertInvoicePs = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // 1. Atomic increment booked_count — chỉ tăng nếu còn chỗ
            String updateSlotSql = "UPDATE doctor_schedules SET "
                    + "booked_count = booked_count + 1, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'APPROVED' AND booked_count < max_slots";
            updateSlotPs = conn.prepareStatement(updateSlotSql);
            updateSlotPs.setInt(1, scheduleId);
            int rowsUpdated = updateSlotPs.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                errors.put("slotId", "Ca khám này đã hết chỗ hoặc không khả dụng.");
                return false;
            }

            // 2. Lấy thông tin doctor_schedule (doctor_id, work_date, giờ từ shifts)
            String selectSlotSql = "SELECT ds.doctor_id, ds.work_date, s.start_time "
                    + "FROM doctor_schedules ds "
                    + "INNER JOIN shifts s ON ds.shift_id = s.id "
                    + "WHERE ds.id = ?";
            selectSlotPs = conn.prepareStatement(selectSlotSql);
            selectSlotPs.setInt(1, scheduleId);
            rs = selectSlotPs.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                errors.put("slotId", "Không tìm thấy thông tin ca khám.");
                return false;
            }
            int doctorId = rs.getInt("doctor_id");
            Date workDate = rs.getDate("work_date");
            Time startTime = rs.getTime("start_time");
            rs.close(); rs = null;
            selectSlotPs.close(); selectSlotPs = null;

            // Format time_slot label từ giờ shift hoặc expectedTimeSlot
            String finalTimeSlotStr = (expectedTimeSlot != null && !expectedTimeSlot.trim().isEmpty()) 
                    ? expectedTimeSlot.trim() + ":00" 
                    : startTime.toString();

            // Kiểm tra trùng lịch hẹn active trong cùng ngày
            if (hasActiveAppointmentOnDate(conn, patientId, doctorId, workDate.toLocalDate(), null)) {
                conn.rollback();
                errors.put("general", "Bệnh nhân đã có 1 lịch khám ngoại trú còn hiệu lực trong ngày này. Không thể đặt thêm lịch mới.");
                return false;
            }

            // 3. Giá dịch vụ
            double servicePrice;
            String selectServiceSql = "SELECT price FROM services WHERE id = ? AND is_active = 1";
            try (PreparedStatement selectServicePs = conn.prepareStatement(selectServiceSql)) {
                selectServicePs.setInt(1, serviceId);
                try (ResultSet srs = selectServicePs.executeQuery()) {
                    if (!srs.next()) {
                        conn.rollback();
                        errors.put("serviceId", "Dịch vụ khám không còn khả dụng, vui lòng chọn lại.");
                        return false;
                    }
                    servicePrice = srs.getDouble("price");
                }
            }
            double totalAmount = basePrice + servicePrice;

            // 4. Tạo lịch hẹn
            String insertApptSql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, "
                    + "last_menstrual_period, is_priority, status, service_id, time_slot, schedule_id, base_fee) "
                    + "VALUES (?, ?, ?, 'WEB', ?, ?, 0, 'Pending', ?, ?, ?, ?)";
            insertApptPs = conn.prepareStatement(insertApptSql, Statement.RETURN_GENERATED_KEYS);
            insertApptPs.setInt(1, patientId);
            insertApptPs.setInt(2, doctorId);
            insertApptPs.setDate(3, workDate);
            insertApptPs.setString(4, symptoms);
            if (lmp != null) {
                insertApptPs.setDate(5, Date.valueOf(lmp));
            } else {
                insertApptPs.setNull(5, java.sql.Types.DATE);
            }
            insertApptPs.setInt(6, serviceId);
            insertApptPs.setString(7, finalTimeSlotStr);
            insertApptPs.setInt(8, scheduleId);
            insertApptPs.setDouble(9, basePrice);

            insertApptPs.executeUpdate();

            int appointmentId = 0;
            rs = insertApptPs.getGeneratedKeys();
            if (rs.next()) {
                appointmentId = rs.getInt(1);
            }
            if (appointmentId <= 0) {
                conn.rollback();
                errors.put("general", "Không thể tạo lịch hẹn.");
                return false;
            }
            rs.close();
            rs = null;

            // 5. Tạo hóa đơn PRE_EXAM = phí khám bác sĩ + một dịch vụ chính.
            String insertInvoiceSql = "INSERT INTO invoices (appointment_id, total_amount, status, invoice_type, created_at) "
                    + "VALUES (?, ?, 'Unpaid', 'PRE_EXAM', GETDATE())";
            insertInvoicePs = conn.prepareStatement(insertInvoiceSql);
            insertInvoicePs.setInt(1, appointmentId);
            insertInvoicePs.setDouble(2, totalAmount);
            insertInvoicePs.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            errors.put("general", "Lỗi database khi đặt lịch: " + e.getMessage());
            return false;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (updateSlotPs != null) { try { updateSlotPs.close(); } catch (SQLException e) {} }
            if (selectSlotPs != null) { try { selectSlotPs.close(); } catch (SQLException e) {} }
            if (insertApptPs != null) { try { insertApptPs.close(); } catch (SQLException e) {} }
            if (insertInvoicePs != null) { try { insertInvoicePs.close(); } catch (SQLException e) {} }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    public boolean cancelAppointmentAndReleaseSlot(int appointmentId, int cancelledByUserId, String reason) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement updateAppPs = null;
        PreparedStatement updateSlotPs = null;
        PreparedStatement cancelInvoicePs = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // 1. SELECT appointment
            String selectSql = "SELECT status, schedule_id FROM appointments WHERE id = ?";
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setInt(1, appointmentId);
            rs = selectPs.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            String status = rs.getString("status");
            int slotId = rs.getInt("schedule_id");
            boolean hasSlot = !rs.wasNull();

            // Check if status allows cancellation
            if ("SUCCESS".equalsIgnoreCase(status) || "InProgress".equalsIgnoreCase(status)) {
                conn.rollback();
                return false;
            }

            // 2. Update appointment status to Cancelled
            String updateAppSql = "UPDATE appointments SET status = 'Cancelled' WHERE id = ?";
            updateAppPs = conn.prepareStatement(updateAppSql);
            updateAppPs.setInt(1, appointmentId);
            updateAppPs.executeUpdate();

            // 3. Close invoices that were never collected. Paid invoices are
            // deliberately left untouched: reception must use a refund flow,
            // not a normal cancellation, once money has been collected.
            String cancelInvoiceSql = "UPDATE invoices SET status = 'Cancelled', payment_note = COALESCE(payment_note, ?) "
                    + "WHERE appointment_id = ? AND (UPPER(status) != 'PAID' OR status IS NULL)";
            cancelInvoicePs = conn.prepareStatement(cancelInvoiceSql);
            cancelInvoicePs.setString(1, reason != null ? reason : "Lịch hẹn đã bị hủy");
            cancelInvoicePs.setInt(2, appointmentId);
            cancelInvoicePs.executeUpdate();

            // 4. Giải phóng chỗ: giảm booked_count trên doctor_schedules
            if (hasSlot) {
                String updateSlotSql = "UPDATE doctor_schedules SET "
                        + "booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END, "
                        + "updated_at = GETDATE() "
                        + "WHERE id = ?";
                updateSlotPs = conn.prepareStatement(updateSlotSql);
                updateSlotPs.setInt(1, slotId);
                updateSlotPs.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (selectPs != null) { try { selectPs.close(); } catch (SQLException e) {} }
            if (updateAppPs != null) { try { updateAppPs.close(); } catch (SQLException e) {} }
            if (updateSlotPs != null) { try { updateSlotPs.close(); } catch (SQLException e) {} }
            if (cancelInvoicePs != null) { try { cancelInvoicePs.close(); } catch (SQLException e) {} }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    public boolean rescheduleAppointmentTransaction(int appointmentId, int oldSlotId, int newSlotId, int userId, Date workDate, Time startTime, java.util.Map<String, String> errors) {
        Connection conn = null;
        PreparedStatement updateNewSlotPs = null;
        PreparedStatement updateOldSlotPs = null;
        PreparedStatement updateApptPs = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // 0. Kiểm tra bệnh nhân có lịch active trùng ngày đổi lịch (trừ chính appointment hiện tại)
            String getPatientSql = "SELECT patient_id FROM appointments WITH (UPDLOCK, HOLDLOCK) WHERE id = ?";
            int patientId = 0;
            try (PreparedStatement pPs = conn.prepareStatement(getPatientSql)) {
                pPs.setInt(1, appointmentId);
                try (ResultSet prs = pPs.executeQuery()) {
                    if (prs.next()) {
                        patientId = prs.getInt(1);
                    }
                }
            }
            int newDoctorId = 0;
            String getDoctorSql = "SELECT doctor_id FROM doctor_schedules WHERE id = ?";
            try (PreparedStatement dPs = conn.prepareStatement(getDoctorSql)) {
                dPs.setInt(1, newSlotId);
                try (ResultSet drs = dPs.executeQuery()) {
                    if (drs.next()) {
                        newDoctorId = drs.getInt(1);
                    }
                }
            }
            if (patientId > 0 && hasActiveAppointmentOnDate(conn, patientId, newDoctorId, workDate.toLocalDate(), appointmentId)) {
                conn.rollback();
                errors.put("general", "Bệnh nhân đã có 1 lịch khám ngoại trú còn hiệu lực trong ngày đổi lịch.");
                return false;
            }

            // 1. Book new slot
            String updateNewSlotSql = "UPDATE doctor_schedules SET "
                    + "booked_count = booked_count + 1, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'APPROVED' AND COALESCE(booked_count, 0) < max_slots";
            updateNewSlotPs = conn.prepareStatement(updateNewSlotSql);
            updateNewSlotPs.setInt(1, newSlotId);
            int rowsUpdated = updateNewSlotPs.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                errors.put("slotId", "Ca khám này đã hết chỗ hoặc không khả dụng.");
                return false;
            }

            // 2. Release old slot
            String updateOldSlotSql = "UPDATE doctor_schedules SET "
                    + "booked_count = CASE WHEN booked_count > 0 THEN booked_count - 1 ELSE 0 END, "
                    + "notes = ISNULL(notes, '') + ?, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ?";
            updateOldSlotPs = conn.prepareStatement(updateOldSlotSql);
            updateOldSlotPs.setString(1, " [Bệnh nhân đổi sang ca #" + newSlotId + "]");
            updateOldSlotPs.setInt(2, oldSlotId);
            updateOldSlotPs.executeUpdate();

            // 3. Update appointment
            String updateApptSql = "UPDATE appointments SET appointment_date = ?, time_slot = ?, schedule_id = ? WHERE id = ?";
            updateApptPs = conn.prepareStatement(updateApptSql);
            updateApptPs.setDate(1, workDate);
            updateApptPs.setTime(2, startTime);
            updateApptPs.setInt(3, newSlotId);
            updateApptPs.setInt(4, appointmentId);
            updateApptPs.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            errors.put("general", "Lỗi database khi đổi lịch: " + e.getMessage());
            return false;
        } finally {
            if (updateNewSlotPs != null) { try { updateNewSlotPs.close(); } catch (SQLException e) {} }
            if (updateOldSlotPs != null) { try { updateOldSlotPs.close(); } catch (SQLException e) {} }
            if (updateApptPs != null) { try { updateApptPs.close(); } catch (SQLException e) {} }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                DatabaseConfig.closeConnection(conn);
            }
        }
    }
    public List<Integer> getExpiredUnpaidAppointments() {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT a.id, a.created_at, ds.work_date, s.start_time " +
                     "FROM appointments a " +
                     "JOIN invoices i ON a.id = i.appointment_id " +
                     "JOIN doctor_schedules ds ON a.schedule_id = ds.id " +
                     "JOIN shifts s ON ds.shift_id = s.id " +
                     "WHERE a.status = 'Pending' " +
                     "AND i.invoice_type = 'PRE_EXAM' " +
                     "AND i.status = 'Unpaid'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            while (rs.next()) {
                int id = rs.getInt("id");
                java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                java.sql.Date workDateSql = rs.getDate("work_date");
                java.sql.Time startTimeSql = rs.getTime("start_time");
                
                if (createdTs == null || workDateSql == null || startTimeSql == null) continue;
                
                java.time.LocalDateTime createdAt = createdTs.toLocalDateTime();
                java.time.LocalDateTime shiftStart = java.time.LocalDateTime.of(workDateSql.toLocalDate(), startTimeSql.toLocalTime());
                
                // Deadline = MAX(shiftStart - 15 mins, createdAt + 15 mins)
                java.time.LocalDateTime advanceDeadline = shiftStart.minusMinutes(15);
                java.time.LocalDateTime walkInDeadline = createdAt.plusMinutes(15);
                
                java.time.LocalDateTime deadline = advanceDeadline.isAfter(walkInDeadline) ? advanceDeadline : walkInDeadline;
                
                if (now.isAfter(deadline) || now.isEqual(deadline)) {
                    list.add(id);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
