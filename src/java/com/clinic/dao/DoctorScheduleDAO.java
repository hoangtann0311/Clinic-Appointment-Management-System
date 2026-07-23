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
 *   <li>Duyệt / Từ chối lịch trực</li>
 *   <li>Tra cứu theo bác sĩ, ngày, trạng thái</li>
 *   <li>Kiểm tra trùng lịch</li>
 * </ul>
 */
public class DoctorScheduleDAO {

    private static final String BASE_COLUMNS =
        "ds.id, ds.doctor_id, ds.work_date, ds.start_time, ds.end_time, "
        + "ds.max_slots, ds.status, ds.rejection_reason, "
        + "ds.approved_by, ds.approved_at, ds.created_by, ds.created_at, ds.updated_at, "
        + "ds.notes, ds.is_approved";

    /**
     * Lấy danh sách lịch trực có phân trang + lọc.
     *
     * @param offset     vị trí bắt đầu (cho phân trang)
     * @param pageSize   số dòng mỗi trang
     * @param status     lọc theo trạng thái (null = tất cả)
     * @param doctorId   lọc theo bác sĩ (null = tất cả)
     * @param dateFrom   lọc từ ngày (null = không lọc)
     * @param dateTo     lọc đến ngày (null = không lọc)
     */
    public List<DoctorSchedule> findAll(int offset, int pageSize,
                                         String status, Integer doctorId,
                                         Date dateFrom, Date dateTo) {
        StringBuilder sql = new StringBuilder("SELECT ")
            .append(BASE_COLUMNS)
            .append(", d.full_name AS doctor_name, d.specialization AS doctor_specialization ")
            .append(", u.full_name AS approved_by_name ")
            .append("FROM doctor_schedules ds ")
            .append("LEFT JOIN doctors d ON ds.doctor_id = d.id ")
            .append("LEFT JOIN users u ON ds.approved_by = u.id ")
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

        sql.append("ORDER BY ds.work_date DESC, ds.start_time ASC ")
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
            throw new RuntimeException("Lỗi cơ sở dữ liệu khi lấy danh sách lịch làm việc", e);
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
     */
    public DoctorSchedule findById(int id) {
        String sql = "SELECT " + BASE_COLUMNS
            + ", d.full_name AS doctor_name, d.specialization AS doctor_specialization "
            + ", u.full_name AS approved_by_name "
            + "FROM doctor_schedules ds "
            + "LEFT JOIN doctors d ON ds.doctor_id = d.id "
            + "LEFT JOIN users u ON ds.approved_by = u.id "
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
     * Duyệt lịch trực — cập nhật status = APPROVED, ghi nhận người duyệt.
     *
     * @param scheduleId ID lịch trực
     * @param approvedBy user_id của Admin/Manager thực hiện duyệt
     * @return true nếu thành công
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
     * Từ chối lịch trực — cập nhật status = REJECTED, lưu lý do.
     *
     * @param scheduleId      ID lịch trực
     * @param rejectedBy      user_id của Admin/Manager thực hiện từ chối
     * @param rejectionReason lý do từ chối (bắt buộc)
     * @return true nếu thành công
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
     * Kiểm tra trùng lịch: bác sĩ đã có lịch APPROVED trong cùng ngày + khung giờ chưa.
     *
     * @param doctorId   ID bác sĩ
     * @param workDate   ngày làm việc
     * @param startTime  giờ bắt đầu
     * @param endTime    giờ kết thúc
     * @param excludeId  ID cần loại trừ (khi sửa), null nếu không
     * @return true nếu có trùng lịch APPROVED
     */
    public boolean hasApprovedConflict(int doctorId, Date workDate,
                                        Time startTime, Time endTime,
                                        Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total ")
            .append("FROM doctor_schedules ds ")
            .append("WHERE ds.doctor_id = ? ")
            .append("AND ds.work_date = ? ")
            .append("AND ds.status = 'APPROVED' ")
            // Kiểm tra trùng khung giờ: start_time < new_end AND end_time > new_start
            .append("AND ds.start_time < CAST(? AS time) AND ds.end_time > CAST(? AS time) ");

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
     * Đếm số bác sĩ đã được APPROVED trong cùng ca trực (cùng ngày + cùng khung giờ).
     * Dùng để kiểm tra giới hạn max_slots.
     */
    public int countApprovedInSameShift(Date workDate, Time startTime, Time endTime) {
        String sql = "SELECT COUNT(*) AS total FROM doctor_schedules "
                   + "WHERE work_date = ? AND start_time = CAST(? AS time) AND end_time = CAST(? AS time) "
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
     * Lấy danh sách lịch trực của một bác sĩ cụ thể (dùng cho bác sĩ xem lịch của mình).
     */
    public List<DoctorSchedule> findByDoctorId(int doctorId, int offset, int pageSize) {
        return findAll(offset, pageSize, null, doctorId, null, null);
    }

    /**
     * Đếm số lịch trực theo trạng thái (dùng cho KPI cards thống kê).
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

    /**
     * Ánh xạ ResultSet → DoctorSchedule (có join doctor + users).
     */
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
        if (!rs.wasNull()) {
            ds.setApprovedBy(approvedBy);
        }
        ds.setApprovedAt(rs.getTimestamp("approved_at"));

        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            ds.setCreatedBy(createdBy);
        }
        ds.setCreatedAt(rs.getTimestamp("created_at"));
        ds.setUpdatedAt(rs.getTimestamp("updated_at"));
        ds.setNotes(rs.getString("notes"));
        ds.setApproved(rs.getBoolean("is_approved"));

        // Join fields
        try { ds.setDoctorName(rs.getString("doctor_name")); } catch (SQLException e) { }
        try { ds.setDoctorSpecialization(rs.getString("doctor_specialization")); } catch (SQLException e) { }
        try { ds.setApprovedByName(rs.getString("approved_by_name")); } catch (SQLException e) { }

        // Shift label tiện hiển thị
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
    // ─────────────────────────────────────────────────────────────────
// CÁC METHOD BỔ SUNG — thêm vào cuối class DoctorScheduleDAO.java
// Dán VÀO TRƯỚC dòng "// ── Private helpers ──"
// ─────────────────────────────────────────────────────────────────

    /**
     * Tạo mới lịch làm việc (bác sĩ đăng ký, trạng thái PENDING).
     *
     * @return true nếu INSERT thành công
     */
    public boolean insert(DoctorSchedule schedule) {
        String sql = "INSERT INTO doctor_schedules "
                   + "(doctor_id, work_date, start_time, end_time, max_slots, "
                   + " status, notes, created_by, created_at, updated_at, is_approved) "
                   + "VALUES (?, ?, ?, ?, ?, 'PENDING', ?, ?, GETDATE(), GETDATE(), 0)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, schedule.getDoctorId());
            ps.setDate(2, schedule.getWorkDate());
            ps.setTime(3, schedule.getStartTime());
            ps.setTime(4, schedule.getEndTime());
            ps.setInt(5, schedule.getMaxSlots());
            ps.setString(6, schedule.getNotes());
            if (schedule.getCreatedBy() != null) {
                ps.setInt(7, schedule.getCreatedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] insert ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Hủy lịch trực — chuyển status → CANCELLED.
     * Chỉ được hủy lịch đang PENDING.
     *
     * @param scheduleId ID lịch trực
     * @return true nếu UPDATE thành công
     */
    public boolean cancel(int scheduleId) {
        String sql = "UPDATE doctor_schedules "
                   + "SET status = 'CANCELLED', is_approved = 0, updated_at = GETDATE() "
                   + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, scheduleId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] cancel ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Kiểm tra xem bác sĩ đã có lịch PENDING hoặc APPROVED trùng ngày + khung giờ chưa.
     * Dùng khi bác sĩ đăng ký lịch mới để tránh tạo trùng.
     *
     * @param doctorId  ID bác sĩ
     * @param workDate  ngày làm việc
     * @param startTime giờ bắt đầu
     * @param endTime   giờ kết thúc
     * @param excludeId ID cần loại trừ (khi sửa), null nếu tạo mới
     * @return true nếu có xung đột
     */
    public boolean hasConflictForDoctor(int doctorId, Date workDate,
                                         Time startTime, Time endTime,
                                         Integer excludeId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) AS total FROM doctor_schedules "
              + "WHERE doctor_id = ? "
              + "AND work_date = ? "
              + "AND status IN ('PENDING', 'APPROVED') "
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
            ps.setInt(1, doctorId);
            ps.setDate(2, workDate);
            ps.setTime(3, endTime);   // start_time < new_end
            ps.setTime(4, startTime); // end_time   > new_start
            if (excludeId != null) {
                ps.setInt(5, excludeId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] hasConflictForDoctor ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Đếm số bệnh nhân đã đặt lịch hẹn trong một slot cụ thể.
     * Dùng để hiển thị "đã đặt / tối đa" trên giao diện.
     *
     * @param doctorId  ID bác sĩ
     * @param workDate  ngày làm việc
     * @param startTime giờ bắt đầu slot
     * @return số appointment đã được confirm/pending trong slot đó
     */
    public int countBookedAppointments(int doctorId, Date workDate, Time startTime) {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE doctor_id = ? "
                   + "AND appointment_date = ? "
                   + "AND time_slot = CAST(? AS time) "
                   + "AND status NOT IN ('cancelled', 'CANCELLED')";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, doctorId);
            ps.setDate(2, workDate);
            ps.setTime(3, startTime);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("[DoctorScheduleDAO] countBookedAppointments ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    public static class ApproveResult {
        private boolean success;
        private int slotsGenerated;
        private String errorCode;
        private String errorMessage;

        public ApproveResult(boolean success, int slotsGenerated, String errorCode, String errorMessage) {
            this.success = success;
            this.slotsGenerated = slotsGenerated;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public boolean isSuccess() { return success; }
        public int getSlotsGenerated() { return slotsGenerated; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }

    public static class CancelScheduleResult {
        private boolean success;
        private String errorCode;
        private String errorMessage;

        public CancelScheduleResult(boolean success, String errorCode, String errorMessage) {
            this.success = success;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        public boolean isSuccess() { return success; }
        public String getErrorCode() { return errorCode; }
        public String getErrorMessage() { return errorMessage; }
    }

    public ApproveResult approveAtomic(int scheduleId, int approvedBy) {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            int doctorId;
            Date workDate;
            try (PreparedStatement seedPs = conn.prepareStatement(
                    "SELECT doctor_id, work_date FROM doctor_schedules WHERE id = ?")) {
                seedPs.setInt(1, scheduleId);
                try (ResultSet rs = seedPs.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return new ApproveResult(false, 0, "NOT_FOUND", "Lịch làm việc không tồn tại.");
                    }
                    doctorId = rs.getInt("doctor_id");
                    workDate = rs.getDate("work_date");
                }
            }

            // The deployed SQL login cannot use sp_getapplock. Approvals are
            // low-volume, so the stable Manager role row is a database-backed
            // mutex covering conflict, capacity, state change and slot creation.
            try (PreparedStatement lockPs = conn.prepareStatement(
                    "SELECT id FROM roles WITH (UPDLOCK, HOLDLOCK) WHERE id = 3")) {
                try (ResultSet rs = lockPs.executeQuery()) {
                    if (!rs.next()) throw new SQLException("Không thể khóa quy trình xác nhận lịch làm việc.");
                }
            }

            Time startTime;
            Time endTime;
            int maxSlots;
            try (PreparedStatement schedulePs = conn.prepareStatement(
                    "SELECT doctor_id, work_date, start_time, end_time, max_slots, status "
                            + "FROM doctor_schedules WITH (UPDLOCK, HOLDLOCK) WHERE id = ?")) {
                schedulePs.setInt(1, scheduleId);
                try (ResultSet rs = schedulePs.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return new ApproveResult(false, 0, "NOT_FOUND", "Lịch làm việc không tồn tại.");
                    }
                    if (!"PENDING".equalsIgnoreCase(rs.getString("status"))) {
                        conn.rollback();
                        return new ApproveResult(false, 0, "ALREADY_PROCESSED", "Lịch làm việc đã được xử lý.");
                    }
                    doctorId = rs.getInt("doctor_id");
                    workDate = rs.getDate("work_date");
                    startTime = rs.getTime("start_time");
                    endTime = rs.getTime("end_time");
                    maxSlots = rs.getInt("max_slots");
                }
            }

            try (PreparedStatement conflictPs = conn.prepareStatement(
                    "SELECT TOP 1 id FROM doctor_schedules WITH (UPDLOCK, HOLDLOCK) "
                            + "WHERE doctor_id = ? AND work_date = ? AND status = 'APPROVED' "
                            + "AND start_time < CAST(? AS time) AND end_time > CAST(? AS time) AND id <> ?")) {
                conflictPs.setInt(1, doctorId);
                conflictPs.setDate(2, workDate);
                conflictPs.setTime(3, endTime);
                conflictPs.setTime(4, startTime);
                conflictPs.setInt(5, scheduleId);
                try (ResultSet rs = conflictPs.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        return new ApproveResult(false, 0, "CONFLICT", "Bác sĩ đã có lịch làm việc được xác nhận trùng thời gian.");
                    }
                }
            }

            if (maxSlots > 0) {
                try (PreparedStatement capacityPs = conn.prepareStatement(
                        "SELECT COUNT(*) FROM doctor_schedules WITH (UPDLOCK, HOLDLOCK) "
                                + "WHERE work_date = ? AND start_time = CAST(? AS time) AND end_time = CAST(? AS time) AND status = 'APPROVED'")) {
                    capacityPs.setDate(1, workDate);
                    capacityPs.setTime(2, startTime);
                    capacityPs.setTime(3, endTime);
                    try (ResultSet rs = capacityPs.executeQuery()) {
                        if (rs.next() && rs.getInt(1) >= maxSlots) {
                            conn.rollback();
                            return new ApproveResult(false, 0, "FULL_SLOTS", "Ca trực đã đủ số lượng bác sĩ tối đa.");
                        }
                    }
                }
            }

            try (PreparedStatement approvePs = conn.prepareStatement(
                    "UPDATE doctor_schedules SET status = 'APPROVED', is_approved = 1, approved_by = ?, "
                            + "approved_at = GETDATE(), updated_at = GETDATE() WHERE id = ? AND status = 'PENDING'")) {
                approvePs.setInt(1, approvedBy);
                approvePs.setInt(2, scheduleId);
                if (approvePs.executeUpdate() != 1) {
                    conn.rollback();
                    return new ApproveResult(false, 0, "ALREADY_PROCESSED", "Lịch làm việc đã được xử lý.");
                }
            }

            int slotsGenerated = new TimeSlotDAO().generateSlots(
                    scheduleId, doctorId, workDate, startTime, endTime, conn);
            if (slotsGenerated <= 0) {
                conn.rollback();
                return new ApproveResult(false, 0, "SYSTEM_ERROR", "Không thể tạo khung giờ cho lịch làm việc.");
            }
            conn.commit();
            return new ApproveResult(true, slotsGenerated, null, null);
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return new ApproveResult(false, 0, "SYSTEM_ERROR", e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED); } catch (SQLException ignored) { }
                try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            }
            closeResources(conn, null, null);
        }
    }


    public CancelScheduleResult cancelAtomic(int scheduleId, int cancelledBy, String reason, int something) {
        String sql = "UPDATE doctor_schedules SET status = 'CANCELLED', is_approved = 0, updated_at = GETDATE(), rejection_reason = ? WHERE id = ? AND status IN ('PENDING', 'APPROVED')";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, scheduleId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                return new CancelScheduleResult(true, null, null);
            } else {
                return new CancelScheduleResult(false, "NOT_FOUND", "Lịch làm việc không tồn tại hoặc đã bị hủy.");
            }
        } catch (SQLException e) {
            return new CancelScheduleResult(false, "SYSTEM_ERROR", e.getMessage());
        }
    }
}
