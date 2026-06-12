package com.clinic.dao;

import com.clinic.config.DBContext;
import com.clinic.model.ServiceItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {

    public ServiceDAO() {
    }

    public List<ServiceItem> getAllServices() {
        List<ServiceItem> list = new ArrayList<>();
        String sql = "SELECT id, service_name, price, duration_mins, requires_fasting, requires_full_bladder, required_room_type FROM services";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ServiceItem(
                        rs.getInt("id"),
                        rs.getString("service_name"),
                        rs.getDouble("price"),
                        rs.getInt("duration_mins"),
                        rs.getBoolean("requires_fasting"),
                        rs.getBoolean("requires_full_bladder"),
                        rs.getString("required_room_type")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ServiceItem findServiceById(int id) {
        String sql = "SELECT id, service_name, price, duration_mins, requires_fasting, requires_full_bladder, required_room_type FROM services WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ServiceItem(
                            rs.getInt("id"),
                            rs.getString("service_name"),
                            rs.getDouble("price"),
                            rs.getInt("duration_mins"),
                            rs.getBoolean("requires_fasting"),
                            rs.getBoolean("requires_full_bladder"),
                            rs.getString("required_room_type")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
