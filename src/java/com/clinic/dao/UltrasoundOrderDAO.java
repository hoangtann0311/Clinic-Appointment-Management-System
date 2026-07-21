package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.UltrasoundWaitingPatient;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for ultrasound test orders assigned to sonographers.
 */
public class UltrasoundOrderDAO {

    public static final String COMPLETED_STATUS = "Completed";

    private static final String WAITING_CONDITION =
        "("
        + "UPPER(LTRIM(RTRIM(ISNULL(o.status, '')))) IN ('PENDING', 'WAITING', 'ORDERED') "
        + "OR LOWER(CONVERT(NVARCHAR(30), ISNULL(o.status, ''))) LIKE N'%chờ%'"
        + ")";

    private static final String ULTRASOUND_SERVICE_CONDITION =
        "("
        + "LOWER(CONVERT(NVARCHAR(255), ISNULL(s.service_name, ''))) LIKE N'%ultrasound%' "
        + "OR LOWER(CONVERT(NVARCHAR(255), ISNULL(s.service_name, ''))) LIKE N'%siêu âm%' "
        + "OR LOWER(CONVERT(NVARCHAR(255), ISNULL(c.category_name, ''))) LIKE N'%ultrasound%' "
        + "OR LOWER(CONVERT(NVARCHAR(255), ISNULL(c.category_name, ''))) LIKE N'%siêu âm%' "
        + "OR LOWER(CONVERT(NVARCHAR(255), ISNULL(s.required_room_type, ''))) LIKE N'%ultrasound%' "
        + "OR LOWER(CONVERT(NVARCHAR(255), ISNULL(s.required_room_type, ''))) LIKE N'%siêu âm%'"
        + ")";

    // BR-11: Chỉ hiển thị chỉ định siêu âm khi hóa đơn POST_EXAM đã Paid,
    // ngoại trừ ca cấp cứu được bỏ qua điều kiện thanh toán (BR-07).
    private static final String PAYMENT_GATE_CONDITION =
        "("
        + "ISNULL(a.is_emergency, 0) = 1 "
        + "OR UPPER(ISNULL(a.status, '')) = 'EMERGENCY_SOS' "
        + "OR ((a.service_id = o.service_id OR EXISTS ("
        + "       SELECT 1 FROM appointment_services aps "
        + "       WHERE aps.appointment_id = a.id AND aps.service_id = o.service_id"
        + "    )) AND EXISTS ("
        + "       SELECT 1 FROM invoices pre "
        + "       WHERE pre.appointment_id = a.id "
        + "       AND UPPER(pre.invoice_type) = 'PRE_EXAM' "
        + "       AND UPPER(pre.status) = 'PAID'"
        + "    )) "
        + "OR EXISTS ("
        + "  SELECT 1 FROM invoices inv "
        + "  WHERE inv.appointment_id = a.id "
        + "  AND UPPER(inv.invoice_type) = 'POST_EXAM' "
        + "  AND UPPER(inv.status) = 'PAID'"
        + ")"
        + ")";

    public List<UltrasoundWaitingPatient> findWaiting(String sortBy, String sortDir) {
        String sql =
            "SELECT o.id AS order_id, o.medical_record_id, mr.appointment_id, "
            + "a.patient_id, p.full_name AS patient_name, p.phone_number, p.date_of_birth, "
            + "a.appointment_date, a.time_slot, o.service_id, s.service_name, s.price, "
            + "d.full_name AS doctor_name, a.symptoms, ISNULL(a.is_emergency, 0) AS is_emergency, "
            + "ISNULL(s.requires_fasting, 0) AS requires_fasting, "
            + "ISNULL(s.requires_full_bladder, 0) AS requires_full_bladder, "
            + "o.status, o.created_at "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN patients p ON a.patient_id = p.id "
            + "LEFT JOIN doctors d ON o.doctor_id = d.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE " + WAITING_CONDITION + " AND " + ULTRASOUND_SERVICE_CONDITION
            + " AND " + PAYMENT_GATE_CONDITION + " "
            + "ORDER BY " + resolveSortColumn(sortBy) + " " + resolveSortDirection(sortDir)
            + ", o.id ASC";

        List<UltrasoundWaitingPatient> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapWaitingPatient(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] findWaiting error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy danh sách chờ siêu âm", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return orders;
    }

    public int countWaiting() {
        String sql =
            "SELECT COUNT(*) AS total "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE " + WAITING_CONDITION + " AND " + ULTRASOUND_SERVICE_CONDITION
            + " AND " + PAYMENT_GATE_CONDITION;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt("total") : 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] countWaiting error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi đếm danh sách chờ siêu âm", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    public UltrasoundWaitingPatient getById(int orderId) {
        String sql =
            "SELECT o.id AS order_id, o.medical_record_id, mr.appointment_id, "
            + "a.patient_id, p.full_name AS patient_name, p.phone_number, p.date_of_birth, "
            + "a.appointment_date, a.time_slot, o.service_id, s.service_name, s.price, "
            + "d.full_name AS doctor_name, a.symptoms, ISNULL(a.is_emergency, 0) AS is_emergency, "
            + "ISNULL(s.requires_fasting, 0) AS requires_fasting, "
            + "ISNULL(s.requires_full_bladder, 0) AS requires_full_bladder, "
            + "o.status, o.created_at "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN patients p ON a.patient_id = p.id "
            + "LEFT JOIN doctors d ON o.doctor_id = d.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE o.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapWaitingPatient(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] getById error: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Uses the same payment gate as the sonographer queue so a guessed order
     * ID cannot be used to bypass payment verification. Orders are handled by
     * the shared sonographer pool in the current data model.
     */
    public boolean isReadyForSonographer(int orderId) {
        String sql = "SELECT 1 "
                + "FROM test_orders o "
                + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
                + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
                + "LEFT JOIN services s ON o.service_id = s.id "
                + "LEFT JOIN service_categories c ON s.category_id = c.id "
                + "WHERE o.id = ? AND " + ULTRASOUND_SERVICE_CONDITION
                + " AND " + PAYMENT_GATE_CONDITION;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] isReadyForSonographer error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateStatus(int orderId, String newStatus) {
        String sql = "UPDATE test_orders SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] updateStatus error: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private static Boolean hasSonographerOwnershipColumn = null;

    public boolean isSonographerOwnershipSupported() {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return checkSonographerOwnershipColumn(conn);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean checkSonographerOwnershipColumn(Connection conn) {
        if (hasSonographerOwnershipColumn != null) return hasSonographerOwnershipColumn;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'test_orders' AND COLUMN_NAME = 'sonographer_user_id'")) {
            try (ResultSet rs = ps.executeQuery()) {
                hasSonographerOwnershipColumn = rs.next();
            }
        } catch (Exception e) {
            hasSonographerOwnershipColumn = false;
        }
        return hasSonographerOwnershipColumn;
    }

    /**
     * Atomically moves an unassigned pending order to InProgress and assigns sonographer_user_id.
     * Prevents race condition if two sonographers try to start the same order.
     */
    public boolean startUltrasoundOrder(int orderId, int sonographerUserId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            boolean hasCol = checkSonographerOwnershipColumn(conn);
            if (!hasCol) {
                System.err.println("[UltrasoundOrderDAO] CẤU HÌNH DATABASE CHƯA HỖ TRỢ OWNERSHIP: Bảng test_orders chưa bổ sung cột sonographer_user_id (V12 migration script).");
                String sql = "UPDATE test_orders SET status = 'InProgress' WHERE id = ? AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('PENDING', 'WAITING', 'ORDERED')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                String sql = "UPDATE test_orders SET sonographer_user_id = ?, accepted_at = CURRENT_TIMESTAMP, status = 'InProgress' "
                        + "WHERE id = ? AND (sonographer_user_id IS NULL OR sonographer_user_id = ?) AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('PENDING', 'WAITING', 'ORDERED')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, sonographerUserId);
                    ps.setInt(2, orderId);
                    ps.setInt(3, sonographerUserId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] startUltrasoundOrder error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Verifies that the given sonographer is the owner of the specified order.
     */
    public boolean checkSonographerOwnership(int orderId, int sonographerUserId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            boolean hasCol = checkSonographerOwnershipColumn(conn);
            if (!hasCol) {
                return true; // Migration not executed yet
            }
            String sql = "SELECT 1 FROM test_orders WHERE id = ? AND sonographer_user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, sonographerUserId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] checkSonographerOwnership error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Verifies that the given doctor (by user ID) is the ordering doctor for this ultrasound order.
     */
    public boolean checkDoctorOwnership(int orderId, int doctorUserId) {
        String sql = "SELECT 1 FROM test_orders o "
                   + "LEFT JOIN doctors d ON o.doctor_id = d.id "
                   + "WHERE o.id = ? AND d.user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, doctorUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] checkDoctorOwnership error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Verifies that the given patient (by user ID) owns the appointment for this order AND order is Confirmed.
     */
    public boolean checkPatientOwnership(int orderId, int patientUserId) {
        String sql = "SELECT 1 FROM test_orders o "
                   + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
                   + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
                   + "LEFT JOIN patients p ON a.patient_id = p.id "
                   + "WHERE o.id = ? AND p.user_id = ? AND UPPER(LTRIM(RTRIM(ISNULL(o.status, '')))) IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, patientUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] checkPatientOwnership error: " + e.getMessage());
            return false;
        }
    }

    public int insert(int medicalRecordId, int doctorId, int serviceId, String status) {
        return insert(medicalRecordId, doctorId, serviceId, status, null);
    }

    /**
     * Creates an ultrasound order.  A reason is recorded only when the doctor
     * explicitly re-orders a service that already has an active order.
     */
    public int insert(Connection conn, int medicalRecordId, int doctorId, int serviceId, String status, String reorderReason) throws SQLException {
        String sql = "INSERT INTO test_orders (medical_record_id, doctor_id, service_id, status, reorder_reason, created_at) VALUES (?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, medicalRecordId);
            ps.setInt(2, doctorId);
            ps.setInt(3, serviceId);
            ps.setString(4, status);
            ps.setString(5, reorderReason);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    public int insert(int medicalRecordId, int doctorId, int serviceId, String status, String reorderReason) {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            return insert(conn, medicalRecordId, doctorId, serviceId, status, reorderReason);
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] insert error: " + e.getMessage());
            return -1;
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    public UltrasoundWaitingPatient findActiveOrder(Connection conn, int medicalRecordId, int serviceId) throws SQLException {
        String sql = "SELECT TOP 1 o.id AS order_id, o.medical_record_id, o.service_id, o.status, o.created_at "
                + "FROM test_orders o WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE o.medical_record_id = ? AND o.service_id = ? "
                + "AND UPPER(LTRIM(RTRIM(ISNULL(o.status, '')))) NOT IN ('COMPLETED', 'CANCELLED', 'CONFIRMED') "
                + "ORDER BY o.id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            ps.setInt(2, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                UltrasoundWaitingPatient order = new UltrasoundWaitingPatient();
                order.setOrderId(rs.getInt("order_id"));
                order.setMedicalRecordId(rs.getInt("medical_record_id"));
                order.setServiceId(rs.getInt("service_id"));
                order.setStatus(rs.getString("status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                return order;
            }
        }
    }

    public UltrasoundWaitingPatient findActiveOrder(int medicalRecordId, int serviceId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return findActiveOrder(conn, medicalRecordId, serviceId);
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi database khi kiểm tra chỉ định siêu âm đang xử lý", e);
        }
    }

    public List<UltrasoundWaitingPatient> findAll(int offset, int pageSize, String search, String statusFilter, String dateFilter, Boolean isEmergency, String sortBy, String sortDir) {
        StringBuilder sql = new StringBuilder(
            "SELECT o.id AS order_id, o.medical_record_id, mr.appointment_id, "
            + "a.patient_id, p.full_name AS patient_name, p.phone_number, p.date_of_birth, "
            + "a.appointment_date, a.time_slot, o.service_id, s.service_name, s.price, "
            + "d.full_name AS doctor_name, a.symptoms, ISNULL(a.is_emergency, 0) AS is_emergency, "
            + "ISNULL(s.requires_fasting, 0) AS requires_fasting, "
            + "ISNULL(s.requires_full_bladder, 0) AS requires_full_bladder, "
            + "o.status, o.created_at "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN patients p ON a.patient_id = p.id "
            + "LEFT JOIN doctors d ON o.doctor_id = d.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE " + ULTRASOUND_SERVICE_CONDITION
            + " AND " + PAYMENT_GATE_CONDITION
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR d.full_name LIKE ? OR CAST(o.id AS VARCHAR) LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND o.status = ? ");
            params.add(statusFilter.trim());
        }

        if (dateFilter != null && !dateFilter.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ? ");
            params.add(java.sql.Date.valueOf(dateFilter.trim()));
        }

        if (isEmergency != null) {
            sql.append(" AND a.is_emergency = ? ");
            params.add(isEmergency ? 1 : 0);
        }

        sql.append(" ORDER BY " + resolveSortColumn(sortBy) + " " + resolveSortDirection(sortDir)
                 + ", o.id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");
        params.add(offset);
        params.add(pageSize);

        List<UltrasoundWaitingPatient> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else if (p instanceof java.sql.Date) {
                    ps.setDate(i + 1, (java.sql.Date) p);
                }
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapWaitingPatient(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] findAll error: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return orders;
    }

    public int countAll(String search, String statusFilter, String dateFilter, Boolean isEmergency) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) AS total "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN patients p ON a.patient_id = p.id "
            + "LEFT JOIN doctors d ON o.doctor_id = d.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE " + ULTRASOUND_SERVICE_CONDITION
            + " AND " + PAYMENT_GATE_CONDITION
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR d.full_name LIKE ? OR CAST(o.id AS VARCHAR) LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND o.status = ? ");
            params.add(statusFilter.trim());
        }

        if (dateFilter != null && !dateFilter.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ? ");
            params.add(java.sql.Date.valueOf(dateFilter.trim()));
        }

        if (isEmergency != null) {
            sql.append(" AND a.is_emergency = ? ");
            params.add(isEmergency ? 1 : 0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else if (p instanceof java.sql.Date) {
                    ps.setDate(i + 1, (java.sql.Date) p);
                }
            }

            rs = ps.executeQuery();
            return rs.next() ? rs.getInt("total") : 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] countAll error: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private UltrasoundWaitingPatient mapWaitingPatient(ResultSet rs) throws SQLException {
        UltrasoundWaitingPatient item = new UltrasoundWaitingPatient();
        item.setOrderId(rs.getInt("order_id"));
        item.setMedicalRecordId(getNullableInt(rs, "medical_record_id"));
        item.setAppointmentId(getNullableInt(rs, "appointment_id"));
        item.setPatientId(getNullableInt(rs, "patient_id"));
        item.setPatientName(rs.getString("patient_name"));
        item.setPhoneNumber(rs.getString("phone_number"));
        item.setDateOfBirth(rs.getDate("date_of_birth"));
        item.setAppointmentDate(rs.getDate("appointment_date"));
        item.setTimeSlot(rs.getTime("time_slot"));
        item.setServiceId(getNullableInt(rs, "service_id"));
        item.setServiceName(rs.getString("service_name"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setDoctorName(rs.getString("doctor_name"));
        item.setSymptoms(rs.getString("symptoms"));
        item.setEmergency(rs.getBoolean("is_emergency"));
        item.setRequiresFasting(rs.getBoolean("requires_fasting"));
        item.setRequiresFullBladder(rs.getBoolean("requires_full_bladder"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    private Integer getNullableInt(ResultSet rs, String columnName) throws SQLException {
        int value = rs.getInt(columnName);
        return rs.wasNull() ? null : value;
    }

    private String resolveSortColumn(String sortBy) {
        if (sortBy == null) {
            return "a.appointment_date";
        }
        switch (sortBy) {
            case "patientName":
                return "p.full_name";
            case "serviceName":
                return "s.service_name";
            case "createdAt":
                return "o.created_at";
            case "emergency":
                return "a.is_emergency";
            case "orderId":
                return "o.id";
            case "appointmentDate":
            default:
                return "a.appointment_date";
        }
    }

    private String resolveSortDirection(String sortDir) {
        return "desc".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
    }

    public List<UltrasoundWaitingPatient> getByMedicalRecordId(int recordId) {
        String sql =
            "SELECT o.id AS order_id, o.medical_record_id, mr.appointment_id, "
            + "a.patient_id, p.full_name AS patient_name, p.phone_number, p.date_of_birth, "
            + "a.appointment_date, a.time_slot, o.service_id, s.service_name, s.price, "
            + "d.full_name AS doctor_name, a.symptoms, ISNULL(a.is_emergency, 0) AS is_emergency, "
            + "ISNULL(s.requires_fasting, 0) AS requires_fasting, "
            + "ISNULL(s.requires_full_bladder, 0) AS requires_full_bladder, "
            + "o.status, o.created_at "
            + "FROM test_orders o "
            + "LEFT JOIN medical_records mr ON o.medical_record_id = mr.id "
            + "LEFT JOIN appointments a ON mr.appointment_id = a.id "
            + "LEFT JOIN patients p ON a.patient_id = p.id "
            + "LEFT JOIN doctors d ON o.doctor_id = d.id "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE o.medical_record_id = ? "
            + "ORDER BY o.id ASC";
        List<UltrasoundWaitingPatient> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, recordId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapWaitingPatient(rs));
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] getByMedicalRecordId error: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.err.println("[UltrasoundOrderDAO] close ResultSet error: " + e.getMessage());
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                System.err.println("[UltrasoundOrderDAO] close PreparedStatement error: " + e.getMessage());
            }
        }
        DatabaseConfig.closeConnection(conn);
    }
}
