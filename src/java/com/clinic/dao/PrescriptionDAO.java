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
            "       p.purchase_decision, p.purchase_decided_at, p.purchase_decided_by, " +
            "       a.id AS appointment_id, d.full_name AS doctor_name, " +
            "       pt.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date " +
            "FROM   prescriptions p " +
            "JOIN   medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN   appointments a     ON mr.appointment_id = a.id " +
            "JOIN   patients pt        ON a.patient_id = pt.id " +
            "LEFT JOIN doctors d        ON a.doctor_id = d.id " +
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
            "       p.purchase_decision, p.purchase_decided_at, p.purchase_decided_by, " +
            "       a.id AS appointment_id, d.full_name AS doctor_name, " +
            "       pt.full_name AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date " +
            "FROM   prescriptions p " +
            "JOIN   medical_records mr ON p.medical_record_id = mr.id " +
            "JOIN   appointments a     ON mr.appointment_id = a.id " +
            "JOIN   patients pt        ON a.patient_id = pt.id " +
            "LEFT JOIN doctors d        ON a.doctor_id = d.id " +
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
        try (Connection conn = DatabaseConfig.getConnection()) {
            return create(conn, medicalRecordId, prescriptionCode);
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    public int create(Connection conn, int medicalRecordId, String prescriptionCode) throws SQLException {
        String sql =
            "INSERT INTO prescriptions (medical_record_id, prescription_code, status, created_at, " +
            "purchase_decision) VALUES (?, ?, 'issued', ?, 'Pending')";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, medicalRecordId);
            ps.setString(2, prescriptionCode);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public Integer findIdByMedicalRecordId(Connection conn, int medicalRecordId) throws SQLException {
        String sql = "SELECT id FROM prescriptions WHERE medical_record_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, medicalRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
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

    /** Loads items for every prescription invoice on a page in one query. */
    public java.util.Map<Integer, List<PrescriptionItem>> getItemsByInvoiceIds(
            java.util.Collection<Integer> invoiceIds) {
        java.util.Map<Integer, List<PrescriptionItem>> result = new java.util.LinkedHashMap<>();
        if (invoiceIds == null || invoiceIds.isEmpty()) return result;
        String placeholders = String.join(",", java.util.Collections.nCopies(invoiceIds.size(), "?"));
        String sql = "SELECT i.id AS invoice_id, pi.id, pi.prescription_id, pi.medicine_id, "
                + "pi.quantity, pi.dosage, m.name AS medicine_name, m.unit AS medicine_unit, "
                + "m.price AS medicine_price, mc.category_name AS medicine_category "
                + "FROM invoices i "
                + "JOIN medical_records mr ON mr.appointment_id = i.appointment_id "
                + "JOIN prescriptions p ON p.medical_record_id = mr.id "
                + "JOIN prescription_items pi ON pi.prescription_id = p.id "
                + "JOIN medicines m ON m.id = pi.medicine_id "
                + "LEFT JOIN medicine_categories mc ON mc.id = m.category_id "
                + "WHERE i.id IN (" + placeholders + ") ORDER BY i.id, pi.id";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (Integer invoiceId : invoiceIds) ps.setInt(index++, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
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
                    item.setPrice(rs.getBigDecimal("medicine_price"));
                    result.computeIfAbsent(rs.getInt("invoice_id"), key -> new ArrayList<>()).add(item);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể tải chi tiết hóa đơn thuốc", e);
        }
        return result;
    }

    private List<PrescriptionItem> getItemsByPrescriptionId(int prescriptionId, Connection conn)
            throws SQLException {
        String sql =
            "SELECT pi.id, pi.prescription_id, pi.medicine_id, pi.quantity, pi.dosage, " +
            "       m.name AS medicine_name, m.unit AS medicine_unit, m.price AS medicine_price, " +
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
                item.setPrice(rs.getBigDecimal("medicine_price"));
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

    public boolean replaceItems(Connection conn, int prescriptionId, List<PrescriptionItem> items)
            throws SQLException {
        String deleteSql = "DELETE FROM prescription_items WHERE prescription_id = ?";
        String insertSql =
            "INSERT INTO prescription_items (prescription_id, medicine_id, quantity, dosage) " +
            "VALUES (?, ?, ?, ?)";
        try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
            del.setInt(1, prescriptionId);
            del.executeUpdate();
        }
        if (items == null || items.isEmpty()) return true;
        try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
            for (PrescriptionItem item : items) {
                ins.setInt(1, prescriptionId);
                ins.setInt(2, item.getMedicineId());
                ins.setInt(3, item.getQuantity());
                ins.setString(4, item.getDosage());
                ins.addBatch();
            }
            int[] counts = ins.executeBatch();
            for (int count : counts) {
                if (count == Statement.EXECUTE_FAILED) return false;
            }
            return true;
        }
    }

    /**
     * Bác sĩ chỉ lưu chỉ định chuyên môn. Khi đơn còn ở giai đoạn soạn/chốt,
     * mọi quyết định mua phải quay về Pending và không được sinh hóa đơn.
     */
    public void resetPurchaseDecision(Connection conn, int prescriptionId) throws SQLException {
        String sql = "UPDATE prescriptions SET purchase_decision = 'Pending', "
                + "purchase_decided_at = NULL, purchase_decided_by = NULL "
                + "WHERE id = ? AND purchase_decision = 'Pending'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            ps.executeUpdate();
        }
    }

    /**
     * Danh sách đơn thuốc bệnh nhân cần quyết định hoặc đã từ chối mua tại
     * phòng khám. Đơn đã chọn mua được theo dõi qua hóa đơn.
     */
    public List<Prescription> getPatientPurchaseChoices(int userId) {
        String sql =
            "SELECT p.id, p.medical_record_id, p.prescription_code, p.status, p.created_at, " +
            "       p.purchase_decision, p.purchase_decided_at, p.purchase_decided_by, " +
            "       a.id AS appointment_id, d.full_name AS doctor_name, " +
            "       COALESCE(u.full_name, pt.full_name) AS patient_name, " +
            "       CONVERT(varchar, a.appointment_date, 23) AS appointment_date, " +
            "       SUM(CAST(pi.quantity AS decimal(18,2)) * ISNULL(m.price, 0)) AS total_amount " +
            "FROM prescriptions p " +
            "JOIN medical_records mr ON mr.id = p.medical_record_id " +
            "JOIN appointments a ON a.id = mr.appointment_id " +
            "JOIN patients pt ON pt.id = a.patient_id " +
            "LEFT JOIN users u ON u.id = pt.user_id " +
            "LEFT JOIN doctors d ON d.id = a.doctor_id " +
            "JOIN prescription_items pi ON pi.prescription_id = p.id " +
            "JOIN medicines m ON m.id = pi.medicine_id " +
            "WHERE pt.user_id = ? AND p.status = 'issued' " +
            "  AND p.purchase_decision IN ('Pending', 'Declined') " +
            "GROUP BY p.id, p.medical_record_id, p.prescription_code, p.status, p.created_at, " +
            "         p.purchase_decision, p.purchase_decided_at, p.purchase_decided_by, " +
            "         a.id, d.full_name, COALESCE(u.full_name, pt.full_name), a.appointment_date " +
            "ORDER BY p.id DESC";
        List<Prescription> result = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Prescription p = mapPrescription(rs);
                    p.setTotalAmount(rs.getBigDecimal("total_amount"));
                    result.add(p);
                }
            }
            for (Prescription prescription : result) {
                prescription.setItems(
                        getItemsByPrescriptionId(prescription.getId(), conn));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể tải lựa chọn mua thuốc", e);
        }
        return result;
    }

    /**
     * Cho phép đánh giá khi không có đơn thuốc, đơn không có thuốc, bệnh nhân
     * đã từ chối mua, hoặc hóa đơn của lựa chọn mua đã thanh toán.
     */
    public boolean isPurchaseResolvedForReview(int appointmentId) {
        String sql =
            "SELECT TOP 1 p.purchase_decision, " +
            "       CASE WHEN EXISTS (SELECT 1 FROM prescription_items pi WHERE pi.prescription_id = p.id) " +
            "            THEN 1 ELSE 0 END AS has_items, " +
            "       CASE WHEN EXISTS (SELECT 1 FROM invoices i WHERE i.appointment_id = a.id " +
            "                 AND UPPER(i.invoice_type) = 'PRESCRIPTION' AND i.status = 'Paid') " +
            "            THEN 1 ELSE 0 END AS is_paid " +
            "FROM appointments a " +
            "LEFT JOIN medical_records mr ON mr.appointment_id = a.id " +
            "LEFT JOIN prescriptions p ON p.medical_record_id = mr.id " +
            "WHERE a.id = ? ORDER BY p.id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next() || rs.getString("purchase_decision") == null) return true;
                if (!rs.getBoolean("has_items")) return true;
                String decision = rs.getString("purchase_decision");
                return "Declined".equalsIgnoreCase(decision)
                        || ("Accepted".equalsIgnoreCase(decision) && rs.getBoolean("is_paid"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể kiểm tra quyết định mua thuốc", e);
        }
    }

    /** Batch: kiểm tra purchase resolved cho nhiều appointment một lần. */
    public java.util.Map<Integer, Boolean> batchIsPurchaseResolved(java.util.List<Integer> apptIds) {
        java.util.Map<Integer, Boolean> result = new java.util.HashMap<>();
        if (apptIds == null || apptIds.isEmpty()) return result;
        for (int id : apptIds) result.put(id, true);

        StringBuilder ph = new StringBuilder();
        for (int i = 0; i < apptIds.size(); i++) { if (i > 0) ph.append(","); ph.append("?"); }
        String sql = "SELECT a.id, p.purchase_decision, "
                + "CASE WHEN EXISTS (SELECT 1 FROM prescription_items pi WHERE pi.prescription_id = p.id) THEN 1 ELSE 0 END AS has_items, "
                + "CASE WHEN EXISTS (SELECT 1 FROM invoices i WHERE i.appointment_id = a.id AND UPPER(i.invoice_type)='PRESCRIPTION' AND i.status='Paid') THEN 1 ELSE 0 END AS is_paid "
                + "FROM appointments a LEFT JOIN medical_records mr ON mr.appointment_id = a.id "
                + "LEFT JOIN prescriptions p ON p.medical_record_id = mr.id "
                + "WHERE a.id IN (" + ph + ")";
        try (java.sql.Connection conn = DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < apptIds.size(); i++) ps.setInt(i + 1, apptIds.get(i));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int apptId = rs.getInt("id");
                    String dec = rs.getString("purchase_decision");
                    if (dec == null) { result.put(apptId, true); continue; }
                    if (!rs.getBoolean("has_items")) { result.put(apptId, true); continue; }
                    result.put(apptId, "Declined".equalsIgnoreCase(dec)
                            || ("Accepted".equalsIgnoreCase(dec) && rs.getBoolean("is_paid")));
                }
            }
        } catch (java.sql.SQLException e) {
            System.err.println("[PrescriptionDAO] batchIsPurchaseResolved ERROR: " + e.getMessage());
        }
        return result;
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
            "WHERE  m.is_active = 1 AND m.stock_quantity > 0 " +
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
        String sql = "SELECT COUNT(*) FROM medicines WHERE is_active = 1 AND stock_quantity > 0 AND id IN (" + placeholders + ")";
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
        p.setPurchaseDecision(rs.getString("purchase_decision"));
        Timestamp decidedAt = rs.getTimestamp("purchase_decided_at");
        if (decidedAt != null) p.setPurchaseDecidedAt(decidedAt.toLocalDateTime());
        int decidedBy = rs.getInt("purchase_decided_by");
        if (!rs.wasNull()) p.setPurchaseDecidedBy(decidedBy);
        p.setPatientName(rs.getString("patient_name"));
        p.setAppointmentDate(rs.getString("appointment_date"));
        p.setAppointmentId(rs.getInt("appointment_id"));
        p.setDoctorName(rs.getString("doctor_name"));
        return p;
    }
}
