package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.TimeSlot;
import com.clinic.model.enums.SlotStatus;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng time_slots — quản lý khung giờ khám bệnh.
 *
 * <p>Hỗ trợ các thao tác:
 * <ul>
 *   <li>Sinh hàng loạt slot từ lịch trực đã duyệt (batch insert, transaction)</li>
 *   <li>Truy vấn slot theo schedule_id, doctor_id + ngày</li>
 *   <li>Xóa slot khi schedule bị hủy</li>
 * </ul>
 */
public class TimeSlotDAO {

    private static final String BASE_COLUMNS =
        "ts.id, ts.schedule_id, ts.doctor_id, ts.work_date, "
        + "ts.start_time, ts.end_time, ts.status, ts.notes, "
        + "ts.created_at, ts.updated_at";

    // ──────────────────────────────────────────────
    //  Batch insert: sinh slots từ lịch trực đã duyệt
    // ──────────────────────────────────────────────

    /**
     * Sinh hàng loạt time slots từ một lịch trực đã được duyệt.
     * Mỗi slot = 20 phút, bắt đầu từ startTime đến endTime.
     * Sử dụng batch insert trong transaction để đảm bảo toàn vẹn dữ liệu.
     *
     * @param scheduleId ID lịch trực gốc
     * @param doctorId   ID bác sĩ
     * @param workDate   ngày làm việc
     * @param startTime  giờ bắt đầu ca
     * @param endTime    giờ kết thúc ca
     * @return số slot đã sinh, 0 nếu không đủ thời gian, -1 nếu lỗi
     */
    public int generateSlots(int scheduleId, int doctorId, Date workDate,
                              Time startTime, Time endTime) {
        // Tính số slot: mỗi slot 20 phút
        long durationMs = endTime.getTime() - startTime.getTime();
        if (durationMs <= 0) {
            return 0; // Không có slot (0 phút hoặc start > end)
        }
        int totalMinutes = (int) (durationMs / (60 * 1000));
        int slotCount = totalMinutes / 20;

        if (slotCount == 0) {
            return 0;
        }

        String sql = "INSERT INTO time_slots (schedule_id, doctor_id, work_date, "
                   + "start_time, end_time, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, 'AVAILABLE', GETDATE(), GETDATE())";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            ps = conn.prepareStatement(sql);

            long slotMs = 20L * 60 * 1000L; // 20 phút = 1,200,000 ms
            long currentStartMs = startTime.getTime();

            for (int i = 0; i < slotCount; i++) {
                long slotEndMs = currentStartMs + slotMs;
                Time slotStart = new Time(currentStartMs);
                Time slotEnd = new Time(slotEndMs);

                ps.setInt(1, scheduleId);
                ps.setInt(2, doctorId);
                ps.setDate(3, workDate);
                ps.setTime(4, slotStart);
                ps.setTime(5, slotEnd);
                ps.addBatch();

                currentStartMs = slotEndMs;
            }

            int[] results = ps.executeBatch();
            conn.commit(); // Commit transaction

            // Đếm số dòng insert thành công
            int inserted = 0;
            for (int r : results) {
                if (r > 0) inserted++;
            }
            System.out.println("[TimeSlotDAO] generateSlots: scheduleId=" + scheduleId
                    + ", total=" + slotCount + ", inserted=" + inserted);
            return inserted;

        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] generateSlots ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {
                    System.err.println("[TimeSlotDAO] rollback ERROR: " + ex.getMessage());
                }
            }
            return -1;
        } finally {
            if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    // ──────────────────────────────────────────────
    //  Truy vấn theo schedule_id
    // ──────────────────────────────────────────────

    /**
     * Lấy danh sách time slots theo schedule_id (có phân trang).
     *
     * @param scheduleId ID lịch trực
     * @param offset     vị trí bắt đầu
     * @param pageSize   số dòng mỗi trang
     */
    public List<TimeSlot> findByScheduleId(int scheduleId, int offset, int pageSize) {
        String sql = "SELECT " + BASE_COLUMNS + ", d.full_name AS doctor_name "
                   + "FROM time_slots ts "
                   + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
                   + "WHERE ts.schedule_id = ? "
                   + "ORDER BY ts.start_time ASC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<TimeSlot> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findByScheduleId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Đếm tổng số time slots của một schedule.
     */
    public int countByScheduleId(int scheduleId) {
        String sql = "SELECT COUNT(*) AS total FROM time_slots WHERE schedule_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] countByScheduleId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Kiểm tra xem schedule đã có time slots hay chưa.
     * Dùng để tránh sinh trùng lặp khi duyệt lại.
     *
     * @param scheduleId ID lịch trực
     * @return true nếu đã có ít nhất 1 slot
     */
    public boolean hasSlotsForSchedule(int scheduleId) {
        String sql = "SELECT COUNT(*) AS total FROM time_slots WHERE schedule_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total") > 0;
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] hasSlotsForSchedule ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Xóa tất cả time slots của một schedule (dùng khi hủy lịch trực hoặc sinh lại).
     *
     * @param scheduleId ID lịch trực
     * @return true nếu xóa thành công
     */
    public boolean deleteByScheduleId(int scheduleId) {
        String sql = "DELETE FROM time_slots WHERE schedule_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            int rows = ps.executeUpdate();
            System.out.println("[TimeSlotDAO] deleteByScheduleId: scheduleId=" + scheduleId
                    + ", deleted=" + rows + " slots");
            return true;
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] deleteByScheduleId ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ──────────────────────────────────────────────
    //  Truy vấn theo doctor + ngày (dùng cho Phase 9 - Đặt lịch)
    // ──────────────────────────────────────────────

    /**
     * Lấy danh sách time slots theo doctor_id và ngày, có thể lọc theo trạng thái.
     * Dùng cho chức năng đặt lịch khám (Phase 9).
     *
     * @param doctorId ID bác sĩ
     * @param workDate ngày khám
     * @param status   trạng thái cần lọc (null = tất cả)
     * @return danh sách slots, sắp xếp theo start_time tăng dần
     */
    public List<TimeSlot> findByDoctorAndDate(int doctorId, Date workDate, SlotStatus status) {
        StringBuilder sql = new StringBuilder("SELECT " + BASE_COLUMNS + " "
            + "FROM time_slots ts "
            + "WHERE ts.doctor_id = ? AND ts.work_date = ? ");
        if (status != null) {
            sql.append("AND ts.status = ? ");
        }
        sql.append("ORDER BY ts.start_time ASC");

        List<TimeSlot> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, doctorId);
            ps.setDate(2, workDate);
            if (status != null) {
                ps.setString(3, status.name());
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findByDoctorAndDate ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Đếm số slot theo trạng thái trong một schedule (dùng hiển thị KPI).
     */
    public int countByScheduleAndStatus(int scheduleId, SlotStatus status) {
        String sql = "SELECT COUNT(*) AS total FROM time_slots "
                   + "WHERE schedule_id = ? AND status = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            ps.setString(2, status.name());
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] countByScheduleAndStatus ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    // ── Private helpers ──

    /**
     * Ánh xạ ResultSet → TimeSlot.
     */
    private TimeSlot mapRow(ResultSet rs) throws SQLException {
        TimeSlot ts = new TimeSlot();
        ts.setId(rs.getInt("id"));
        ts.setScheduleId(rs.getInt("schedule_id"));
        ts.setDoctorId(rs.getInt("doctor_id"));
        ts.setWorkDate(rs.getDate("work_date"));
        ts.setStartTime(rs.getTime("start_time"));
        ts.setEndTime(rs.getTime("end_time"));

        String statusStr = rs.getString("status");
        ts.setStatus(SlotStatus.fromString(statusStr));

        ts.setNotes(rs.getString("notes"));
        ts.setCreatedAt(rs.getTimestamp("created_at"));
        ts.setUpdatedAt(rs.getTimestamp("updated_at"));

        // Join fields
        try { ts.setDoctorName(rs.getString("doctor_name")); } catch (SQLException e) { }

        return ts;
    }

    /**
     * Đóng tài nguyên database an toàn.
     */
    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
