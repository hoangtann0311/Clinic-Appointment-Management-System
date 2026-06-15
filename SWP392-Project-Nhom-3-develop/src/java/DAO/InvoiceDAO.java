/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import com.clinic.config.DatabaseConfig;

import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author ADMIN
 */
public class InvoiceDAO {

    public boolean createInvoice(
            int appointmentId,
            BigDecimal amount) {

        String sql
                = "INSERT INTO invoices "
                + "(appointment_id,total_amount,status) "
                + "VALUES(?,?,?)";

        try (Connection con
                = DatabaseConfig.getConnection(); PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);
            ps.setBigDecimal(2, amount);
            ps.setString(3, "Unpaid");

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean payInvoice(int invoiceId) {

        String sql
                = "UPDATE invoices "
                + "SET status=?, transaction_code=? "
                + "WHERE id=?";

        try (Connection con
                = DatabaseConfig.getConnection(); PreparedStatement ps
                = con.prepareStatement(sql)) {
            ps.setString(1, "Paid");
            ps.setString(
                    2,
                    "TXN" + System.currentTimeMillis());

            ps.setInt(3, invoiceId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
