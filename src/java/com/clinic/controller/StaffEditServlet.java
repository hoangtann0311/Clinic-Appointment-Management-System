package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.Invoice;
import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

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
        if (!requireReceptionAccess(req, resp)) return;
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
                    req.setAttribute("currentDisplayDate", LocalDate.now().format(DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")));

                    Invoice preInvoice = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(id, "PRE_EXAM");
                    req.setAttribute("preInvoice", preInvoice);

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
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Thao tác chỉnh sửa tiếp đón chỉ dành cho nhân viên Lễ tân (Staff).");
            return;
        }
        req.setCharacterEncoding("UTF-8");

        String idStr = req.getParameter("id");
        String action = req.getParameter("action");

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/reception");
            return;
        }

        if ("confirmPayment".equals(action)) {
            String paymentMethod = req.getParameter("paymentMethod");
            String transactionCode = req.getParameter("transactionCode");
            String paymentNote = req.getParameter("paymentNote");

            int userId = user != null ? user.getId() : 0;

            Invoice preInvoice = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(id, "PRE_EXAM");
            if (preInvoice == null || (!"PendingConfirmation".equalsIgnoreCase(preInvoice.getStatus())
                    && !"Unpaid".equalsIgnoreCase(preInvoice.getStatus()))) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&error=" + java.net.URLEncoder.encode("Không thể xác nhận thanh toán cho hóa đơn này.", "UTF-8"));
                return;
            }

            boolean success = staffReceptionService.confirmPayment(preInvoice.getId(), paymentMethod, transactionCode, paymentNote, userId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&success=paymentConfirmed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&error=" + java.net.URLEncoder.encode("Không thể xác nhận thanh toán.", "UTF-8"));
            }
            return;
        }

        String doctorId = req.getParameter("doctorId");
        String serviceId = req.getParameter("serviceId");
        String appDate = req.getParameter("appointmentDate");
        String timeSlot = req.getParameter("timeSlot");
        String symptoms = req.getParameter("symptoms");
        String lmp = req.getParameter("lastMenstrualPeriod");

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

            req.getRequestDispatcher("/views/staff/reception-edit.jsp").forward(req, resp);
        }
    }

    private boolean requireReceptionAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa lịch tiếp đón.");
            return false;
        }
        return true;
    }
}
