package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Invoice;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng invoices.
 */
public class InvoiceDAO {

    private static final String BASE_SELECT = 
        "SELECT i.*, "
        + "  COALESCE(u_pat.full_name, pt.full_name) AS patient_name, "
        + "  pt.phone_number AS patient_phone, "
        + "  doc.full_name AS doctor_name, "
        + "  CONVERT(varchar, a.appointment_date, 23) AS appointment_date, "
        + "  COALESCE(s.service_name, (SELECT STRING_AGG(sa.service_name, N', ') FROM appointment_services aps JOIN services sa ON sa.id = aps.service_id WHERE aps.appointment_id = a.id), N'Khám thai định kỳ') AS service_name, "
        + "  u_staff.full_name AS confirmed_by_name "
        + "FROM invoices i "
        + "LEFT JOIN appointments a ON i.appointment_id = a.id "
        + "LEFT JOIN patients pt ON a.patient_id = pt.id "
        + "LEFT JOIN users u_pat ON pt.user_id = u_pat.id "
        + "LEFT JOIN doctors doc ON a.doctor_id = doc.id "
        + "LEFT JOIN services s ON a.service_id = s.id "
        + "LEFT JOIN users u_staff ON i.confirmed_by = u_staff.id ";

    public List<Invoice> getAllInvoices(int offset, int pageSize, String search, String status, String type, String date) {
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append(" WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (COALESCE(u_pat.full_name, pt.full_name) LIKE ? OR pt.phone_number LIKE ? OR i.transaction_code LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND i.status = ? ");
            params.add(status.trim());
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND i.invoice_type = ? ");
            params.add(type.trim());
        }

        if (date != null && !date.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ? ");
            params.add(java.sql.Date.valueOf(date.trim()));
        }

        sql.append(" ORDER BY i.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");
        params.add(offset);
        params.add(pageSize);

        List<Invoice> list = new ArrayList<>();
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
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] getAllInvoices ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    public int countAllInvoices(String search, String status, String type, String date) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM invoices i ")
                .append("LEFT JOIN appointments a ON i.appointment_id = a.id ")
                .append("LEFT JOIN patients pt ON a.patient_id = pt.id ")
                .append("LEFT JOIN users u_pat ON pt.user_id = u_pat.id ")
                .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (COALESCE(u_pat.full_name, pt.full_name) LIKE ? OR pt.phone_number LIKE ? OR i.transaction_code LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND i.status = ? ");
            params.add(status.trim());
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND i.invoice_type = ? ");
            params.add(type.trim());
        }

        if (date != null && !date.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ? ");
            params.add(java.sql.Date.valueOf(date.trim()));
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else if (p instanceof java.sql.Date) {
                    ps.setDate(i + 1, (java.sql.Date) p);
                }
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] countAllInvoices ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    public int countPendingConfirmation() {
        String sql = "SELECT COUNT(*) FROM invoices WHERE status = 'PendingConfirmation'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] countPendingConfirmation ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    public Invoice getById(int id) {
        String sql = BASE_SELECT + " WHERE i.id = ? ";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] getById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    public Invoice getByAppointmentIdAndType(int appointmentId, String type) {
        String sql = BASE_SELECT + " WHERE i.appointment_id = ? AND i.invoice_type = ? ORDER BY i.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            ps.setString(2, type);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] getByAppointmentIdAndType ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    public List<Invoice> getByAppointmentId(int appointmentId) {
        String sql = BASE_SELECT + " WHERE i.appointment_id = ? ORDER BY i.id DESC";
        List<Invoice> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] getByAppointmentId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    public boolean updatePaymentStatus(Connection conn, int id, String status, String paymentMethod, String transactionCode, String paymentNote, int confirmedBy, Timestamp confirmedAt) throws SQLException {
        String sql = "UPDATE invoices SET status = ?, payment_method = ?, transaction_code = ?, payment_note = ?, confirmed_by = ?, confirmed_at = ? "
                + "WHERE id = ? AND status IN ('Unpaid', 'PendingConfirmation')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, paymentMethod);
            ps.setString(3, transactionCode);
            ps.setString(4, paymentNote);
            ps.setInt(5, confirmedBy);
            ps.setTimestamp(6, confirmedAt);
            ps.setInt(7, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePaymentStatus(int id, String status, String paymentMethod, String transactionCode, String paymentNote, int confirmedBy, Timestamp confirmedAt) {
        // Atomic state transition: a receipt can only be approved or rejected
        // once, from an unpaid/pending-verification state.
        String sql = "UPDATE invoices SET status = ?, payment_method = ?, transaction_code = ?, payment_note = ?, confirmed_by = ?, confirmed_at = ? "
                + "WHERE id = ? AND status IN ('Unpaid', 'PendingConfirmation')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, paymentMethod);
            ps.setString(3, transactionCode);
            ps.setString(4, paymentNote);
            ps.setInt(5, confirmedBy);
            ps.setTimestamp(6, confirmedAt);
            ps.setInt(7, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] updatePaymentStatus ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    public int createOrAppendPostExamServiceInvoice(Connection conn, int appointmentId, int serviceId, java.math.BigDecimal price) throws SQLException {
        String selectSql = "SELECT id, total_amount, status FROM invoices WITH (UPDLOCK, HOLDLOCK) WHERE appointment_id = ? AND UPPER(invoice_type) = 'POST_EXAM'";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int existingId = rs.getInt("id");
                    java.math.BigDecimal curAmt = rs.getBigDecimal("total_amount");
                    java.math.BigDecimal newAmt = curAmt != null ? curAmt.add(price != null ? price : java.math.BigDecimal.ZERO) : price;
                    String updateSql = "UPDATE invoices SET total_amount = ? WHERE id = ?";
                    try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                        ups.setBigDecimal(1, newAmt);
                        ups.setInt(2, existingId);
                        ups.executeUpdate();
                    }
                    return existingId;
                }
            }
        }
        String insertSql = "INSERT INTO invoices (appointment_id, total_amount, status, invoice_type, created_at) VALUES (?, ?, 'Unpaid', 'POST_EXAM', GETDATE())";
        try (PreparedStatement ips = conn.prepareStatement(insertSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ips.setInt(1, appointmentId);
            ips.setBigDecimal(2, price);
            ips.executeUpdate();
            try (ResultSet keys = ips.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public int createOrAppendPostExamServiceInvoice(int appointmentId, int serviceId, java.math.BigDecimal price) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return createOrAppendPostExamServiceInvoice(conn, appointmentId, serviceId, price);
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] createOrAppendPostExamServiceInvoice ERROR: " + e.getMessage());
            return -1;
        }
    }

    public boolean submitPaymentDetails(int id, String paymentMethod, String transactionCode, String status) {
        String sql = "UPDATE invoices SET payment_method = ?, transaction_code = ?, status = ? "
                + "WHERE id = ? AND (status = 'Unpaid' OR (status = 'Rejected' AND invoice_type <> 'PRE_EXAM'))";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, paymentMethod);
            ps.setString(2, transactionCode);
            ps.setString(3, status);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] submitPaymentDetails ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Giống submitPaymentDetails nhưng lưu kèm đường dẫn ảnh minh chứng chuyển khoản
     * (bệnh nhân tải ảnh lên thay vì tự gõ mã giao dịch).
     */
    public boolean submitPaymentDetailsWithProof(int id, String paymentMethod, String transactionCode,
                                                  String proofImagePath, String status) {
        String sql = "UPDATE invoices SET payment_method = ?, transaction_code = ?, proof_image_path = ?, status = ? " +
                     "WHERE id = ? AND (status = 'Unpaid' OR (status = 'Rejected' AND invoice_type <> 'PRE_EXAM'))";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, paymentMethod);
            ps.setString(2, transactionCode);
            ps.setString(3, proofImagePath);
            ps.setString(4, status);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] submitPaymentDetailsWithProof ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Cộng dồn thêm số tiền vào hóa đơn đã tồn tại.
     * Dùng khi bác sĩ chỉ định thêm dịch vụ sau khi hóa đơn POST_EXAM đã được tạo.
     */
    public boolean addAmountToInvoice(int invoiceId, java.math.BigDecimal amount) {
        String sql = "UPDATE invoices SET total_amount = total_amount + ? WHERE id = ? AND status <> 'Paid'";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBigDecimal(1, amount);
            ps.setInt(2, invoiceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] addAmountToInvoice ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    public int insert(Invoice inv) {
        String sql = "INSERT INTO invoices (appointment_id, total_amount, status, transaction_code, invoice_type, payment_method, confirmed_by, confirmed_at, payment_note, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            if (inv.getAppointmentId() != null) ps.setInt(1, inv.getAppointmentId()); else ps.setNull(1, Types.INTEGER);
            ps.setBigDecimal(2, inv.getTotalAmount());
            ps.setString(3, inv.getStatus());
            ps.setString(4, inv.getTransactionCode());
            ps.setString(5, inv.getInvoiceType());
            ps.setString(6, inv.getPaymentMethod());
            if (inv.getConfirmedBy() != null) ps.setInt(7, inv.getConfirmedBy()); else ps.setNull(7, Types.INTEGER);
            ps.setTimestamp(8, inv.getConfirmedAt());
            ps.setString(9, inv.getPaymentNote());
            if (inv.getCreatedAt() != null) {
                ps.setTimestamp(10, inv.getCreatedAt());
            } else {
                ps.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
            }

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] insert ERROR: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }

    /**
     * Tạo mới hoặc cập nhật hóa đơn thuốc (PRESCRIPTION) cho một lịch hẹn.
     * - Nếu đã tồn tại hóa đơn PRESCRIPTION chưa thanh toán → cập nhật totalAmount.
     * - Nếu chưa có → tạo hóa đơn mới với status = 'Unpaid'.
     * - Nếu đã Paid/DeclinedPurchase → không thay đổi (hóa đơn đã khóa).
     *
     * @param appointmentId ID của lịch hẹn
     * @param totalAmount   Tổng tiền đơn thuốc
     * @return ID của hóa đơn thuốc (mới tạo hoặc đã có), -1 nếu thất bại
     */
    public int upsertPrescriptionInvoice(int appointmentId, java.math.BigDecimal totalAmount) {
        // Kiểm tra hóa đơn thuốc đã tồn tại chưa
        String selectSql = "SELECT id, status FROM invoices WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRESCRIPTION'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(selectSql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int existingId = rs.getInt("id");
                String existingStatus = rs.getString("status");
                // Chỉ cập nhật nếu hóa đơn chưa được khóa (Paid hoặc DeclinedPurchase)
                if (!"Paid".equalsIgnoreCase(existingStatus) && !"DeclinedPurchase".equalsIgnoreCase(existingStatus)) {
                    closeResources(null, ps, rs);
                    ps = conn.prepareStatement("UPDATE invoices SET total_amount = ? WHERE id = ?");
                    ps.setBigDecimal(1, totalAmount);
                    ps.setInt(2, existingId);
                    ps.executeUpdate();
                }
                return existingId;
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] upsertPrescriptionInvoice SELECT ERROR: " + e.getMessage());
        } finally {
            closeResources(null, ps, rs);
        }

        // Chưa có → tạo mới
        String insertSql = "INSERT INTO invoices (appointment_id, total_amount, status, invoice_type, created_at) VALUES (?, ?, 'Unpaid', 'PRESCRIPTION', GETDATE())";
        try {
            ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, appointmentId);
            ps.setBigDecimal(2, totalAmount);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] upsertPrescriptionInvoice INSERT ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }

    /**
     * Đánh dấu hóa đơn thuốc là DeclinedPurchase (Bệnh nhân từ chối mua thuốc).
     * Chỉ áp dụng cho hóa đơn loại PRESCRIPTION đang ở trạng thái Unpaid/PendingConfirmation.
     *
     * @param invoiceId   ID hóa đơn cần từ chối
     * @param confirmedBy ID nhân viên xác nhận từ chối
     * @return true nếu cập nhật thành công
     */
    public boolean declinePrescriptionInvoice(int invoiceId, int confirmedBy) {
        String sql = "UPDATE invoices SET status = 'DeclinedPurchase', confirmed_by = ?, confirmed_at = GETDATE() "
                   + "WHERE id = ? AND UPPER(invoice_type) = 'PRESCRIPTION' "
                   + "AND status NOT IN ('Paid', 'DeclinedPurchase')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, confirmedBy);
            ps.setInt(2, invoiceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] declinePrescriptionInvoice ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Kiểm tra xem hóa đơn thuốc (PRESCRIPTION) của cuộc hẹn đã được thanh toán hoặc từ chối mua hay chưa (BR-31, BR-32).
     * Nếu không có hóa đơn thuốc cho cuộc hẹn này, trả về true.
     *
     * @param appointmentId ID cuộc hẹn
     * @return true nếu hóa đơn thuốc đã Paid/DeclinedPurchase hoặc không có hóa đơn thuốc.
     */
    public boolean isPrescriptionPaidOrDeclined(int appointmentId) {
        String sql = "SELECT status FROM invoices WHERE appointment_id = ? AND UPPER(invoice_type) = 'PRESCRIPTION'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String status = rs.getString("status");
                return "Paid".equalsIgnoreCase(status) || "DeclinedPurchase".equalsIgnoreCase(status);
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] isPrescriptionPaidOrDeclined ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return true;
    }

    public List<Invoice> getInvoicesByPatientUserId(int userId) {
        String sql = BASE_SELECT + " WHERE pt.user_id = ? ORDER BY i.id DESC";
        List<Invoice> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[InvoiceDAO] getInvoicesByPatientUserId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }


    private Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getInt("id"));
        
        int appointmentId = rs.getInt("appointment_id");
        inv.setAppointmentId(rs.wasNull() ? null : appointmentId);
        
        inv.setTotalAmount(rs.getBigDecimal("total_amount"));
        inv.setStatus(rs.getString("status"));
        inv.setTransactionCode(rs.getString("transaction_code"));
        inv.setInvoiceType(rs.getString("invoice_type"));
        inv.setPaymentMethod(rs.getString("payment_method"));
        
        int confirmedBy = rs.getInt("confirmed_by");
        inv.setConfirmedBy(rs.wasNull() ? null : confirmedBy);
        
        inv.setConfirmedAt(rs.getTimestamp("confirmed_at"));
        inv.setPaymentNote(rs.getString("payment_note"));
        inv.setCreatedAt(rs.getTimestamp("created_at"));
        try { inv.setProofImagePath(rs.getString("proof_image_path")); } catch (SQLException ignore) {}

        // Transient
        inv.setPatientName(rs.getString("patient_name"));
        inv.setPatientPhone(rs.getString("patient_phone"));
        inv.setDoctorName(rs.getString("doctor_name"));
        inv.setAppointmentDate(rs.getString("appointment_date"));
        inv.setServiceName(rs.getString("service_name"));
        inv.setConfirmedByName(rs.getString("confirmed_by_name"));

        return inv;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
