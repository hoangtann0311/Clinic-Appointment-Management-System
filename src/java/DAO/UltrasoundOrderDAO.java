package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.UltrasoundWaitingPatient;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
