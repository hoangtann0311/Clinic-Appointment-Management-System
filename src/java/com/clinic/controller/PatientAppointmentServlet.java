package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.Invoice;
import com.clinic.model.Prescription;
import com.clinic.model.User;
import com.clinic.service.PatientBookingService;

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
 * Xem danh sách và huỷ lịch hẹn của Patient — mục 4.3 BA (Hủy hoặc đổi lịch).
 * (Đổi lịch chưa được hiện thực trong bản này — xem ghi chú cuối servlet.)
 *
 * URL patterns:
 *   GET  /patient/appointments                 → danh sách lịch hẹn của bản thân
 *   POST /patient/appointments?action=cancel   → huỷ 1 lịch hẹn (param: appointmentId)
 */
@WebServlet("/patient/appointments")
public class PatientAppointmentServlet extends HttpServlet {

    private final PatientBookingService bookingService = new PatientBookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);
        if (user == null) return;

        List<Appointment> appointments = bookingService.getMyAppointments(user.getId());
        request.setAttribute("appointments", appointments);

        // Load invoices for payment status display
        Map<Integer, Invoice> postExamInvoices = new HashMap<>();
        Map<Integer, Invoice> prescriptionInvoices = new HashMap<>();
        Map<Integer, Boolean> prescriptionPurchaseResolved = new HashMap<>();
        com.clinic.dao.PrescriptionDAO prescriptionDAO =
                new com.clinic.dao.PrescriptionDAO();
        for (Appointment apt : appointments) {
            Invoice postInv = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(apt.getId(), "POST_EXAM");
            if (postInv != null && !"Paid".equalsIgnoreCase(postInv.getStatus()) && !"PendingConfirmation".equalsIgnoreCase(postInv.getStatus())) {
                postExamInvoices.put(apt.getId(), postInv);
            }
            Invoice rxInv = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(apt.getId(), "PRESCRIPTION");
            if (rxInv != null && !"Paid".equalsIgnoreCase(rxInv.getStatus()) && !"PendingConfirmation".equalsIgnoreCase(rxInv.getStatus())) {
                prescriptionInvoices.put(apt.getId(), rxInv);
            }
            prescriptionPurchaseResolved.put(
                    apt.getId(),
                    prescriptionDAO.isPurchaseResolvedForReview(apt.getId()));
        }
        request.setAttribute("postExamInvoices", postExamInvoices);
        request.setAttribute("prescriptionInvoices", prescriptionInvoices);
        request.setAttribute(
                "prescriptionPurchaseResolved", prescriptionPurchaseResolved);
        Map<Integer, Prescription> pendingPrescriptionChoices = new HashMap<>();
        for (Prescription prescription :
                prescriptionDAO.getPatientPurchaseChoices(user.getId())) {
            if ("Pending".equalsIgnoreCase(prescription.getPurchaseDecision())) {
                pendingPrescriptionChoices.put(
                        prescription.getAppointmentId(), prescription);
            }
        }
        request.setAttribute("pendingPrescriptionChoices", pendingPrescriptionChoices);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("bookingSuccess") != null) {
            request.setAttribute("bookingSuccess", session.getAttribute("bookingSuccess"));
            session.removeAttribute("bookingSuccess");
        }
        if (session != null && session.getAttribute("bookingError") != null) {
            request.setAttribute("bookingError", session.getAttribute("bookingError"));
            session.removeAttribute("bookingError");
        }
        String errorCode = request.getParameter("bookingError");
        if (request.getAttribute("bookingError") == null && errorCode != null) {
            request.setAttribute("bookingError", mapErrorCode(errorCode));
        }

        request.getRequestDispatcher("/views/patient/appointments.jsp").forward(request, response);
    }

    private final com.clinic.dao.AppointmentDAO appointmentDAO = new com.clinic.dao.AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User user = requireLogin(request, response);
        if (user == null) return;

        String action = request.getParameter("action");

        if ("cancel".equals(action)) {
            Map<String, String> errors = new HashMap<>();
            try {
                int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
                boolean ok = bookingService.cancelAppointment(user.getId(), appointmentId, errors);

                HttpSession session = request.getSession();
                if (ok) {
                    session.setAttribute("bookingSuccess", "Đã huỷ lịch hẹn thành công.");
                } else {
                    session.setAttribute("bookingError",
                            errors.getOrDefault("general", "Không thể huỷ lịch hẹn."));
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("bookingError", "Lịch hẹn không hợp lệ.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/patient/appointments");
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private String mapErrorCode(String code) {
        if ("ChuaXuLyDonThuoc".equals(code)) {
            return "Vui lòng chọn mua hoặc không mua thuốc tại phòng khám trước khi đánh giá.";
        }
        if ("ChuaThanhToanDonThuoc".equals(code)) {
            return "Hóa đơn thuốc chưa được thanh toán.";
        }
        if ("LichHenChuaHoanThanh".equals(code)) {
            return "Lịch hẹn chưa hoàn thành nên chưa thể đánh giá.";
        }
        return "Không thể thực hiện thao tác. Vui lòng kiểm tra lại.";
    }
}
