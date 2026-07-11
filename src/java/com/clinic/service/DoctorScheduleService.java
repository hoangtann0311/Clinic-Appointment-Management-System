package com.clinic.service;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.dao.DoctorScheduleDAO.ApproveResult;
import com.clinic.dao.DoctorScheduleDAO.CancelScheduleResult;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;
import com.clinic.model.enums.ScheduleStatus;

import java.sql.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý lịch trực bác sĩ.
 *
 * <p>Nghiệp vụ chính:
 * <ul>
 *   <li>Lấy danh sách lịch trực (có phân trang + filter)</li>
 *   <li>Duyệt lịch trực (APPROVE) — optimistic locking, ngăn 2 Manager duyệt đồng thời</li>
 *   <li>Từ chối lịch trực (REJECT)</li>
 *   <li>Hủy lịch trực (CANCEL) — kiểm tra booked slots, xử lý chuyển bệnh nhân</li>
 *   <li>Kiểm tra sửa lịch trực — không cho sửa nếu đã có slot BOOKED</li>
 * </ul>
 *
 * <p><strong>Edge cases handled:</strong>
 * <ul>
 *   <li>2 Manager cùng duyệt 1 lịch → optimistic lock, chỉ 1 thành công</li>
 *   <li>Bác sĩ hủy lịch sau khi có patient đặt → không hủy trực tiếp, phải chuyển patient</li>
 *   <li>Lịch trực bị sửa sau khi đã sinh slot → cần đồng bộ, không cho sửa nếu có BOOKED</li>
 *   <li>Session hết hạn khi đang duyệt → Controller kiểm tra, yêu cầu login lại</li>
 * </ul>
 */
public class DoctorScheduleService {

    private final DoctorScheduleDAO scheduleDAO;
    private final DoctorDAO doctorDAO;
    private final TimeSlotService timeSlotService;

    public DoctorScheduleService() {
        this.scheduleDAO = new DoctorScheduleDAO();
        this.doctorDAO = new DoctorDAO();
        this.timeSlotService = new TimeSlotService();
    }

    // ──────────────────────────────────────────────
    //  Truy vấn
    // ──────────────────────────────────────────────

    public List<DoctorSchedule> getSchedules(int page, int pageSize,
                                              String status, Integer doctorId,
                                              Date dateFrom, Date dateTo) {
        int offset = (page - 1) * pageSize;
        try {
            return scheduleDAO.findAll(offset, pageSize, status, doctorId, dateFrom, dateTo);
        } catch (Exception e) {
            System.err.println("[DoctorScheduleService] getSchedules ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public int getTotalSchedules(String status, Integer doctorId,
                                  Date dateFrom, Date dateTo) {
        try {
            return scheduleDAO.countAll(status, doctorId, dateFrom, dateTo);
        } catch (Exception e) {
            System.err.println("[DoctorScheduleService] getTotalSchedules ERROR: " + e.getMessage());
            return 0;
        }
    }

    public DoctorSchedule getScheduleById(int id) {
        return scheduleDAO.findById(id);
    }

    public int countByStatus(ScheduleStatus status) {
        try {
            return scheduleDAO.countByStatus(status);
        } catch (Exception e) {
            return 0;
        }
    }

    public List<Doctor> getAllDoctors() {
        try {
            return doctorDAO.findAll();
        } catch (Exception e) {
            System.err.println("[DoctorScheduleService] getAllDoctors ERROR: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    //  Duyệt lịch trực — optimistic locking
    // ──────────────────────────────────────────────

    /**
     * Duyệt lịch trực với optimistic locking.
     *
     * <p>Cơ chế chống double-approve:
     * <ul>
     *   <li>DAO dùng {@code WHERE status = 'PENDING'} — chỉ UPDATE nếu chưa bị đổi</li>
     *   <li>Nếu 2 Manager cùng duyệt, người thứ 2 nhận lỗi "already processed"</li>
     *   <li>Sinh time slots trong CÙNG transaction với duyệt — đảm bảo nguyên tử</li>
     * </ul>
     *
     * <p>Quy trình:
     * <ol>
     *   <li>Validate: lịch trực tồn tại & PENDING</li>
     *   <li>Kiểm tra trùng lịch APPROVED của cùng bác sĩ</li>
     *   <li>Kiểm tra giới hạn max_slots của ca</li>
     *   <li>Atomic approve + sinh slots (transaction)</li>
     * </ol>
     *
     * @param scheduleId ID lịch trực
     * @param approvedBy user_id của Admin/Manager
     * @param errors     map để chứa lỗi validate
     * @return true nếu duyệt thành công
     */
    public boolean approveSchedule(int scheduleId, int approvedBy,
                                    Map<String, String> errors) {
        // 1. Kiểm tra tồn tại & trạng thái
        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            errors.put("general", "Lịch trực không tồn tại.");
            return false;
        }
        if (schedule.getStatus() != ScheduleStatus.PENDING) {
            errors.put("general", "Chỉ có thể duyệt lịch trực đang ở trạng thái Chờ duyệt. "
                    + "Trạng thái hiện tại: " + schedule.getStatus().getLabel());
            return false;
        }

        // 2. Kiểm tra trùng lịch APPROVED của cùng bác sĩ
        boolean conflict = scheduleDAO.hasApprovedConflict(
            schedule.getDoctorId(),
            schedule.getWorkDate(),
            schedule.getStartTime(),
            schedule.getEndTime(),
            null
        );
        if (conflict) {
            errors.put("conflict",
                    "Bác sĩ " + schedule.getDoctorName()
                    + " đã có lịch trực được duyệt trong cùng ngày và khung giờ này.");
            return false;
        }

        // 3. Kiểm tra giới hạn max_slots của ca
        int maxSlots = schedule.getMaxSlots();
        if (maxSlots > 0) {
            int currentCount = scheduleDAO.countApprovedInSameShift(
                schedule.getWorkDate(),
                schedule.getStartTime(),
                schedule.getEndTime()
            );
            if (currentCount >= maxSlots) {
                errors.put("full_slots", "Ca trực này đã đủ số lượng bác sĩ tối đa ("
                        + maxSlots + "). Không thể duyệt thêm.");
                return false;
            }
        }

        // 4. Thực hiện atomic approve (approve + sinh slots trong 1 transaction)
        ApproveResult result = scheduleDAO.approveAtomic(scheduleId, approvedBy);

        if (result.isSuccess()) {
            System.out.println("[DoctorScheduleService] approveSchedule SUCCESS: scheduleId="
                    + scheduleId + ", approvedBy=" + approvedBy
                    + ", slotsGenerated=" + result.getSlotsGenerated());
            return true;
        }

        // 5. Xử lý các loại lỗi từ atomic approve
        switch (result.getErrorCode()) {
            case "ALREADY_PROCESSED":
                errors.put("general", result.getErrorMessage());
                break;
            case "NOT_FOUND":
                errors.put("general", result.getErrorMessage());
                break;
            case "SYSTEM_ERROR":
                errors.put("general", result.getErrorMessage());
                break;
            default:
                errors.put("general", "Duyệt lịch trực thất bại. Vui lòng thử lại.");
                break;
        }

        return false;
    }

    // ──────────────────────────────────────────────
    //  Từ chối lịch trực
    // ──────────────────────────────────────────────

    /**
     * Từ chối lịch trực — yêu cầu nhập lý do.
     */
    public boolean rejectSchedule(int scheduleId, int rejectedBy,
                                   String rejectionReason, Map<String, String> errors) {
        // 1. Validate lý do từ chối
        if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
            errors.put("rejectionReason", "Vui lòng nhập lý do từ chối.");
            return false;
        }
        String trimmedReason = rejectionReason.trim();
        if (trimmedReason.length() < 10) {
            errors.put("rejectionReason", "Lý do từ chối phải có ít nhất 10 ký tự.");
            return false;
        }

        // 2. Kiểm tra tồn tại & trạng thái
        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            errors.put("general", "Lịch trực không tồn tại.");
            return false;
        }
        if (schedule.getStatus() != ScheduleStatus.PENDING) {
            errors.put("general", "Chỉ có thể từ chối lịch trực đang ở trạng thái Chờ duyệt.");
            return false;
        }

        // 3. Thực hiện từ chối
        boolean result = scheduleDAO.reject(scheduleId, rejectedBy, trimmedReason);
        if (!result) {
            errors.put("general", "Từ chối lịch trực thất bại. Có thể lịch đã được xử lý bởi người khác.");
        }
        return result;
    }

    // ──────────────────────────────────────────────
    //  Hủy lịch trực — xử lý edge cases
    // ──────────────────────────────────────────────

    /**
     * Hủy lịch trực với kiểm tra booked slots.
     *
     * <p><strong>Luồng nghiệp vụ:</strong>
     * <ol>
     *   <li>Kiểm tra lịch trực tồn tại và có thể hủy</li>
     *   <li>Đếm số slot đã BOOKED của lịch trực này</li>
     *   <li>Nếu có BOOKED slots → không cho hủy trực tiếp, yêu cầu xử lý chuyển
     *       bệnh nhân sang bác sĩ khác hoặc đổi lịch trước</li>
     *   <li>Nếu không có BOOKED slots → hủy bình thường</li>
     * </ol>
     *
     * @param scheduleId  ID lịch trực
     * @param cancelledBy user_id người hủy
     * @param reason      lý do hủy
     * @param errors      map chứa lỗi nghiệp vụ
     * @return CancelResult chứa kết quả (thành công / cần xử lý booked slots)
     */
    public ScheduleCancelResult cancelSchedule(int scheduleId, int cancelledBy,
                                                String reason, Map<String, String> errors) {
        // 1. Validate
        if (reason == null || reason.trim().length() < 10) {
            errors.put("cancellationReason", "Vui lòng nhập lý do hủy (tối thiểu 10 ký tự).");
            return ScheduleCancelResult.validationFailed();
        }

        // 2. Kiểm tra tồn tại & trạng thái
        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            errors.put("general", "Lịch trực không tồn tại.");
            return ScheduleCancelResult.validationFailed();
        }

        ScheduleStatus currentStatus = schedule.getStatus();
        if (currentStatus == ScheduleStatus.CANCELLED) {
            errors.put("general", "Lịch trực này đã bị hủy trước đó.");
            return ScheduleCancelResult.validationFailed();
        }

        // 3. Kiểm tra booked slots — ĐÂY LÀ BƯỚC QUAN TRỌNG
        int bookedSlots = timeSlotService.countBookedSlots(scheduleId);

        if (bookedSlots > 0) {
            // Có bệnh nhân đã đặt lịch → không cho hủy trực tiếp
            List<TimeSlot> bookedSlotList = timeSlotService.getBookedSlotsBySchedule(scheduleId);

            errors.put("hasBookedSlots",
                    "Lịch trực #" + scheduleId + " của bác sĩ " + schedule.getDoctorName()
                    + " hiện có " + bookedSlots + " bệnh nhân đã đặt lịch. "
                    + "Bạn không thể hủy trực tiếp. Vui lòng xử lý chuyển bác sĩ hoặc "
                    + "đổi lịch cho từng bệnh nhân trước.");

            return ScheduleCancelResult.hasBookedSlots(scheduleId, bookedSlots, bookedSlotList);
        }

        // 4. Không có booked slots → thực hiện hủy atomic
        CancelScheduleResult result = scheduleDAO.cancelAtomic(
                scheduleId, cancelledBy, reason.trim(), 0);

        if (result.isSuccess()) {
            // Xóa các time slots (vì không có booked nên xóa an toàn)
            timeSlotService.deleteSlotsBySchedule(scheduleId, new java.util.HashMap<>());

            System.out.println("[DoctorScheduleService] cancelSchedule SUCCESS: scheduleId="
                    + scheduleId + ", cancelledBy=" + cancelledBy);
            return ScheduleCancelResult.success(scheduleId);
        }

        // Lỗi từ DAO
        errors.put("general", result.getErrorMessage());
        return ScheduleCancelResult.validationFailed();
    }

    /**
     * Hủy lịch trực sau khi đã xử lý xong tất cả booked slots (chuyển bệnh nhân).
     * Đây là bước 2 sau khi Manager đã chuyển hết bệnh nhân sang bác sĩ khác.
     */
    public ScheduleCancelResult cancelScheduleAfterReassignment(int scheduleId, int cancelledBy,
                                                                  String reason,
                                                                  Map<String, String> errors) {
        // Kiểm tra lại lần cuối: còn booked slots nào không?
        int bookedSlots = timeSlotService.countBookedSlots(scheduleId);
        if (bookedSlots > 0) {
            errors.put("hasBookedSlots",
                    "Vẫn còn " + bookedSlots + " bệnh nhân chưa được chuyển lịch. "
                    + "Vui lòng xử lý tất cả trước khi hủy.");
            return ScheduleCancelResult.hasBookedSlots(scheduleId, bookedSlots,
                    timeSlotService.getBookedSlotsBySchedule(scheduleId));
        }

        CancelScheduleResult result = scheduleDAO.cancelAtomic(
                scheduleId, cancelledBy, reason.trim(), 0);

        if (result.isSuccess()) {
            timeSlotService.deleteSlotsBySchedule(scheduleId, new java.util.HashMap<>());
            return ScheduleCancelResult.success(scheduleId);
        }

        errors.put("general", result.getErrorMessage());
        return ScheduleCancelResult.validationFailed();
    }

    // ──────────────────────────────────────────────
    //  Kiểm tra sửa lịch trực
    // ──────────────────────────────────────────────

    /**
     * Kiểm tra xem có thể sửa lịch trực không.
     *
     * <p>Quy tắc: Nếu lịch trực đã APPROVED và có slot BOOKED,
     * KHÔNG cho phép sửa trực tiếp. Phải xử lý chuyển bệnh nhân trước.
     *
     * @return true nếu có thể sửa, false nếu bị chặn
     */
    public boolean canModifySchedule(int scheduleId, Map<String, String> errors) {
        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            errors.put("general", "Lịch trực không tồn tại.");
            return false;
        }

        // PENDING thì luôn sửa được
        if (schedule.getStatus() == ScheduleStatus.PENDING) {
            return true;
        }

        // APPROVED thì kiểm tra booked slots
        if (schedule.getStatus() == ScheduleStatus.APPROVED) {
            int bookedSlots = timeSlotService.countBookedSlots(scheduleId);
            if (bookedSlots > 0) {
                errors.put("hasBookedSlots",
                        "Lịch trực này có " + bookedSlots + " bệnh nhân đã đặt lịch. "
                        + "Không thể sửa lịch trực. Vui lòng xử lý chuyển bệnh nhân trước.");
                return false;
            }
            return true;
        }

        // Các trạng thái khác không sửa được
        errors.put("general", "Không thể sửa lịch trực ở trạng thái "
                + schedule.getStatus().getLabel() + ".");
        return false;
    }

    // ──────────────────────────────────────────────
    //  Validate / Warnings
    // ──────────────────────────────────────────────

    /**
     * Validate tổng quan trước khi hiển thị form duyệt.
     */
    public List<String> validateScheduleWarnings(DoctorSchedule schedule) {
        List<String> warnings = new ArrayList<>();
        if (schedule == null) return warnings;

        boolean conflict = scheduleDAO.hasApprovedConflict(
            schedule.getDoctorId(),
            schedule.getWorkDate(),
            schedule.getStartTime(),
            schedule.getEndTime(),
            schedule.getId()
        );
        if (conflict) {
            warnings.add("Cảnh báo: Bác sĩ đã có lịch trực được duyệt trùng ngày và khung giờ này.");
        }

        int maxSlots = schedule.getMaxSlots();
        if (maxSlots > 0) {
            int currentCount = scheduleDAO.countApprovedInSameShift(
                schedule.getWorkDate(),
                schedule.getStartTime(),
                schedule.getEndTime()
            );
            if (currentCount >= maxSlots) {
                warnings.add("Cảnh báo: Ca trực này đã đủ " + maxSlots + " bác sĩ.");
            }
        }

        return warnings;
    }

    // ═══════════════════════════════════════════════════════════
    //  INNER CLASS: ScheduleCancelResult
    // ═══════════════════════════════════════════════════════════

    /**
     * Kết quả của thao tác hủy lịch trực.
     * Bao gồm thông tin về booked slots cần xử lý.
     */
    public static class ScheduleCancelResult {
        private final boolean success;
        private final boolean needsReassignment; // Cần chuyển bệnh nhân trước khi hủy
        private final int scheduleId;
        private final int bookedSlotCount;
        private final List<TimeSlot> bookedSlots; // Danh sách slot cần xử lý

        private ScheduleCancelResult(boolean success, boolean needsReassignment,
                                      int scheduleId, int bookedSlotCount,
                                      List<TimeSlot> bookedSlots) {
            this.success = success;
            this.needsReassignment = needsReassignment;
            this.scheduleId = scheduleId;
            this.bookedSlotCount = bookedSlotCount;
            this.bookedSlots = bookedSlots;
        }

        public static ScheduleCancelResult success(int scheduleId) {
            return new ScheduleCancelResult(true, false, scheduleId, 0, null);
        }

        public static ScheduleCancelResult hasBookedSlots(int scheduleId, int count,
                                                           List<TimeSlot> slots) {
            return new ScheduleCancelResult(false, true, scheduleId, count, slots);
        }

        public static ScheduleCancelResult validationFailed() {
            return new ScheduleCancelResult(false, false, 0, 0, null);
        }

        public boolean isSuccess() { return success; }
        public boolean needsReassignment() { return needsReassignment; }
        public int getScheduleId() { return scheduleId; }
        public int getBookedSlotCount() { return bookedSlotCount; }
        public List<TimeSlot> getBookedSlots() { return bookedSlots; }
    }
}
