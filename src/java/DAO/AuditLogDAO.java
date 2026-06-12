package com.clinic.dao;

import com.clinic.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class AuditLogDAO {

    public void logAction(String action, String actor, String tableName, String oldValue, String newValue) {
        String sql = "INSERT INTO audit_logs " +
                "(user_id, action, table_name, old_value, new_value, ip_address, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setNull(1, java.sql.Types.INTEGER);
            ps.setString(2, action);
            ps.setString(3, tableName);
            ps.setString(4, oldValue);
            ps.setString(5, newValue);
            ps.setString(6, actor);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}