package com.clinic.service;

import com.clinic.config.DatabaseConfig;
import com.clinic.utils.AuditUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Xử lý quyết định mua thuốc tách biệt với chỉ định chuyên môn của bác sĩ.
 */
public class PrescriptionPurchaseService {

    public DecisionResult decide(int userId, int prescriptionId, String requestedDecision,
                                 String ipAddress) {
        String decision = normalizeDecision(requestedDecision);

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                LockedPrescription prescription = lockOwnedPrescription(
                        conn, userId, prescriptionId);
                if (prescription == null) {
                    throw new IllegalArgumentException(
                            "Không tìm thấy đơn thuốc hoặc bạn không có quyền thao tác.");
                }
                if (!"issued".equalsIgnoreCase(prescription.status)) {
                    throw new IllegalArgumentException(
                            "Đơn thuốc chưa được bác sĩ phát hành.");
                }
                if (!"Pending".equalsIgnoreCase(prescription.purchaseDecision)) {
                    throw new IllegalArgumentException(
                            "Bạn đã xác nhận lựa chọn cho đơn thuốc này trước đó.");
                }

                PrescriptionAmount amount = loadAmountAndStock(conn, prescriptionId);
                if (amount.itemCount <= 0 || amount.total.signum() <= 0) {
                    throw new IllegalArgumentException(
                            "Đơn thuốc không có thuốc hợp lệ để thực hiện lựa chọn.");
                }

                Integer invoiceId = null;
                if ("Accepted".equals(decision)) {
                    if (amount.insufficientItemCount > 0) {
                        throw new IllegalArgumentException(
                                "Một hoặc nhiều thuốc trong đơn hiện không đủ tồn kho. "
                                + "Vui lòng liên hệ phòng khám.");
                    }
                    ensureNoActivePrescriptionInvoice(conn, prescription.appointmentId);
                    invoiceId = insertInvoice(conn, prescription.appointmentId, amount.total);
                } else {
                    ensureNoSubmittedPrescriptionInvoice(
                            conn, prescription.appointmentId);
                    cancelLegacyUnpaidInvoice(conn, prescription.appointmentId);
                }

                if (!saveDecision(conn, prescriptionId, userId, decision)) {
                    throw new SQLException("PRESCRIPTION_DECISION_CONFLICT");
                }

                conn.commit();

                String action = "Accepted".equals(decision)
                        ? "Bệnh nhân chọn mua thuốc tại phòng khám"
                        : "Bệnh nhân chọn không mua thuốc tại phòng khám";
                AuditUtil.log(userId, action + " - đơn " + prescription.code,
                        "prescriptions", "Pending", decision, ipAddress);

                return new DecisionResult(
                        prescription.appointmentId, prescriptionId, invoiceId, decision);
            } catch (IllegalArgumentException e) {
                conn.rollback();
                throw e;
            } catch (SQLException e) {
                conn.rollback();
                throw new IllegalStateException(
                        "Không thể lưu lựa chọn mua thuốc một cách an toàn.", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể kết nối cơ sở dữ liệu.", e);
        }
    }

    private String normalizeDecision(String value) {
        if ("buy".equalsIgnoreCase(value) || "Accepted".equalsIgnoreCase(value)) {
            return "Accepted";
        }
        if ("decline".equalsIgnoreCase(value) || "Declined".equalsIgnoreCase(value)) {
            return "Declined";
        }
        throw new IllegalArgumentException("Lựa chọn mua thuốc không hợp lệ.");
    }

    private LockedPrescription lockOwnedPrescription(Connection conn, int userId,
                                                       int prescriptionId) throws SQLException {
        String sql = "SELECT p.status, p.purchase_decision, p.prescription_code, a.id AS appointment_id "
                + "FROM prescriptions p WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN medical_records mr ON mr.id = p.medical_record_id "
                + "JOIN appointments a ON a.id = mr.appointment_id "
                + "JOIN patients pt ON pt.id = a.patient_id "
                + "WHERE p.id = ? AND pt.user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new LockedPrescription(
                        rs.getString("status"),
                        rs.getString("purchase_decision"),
                        rs.getString("prescription_code"),
                        rs.getInt("appointment_id"));
            }
        }
    }

    private PrescriptionAmount loadAmountAndStock(Connection conn, int prescriptionId)
            throws SQLException {
        String sql = "SELECT COUNT(*) AS item_count, "
                + "COALESCE(SUM(CAST(pi.quantity AS decimal(18,2)) * ISNULL(m.price, 0)), 0) AS total, "
                + "SUM(CASE WHEN ISNULL(m.is_active, 0) = 0 "
                + "          OR ISNULL(m.stock_quantity, 0) < pi.quantity THEN 1 ELSE 0 END) AS insufficient_count "
                + "FROM prescription_items pi "
                + "JOIN medicines m ON m.id = pi.medicine_id "
                + "WHERE pi.prescription_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prescriptionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return new PrescriptionAmount(0, BigDecimal.ZERO, 0);
                return new PrescriptionAmount(
                        rs.getInt("item_count"),
                        rs.getBigDecimal("total"),
                        rs.getInt("insufficient_count"));
            }
        }
    }

    private void ensureNoActivePrescriptionInvoice(Connection conn, int appointmentId)
            throws SQLException {
        String sql = "SELECT TOP 1 status FROM invoices WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRESCRIPTION' "
                + "AND status IN ('Unpaid', 'PendingConfirmation', 'Paid')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new IllegalArgumentException(
                            "Đơn thuốc này đã có hóa đơn đang được xử lý.");
                }
            }
        }
    }

    private int insertInvoice(Connection conn, int appointmentId, BigDecimal amount)
            throws SQLException {
        String sql = "INSERT INTO invoices "
                + "(appointment_id, total_amount, status, invoice_type, created_at) "
                + "VALUES (?, ?, 'Unpaid', 'PRESCRIPTION', GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(
                sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, appointmentId);
            ps.setBigDecimal(2, amount);
            if (ps.executeUpdate() != 1) throw new SQLException("INVOICE_CREATE_FAILED");
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("INVOICE_ID_MISSING");
                return keys.getInt(1);
            }
        }
    }

    private void ensureNoSubmittedPrescriptionInvoice(Connection conn,
                                                       int appointmentId)
            throws SQLException {
        String sql = "SELECT TOP 1 status FROM invoices WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRESCRIPTION' "
                + "AND status IN ('PendingConfirmation', 'Paid')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new IllegalArgumentException(
                            "Hóa đơn thuốc đã được gửi thanh toán nên không thể chuyển sang không mua.");
                }
            }
        }
    }

    private void cancelLegacyUnpaidInvoice(Connection conn, int appointmentId)
            throws SQLException {
        String sql = "UPDATE invoices SET status = 'Cancelled' "
                + "WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRESCRIPTION' "
                + "AND status = 'Unpaid'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.executeUpdate();
        }
    }

    private boolean saveDecision(Connection conn, int prescriptionId, int userId,
                                 String decision) throws SQLException {
        String sql = "UPDATE prescriptions SET purchase_decision = ?, "
                + "purchase_decided_at = GETDATE(), purchase_decided_by = ? "
                + "WHERE id = ? AND purchase_decision = 'Pending'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, decision);
            ps.setInt(2, userId);
            ps.setInt(3, prescriptionId);
            return ps.executeUpdate() == 1;
        }
    }

    private static final class LockedPrescription {
        private final String status;
        private final String purchaseDecision;
        private final String code;
        private final int appointmentId;

        private LockedPrescription(String status, String purchaseDecision,
                                   String code, int appointmentId) {
            this.status = status;
            this.purchaseDecision = purchaseDecision;
            this.code = code;
            this.appointmentId = appointmentId;
        }
    }

    private static final class PrescriptionAmount {
        private final int itemCount;
        private final BigDecimal total;
        private final int insufficientItemCount;

        private PrescriptionAmount(int itemCount, BigDecimal total,
                                   int insufficientItemCount) {
            this.itemCount = itemCount;
            this.total = total != null ? total : BigDecimal.ZERO;
            this.insufficientItemCount = insufficientItemCount;
        }
    }

    public static final class DecisionResult {
        private final int appointmentId;
        private final int prescriptionId;
        private final Integer invoiceId;
        private final String decision;

        private DecisionResult(int appointmentId, int prescriptionId,
                               Integer invoiceId, String decision) {
            this.appointmentId = appointmentId;
            this.prescriptionId = prescriptionId;
            this.invoiceId = invoiceId;
            this.decision = decision;
        }

        public int getAppointmentId() { return appointmentId; }
        public int getPrescriptionId() { return prescriptionId; }
        public Integer getInvoiceId() { return invoiceId; }
        public String getDecision() { return decision; }
    }
}
