package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.LabResult;
import com.clinic.model.TestOrder;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho test_orders (chỉ định xét nghiệm) và lab_results (kết quả xét nghiệm).
 */
public class TestOrderDAO {

    // ────────────────────────────────────────────────────────────────────────
    // TEST ORDERS — bác sĩ chỉ định
    // ────────────────────────────────────────────────────────────────────────

    /**
     * Lấy tất cả chỉ định xét nghiệm của 1 hồ sơ bệnh án, kèm kết quả nếu đã có.
     */
    public List<TestOrder> getByMedicalRecordId(int medicalRecordId) {
        String sql =
            "SELECT to2.id, to2.medical_record_id, to2.doctor_id, to2.service_id, " +
            "       to2.status, to2.created_at, " +
            "       s.service_name, s.service_code, s.price, s.requires_fasting, " +
            "       lr.id AS lr_id, lr.result_details, lr.image_url, lr.updated_at AS lr_updated, " +
            "       u.full_name AS tech_name " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN lab_results lr ON lr.test_order_id = to2.id " +
            "LEFT JOIN users u ON u.id = lr.lab_technician_id " +
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

    /**
     * Lấy tất cả chỉ định PENDING (chờ xử lý) — dùng cho trang KTV xét nghiệm.
     */
    public List<TestOrder> getPending() {
        String sql =
            "SELECT to2.id, to2.medical_record_id, to2.doctor_id, to2.service_id, " +
            "       to2.status, to2.created_at, " +
            "       s.service_name, s.service_code, s.price, s.requires_fasting, " +
            "       CAST(NULL AS INT) AS lr_id, CAST(NULL AS NVARCHAR(MAX)) AS result_details, " +
            "       CAST(NULL AS VARCHAR(255)) AS image_url, " +
            "       CAST(NULL AS DATETIME) AS lr_updated, CAST(NULL AS NVARCHAR(200)) AS tech_name, " +
            "       u_pat.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appt_date " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "JOIN medical_records mr ON mr.id = to2.medical_record_id " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN users u_pat ON u_pat.id = a.patient_id " +
            "WHERE to2.status = 'pending' " +
            "ORDER BY to2.created_at";
        List<TestOrder> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TestOrder o = mapRow(rs);
                o.setPatientName(rs.getString("patient_name"));
                o.setApptDate(rs.getString("appt_date"));
                list.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public TestOrder getById(int id) {
        String sql =
            "SELECT to2.id, to2.medical_record_id, to2.doctor_id, to2.service_id, " +
            "       to2.status, to2.created_at, " +
            "       s.service_name, s.service_code, s.price, s.requires_fasting, " +
            "       lr.id AS lr_id, lr.result_details, lr.image_url, lr.updated_at AS lr_updated, " +
            "       u.full_name AS tech_name " +
            "FROM test_orders to2 " +
            "JOIN services s ON s.id = to2.service_id " +
            "LEFT JOIN lab_results lr ON lr.test_order_id = to2.id " +
            "LEFT JOIN users u ON u.id = lr.lab_technician_id " +
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
    // LAB RESULTS — KTV xét nghiệm nhập kết quả
    // ────────────────────────────────────────────────────────────────────────

    /**
     * Lưu kết quả xét nghiệm (upsert: tạo mới hoặc cập nhật nếu đã có).
     * Đồng thời cập nhật status của test_order thành 'completed'.
     */
    public boolean saveResult(int testOrderId, int serviceId, int labTechnicianId,
                              String resultDetails, String imageUrl) {
        String checkSql = "SELECT id FROM lab_results WHERE test_order_id = ?";
        try (Connection conn = DatabaseConfig.getConnection()) {
            // Kiểm tra đã có result chưa
            Integer existingResultId = null;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, testOrderId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) existingResultId = rs.getInt("id");
            }

            if (existingResultId == null) {
                // INSERT mới
                String ins =
                    "INSERT INTO lab_results (test_order_id, service_id, result_details, image_url, " +
                    "  lab_technician_id, updated_at) VALUES (?,?,?,?,?,GETDATE())";
                try (PreparedStatement ps = conn.prepareStatement(ins)) {
                    ps.setInt(1, testOrderId);
                    ps.setInt(2, serviceId);
                    ps.setString(3, resultDetails);
                    ps.setString(4, imageUrl == null ? "" : imageUrl);
                    ps.setInt(5, labTechnicianId);
                    ps.executeUpdate();
                }
            } else {
                // UPDATE
                String upd =
                    "UPDATE lab_results SET result_details=?, image_url=?, " +
                    "  lab_technician_id=?, updated_at=GETDATE() WHERE id=?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, resultDetails);
                    ps.setString(2, imageUrl == null ? "" : imageUrl);
                    ps.setInt(3, labTechnicianId);
                    ps.setInt(4, existingResultId);
                    ps.executeUpdate();
                }
            }

            // Cập nhật status test_order → completed
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE test_orders SET status='completed' WHERE id=?")) {
                ps.setInt(1, testOrderId);
                ps.executeUpdate();
            }
            return true;
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

        // Lab result (có thể null nếu chưa có kết quả)
        int lrId = rs.getInt("lr_id");
        if (!rs.wasNull() && lrId > 0) {
            LabResult lr = new LabResult();
            lr.setId(lrId);
            lr.setTestOrderId(o.getId());
            lr.setResultDetails(rs.getString("result_details"));
            lr.setImageUrl(rs.getString("image_url"));
            Timestamp lrTs = rs.getTimestamp("lr_updated");
            if (lrTs != null) lr.setUpdatedAt(lrTs.toLocalDateTime());
            lr.setLabTechnicianName(rs.getString("tech_name"));
            o.setLabResult(lr);
        }
        return o;
    }
}