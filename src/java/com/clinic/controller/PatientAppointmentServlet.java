package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.Invoice;
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

            // ── Load invoice data cho hiển thị cột "Thanh toán" ──
            com.clinic.dao.InvoiceDAO invoiceDAO = new com.clinic.dao.InvoiceDAO();

            Map<Integer, String> preExamPaymentMethods = new HashMap<>();
            Map<Integer, String> preExamPaymentStatuses = new HashMap<>();
            for (Appointment apt : appointments) {
                Invoice preInv = invoiceDAO.getByAppointmentIdAndType(apt.getId(), "PRE_EXAM");
                if (preInv != null) {
                    if (preInv.getPaymentMethod() != null && !preInv.getPaymentMethod().isEmpty()) {
                        preExamPaymentMethods.put(apt.getId(), preInv.getPaymentMethod());
                    }
                    if ("Paid".equalsIgnoreCase(preInv.getStatus())) {
                        preExamPaymentStatuses.put(apt.getId(), "Paid");
                    }
                }
            }

            request.setAttribute("preExamPaymentMethods", preExamPaymentMethods);
            request.setAttribute("preExamPaymentStatuses", preExamPaymentStatuses);

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
