package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.enums.ScheduleStatus;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng doctor_schedules — quản lý lịch trực bác sĩ.
 *
 * <p>Hỗ trợ các thao tác:
 * <ul>
 *   <li>CRUD lịch trực</li>
 *   <li>Duyệt / Từ chối / Hủy lịch trực (có optimistic locking)</li>
 *   <li>Tra cứu theo bác sĩ, ngày, trạng thái</li>
 *   <li>Kiểm tra trùng lịch</li>
 *   <li>Kiểm tra số slot đã BOOKED trước khi hủy/sửa</li>
 * </ul>
 *
 * <p><strong>Concurrency strategy:</strong>
 * <ul>
 *   <li>Approve: WHERE status='PENDING' — nếu 2 Manager cùng duyệt, chỉ 1 thành công</li>
 *   <li>Cancel: Kiểm tra booked slots trước, dùng transaction</li>
 *   <li>Modify: Không cho phép sửa nếu đã có slot BOOKED</li>
 * </ul>
 */
public class DoctorScheduleDAO {

    private static final String BASE_COLUMNS =
        "ds.id, ds.doctor_id, ds.work_date, ds.start_time, ds.end_time, "
        + "ds.max_slots, ds.status, ds.rejection_reason, "
        + "ds.approved_by, ds.approved_at, ds.created_by, ds.created_at, ds.updated_at, "
        + "ds.notes, ds.is_approved, "
        + "ds.cancelled_by, ds.cancelled_at, ds.cancellation_reason";

    /**
     * Lấy danh sách lịch trực có phân trang + lọc.
     */
    public List<DoctorSchedule> findAll(int offset, int pageSize,
                                         String status, Integer doctorId,
                                         Date dateFrom, Date dateTo) {
        StringBuilder sql = new StringBuilder("SELECT ")
            .append(BASE_COLUMNS)
            .append(", d.full_name AS doctor_name, d.specialization AS doctor_specialization ")
            .append(", u.full_name AS approved_by_name ")
            .append(", cu.full_name AS cancelled_by_name ")
            .append("FROM doctor_schedules ds ")
            .append("LEFT JOIN doctors d ON ds.doctor_id = d.id ")
            .append("LEFT JOIN users u ON ds.approved_by = u.id ")
            .append("LEFT JOIN users cu ON ds.cancelled_by = cu.id ")
            .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND ds.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (doctorId != null) {
            sql.append("AND ds.doctor_id = ? ");
            params.add(doctorId);
        }
        if (dateFrom != null) {
            sql.append("AND ds.work_date >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null) {
            sql.append("AND ds.work_date <= ? ");
            params.add(dateTo);
        }

        sql.append("ORDER BY ds.id ASC ")
           .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        List<DoctorSchedule> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof Date) {
                    ps.setDate(i + 1, (Date) param);
                }
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] findAll ERROR: " + e.getMessage());
            throw new RuntimeException("Lỗi database khi lấy danh sách lịch trực", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Đếm tổng số lịch trực (dùng cho phân trang).
     */
    public int countAll(String status, Integer doctorId,
                        Date dateFrom, Date dateTo) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total ")
            .append("FROM doctor_schedules ds WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND ds.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (doctorId != null) {
            sql.append("AND ds.doctor_id = ? ");
            params.add(doctorId);
        }
        if (dateFrom != null) {
            sql.append("AND ds.work_date >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null) {
            sql.append("AND ds.work_date <= ? ");
            params.add(dateTo);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof Date) {
                    ps.setDate(i + 1, (Date) param);
                }
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] countAll ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Tìm lịch trực theo id (kèm join để hiển thị).
     * Kèm thêm số slot đã BOOKED để kiểm tra nghiệp vụ.
     */
    public DoctorSchedule findById(int id) {
        String sql = "SELECT " + BASE_COLUMNS
            + ", d.full_name AS doctor_name, d.specialization AS doctor_specialization "
            + ", u.full_name AS approved_by_name "
            + ", cu.full_name AS cancelled_by_name "
            + ", (SELECT COUNT(*) FROM time_slots "
            + "   WHERE schedule_id = ds.id AND status = 'BOOKED') AS booked_slot_count "
            + "FROM doctor_schedules ds "
            + "LEFT JOIN doctors d ON ds.doctor_id = d.id "
            + "LEFT JOIN users u ON ds.approved_by = u.id "
            + "LEFT JOIN users cu ON ds.cancelled_by = cu.id "
            + "WHERE ds.id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRowWithJoin(rs);
            }
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] findById ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    /**
     * Duyệt lịch trực với optimistic locking.
     * Chỉ UPDATE nếu status hiện tại = 'PENDING' — nếu 2 Manager cùng duyệt,
     * chỉ người đầu tiên thành công, người thứ 2 nhận rowsAffected = 0.
     *
     * @param scheduleId ID lịch trực
     * @param approvedBy user_id của Admin/Manager thực hiện duyệt
     * @return ApproveResult chứa kết quả: thành công / đã bị duyệt / không tồn tại
     */
    public ApproveResult approveAtomic(int scheduleId, int approvedBy) {
        Connection conn = null;
        PreparedStatement checkPs = null;
        PreparedStatement updatePs = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Kiểm tra tồn tại + trạng thái hiện tại
            String checkSql = "SELECT id, status, doctor_id, work_date, start_time, end_time "
                            + "FROM doctor_schedules WITH (UPDLOCK, ROWLOCK) "
                            + "WHERE id = ?";
            checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, scheduleId);
            rs = checkPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return ApproveResult.notFound(scheduleId);
            }

            String currentStatus = rs.getString("status");
            if (!"PENDING".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return ApproveResult.alreadyProcessed(scheduleId, currentStatus);
            }

            // Step 2: UPDATE với điều kiện status='PENDING' (optimistic lock)
            String updateSql = "UPDATE doctor_schedules SET "
                    + "status = 'APPROVED', is_approved = 1, "
                    + "approved_by = ?, approved_at = GETDATE(), "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ? AND status = 'PENDING'";

            updatePs = conn.prepareStatement(updateSql);
            updatePs.setInt(1, approvedBy);
            updatePs.setInt(2, scheduleId);
            int rowsAffected = updatePs.executeUpdate();

            if (rowsAffected == 0) {
                conn.rollback();
                return ApproveResult.alreadyProcessed(scheduleId, currentStatus);
            }

            // Step 3: Lấy thông tin để sinh slots
            int doctorId = rs.getInt("doctor_id");
            Date workDate = rs.getDate("work_date");
            Time startTime = rs.getTime("start_time");
            Time endTime = rs.getTime("end_time");

            // Step 4: Sinh time slots trong cùng transaction
            TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
            int slotsGenerated = timeSlotDAO.generateSlots(
                    scheduleId, doctorId, workDate, startTime, endTime, conn);

            if (slotsGenerated < 0) {
                // Sinh slot thất bại → rollback toàn bộ
                conn.rollback();
                return ApproveResult.systemError(scheduleId,
                        "Không thể sinh khung giờ khám cho lịch trực này.");
            }

            conn.commit();

            System.out.println("[DoctorScheduleDAO] approveAtomic SUCCESS: scheduleId="
                    + scheduleId + ", approvedBy=" + approvedBy
                    + ", slotsGenerated=" + slotsGenerated);
            return ApproveResult.success(scheduleId, slotsGenerated);

        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] approveAtomic ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return ApproveResult.systemError(scheduleId,
                    "Lỗi database: " + e.getMessage());
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
            if (checkPs != null) { try { checkPs.close(); } catch (SQLException e) { } }
            if (updatePs != null) { try { updatePs.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Duyệt lịch trực (giữ backward compatibility — dùng cho code cũ).
     * Phương thức này chỉ UPDATE, KHÔNG sinh slots (sinh slots do Service xử lý sau).
     */
    public boolean approve(int scheduleId, int approvedBy) {
        String sql = "UPDATE doctor_schedules SET "
                   + "status = 'APPROVED', is_approved = 1, "
                   + "approved_by = ?, approved_at = GETDATE(), "
                   + "updated_at = GETDATE() "
                   + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, approvedBy);
            ps.setInt(2, scheduleId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] approve ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Từ chối lịch trực.
     */
    public boolean reject(int scheduleId, int rejectedBy, String rejectionReason) {
        String sql = "UPDATE doctor_schedules SET "
                   + "status = 'REJECTED', is_approved = 0, "
                   + "approved_by = ?, approved_at = GETDATE(), "
                   + "rejection_reason = ?, "
                   + "updated_at = GETDATE() "
                   + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, rejectedBy);
            ps.setString(2, rejectionReason);
            ps.setInt(3, scheduleId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] reject ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Hủy lịch trực với kiểm tra booked slots.
     * Dùng transaction để đảm bảo toàn vẹn.
     *
     * @param scheduleId       ID lịch trực
     * @param cancelledBy      user_id người hủy
     * @param reason           lý do hủy
     * @param hasBookedSlots   số slot đã BOOKED (được kiểm tra TRƯỚC bởi Service)
     * @return CancelScheduleResult
     */
    public CancelScheduleResult cancelAtomic(int scheduleId, int cancelledBy,
                                              String reason, int hasBookedSlots) {
        Connection conn = null;
        PreparedStatement checkPs = null;
        PreparedStatement updatePs = null;
        PreparedStatement slotUpdatePs = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Kiểm tra tồn tại + trạng thái
            String checkSql = "SELECT id, status FROM doctor_schedules "
                            + "WITH (UPDLOCK, ROWLOCK) WHERE id = ?";
            checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, scheduleId);
            rs = checkPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return CancelScheduleResult.notFound(scheduleId);
            }

            String currentStatus = rs.getString("status");

            // Chỉ được hủy lịch APPROVED hoặc PENDING
            if (!"APPROVED".equalsIgnoreCase(currentStatus)
                    && !"PENDING".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return CancelScheduleResult.invalidStatus(scheduleId, currentStatus);
            }

            // Step 2: Nếu là APPROVED và có booked slots, đánh dấu các slot đó
            //    về trạng thái cần chuyển đổi (notes ghi chú)
            if ("APPROVED".equalsIgnoreCase(currentStatus) && hasBookedSlots > 0) {
                // Đánh dấu các slot BOOKED để Manager xử lý sau
                String slotNoteSql = "UPDATE time_slots SET "
                        + "notes = ISNULL(notes, '') + N' [LỊCH TRỰC BỊ HỦY — cần đổi bác sĩ hoặc lịch mới]', "
                        + "updated_at = GETDATE() "
                        + "WHERE schedule_id = ? AND status = 'BOOKED'";
                slotUpdatePs = conn.prepareStatement(slotNoteSql);
                slotUpdatePs.setInt(1, scheduleId);
                slotUpdatePs.executeUpdate();
            }

            // Step 3: Cập nhật trạng thái schedule
            String updateSql = "UPDATE doctor_schedules SET "
                    + "status = 'CANCELLED', is_approved = 0, "
                    + "cancelled_by = ?, cancelled_at = GETDATE(), "
                    + "cancellation_reason = ?, "
                    + "updated_at = GETDATE() "
                    + "WHERE id = ?";

            updatePs = conn.prepareStatement(updateSql);
            updatePs.setInt(1, cancelledBy);
            updatePs.setString(2, reason);
            updatePs.setInt(3, scheduleId);
            int rowsAffected = updatePs.executeUpdate();

            if (rowsAffected == 0) {
                conn.rollback();
                return CancelScheduleResult.concurrentModification(scheduleId);
            }

            conn.commit();

            System.out.println("[DoctorScheduleDAO] cancelAtomic SUCCESS: scheduleId="
                    + scheduleId + ", cancelledBy=" + cancelledBy
                    + ", hadBookedSlots=" + hasBookedSlots);
            return CancelScheduleResult.success(scheduleId, hasBookedSlots);

        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] cancelAtomic ERROR: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            return CancelScheduleResult.systemError(scheduleId,
                    "Lỗi database: " + e.getMessage());
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
            if (checkPs != null) { try { checkPs.close(); } catch (SQLException e) { } }
            if (updatePs != null) { try { updatePs.close(); } catch (SQLException e) { } }
            if (slotUpdatePs != null) { try { slotUpdatePs.close(); } catch (SQLException e) { } }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Kiểm tra trùng lịch: bác sĩ đã có lịch APPROVED trong cùng ngày + khung giờ chưa.
     */
    public boolean hasApprovedConflict(int doctorId, Date workDate,
                                        Time startTime, Time endTime,
                                        Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total ")
            .append("FROM doctor_schedules ds ")
            .append("WHERE ds.doctor_id = ? ")
            .append("AND ds.work_date = ? ")
            .append("AND ds.status = 'APPROVED' ")
            .append("AND ds.start_time < ? AND ds.end_time > ? ");

        if (excludeId != null) {
            sql.append("AND ds.id <> ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, doctorId);
            ps.setDate(2, workDate);
            ps.setTime(3, endTime);
            ps.setTime(4, startTime);
            if (excludeId != null) {
                ps.setInt(5, excludeId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] hasApprovedConflict ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Đếm số bác sĩ đã được APPROVED trong cùng ca trực.
     */
    public int countApprovedInSameShift(Date workDate, Time startTime, Time endTime) {
        String sql = "SELECT COUNT(*) AS total FROM doctor_schedules "
                   + "WHERE work_date = ? AND start_time = ? AND end_time = ? "
                   + "AND status = 'APPROVED'";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, workDate);
            ps.setTime(2, startTime);
            ps.setTime(3, endTime);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] countApprovedInSameShift ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Lấy danh sách lịch trực của một bác sĩ.
     */
    public List<DoctorSchedule> findByDoctorId(int doctorId, int offset, int pageSize) {
        return findAll(offset, pageSize, null, doctorId, null, null);
    }

    /**
     * Đếm số lịch trực theo trạng thái (dùng cho KPI).
     */
    public int countByStatus(ScheduleStatus status) {
        String sql = "SELECT COUNT(*) AS total FROM doctor_schedules WHERE status = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status.name());
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] countByStatus ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    // ── Private helpers ──

    private DoctorSchedule mapRowWithJoin(ResultSet rs) throws SQLException {
        DoctorSchedule ds = new DoctorSchedule();
        ds.setId(rs.getInt("id"));
        ds.setDoctorId(rs.getInt("doctor_id"));
        ds.setWorkDate(rs.getDate("work_date"));
        ds.setStartTime(rs.getTime("start_time"));
        ds.setEndTime(rs.getTime("end_time"));
        ds.setMaxSlots(rs.getInt("max_slots"));

        String statusStr = rs.getString("status");
        ds.setStatus(ScheduleStatus.fromString(statusStr));

        ds.setRejectionReason(rs.getString("rejection_reason"));

        int approvedBy = rs.getInt("approved_by");
        if (!rs.wasNull()) ds.setApprovedBy(approvedBy);

        ds.setApprovedAt(rs.getTimestamp("approved_at"));

        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) ds.setCreatedBy(createdBy);

        ds.setCreatedAt(rs.getTimestamp("created_at"));
        ds.setUpdatedAt(rs.getTimestamp("updated_at"));
        ds.setNotes(rs.getString("notes"));
        ds.setApproved(rs.getBoolean("is_approved"));

        // Cancellation fields
        int cancelledBy = rs.getInt("cancelled_by");
        if (!rs.wasNull()) ds.setCancelledBy(cancelledBy);

        ds.setCancelledAt(rs.getTimestamp("cancelled_at"));
        ds.setCancellationReason(rs.getString("cancellation_reason"));

        // Join fields
        try { ds.setDoctorName(rs.getString("doctor_name")); } catch (SQLException e) { }
        try { ds.setDoctorSpecialization(rs.getString("doctor_specialization")); } catch (SQLException e) { }
        try { ds.setApprovedByName(rs.getString("approved_by_name")); } catch (SQLException e) { }
        try { ds.setCancelledByName(rs.getString("cancelled_by_name")); } catch (SQLException e) { }

        // Booked slot count (subquery — có thể NULL nếu không có subquery)
        try {
            ds.setBookedSlotCount(rs.getInt("booked_slot_count"));
        } catch (SQLException e) { }

        // Shift label
        if (ds.getStartTime() != null && ds.getEndTime() != null) {
            ds.setShiftLabel(DoctorSchedule.buildShiftLabel(
                ds.getStartTime().toString(), ds.getEndTime().toString()));
        }

        return ds;
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
     * Kết quả của thao tác duyệt lịch trực (approveAtomic).
     */
    public static class ApproveResult {
        private final boolean success;
        private final int scheduleId;
        private final int slotsGenerated;
        private final String errorCode;
        private final String errorMessage;

        private ApproveResult(boolean success, int scheduleId, int slotsGenerated,
                              String errorCode, String errorMessage) {
            this.success = success;
            this.scheduleId = scheduleId;
            this.slotsGenerated = slotsGenerated;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public static ApproveResult success(int scheduleId, int slotsGenerated) {
            return new ApproveResult(true, scheduleId, slotsGenerated, null, null);
        }

        public static ApproveResult notFound(int scheduleId) {
            return new ApproveResult(false, scheduleId, 0, "NOT_FOUND",
                    "Lịch trực #" + scheduleId + " không tồn tại.");
        }

        public static ApproveResult alreadyProcessed(int scheduleId, String currentStatus) {
            return new ApproveResult(false, scheduleId, 0, "ALREADY_PROCESSED",
                    "Lịch trực #" + scheduleId + " đã được xử lý trước đó "
                    + "(trạng thái hiện tại: " + currentStatus + "). "
                    + "Có thể một Manager khác vừa duyệt lịch này.");
        }

        public static ApproveResult systemError(int scheduleId, String message) {
            return new ApproveResult(false, scheduleId, 0, "SYSTEM_ERROR", message);
        }

        public boolean isSuccess() { return success; }
        public int getScheduleId() { return scheduleId; }
        public int getSlotsGenerated() { return slotsGenerated; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }

    /**
     * Kết quả của thao tác hủy lịch trực (cancelAtomic).
     */
    public static class CancelScheduleResult {
        private final boolean success;
        private final int scheduleId;
        private final int bookedSlotsAffected;
        private final String errorCode;
        private final String errorMessage;

        private CancelScheduleResult(boolean success, int scheduleId,
                                      int bookedSlotsAffected,
                                      String errorCode, String errorMessage) {
            this.success = success;
            this.scheduleId = scheduleId;
            this.bookedSlotsAffected = bookedSlotsAffected;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public static CancelScheduleResult success(int scheduleId, int bookedSlotsAffected) {
            return new CancelScheduleResult(true, scheduleId, bookedSlotsAffected, null, null);
        }

        public static CancelScheduleResult notFound(int scheduleId) {
            return new CancelScheduleResult(false, scheduleId, 0, "NOT_FOUND",
                    "Lịch trực #" + scheduleId + " không tồn tại.");
        }

        public static CancelScheduleResult invalidStatus(int scheduleId, String status) {
            return new CancelScheduleResult(false, scheduleId, 0, "INVALID_STATUS",
                    "Không thể hủy lịch trực ở trạng thái " + status + ".");
        }

        public static CancelScheduleResult concurrentModification(int scheduleId) {
            return new CancelScheduleResult(false, scheduleId, 0, "CONCURRENT",
                    "Lịch trực #" + scheduleId + " vừa bị thay đổi bởi người khác.");
        }

        public static CancelScheduleResult systemError(int scheduleId, String message) {
            return new CancelScheduleResult(false, scheduleId, 0, "SYSTEM_ERROR", message);
        }

        public boolean isSuccess() { return success; }
        public int getScheduleId() { return scheduleId; }
        public int getBookedSlotsAffected() { return bookedSlotsAffected; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }
}
