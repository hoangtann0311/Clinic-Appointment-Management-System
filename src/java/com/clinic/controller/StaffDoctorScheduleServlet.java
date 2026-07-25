package com.clinic.controller;

import com.clinic.model.DoctorSchedule;
import com.clinic.model.TimeSlot;
import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Gộp "Lịch làm việc" + "Khung giờ khám" thành một màn hình duy nhất.
 *
 * GET /admin/reception/doctor-schedules → tổng quan ca trực + chi tiết từng slot
 * GET /admin/reception/slots             → redirect về /doctor-schedules (backward compat)
 */
@WebServlet(urlPatterns = {
        "/admin/reception/doctor-schedules",
        "/admin/reception/slots"
})
public class StaffDoctorScheduleServlet extends HttpServlet {

    private StaffReceptionService receptionService;

    @Override
    public void init() {
        receptionService = (StaffReceptionService) getServletContext()
                .getAttribute("staffReceptionService");
        if (receptionService == null) {
            receptionService = new StaffReceptionService();
            getServletContext().setAttribute("staffReceptionService", receptionService);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Staff access required.");
            return;
        }

        // Backward-compat: /slots redirects to /doctor-schedules, preserving date param
        if (request.getServletPath().endsWith("/slots")) {
            String date = request.getParameter("date");
            String redirect = request.getContextPath() + "/admin/reception/doctor-schedules"
                    + (date != null && !date.isBlank() ? "?date=" + date : "");
            response.sendRedirect(redirect);
            return;
        }

        try {
            LocalDate date = parseDate(request.getParameter("date"));
            request.setAttribute("selectedDate", date.toString());
            request.setAttribute("displayDate", date.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            request.setAttribute("currentDisplayDate", LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

            // 1. Danh sach ca truc (tong quan theo bac si)
            List<DoctorSchedule> schedules = receptionService.getApprovedDoctorSchedules(date);
            request.setAttribute("schedules", schedules);

            // 2. Chi tiet tung slot trong ngay (co ten benh nhan, trang thai)
            List<TimeSlot> slots = receptionService.getDoctorSlotsForReception(date);
            request.setAttribute("slots", slots);

            request.getRequestDispatcher("/views/staff/doctor-schedules.jsp").forward(request, response);
        } catch (Exception ex) {
            System.err.println("[StaffDoctorScheduleServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Khong the tai trang. Vui long thu lai sau.");
            request.getRequestDispatcher("/views/staff/doctor-schedules.jsp").forward(request, response);
        }
    }

    private LocalDate parseDate(String value) {
        try {
            return value != null && !value.isBlank() ? LocalDate.parse(value) : LocalDate.now();
        } catch (Exception ignored) {
            return LocalDate.now();
        }
    }
}
