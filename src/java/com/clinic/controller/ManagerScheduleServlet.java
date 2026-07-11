package com.clinic.controller;

import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;
import com.clinic.model.User;
import com.clinic.model.enums.ScheduleStatus;
import com.clinic.service.DoctorScheduleService;
import com.clinic.service.DoctorScheduleService.ScheduleCancelResult;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý Duyệt/Từ chối/Hủy lịch trực bác sĩ cho Manager.
 *
 * <p>GET  → hiển thị danh sách lịch trực (phân trang + lọc)
 * <p>POST → xử lý: approve, reject, cancel, force-cancel
 *
 * <p><strong>Edge cases:</strong>
 * <ul>
 *   <li>Session hết hạn khi đang duyệt → yêu cầu login lại</li>
 *   <li>2 Manager cùng duyệt 1 lịch → optimistic lock, thông báo lỗi</li>
 *   <li>Hủy lịch có booked slots → chặn, yêu cầu chuyển patient trước</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/manager/schedules/", "/manager/schedules"})
public class ManagerScheduleServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private DoctorScheduleService scheduleService;

    @Override
    public void init() throws ServletException {
        scheduleService = new DoctorScheduleService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Session check ──
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            redirectToLogin(req, resp);
            return;
        }

        int page = parseInt(req.getParameter("page"), 1);
        String status = req.getParameter("status");
        String doctorIdStr = req.getParameter("doctorId");
        String dateFromStr = req.getParameter("dateFrom");
        String dateToStr = req.getParameter("dateTo");
        String view = req.getParameter("view");

        Integer doctorId = (doctorIdStr != null && !doctorIdStr.isEmpty())
                ? parseInt(doctorIdStr, null) : null;
        Date dateFrom = parseDate(dateFromStr);
        Date dateTo = parseDate(dateToStr);

        // Xem chi tiết một lịch trực
        if ("detail".equals(view)) {
            int scheduleId = parseInt(req.getParameter("id"), -1);
            if (scheduleId > 0) {
                DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
                if (schedule != null) {
                    List<String> warnings = scheduleService.validateScheduleWarnings(schedule);
                    req.setAttribute("detailSchedule", schedule);
                    req.setAttribute("warnings", warnings);

                    // Hiển thị booked slot count nếu có
                    req.setAttribute("bookedSlotCount", schedule.getBookedSlotCount());
                }
            }
        }

        // Lấy danh sách lịch trực
        List<DoctorSchedule> schedules = scheduleService.getSchedules(
                page, PAGE_SIZE, status, doctorId, dateFrom, dateTo);
        int totalSchedules = scheduleService.getTotalSchedules(status, doctorId, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalSchedules / PAGE_SIZE);

        List<Doctor> doctors = scheduleService.getAllDoctors();

        int pendingCount = scheduleService.countByStatus(ScheduleStatus.PENDING);
        int approvedCount = scheduleService.countByStatus(ScheduleStatus.APPROVED);
        int rejectedCount = scheduleService.countByStatus(ScheduleStatus.REJECTED);
        int cancelledCount = scheduleService.countByStatus(ScheduleStatus.CANCELLED);

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

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));
        req.setAttribute("warning", req.getParameter("warning"));

        req.getRequestDispatcher("/views/manager/schedules/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── QUAN TRỌNG: Session check & re-validation ──
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            // Session hết hạn khi đang duyệt → yêu cầu login lại
            req.getSession(true).setAttribute("redirectAfterLogin",
                    req.getContextPath() + "/manager/schedules/");
            req.getSession().setAttribute("sessionExpiredMessage",
                    "Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại để tiếp tục.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/manager/schedules/";

        try {
            if ("approve".equals(action)) {
                handleApprove(req, resp, currentUser, redirectUrl);

            } else if ("reject".equals(action)) {
                handleReject(req, resp, currentUser, redirectUrl);

            } else if ("cancel".equals(action)) {
                handleCancel(req, resp, currentUser, redirectUrl);

            } else if ("cancel-force".equals(action)) {
                handleForceCancel(req, resp, currentUser, redirectUrl);

            } else {
                resp.sendRedirect(redirectUrl);
            }

        } catch (Exception e) {
            System.err.println("[ManagerScheduleServlet] POST ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống:+"
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    // ── Action Handlers ──

    /**
     * Xử lý duyệt lịch trực — với optimistic locking.
     */
    private void handleApprove(HttpServletRequest req, HttpServletResponse resp,
                                User currentUser, String redirectUrl) throws IOException {
        int scheduleId = parseInt(req.getParameter("id"), -1);
        if (scheduleId <= 0) {
            resp.sendRedirect(redirectUrl + "?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        boolean success = scheduleService.approveSchedule(
                scheduleId, currentUser.getId(), errors);

        if (success) {
            // Ghi audit log
            DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
            String doctorInfo = schedule != null
                    ? (schedule.getDoctorName() + " - " + schedule.getWorkDate())
                    : "ID " + scheduleId;
            AuditUtil.log(currentUser.getId(),
                    "Duyệt lịch trực: " + doctorInfo,
                    "doctor_schedules", null, "APPROVED", null);

            resp.sendRedirect(redirectUrl + "?success=approved&id=" + scheduleId);
        } else {
            String errorMsg = errors.getOrDefault("general",
                    errors.getOrDefault("conflict",
                    errors.getOrDefault("full_slots", "Duyệt+thất+bại")));
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        }
    }

    /**
     * Xử lý từ chối lịch trực.
     */
    private void handleReject(HttpServletRequest req, HttpServletResponse resp,
                               User currentUser, String redirectUrl)
            throws IOException, ServletException {
        int scheduleId = parseInt(req.getParameter("id"), -1);
        String rejectionReason = req.getParameter("rejectionReason");

        if (scheduleId <= 0) {
            resp.sendRedirect(redirectUrl + "?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        boolean success = scheduleService.rejectSchedule(
                scheduleId, currentUser.getId(), rejectionReason, errors);

        if (success) {
            // Ghi audit log
            DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
            String doctorInfo = schedule != null
                    ? (schedule.getDoctorName() + " - " + schedule.getWorkDate())
                    : "ID " + scheduleId;
            String reasonNote = (rejectionReason != null && !rejectionReason.trim().isEmpty())
                    ? ": " + rejectionReason.trim() : "";
            AuditUtil.log(currentUser.getId(),
                    "Từ chối lịch trực: " + doctorInfo + reasonNote,
                    "doctor_schedules", null, "REJECTED", null);

            resp.sendRedirect(redirectUrl + "?success=rejected&id=" + scheduleId);
        } else {
            // Nếu lỗi validate, hiển thị lại trang với modal reject
            req.setAttribute("errors", errors);
            req.setAttribute("showRejectModal", true);
            req.setAttribute("rejectScheduleId", scheduleId);
            doGet(req, resp);
        }
    }

    /**
     * Xử lý hủy lịch trực — kiểm tra booked slots.
     */
    private void handleCancel(HttpServletRequest req, HttpServletResponse resp,
                               User currentUser, String redirectUrl)
            throws IOException, ServletException {
        int scheduleId = parseInt(req.getParameter("id"), -1);
        String reason = req.getParameter("cancellationReason");

        if (scheduleId <= 0) {
            resp.sendRedirect(redirectUrl + "?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        ScheduleCancelResult result = scheduleService.cancelSchedule(
                scheduleId, currentUser.getId(), reason, errors);

        if (result.isSuccess()) {
            // Ghi audit log
            DoctorSchedule sched = scheduleService.getScheduleById(scheduleId);
            String doctorInfo = sched != null
                    ? (sched.getDoctorName() + " - " + sched.getWorkDate())
                    : "ID " + scheduleId;
            String reasonNote = (reason != null && !reason.trim().isEmpty())
                    ? ": " + reason.trim() : "";
            AuditUtil.log(currentUser.getId(),
                    "Hủy lịch trực: " + doctorInfo + reasonNote,
                    "doctor_schedules", null, "CANCELLED", null);

            resp.sendRedirect(redirectUrl + "?success=cancelled&id=" + scheduleId);
        } else if (result.needsReassignment()) {
            // Có booked slots → hiển thị trang xác nhận với danh sách bệnh nhân
            DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
            req.setAttribute("cancelSchedule", schedule);
            req.setAttribute("bookedSlots", result.getBookedSlots());
            req.setAttribute("bookedSlotCount", result.getBookedSlotCount());
            req.setAttribute("showCancelWarning", true);
            req.setAttribute("hasBookedSlotsError", errors.get("hasBookedSlots"));
            doGet(req, resp);
        } else {
            // Lỗi validate
            req.setAttribute("errors", errors);
            req.setAttribute("showCancelModal", true);
            req.setAttribute("cancelScheduleId", scheduleId);
            doGet(req, resp);
        }
    }

    /**
     * Xử lý hủy lịch trực sau khi đã chuyển hết bệnh nhân.
     */
    private void handleForceCancel(HttpServletRequest req, HttpServletResponse resp,
                                    User currentUser, String redirectUrl)
            throws IOException {
        int scheduleId = parseInt(req.getParameter("id"), -1);
        String reason = req.getParameter("cancellationReason");

        if (scheduleId <= 0) {
            resp.sendRedirect(redirectUrl + "?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        ScheduleCancelResult result = scheduleService.cancelScheduleAfterReassignment(
                scheduleId, currentUser.getId(), reason, errors);

        if (result.isSuccess()) {
            // Ghi audit log
            DoctorSchedule sched = scheduleService.getScheduleById(scheduleId);
            String doctorInfo = sched != null
                    ? (sched.getDoctorName() + " - " + sched.getWorkDate())
                    : "ID " + scheduleId;
            String reasonNote = (reason != null && !reason.trim().isEmpty())
                    ? ": " + reason.trim() : "";
            AuditUtil.log(currentUser.getId(),
                    "Hủy lịch trực (cưỡng chế): " + doctorInfo + reasonNote,
                    "doctor_schedules", null, "CANCELLED", null);

            resp.sendRedirect(redirectUrl + "?success=cancelled&id=" + scheduleId);
        } else if (result.needsReassignment()) {
            resp.sendRedirect(redirectUrl
                    + "?warning=Vẫn+còn+" + result.getBookedSlotCount()
                    + "+bệnh+nhân+chưa+được+chuyển+lịch&id=" + scheduleId);
        } else {
            resp.sendRedirect(redirectUrl + "?error="
                    + java.net.URLEncoder.encode(
                            errors.getOrDefault("general", "Hủy+thất+bại"), "UTF-8"));
        }
    }

    // ── Private helpers ──

    /**
     * Lấy user hiện tại từ session.
     * Trả về null nếu session hết hạn hoặc chưa đăng nhập.
     */
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("user");
    }

    /**
     * Redirect về login khi session hết hạn.
     */
    private void redirectToLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(true);
        session.setAttribute("redirectAfterLogin", req.getRequestURI());
        session.setAttribute("sessionExpiredMessage",
                "Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại.");
        resp.sendRedirect(req.getContextPath() + "/login");
    }

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

