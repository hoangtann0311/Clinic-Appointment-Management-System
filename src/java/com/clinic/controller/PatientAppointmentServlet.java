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

        try {
            int page = 1;
            int pageSize = 10;
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");

            if (request.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            List<Appointment> appointments = bookingService.getMyAppointmentsPaginated(user.getId(), keyword, status, page, pageSize);
            int totalAppointments = bookingService.countMyAppointments(user.getId(), keyword, status);
            int totalPages = (int) Math.ceil((double) totalAppointments / pageSize);

            request.setAttribute("appointments", appointments);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("keyword", keyword);
            request.setAttribute("status", status);

            // Batch load invoices + prescription status — 2 queries thay vì N*3 queries
            com.clinic.dao.InvoiceDAO invoiceDAO = new com.clinic.dao.InvoiceDAO();
            com.clinic.dao.PrescriptionDAO prescriptionDAO = new com.clinic.dao.PrescriptionDAO();

            java.util.List<Integer> apptIds = new java.util.ArrayList<>();
            for (Appointment apt : appointments) apptIds.add(apt.getId());

            // 1 query: tất cả POST_EXAM + PRESCRIPTION invoices
            java.util.Map<Integer, java.util.Map<String, Invoice>> invoiceMap =
                    invoiceDAO.getPostExamAndPrescriptionInvoices(apptIds);

            Map<Integer, Invoice> postExamInvoices = new HashMap<>();
            for (Appointment apt : appointments) {
                java.util.Map<String, Invoice> map = invoiceMap.getOrDefault(apt.getId(), java.util.Collections.emptyMap());
                Invoice postInv = map.get("POST_EXAM");
                if (postInv != null && !"Paid".equalsIgnoreCase(postInv.getStatus()) && !"PendingConfirmation".equalsIgnoreCase(postInv.getStatus())) {
                    postExamInvoices.put(apt.getId(), postInv);
                }
            }
            // 1 query: đã đánh giá chưa (để ẩn nút sau khi đánh giá)
            Map<Integer, Boolean> hasReviewed = new com.clinic.dao.ReviewDAO().batchHasReviewed(apptIds);

            request.setAttribute("postExamInvoices", postExamInvoices);
            request.setAttribute("hasReviewed", hasReviewed);

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
        } catch (Exception ex) {
            System.err.println("[PatientAppointmentServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/patient/appointments.jsp").forward(request, response);
        }
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
