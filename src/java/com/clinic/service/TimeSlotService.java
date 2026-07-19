package com.clinic.service;

import com.clinic.dao.TimeSlotDAO;
import com.clinic.dao.TimeSlotDAO.BookingResult;
import com.clinic.dao.TimeSlotDAO.CancelResult;
import com.clinic.dao.TimeSlotDAO.DeleteSlotsResult;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ sinh, đặt, hủy và quản lý khung giờ khám (time slots).
 *
 * <p>Nghiệp vụ chính:
 * <ul>
 *   <li>Tự động sinh 20-phút slots khi Admin/Manager duyệt lịch trực</li>
 *   <li>Đặt slot nguyên tử — chống double-booking (2 patient cùng đặt 1 slot)</li>
 *   <li>Hủy slot — giải phóng slot, cho phép patient khác đặt lại</li>
 *   <li>Xóa slots an toàn — kiểm tra booked slots trước khi xóa</li>
 *   <li>Xem danh sách slots theo lịch trực (có phân trang)</li>
 * </ul>
 *
 * <p><strong>Quy tắc nghiệp vụ:</strong>
 * <ul>
 *   <li>Một bác sĩ chỉ có 1 lịch hẹn trong 1 slot (doctor + slot là unique per booking)</li>
 *   <li>Hai bệnh nhân KHÔNG được đặt cùng 1 slot của cùng 1 bác sĩ</li>
 *   <li>Hai bác sĩ khác nhau CÓ THỂ có lịch khám cùng thời điểm</li>
 *   <li>Khi hủy appointment → slot được giải phóng (AVAILABLE) để đặt lại</li>
 * </ul>
 */
public class TimeSlotService {

    private final TimeSlotDAO timeSlotDAO;

    public TimeSlotService() {
        this.timeSlotDAO = new TimeSlotDAO();
    }

    // ──────────────────────────────────────────────
    //  Sinh slots từ lịch trực
    // ──────────────────────────────────────────────

    /**
     * Sinh time slots từ lịch trực đã được duyệt.
     * Kiểm tra trước: nếu đã có slots cho schedule này thì bỏ qua (idempotent).
     *
     * @param schedule lịch trực đã APPROVED
     * @param errors   map để chứa lỗi nếu có
     * @return số slot đã sinh, 0 nếu không sinh, -1 nếu lỗi
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

        // 3. Thực hiện sinh slots
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

    // ──────────────────────────────────────────────
    //  Đặt slot (booking) — nghiệp vụ chính
    // ──────────────────────────────────────────────

    /**
     * Đặt một khung giờ khám cho bệnh nhân.
     *
     * <p>Quy tắc nghiệp vụ:
     * <ul>
     *   <li>Slot phải ở trạng thái AVAILABLE</li>
     *   <li>Một bác sĩ chỉ có 1 lịch hẹn trong 1 slot (đảm bảo bởi DB constraint)</li>
     *   <li>Hai patient không được đặt cùng 1 slot (UPDLOCK atomic booking)</li>
     *   <li>Bác sĩ khác nhau có thể khám cùng thời điểm (slot khác doctor khác nhau)</li>
     * </ul>
     *
     * @param slotId    ID của time slot
     * @param patientId user_id của bệnh nhân
     * @param errors    map chứa lỗi nếu có
     * @return TimeSlot đã được đặt, hoặc null nếu thất bại
     */
    public TimeSlot bookSlot(int slotId, int patientId, Map<String, String> errors) {
        // 1. Validate input
        if (slotId <= 0) {
            errors.put("slotId", "ID khung giờ khám không hợp lệ.");
            return null;
        }
        if (patientId <= 0) {
            errors.put("patientId", "ID bệnh nhân không hợp lệ.");
            return null;
        }

        // 2. Thực hiện atomic booking
        BookingResult result = timeSlotDAO.bookSlotAtomic(slotId, patientId);

        if (result.isSuccess()) {
            System.out.println("[TimeSlotService] bookSlot SUCCESS: slotId=" + slotId
                    + ", patientId=" + patientId);
            return result.getBookedSlot();
        }

        // 3. Xử lý các loại lỗi
        switch (result.getErrorCode()) {
            case "NOT_FOUND":
                errors.put("slotId", result.getErrorMessage());
                break;
            case "NOT_AVAILABLE":
                errors.put("slotId", result.getErrorMessage());
                break;
            case "SYSTEM_ERROR":
                errors.put("general", result.getErrorMessage());
                break;
            default:
                errors.put("general", "Đặt lịch thất bại. Vui lòng thử lại.");
                break;
        }

        System.out.println("[TimeSlotService] bookSlot FAILED: slotId=" + slotId
                + ", error=" + result.getErrorCode());
        return null;
    }

    // ──────────────────────────────────────────────
    //  Hủy slot (cancellation) — giải phóng slot
    // ──────────────────────────────────────────────

    /**
     * Hủy một lịch hẹn đã đặt, giải phóng slot về AVAILABLE.
     *
     * <p>Quy tắc:
     * <ul>
     *   <li>Chỉ hủy được slot đang BOOKED</li>
     *   <li>Sau khi hủy, slot trở về AVAILABLE — patient khác có thể đặt lại</li>
     *   <li>Ghi nhận lý do hủy vào notes</li>
     * </ul>
     *
     * @param slotId      ID của time slot
     * @param cancelledBy user_id thực hiện hủy
     * @param reason      lý do hủy (có thể null)
     * @param errors      map chứa lỗi nếu có
     * @return true nếu hủy thành công
     */
    public boolean cancelSlot(int slotId, int cancelledBy, String reason,
                               Map<String, String> errors) {
        if (slotId <= 0) {
            errors.put("slotId", "ID khung giờ khám không hợp lệ.");
            return false;
        }

        CancelResult result = timeSlotDAO.cancelSlotAtomic(slotId, cancelledBy, reason);

        if (result.isSuccess()) {
            System.out.println("[TimeSlotService] cancelSlot SUCCESS: slotId=" + slotId
                    + ", cancelledBy=" + cancelledBy);
            return true;
        }

        switch (result.getErrorCode()) {
            case "NOT_FOUND":
                errors.put("slotId", result.getErrorMessage());
                break;
            case "NOT_BOOKED":
                errors.put("slotId", result.getErrorMessage());
                break;
            case "CONCURRENT":
                errors.put("general", result.getErrorMessage());
                break;
            default:
                errors.put("general", result.getErrorMessage());
                break;
        }

        System.out.println("[TimeSlotService] cancelSlot FAILED: slotId=" + slotId
                + ", error=" + result.getErrorCode());
        return false;
    }

    // ──────────────────────────────────────────────
    //  Xóa slots — an toàn, có kiểm tra booked
    // ──────────────────────────────────────────────

    /**
     * Xóa toàn bộ time slots của một schedule.
     * CHỈ xóa nếu không có slot nào đang BOOKED.
     *
     * @param scheduleId ID lịch trực
     * @param errors     map chứa lỗi nghiệp vụ
     * @return true nếu xóa thành công
     */
    public boolean deleteSlotsBySchedule(int scheduleId, Map<String, String> errors) {
        DeleteSlotsResult result = timeSlotDAO.deleteByScheduleIdSafe(scheduleId, false);

        if (result.isSuccess()) {
            System.out.println("[TimeSlotService] deleteSlotsBySchedule SUCCESS: scheduleId="
                    + scheduleId + ", deleted=" + result.getDeletedCount());
            return true;
        }

        if ("HAS_BOOKED".equals(result.getErrorCode())) {
            errors.put("hasBookedSlots", result.getErrorMessage());
        } else {
            errors.put("general", result.getErrorMessage());
        }

        return false;
    }

    /**
     * Xóa slots của schedule kể cả khi có BOOKED slots (force).
     * Chỉ dùng trong trường hợp khẩn cấp, sau khi đã xử lý chuyển bệnh nhân.
     */
    public boolean forceDeleteSlots(int scheduleId, Map<String, String> errors) {
        DeleteSlotsResult result = timeSlotDAO.deleteByScheduleIdSafe(scheduleId, true);

        if (result.isSuccess()) {
            System.out.println("[TimeSlotService] forceDeleteSlots SUCCESS: scheduleId="
                    + scheduleId + ", deleted=" + result.getDeletedCount()
                    + " (FORCE)");
            return true;
        }

        errors.put("general", result.getErrorMessage());
        return false;
    }

    // ──────────────────────────────────────────────
    //  Truy vấn
    // ──────────────────────────────────────────────

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
     * Cập nhật giá riêng cho MỘT khung giờ (giá theo giờ).
     * priceStr rỗng/null → xóa giá riêng (dùng lại giá mặc định của bác sĩ).
     *
     * @return true nếu cập nhật thành công, false nếu có lỗi (xem errors)
     */
    public boolean updateSlotPrice(int slotId, String priceStr, Map<String, String> errors) {
        Double price = parsePrice(priceStr, errors);
        if (errors.containsKey("price")) return false;
        boolean ok = timeSlotDAO.updateSlotPrice(slotId, price);
        if (!ok) errors.put("general", "Không thể cập nhật giá cho khung giờ này.");
        return ok;
    }

    /**
     * Áp một giá cho TẤT CẢ khung giờ của một lịch trực (giá theo ngày,
     * vì mỗi schedule tương ứng 1 bác sĩ trong 1 ngày làm việc cụ thể).
     *
     * @return số slot đã cập nhật, hoặc -1 nếu lỗi
     */
    public int updatePriceForSchedule(int scheduleId, String priceStr, Map<String, String> errors) {
        Double price = parsePrice(priceStr, errors);
        if (errors.containsKey("price")) return -1;
        int updated = timeSlotDAO.updatePriceBySchedule(scheduleId, price);
        if (updated < 0) errors.put("general", "Không thể cập nhật giá cho lịch trực này.");
        return updated;
    }

    private Double parsePrice(String priceStr, Map<String, String> errors) {
        if (priceStr == null || priceStr.trim().isEmpty()) {
            return null; // xóa giá riêng → dùng lại giá mặc định của bác sĩ
        }
        try {
            double price = Double.parseDouble(priceStr.trim());
            if (price < 0) {
                errors.put("price", "Giá không được âm.");
                return null;
            }
            return price;
        } catch (NumberFormatException e) {
            errors.put("price", "Giá không hợp lệ.");
            return null;
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
     * Đếm số slot đã BOOKED trong một schedule.
     * Dùng để kiểm tra trước khi hủy/sửa lịch trực.
     */
    public int countBookedSlots(int scheduleId) {
        try {
            return timeSlotDAO.countBookedSlots(scheduleId);
        } catch (Exception e) {
            System.err.println("[TimeSlotService] countBookedSlots ERROR: " + e.getMessage());
            return 999; // Trả về số lớn để ngăn thao tác nguy hiểm
        }
    }

    /**
     * Lấy danh sách slot đã BOOKED trong một schedule.
     */
    public List<TimeSlot> getBookedSlotsBySchedule(int scheduleId) {
        try {
            return timeSlotDAO.findBookedSlotsByScheduleId(scheduleId);
        } catch (Exception e) {
            System.err.println("[TimeSlotService] getBookedSlotsBySchedule ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Đếm số slot theo trạng thái trong một schedule (KPI).
     */
    public int countSlotsByStatus(int scheduleId, com.clinic.model.enums.SlotStatus status) {
        try {
            return timeSlotDAO.countByScheduleAndStatus(scheduleId, status);
        } catch (Exception e) {
            return 0;
        }
    }
}