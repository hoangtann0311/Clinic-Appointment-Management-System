package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Medicine;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng medicines — quản lý biểu giá thuốc.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class MedicineDAO {

    /**
     * Lấy danh sách thuốc có phân trang + tìm kiếm + lọc.
     * Tự động fallback nếu cột migration chưa tồn tại.
     */
    public List<Medicine> findAll(int offset, int pageSize,
                                   String search, Boolean activeFilter) {
        try {
            return findAllInternal(offset, pageSize, search, activeFilter, true);
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Invalid column name") || msg.contains("invalid column")) {
                System.err.println("[MedicineDAO] Falling back to base columns: " + msg);
                try {
                    return findAllInternal(offset, pageSize, search, activeFilter, false);
                } catch (SQLException e2) {
                    System.err.println("[MedicineDAO] findAll fallback failed: " + e2.getMessage());
                    throw new RuntimeException("Lỗi database khi lấy danh sách thuốc", e2);
                }
            }
            System.err.println("[MedicineDAO] findAll error: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy danh sách thuốc", e);
        }
    }

    private List<Medicine> findAllInternal(int offset, int pageSize,
                                            String search, Boolean activeFilter,
                                            boolean fullColumns) throws SQLException {
        String columns;
        if (fullColumns) {
            columns = "id, medicine_code, name, description, dosage, unit, price, "
                    + "stock_quantity, is_active, created_at, updated_at";
        } else {
            columns = "id, medicine_code, name, unit, price, stock_quantity, is_active";
        }

        StringBuilder sql = new StringBuilder("SELECT ").append(columns)
            .append(" FROM medicines WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR medicine_code LIKE ?) ");
        }
        if (activeFilter != null) {
            sql.append("AND is_active = ? ");
        }
        sql.append("ORDER BY id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<Medicine> list = new ArrayList<>();
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
     * Đếm tổng số thuốc (có filter) — dùng cho phân trang.
     */
    public int countAll(String search, Boolean activeFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM medicines WHERE 1=1 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR medicine_code LIKE ?) ");
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
            System.err.println("Lỗi countAll medicines: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Tìm thuốc theo id.
     */
    public Medicine findById(int id) {
        String sql = "SELECT id, medicine_code, name, description, dosage, unit, price, "
                   + "stock_quantity, is_active, created_at, updated_at "
                   + "FROM medicines WHERE id = ?";

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
            System.err.println("Lỗi findById medicine: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Tìm thuốc theo medicine_code (để kiểm tra trùng).
     */
    public Medicine findByCode(String medicineCode) {
        String sql = "SELECT id, medicine_code, name, unit, price, is_active "
                   + "FROM medicines WHERE medicine_code = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, medicineCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs, false);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi findByCode medicine: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Thêm thuốc mới.
     */
    public int insert(Medicine medicine) {
        String sql = "INSERT INTO medicines (medicine_code, name, description, dosage, unit, "
                   + "price, stock_quantity, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, medicine.getMedicineCode());
            ps.setString(2, medicine.getName());
            ps.setString(3, medicine.getDescription());
            ps.setString(4, medicine.getDosage());
            ps.setString(5, medicine.getUnit());
            ps.setBigDecimal(6, medicine.getPrice());
            ps.setInt(7, medicine.getStockQuantity());
            ps.setBoolean(8, medicine.isActive());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new RuntimeException("Thêm thuốc thất bại - không có dòng nào được tạo");
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new RuntimeException("Thêm thuốc thất bại - không lấy được ID");
        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm thuốc: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi thêm thuốc", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Cập nhật thông tin thuốc.
     */
    public boolean update(Medicine medicine) {
        String sql = "UPDATE medicines SET medicine_code=?, name=?, description=?, dosage=?, "
                   + "unit=?, price=?, stock_quantity=?, is_active=?, updated_at=GETDATE() "
                   + "WHERE id=?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, medicine.getMedicineCode());
            ps.setString(2, medicine.getName());
            ps.setString(3, medicine.getDescription());
            ps.setString(4, medicine.getDosage());
            ps.setString(5, medicine.getUnit());
            ps.setBigDecimal(6, medicine.getPrice());
            ps.setInt(7, medicine.getStockQuantity());
            ps.setBoolean(8, medicine.isActive());
            ps.setInt(9, medicine.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi update medicine: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Vô hiệu hóa thuốc (soft delete — không xóa vật lý).
     */
    public boolean deactivate(int id) {
        String sql = "UPDATE medicines SET is_active = 0, updated_at = GETDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deactivate medicine: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Lấy tất cả thuốc đang hoạt động (dùng cho dropdown).
     */
    public List<Medicine> findAllActive() {
        String sql = "SELECT id, medicine_code, name, unit, price, is_active "
                   + "FROM medicines WHERE is_active = 1 ORDER BY name";
        List<Medicine> list = new ArrayList<>();
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
            System.err.println("Lỗi findAllActive medicines: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Cập nhật số lượng tồn kho (khi nhập/xuất thuốc).
     */
    public boolean updateStock(int id, int newQuantity) {
        String sql = "UPDATE medicines SET stock_quantity = ?, updated_at = GETDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, newQuantity);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateStock medicine: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Ánh xạ ResultSet → Medicine entity. */
    private Medicine mapRow(ResultSet rs, boolean fullColumns) throws SQLException {
        Medicine m = new Medicine();
        m.setId(rs.getInt("id"));
        m.setName(rs.getString("name"));
        m.setPrice(rs.getBigDecimal("price"));

        try { m.setMedicineCode(rs.getString("medicine_code")); } catch (SQLException e) { m.setMedicineCode(null); }
        try { m.setUnit(rs.getString("unit")); } catch (SQLException e) { m.setUnit(null); }
        try { m.setStockQuantity(rs.getInt("stock_quantity")); } catch (SQLException e) { m.setStockQuantity(0); }
        try { m.setActive(rs.getBoolean("is_active")); } catch (SQLException e) { m.setActive(true); }

        if (fullColumns) {
            try { m.setDescription(rs.getString("description")); } catch (SQLException e) { m.setDescription(null); }
            try { m.setDosage(rs.getString("dosage")); } catch (SQLException e) { m.setDosage(null); }
            try { m.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException e) { m.setCreatedAt(null); }
            try { m.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException e) { m.setUpdatedAt(null); }
        }
        return m;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
