package controller;

import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;
import com.clinic.model.User;
import com.clinic.service.DoctorScheduleService;
import com.clinic.service.TimeSlotService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý khung giờ khám (time slots) — xem, sinh, xóa slots.
 *
 * <p>GET  → hiển thị danh sách time slots của một lịch trực đã duyệt
 * <p>POST → xử lý: regenerate (sinh lại), delete (xóa), safe-delete (xóa an toàn)
 *
 * <p><strong>Edge cases:</strong>
 * <ul>
 *   <li>Sinh lại slots khi đã có BOOKED → chặn, yêu cầu xử lý trước</li>
 *   <li>Xóa slots khi có BOOKED → chặn, hiển thị danh sách patient cần chuyển</li>
 *   <li>Session hết hạn → redirect về login</li>
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

        // ── Session check ──
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            redirectToLogin(req, resp);
            return;
        }

        int scheduleId = parseInt(req.getParameter("scheduleId"), -1);

        // Không có scheduleId → hiển thị danh sách lịch trực đã duyệt
        if (scheduleId <= 0) {
            showApprovedSchedulesOverview(req, resp);
            return;
        }

        // Lấy thông tin lịch trực
        DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
        if (schedule == null) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/time-slots/?error=Lịch+trực+không+tồn+tại");
            return;
        }

        int page = parseInt(req.getParameter("page"), 1);
        List<TimeSlot> slots = timeSlotService.getSlotsBySchedule(scheduleId, page, PAGE_SIZE);
        int totalSlots = timeSlotService.countSlotsBySchedule(scheduleId);
        int totalPages = (int) Math.ceil((double) totalSlots / PAGE_SIZE);
        boolean hasSlots = timeSlotService.hasSlotsForSchedule(scheduleId);

        // Đếm booked slots để hiển thị cảnh báo
        int bookedCount = hasSlots ? timeSlotService.countBookedSlots(scheduleId) : 0;
        int availableCount = hasSlots
                ? timeSlotService.countSlotsByStatus(scheduleId,
                        com.clinic.model.enums.SlotStatus.AVAILABLE)
                : 0;

        // Set attributes
        req.setAttribute("schedule", schedule);
        req.setAttribute("slots", slots);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalSlots", totalSlots);
        req.setAttribute("hasSlots", hasSlots);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("bookedCount", bookedCount);
        req.setAttribute("availableCount", availableCount);

        // Thông báo
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));
        req.setAttribute("warning", req.getParameter("warning"));
        String countParam = req.getParameter("count");
        if (countParam != null) {
            req.setAttribute("generatedCount", parseInt(countParam, 0));
        }

        // Nếu có lỗi hasBookedSlots từ POST, hiển thị modal cảnh báo
        String bookedSlotsError = req.getParameter("bookedSlotsError");
        if (bookedSlotsError != null) {
            req.setAttribute("showBookedSlotsWarning", true);
            req.setAttribute("bookedSlotsError", bookedSlotsError);
            // Lấy danh sách booked slots
            List<TimeSlot> bookedSlots = timeSlotService.getBookedSlotsBySchedule(scheduleId);
            req.setAttribute("bookedSlotsList", bookedSlots);
        }

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    /**
     * Hiển thị trang tổng quan: danh sách tất cả lịch trực đã duyệt.
     */
    private void showApprovedSchedulesOverview(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<DoctorSchedule> approvedSchedules = scheduleService.getSchedules(
                1, 200, "APPROVED", null, null, null);

        Map<Integer, Integer> slotCounts = new HashMap<>();
        Map<Integer, Boolean> slotStatus = new HashMap<>();
        Map<Integer, Integer> bookedCounts = new HashMap<>();
        for (DoctorSchedule sched : approvedSchedules) {
            int count = timeSlotService.countSlotsBySchedule(sched.getId());
            slotCounts.put(sched.getId(), count);
            slotStatus.put(sched.getId(), count > 0);
            if (count > 0) {
                bookedCounts.put(sched.getId(),
                        timeSlotService.countBookedSlots(sched.getId()));
            }
        }

        req.setAttribute("approvedSchedules", approvedSchedules);
        req.setAttribute("slotCounts", slotCounts);
        req.setAttribute("slotStatus", slotStatus);
        req.setAttribute("bookedCounts", bookedCounts);
        req.setAttribute("overviewMode", true);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/slots/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Session check ──
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            redirectToLogin(req, resp);
            return;
        }

        String action = req.getParameter("action");
        int scheduleId = parseInt(req.getParameter("scheduleId"), -1);
        String redirectUrl = req.getContextPath()
                + "/manager/time-slots/?scheduleId=" + scheduleId;

        if (scheduleId <= 0) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/schedules/?error=ID+lịch+trực+không+hợp+lệ");
            return;
        }

        try {
            if ("regenerate".equals(action)) {
                handleRegenerate(req, resp, scheduleId, redirectUrl);
            } else if ("delete".equals(action)) {
                handleDelete(req, resp, scheduleId, redirectUrl);
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

    /**
     * Sinh lại slots — kiểm tra booked slots trước.
     * Nếu có booked slots → chặn, hiển thị danh sách cần xử lý.
     */
    private void handleRegenerate(HttpServletRequest req, HttpServletResponse resp,
                                   int scheduleId, String redirectUrl) throws IOException {
        // Kiểm tra booked slots
        int bookedSlots = timeSlotService.countBookedSlots(scheduleId);

        if (bookedSlots > 0) {
            // Có patient đã đặt → không cho sinh lại, redirect với thông báo
            resp.sendRedirect(redirectUrl
                    + "&warning=Có+" + bookedSlots
                    + "+bệnh+nhân+đã+đặt+lịch.+Không+thể+sinh+lại+slots.+"
                    + "Vui+lòng+xử+lý+các+lịch+hẹn+trước.");
            return;
        }

        // Xóa slots cũ
        Map<String, String> deleteErrors = new HashMap<>();
        boolean deleted = timeSlotService.deleteSlotsBySchedule(scheduleId, deleteErrors);

        if (!deleted && deleteErrors.containsKey("hasBookedSlots")) {
            resp.sendRedirect(redirectUrl
                    + "&bookedSlotsError="
                    + java.net.URLEncoder.encode(deleteErrors.get("hasBookedSlots"), "UTF-8"));
            return;
        }

        // Sinh lại slots
        DoctorSchedule schedule = scheduleService.getScheduleById(scheduleId);
        if (schedule == null || !schedule.isApprovedSchedule()) {
            resp.sendRedirect(redirectUrl
                    + "&error=Chỉ+có+thể+sinh+slot+cho+lịch+trực+đã+duyệt");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        int count = timeSlotService.generateSlotsForSchedule(schedule, errors);

        if (count > 0) {
            User actor = getCurrentUser(req);
            AuditUtil.log(actor != null ? actor.getId() : null,
                    "Sinh " + count + " slot cho lịch trực #" + scheduleId
                    + " (" + schedule.getDoctorName() + " - " + schedule.getWorkDate() + ")",
                    "time_slots", null, "count=" + count, null);
            resp.sendRedirect(redirectUrl + "&success=generated&count=" + count);
        } else if (count == 0) {
            resp.sendRedirect(redirectUrl
                    + "&error=Lịch+trực+có+thời+gian+làm+việc+dưới+20+phút,+không+thể+sinh+slot");
        } else {
            resp.sendRedirect(redirectUrl + "&error="
                    + java.net.URLEncoder.encode(
                            errors.getOrDefault("general", "Lỗi+hệ+thống+khi+sinh+slot"), "UTF-8"));
        }
    }

    /**
     * Xóa slots — kiểm tra booked slots trước.
     */
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp,
                               int scheduleId, String redirectUrl) throws IOException {
        // Kiểm tra booked slots
        int bookedSlots = timeSlotService.countBookedSlots(scheduleId);

        if (bookedSlots > 0) {
            resp.sendRedirect(redirectUrl
                    + "&warning=Có+" + bookedSlots
                    + "+bệnh+nhân+đã+đặt+lịch.+Không+thể+xóa+slots.+"
                    + "Vui+lòng+xử+lý+các+lịch+hẹn+trước+khi+xóa.");
            return;
        }

        Map<String, String> errors = new HashMap<>();
        boolean deleted = timeSlotService.deleteSlotsBySchedule(scheduleId, errors);

        if (deleted) {
            User actor = getCurrentUser(req);
            AuditUtil.log(actor != null ? actor.getId() : null,
                    "Xóa toàn bộ slot của lịch trực #" + scheduleId,
                    "time_slots", null, null, null);
            resp.sendRedirect(redirectUrl + "&success=deleted");
        } else if (errors.containsKey("hasBookedSlots")) {
            resp.sendRedirect(redirectUrl
                    + "&bookedSlotsError="
                    + java.net.URLEncoder.encode(errors.get("hasBookedSlots"), "UTF-8"));
        } else {
            resp.sendRedirect(redirectUrl + "&error="
                    + java.net.URLEncoder.encode(
                            errors.getOrDefault("general", "Không+thể+xóa+slot"), "UTF-8"));
        }
    }

    // ── Private helpers ──

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("user");
    }

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
}
