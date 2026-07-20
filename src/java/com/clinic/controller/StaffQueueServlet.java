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
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/reception", "/admin/reception/checkin", "/admin/reception/cancel"})
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

        if ("/admin/reception/checkin".equals(path) || "/admin/reception/cancel".equals(path)) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Check-in và hủy lịch phải dùng POST.");
            return;
        }
        renderQueue(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireReceptionAccess(req, resp)) return;
        String path = req.getServletPath();

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
        req.setAttribute("activeSos", staffReceptionService.getWidgetActiveSosByDate(selectedDate));

        req.setAttribute("zaloMsgs", staffReceptionService.getZaloNotifications()
                .stream()
                .limit(5)
                .collect(Collectors.toList()));

        req.getRequestDispatcher("/views/staff/reception-queue.jsp").forward(req, resp);
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
