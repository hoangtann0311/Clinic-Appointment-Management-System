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
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.slot_id, " +
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
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.slot_id, " +
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
        return createAppointment(app, null);
    }

    /**
     * Tạo lịch hẹn, có thể liên kết với 1 time_slot đã đặt (slotId != null).
     * Dùng cho luồng bệnh nhân tự đặt lịch qua hệ thống time_slots (Phase 9).
     * Khi slotId == null, hành vi giống hệt createAppointment(app) cũ (Staff tạo thủ công).
     */
    public Appointment createAppointment(Appointment app, Integer slotId) {
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, " +
                "last_menstrual_period, is_emergency, status, service_id, time_slot, queue_number, slot_id) " +
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
            ps.setBoolean(7, app.isEmergency());
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
     * Danh sách lịch hẹn của 1 bệnh nhân (patients.id — KHÔNG phải users.id).
     * Dùng cho trang "Lịch hẹn của tôi" của Patient.
     */
    public List<Appointment> getByPatientId(int patientId) {
        String sql = "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, a.appointment_date, a.booking_source, a.slot_id, " +
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

    /**
     * Tra slot_id gắn với 1 appointment (để giải phóng time_slot khi huỷ lịch hẹn).
     * @return slot_id, hoặc null nếu appointment không có slot liên kết (VD: Staff tạo thủ công).
     */
    public Integer getSlotIdByAppointmentId(int appointmentId) {
        String sql = "SELECT slot_id FROM appointments WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int v = rs.getInt("slot_id");
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

    public boolean activateEmergencySosForAppointment(int appointmentId, String queueNumber) {
        String sql = "UPDATE appointments SET status = 'Emergency_SOS', is_emergency = 1, queue_number = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, queueNumber);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Cập nhật triệu chứng cho lịch hẹn (dùng khi bệnh nhân nhập thêm mô tả lúc kích hoạt SOS). */
    public boolean updateSymptoms(int appointmentId, String symptoms) {
        String sql = "UPDATE appointments SET symptoms = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, symptoms);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getNextSosQueueNumber(LocalDate appointmentDate) {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(queue_number, 5, 10) AS INT)), 0) + 1 " +
                "FROM appointments " +
                "WHERE queue_number LIKE 'SOS-%' " +
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

    public boolean isSlotBooked(Integer excludeAppointmentId, int doctorId, LocalDate appointmentDate, String timeSlot) {
        String sql = "SELECT COUNT(*) FROM appointments " +
                "WHERE doctor_id = ? " +
                "AND appointment_date = ? " +
                "AND time_slot = ? " +
                "AND status NOT IN ('Cancelled', 'NoShow') ";

        if (excludeAppointmentId != null) {
            sql += "AND id <> ? ";
        }

        try (Connection conn = DatabaseConfig.getConnection();
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

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // --- Doctor / origin/dungdi methods ---

    public List<Appointment> getByDoctorAndDate(int doctorId, LocalDate date) {
        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, a.is_emergency, a.status, " +
            "       a.service_id, a.time_slot, a.slot_id, " +
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

    public List<Appointment> getByDoctorDateRange(int doctorId, LocalDate from, LocalDate to, String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, a.is_emergency, a.status, " +
            "       a.service_id, a.time_slot, a.slot_id, " +
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
     * Lấy TẤT CẢ lịch hẹn của bác sĩ, không giới hạn theo ngày.
     * Dùng khi bác sĩ không chọn bộ lọc ngày/khoảng ngày cụ thể.
     */
    public List<Appointment> getAllByDoctor(int doctorId, String statusFilter) {
        boolean filterStatus = statusFilter != null && !statusFilter.isBlank();

        String sql =
            "SELECT a.id, a.patient_id, a.doctor_id, a.pregnancy_id, " +
            "       a.appointment_date, a.booking_source, a.symptoms, " +
            "       a.last_menstrual_period, a.is_emergency, a.status, " +
            "       a.service_id, a.time_slot, a.slot_id, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name " +
            "FROM   appointments a " +
            "JOIN   patients  pt ON a.patient_id = pt.id " +
            "LEFT JOIN users  u  ON pt.user_id   = u.id " +
            "WHERE  a.doctor_id = ? " +
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

    public boolean updateStatus(int appointmentId, int doctorId, String newStatus) {
        String sql = "UPDATE appointments SET status = ? WHERE id = ? AND doctor_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            // Preserve exact case per BA spec: Pending, Confirmed, Waiting,
            // Emergency_SOS, InProgress, SUCCESS, Cancelled, NoShow
            ps.setString(1, newStatus);
            ps.setInt(2, appointmentId);
            ps.setInt(3, doctorId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
                    dob,
                    rs.getString("patient_zalo")
            );
        }

        int doctorId = rs.getInt("doctor_id");
        Doctor doctor = null;
        if (!rs.wasNull()) {
            String docName = rs.getString("doctor_name");
            String spec = rs.getString("doctor_spec");
            
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
            int slotIdVal = rs.getInt("slot_id");
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
        a.setStatus(status != null ? status : null);

        int serviceId = rs.getInt("service_id");
        if (!rs.wasNull()) a.setServiceId(serviceId);

        int slotId = rs.getInt("slot_id");
        if (!rs.wasNull()) a.setSlotId(slotId);

        Time timeSlot = rs.getTime("time_slot");
        if (timeSlot != null) {
            a.setTimeSlot(formatTimeSlot(timeSlot, status));
        }

        a.setPatientName(rs.getString("patient_name"));

        return a;
    }

    public boolean bookSlotAndCreateAppointment(int userId, int patientId, int slotId, int serviceId, String symptoms, LocalDate lmp, String gestationalAge, java.util.Map<String, String> errors) {
        Connection conn = null;
        PreparedStatement updateSlotPs = null;
        PreparedStatement selectSlotPs = null;
        PreparedStatement insertApptPs = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // 1. Conditional Update on slot
            String updateSlotSql = "UPDATE time_slots SET "
                    + "status = 'BOOKED', "
                    + "booked_by = ?, "
                    + "booked_at = GETDATE(), "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'AVAILABLE'";
            updateSlotPs = conn.prepareStatement(updateSlotSql);
            updateSlotPs.setInt(1, userId);
            updateSlotPs.setInt(2, slotId);
            int rowsUpdated = updateSlotPs.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                errors.put("slotId", "Khung giờ khám này đã bị người khác đặt hoặc không tồn tại.");
                return false;
            }

            // 2. Select slot details (doctor_id, work_date, start_time) to build appointment
            String selectSlotSql = "SELECT doctor_id, work_date, start_time FROM time_slots WHERE id = ?";
            selectSlotPs = conn.prepareStatement(selectSlotSql);
            selectSlotPs.setInt(1, slotId);
            rs = selectSlotPs.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                errors.put("slotId", "Không tìm thấy thông tin khung giờ khám.");
                return false;
            }
            int doctorId = rs.getInt("doctor_id");
            Date workDate = rs.getDate("work_date");
            Time startTime = rs.getTime("start_time");

            // 3. Create appointment
            String insertApptSql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, booking_source, symptoms, "
                    + "last_menstrual_period, is_emergency, status, service_id, time_slot, slot_id) "
                    + "VALUES (?, ?, ?, 'WEB', ?, ?, 0, 'Confirmed', ?, ?, ?)";
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
            insertApptPs.setTime(7, startTime);
            insertApptPs.setInt(8, slotId);
            
            insertApptPs.executeUpdate();
            
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
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // 1. SELECT appointment
            String selectSql = "SELECT status, slot_id FROM appointments WHERE id = ?";
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setInt(1, appointmentId);
            rs = selectPs.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            String status = rs.getString("status");
            int slotId = rs.getInt("slot_id");
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

            // 3. Release slot (if has slot)
            if (hasSlot) {
                String noteText = "Hủy bởi user #" + cancelledByUserId + (reason != null ? ": " + reason : "");
                if (noteText.length() > 500) {
                    noteText = noteText.substring(0, 500);
                }
                String updateSlotSql = "UPDATE time_slots SET "
                        + "status = 'AVAILABLE', "
                        + "booked_by = NULL, "
                        + "booked_at = NULL, "
                        + "notes = ?, "
                        + "updated_at = GETDATE() "
                        + "WHERE id = ? AND status = 'BOOKED'";
                updateSlotPs = conn.prepareStatement(updateSlotSql);
                updateSlotPs.setString(1, noteText);
                updateSlotPs.setInt(2, slotId);
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

            // 1. Book new slot
            String updateNewSlotSql = "UPDATE time_slots SET "
                    + "status = 'BOOKED', "
                    + "booked_by = ?, "
                    + "booked_at = GETDATE(), "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'AVAILABLE'";
            updateNewSlotPs = conn.prepareStatement(updateNewSlotSql);
            updateNewSlotPs.setInt(1, userId);
            updateNewSlotPs.setInt(2, newSlotId);
            int rowsUpdated = updateNewSlotPs.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                errors.put("slotId", "Khung giờ khám mới đã bị người khác đặt hoặc không tồn tại.");
                return false;
            }

            // 2. Release old slot
            String updateOldSlotSql = "UPDATE time_slots SET "
                    + "status = 'AVAILABLE', "
                    + "booked_by = NULL, "
                    + "booked_at = NULL, "
                    + "notes = ?, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'BOOKED'";
            updateOldSlotPs = conn.prepareStatement(updateOldSlotSql);
            updateOldSlotPs.setString(1, "Bệnh nhân đổi sang slot #" + newSlotId);
            updateOldSlotPs.setInt(2, oldSlotId);
            updateOldSlotPs.executeUpdate();

            // 3. Update appointment
            String updateApptSql = "UPDATE appointments SET appointment_date = ?, time_slot = ?, slot_id = ? WHERE id = ?";
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
}
