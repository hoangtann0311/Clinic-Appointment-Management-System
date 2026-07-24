package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;

import java.io.IOException;

@WebServlet(urlPatterns = {
        "/admin/reception",
        "/admin/reception/checkin",
        "/admin/reception/cancel",
        "/admin/reception/priority"
})
public class StaffQueueServlet extends HttpServlet {

    private StaffReceptionService staffReceptionService;

    @Override
    public void init() throws ServletException {
        staffReceptionService = (StaffReceptionService) getServletContext().getAttribute("staffReceptionService");

        if (staffReceptionService == null) {
            staffReceptionService = new StaffReceptionService();
            getServletContext().setAttribute("staffReceptionService", staffReceptionService);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireReceptionAccess(req, resp)) return;
        String path = req.getServletPath();

        if ("/admin/reception/checkin".equals(path)
                || "/admin/reception/cancel".equals(path)
                || "/admin/reception/priority".equals(path)) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                    "Check-in, hủy lịch và cập nhật ưu tiên phải dùng POST.");
            return;
        }
        renderQueue(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Thao tác tiếp đón chỉ dành cho nhân viên Lễ tân (Staff).");
            return;
        }
        String path = req.getServletPath();

        if ("/admin/reception/priority".equals(path)) {
            try {
                String action = req.getParameter("action");
                if ("mark".equals(action)) {
                    staffReceptionService.markPriority(
                            req.getParameter("id"),
                            req.getParameter("reason"),
                            user.getId(),
                            getClientIp(req));
                    req.getSession().setAttribute(
                            "queueSuccess", "Đã đưa ca khám lên mức ưu tiên.");
                } else if ("clear".equals(action)) {
                    staffReceptionService.clearPriority(
                            req.getParameter("id"), user.getId(), getClientIp(req));
                    req.getSession().setAttribute(
                            "queueSuccess", "Đã bỏ mức ưu tiên của ca khám.");
                } else {
                    throw new IllegalArgumentException("Thao tác ưu tiên không hợp lệ.");
                }
            } catch (IllegalArgumentException | IllegalStateException e) {
                req.getSession().setAttribute("queueError", e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/reception");
            return;
        }

        if ("/admin/reception/checkin".equals(path)) {
            String id = req.getParameter("id");

            try {
                staffReceptionService.checkInPatient(id);
                resp.sendRedirect(req.getContextPath() + "/admin/reception");
            } catch (IllegalArgumentException e) {
                req.setAttribute("errors", Collections.singletonList(e.getMessage()));
                renderQueue(req, resp);
            }

            return;
        }

        if ("/admin/reception/cancel".equals(path)) {
            String id = req.getParameter("id");

            try {
                staffReceptionService.cancelAppointment(id);
                resp.sendRedirect(req.getContextPath() + "/admin/reception");
            } catch (IllegalArgumentException e) {
                req.setAttribute("errors", Collections.singletonList(e.getMessage()));
                renderQueue(req, resp);
            }

            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reception");
    }

    private void renderQueue(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate selectedDate;

        String dateParam = req.getParameter("date");
        if (dateParam != null && !dateParam.isEmpty()) {
            try {
                selectedDate = LocalDate.parse(dateParam);
            } catch (java.time.format.DateTimeParseException e) {
                selectedDate = LocalDate.now();
                req.setAttribute("errors", Collections.singletonList("Ngày lọc không hợp lệ. Hệ thống đã hiển thị lịch hôm nay."));
            }
        } else {
            selectedDate = LocalDate.now();
        }

        LocalDate currentDate = LocalDate.now();

        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy");

        req.setAttribute("selectedDate", selectedDate.toString());
        req.setAttribute("displayDate", selectedDate.format(displayFormatter));

// Ngày hiện tại dùng riêng cho header trên cùng
        req.setAttribute("currentDisplayDate", currentDate.format(displayFormatter));

        req.setAttribute("queue", staffReceptionService.getSmartQueueByDate(selectedDate));
        req.setAttribute("todayAppointments", staffReceptionService.getWidgetAppointmentsByDate(selectedDate));
        req.setAttribute("waitingQueue", staffReceptionService.getWidgetWaitingQueueByDate(selectedDate));
        // Đánh dấu bệnh nhân đến muộn (>60 phút sau giờ hẹn)
        req.setAttribute("lateAppointments", staffReceptionService.getLateAppointmentIds(selectedDate));
        Object queueSuccess = req.getSession().getAttribute("queueSuccess");
        if (queueSuccess != null) {
            req.setAttribute("queueSuccess", queueSuccess);
            req.getSession().removeAttribute("queueSuccess");
        }
        Object queueError = req.getSession().getAttribute("queueError");
        if (queueError != null) {
            req.setAttribute("queueError", queueError);
            req.getSession().removeAttribute("queueError");
        }
        req.getRequestDispatcher("/views/staff/reception-queue.jsp").forward(req, resp);
    }

    private String getClientIp(HttpServletRequest req) {
        String forwarded = req.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }

    private boolean requireReceptionAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền sử dụng khu vực tiếp đón.");
            return false;
        }
        return true;
    }
}
