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
        + "  u_pat.full_name AS patient_name, "
        + "  u_pat.phone AS patient_phone, "
        + "  doc.full_name AS doctor_name, "
        + "  CONVERT(varchar, a.appointment_date, 23) AS appointment_date, "
        + "  s.service_name, "
        + "  u_staff.full_name AS confirmed_by_name "
        + "FROM invoices i "
        + "LEFT JOIN appointments a ON i.appointment_id = a.id "
        + "LEFT JOIN users u_pat ON a.patient_id = u_pat.id "
        + "LEFT JOIN doctors doc ON a.doctor_id = doc.id "
        + "LEFT JOIN services s ON a.service_id = s.id "
        + "LEFT JOIN users u_staff ON i.confirmed_by = u_staff.id ";

    public List<Invoice> getAllInvoices(int offset, int pageSize, String search, String status, String type, String date) {
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append(" WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u_pat.full_name LIKE ? OR u_pat.phone LIKE ? OR i.transaction_code LIKE ?) ");
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
                .append("LEFT JOIN users u_pat ON a.patient_id = u_pat.id ")
                .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u_pat.full_name LIKE ? OR u_pat.phone LIKE ? OR i.transaction_code LIKE ?) ");
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
        String sql = BASE_SELECT + " WHERE i.appointment_id = ? AND i.invoice_type = ? ";
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

    public boolean updatePaymentStatus(int id, String status, String paymentMethod, String transactionCode, String paymentNote, int confirmedBy, Timestamp confirmedAt) {
        String sql = "UPDATE invoices SET status = ?, payment_method = ?, transaction_code = ?, payment_note = ?, confirmed_by = ?, confirmed_at = ? WHERE id = ? ";
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
