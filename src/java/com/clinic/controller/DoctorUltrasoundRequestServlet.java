package com.clinic.controller;

import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.AppointmentDAO;
import com.clinic.model.Doctor;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Invoice;
import com.clinic.model.ServiceItem;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Servlet xử lý yêu cầu tạo chỉ định siêu âm của Bác sĩ.
 */
@WebServlet("/doctor/ultrasound-request/create")
public class DoctorUltrasoundRequestServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền thực hiện.");
            return;
        }

        String apptIdStr = request.getParameter("apptId");
        String serviceIdStr = request.getParameter("serviceId");
        String reorderReason = request.getParameter("reorderReason");
        if (reorderReason == null || reorderReason.isBlank()) {
            reorderReason = request.getParameter("additionalReason");
        }
        reorderReason = reorderReason == null ? "" : reorderReason.trim();
        if (reorderReason.length() > 500) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Lý do chỉ định không được vượt quá 500 ký tự.");
            return;
        }

        if (apptIdStr == null || apptIdStr.trim().isEmpty()
                || serviceIdStr == null || serviceIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số apptId hoặc serviceId.");
            return;
        }

        try {
            int apptId = Integer.parseInt(apptIdStr.trim());
            int serviceId = Integer.parseInt(serviceIdStr.trim());
            if (apptId <= 0 || serviceId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "apptId và serviceId phải là số dương.");
                return;
            }

            if (!serviceDAO.isActiveUltrasoundService(serviceId)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Chỉ có thể chỉ định một dịch vụ siêu âm đang hoạt động.");
                return;
            }

            // test_orders.doctor_id references the doctors profile ID, not users.id.
            Doctor doctor = doctorDAO.findByUserId(user.getId());
            if (doctor == null || doctor.getId() <= 0) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                        "Tài khoản bác sĩ chưa được liên kết với hồ sơ bác sĩ.");
                return;
            }

            if (!medicalRecordDAO.appointmentBelongsToDoctor(apptId, doctor.getId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉ định siêu âm cho ca khám này.");
                return;
            }

            // 1. Kiểm tra / tạo hồ sơ bệnh án
            MedicalRecord record = medicalRecordDAO.getByAppointmentId(apptId);
            if (record == null || record.getId() <= 0) {
                response.sendRedirect(request.getContextPath()
                        + "/doctor/medical-records?apptId=" + apptId + "&error=saveRecordFirst");
                return;
            }
            if (!"draft".equalsIgnoreCase(record.getStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/doctor/medical-records?apptId=" + apptId + "&error=recordClosed");
                return;
            }
            if (!appointmentDAO.isConsultationInProgress(apptId, doctor.getId())) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                        "Chỉ được chỉ định siêu âm khi ca khám đang ở trạng thái Đang khám.");
                return;
            }
            // A service selected during booking belongs to PRE_EXAM and must
            // not be charged again when the doctor creates its clinical order.
            boolean includedInBookedAppointment = appointmentDAO.hasBookedService(apptId, serviceId);
            if (!includedInBookedAppointment) {
                if (reorderReason.length() < 5) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                            "Chỉ định bổ sung cần có lý do lâm sàng (ít nhất 5 ký tự).");
                    return;
                }
                if (!"1".equals(request.getParameter("confirmAdditional"))) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                            "Cần xác nhận đã giải thích chi phí dịch vụ bổ sung.");
                    return;
                }
            }

            int recordId = record.getId();

            java.math.BigDecimal price = null;
            if (!includedInBookedAppointment) {
                ServiceItem service = serviceDAO.findServiceById(serviceId);
                if (service == null || service.getPrice() < 0) {
                    response.sendError(HttpServletResponse.SC_CONFLICT,
                            "Không đọc được giá dịch vụ hiện hành. Chỉ định chưa được tạo.");
                    return;
                }
                price = java.math.BigDecimal.valueOf(service.getPrice());
            }

            // 2 & 3. Tạo chỉ định siêu âm và hóa đơn POST_EXAM trong cùng 1 database Transaction
            int orderId = orderService.createUltrasoundRequestInTransaction(apptId, recordId, doctor.getId(), serviceId,
                    includedInBookedAppointment, price, reorderReason);

            if (orderId == UltrasoundOrderService.ACTIVE_ORDER_EXISTS) {
                ServiceItem existingService = serviceDAO.findServiceById(serviceId);
                String serviceName = existingService != null ? existingService.getServiceName() : "dịch vụ đã chọn";
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                        + "&reorderConflict=1&conflictServiceId=" + serviceId
                        + "&conflictServiceName=" + URLEncoder.encode(serviceName, StandardCharsets.UTF_8));
                return;
            }
            if (orderId <= 0) {
                throw new Exception("Không thể tạo yêu cầu siêu âm và hóa đơn.");
            }

            String billing = includedInBookedAppointment ? "covered" : "additional";

            // Send a patient-safe message only after the applicable billing path is known.
            try {
                com.clinic.utils.NotificationHelper.notifyPatientForUltrasound(
                        recordId, serviceId, "additional".equals(billing));
            } catch (Exception ex) {
                System.err.println("[DoctorUltrasoundRequestServlet] Gửi thông báo chỉ định siêu âm thất bại: " + ex.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                    + "&success=requested&billing=" + billing);

        } catch (Exception e) {
            System.err.println("[DoctorUltrasoundRequestServlet] requestId="
                    + request.getAttribute("requestId") + " error=" + e.getClass().getSimpleName());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể xử lý chỉ định siêu âm. Vui lòng dùng mã đối chiếu để liên hệ hỗ trợ.");
        }
    }
}
