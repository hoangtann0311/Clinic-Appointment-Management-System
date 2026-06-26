package controller;

import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;
import com.clinic.model.User;
import com.clinic.service.DoctorScheduleService;
import com.clinic.service.TimeSlotService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý khung giờ khám (time slots) — xem và sinh lại slots.
 *
 * <p>GET  → hiển thị danh sách time slots của một lịch trực đã duyệt
 * <p>POST → xử lý sinh lại slots (regenerate) hoặc xóa slots (delete)
 *
 * <p>URL Patterns:
 * <ul>
 *   <li>/manager/time-slots/  — xem slots + xử lý</li>
 *   <li>/manager/time-slots   — redirect về schedules</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/manager/time-slots/", "/manager/time-slots"})
public class ManagerTimeSlotServlet extends HttpServlet {

    private static final int PAGE_SIZE = 20;

    private TimeSlotService timeSlotService;
    private DoctorScheduleService scheduleService;

    @Override
    public void init() throws ServletException {
        timeSlotService = new TimeSlotService();
        scheduleService = new DoctorScheduleService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int scheduleId = parseInt(req.getParameter("scheduleId"), -1);

        // Không có scheduleId cụ thể → hiển thị danh sách lịch trực đã duyệt (landing page)
        if (scheduleId <= 0) {
            showApprovedSchedulesOverview(req, resp);
            return;
        }

        // Lấy thông tin lịch trực
        DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
        if (schedule == null) {
            resp.sendRedirect(req.getContextPath() + "/manager/time-slots/?error=Lịch+trực+không+tồn+tại");
            return;
        }

        int page = parseInt(req.getParameter("page"), 1);
        List<TimeSlot> slots = timeSlotService.getSlotsBySchedule(scheduleId, page, PAGE_SIZE);
        int totalSlots = timeSlotService.countSlotsBySchedule(scheduleId);
        int totalPages = (int) Math.ceil((double) totalSlots / PAGE_SIZE);
        boolean hasSlots = timeSlotService.hasSlotsForSchedule(scheduleId);

        // Set attributes cho JSP
        req.setAttribute("schedule", schedule);
        req.setAttribute("slots", slots);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalSlots", totalSlots);
        req.setAttribute("hasSlots", hasSlots);
        req.setAttribute("pageSize", PAGE_SIZE);

        // Thông báo từ POST redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));
        String countParam = req.getParameter("count");
        if (countParam != null) {
            req.setAttribute("generatedCount", parseInt(countParam, 0));
        }

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    /**
     * Hiển thị trang tổng quan: danh sách tất cả lịch trực đã duyệt
     * kèm trạng thái slot (đã sinh / chưa sinh).
     */
    private void showApprovedSchedulesOverview(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách lịch trực APPROVED
        List<DoctorSchedule> approvedSchedules = scheduleService.getSchedules(
                1, 200, "APPROVED", null, null, null);

        // Đếm số slot cho mỗi schedule (dùng Map để cache)
        Map<Integer, Integer> slotCounts = new HashMap<>();
        Map<Integer, Boolean> slotStatus = new HashMap<>();
        for (DoctorSchedule sched : approvedSchedules) {
            int count = timeSlotService.countSlotsBySchedule(sched.getId());
            slotCounts.put(sched.getId(), count);
            slotStatus.put(sched.getId(), count > 0);
        }

        req.setAttribute("approvedSchedules", approvedSchedules);
        req.setAttribute("slotCounts", slotCounts);
        req.setAttribute("slotStatus", slotStatus);
        req.setAttribute("overviewMode", true);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        int scheduleId = parseInt(req.getParameter("scheduleId"), -1);
        String redirectUrl = req.getContextPath() + "/manager/time-slots/?scheduleId=" + scheduleId;

        // Lấy thông tin user hiện tại từ session
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (scheduleId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/manager/schedules/?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        try {
            if ("regenerate".equals(action)) {
                // Xóa slots cũ trước khi sinh lại
                Map<String, String> deleteErrors = new HashMap<>();
                timeSlotService.deleteSlotsBySchedule(scheduleId, deleteErrors);

                DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
                if (schedule == null || !schedule.isApprovedSchedule()) {
                    resp.sendRedirect(redirectUrl + "&error=Chỉ+có+thể+sinh+slot+cho+lịch+trực+đã+duyệt");
                    return;
                }

                Map<String, String> errors = new HashMap<>();
                int count = timeSlotService.generateSlotsForSchedule(schedule, errors);

                if (count > 0) {
                    resp.sendRedirect(redirectUrl + "&success=generated&count=" + count);
                } else if (count == 0) {
                    resp.sendRedirect(redirectUrl
                            + "&error=Lịch+trực+có+thời+gian+làm+việc+dưới+20+phút,+không+thể+sinh+slot");
                } else {
                    resp.sendRedirect(redirectUrl + "&error="
                            + java.net.URLEncoder.encode(
                                    errors.getOrDefault("general", "Lỗi+hệ+thống+khi+sinh+slot"), "UTF-8"));
                }

            } else if ("delete".equals(action)) {
                Map<String, String> errors = new HashMap<>();
                boolean deleted = timeSlotService.deleteSlotsBySchedule(scheduleId, errors);

                if (deleted) {
                    resp.sendRedirect(redirectUrl + "&success=deleted");
                } else {
                    resp.sendRedirect(redirectUrl + "&error="
                            + java.net.URLEncoder.encode(
                                    errors.getOrDefault("general", "Không+thể+xóa+slot"), "UTF-8"));
                }

            } else {
                resp.sendRedirect(redirectUrl);
            }

        } catch (Exception e) {
            System.err.println("[ManagerTimeSlotServlet] POST ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "&error=Lỗi+hệ+thống:+"
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    // ── Private helpers ──

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}
