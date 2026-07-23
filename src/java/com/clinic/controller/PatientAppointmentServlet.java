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

        List<Appointment> appointments = bookingService.getMyAppointments(user.getId());
        request.setAttribute("appointments", appointments);

        // Load invoices for payment status display
        Map<Integer, Invoice> postExamInvoices = new HashMap<>();
        Map<Integer, Invoice> prescriptionInvoices = new HashMap<>();
        for (Appointment apt : appointments) {
            Invoice postInv = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(apt.getId(), "POST_EXAM");
            if (postInv != null && !"Paid".equalsIgnoreCase(postInv.getStatus()) && !"PendingConfirmation".equalsIgnoreCase(postInv.getStatus())) {
                postExamInvoices.put(apt.getId(), postInv);
            }
            Invoice rxInv = new com.clinic.dao.InvoiceDAO().getByAppointmentIdAndType(apt.getId(), "PRESCRIPTION");
            if (rxInv != null && !"Paid".equalsIgnoreCase(rxInv.getStatus()) && !"PendingConfirmation".equalsIgnoreCase(rxInv.getStatus()) && !"DeclinedPurchase".equalsIgnoreCase(rxInv.getStatus())) {
                prescriptionInvoices.put(apt.getId(), rxInv);
            }
        }
        request.setAttribute("postExamInvoices", postExamInvoices);
        request.setAttribute("prescriptionInvoices", prescriptionInvoices);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("bookingSuccess") != null) {
            request.setAttribute("bookingSuccess", session.getAttribute("bookingSuccess"));
            session.removeAttribute("bookingSuccess");
        }
        if (session != null && session.getAttribute("bookingError") != null) {
            request.setAttribute("bookingError", session.getAttribute("bookingError"));
            session.removeAttribute("bookingError");
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
        } else if ("sos".equals(action)) {
            try {
                int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));

                // Bảo mật: Xác minh lịch hẹn có thuộc về bệnh nhân đang đăng nhập không
                int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
                Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
                HttpSession session = request.getSession();
                if (appt == null || appt.getPatientId() != patientId) {
                    session.setAttribute("bookingError", "Bạn không có quyền kích hoạt SOS cho lịch hẹn này.");
                    response.sendRedirect(request.getContextPath() + "/patient/appointments");
                    return;
                }

                // Triệu chứng bệnh nhân mô tả trong modal
                String sosSymptoms = request.getParameter("symptoms");
                if (sosSymptoms == null || sosSymptoms.isBlank()) {
                    sosSymptoms = "Bệnh nhân báo động khẩn cấp SOS.";
                }
                sosSymptoms = sosSymptoms.trim();
                if (sosSymptoms.length() > 500) {
                    request.getSession().setAttribute("bookingError", "Mô tả SOS không được vượt quá 500 ký tự.");
                    response.sendRedirect(request.getContextPath() + "/patient/appointments");
                    return;
                }

                String queueNum = appointmentDAO.activateEmergencySosForAppointment(
                        appointmentId, patientId, sosSymptoms);
                boolean ok = queueNum != null;

                if (ok) {
                    
                    // Gửi thông báo khẩn cấp cho bác sĩ phụ trách
                    try {
                        String[] apptInfo = com.clinic.utils.NotificationHelper.getApptInfo(appointmentId);
                        if (apptInfo != null) {
                            String patientName = apptInfo[0];
                            int doctorUserId = Integer.parseInt(apptInfo[3]);
                            com.clinic.utils.NotificationHelper.sosAlert(doctorUserId, patientName, queueNum, sosSymptoms);
                        }
                    } catch (Exception e) {
                        System.err.println("[PatientAppointmentServlet] Gửi thông báo SOS thất bại: " + e.getMessage());
                    }
                }

                session = request.getSession();
                if (ok) {
                    session.setAttribute("bookingSuccess",
                            "Báo động khẩn cấp SOS đã được kích hoạt! Số thứ tự ưu tiên: "
                            + queueNum + ". Vui lòng giữ bình tĩnh, bác sĩ đang được điều phối.");

                    // Log action
                    new com.clinic.dao.AuditLogDAO().logAction(
                            "Bệnh nhân kích hoạt SOS cho lịch hẹn #" + appointmentId
                                    + " | Triệu chứng: " + sosSymptoms,
                            "Patient",
                            "appointments",
                            "Confirmed",
                            "Emergency_SOS"
                    );
                } else {
                    session.setAttribute("bookingError", "Không thể kích hoạt SOS cho lịch hẹn này. Vui lòng thử lại.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("bookingError", "Mã lịch hẹn không hợp lệ.");
            }
        } else if ("globalSos".equals(action)) {
            // Global emergency activation
            try {
                String symptoms = request.getParameter("symptoms");
                if (symptoms == null || symptoms.trim().isEmpty()) {
                    symptoms = "Báo động khẩn cấp SOS kích hoạt từ thiết bị của Bệnh nhân.";
                }
                
                // Retrieve or create patient profile
                int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
                com.clinic.model.Patient patient = null;
                if (patientId > 0) {
                    patient = new com.clinic.dao.PatientDAO().findById(patientId);
                } else {
                    patient = new com.clinic.dao.PatientDAO().createPatientWithUserId(
                            user.getFullName(), user.getPhone(), null, "zalo_" + user.getPhone(), user.getId()
                    );
                }
                
                if (patient != null) {
                    // Trigger SOS manual using StaffReceptionService logic
                    com.clinic.service.StaffReceptionService receptionService = new com.clinic.service.StaffReceptionService();
                    receptionService.activateEmergencySosManual(patient.getFullName(), patient.getPhone(), symptoms);
                    
                    HttpSession session = request.getSession();
                    session.setAttribute("bookingSuccess", "Báo động đỏ SOS khẩn cấp đã được phát toàn hệ thống! Vui lòng giữ an toàn, nhân viên y tế đang đến.");
                } else {
                    request.getSession().setAttribute("bookingError", "Không thể kích hoạt SOS vì không tạo được hồ sơ bệnh nhân.");
                }
            } catch (Exception e) {
                request.getSession().setAttribute("bookingError", "Lỗi kích hoạt SOS: " + e.getMessage());
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
}
