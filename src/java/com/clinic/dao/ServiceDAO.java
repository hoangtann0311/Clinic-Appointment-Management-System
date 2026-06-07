package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Service;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng services — quản lý biểu giá dịch vụ y tế.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class ServiceDAO {

    /**
     * Lấy danh sách dịch vụ có phân trang + tìm kiếm + lọc.
     * Tự động fallback nếu cột migration chưa tồn tại.
     */
    public List<Service> findAll(int offset, int pageSize,
                                  String search, Boolean activeFilter) {
        try {
            return findAllInternal(offset, pageSize, search, activeFilter, true);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column")) {
                System.err.println("[ServiceDAO] Falling back to base columns: " + msg);
                try {
                    return findAllInternal(offset, pageSize, search, activeFilter, false);
                } catch (SQLException e2) {
                    System.err.println("[ServiceDAO] findAll fallback failed: " + e2.getMessage());
                    throw new RuntimeException("Lỗi database khi lấy danh sách dịch vụ", e2);
                }
            }
            System.err.println("[ServiceDAO] findAll error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy danh sách dịch vụ", e);
        }
    }

    private List<Service> findAllInternal(int offset, int pageSize,
                                           String search, Boolean activeFilter,
                                           boolean fullColumns) throws SQLException {
        String columns;
        if (fullColumns) {
            columns = "s.id, s.service_code, s.service_name, s.description, s.price, "
                    + "s.duration_mins, s.requires_fasting, s.requires_full_bladder, "
                    + "s.required_room_type, s.allowed_specialties, s.category_id, "
                    + "s.is_active, s.created_at, s.updated_at";
        } else {
            columns = "s.id, s.service_code, s.service_name, s.price, "
                    + "s.duration_mins, s.requires_fasting, s.requires_full_bladder, "
                    + "s.required_room_type, s.allowed_specialties, s.category_id, "
                    + "s.is_active";
        }

        StringBuilder sql = new StringBuilder("SELECT ").append(columns)
            .append(" FROM services s WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (s.service_name LIKE ? OR s.service_code LIKE ?) ");
        }
        if (activeFilter != null) {
            sql.append("AND s.is_active = ? ");
        }
        sql.append("ORDER BY s.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<Service> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (activeFilter != null) {
                ps.setBoolean(idx++, activeFilter);
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs, fullColumns));
            }
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Đếm tổng số dịch vụ (có filter) — dùng cho phân trang.
     */
    public int countAll(String search, Boolean activeFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM services WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (service_name LIKE ? OR service_code LIKE ?) ");
        }
        if (activeFilter != null) {
            sql.append("AND is_active = ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (activeFilter != null) {
                ps.setBoolean(idx++, activeFilter);
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Lỗi countAll services: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Tìm dịch vụ theo id.
     */
    public Service findById(int id) {
        String sql = "SELECT s.id, s.service_code, s.service_name, s.description, s.price, "
                   + "s.duration_mins, s.requires_fasting, s.requires_full_bladder, "
                   + "s.required_room_type, s.allowed_specialties, s.category_id, "
                   + "s.is_active, s.created_at, s.updated_at "
                   + "FROM services s WHERE s.id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs, true);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi findById service: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm dịch vụ theo service_code (để kiểm tra trùng).
     */
    public Service findByCode(String serviceCode) {
        String sql = "SELECT s.id, s.service_code, s.service_name, s.price, s.is_active "
                   + "FROM services s WHERE s.service_code = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, serviceCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs, false);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi findByCode service: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Thêm dịch vụ mới.
     */
    public int insert(Service service) {
        String sql = "INSERT INTO services (service_code, service_name, description, price, "
                   + "duration_mins, requires_fasting, requires_full_bladder, required_room_type, "
                   + "allowed_specialties, category_id, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, service.getServiceCode());
            ps.setString(2, service.getServiceName());
            ps.setString(3, service.getDescription());
            ps.setBigDecimal(4, service.getPrice());
            if (service.getDurationMins() > 0) {
                ps.setInt(5, service.getDurationMins());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setBoolean(6, service.isRequiresFasting());
            ps.setBoolean(7, service.isRequiresFullBladder());
            ps.setString(8, service.getRequiredRoomType());
            ps.setString(9, service.getAllowedSpecialties());
            if (service.getCategoryId() != null) {
                ps.setInt(10, service.getCategoryId());
            } else {
                ps.setNull(10, Types.INTEGER);
            }
            ps.setBoolean(11, service.isActive());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new RuntimeException("Thêm dịch vụ thất bại - không có dòng nào được tạo");
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new RuntimeException("Thêm dịch vụ thất bại - không lấy được ID");
        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm dịch vụ: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi thêm dịch vụ", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Cập nhật thông tin dịch vụ.
     */
    public boolean update(Service service) {
        String sql = "UPDATE services SET service_code=?, service_name=?, description=?, price=?, "
                   + "duration_mins=?, requires_fasting=?, requires_full_bladder=?, "
                   + "required_room_type=?, allowed_specialties=?, category_id=?, is_active=?, "
                   + "updated_at=GETDATE() WHERE id=?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, service.getServiceCode());
            ps.setString(2, service.getServiceName());
            ps.setString(3, service.getDescription());
            ps.setBigDecimal(4, service.getPrice());
            if (service.getDurationMins() > 0) {
                ps.setInt(5, service.getDurationMins());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setBoolean(6, service.isRequiresFasting());
            ps.setBoolean(7, service.isRequiresFullBladder());
            ps.setString(8, service.getRequiredRoomType());
            ps.setString(9, service.getAllowedSpecialties());
            if (service.getCategoryId() != null) {
                ps.setInt(10, service.getCategoryId());
            } else {
                ps.setNull(10, Types.INTEGER);
            }
            ps.setBoolean(11, service.isActive());
            ps.setInt(12, service.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi update service: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Vô hiệu hóa dịch vụ (soft delete — không xóa vật lý).
     */
    public boolean deactivate(int id) {
        String sql = "UPDATE services SET is_active = 0, updated_at = GETDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deactivate service: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Lấy tất cả dịch vụ đang hoạt động (dùng cho dropdown).
     */
    public List<Service> findAllActive() {
        String sql = "SELECT id, service_code, service_name, price, is_active "
                   + "FROM services WHERE is_active = 1 ORDER BY service_name";
        List<Service> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs, false));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi findAllActive services: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Ánh xạ ResultSet → Service entity. */
    private Service mapRow(ResultSet rs, boolean fullColumns) throws SQLException {
        Service s = new Service();
        s.setId(rs.getInt("id"));
        s.setServiceName(rs.getString("service_name"));
        s.setPrice(rs.getBigDecimal("price"));

        try { s.setServiceCode(rs.getString("service_code")); } catch (SQLException e) { s.setServiceCode(null); }
        try { s.setDurationMins(rs.getInt("duration_mins")); } catch (SQLException e) { s.setDurationMins(0); }
        try { s.setRequiresFasting(rs.getBoolean("requires_fasting")); } catch (SQLException e) { s.setRequiresFasting(false); }
        try { s.setRequiresFullBladder(rs.getBoolean("requires_full_bladder")); } catch (SQLException e) { s.setRequiresFullBladder(false); }
        try { s.setRequiredRoomType(rs.getString("required_room_type")); } catch (SQLException e) { s.setRequiredRoomType(null); }
        try { s.setAllowedSpecialties(rs.getString("allowed_specialties")); } catch (SQLException e) { s.setAllowedSpecialties(null); }
        try { s.setCategoryId((Integer) rs.getObject("category_id")); } catch (SQLException e) { s.setCategoryId(null); }
        try { s.setActive(rs.getBoolean("is_active")); } catch (SQLException e) { s.setActive(true); }

        if (fullColumns) {
            try { s.setDescription(rs.getString("description")); } catch (SQLException e) { s.setDescription(null); }
            try { s.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { s.setCreatedAt(null); }
            try { s.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { s.setUpdatedAt(null); }
        }
        return s;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
