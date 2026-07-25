package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.Shift;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng shifts — quản lý ca làm việc.
 *
 * <p>Hỗ trợ các thao tác:
 * <ul>
 *   <li>CRUD ca làm việc</li>
 *   <li>Kiểm tra trùng khung giờ</li>
 *   <li>Kiểm tra phụ thuộc trước khi xóa</li>
 * </ul>
 */
public class ShiftDAO {

    private static final String BASE_COLUMNS =
        "id, name, start_time, end_time, description, is_active, created_at, updated_at";

    /**
     * Lấy tất cả ca làm việc, sắp xếp theo giờ bắt đầu.
     */
    public List<Shift> findAll() {
        String sql = "SELECT " + BASE_COLUMNS + " FROM shifts ORDER BY start_time ASC";
        List<Shift> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] findAll ERROR: " + e.getMessage());
            throw new RuntimeException("Lỗi cơ sở dữ liệu khi lấy danh sách ca làm việc", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Lấy danh sách ca làm việc đang hoạt động.
     */
    public List<Shift> findAllActive() {
        String sql = "SELECT " + BASE_COLUMNS
                   + " FROM shifts WHERE is_active = 1 ORDER BY start_time ASC";
        List<Shift> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] findAllActive ERROR: " + e.getMessage());
            return list;
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tìm ca làm việc theo id.
     */
    public Shift findById(int id) {
        String sql = "SELECT " + BASE_COLUMNS + " FROM shifts WHERE id = ?";
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
            System.err.println("[ShiftDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Thêm mới ca làm việc.
     *
     * @return true nếu INSERT thành công
     */
    public boolean insert(Shift shift) {
        String sql = "INSERT INTO shifts (name, start_time, end_time, description, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, 1, GETDATE(), GETDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, shift.getName());
            ps.setTime(2, shift.getStartTime());
            ps.setTime(3, shift.getEndTime());
            if (shift.getDescription() != null && !shift.getDescription().isEmpty()) {
                ps.setString(4, shift.getDescription());
            } else {
                ps.setNull(4, Types.NVARCHAR);
            }
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] insert ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Cập nhật ca làm việc.
     *
     * @return true nếu UPDATE thành công
     */
    public boolean update(Shift shift) {
        String sql = "UPDATE shifts SET name = ?, start_time = ?, end_time = ?, "
                   + "description = ?, updated_at = GETDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, shift.getName());
            ps.setTime(2, shift.getStartTime());
            ps.setTime(3, shift.getEndTime());
            if (shift.getDescription() != null && !shift.getDescription().isEmpty()) {
                ps.setString(4, shift.getDescription());
            } else {
                ps.setNull(4, Types.NVARCHAR);
            }
            ps.setInt(5, shift.getId());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] update ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Bật/tắt trạng thái hoạt động của ca (xóa mềm).
     *
     * @return true nếu UPDATE thành công
     */
    public boolean setActive(int id, boolean active) {
        String sql = "UPDATE shifts SET is_active = ?, updated_at = GETDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] setActive ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Xóa cứng ca làm việc. Chỉ xóa nếu không có doctor_schedules tham chiếu.
     *
     * @return true nếu DELETE thành công
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM shifts WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] delete ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Đếm số ca làm việc theo trạng thái hoạt động.
     */
    public int countByStatus(boolean active) {
        String sql = "SELECT COUNT(*) AS total FROM shifts WHERE is_active = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] countByStatus ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Kiểm tra trùng tên ca làm việc.
     *
     * @param name      tên cần kiểm tra
     * @param excludeId ID cần loại trừ (khi sửa), null nếu tạo mới
     * @return true nếu đã tồn tại tên
     */
    public boolean existsByName(String name, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM shifts WHERE name = ?");
        if (excludeId != null) {
            sql.append(" AND id <> ?");
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setString(1, name);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total") > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] existsByName ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Kiểm tra trùng khung giờ với các ca đang hoạt động.
     *
     * @param startTime giờ bắt đầu ca mới
     * @param endTime   giờ kết thúc ca mới
     * @param excludeId ID cần loại trừ (khi sửa), null nếu tạo mới
     * @return true nếu có trùng
     */
    public boolean isTimeRangeOverlapping(Time startTime, Time endTime, Integer excludeId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) AS total FROM shifts "
          + "WHERE is_active = 1 "
          + "AND start_time < CAST(? AS time) AND end_time > CAST(? AS time) ");
        if (excludeId != null) {
            sql.append("AND id <> ? ");
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setTime(1, endTime);   // start_time < new_end
            ps.setTime(2, startTime); // end_time   > new_start
            if (excludeId != null) {
                ps.setInt(3, excludeId);
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total") > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] isTimeRangeOverlapping ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Kiểm tra xem có doctor_schedules nào đang dùng khung giờ của ca này không.
     * Dùng để chặn xóa ca đã có dữ liệu.
     */
    public boolean hasDoctorSchedulesForTimeRange(Time startTime, Time endTime) {
        String sql = "SELECT COUNT(*) AS total FROM doctor_schedules "
                   + "WHERE start_time = CAST(? AS time) AND end_time = CAST(? AS time) "
                   + "AND status NOT IN ('CANCELLED', 'REJECTED')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setTime(1, startTime);
            ps.setTime(2, endTime);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total") > 0;
        } catch (SQLException e) {
            System.err.println("[ShiftDAO] hasDoctorSchedulesForTimeRange ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    // ── Private helpers ──

    private Shift mapRow(ResultSet rs) throws SQLException {
        Shift shift = new Shift();
        shift.setId(rs.getInt("id"));
        shift.setName(rs.getString("name"));
        shift.setStartTime(rs.getTime("start_time"));
        shift.setEndTime(rs.getTime("end_time"));
        shift.setDescription(rs.getString("description"));
        shift.setActive(rs.getBoolean("is_active"));
        shift.setCreatedAt(rs.getTimestamp("created_at"));
        shift.setUpdatedAt(rs.getTimestamp("updated_at"));
        return shift;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { /* ignore */ }
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) { /* ignore */ }
        }
        DatabaseConfig.closeConnection(conn);
    }
}
