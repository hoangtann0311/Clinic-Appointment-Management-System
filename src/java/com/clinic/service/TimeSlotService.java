package com.clinic.service;

import com.clinic.dao.TimeSlotDAO;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ sinh và quản lý khung giờ khám (time slots).
 *
 * <p>Nghiệp vụ chính:
 * <ul>
 *   <li>Tự động sinh 20-phút slots khi Admin/Manager duyệt lịch trực</li>
 *   <li>Xem danh sách slots theo lịch trực (có phân trang)</li>
 *   <li>Kiểm tra và ngăn sinh trùng lặp (idempotent)</li>
 *   <li>Xóa slots khi cần sinh lại hoặc hủy lịch trực</li>
 * </ul>
 */
public class TimeSlotService {

    private final TimeSlotDAO timeSlotDAO;

    public TimeSlotService() {
        this.timeSlotDAO = new TimeSlotDAO();
    }

    /**
     * Sinh time slots từ lịch trực đã được duyệt.
     * Kiểm tra trước: nếu đã có slots cho schedule này thì bỏ qua (idempotent).
     *
     * @param schedule lịch trực đã APPROVED (chứa doctorId, workDate, startTime, endTime)
     * @param errors   map để chứa lỗi nếu có
     * @return số slot đã sinh, 0 nếu không sinh (đã tồn tại / không đủ thời gian), -1 nếu lỗi
     */
    public int generateSlotsForSchedule(DoctorSchedule schedule, Map<String, String> errors) {
        // 1. Kiểm tra đã có slots chưa — tránh sinh trùng
        if (timeSlotDAO.hasSlotsForSchedule(schedule.getId())) {
            System.out.println("[TimeSlotService] generateSlotsForSchedule: scheduleId="
                    + schedule.getId() + " đã có slots, bỏ qua.");
            return 0;
        }

        // 2. Kiểm tra thời gian hợp lệ
        if (schedule.getStartTime() == null || schedule.getEndTime() == null) {
            errors.put("general", "Lịch trực thiếu thông tin giờ bắt đầu hoặc kết thúc.");
            return -1;
        }

        // 3. Thực hiện sinh slots (batch insert trong transaction)
        int result = timeSlotDAO.generateSlots(
            schedule.getId(),
            schedule.getDoctorId(),
            schedule.getWorkDate(),
            schedule.getStartTime(),
            schedule.getEndTime()
        );

        if (result < 0) {
            errors.put("general", "Lỗi hệ thống khi sinh khung giờ khám. Vui lòng thử lại sau.");
        } else if (result == 0) {
            System.out.println("[TimeSlotService] generateSlotsForSchedule: scheduleId="
                    + schedule.getId() + " — thời gian làm việc < 20 phút, không sinh slot.");
        }

        return result;
    }

    /**
     * Kiểm tra đã có time slots cho schedule_id chưa.
     */
    public boolean hasSlotsForSchedule(int scheduleId) {
        return timeSlotDAO.hasSlotsForSchedule(scheduleId);
    }

    /**
     * Lấy danh sách time slots theo schedule_id (có phân trang).
     */
    public List<TimeSlot> getSlotsBySchedule(int scheduleId, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        try {
            return timeSlotDAO.findByScheduleId(scheduleId, offset, pageSize);
        } catch (Exception e) {
            System.err.println("[TimeSlotService] getSlotsBySchedule ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Đếm tổng số time slots của một schedule.
     */
    public int countSlotsBySchedule(int scheduleId) {
        try {
            return timeSlotDAO.countByScheduleId(scheduleId);
        } catch (Exception e) {
            System.err.println("[TimeSlotService] countSlotsBySchedule ERROR: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Xóa toàn bộ time slots của một schedule (dùng khi hủy lịch trực hoặc sinh lại).
     */
    public boolean deleteSlotsBySchedule(int scheduleId, Map<String, String> errors) {
        boolean result = timeSlotDAO.deleteByScheduleId(scheduleId);
        if (!result) {
            errors.put("general", "Không thể xóa khung giờ khám. Vui lòng thử lại.");
        }
        return result;
    }
}
