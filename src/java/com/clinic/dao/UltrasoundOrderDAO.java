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
            + "WHERE " + WAITING_CONDITION + " AND " + ULTRASOUND_SERVICE_CONDITION + " "
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
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE " + WAITING_CONDITION + " AND " + ULTRASOUND_SERVICE_CONDITION;

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

    public boolean markCompleted(int orderId) {
        String sql =
            "UPDATE o SET o.status = ? "
            + "FROM test_orders o "
            + "LEFT JOIN services s ON o.service_id = s.id "
            + "LEFT JOIN service_categories c ON s.category_id = c.id "
            + "WHERE o.id = ? AND " + WAITING_CONDITION + " AND " + ULTRASOUND_SERVICE_CONDITION;

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, COMPLETED_STATUS);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] markCompleted error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi cập nhật trạng thái siêu âm", e);
        } finally {
            closeResources(conn, ps, null);
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

    public int insert(int medicalRecordId, int doctorId, int serviceId, String status) {
        String sql = "INSERT INTO test_orders (medical_record_id, doctor_id, service_id, status, created_at) VALUES (?, ?, ?, ?, GETDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, medicalRecordId);
            ps.setInt(2, doctorId);
            ps.setInt(3, serviceId);
            ps.setString(4, status);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int orderId = rs.getInt(1);
                    // Gửi thông báo cho bệnh nhân đi siêu âm/xét nghiệm
                    com.clinic.utils.NotificationHelper.notifyPatientForTest(medicalRecordId, serviceId);
                    return orderId;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundOrderDAO] insert error: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
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
