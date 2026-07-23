package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import com.clinic.utils.NotificationHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;

@WebServlet("/admin/reception/booking")
public class StaffBookingServlet extends HttpServlet {

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
        LocalDate currentDate = LocalDate.now();
        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy");

        req.setAttribute("currentDisplayDate", currentDate.format(displayFormatter));

        req.setAttribute("doctors", staffReceptionService.getAllDoctors());
        req.setAttribute("services", staffReceptionService.getAllServices());
        req.setAttribute("today", currentDate.toString());

        req.getRequestDispatcher("/views/staff/reception-booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Thao tác đặt lịch tại quầy chỉ dành cho nhân viên Lễ tân (Staff).");
            return;
        }
        req.setCharacterEncoding("UTF-8");

        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        String dob = req.getParameter("dob");
        String doctorId = req.getParameter("doctorId");
        String serviceId = req.getParameter("serviceId");
        String appDate = req.getParameter("appointmentDate");
        String timeSlot = req.getParameter("timeSlot");
        String symptoms = req.getParameter("symptoms");
        String lmp = req.getParameter("lastMenstrualPeriod");
        try {
            Appointment appt = staffReceptionService.createManualBooking(
                    name, phone, dob, doctorId, serviceId, appDate, timeSlot, symptoms, lmp, false
            );

            // Thông báo cho bác sĩ về lịch hẹn mới
            try {
                if (appt != null) {
                    int docUserId = NotificationHelper.getDoctorUserId(appt.getDoctorId());
                    if (docUserId > 0) {
                        String patientName = appt.getPatientName() != null ? appt.getPatientName() : name;
                        String slot = appt.getTimeSlot() != null ? appt.getTimeSlot() : timeSlot;
                        NotificationHelper.newAppointment(docUserId, patientName,
                                appDate, slot != null ? slot : "");
                    }
                }
            } catch (Exception ignored) {}

            resp.sendRedirect(req.getContextPath() + "/admin/reception");

        } catch (IllegalArgumentException e) {
            LocalDate currentDate = LocalDate.now();
            DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy");

            req.setAttribute("errors", Arrays.asList(e.getMessage().split("\\|")));

            req.setAttribute("currentDisplayDate", currentDate.format(displayFormatter));
            req.setAttribute("doctors", staffReceptionService.getAllDoctors());
            req.setAttribute("services", staffReceptionService.getAllServices());
            req.setAttribute("today", currentDate.toString());

            req.getRequestDispatcher("/views/staff/reception-booking.jsp").forward(req, resp);
        }
    }

    private boolean requireReceptionAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền tạo lịch tại quầy.");
            return false;
        }
        return true;
    }
}
