package com.clinic.controller;

import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.User;
import com.clinic.model.enums.ScheduleStatus;
import com.clinic.service.DoctorScheduleService;
import com.clinic.utils.NotificationHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
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

    @Override
    public void init() throws ServletException {
        scheduleService = new DoctorScheduleService();
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

        // Set attributes cho JSP
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

        // Thông báo từ POST redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

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
            if ("approve".equals(action)) {
                int scheduleId = parseInt(req.getParameter("id"), -1);
                if (scheduleId <= 0) {
                    resp.sendRedirect(redirectUrl + "?error=ID+lịch+trực+không+hợp+lệ");
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
                    resp.sendRedirect(redirectUrl + "?success=approved&id=" + scheduleId);
                } else {
                    String errorMsg = errors.getOrDefault("general",
                            errors.getOrDefault("conflict",
                            errors.getOrDefault("full_slots", "Duyệt+thất+bại")));
                    resp.sendRedirect(redirectUrl + "?error=" + errorMsg);
                }

            } else if ("reject".equals(action)) {
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
                    resp.sendRedirect(redirectUrl + "?success=rejected&id=" + scheduleId);
                } else {
                    // Nếu lỗi validate (thiếu lý do), hiển thị lại trang với modal reject
                    req.setAttribute("errors", errors);
                    req.setAttribute("showRejectModal", true);
                    req.setAttribute("rejectScheduleId", scheduleId);
                    doGet(req, resp);
                }

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