package com.clinic.controller;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.dao.ShiftDAO;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.Shift;
import com.clinic.model.User;
import com.clinic.model.enums.ScheduleStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet cho bác sĩ tự quản lý lịch làm việc và lịch nghỉ.
 *
 * <p>GET  /doctor/schedules  — hiển thị lịch làm việc của bác sĩ đang đăng nhập
 * <p>POST /doctor/schedules  — tạo mới / hủy lịch làm việc
 *
 * <p>Nghiệp vụ:
 * <ul>
 *   <li>Bác sĩ tạo lịch làm việc → trạng thái PENDING, chờ Manager duyệt</li>
 *   <li>Bác sĩ chỉ hủy được lịch PENDING của chính mình</li>
 *   <li>Mỗi slot có max_patients (giới hạn số bệnh nhân trong một ca)</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/doctor/schedules", "/doctor/schedules/"})
public class DoctorScheduleServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private DoctorScheduleDAO scheduleDAO;
    private DoctorDAO doctorDAO;
    private ShiftDAO shiftDAO;

    @Override
    public void init() throws ServletException {
        scheduleDAO = new DoctorScheduleDAO();
        doctorDAO   = new DoctorDAO();
        shiftDAO    = new ShiftDAO();
    }

    // ── GET ──────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            User user = (User) session.getAttribute("user");

            // Tìm doctor record của user đang đăng nhập
            Doctor doctor = doctorDAO.findByUserId(user.getId());
            if (doctor == null) {
                req.setAttribute("errorMessage", "Tài khoản chưa được liên kết hồ sơ bác sĩ.");
                req.getRequestDispatcher("/views/doctors/schedule.jsp").forward(req, resp);
                return;
            }

            // Tham số phân trang + filter
            int page = parseInt(req.getParameter("page"), 1);
            String statusFilter = req.getParameter("status");
            String dateFromStr  = req.getParameter("dateFrom");
            String dateToStr    = req.getParameter("dateTo");

            Date dateFrom = parseDate(dateFromStr);
            Date dateTo   = parseDate(dateToStr);

            int offset = (page - 1) * PAGE_SIZE;

            List<DoctorSchedule> schedules = scheduleDAO.findAll(
                    offset, PAGE_SIZE, statusFilter, doctor.getId(), dateFrom, dateTo);
            int total      = scheduleDAO.countAll(statusFilter, doctor.getId(), dateFrom, dateTo);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            // Toàn bộ lịch (không phân trang) để render calendar view
            List<DoctorSchedule> allSchedules = scheduleDAO.findAll(
                    0, Integer.MAX_VALUE, null, doctor.getId(), null, null);

            // KPI counts cho bác sĩ này
            int pendingCount  = countByDoctorAndStatus(doctor.getId(), ScheduleStatus.PENDING);
            int approvedCount = countByDoctorAndStatus(doctor.getId(), ScheduleStatus.APPROVED);
            int cancelledCount= countByDoctorAndStatus(doctor.getId(), ScheduleStatus.CANCELLED);

            // Ngày tối thiểu để tạo lịch (ngày mai)
            String minDate = LocalDate.now().plusDays(1).toString();

            // Load danh sách ca làm việc (shifts) từ database để bác sĩ chọn
            List<Shift> activeShifts;
            try {
                activeShifts = shiftDAO.findAllActive();
            } catch (Exception e) {
                activeShifts = new ArrayList<>();
                System.err.println("[DoctorScheduleServlet] Lỗi load shifts: " + e.getMessage());
            }

            req.setAttribute("doctor",        doctor);
            req.setAttribute("schedules",     schedules);
            req.setAttribute("allSchedules",  allSchedules);
            req.setAttribute("currentPage",   page);
            req.setAttribute("totalPages",    totalPages);
            req.setAttribute("totalSchedules",total);
            req.setAttribute("pageSize",      PAGE_SIZE);
            req.setAttribute("statusFilter",  statusFilter);
            req.setAttribute("dateFromFilter",dateFromStr);
            req.setAttribute("dateToFilter",  dateToStr);
            req.setAttribute("pendingCount",  pendingCount);
            req.setAttribute("approvedCount", approvedCount);
            req.setAttribute("cancelledCount",cancelledCount);
            req.setAttribute("minDate",       minDate);
            req.setAttribute("activeShifts",  activeShifts);

            // Flash messages từ redirect
            req.setAttribute("success", req.getParameter("success"));
            req.setAttribute("error",   req.getParameter("error"));

            req.getRequestDispatcher("/views/doctors/schedule.jsp").forward(req, resp);
        } catch (Exception ex) {
            System.err.println("[DoctorScheduleServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            req.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/doctors/schedule.jsp").forward(req, resp);
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/schedules?error=" + java.net.URLEncoder.encode("Tài khoản chưa liên kết hồ sơ bác sĩ", "UTF-8"));
            return;
        }

        String action      = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/doctor/schedules";

        try {
            switch (action == null ? "" : action) {
                case "create":
                    handleCreate(req, resp, doctor, user, redirectUrl);
                    break;
                case "cancel":
                    handleCancel(req, resp, doctor, redirectUrl);
                    break;
                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("[DoctorScheduleServlet] POST ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode("Lỗi hệ thống: " + e.getMessage(), "UTF-8"));
        }
    }

    // ── Handlers ─────────────────────────────────────────────────────────────

    /**
     * Tạo lịch làm việc mới — validate kỹ trước khi INSERT.
     */
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp,
                               Doctor doctor, User user, String redirectUrl)
            throws IOException, ServletException {

        Map<String, String> errors = new HashMap<>();

        // 1. Đọc tham số
        String workDateStr  = req.getParameter("workDate");
        String shiftIdStr   = req.getParameter("shiftId");
        String startTimeStr = req.getParameter("startTime");
        String endTimeStr   = req.getParameter("endTime");
        String maxSlotsStr  = req.getParameter("maxSlots");
        String notes        = req.getParameter("notes");

        // 2. Validate bắt buộc
        if (workDateStr == null || workDateStr.trim().isEmpty()) {
            errors.put("workDate", "Vui lòng chọn ngày làm việc.");
        }
        if (maxSlotsStr == null || maxSlotsStr.trim().isEmpty()) {
            errors.put("maxSlots", "Vui lòng nhập số bệnh nhân tối đa.");
        }

        // 3. Parse giá trị
        Date workDate  = null;
        int  shiftId   = 0;
        int  maxSlots  = 10;

        if (errors.isEmpty()) {
            try {
                workDate = Date.valueOf(workDateStr.trim());
            } catch (IllegalArgumentException e) {
                errors.put("workDate", "Định dạng ngày không hợp lệ.");
            }
            try {
                maxSlots = Integer.parseInt(maxSlotsStr.trim());
                if (maxSlots < 1 || maxSlots > 50) {
                    errors.put("maxSlots", "Số bệnh nhân tối đa phải từ 1 đến 50.");
                }
            } catch (NumberFormatException e) {
                errors.put("maxSlots", "Số bệnh nhân tối đa phải là số nguyên.");
            }

            // Ưu tiên shiftId từ dropdown; fallback: tìm shift khớp startTime/endTime
            if (shiftIdStr != null && !shiftIdStr.trim().isEmpty()) {
                try {
                    shiftId = Integer.parseInt(shiftIdStr.trim());
                } catch (NumberFormatException e) {
                    errors.put("shiftId", "Ca làm việc không hợp lệ.");
                }
            } else if (startTimeStr != null && !startTimeStr.trim().isEmpty()
                    && endTimeStr != null && !endTimeStr.trim().isEmpty()) {
                // Fallback: tìm shift theo giờ
                try {
                    Time st = Time.valueOf(startTimeStr.trim() + ":00");
                    Time et = Time.valueOf(endTimeStr.trim() + ":00");
                    shiftId = resolveShiftId(st, et);
                    if (shiftId <= 0) {
                        errors.put("shiftId", "Không tìm thấy ca làm việc khớp với giờ đã chọn. Vui lòng chọn ca từ danh sách.");
                    }
                } catch (IllegalArgumentException e) {
                    errors.put("startTime", "Định dạng giờ không hợp lệ.");
                }
            } else {
                errors.put("shiftId", "Vui lòng chọn ca làm việc.");
            }
        }

        // 4. Validate logic ngày
        if (errors.isEmpty()) {
            if (!workDate.toLocalDate().isAfter(LocalDate.now())) {
                errors.put("workDate", "Ngày làm việc phải từ ngày mai trở đi.");
            }
        }

        // 5. Kiểm tra trùng lịch PENDING/APPROVED của cùng bác sĩ (theo shift_id)
        if (errors.isEmpty()) {
            boolean conflict = scheduleDAO.hasConflictForDoctor(
                    doctor.getId(), workDate, shiftId, null);
            if (conflict) {
                errors.put("conflict",
                        "Bạn đã có lịch đăng ký trong cùng ngày và ca này (đang chờ duyệt hoặc đã duyệt).");
            }
        }

        // 6. Nếu có lỗi → forward lại với thông tin đã nhập
        if (!errors.isEmpty()) {
            // Set lại tất cả attributes để hiển thị form
            Doctor doc2  = doctorDAO.findByUserId(((User) req.getSession().getAttribute("user")).getId());
            int pageNum  = parseInt(req.getParameter("page"), 1);
            int offset   = (pageNum - 1) * PAGE_SIZE;
            List<DoctorSchedule> schedules = scheduleDAO.findAll(offset, PAGE_SIZE, null, doctor.getId(), null, null);
            int total      = scheduleDAO.countAll(null, doctor.getId(), null, null);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("doctor",        doc2);
            req.setAttribute("schedules",     schedules);
            req.setAttribute("currentPage",   pageNum);
            req.setAttribute("totalPages",    totalPages);
            req.setAttribute("totalSchedules",total);
            req.setAttribute("pageSize",      PAGE_SIZE);
            req.setAttribute("pendingCount",  countByDoctorAndStatus(doctor.getId(), ScheduleStatus.PENDING));
            req.setAttribute("approvedCount", countByDoctorAndStatus(doctor.getId(), ScheduleStatus.APPROVED));
            req.setAttribute("cancelledCount",countByDoctorAndStatus(doctor.getId(), ScheduleStatus.CANCELLED));
            req.setAttribute("minDate",       LocalDate.now().plusDays(1).toString());
            req.setAttribute("errors",        errors);
            req.setAttribute("showCreateModal", true);
            // Load shifts again for re-render
            try {
                req.setAttribute("activeShifts", shiftDAO.findAllActive());
            } catch (Exception e) {
                req.setAttribute("activeShifts", new ArrayList<Shift>());
            }
            // Giữ lại giá trị đã nhập
            req.setAttribute("formWorkDate",  workDateStr);
            req.setAttribute("formShiftId",   shiftIdStr);
            req.setAttribute("formStartTime", startTimeStr);
            req.setAttribute("formEndTime",   endTimeStr);
            req.setAttribute("formMaxSlots",  maxSlotsStr);
            req.setAttribute("formNotes",     notes);

            req.getRequestDispatcher("/views/doctors/schedule.jsp").forward(req, resp);
            return;
        }

        // 7. INSERT
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setDoctorId(doctor.getId());
        schedule.setShiftId(shiftId);
        schedule.setWorkDate(workDate);
        schedule.setMaxSlots(maxSlots);
        schedule.setNotes(notes != null ? notes.trim() : null);
        schedule.setStatus(ScheduleStatus.PENDING);
        schedule.setCreatedBy(user.getId());

        boolean created = scheduleDAO.insert(schedule);
        if (created) {
            resp.sendRedirect(redirectUrl + "?success=created");
        } else {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode("Tạo lịch thất bại, vui lòng thử lại.", "UTF-8"));
        }
    }

    /**
     * Hủy lịch làm việc — chỉ hủy được lịch PENDING của chính mình.
     */
    private void handleCancel(HttpServletRequest req, HttpServletResponse resp,
                               Doctor doctor, String redirectUrl)
            throws IOException {

        int scheduleId = parseInt(req.getParameter("id"), -1);
        if (scheduleId <= 0) {
            resp.sendRedirect(redirectUrl + "?error=" + java.net.URLEncoder.encode("ID lịch không hợp lệ", "UTF-8"));
            return;
        }

        DoctorSchedule schedule = scheduleDAO.findById(scheduleId);
        if (schedule == null) {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode("Lịch làm việc không tồn tại.", "UTF-8"));
            return;
        }
        if (schedule.getDoctorId() != doctor.getId()) {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode("Bạn không có quyền hủy lịch này.", "UTF-8"));
            return;
        }
        if (schedule.getStatus() != ScheduleStatus.PENDING) {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode(
                            "Chỉ có thể hủy lịch đang ở trạng thái Chờ duyệt.", "UTF-8"));
            return;
        }

        boolean cancelled = scheduleDAO.cancel(scheduleId);
        if (cancelled) {
            resp.sendRedirect(redirectUrl + "?success=cancelled");
        } else {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode("Hủy lịch thất bại, vui lòng thử lại.", "UTF-8"));
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private int countByDoctorAndStatus(int doctorId, ScheduleStatus status) {
        try {
            return scheduleDAO.countAll(status.name(), doctorId, null, null);
        } catch (Exception e) {
            return 0;
        }
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return defaultVal; }
    }

    /**
     * Tìm shift_id từ start_time và end_time (fallback khi user nhập giờ thủ công).
     * @return shift_id > 0 nếu tìm thấy, 0 nếu không khớp.
     */
    private int resolveShiftId(Time startTime, Time endTime) {
        String sql = "SELECT id FROM shifts WHERE start_time = CAST(? AS time) AND end_time = CAST(? AS time) AND is_active = 1";
        try (java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTime(1, startTime);
            ps.setTime(2, endTime);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) {
            System.err.println("[DoctorScheduleServlet] resolveShiftId ERROR: " + e.getMessage());
        }
        return 0;
    }

    private Date parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Date.valueOf(s.trim()); } catch (IllegalArgumentException e) { return null; }
    }
}
