package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.TestOrder;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho test_orders (chỉ định cận lâm sàng).
 */
public class TestOrderDAO {

    // ────────────────────────────────────────────────────────────────────────
    // TEST ORDERS — bác sĩ chỉ định
    // ────────────────────────────────────────────────────────────────────────

    /**
     * Lấy tất cả chỉ định của 1 hồ sơ bệnh án.
     */
    public List<TestOrder> getByMedicalRecordId(int medicalRecordId) {
        String sql =
            "SELECT to2.id, to2.medical_record_id, to2.doctor_id, to2.service_id, " +
            "       to2.status, to2.created_at, " +
            "       s.service_name, s.service_code, s.price, s.requires_fasting " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "WHERE to2.medical_record_id = ? " +
            "ORDER BY to2.created_at";
        List<TestOrder> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public TestOrder getById(int id) {
        String sql =
            "SELECT to2.id, to2.medical_record_id, to2.doctor_id, to2.service_id, " +
            "       to2.status, to2.created_at, " +
            "       s.service_name, s.service_code, s.price, s.requires_fasting " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "WHERE to2.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Tạo nhiều chỉ định xét nghiệm cùng lúc (1 lần submit form bệnh án có thể có N xét nghiệm).
     * Bỏ qua serviceId đã được chỉ định trong cùng medical_record (chống trùng).
     */
    public int createBatch(int medicalRecordId, int doctorId, List<Integer> serviceIds) {
        if (serviceIds == null || serviceIds.isEmpty()) return 0;
        // Lấy danh sách serviceId đã chỉ định (tránh duplicate)
        List<Integer> existing = getExistingServiceIds(medicalRecordId);
        String sql =
            "INSERT INTO test_orders (medical_record_id, doctor_id, service_id, status, created_at) " +
            "VALUES (?, ?, ?, 'pending', GETDATE())";
        int count = 0;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Integer sid : serviceIds) {
                if (sid == null || sid <= 0 || existing.contains(sid)) continue;
                ps.setInt(1, medicalRecordId);
                ps.setInt(2, doctorId);
                ps.setInt(3, sid);
                ps.addBatch();
                count++;
                // Gửi thông báo cho bệnh nhân đi thực hiện xét nghiệm cận lâm sàng
                com.clinic.utils.NotificationHelper.notifyPatientForTest(medicalRecordId, sid);
            }
            if (count > 0) ps.executeBatch();
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }

    public boolean cancel(int testOrderId) {
        String sql = "UPDATE test_orders SET status = 'cancelled' WHERE id = ? AND status = 'pending'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, testOrderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }



    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private List<Integer> getExistingServiceIds(int medicalRecordId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT service_id FROM test_orders WHERE medical_record_id = ? AND status != 'cancelled'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) ids.add(rs.getInt("service_id"));
        } catch (SQLException e) { e.printStackTrace(); }
        return ids;
    }

    private TestOrder mapRow(ResultSet rs) throws SQLException {
        TestOrder o = new TestOrder();
        o.setId(rs.getInt("id"));
        o.setMedicalRecordId(rs.getInt("medical_record_id"));
        o.setDoctorId(rs.getInt("doctor_id"));
        o.setServiceId(rs.getInt("service_id"));
        o.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) o.setCreatedAt(ts.toLocalDateTime());

        o.setServiceName(rs.getString("service_name"));
        o.setServiceCode(rs.getString("service_code"));
        o.setServicePrice(rs.getBigDecimal("price"));
        o.setRequiresFasting(rs.getBoolean("requires_fasting"));

        return o;
    }
}