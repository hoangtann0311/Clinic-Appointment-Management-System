package com.clinic.dao;

<<<<<<< HEAD
import com.clinic.config.DBContext;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    public AppointmentDAO() {
    }

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, " +
                "a.symptoms, a.last_menstrual_period, a.is_emergency, a.status, a.service_id, a.time_slot, a.queue_number, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, p.zalo_user_id AS patient_zalo, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "s.service_name AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN services s ON a.service_id = s.id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToAppointment(rs));
            }
        } catch (Exception e) {
=======
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
>>>>>>> origin/dungdi
            e.printStackTrace();
        }
        return list;
    }

<<<<<<< HEAD
    public Appointment findAppointmentById(int id) {
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, " +
                "a.symptoms, a.last_menstrual_period, a.is_emergency, a.status, a.service_id, a.time_slot, a.queue_number, " +
                "p.full_name AS patient_name, p.phone_number AS patient_phone, p.date_of_birth AS patient_dob, p.zalo_user_id AS patient_zalo, " +
                "d.full_name AS doctor_name, d.specialization AS doctor_spec, " +
                "s.service_name AS service_name, s.price AS service_price, s.duration_mins AS service_dur, " +
                "s.requires_fasting AS service_fasting, s.requires_full_bladder AS service_bladder, s.required_room_type AS service_room, " +
                "CASE " +
                "   WHEN EXISTS ( " +
                "       SELECT 1 FROM invoices i " +
                "       WHERE i.appointment_id = a.id " +
                "       AND UPPER(i.invoice_type) = 'PRE_EXAM' " +
                "       AND UPPER(i.status) = 'PAID' " +
                "   ) THEN 'Paid' " +
                "   ELSE 'Unpaid' " +
                "END AS pre_exam_payment_status " +
                "FROM appointments a " +
                "LEFT JOIN patients p ON a.patient_id = p.id " +
                "LEFT JOIN doctors d ON a.doctor_id = d.id " +
                "LEFT JOIN services s ON a.service_id = s.id " +
                "WHERE a.id = ?";
        try (Connection conn = DBContext.getConnection();
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
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, " +
                "last_menstrual_period, is_emergency, status, service_id, time_slot, queue_number) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
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
            ps.setString(4, "Staff");
            ps.setString(5, app.getSymptoms());
            if (app.getLastMenstrualPeriod() != null) {
                ps.setDate(6, java.sql.Date.valueOf(app.getLastMenstrualPeriod()));
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setBoolean(7, app.isEmergency());
            ps.setString(8, app.getStatus());
            
            if (app.getService() != null) {
                ps.setInt(9, app.getService().getId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            
            ps.setTime(10, parseTimeSlot(app.getTimeSlot()));
            ps.setString(11, app.getQueueNumber());
            
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

    public void updateAppointmentDetails(Appointment app) {
        String sql = "UPDATE appointments SET doctor_id = ?, service_id = ?, appointment_date = ?, time_slot = ?, symptoms = ?, last_menstrual_period = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
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

    public void updateCheckIn(int id, String status, String queueNumber) {
        String sql = "UPDATE appointments SET status = ?, queue_number = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getNextSosQueueNumber(LocalDate appointmentDate) {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(queue_number, 5, 10) AS INT)), 0) + 1 " +
                "FROM appointments " +
                "WHERE queue_number LIKE 'SOS-%' " +
                "AND appointment_date = ? " +
                "AND status NOT IN ('Cancelled', 'NoShow')";

        try (Connection conn = DBContext.getConnection();
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

    public int getNextNormalQueueNumber(LocalDate appointmentDate) {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(queue_number, 5, 10) AS INT)), 0) + 1 " +
                "FROM appointments " +
                "WHERE queue_number LIKE 'STT-%' " +
                "AND appointment_date = ? " +
                "AND status NOT IN ('Cancelled', 'NoShow')";

        try (Connection conn = DBContext.getConnection();
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

    public boolean isSlotBooked(Integer excludeAppointmentId, int doctorId, LocalDate appointmentDate, String timeSlot) {
        String sql = "SELECT COUNT(*) FROM appointments " +
                "WHERE doctor_id = ? " +
                "AND appointment_date = ? " +
                "AND time_slot = ? " +
                "AND status NOT IN ('Cancelled', 'NoShow') ";

        if (excludeAppointmentId != null) {
            sql += "AND id <> ? ";
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ps.setDate(2, java.sql.Date.valueOf(appointmentDate));
            ps.setTime(3, parseTimeSlot(timeSlot));

            if (excludeAppointmentId != null) {
                ps.setInt(4, excludeAppointmentId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

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
                    dob,
                    rs.getString("patient_zalo")
            );
        }

        int doctorId = rs.getInt("doctor_id");
        Doctor doctor = null;
        if (!rs.wasNull()) {
            String docName = rs.getString("doctor_name");
            String spec = rs.getString("doctor_spec");
            
            // Map degrees, prices, and avatars dynamically based on doctor details
            String degree = "Bác sĩ Sản phụ khoa";
            int experienceYears = 5;
            double price = 150000;
            String avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";

            if (docName != null) {
                if (docName.contains("Phạm Trung Hiếu")) {
                    degree = "Bác sĩ Trưởng khoa (CKII)";
                    experienceYears = 12;
                    price = 200000;
                } else if (docName.contains("Nguyễn Thị Mai")) {
                    degree = "Thạc sĩ, Bác sĩ Nội trú";
                    experienceYears = 15;
                    price = 300000;
                } else if (docName.contains("Trần Văn Khoa")) {
                    degree = "Bác sĩ Chuyên khoa I";
                    experienceYears = 8;
                    price = 150000;
                }
            }
            doctor = new Doctor(doctorId, docName, spec, degree, experienceYears, price, avatar);
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
        
        boolean isEmergency = rs.getBoolean("is_emergency");
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
                isEmergency,
                status
        );
        app.setQueueNumber(queueNum);
        try {
            app.setPreExamPaymentStatus(rs.getString("pre_exam_payment_status"));
        } catch (Exception e) {
            app.setPreExamPaymentStatus("Unpaid");
        }
        return app;
    }

    private String formatTimeSlot(java.sql.Time timeSql, String status) {
        if ("Emergency_SOS".equals(status)) {
            return "Khẩn cấp (SOS)";
        }
        if (timeSql == null) {
            return "08:00 - 08:20";
        }
        LocalTime start = timeSql.toLocalTime();
        LocalTime end = start.plusMinutes(20);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
        return start.format(formatter) + " - " + end.format(formatter);
    }

    private java.sql.Time parseTimeSlot(String timeSlotStr) {
        if (timeSlotStr == null || "Khẩn cấp (SOS)".equalsIgnoreCase(timeSlotStr) || !timeSlotStr.contains("-")) {
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

    public boolean isPreExamPaid(int appointmentId) {
        String sql = "SELECT COUNT(*) " +
                "FROM invoices " +
                "WHERE appointment_id = ? " +
                "AND UPPER(invoice_type) = 'PRE_EXAM' " +
                "AND UPPER(status) = 'PAID'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
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

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
=======
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
>>>>>>> origin/dungdi
