package com.clinic.controller;

import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.Shift;
import com.clinic.model.User;
import com.clinic.model.enums.ScheduleStatus;
import com.clinic.service.DoctorScheduleService;
import com.clinic.service.ShiftService;
import com.clinic.utils.NotificationHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý Duyệt/Từ chối lịch trực bác sĩ cho Manager.
 *
 * <p>GET  → hiển thị danh sách lịch trực (phân trang + lọc theo trạng thái, bác sĩ, ngày)
 * <p>POST → xử lý duyệt (approve) hoặc từ chối (reject) lịch trực.
 *
 * <p>URL Patterns:
 * <ul>
 *   <li>/manager/schedules/  — danh sách + xử lý</li>
 *   <li>/manager/schedules   — redirect</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/manager/schedules/", "/manager/schedules"})
public class ManagerScheduleServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private DoctorScheduleService scheduleService;
    private ShiftService shiftService;

    @Override
    public void init() throws ServletException {
        scheduleService = new DoctorScheduleService();
        shiftService = new ShiftService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int page = parseInt(req.getParameter("page"), 1);
        String status = req.getParameter("status");
        String doctorIdStr = req.getParameter("doctorId");
        String dateFromStr = req.getParameter("dateFrom");
        String dateToStr = req.getParameter("dateTo");
        String view = req.getParameter("view"); // "detail" = xem chi tiết 1 lịch
        String tab = req.getParameter("tab");   // "shifts" hoặc "schedules"
        if (tab == null || tab.isEmpty()) {
            tab = "shifts"; // mặc định hiển thị tab quản lý ca làm việc
        }

        Integer doctorId = (doctorIdStr != null && !doctorIdStr.isEmpty())
                ? parseInt(doctorIdStr, null) : null;
        Date dateFrom = parseDate(dateFromStr);
        Date dateTo = parseDate(dateToStr);

        // ── Tab: Quản lý ca làm việc ──
        List<Shift> shifts = shiftService.getAllShifts();
        int[] shiftStats = shiftService.getShiftStats();
        req.setAttribute("shifts", shifts);
        req.setAttribute("activeShiftCount", shiftStats[0]);
        req.setAttribute("inactiveShiftCount", shiftStats[1]);
        req.setAttribute("totalShiftCount", shiftStats[0] + shiftStats[1]);

        // ── Tab: Duyệt đăng ký lịch ──
        if ("detail".equals(view)) {
            int scheduleId = parseInt(req.getParameter("id"), -1);
            if (scheduleId > 0) {
                DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
                if (schedule != null) {
                    List<String> warnings = scheduleService.validateScheduleWarnings(schedule);
                    req.setAttribute("detailSchedule", schedule);
                    req.setAttribute("warnings", warnings);
                }
            }
        }

        // Lấy danh sách lịch trực
        List<DoctorSchedule> schedules = scheduleService.getSchedules(
                page, PAGE_SIZE, status, doctorId, dateFrom, dateTo);
        int totalSchedules = scheduleService.getTotalSchedules(status, doctorId, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalSchedules / PAGE_SIZE);

        // Lấy danh sách bác sĩ cho dropdown filter
        List<Doctor> doctors = scheduleService.getAllDoctors();

        // Thống kê KPI
        int pendingCount = scheduleService.countByStatus(ScheduleStatus.PENDING);
        int approvedCount = scheduleService.countByStatus(ScheduleStatus.APPROVED);
        int rejectedCount = scheduleService.countByStatus(ScheduleStatus.REJECTED);
        int cancelledCount = scheduleService.countByStatus(ScheduleStatus.CANCELLED);

        // Set attributes cho JSP
        req.setAttribute("tab", tab);
        req.setAttribute("schedules", schedules);
        req.setAttribute("doctors", doctors);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalSchedules", totalSchedules);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("statusFilter", status);
        req.setAttribute("doctorIdFilter", doctorIdStr);
        req.setAttribute("dateFromFilter", dateFromStr);
        req.setAttribute("dateToFilter", dateToStr);

        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("approvedCount", approvedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.setAttribute("cancelledCount", cancelledCount);

        // Thông báo từ POST redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        // Shift form errors
        req.setAttribute("shiftErrors", req.getAttribute("shiftErrors"));

        req.getRequestDispatcher("/views/manager/schedules/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/manager/schedules/";

        // Lấy thông tin user hiện tại từ session
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // ── Shift CRUD actions ──
            if ("createShift".equals(action)) {
                handleCreateShift(req, resp, redirectUrl);
                return;
            } else if ("updateShift".equals(action)) {
                handleUpdateShift(req, resp, redirectUrl);
                return;
            } else if ("toggleShift".equals(action)) {
                handleToggleShift(req, resp, redirectUrl);
                return;
            } else if ("deleteShift".equals(action)) {
                handleDeleteShift(req, resp, redirectUrl);
                return;
            }

            // ── Schedule approve/reject actions ──
            if ("approve".equals(action)) {
                int scheduleId = parseInt(req.getParameter("id"), -1);
                if (scheduleId <= 0) {
                    resp.sendRedirect(redirectUrl + "?tab=schedules&error=ID+lịch+trực+không+hợp+lệ");
                    return;
                }

                Map<String, String> errors = new HashMap<>();
                boolean success = scheduleService.approveSchedule(
                        scheduleId, currentUser.getId(), errors);

                if (success) {
                    // Thông báo cho bác sĩ
                    try {
                        DoctorSchedule s = scheduleService.getScheduleById(scheduleId);
                        if (s != null) {
                            int docUserId = NotificationHelper.getDoctorUserId(s.getDoctorId());
                            if (docUserId > 0) NotificationHelper.scheduleApproved(
                                docUserId,
                                s.getWorkDate() != null ? s.getWorkDate().toString() : "",
                                s.getStartTime() != null ? s.getStartTime().toString() : "",
                                s.getEndTime()   != null ? s.getEndTime().toString()   : "");
                        }
                    } catch (Exception ignored) {}
                    resp.sendRedirect(redirectUrl + "?tab=schedules&success=approved&id=" + scheduleId);
                } else {
                    String errorMsg = errors.getOrDefault("general",
                            errors.getOrDefault("conflict",
                            errors.getOrDefault("full_slots", "Duyệt+thất+bại")));
                    resp.sendRedirect(redirectUrl + "?tab=schedules&error=" + errorMsg);
                }

            } else if ("reject".equals(action)) {
                int scheduleId = parseInt(req.getParameter("id"), -1);
                String rejectionReason = req.getParameter("rejectionReason");

                if (scheduleId <= 0) {
                    resp.sendRedirect(redirectUrl + "?tab=schedules&error=ID+lịch+trực+không+hợp+lệ");
                    return;
                }

                Map<String, String> errors = new HashMap<>();
                boolean success = scheduleService.rejectSchedule(
                        scheduleId, currentUser.getId(), rejectionReason, errors);

                if (success) {
                    // Thông báo cho bác sĩ
                    try {
                        DoctorSchedule s = scheduleService.getScheduleById(scheduleId);
                        if (s != null) {
                            int docUserId = NotificationHelper.getDoctorUserId(s.getDoctorId());
                            if (docUserId > 0) NotificationHelper.scheduleRejected(
                                docUserId,
                                s.getWorkDate() != null ? s.getWorkDate().toString() : "",
                                s.getStartTime() != null ? s.getStartTime().toString() : "",
                                s.getEndTime()   != null ? s.getEndTime().toString()   : "",
                                rejectionReason);
                        }
                    } catch (Exception ignored) {}
                    resp.sendRedirect(redirectUrl + "?tab=schedules&success=rejected&id=" + scheduleId);
                } else {
                    // Nếu lỗi validate (thiếu lý do), hiển thị lại trang với modal reject
                    req.setAttribute("errors", errors);
                    req.setAttribute("showRejectModal", true);
                    req.setAttribute("rejectScheduleId", scheduleId);
                    req.setAttribute("tab", "schedules");
                    doGet(req, resp);
                }

            } else if ("cancel".equals(action)) {
                int scheduleId = parseInt(req.getParameter("id"), -1);
                String cancellationReason = req.getParameter("cancellationReason");

                if (scheduleId <= 0) {
                    resp.sendRedirect(redirectUrl + "?tab=schedules&error=ID+lịch+trực+không+hợp+lệ");
                    return;
                }

                Map<String, String> errors = new HashMap<>();
                DoctorScheduleService.ScheduleCancelResult result = scheduleService.cancelSchedule(
                        scheduleId, currentUser.getId(), cancellationReason, errors);

                if (result.isSuccess()) {
                    resp.sendRedirect(redirectUrl + "?tab=schedules&success=cancelled&id=" + scheduleId);
                } else if (result.needsReassignment()) {
                    req.setAttribute("showCancelWarning", true);
                    req.setAttribute("hasBookedSlotsError", errors.get("hasBookedSlots"));
                    req.setAttribute("bookedSlots", result.getBookedSlots());
                    req.setAttribute("bookedSlotCount", result.getBookedSlotCount());
                    req.setAttribute("cancelSchedule", scheduleService.getScheduleById(scheduleId));
                    req.setAttribute("tab", "schedules");
                    doGet(req, resp);
                } else {
                    req.setAttribute("errors", errors);
                    req.setAttribute("showCancelModal", true);
                    req.setAttribute("cancelScheduleId", scheduleId);
                    req.setAttribute("tab", "schedules");
                    doGet(req, resp);
                }

            } else {
                resp.sendRedirect(redirectUrl + "?tab=schedules");
            }

        } catch (Exception e) {
            System.err.println("[ManagerScheduleServlet] POST ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống:+"
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    // ── Shift CRUD Handlers ──

    private void handleCreateShift(HttpServletRequest req, HttpServletResponse resp,
                                   String redirectUrl) throws IOException, ServletException {
        String name = req.getParameter("shiftName");
        String startTimeStr = req.getParameter("shiftStartTime");
        String endTimeStr = req.getParameter("shiftEndTime");
        String description = req.getParameter("shiftDescription");

        Map<String, String> errors = new HashMap<>();
        if (name == null || name.trim().isEmpty()) {
            errors.put("shiftName", "Vui lòng nhập tên ca làm việc.");
        }
        if (startTimeStr == null || startTimeStr.trim().isEmpty()) {
            errors.put("shiftTime", "Vui lòng nhập giờ bắt đầu.");
        }
        if (endTimeStr == null || endTimeStr.trim().isEmpty()) {
            errors.put("shiftTime", "Vui lòng nhập giờ kết thúc.");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("shiftErrors", errors);
            req.setAttribute("showShiftModal", true);
            req.setAttribute("tab", "shifts");
            doGet(req, resp);
            return;
        }

        try {
            Shift shift = new Shift();
            shift.setName(name.trim());
            shift.setStartTime(java.sql.Time.valueOf(startTimeStr.trim() + ":00"));
            shift.setEndTime(java.sql.Time.valueOf(endTimeStr.trim() + ":00"));
            if (description != null && !description.trim().isEmpty()) {
                shift.setDescription(description.trim());
            }

            if (shiftService.createShift(shift, errors)) {
                resp.sendRedirect(redirectUrl + "?tab=shifts&success=shiftCreated");
            } else {
                req.setAttribute("shiftErrors", errors);
                req.setAttribute("showShiftModal", true);
                req.setAttribute("tab", "shifts");
                doGet(req, resp);
            }
        } catch (IllegalArgumentException e) {
            errors.put("shiftTime", "Định dạng giờ không hợp lệ. Sử dụng định dạng HH:mm.");
            req.setAttribute("shiftErrors", errors);
            req.setAttribute("showShiftModal", true);
            req.setAttribute("tab", "shifts");
            doGet(req, resp);
        }
    }

    private void handleUpdateShift(HttpServletRequest req, HttpServletResponse resp,
                                   String redirectUrl) throws IOException, ServletException {
        int id = parseInt(req.getParameter("shiftId"), -1);
        String name = req.getParameter("shiftName");
        String startTimeStr = req.getParameter("shiftStartTime");
        String endTimeStr = req.getParameter("shiftEndTime");
        String description = req.getParameter("shiftDescription");

        Map<String, String> errors = new HashMap<>();
        if (id <= 0) {
            errors.put("general", "ID ca làm việc không hợp lệ.");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("shiftErrors", errors);
            req.setAttribute("showShiftModal", true);
            req.setAttribute("tab", "shifts");
            doGet(req, resp);
            return;
        }

        try {
            Shift shift = new Shift();
            shift.setId(id);
            shift.setName(name != null ? name.trim() : "");
            if (startTimeStr != null && !startTimeStr.trim().isEmpty()) {
                shift.setStartTime(java.sql.Time.valueOf(startTimeStr.trim() + ":00"));
            }
            if (endTimeStr != null && !endTimeStr.trim().isEmpty()) {
                shift.setEndTime(java.sql.Time.valueOf(endTimeStr.trim() + ":00"));
            }
            if (description != null && !description.trim().isEmpty()) {
                shift.setDescription(description.trim());
            }

            if (shiftService.updateShift(shift, errors)) {
                resp.sendRedirect(redirectUrl + "?tab=shifts&success=shiftUpdated");
            } else {
                req.setAttribute("shiftErrors", errors);
                req.setAttribute("showShiftModal", true);
                req.setAttribute("tab", "shifts");
                doGet(req, resp);
            }
        } catch (IllegalArgumentException e) {
            errors.put("shiftTime", "Định dạng giờ không hợp lệ. Sử dụng định dạng HH:mm.");
            req.setAttribute("shiftErrors", errors);
            req.setAttribute("showShiftModal", true);
            req.setAttribute("tab", "shifts");
            doGet(req, resp);
        }
    }

    private void handleToggleShift(HttpServletRequest req, HttpServletResponse resp,
                                   String redirectUrl) throws IOException {
        int id = parseInt(req.getParameter("shiftId"), -1);
        boolean active = "true".equals(req.getParameter("shiftActive"));

        if (id > 0) {
            shiftService.toggleActive(id, active);
            resp.sendRedirect(redirectUrl + "?tab=shifts&success=shiftToggled");
        } else {
            resp.sendRedirect(redirectUrl + "?tab=shifts&error=ID+ca+làm+việc+không+hợp+lệ");
        }
    }

    private void handleDeleteShift(HttpServletRequest req, HttpServletResponse resp,
                                   String redirectUrl) throws IOException, ServletException {
        int id = parseInt(req.getParameter("shiftId"), -1);

        if (id <= 0) {
            resp.sendRedirect(redirectUrl + "?tab=shifts&error=ID+ca+làm+việc+không+hợp+lệ");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        if (shiftService.deleteShift(id, errors)) {
            resp.sendRedirect(redirectUrl + "?tab=shifts&success=shiftDeleted");
        } else {
            req.setAttribute("shiftErrors", errors);
            req.setAttribute("tab", "shifts");
            doGet(req, resp);
        }
    }

    // ── Private helpers ──

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }

    private Integer parseInt(String s, Integer defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }

    private Date parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return Date.valueOf(s.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}