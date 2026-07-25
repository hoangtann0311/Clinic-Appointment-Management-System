package com.clinic.service;

import com.clinic.dao.ShiftDAO;
import com.clinic.model.Shift;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý ca làm việc.
 *
 * <p>Nghiệp vụ chính:
 * <ul>
 *   <li>Lấy danh sách ca làm việc (tất cả / đang hoạt động)</li>
 *   <li>Tạo / Sửa / Xóa ca làm việc với validate</li>
 *   <li>Bật/tắt trạng thái hoạt động</li>
 * </ul>
 */
public class ShiftService {

    private final ShiftDAO shiftDAO;

    public ShiftService() {
        this.shiftDAO = new ShiftDAO();
    }

    // ──────────────────────────────────────────────
    //  Truy vấn
    // ──────────────────────────────────────────────

    public List<Shift> getAllShifts() {
        try {
            return shiftDAO.findAll();
        } catch (Exception e) {
            System.err.println("[ShiftService] getAllShifts ERROR: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public List<Shift> getActiveShifts() {
        try {
            return shiftDAO.findAllActive();
        } catch (Exception e) {
            System.err.println("[ShiftService] getActiveShifts ERROR: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public Shift getShiftById(int id) {
        return shiftDAO.findById(id);
    }

    /**
     * @return mảng 2 phần tử: [activeCount, inactiveCount]
     */
    public int[] getShiftStats() {
        try {
            int active = shiftDAO.countByStatus(true);
            int inactive = shiftDAO.countByStatus(false);
            return new int[]{active, inactive};
        } catch (Exception e) {
            return new int[]{0, 0};
        }
    }

    // ──────────────────────────────────────────────
    //  CRUD với validate
    // ──────────────────────────────────────────────

    /**
     * Tạo ca làm việc mới.
     *
     * @param shift  đối tượng Shift (chưa có id)
     * @param errors map để chứa lỗi validate
     * @return true nếu tạo thành công
     */
    public boolean createShift(Shift shift, Map<String, String> errors) {
        // 1. Validate name
        if (shift.getName() == null || shift.getName().trim().isEmpty()) {
            errors.put("shiftName", "Vui lòng nhập tên ca làm việc.");
            return false;
        }
        String name = shift.getName().trim();
        if (name.length() > 100) {
            errors.put("shiftName", "Tên ca làm việc không được vượt quá 100 ký tự.");
            return false;
        }

        // 2. Validate times
        if (shift.getStartTime() == null || shift.getEndTime() == null) {
            errors.put("shiftTime", "Vui lòng nhập giờ bắt đầu và giờ kết thúc.");
            return false;
        }
        if (!shift.getEndTime().after(shift.getStartTime())) {
            errors.put("shiftTime", "Giờ kết thúc phải sau giờ bắt đầu.");
            return false;
        }
        // Kiểm tra duration tối thiểu 30 phút
        long durationMs = shift.getEndTime().getTime() - shift.getStartTime().getTime();
        if (durationMs < 30 * 60 * 1000) {
            errors.put("shiftTime", "Ca làm việc phải có độ dài tối thiểu 30 phút.");
            return false;
        }

        // 3. Kiểm tra trùng tên
        if (shiftDAO.existsByName(name, null)) {
            errors.put("shiftName", "Tên ca làm việc \"" + name + "\" đã tồn tại.");
            return false;
        }

        // 4. Kiểm tra trùng khung giờ
        if (shiftDAO.isTimeRangeOverlapping(shift.getStartTime(), shift.getEndTime(), null)) {
            errors.put("shiftTime", "Khung giờ của ca làm việc bị trùng với một ca đang hoạt động khác.");
            return false;
        }

        // 5. Insert
        shift.setName(name);
        boolean result = shiftDAO.insert(shift);
        if (!result) {
            errors.put("general", "Không thể tạo ca làm việc. Vui lòng thử lại.");
        }
        return result;
    }

    /**
     * Cập nhật ca làm việc.
     *
     * @param shift  đối tượng Shift (phải có id)
     * @param errors map để chứa lỗi validate
     * @return true nếu cập nhật thành công
     */
    public boolean updateShift(Shift shift, Map<String, String> errors) {
        // 1. Kiểm tra tồn tại
        Shift existing = shiftDAO.findById(shift.getId());
        if (existing == null) {
            errors.put("general", "Ca làm việc không tồn tại.");
            return false;
        }

        // 2. Validate name
        if (shift.getName() == null || shift.getName().trim().isEmpty()) {
            errors.put("shiftName", "Vui lòng nhập tên ca làm việc.");
            return false;
        }
        String name = shift.getName().trim();
        if (name.length() > 100) {
            errors.put("shiftName", "Tên ca làm việc không được vượt quá 100 ký tự.");
            return false;
        }

        // 3. Validate times
        if (shift.getStartTime() == null || shift.getEndTime() == null) {
            errors.put("shiftTime", "Vui lòng nhập giờ bắt đầu và giờ kết thúc.");
            return false;
        }
        if (!shift.getEndTime().after(shift.getStartTime())) {
            errors.put("shiftTime", "Giờ kết thúc phải sau giờ bắt đầu.");
            return false;
        }
        long durationMs = shift.getEndTime().getTime() - shift.getStartTime().getTime();
        if (durationMs < 30 * 60 * 1000) {
            errors.put("shiftTime", "Ca làm việc phải có độ dài tối thiểu 30 phút.");
            return false;
        }

        // 4. Kiểm tra trùng tên (loại trừ chính nó)
        if (shiftDAO.existsByName(name, shift.getId())) {
            errors.put("shiftName", "Tên ca làm việc \"" + name + "\" đã tồn tại.");
            return false;
        }

        // 5. Kiểm tra trùng khung giờ (loại trừ chính nó)
        if (shiftDAO.isTimeRangeOverlapping(shift.getStartTime(), shift.getEndTime(), shift.getId())) {
            errors.put("shiftTime", "Khung giờ của ca làm việc bị trùng với một ca đang hoạt động khác.");
            return false;
        }

        // 6. Update
        shift.setName(name);
        boolean result = shiftDAO.update(shift);
        if (!result) {
            errors.put("general", "Không thể cập nhật ca làm việc. Vui lòng thử lại.");
        }
        return result;
    }

    /**
     * Xóa ca làm việc.
     * Chỉ xóa được nếu không có doctor_schedules nào đang dùng khung giờ này.
     *
     * @param id     ID ca làm việc
     * @param errors map để chứa lỗi
     * @return true nếu xóa thành công
     */
    public boolean deleteShift(int id, Map<String, String> errors) {
        Shift existing = shiftDAO.findById(id);
        if (existing == null) {
            errors.put("general", "Ca làm việc không tồn tại.");
            return false;
        }

        // Kiểm tra phụ thuộc
        if (shiftDAO.hasDoctorSchedulesForTimeRange(existing.getStartTime(), existing.getEndTime())) {
            errors.put("general",
                "Ca làm việc \"" + existing.getName()
                + "\" đã có lịch đăng ký. Bạn có thể vô hiệu hóa ca này thay vì xóa.");
            return false;
        }

        boolean result = shiftDAO.delete(id);
        if (!result) {
            errors.put("general", "Không thể xóa ca làm việc. Vui lòng thử lại.");
        }
        return result;
    }

    /**
     * Bật/tắt trạng thái hoạt động của ca.
     */
    public boolean toggleActive(int id, boolean active) {
        return shiftDAO.setActive(id, active);
    }
}
