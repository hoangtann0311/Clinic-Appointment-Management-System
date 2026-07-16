package com.clinic.controller;

import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.ServiceDAO;
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

/**
 * Servlet xử lý yêu cầu tạo chỉ định siêu âm của Bác sĩ.
 */
@WebServlet("/doctor/ultrasound-request/create")
public class DoctorUltrasoundRequestServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

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

        if (apptIdStr == null || serviceIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số apptId hoặc serviceId.");
            return;
        }

        try {
            int apptId = Integer.parseInt(apptIdStr);
            int serviceId = Integer.parseInt(serviceIdStr);

            // 1. Kiểm tra / tạo hồ sơ bệnh án
            MedicalRecord record = medicalRecordDAO.getByAppointmentId(apptId);
            int recordId;
            if (record == null) {
                MedicalRecord draft = new MedicalRecord();
                draft.setAppointmentId(apptId);
                draft.setClinicalNotes("Bác sĩ chỉ định siêu âm.");
                draft.setFinalDiagnosis("Chờ kết quả siêu âm.");
                draft.setTreatmentPlan("Thực hiện siêu âm.");
                recordId = medicalRecordDAO.create(draft);
                if (recordId <= 0) {
                    throw new Exception("Không thể tự động tạo hồ sơ bệnh án.");
                }
            } else {
                recordId = record.getId();
            }

            // 2. Tạo chỉ định siêu âm trong test_orders
            int orderId = orderService.createUltrasoundRequest(recordId, user.getId(), serviceId);
            if (orderId <= 0) {
                throw new Exception("Không thể tạo yêu cầu siêu âm.");
            }

            // 3. Tự động cập nhật / tạo hóa đơn POST_EXAM cho dịch vụ chỉ định
            ServiceItem service = serviceDAO.findServiceById(serviceId);
            BigDecimal price = service != null ? BigDecimal.valueOf(service.getPrice()) : new BigDecimal("250000.00");

            // Kiểm tra nếu đã có POST_EXAM invoice chưa thanh toán → cộng dồn tiền
            Invoice existingPostInvoice = invoiceDAO.getByAppointmentIdAndType(apptId, "POST_EXAM");
            if (existingPostInvoice != null && !"Paid".equalsIgnoreCase(existingPostInvoice.getStatus())) {
                // Cộng dồn tiền dịch vụ mới vào hóa đơn cũ
                invoiceDAO.addAmountToInvoice(existingPostInvoice.getId(), price);
            } else {
                // Tạo hóa đơn POST_EXAM mới
                Invoice invoice = new Invoice();
                invoice.setAppointmentId(apptId);
                invoice.setTotalAmount(price);
                invoice.setStatus("Unpaid");
                invoice.setInvoiceType("POST_EXAM");
                invoice.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
                invoiceDAO.insert(invoice);
            }

            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?apptId=" + apptId + "&success=requested");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi xử lý chỉ định siêu âm: " + e.getMessage());
        }
    }
}
