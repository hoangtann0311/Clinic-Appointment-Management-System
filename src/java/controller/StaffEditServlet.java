package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/admin/reception/edit")
public class StaffEditServlet extends HttpServlet {

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
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                Appointment apt = staffReceptionService.findAppointmentById(id);
                if (apt != null) {
                    req.setAttribute("apt", apt);
                    req.setAttribute("doctors", staffReceptionService.getAllDoctors());
                    req.setAttribute("services", staffReceptionService.getAllServices());
                    req.setAttribute("today", LocalDate.now().toString());
                    req.setAttribute("activeSos", staffReceptionService.getWidgetActiveSos());
                    
                    req.getRequestDispatcher("/views/staff/reception-edit.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/reception");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String idStr = req.getParameter("id");
        String doctorId = req.getParameter("doctorId");
        String serviceId = req.getParameter("serviceId");
        String appDate = req.getParameter("appointmentDate");
        String timeSlot = req.getParameter("timeSlot");
        String symptoms = req.getParameter("symptoms");
        String lmp = req.getParameter("lastMenstrualPeriod");

        int id;

        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/reception");
            return;
        }

        try {
            staffReceptionService.updateAppointment(id, doctorId, serviceId, appDate, timeSlot, symptoms, lmp);
            resp.sendRedirect(req.getContextPath() + "/admin/reception");

        } catch (IllegalArgumentException e) {
            Appointment apt = staffReceptionService.findAppointmentById(id);

            req.setAttribute("errors", Arrays.asList(e.getMessage().split("\\|")));
            req.setAttribute("apt", apt);
            req.setAttribute("doctors", staffReceptionService.getAllDoctors());
            req.setAttribute("services", staffReceptionService.getAllServices());
            req.setAttribute("today", LocalDate.now().toString());
            req.setAttribute("activeSos", staffReceptionService.getWidgetActiveSos());

            req.getRequestDispatcher("/views/staff/reception-edit.jsp").forward(req, resp);
        }
    }
}
