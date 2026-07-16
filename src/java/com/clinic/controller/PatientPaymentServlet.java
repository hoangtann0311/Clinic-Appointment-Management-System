package com.clinic.controller;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.model.Appointment;
import com.clinic.model.Invoice;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;

@WebServlet("/patient/payment")
public class PatientPaymentServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String appointmentIdStr = request.getParameter("appointmentId");
        if (appointmentIdStr == null || appointmentIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã lịch hẹn.");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(appointmentIdStr);
            Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
            if (appt == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch hẹn.");
                return;
            }

            // Security check: only view own appointment invoice
            int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
            if (appt.getPatientId() != patientId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập hóa đơn này.");
                return;
            }

            // Retrieve or create PRE_EXAM invoice
            Invoice invoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
            if (invoice == null) {
                invoice = new Invoice();
                invoice.setAppointmentId(appointmentId);
                double price = appt.getService() != null ? appt.getService().getPrice() : 250000;
                invoice.setTotalAmount(BigDecimal.valueOf(price));
                invoice.setStatus("Unpaid");
                invoice.setInvoiceType("PRE_EXAM");
                invoice.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                
                int invoiceId = invoiceDAO.insert(invoice);
                if (invoiceId > 0) {
                    invoice = invoiceDAO.getById(invoiceId);
                }
            }

            // Load POST_EXAM invoice if exists (for display)
            Invoice postInvoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, "POST_EXAM");

            request.setAttribute("appointment", appt);
            request.setAttribute("invoice", invoice);
            request.setAttribute("postInvoice", postInvoice);
            request.setAttribute("success", request.getParameter("success"));
            request.setAttribute("error", request.getParameter("error"));

            request.getRequestDispatcher("/views/patient/payment.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã lịch hẹn không hợp lệ.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String invoiceIdStr = request.getParameter("invoiceId");
        String paymentMethod = request.getParameter("paymentMethod");
        String transactionCode = request.getParameter("transactionCode");

        if (invoiceIdStr == null || invoiceIdStr.trim().isEmpty() || paymentMethod == null || paymentMethod.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=ThieuThongTinThanhToan");
            return;
        }

        try {
            int invoiceId = Integer.parseInt(invoiceIdStr);
            Invoice invoice = invoiceDAO.getById(invoiceId);
            if (invoice == null) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=HoaDonKhongTonTai");
                return;
            }

            if ("Paid".equalsIgnoreCase(invoice.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&error=HoaDonDaThanhToan");
                return;
            }

            String status = "Unpaid";
            if ("BankTransfer".equalsIgnoreCase(paymentMethod)) {
                if (transactionCode == null || transactionCode.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&error=Mã giao dịch là bắt buộc.");
                    return;
                }
                status = "PendingConfirmation";
            } else if ("Cash".equalsIgnoreCase(paymentMethod)) {
                status = "Unpaid";
                transactionCode = "";
            }

            boolean ok = invoiceDAO.submitPaymentDetails(invoiceId, paymentMethod, transactionCode, status);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&success=ThanhToanChoXacNhan");
            } else {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&error=LoiCapNhatThanhToan");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LoiThanhToan");
        }
    }
}
