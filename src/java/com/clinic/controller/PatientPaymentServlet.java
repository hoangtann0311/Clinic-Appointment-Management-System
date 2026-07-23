package com.clinic.controller;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.model.Appointment;
import com.clinic.model.Invoice;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

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

            String typeParam = request.getParameter("type");
            if (typeParam == null) {
                typeParam = request.getParameter("invoiceType");
            }
            String invoiceType = "PRE_EXAM";
            
            Invoice preCheck = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
            Invoice postCheck = invoiceDAO.getByAppointmentIdAndType(appointmentId, "POST_EXAM");
            Invoice rxCheck = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRESCRIPTION");
            
            if (typeParam != null) {
                invoiceType = ("POST_EXAM".equalsIgnoreCase(typeParam)) ? "POST_EXAM" : ("PRESCRIPTION".equalsIgnoreCase(typeParam) ? "PRESCRIPTION" : "PRE_EXAM");
            } else {
                if (preCheck != null && "Paid".equalsIgnoreCase(preCheck.getStatus()) 
                        && postCheck != null && !"Paid".equalsIgnoreCase(postCheck.getStatus())) {
                    invoiceType = "POST_EXAM";
                } else if (preCheck != null && "Paid".equalsIgnoreCase(preCheck.getStatus())
                        && postCheck != null && "Paid".equalsIgnoreCase(postCheck.getStatus())
                        && rxCheck != null && !"Paid".equalsIgnoreCase(rxCheck.getStatus())) {
                    invoiceType = "PRESCRIPTION";
                }
            }

            // Retrieve or create invoice
            Invoice invoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, invoiceType);
            if (invoice == null) {
                if ("PRE_EXAM".equals(invoiceType)) {
                    invoice = new Invoice();
                    invoice.setAppointmentId(appointmentId);
                    invoice.setTotalAmount(resolvePreExamAmount(appointmentId));
                    invoice.setStatus("Unpaid");
                    invoice.setInvoiceType("PRE_EXAM");
                    invoice.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                    
                    int invoiceId = invoiceDAO.insert(invoice);
                    if (invoiceId > 0) {
                        invoice = invoiceDAO.getById(invoiceId);
                    }
                } else if ("PRESCRIPTION".equals(invoiceType)) {
                    response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=ChuaCoDonThuoc");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=ChuaCoHoaDonSauKham");
                    return;
                }
            }

            // Load the other invoice for view references
            Invoice preInvoice = null;
            Invoice postInvoice = null;
            if ("PRE_EXAM".equals(invoiceType)) {
                preInvoice = invoice;
                postInvoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, "POST_EXAM");
            } else {
                preInvoice = invoiceDAO.getByAppointmentIdAndType(appointmentId, "PRE_EXAM");
                postInvoice = invoice;
            }

            // Load prescription items for PRESCRIPTION invoices
            List<PrescriptionItem> prescriptionItems = List.of();
            if ("PRESCRIPTION".equalsIgnoreCase(invoiceType)) {
                MedicalRecord record = new MedicalRecordDAO().getByAppointmentId(appointmentId);
                if (record != null && record.getId() > 0) {
                    Prescription prescription = new PrescriptionDAO().getByMedicalRecordId(record.getId());
                    if (prescription != null && prescription.getId() > 0) {
                        prescriptionItems = new PrescriptionDAO().getItemsByPrescriptionId(prescription.getId());
                    }
                }
            }

            // Thời điểm hết hạn giữ chỗ slot (để hiển thị đếm ngược 15 phút) — chỉ còn ý nghĩa
            // khi slot đang ở trạng thái HELD (chưa gửi thanh toán / chưa được staff duyệt).
            Long holdExpiresAtMillis = null;
            if (appt.getSlotId() != null) {
                Timestamp heldUntil = getSlotHeldUntil(appt.getSlotId());
                if (heldUntil != null) {
                    holdExpiresAtMillis = heldUntil.getTime();
                }
            }

            request.setAttribute("appointment", appt);
            request.setAttribute("invoice", invoice);
            request.setAttribute("preInvoice", preInvoice);
            request.setAttribute("postInvoice", postInvoice);
            request.setAttribute("invoiceType", invoiceType);
            request.setAttribute("success", request.getParameter("success"));
            request.setAttribute("error", request.getParameter("error"));
            request.setAttribute("prescriptionItems", prescriptionItems);
            request.setAttribute("holdExpiresAtMillis", holdExpiresAtMillis);

            request.getRequestDispatcher("/views/patient/payment.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã lịch hẹn không hợp lệ.");
        }
    }

    private Timestamp getSlotHeldUntil(int slotId) {
        String sql = "SELECT held_until FROM time_slots WHERE id = ? AND status = 'HELD'";
        try (Connection conn = com.clinic.config.DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, slotId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getTimestamp("held_until");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lịch hẹn cũ có thể chưa có hóa đơn PRE_EXAM. Tổng tiền gồm phí khám đã khóa
     * và đúng một dịch vụ chính của lịch hẹn.
     */
    private BigDecimal resolvePreExamAmount(int appointmentId) {
        String sql = "SELECT COALESCE(a.base_fee, CAST(250000 AS decimal(12,2))) "
                + "+ COALESCE(s.price, 0) AS total_amount "
                + "FROM appointments a "
                + "LEFT JOIN services s ON s.id = a.service_id "
                + "WHERE a.id = ?";
        try (Connection conn = com.clinic.config.DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getBigDecimal("total_amount") != null) {
                    return rs.getBigDecimal("total_amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.valueOf(250000);
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

            User user = (User) session.getAttribute("user");
            Appointment appointment = appointmentDAO.findAppointmentById(invoice.getAppointmentId());
            int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
            if (appointment == null || patientId <= 0 || appointment.getPatientId() != patientId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thanh toán hóa đơn này.");
                return;
            }

            if ("Paid".equalsIgnoreCase(invoice.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=HoaDonDaThanhToan");
                return;
            }
            if ("PendingConfirmation".equalsIgnoreCase(invoice.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                        + "&type=" + invoice.getInvoiceType() + "&error=HoaDonDangChoXacNhan");
                return;
            }
            if (!"Unpaid".equalsIgnoreCase(invoice.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                        + "&type=" + invoice.getInvoiceType() + "&error=TrangThaiHoaDonKhongHopLe");
                return;
            }
            if (!"BankTransfer".equalsIgnoreCase(paymentMethod) && !"Cash".equalsIgnoreCase(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                        + "&type=" + invoice.getInvoiceType() + "&error=PhuongThucThanhToanKhongHopLe");
                return;
            }

            // The patient selects a method only. Reception verifies the actual
            // payment and is the sole authority that records it as paid.
            boolean ok;
            try (Connection conn = com.clinic.config.DatabaseConfig.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    ok = invoiceDAO.submitPaymentDetails(conn, invoiceId, paymentMethod, "");
                    if (ok && "PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType())) {
                        ok = appointmentDAO.finalizeHoldOnPaymentSubmit(conn, invoice.getAppointmentId());
                    }
                    if (ok) conn.commit(); else conn.rollback();
                } catch (SQLException ex) {
                    conn.rollback();
                    throw ex;
                } finally {
                    conn.setAutoCommit(true);
                }
            }
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&success=ThanhToanChoXacNhan");
            } else {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=LoiCapNhatThanhToan");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LoiThanhToan");
        }
    }

}
