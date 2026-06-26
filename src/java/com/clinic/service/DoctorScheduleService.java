package com.clinic.service;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
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
 *   <li>Duyệt lịch trực (APPROVE) — kiểm tra trùng lịch, giới hạn slot</li>
 *   <li>Từ chối lịch trực (REJECT) — yêu cầu nhập lý do</li>
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

    /**
     * Lấy danh sách lịch trực có phân trang + filter.
     */
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

    /**
     * Tổng số lịch trực (để tính số trang).
     */
    public int getTotalSchedules(String status, Integer doctorId,
                                  Date dateFrom, Date dateTo) {
        try {
            return scheduleDAO.countAll(status, doctorId, dateFrom, dateTo);
        } catch (Exception e) {
            System.err.println("[DoctorScheduleService] getTotalSchedules ERROR: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Lấy chi tiết một lịch trực theo id.
     */
    public DoctorSchedule getScheduleById(int id) {
        return scheduleDAO.findById(id);
    }

    /**
     * Duyệt lịch trực — kiểm tra nghiệp vụ trước khi duyệt.
     *
     * <p>Các bước kiểm tra:
     * <ol>
     *   <li>Lịch trực phải tồn tại và ở trạng thái PENDING</li>
     *   <li>Bác sĩ không có lịch APPROVED trùng ngày + khung giờ</li>
     *   <li>Số bác sĩ trong ca chưa vượt max_slots của ca đó</li>
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
            errors.put("general", "Chỉ có thể duyệt lịch trực đang ở trạng thái Chờ duyệt.");
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
            errors.put("conflict", "Bác sĩ đã có lịch trực được duyệt trong cùng ngày và khung giờ này.");
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

        // 4. Thực hiện duyệt
        boolean result = scheduleDAO.approve(scheduleId, approvedBy);
        if (!result) {
            errors.put("general", "Duyệt lịch trực thất bại. Có thể lịch đã được xử lý bởi người khác.");
            return false;
        }

        // 5. Tự động sinh khung giờ khám 20 phút
        //    Sau khi duyệt thành công, sinh time slots cho lịch trực này
        //    Lỗi sinh slot không rollback việc duyệt — Manager có thể sinh lại thủ công
        try {
            int slotsGenerated = timeSlotService.generateSlotsForSchedule(schedule, errors);
            if (slotsGenerated > 0) {
                System.out.println("[DoctorScheduleService] approveSchedule INFO: "
                        + "Đã sinh " + slotsGenerated + " khung giờ khám cho lịch trực #" + scheduleId);
            } else if (slotsGenerated == 0) {
                System.out.println("[DoctorScheduleService] approveSchedule INFO: "
                        + "Lịch trực #" + scheduleId + " — không sinh slot "
                        + "(đã tồn tại hoặc thời gian < 20 phút).");
            } else {
                System.err.println("[DoctorScheduleService] approveSchedule WARNING: "
                        + "Lịch trực #" + scheduleId + " đã duyệt nhưng sinh slot thất bại. "
                        + "Manager có thể sinh lại thủ công.");
            }
        } catch (Exception e) {
            // Không làm fail quá trình duyệt — chỉ log lỗi
            System.err.println("[DoctorScheduleService] approveSchedule WARNING: "
                    + "Lỗi khi sinh slot cho lịch trực #" + scheduleId
                    + ": " + e.getMessage());
            e.printStackTrace(System.err);
        }

        return true;
    }

    /**
     * Từ chối lịch trực — yêu cầu nhập lý do.
     *
     * @param scheduleId      ID lịch trực
     * @param rejectedBy      user_id của Admin/Manager
     * @param rejectionReason lý do từ chối
     * @param errors          map để chứa lỗi validate
     * @return true nếu từ chối thành công
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

    /**
     * Đếm số lịch trực theo trạng thái (dùng cho thống kê KPI).
     */
    public int countByStatus(ScheduleStatus status) {
        try {
            return scheduleDAO.countByStatus(status);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Lấy danh sách tất cả bác sĩ (dùng cho dropdown filter).
     */
    public List<Doctor> getAllDoctors() {
        try {
            return doctorDAO.findAll();
        } catch (Exception e) {
            System.err.println("[DoctorScheduleService] getAllDoctors ERROR: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    /**
     * Validate tổng quan trước khi hiển thị form duyệt:
     * Kiểm tra các vấn đề tiềm năng và trả về danh sách cảnh báo.
     */
    public List<String> validateScheduleWarnings(DoctorSchedule schedule) {
        List<String> warnings = new ArrayList<>();
        if (schedule == null) return warnings;

        // Kiểm tra trùng lịch
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

        // Kiểm tra slot
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
}
