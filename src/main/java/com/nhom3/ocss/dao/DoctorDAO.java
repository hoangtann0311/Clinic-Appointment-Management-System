package com.nhom3.ocss.dao;

import com.nhom3.ocss.listeners.DBContext;
import com.nhom3.ocss.models.Doctor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO {

    public DoctorDAO() {
    }

    public List<Doctor> getAllDoctors() {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT id, full_name, specialization, phone_number FROM doctors";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToDoctor(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Doctor findDoctorById(int id) {
        String sql = "SELECT id, full_name, specialization, phone_number FROM doctors WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToDoctor(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Doctor mapRowToDoctor(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String fullName = rs.getString("full_name");
        String specialization = rs.getString("specialization");
        
        // Map degrees, prices, and avatars dynamically based on doctor details
        String degree = "Bác sĩ Sản phụ khoa";
        int experienceYears = 5;
        double price = 150000;
        String avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";

        if (fullName != null) {
            if (fullName.contains("Phạm Trung Hiếu")) {
                degree = "Bác sĩ Trưởng khoa (CKII)";
                experienceYears = 12;
                price = 200000;
                avatar = "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop";
            } else if (fullName.contains("Nguyễn Thị Mai")) {
                degree = "Thạc sĩ, Bác sĩ Nội trú";
                experienceYears = 15;
                price = 300000;
                avatar = "https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=150&auto=format&fit=crop";
            } else if (fullName.contains("Trần Văn Khoa")) {
                degree = "Bác sĩ Chuyên khoa I";
                experienceYears = 8;
                price = 150000;
                avatar = "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=150&auto=format&fit=crop";
            }
        }

        return new Doctor(id, fullName, specialization, degree, experienceYears, price, avatar);
    }
}
