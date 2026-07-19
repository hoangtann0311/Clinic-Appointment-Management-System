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

            User user = (User) req.getSession().getAttribute("user");
            int userId = user != null ? user.getId() : 0;

            Invoice preInvoice = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(id, "PRE_EXAM");
            if (preInvoice == null || !"PendingConfirmation".equalsIgnoreCase(preInvoice.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&error=Không thể xác nhận thanh toán cho hóa đơn này.");
                return;
            }

            boolean success = staffReceptionService.confirmPayment(preInvoice.getId(), paymentMethod, transactionCode, paymentNote, userId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&success=paymentConfirmed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&error=Không thể xác nhận thanh toán.");
            }
            return;
        }

        if ("rejectPayment".equals(action)) {
            String rejectReason = req.getParameter("rejectReason");
            String invoiceIdParam = req.getParameter("invoiceId");

            User user = (User) req.getSession().getAttribute("user");
            int userId = user != null ? user.getId() : 0;

            Invoice targetInvoice;
            if (invoiceIdParam != null && !invoiceIdParam.trim().isEmpty()) {
                // Gọi từ trang Xác Nhận Thanh Toán (reception-payments.jsp) — biết chính xác invoiceId,
                // áp dụng được cho mọi loại hóa đơn (PRE_EXAM/POST_EXAM/PRESCRIPTION).
                targetInvoice = new com.clinic.dao.InvoiceDAO().getById(Integer.parseInt(invoiceIdParam));
            } else {
                // Gọi từ trang reception-edit.jsp (chỉ có appointmentId) — giữ hành vi cũ, chỉ xét PRE_EXAM.
                targetInvoice = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(id, "PRE_EXAM");
            }

            if (targetInvoice == null || !"PendingConfirmation".equalsIgnoreCase(targetInvoice.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/edit?id=" + id + "&error=Không thể từ chối hóa đơn này.");
                return;
            }

            try {
                boolean success = staffReceptionService.rejectPayment(targetInvoice.getId(), rejectReason, userId);
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/reception/payments?success=paymentRejected");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/reception/payments?error=Không thể từ chối thanh toán.");
                }
            } catch (IllegalArgumentException e) {
                resp.sendRedirect(req.getContextPath() + "/admin/reception/payments?error=" + e.getMessage());
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
            req.setAttribute("activeSos", staffReceptionService.getWidgetActiveSos());

            req.getRequestDispatcher("/views/staff/reception-edit.jsp").forward(req, resp);
        }
    }
}