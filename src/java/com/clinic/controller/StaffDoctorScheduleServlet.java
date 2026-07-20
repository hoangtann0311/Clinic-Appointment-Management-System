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
 * Read-only schedule views for reception staff.  Schedule changes remain a
 * Manager responsibility; Staff use these screens to make safe bookings.
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

        LocalDate date = parseDate(request.getParameter("date"));
        request.setAttribute("selectedDate", date.toString());
        request.setAttribute("displayDate", date.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        request.setAttribute("currentDisplayDate", LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

        if (request.getServletPath().endsWith("/slots")) {
            List<TimeSlot> slots = receptionService.getDoctorSlotsForReception(date);
            request.setAttribute("slots", slots);
            request.getRequestDispatcher("/views/staff/doctor-slots.jsp").forward(request, response);
            return;
        }

        List<DoctorSchedule> schedules = receptionService.getApprovedDoctorSchedules(date);
        request.setAttribute("schedules", schedules);
        request.getRequestDispatcher("/views/staff/doctor-schedules.jsp").forward(request, response);
    }

    private LocalDate parseDate(String value) {
        try {
            return value != null && !value.isBlank() ? LocalDate.parse(value) : LocalDate.now();
        } catch (Exception ignored) {
            return LocalDate.now();
        }
    }
}
