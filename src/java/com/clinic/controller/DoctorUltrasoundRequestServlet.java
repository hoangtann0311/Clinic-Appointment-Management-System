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
@WebServlet({"/doctor/ultrasound-request", "/doctor/ultrasound-request/create"})
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

        // ── Action: Huỷ chỉ định siêu âm ──
        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            handleCancel(request, response, user);
            return;
        }

        String apptIdStr = request.getParameter("apptId");
        String serviceIdStr = request.getParameter("serviceId");
        String forceStr = request.getParameter("force");
        boolean force = "1".equals(forceStr) || "true".equalsIgnoreCase(forceStr);
        String reorderReason = request.getParameter("reorderReason");
        if (reorderReason == null || reorderReason.isBlank()) {
            reorderReason = request.getParameter("additionalReason");
        }
        reorderReason = reorderReason == null ? "" : reorderReason.trim();

        // Parse apptId/force sớm để dùng cho redirect khi có lỗi validation
        int apptId = 0;
        if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
            try { apptId = Integer.parseInt(apptIdStr.trim()); } catch (NumberFormatException ignored) {}
        }
        String redirectBase = request.getContextPath() + "/doctor/medical-records?apptId=" + apptId;

        if (apptIdStr == null || apptIdStr.trim().isEmpty()
                || serviceIdStr == null || serviceIdStr.trim().isEmpty()) {
            response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Thiếu tham số apptId hoặc serviceId.", StandardCharsets.UTF_8));
            return;
        }

        if (apptId <= 0) {
            response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("apptId không hợp lệ.", StandardCharsets.UTF_8));
            return;
        }

        if (force && reorderReason.isEmpty()) {
            response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Vui lòng nhập lý do chỉ định lại siêu âm.", StandardCharsets.UTF_8));
            return;
        }
        if (reorderReason.length() > 500) {
            response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Lý do chỉ định không được vượt quá 500 ký tự.", StandardCharsets.UTF_8));
            return;
        }

        try {
            int serviceId = Integer.parseInt(serviceIdStr.trim());
            if (serviceId <= 0) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("serviceId không hợp lệ.", StandardCharsets.UTF_8));
                return;
            }

            if (!serviceDAO.isActiveUltrasoundService(serviceId)) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Chỉ có thể chỉ định một dịch vụ siêu âm đang hoạt động.", StandardCharsets.UTF_8));
                return;
            }

            // test_orders.doctor_id references the doctors profile ID, not users.id.
            Doctor doctor = doctorDAO.findByUserId(user.getId());
            if (doctor == null || doctor.getId() <= 0) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Tài khoản bác sĩ chưa được liên kết với hồ sơ bác sĩ.", StandardCharsets.UTF_8));
                return;
            }

            if (!medicalRecordDAO.appointmentBelongsToDoctor(apptId, doctor.getId())) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Bạn không có quyền chỉ định siêu âm cho ca khám này.", StandardCharsets.UTF_8));
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
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Chỉ được chỉ định siêu âm khi ca khám đang ở trạng thái Đang khám.", StandardCharsets.UTF_8));
                return;
            }
            if (reorderReason.length() < 5) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Chỉ định siêu âm cần có lý do lâm sàng (ít nhất 5 ký tự).", StandardCharsets.UTF_8));
                return;
            }

            int recordId = record.getId();

            ServiceItem service = serviceDAO.findServiceById(serviceId);
            if (service == null || service.getPrice() < 0) {
                response.sendRedirect(redirectBase + "&error=" + URLEncoder.encode("Không đọc được giá dịch vụ hiện hành. Chỉ định chưa được tạo.", StandardCharsets.UTF_8));
                return;
            }
            java.math.BigDecimal price = java.math.BigDecimal.valueOf(service.getPrice());

            // Tạo chỉ định siêu âm và hóa đơn POST_EXAM trong cùng 1 database Transaction
            int orderId = orderService.createUltrasoundRequestInTransaction(apptId, recordId, doctor.getId(), serviceId,
                    false, price, reorderReason, force);

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

            // Gửi thông báo cho bệnh nhân
            try {
                com.clinic.utils.NotificationHelper.notifyPatientForUltrasound(recordId, serviceId, true);
            } catch (Exception ex) {
                System.err.println("[DoctorUltrasoundRequestServlet] Gửi thông báo chỉ định siêu âm thất bại: " + ex.getMessage());
            }

            // Audit log
            com.clinic.utils.AuditUtil.log(user.getId(),
                    "Tạo chỉ định siêu âm #" + orderId + " cho lịch hẹn #" + apptId
                    + " — Dịch vụ #" + serviceId + " — Lý do: " + reorderReason,
                    "test_orders", "", "Pending", request.getRemoteAddr());

            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                    + "&success=requested");

        } catch (Exception e) {
            System.err.println("[DoctorUltrasoundRequestServlet] error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            int fallbackApptId = 0;
            try { fallbackApptId = Integer.parseInt(request.getParameter("apptId")); } catch (NumberFormatException ignored) {}
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?apptId=" + fallbackApptId
                    + "&error=" + URLEncoder.encode("Không thể xử lý chỉ định siêu âm. Vui lòng thử lại.", StandardCharsets.UTF_8));
        }
    }

    /** P7: Huỷ chỉ định siêu âm khi POST_EXAM chưa thanh toán */
    private void handleCancel(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String orderIdStr = req.getParameter("orderId");
        String apptIdStr = req.getParameter("apptId");
        String reason = req.getParameter("reason");
        try {
            int orderId = Integer.parseInt(orderIdStr);
            int apptId = Integer.parseInt(apptIdStr);
            if (reason == null || reason.trim().length() < 10 || reason.trim().length() > 500) {
                resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                        + "&error=" + URLEncoder.encode("Lý do huỷ phải từ 10 đến 500 ký tự.", StandardCharsets.UTF_8));
                return;
            }
            Doctor doctor = doctorDAO.findByUserId(user.getId());
            if (doctor == null || !medicalRecordDAO.appointmentBelongsToDoctor(apptId, doctor.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền.");
                return;
            }
            if (!appointmentDAO.isConsultationInProgress(apptId, doctor.getId())) {
                resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                        + "&error=" + URLEncoder.encode("Chỉ được huỷ chỉ định khi ca khám đang ở trạng thái Đang khám.", StandardCharsets.UTF_8));
                return;
            }

            // Kiểm tra hoá đơn POST_EXAM chưa thanh toán
            com.clinic.model.Invoice inv = invoiceDAO.getByAppointmentIdAndType(apptId, "POST_EXAM");
            if (inv != null && "Paid".equalsIgnoreCase(inv.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                        + "&error=" + URLEncoder.encode("Bệnh nhân đã thanh toán dịch vụ siêu âm. Không thể huỷ chỉ định — liên hệ Lễ tân để xử lý hoàn tiền.", StandardCharsets.UTF_8));
                return;
            }

            // Transaction: huỷ order + huỷ hoá đơn chưa thanh toán
            try (java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    com.clinic.dao.UltrasoundOrderDAO orderDAO = new com.clinic.dao.UltrasoundOrderDAO();
                    orderDAO.cancelOrder(conn, orderId);

                    if (inv != null && !"Paid".equalsIgnoreCase(inv.getStatus())) {
                        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                                "UPDATE invoices SET status = 'Cancelled' WHERE id = ? AND status = 'Unpaid'")) {
                            ps.setInt(1, inv.getId());
                            ps.executeUpdate();
                        }
                    }
                    conn.commit();
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            }

            // Audit log
            com.clinic.utils.AuditUtil.log(user.getId(),
                    "Huỷ chỉ định siêu âm #" + orderId + " cho lịch hẹn #" + apptId + " — Lý do: " + reason.trim(),
                    "test_orders", "", "Cancelled", req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId=" + apptId
                    + "&success=cancelled");
        } catch (Exception e) {
            System.err.println("[DoctorUltrasoundRequestServlet] cancel error: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?apptId="
                    + (apptIdStr != null ? apptIdStr : "0")
                    + "&error=" + URLEncoder.encode("Không thể huỷ chỉ định. Vui lòng thử lại.", StandardCharsets.UTF_8));
        }
    }
}
