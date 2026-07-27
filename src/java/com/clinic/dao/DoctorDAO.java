package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.utils.EncryptionUtil;

import com.clinic.model.Doctor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng doctors — tra cứu thông tin bác sĩ.
 */
public class DoctorDAO {

    public DoctorDAO() {
    }

    /**
     * Lấy tất cả bác sĩ, sắp xếp theo tên. (Bác sĩ dashboard / manager)
     */
    public List<Doctor> findAll() {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number "
                   + "FROM doctors d ORDER BY d.full_name";

        List<Doctor> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findAll ERROR: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy tất cả bác sĩ. (Manual booking / receptionist)
     */
    /**
     * Lấy tất cả bác sĩ đang hoạt động (Active) có tài khoản hợp lệ. (Manual booking / receptionist)
     */
    public List<Doctor> getAllDoctors() {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.id, d.full_name, d.specialization, d.phone_number, d.degree, d.experience_years, d.avatar_url "
                   + "FROM doctors d "
                   + "INNER JOIN users u ON d.user_id = u.id "
                   + "WHERE u.status = 'Active' AND ISNULL(u.is_deleted, 0) = 0 "
                   + "ORDER BY d.full_name";
        try (Connection conn = DatabaseConfig.getConnection();
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

    public List<Doctor> getDoctorsPaginated(String keyword, int offset, int limit) {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.id, d.full_name, d.specialization, d.phone_number, d.degree, d.experience_years, d.avatar_url "
                   + "FROM doctors d "
                   + "INNER JOIN users u ON d.user_id = u.id "
                   + "WHERE u.status = 'Active' AND ISNULL(u.is_deleted, 0) = 0 ";
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (d.full_name LIKE ? OR d.specialization LIKE ?) ";
        }
        
        sql += "ORDER BY d.full_name OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToDoctor(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[DoctorDAO] getDoctorsPaginated ERROR: " + e.getMessage());
        }
        return list;
    }

    public int countDoctors(String keyword) {
        String sql = "SELECT COUNT(*) FROM doctors d "
                   + "INNER JOIN users u ON d.user_id = u.id "
                   + "WHERE u.status = 'Active' AND ISNULL(u.is_deleted, 0) = 0 ";
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (d.full_name LIKE ? OR d.specialization LIKE ?) ";
        }
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("[DoctorDAO] countDoctors ERROR: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Tìm bác sĩ theo id (Bác sĩ dashboard / manager)
     */
    public Doctor findById(int id) {
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number, d.degree, d.experience_years, d.bio, d.avatar_url "
                   + "FROM doctors d WHERE d.id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findById ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Tìm bác sĩ theo id có tài khoản hợp lệ (receptionist)
     */
    public Doctor findDoctorById(int id) {
        String sql = "SELECT d.id, d.full_name, d.specialization, d.phone_number, d.degree, d.experience_years, d.avatar_url "
                   + "FROM doctors d "
                   + "INNER JOIN users u ON d.user_id = u.id "
                   + "WHERE d.id = ? AND u.status = 'Active' AND ISNULL(u.is_deleted, 0) = 0";
        try (Connection conn = DatabaseConfig.getConnection();
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

    /**
     * Tìm bác sĩ theo user_id sử dụng connection từ transaction bên ngoài truyền vào.
     * Ném SQLException lên tầng caller để xử lý transaction an toàn.
     */
    public Doctor findByUserId(Connection conn, int userId) throws SQLException {
        String sql =
            "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number, " +
            "       d.degree, d.experience_years, d.bio, d.avatar_url " +
            "FROM doctors d " +
            "WHERE d.user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Tìm bác sĩ theo user_id (liên kết với bảng users).
     */
    public Doctor findByUserId(int userId) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return findByUserId(conn, userId);
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Lấy doctor_id từ user_id. Dùng chung cho tất cả servlet Doctor để tránh
     * duplicate code (8 servlet từng copy-paste cùng một SQL query).
     *
     * @return doctor id hoặc null nếu user chưa liên kết hồ sơ bác sĩ
     */
    public static Integer getDoctorIdByUserId(int userId) {
        String sql = "SELECT id FROM doctors WHERE user_id = ?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) {
            System.err.println("[DoctorDAO] getDoctorIdByUserId ERROR: " + e.getMessage());
        }
        return null;
    }

    public boolean updateProfile(Doctor d) {
        String sql =
            "UPDATE doctors SET full_name=?, specialization=?, phone_number=?, " +
            "  degree=?, experience_years=?, bio=?, avatar_url=? " +
            "WHERE id=?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getFullName());
            ps.setString(2, d.getSpecialization());
            ps.setString(3, d.getPhoneNumber());
            ps.setString(4, d.getDegree());
            if (d.getExperienceYears() >= 0) ps.setInt(5, d.getExperienceYears());
            else ps.setNull(5, java.sql.Types.INTEGER);
            ps.setString(6, d.getBio());
            ps.setString(7, d.getAvatarUrl());
            ps.setInt(8, d.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] updateProfile ERROR: " + e.getMessage());
        }
        return false;
    }

    /**
     * Ánh xạ ResultSet → Doctor (Bác sĩ / manager)
     */
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        d.setFullName(rs.getString("full_name"));
        d.setSpecialization(rs.getString("specialization"));
        d.setPhoneNumber(rs.getString("phone_number"));
        // Đọc các cột mới (nếu không tồn tại thì bỏ qua)
        try { d.setDegree(rs.getString("degree")); }         catch (SQLException ignored) {}
        try { d.setExperienceYears(rs.getInt("experience_years")); } catch (SQLException ignored) {}
        try { d.setBio(rs.getString("bio")); }               catch (SQLException ignored) {}
        try { d.setAvatarUrl(rs.getString("avatar_url")); }  catch (SQLException ignored) {}
        try { d.setEmail(rs.getString("email")); }           catch (SQLException ignored) {}
        return d;
    }

    /**
     * Ánh xạ ResultSet → Doctor (receptionist)
     */
    private Doctor mapRowToDoctor(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String fullName = rs.getString("full_name");
        String specialization = rs.getString("specialization");

        String degree = rs.getString("degree");
        if (degree == null || degree.isBlank()) degree = "Bác sĩ";

        int experienceYears = rs.getInt("experience_years"); // 0 nếu NULL hoặc chưa cập nhật
        String avatar = rs.getString("avatar_url"); // null nếu bác sĩ chưa upload ảnh — JSP tự hiện chữ cái đầu thay thế

        return new Doctor(id, fullName, specialization, degree, experienceYears, avatar);
    }

    /**
     * Thêm mới bác sĩ trong cùng 1 connection/transaction từ ngoài truyền vào.
     */
    public int insert(Connection conn, Doctor d) throws SQLException {
        String sql = "INSERT INTO doctors (user_id, full_name, phone_number, specialization, degree, experience_years) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getUserId());
            ps.setString(2, d.getFullName());
            ps.setString(3, d.getPhoneNumber());
            ps.setString(4, d.getSpecialization());
            ps.setString(5, d.getDegree() != null ? d.getDegree() : "Bác sĩ");
            if (d.getExperienceYears() >= 0) {
                ps.setInt(6, d.getExperienceYears());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Cập nhật hồ sơ bác sĩ theo user_id trong cùng transaction.
     */
    public boolean updateProfile(Connection conn, Doctor d) throws SQLException {
        String sql = "UPDATE doctors SET full_name=?, specialization=?, phone_number=?, degree=?, experience_years=? WHERE user_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getFullName());
            ps.setString(2, d.getSpecialization());
            ps.setString(3, d.getPhoneNumber());
            ps.setString(4, d.getDegree());
            if (d.getExperienceYears() >= 0) {
                ps.setInt(5, d.getExperienceYears());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setInt(6, d.getUserId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Kiểm tra Bác sĩ có cuộc hẹn chưa hoàn tất hoặc lịch làm việc hiện tại/tương lai không.
     * Ném SQLException lên tầng Service xử lý an toàn, không tự ý trả false khi database bị lỗi.
     */
    public boolean hasActiveWorkOrAppointments(Connection conn, int doctorId) throws SQLException {
        if (doctorId <= 0) return false;
        String apptSql = "SELECT 1 FROM appointments WHERE doctor_id = ? "
                       + "AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('PENDING', 'CONFIRMED', 'WAITING', 'INPROGRESS')";
        String schedSql = "SELECT 1 FROM doctor_schedules WHERE doctor_id = ? "
                        + "AND work_date >= CAST(GETDATE() AS DATE) "
                        + "AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('PENDING', 'APPROVED')";

        try (PreparedStatement ps1 = conn.prepareStatement(apptSql)) {
            ps1.setInt(1, doctorId);
            try (ResultSet rs1 = ps1.executeQuery()) {
                if (rs1.next()) return true;
            }
        }

        try (PreparedStatement ps2 = conn.prepareStatement(schedSql)) {
            ps2.setInt(1, doctorId);
            try (ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) return true;
            }
        }

        return false;
    }

    public boolean hasActiveWorkOrAppointments(int doctorId) throws SQLException {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return hasActiveWorkOrAppointments(conn, doctorId);
        }
    }

    /**
     * Thêm mới bác sĩ.
     */
    public int insert(Doctor d) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return insert(conn, d);
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] insert ERROR: " + e.getMessage());
        }
        return -1;
    }

    /**
     * Lấy danh sách tất cả bác sĩ (không lọc Active) kèm thông tin user
     * cho Manager xem danh sách (chỉ xem, không sửa/xóa).
     */
    public List<Doctor> findAllWithUserInfo(String keyword, int offset, int limit) {
        List<Doctor> list = new ArrayList<>();
        String decryptEmail = EncryptionUtil.decryptEmailSql("u.email");
        String decryptPhone = EncryptionUtil.decryptPhoneSql("u.phone");
        StringBuilder sql = new StringBuilder(
            "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number, "
            + "d.degree, d.experience_years, d.bio, d.avatar_url, "
            + decryptEmail + " AS user_email, u.username, u.status AS user_status, "
            + decryptPhone + " AS user_phone "
            + "FROM doctors d "
            + "LEFT JOIN users u ON d.user_id = u.id "
            + "WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (d.full_name LIKE ? OR d.specialization LIKE ? "
                     + "OR u.email LIKE ? OR d.phone_number LIKE ?) ");
        }

        sql.append("ORDER BY d.full_name OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
                ps.setString(paramIndex++, like);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowWithUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findAllWithUserInfo ERROR: " + e.getMessage());
        }
        return list;
    }

    /**
     * Đếm tổng số bác sĩ (cho phân trang Manager).
     */
    public int countAllDoctors(String keyword) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM doctors d "
            + "LEFT JOIN users u ON d.user_id = u.id WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (d.full_name LIKE ? OR d.specialization LIKE ? "
                     + "OR u.email LIKE ? OR d.phone_number LIKE ?) ");
        }

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] countAllDoctors ERROR: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Lấy chi tiết bác sĩ kèm thông tin user (email, status, phone)
     * cho Manager xem chi tiết (chỉ xem).
     */
    public Doctor findByIdWithUserInfo(int id) {
        String decryptEmail = EncryptionUtil.decryptEmailSql("u.email");
        String decryptPhone = EncryptionUtil.decryptPhoneSql("u.phone");
        String sql = "SELECT d.id, d.user_id, d.full_name, d.specialization, d.phone_number, "
                   + "d.degree, d.experience_years, d.bio, d.avatar_url, "
                   + decryptEmail + " AS user_email, u.username, u.status AS user_status, "
                   + decryptPhone + " AS user_phone "
                   + "FROM doctors d "
                   + "LEFT JOIN users u ON d.user_id = u.id "
                   + "WHERE d.id = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowWithUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DoctorDAO] findByIdWithUserInfo ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Ánh xạ ResultSet → Doctor kèm thông tin user (email, trạng thái).
     */
    private Doctor mapRowWithUser(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        d.setFullName(rs.getString("full_name"));
        d.setSpecialization(rs.getString("specialization"));
        d.setPhoneNumber(rs.getString("phone_number"));
        try { d.setDegree(rs.getString("degree")); } catch (SQLException ignored) {}
        try { d.setExperienceYears(rs.getInt("experience_years")); } catch (SQLException ignored) {}
        try { d.setBio(rs.getString("bio")); } catch (SQLException ignored) {}
        try { d.setAvatarUrl(rs.getString("avatar_url")); } catch (SQLException ignored) {}
        d.setEmail(rs.getString("user_email"));
        try { d.setUsername(rs.getString("username")); } catch (SQLException ignored) {}
        String userStatus = rs.getString("user_status");
        d.setUserStatus(userStatus != null ? userStatus : "");
        String userPhone = rs.getString("user_phone");
        d.setUserPhone(userPhone != null ? userPhone : "");
        return d;
    }
}
