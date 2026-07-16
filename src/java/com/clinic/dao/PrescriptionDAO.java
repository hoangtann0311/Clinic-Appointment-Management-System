package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Medicine;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng prescriptions và prescription_items.
 */
public class PrescriptionDAO {

    // ── Prescription ────────────────────────────────────────────────────────

    /**
     * Lấy đơn thuốc theo medical_record_id (mỗi hồ sơ chỉ có 1 đơn thuốc).
     * Trả về null nếu chưa có.
     */
    public Prescription getByMedicalRecordId(int medicalRecordId) {
        String sql =
            "SELECT p.id, p.medical_record_id, p.prescription_code, p.status, p.created_at, " +
            "       pt.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date " +
            "FROM   prescriptions p " +
            "JOIN   medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN   appointments a     ON mr.appointment_id = a.id " +
            "JOIN   patients pt        ON a.patient_id = pt.id " +
            "WHERE  p.medical_record_id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Prescription p = mapPrescription(rs);
                p.setItems(getItemsByPrescriptionId(p.getId(), conn));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy đơn thuốc theo prescription.id (kèm items).
     */
    public Prescription getById(int prescriptionId) {
        String sql =
            "SELECT p.id, p.medical_record_id, p.prescription_code, p.status, p.created_at, " +
            "       pt.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date " +
            "FROM   prescriptions p " +
            "JOIN   medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN   appointments a     ON mr.appointment_id = a.id " +
            "JOIN   patients pt        ON a.patient_id = pt.id " +
            "WHERE  p.id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Prescription p = mapPrescription(rs);
                p.setItems(getItemsByPrescriptionId(p.getId(), conn));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo mới đơn thuốc (chưa có items).
     * Trả về ID vừa tạo, hoặc -1 nếu thất bại.
     */
    public int create(int medicalRecordId, String prescriptionCode) {
        String sql =
            "INSERT INTO prescriptions (medical_record_id, prescription_code, status, created_at) " +
            "VALUES (?, ?, 'issued', ?)";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, medicalRecordId);
            ps.setString(2, prescriptionCode);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Cập nhật trạng thái đơn thuốc.
     */
    public boolean updateStatus(int prescriptionId, String status) {
        String sql = "UPDATE prescriptions SET status = ? WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, prescriptionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Prescription Items ───────────────────────────────────────────────────

    /**
     * Lấy danh sách thuốc trong đơn.
     */
    public List<PrescriptionItem> getItemsByPrescriptionId(int prescriptionId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return getItemsByPrescriptionId(prescriptionId, conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    private List<PrescriptionItem> getItemsByPrescriptionId(int prescriptionId, Connection conn)
            throws SQLException {
        String sql =
            "SELECT pi.id, pi.prescription_id, pi.medicine_id, pi.quantity, pi.dosage, " +
            "       m.name AS medicine_name, m.unit AS medicine_unit, " +
            "       mc.category_name AS medicine_category " +
            "FROM   prescription_items pi " +
            "JOIN   medicines m ON pi.medicine_id = m.id " +
            "LEFT JOIN medicine_categories mc ON mc.id = m.category_id " +
            "WHERE  pi.prescription_id = ?";

        List<PrescriptionItem> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PrescriptionItem item = new PrescriptionItem();
                item.setId(rs.getInt("id"));
                item.setPrescriptionId(rs.getInt("prescription_id"));
                item.setMedicineId(rs.getInt("medicine_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setDosage(rs.getString("dosage"));
                item.setMedicineName(rs.getString("medicine_name"));
                item.setMedicineUnit(rs.getString("medicine_unit"));
                item.setMedicineCategory(rs.getString("medicine_category"));
                list.add(item);
            }
        }
        return list;
    }

    /**
     * Thêm một dòng thuốc vào đơn.
     * Trả về ID vừa tạo hoặc -1 nếu thất bại.
     */
    public int addItem(int prescriptionId, int medicineId, int quantity, String dosage) {
        String sql =
            "INSERT INTO prescription_items (prescription_id, medicine_id, quantity, dosage) " +
            "VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, prescriptionId);
            ps.setInt(2, medicineId);
            ps.setInt(3, quantity);
            ps.setString(4, dosage);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Xoá một dòng thuốc khỏi đơn.
     */
    public boolean deleteItem(int itemId) {
        String sql = "DELETE FROM prescription_items WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xoá toàn bộ items rồi insert lại (dùng khi lưu lại toàn đơn).
     */
    public boolean replaceItems(int prescriptionId, List<PrescriptionItem> items) {
        String deleteSql = "DELETE FROM prescription_items WHERE prescription_id = ?";
        String insertSql =
            "INSERT INTO prescription_items (prescription_id, medicine_id, quantity, dosage) " +
            "VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
                del.setInt(1, prescriptionId);
                del.executeUpdate();
            }
            try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
                for (PrescriptionItem item : items) {
                    ins.setInt(1, prescriptionId);
                    ins.setInt(2, item.getMedicineId());
                    ins.setInt(3, item.getQuantity());
                    ins.setString(4, item.getDosage());
                    ins.addBatch();
                }
                ins.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Medicines lookup ─────────────────────────────────────────────────────

    /**
     * Lấy toàn bộ danh sách thuốc (dùng cho dropdown).
     */
    public List<Medicine> getAllMedicines() {
        String sql =
            "SELECT m.id, m.name, m.price, m.description, m.unit, m.stock_quantity, " +
            "       mc.category_name " +
            "FROM   medicines m " +
            "LEFT JOIN medicine_categories mc ON mc.id = m.category_id " +
            "WHERE  m.is_active = 1 " +
            "ORDER BY mc.category_name, m.name";
        List<Medicine> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Medicine m = new Medicine();
                m.setId(rs.getInt("id"));
                m.setName(rs.getString("name"));
                m.setPrice(rs.getBigDecimal("price"));
                m.setDescription(rs.getString("description"));
                m.setUnit(rs.getString("unit"));
                m.setStockQuantity(rs.getInt("stock_quantity"));
                m.setCategoryName(rs.getString("category_name"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra tất cả medicineId trong tập hợp đều tồn tại và đang active.
     * Trả về true nếu tất cả hợp lệ, false nếu có ít nhất 1 ID không hợp lệ.
     * Dùng để chống trường hợp client gửi ID giả hoặc thuốc đã bị ngừng kinh doanh.
     */
    public boolean allMedicineIdsValid(java.util.Collection<Integer> medicineIds) {
        if (medicineIds == null || medicineIds.isEmpty()) return false;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < medicineIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT COUNT(*) FROM medicines WHERE is_active = 1 AND id IN (" + placeholders + ")";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (Integer id : medicineIds) ps.setInt(idx++, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) == medicineIds.size();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Security checks ──────────────────────────────────────────────────────

    /**
     * Kiểm tra đơn thuốc có thuộc bác sĩ này không.
     */
    public boolean prescriptionBelongsToDoctor(int prescriptionId, int doctorId) {
        String sql =
            "SELECT 1 FROM prescriptions p " +
            "JOIN medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN appointments a     ON mr.appointment_id = a.id " +
            "WHERE p.id = ? AND a.doctor_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            ps.setInt(2, doctorId);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    private Prescription mapPrescription(ResultSet rs) throws SQLException {
        Prescription p = new Prescription();
        p.setId(rs.getInt("id"));
        p.setMedicalRecordId(rs.getInt("medical_record_id"));
        p.setPrescriptionCode(rs.getString("prescription_code"));
        p.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
        p.setPatientName(rs.getString("patient_name"));
        p.setAppointmentDate(rs.getString("appointment_date"));
        return p;
    }
}