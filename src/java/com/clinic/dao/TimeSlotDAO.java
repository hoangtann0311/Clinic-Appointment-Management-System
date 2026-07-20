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
 *   <li>Đặt slot nguyên tử (atomic booking) với UPDLOCK — ngăn double-booking</li>
 *   <li>Hủy slot nguyên tử (atomic cancellation) — giải phóng slot</li>
 *   <li>Xóa slot khi schedule bị hủy (có kiểm tra booked slots)</li>
 * </ul>
 *
 * <p><strong>Concurrency strategy:</strong>
 * <ul>
 *   <li>Booking dùng {@code WITH (UPDLOCK, ROWLOCK, HOLDLOCK)} — khóa dòng khi SELECT,
 *       chỉ 1 transaction được book 1 slot tại một thời điểm.</li>
 *   <li>Cancellation dùng UPDLOCK tương tự.</li>
 *   <li>Optimistic locking: version (ROWVERSION) được kiểm tra ở các thao tác quan trọng.</li>
 * </ul>
 */
public class TimeSlotDAO {

    private static final String BASE_COLUMNS =
        "ts.id, ts.schedule_id, ts.doctor_id, ts.work_date, "
        + "ts.start_time, ts.end_time, ts.status, ts.notes, "
        + "ts.booked_by, ts.booked_at, ts.version, "
        + "ts.created_at, ts.updated_at";

    // ──────────────────────────────────────────────
    //  Batch insert: sinh slots từ lịch trực đã duyệt
    // ──────────────────────────────────────────────

    /**
     * Sinh hàng loạt time slots từ một lịch trực đã được duyệt.
     * Mỗi slot = 20 phút, bắt đầu từ startTime đến endTime.
     * Sử dụng batch insert trong transaction để đảm bảo toàn vẹn dữ liệu.
     *
     * <p>Quan trọng: Phương thức này nên được gọi TRONG CÙNG transaction
     * với approve schedule để đảm bảo tính nguyên tử (approve + sinh slot).
     *
     * @param scheduleId ID lịch trực gốc
     * @param doctorId   ID bác sĩ
     * @param workDate   ngày làm việc
     * @param startTime  giờ bắt đầu ca
     * @param endTime    giờ kết thúc ca
     * @param conn       connection hiện tại (có thể nằm trong transaction cha)
     * @return số slot đã sinh, 0 nếu không đủ thời gian, -1 nếu lỗi
     */
    public int generateSlots(int scheduleId, int doctorId, Date workDate,
                              Time startTime, Time endTime, Connection conn) {
        // Tính số slot: mỗi slot 20 phút
        long durationMs = endTime.getTime() - startTime.getTime();
        if (durationMs <= 0) {
            return 0;
        }
        int totalMinutes = (int) (durationMs / (60 * 1000));
        int slotCount = totalMinutes / 20;

        if (slotCount == 0) {
            return 0;
        }

        double defaultPrice = 200000.00; // Mặc định Khám thai định kỳ
        boolean ownConn = (conn == null);
        PreparedStatement ps = null;
        try {
            if (ownConn) {
                conn = DatabaseConfig.getConnection();
                conn.setAutoCommit(false);
            }

            // Lấy specialization để map giá khám mặc định
            String getSpecSql = "SELECT specialization FROM doctors WHERE id = ?";
            try (PreparedStatement specPs = conn.prepareStatement(getSpecSql)) {
                specPs.setInt(1, doctorId);
                try (ResultSet specRs = specPs.executeQuery()) {
                    if (specRs.next()) {
                        String spec = specRs.getString("specialization");
                        if (spec != null) {
                            String lower = spec.toLowerCase();
                            if (lower.contains("hiếm muộn") || lower.contains("ivf")) {
                                defaultPrice = 350000.00;
                            } else if (lower.contains("tiền sản")) {
                                defaultPrice = 300000.00;
                            } else if (lower.contains("phụ khoa")) {
                                defaultPrice = 250000.00;
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("[TimeSlotDAO] Không lấy được specialization bác sĩ: " + e.getMessage());
            }

            String sql = "INSERT INTO time_slots (schedule_id, doctor_id, work_date, "
                       + "start_time, end_time, status, price, created_at, updated_at) "
                       + "VALUES (?, ?, ?, ?, ?, 'AVAILABLE', ?, GETDATE(), GETDATE())";

            ps = conn.prepareStatement(sql);

            long slotMs = 20L * 60 * 1000L;
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
                ps.setDouble(6, defaultPrice);
                ps.addBatch();

                currentStartMs = slotEndMs;
            }

            int[] results = ps.executeBatch();

            if (ownConn) {
                conn.commit();
            }

            int inserted = 0;
            for (int r : results) {
                if (r > 0) inserted++;
            }
            System.out.println("[TimeSlotDAO] generateSlots: scheduleId=" + scheduleId
                    + ", total=" + slotCount + ", inserted=" + inserted);
            return inserted;

        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] generateSlots ERROR: " + e.getMessage());
            if (ownConn && conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {
                    System.err.println("[TimeSlotDAO] rollback ERROR: " + ex.getMessage());
                }
            }
            return -1;
        } finally {
            if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
            if (ownConn && conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Overload giữ backward compatibility — mở connection riêng.
     */
    public int generateSlots(int scheduleId, int doctorId, Date workDate,
                              Time startTime, Time endTime) {
        return generateSlots(scheduleId, doctorId, workDate, startTime, endTime, null);
    }

    // ──────────────────────────────────────────────
    //  Atomic Booking — đặt slot nguyên tử (chống double-booking)
    // ──────────────────────────────────────────────

    /**
     * Đặt một slot cho bệnh nhân một cách NGUYÊN TỬ.
     * Dùng {@code WITH (UPDLOCK, ROWLOCK, HOLDLOCK)} để khóa dòng,
     * đảm bảo chỉ 1 transaction được book thành công.
     *
     * <p>Cơ chế: SELECT FOR UPDATE → kiểm tra status=AVAILABLE → UPDATE.
     * Nếu slot đã bị đặt (status != AVAILABLE), trả về kết quả tương ứng.
     *
     * @param slotId    ID của time slot cần đặt
     * @param patientId user_id của bệnh nhân
     * @return BookingResult chứa kết quả: thành công / thất bại + lý do
     */
    public BookingResult bookSlotAtomic(int slotId, int patientId) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement updatePs = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            // SET TRANSACTION ISOLATION LEVEL SERIALIZABLE để đảm bảo
            // không phantom read trong quá trình book slot
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // Step 1: SELECT với UPDLOCK để khóa dòng
            String selectSql = "SELECT id, status, doctor_id, work_date, "
                    + "start_time, end_time "
                    + "FROM time_slots WITH (UPDLOCK, ROWLOCK, HOLDLOCK) "
                    + "WHERE id = ?";

            selectPs = conn.prepareStatement(selectSql);
            selectPs.setInt(1, slotId);
            rs = selectPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return BookingResult.slotNotFound(slotId);
            }

            String currentStatus = rs.getString("status");

            if (!"AVAILABLE".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return BookingResult.slotNotAvailable(slotId, currentStatus);
            }

            // Step 2: UPDATE — chỉ UPDATE nếu status vẫn là AVAILABLE
            String updateSql = "UPDATE time_slots SET "
                    + "status = 'BOOKED', "
                    + "booked_by = ?, "
                    + "booked_at = GETDATE(), "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'AVAILABLE'";

            updatePs = conn.prepareStatement(updateSql);
            updatePs.setInt(1, patientId);
            updatePs.setInt(2, slotId);

            int rowsAffected = updatePs.executeUpdate();

            if (rowsAffected == 0) {
                // Race condition: slot vừa bị đặt bởi transaction khác
                conn.rollback();
                return BookingResult.slotNotAvailable(slotId, "BOOKED (vừa được đặt bởi người khác)");
            }

            conn.commit();

            // Build TimeSlot kết quả
            TimeSlot booked = new TimeSlot();
            booked.setId(slotId);
            booked.setDoctorId(rs.getInt("doctor_id"));
            booked.setWorkDate(rs.getDate("work_date"));
            booked.setStartTime(rs.getTime("start_time"));
            booked.setEndTime(rs.getTime("end_time"));
            booked.setStatus(SlotStatus.BOOKED);
            booked.setBookedBy(patientId);
            booked.setBookedAt(new Timestamp(System.currentTimeMillis()));

            System.out.println("[TimeSlotDAO] bookSlotAtomic SUCCESS: slotId=" + slotId
                    + ", patientId=" + patientId);
            return BookingResult.success(booked);

        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] bookSlotAtomic ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return BookingResult.systemError("Lỗi database: " + e.getMessage());
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
            if (selectPs != null) { try { selectPs.close(); } catch (SQLException e) { } }
            if (updatePs != null) { try { updatePs.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    // ──────────────────────────────────────────────
    //  Atomic Cancellation — hủy slot nguyên tử
    // ──────────────────────────────────────────────

    /**
     * Hủy một slot đã BOOKED, giải phóng về trạng thái AVAILABLE.
     * Dùng UPDLOCK để đảm bảo không conflict với booking đồng thời.
     *
     * @param slotId       ID của time slot cần hủy
     * @param cancelledBy  user_id thực hiện hủy (patient hoặc system)
     * @param reason       lý do hủy
     * @return CancelResult chứa kết quả
     */
    public CancelResult cancelSlotAtomic(int slotId, int cancelledBy, String reason) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement updatePs = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            // SELECT với UPDLOCK
            String selectSql = "SELECT id, status, booked_by "
                    + "FROM time_slots WITH (UPDLOCK, ROWLOCK, HOLDLOCK) "
                    + "WHERE id = ?";
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setInt(1, slotId);
            rs = selectPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return CancelResult.slotNotFound(slotId);
            }

            String currentStatus = rs.getString("status");

            if (!"BOOKED".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return CancelResult.slotNotBooked(slotId, currentStatus);
            }

            // Cập nhật về AVAILABLE
            String notesText = (reason != null && !reason.isEmpty())
                    ? "Hủy bởi user #" + cancelledBy + ": " + reason
                    : "Hủy bởi user #" + cancelledBy;

            String updateSql = "UPDATE time_slots SET "
                    + "status = 'AVAILABLE', "
                    + "notes = ?, "
                    + "booked_by = NULL, "
                    + "booked_at = NULL, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'BOOKED'";

            updatePs = conn.prepareStatement(updateSql);
            updatePs.setString(1, notesText);
            updatePs.setInt(2, slotId);

            int rowsAffected = updatePs.executeUpdate();

            if (rowsAffected == 0) {
                conn.rollback();
                return CancelResult.concurrentModification(slotId);
            }

            conn.commit();

            System.out.println("[TimeSlotDAO] cancelSlotAtomic SUCCESS: slotId=" + slotId
                    + ", cancelledBy=" + cancelledBy);
            return CancelResult.success(slotId);

        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] cancelSlotAtomic ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return CancelResult.systemError("Lỗi database: " + e.getMessage());
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
            if (selectPs != null) { try { selectPs.close(); } catch (SQLException e) { } }
            if (updatePs != null) { try { updatePs.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    public TimeSlot findById(int id) {
        String sql = "SELECT " + BASE_COLUMNS + ", ts.price, d.full_name AS doctor_name, "
                   + "u.full_name AS booked_by_name "
                   + "FROM time_slots ts "
                   + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
                   + "LEFT JOIN users u ON ts.booked_by = u.id "
                   + "WHERE ts.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                TimeSlot ts = mapRow(rs);
                double p = rs.getDouble("price");
                if (!rs.wasNull()) ts.setPrice(p);
                return ts;
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    // ──────────────────────────────────────────────
    //  Truy vấn theo schedule_id
    // ──────────────────────────────────────────────

    /**
     * Lấy danh sách time slots theo schedule_id (có phân trang).
     */
    public List<TimeSlot> findByScheduleId(int scheduleId, int offset, int pageSize) {
        String sql = "SELECT " + BASE_COLUMNS + ", ts.price, d.full_name AS doctor_name, "
                   + "u.full_name AS booked_by_name "
                   + "FROM time_slots ts "
                   + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
                   + "LEFT JOIN users u ON ts.booked_by = u.id "
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
                TimeSlot ts = mapRow(rs);
                double p = rs.getDouble("price");
                if (!rs.wasNull()) ts.setPrice(p);
                list.add(ts);
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findByScheduleId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Cập nhật giá riêng cho MỘT khung giờ cụ thể (giá theo ngày/giờ).
     * Truyền price = null để bỏ công bố giá của slot.
     */
    public boolean updateSlotPrice(int scheduleId, int slotId, Double price) {
        // A price is part of the booking contract once a patient has held or booked a slot.
        String sql = "UPDATE time_slots SET price = ?, updated_at = GETDATE() "
                + "WHERE id = ? AND schedule_id = ? AND status = 'AVAILABLE'";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            if (price == null) {
                ps.setNull(1, Types.DECIMAL);
            } else {
                ps.setDouble(1, price);
            }
            ps.setInt(2, slotId);
            ps.setInt(3, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] updateSlotPrice ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Áp giá hàng loạt cho TẤT CẢ slot của một lịch trực (áp giá theo ngày,
     * vì 1 schedule ứng với 1 bác sĩ trong 1 ngày làm việc).
     */
    public int updatePriceBySchedule(int scheduleId, Double price) {
        // Keep historical invoice totals stable: only open slots may be repriced.
        String sql = "UPDATE time_slots SET price = ?, updated_at = GETDATE() "
                + "WHERE schedule_id = ? AND status = 'AVAILABLE'";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            if (price == null) {
                ps.setNull(1, Types.DECIMAL);
            } else {
                ps.setDouble(1, price);
            }
            ps.setInt(2, scheduleId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] updatePriceBySchedule ERROR: " + e.getMessage());
            return -1;
        } finally {
            closeResources(conn, ps, null);
        }
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

    // ──────────────────────────────────────────────
    //  Kiểm tra BOOKED slots — bảo vệ nghiệp vụ
    // ──────────────────────────────────────────────

    /**
     * Đếm số slot đã BOOKED trong một schedule.
     * Dùng để kiểm tra trước khi hủy/sửa lịch trực.
     */
    public int countBookedSlots(int scheduleId) {
        String sql = "SELECT COUNT(*) AS total FROM time_slots "
                   + "WHERE schedule_id = ? AND status IN ('BOOKED', 'WAITING_VERIFICATION')";
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
            System.err.println("[TimeSlotDAO] countBookedSlots ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Lấy danh sách slot đã BOOKED trong một schedule (dùng để chuyển bệnh nhân).
     */
    public List<TimeSlot> findBookedSlotsByScheduleId(int scheduleId) {
        String sql = "SELECT " + BASE_COLUMNS + ", d.full_name AS doctor_name, "
                   + "u.full_name AS booked_by_name "
                   + "FROM time_slots ts "
                   + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
                   + "LEFT JOIN users u ON ts.booked_by = u.id "
                   + "WHERE ts.schedule_id = ? AND ts.status IN ('BOOKED', 'WAITING_VERIFICATION') "
                   + "ORDER BY ts.start_time ASC";

        List<TimeSlot> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findBookedSlotsByScheduleId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Xóa tất cả time slots của một schedule.
     * CHỈ xóa nếu không có slot nào đang BOOKED (bảo vệ dữ liệu bệnh nhân).
     *
     * @param scheduleId ID lịch trực
     * @param force      true = xóa cả nếu có BOOKED slots (dùng trong trường hợp khẩn)
     * @return DeleteSlotsResult chứa kết quả
     */
    public DeleteSlotsResult deleteByScheduleIdSafe(int scheduleId, boolean force) {
        Connection conn = null;
        PreparedStatement countPs = null;
        PreparedStatement deletePs = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // Đếm số slot BOOKED
            String countSql = "SELECT COUNT(*) AS total FROM time_slots WITH (UPDLOCK) "
                            + "WHERE schedule_id = ? AND status IN ('BOOKED', 'WAITING_VERIFICATION')";
            countPs = conn.prepareStatement(countSql);
            countPs.setInt(1, scheduleId);
            rs = countPs.executeQuery();
            int bookedCount = 0;
            if (rs.next()) {
                bookedCount = rs.getInt("total");
            }

            if (bookedCount > 0 && !force) {
                conn.rollback();
                return DeleteSlotsResult.hasBookedSlots(scheduleId, bookedCount);
            }

            // Xóa tất cả slots
            String deleteSql = "DELETE FROM time_slots WHERE schedule_id = ?";
            deletePs = conn.prepareStatement(deleteSql);
            deletePs.setInt(1, scheduleId);
            int rows = deletePs.executeUpdate();

            conn.commit();

            System.out.println("[TimeSlotDAO] deleteByScheduleIdSafe: scheduleId=" + scheduleId
                    + ", deleted=" + rows + " slots"
                    + (bookedCount > 0 ? " (FORCE delete, " + bookedCount + " booked slots removed)" : ""));
            return DeleteSlotsResult.success(scheduleId, rows);

        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] deleteByScheduleIdSafe ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return DeleteSlotsResult.systemError("Lỗi database: " + e.getMessage());
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
            if (countPs != null) { try { countPs.close(); } catch (SQLException e) { } }
            if (deletePs != null) { try { deletePs.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Xóa tất cả time slots của một schedule (giữ backward compatibility).
     * Mặc định KHÔNG force — sẽ thất bại nếu có BOOKED slots.
     */
    public boolean deleteByScheduleId(int scheduleId) {
        DeleteSlotsResult result = deleteByScheduleIdSafe(scheduleId, false);
        return result.isSuccess();
    }

    // ──────────────────────────────────────────────
    //  Truy vấn theo doctor + ngày (dùng cho Phase 9 - Đặt lịch)
    // ──────────────────────────────────────────────

    /**
     * Lấy danh sách time slots theo doctor_id và ngày, có thể lọc theo trạng thái.
     * Dùng cho chức năng đặt lịch khám (Phase 9).
     */
    /**
     * Giống findByDoctorAndDate nhưng SELECT thêm cột ts.price — dùng riêng cho trang
     * đặt lịch bệnh nhân (cần hiển thị giá theo từng khung giờ cụ thể). Tách riêng khỏi
     * BASE_COLUMNS dùng chung để không ảnh hưởng các trang quản lý slot khác.
     */
    public List<TimeSlot> findByDoctorAndDateWithPrice(int doctorId, Date workDate, SlotStatus status) {
        StringBuilder sql = new StringBuilder("SELECT DISTINCT " + BASE_COLUMNS + ", ts.price, "
            + "d.full_name AS doctor_name, "
            + "u.full_name AS booked_by_name "
            + "FROM time_slots ts "
            + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
            + "LEFT JOIN users u ON ts.booked_by = u.id "
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
                TimeSlot ts = mapRow(rs);
                double p = rs.getDouble("price");
                if (!rs.wasNull()) ts.setPrice(p);
                list.add(ts);
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findByDoctorAndDateWithPrice ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    public List<TimeSlot> findByDoctorAndDate(int doctorId, Date workDate, SlotStatus status) {
        StringBuilder sql = new StringBuilder("SELECT DISTINCT " + BASE_COLUMNS + ", "
            + "d.full_name AS doctor_name, "
            + "u.full_name AS booked_by_name "
            + "FROM time_slots ts "
            + "LEFT JOIN doctors d ON ts.doctor_id = d.id "
            + "LEFT JOIN users u ON ts.booked_by = u.id "
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
     * Read-only reception view of all approved slots on one day. Staff can see
     * availability, but this DAO intentionally exposes no mutation operation.
     */
    public List<TimeSlot> findByDateForReception(Date workDate) {
        String sql = "SELECT " + BASE_COLUMNS + ", d.full_name AS doctor_name, "
                + "p.full_name AS booked_by_name "
                + "FROM time_slots ts "
                + "INNER JOIN doctor_schedules ds ON ds.id = ts.schedule_id "
                + "INNER JOIN doctors d ON d.id = ts.doctor_id "
                + "LEFT JOIN appointments a ON a.slot_id = ts.id "
                + " AND a.status NOT IN ('Cancelled', 'NoShow') "
                + "LEFT JOIN patients p ON p.id = a.patient_id "
                + "WHERE ts.work_date = ? AND ds.status = 'APPROVED' "
                + "ORDER BY d.full_name, ts.start_time";

        List<TimeSlot> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, workDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[TimeSlotDAO] findByDateForReception ERROR: " + e.getMessage());
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

        // booked_by có thể NULL
        int bookedBy = rs.getInt("booked_by");
        if (!rs.wasNull()) {
            ts.setBookedBy(bookedBy);
        }

        ts.setBookedAt(rs.getTimestamp("booked_at"));
        ts.setVersion(rs.getBytes("version"));
        ts.setCreatedAt(rs.getTimestamp("created_at"));
        ts.setUpdatedAt(rs.getTimestamp("updated_at"));

        // Join fields
        try { ts.setDoctorName(rs.getString("doctor_name")); } catch (SQLException e) { }
        try { ts.setBookedByName(rs.getString("booked_by_name")); } catch (SQLException e) { }

        return ts;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }

    // ═══════════════════════════════════════════════════════════
    //  INNER CLASSES: Result objects
    // ═══════════════════════════════════════════════════════════

    /**
     * Kết quả của thao tác đặt slot (bookSlotAtomic).
     */
    public static class BookingResult {
        private final boolean success;
        private final TimeSlot bookedSlot;
        private final String errorCode;    // NOT_FOUND / NOT_AVAILABLE / SYSTEM_ERROR
        private final String errorMessage;
        private final int slotId;

        private BookingResult(boolean success, TimeSlot bookedSlot,
                              String errorCode, String errorMessage, int slotId) {
            this.success = success;
            this.bookedSlot = bookedSlot;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
            this.slotId = slotId;
        }

        public static BookingResult success(TimeSlot slot) {
            return new BookingResult(true, slot, null, null, slot.getId());
        }

        public static BookingResult slotNotFound(int slotId) {
            return new BookingResult(false, null, "NOT_FOUND",
                    "Khung giờ khám #" + slotId + " không tồn tại.", slotId);
        }

        public static BookingResult slotNotAvailable(int slotId, String currentStatus) {
            return new BookingResult(false, null, "NOT_AVAILABLE",
                    "Khung giờ khám #" + slotId + " không còn trống (trạng thái: "
                    + currentStatus + "). Vui lòng chọn khung giờ khác.", slotId);
        }

        public static BookingResult systemError(String message) {
            return new BookingResult(false, null, "SYSTEM_ERROR", message, 0);
        }

        public boolean isSuccess() { return success; }
        public TimeSlot getBookedSlot() { return bookedSlot; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
        public int getSlotId() { return slotId; }
    }

    /**
     * Kết quả của thao tác hủy slot (cancelSlotAtomic).
     */
    public static class CancelResult {
        private final boolean success;
        private final int slotId;
        private final String errorCode;
        private final String errorMessage;

        private CancelResult(boolean success, int slotId,
                             String errorCode, String errorMessage) {
            this.success = success;
            this.slotId = slotId;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public static CancelResult success(int slotId) {
            return new CancelResult(true, slotId, null, null);
        }

        public static CancelResult slotNotFound(int slotId) {
            return new CancelResult(false, slotId, "NOT_FOUND",
                    "Khung giờ khám #" + slotId + " không tồn tại.");
        }

        public static CancelResult slotNotBooked(int slotId, String currentStatus) {
            return new CancelResult(false, slotId, "NOT_BOOKED",
                    "Khung giờ khám #" + slotId + " không ở trạng thái Đã đặt (hiện tại: "
                    + currentStatus + ").");
        }

        public static CancelResult concurrentModification(int slotId) {
            return new CancelResult(false, slotId, "CONCURRENT",
                    "Khung giờ khám #" + slotId + " vừa bị thay đổi bởi người khác.");
        }

        public static CancelResult systemError(String message) {
            return new CancelResult(false, 0, "SYSTEM_ERROR", message);
        }

        public boolean isSuccess() { return success; }
        public int getSlotId() { return slotId; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }

    /**
     * Kết quả của thao tác xóa slots an toàn (deleteByScheduleIdSafe).
     */
    public static class DeleteSlotsResult {
        private final boolean success;
        private final int scheduleId;
        private final int deletedCount;
        private final int bookedCount;
        private final String errorCode;
        private final String errorMessage;

        private DeleteSlotsResult(boolean success, int scheduleId, int deletedCount,
                                  int bookedCount, String errorCode, String errorMessage) {
            this.success = success;
            this.scheduleId = scheduleId;
            this.deletedCount = deletedCount;
            this.bookedCount = bookedCount;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public static DeleteSlotsResult success(int scheduleId, int deletedCount) {
            return new DeleteSlotsResult(true, scheduleId, deletedCount, 0, null, null);
        }

        public static DeleteSlotsResult hasBookedSlots(int scheduleId, int bookedCount) {
            return new DeleteSlotsResult(false, scheduleId, 0, bookedCount, "HAS_BOOKED",
                    "Không thể xóa: lịch trực #" + scheduleId + " có " + bookedCount
                    + " khung giờ đã được bệnh nhân đặt. "
                    + "Vui lòng xử lý các lịch hẹn này trước khi xóa.");
        }

        public static DeleteSlotsResult systemError(String message) {
            return new DeleteSlotsResult(false, 0, 0, 0, "SYSTEM_ERROR", message);
        }

        public boolean isSuccess() { return success; }
        public int getScheduleId() { return scheduleId; }
        public int getDeletedCount() { return deletedCount; }
        public int getBookedCount() { return bookedCount; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }
}
