package com.clinic.controller;

import com.clinic.config.AppConfig;
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
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.Normalizer;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

@WebServlet("/patient/payment")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
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
            java.math.BigDecimal previousPrescriptionTotal = null;
            if ("PRESCRIPTION".equalsIgnoreCase(invoiceType)) {
                MedicalRecord record = new MedicalRecordDAO().getByAppointmentId(appointmentId);
                if (record != null && record.getId() > 0) {
                    Prescription prescription = new PrescriptionDAO().getByMedicalRecordId(record.getId());
                    if (prescription != null && prescription.getId() > 0) {
                        prescriptionItems = new PrescriptionDAO().getItemsByPrescriptionId(prescription.getId());
                    }
                }

                java.math.BigDecimal currentTotal = invoice.getTotalAmount() != null ? invoice.getTotalAmount() : java.math.BigDecimal.ZERO;
                java.util.List<com.clinic.model.Invoice> allRx = new com.clinic.dao.InvoiceDAO().getByAppointmentId(appointmentId);
                for (com.clinic.model.Invoice inv : allRx) {
                    if ("PRESCRIPTION".equalsIgnoreCase(inv.getInvoiceType()) && "Paid".equalsIgnoreCase(inv.getStatus())) {
                        previousPrescriptionTotal = inv.getTotalAmount();
                        break;
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

            // Nội dung chuyển khoản = SĐT bệnh nhân + tên dịch vụ (không dấu, không khoảng trắng thừa)
            // để nhân viên đối chiếu minh chứng dễ dàng, thay vì mã cố định không có ý nghĩa.
            String patientPhone = appt.getPatient() != null ? appt.getPatient().getPhone() : null;
            String svcName = appt.getService() != null ? appt.getService().getServiceName() : "KHAM";
            String transferContent = buildTransferContent(patientPhone, svcName, appointmentId);
            String transferContentEncoded = java.net.URLEncoder.encode(transferContent, "UTF-8");

            request.setAttribute("appointment", appt);
            request.setAttribute("invoice", invoice);
            request.setAttribute("preInvoice", preInvoice);
            request.setAttribute("postInvoice", postInvoice);
            request.setAttribute("invoiceType", invoiceType);
            request.setAttribute("success", request.getParameter("success"));
            request.setAttribute("error", request.getParameter("error"));
            request.setAttribute("prescriptionItems", prescriptionItems);
            request.setAttribute("previousPrescriptionTotal", previousPrescriptionTotal);
            request.setAttribute("holdExpiresAtMillis", holdExpiresAtMillis);
            request.setAttribute("transferContent", transferContent);
            request.setAttribute("transferContentEncoded", transferContentEncoded);

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
     * Legacy appointments may not yet have a PRE_EXAM invoice. Preserve the locked
     * doctor fee and every selected add-on service when creating that fallback invoice.
     */
    private BigDecimal resolvePreExamAmount(int appointmentId) {
        String sql = "SELECT COALESCE(a.base_fee, s.price, CAST(250000 AS decimal(12,2))) "
                + "+ COALESCE(SUM(aps.price), 0) AS total_amount "
                + "FROM appointments a "
                + "LEFT JOIN services s ON s.id = a.service_id "
                + "LEFT JOIN appointment_services aps ON aps.appointment_id = a.id "
                + "WHERE a.id = ? "
                + "GROUP BY a.base_fee, s.price";
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

    /** SĐT + tên dịch vụ, bỏ dấu tiếng Việt, chỉ giữ chữ/số/khoảng trắng — dùng cho nội dung CK và QR. */
    private String buildTransferContent(String phone, String serviceName, int appointmentId) {
        String phonePart = (phone == null || phone.trim().isEmpty()) ? ("LH" + appointmentId) : phone.trim();
        String namePart = removeDiacritics(serviceName == null ? "KHAM" : serviceName).toUpperCase();
        String content = (phonePart + " " + namePart).trim();
        return content.length() > 60 ? content.substring(0, 60) : content;
    }

    private String removeDiacritics(String input) {
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        String noAccents = Pattern.compile("\\p{InCombiningDiacriticalMarks}+").matcher(normalized).replaceAll("");
        noAccents = noAccents.replace('Đ', 'D').replace('đ', 'd');
        return noAccents.replaceAll("[^a-zA-Z0-9\\s]", "").trim();
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
        String transactionCode = request.getParameter("transactionCode"); // vẫn cho phép, nhưng không bắt buộc nữa

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
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not own this invoice.");
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
            if ("DeclinedPurchase".equalsIgnoreCase(invoice.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                        + "&type=" + invoice.getInvoiceType() + "&error=HoaDonDaTuChoiMua");
                return;
            }
            if ("Rejected".equalsIgnoreCase(invoice.getStatus()) && "PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType())) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=ThanhToanTruocKhamDaBiTuChoi");
                return;
            }
            if (!"BankTransfer".equalsIgnoreCase(paymentMethod) && !"Cash".equalsIgnoreCase(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                        + "&type=" + invoice.getInvoiceType() + "&error=PhuongThucThanhToanKhongHopLe");
                return;
            }

            String status = "PendingConfirmation";
            String proofImagePath = null;

            if ("BankTransfer".equalsIgnoreCase(paymentMethod)) {
                transactionCode = transactionCode == null ? "" : transactionCode.trim();
                if (transactionCode.length() < 4 || transactionCode.length() > 100) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId()
                            + "&type=" + invoice.getInvoiceType() + "&error="
                            + java.net.URLEncoder.encode("Vui lòng nhập mã tham chiếu hoặc nội dung chuyển khoản từ 4 đến 100 ký tự.", "UTF-8"));
                    return;
                }
                Part filePart = request.getPart("proofImage");
                if (filePart == null || filePart.getSize() <= 0) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=" + java.net.URLEncoder.encode("Vui lòng tải lên ảnh chụp màn hình chuyển khoản.", "UTF-8"));
                    return;
                }

                String contentType = filePart.getContentType();
                if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/jpg"))) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=" + java.net.URLEncoder.encode("Chỉ hỗ trợ ảnh định dạng JPEG, JPG hoặc PNG.", "UTF-8"));
                    return;
                }
                if (filePart.getSize() > AppConfig.getMaxFileSize()) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=" + java.net.URLEncoder.encode("Kích thước ảnh không được vượt quá 10MB.", "UTF-8"));
                    return;
                }

                proofImagePath = saveProofImage(filePart);
                if (proofImagePath == null) {
                    response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=" + java.net.URLEncoder.encode("Lỗi khi lưu ảnh, vui lòng thử lại.", "UTF-8"));
                    return;
                }
            } else if ("Cash".equalsIgnoreCase(paymentMethod)) {
                transactionCode = "";
            }

            boolean ok = invoiceDAO.submitPaymentDetailsWithProof(invoiceId, paymentMethod, transactionCode, proofImagePath, status);
            if (ok) {
                // Bệnh nhân đã gửi thanh toán trong thời hạn giữ chỗ 15 phút → chốt slot BOOKED hẳn,
                // không để background job nhả nhầm slot trong lúc chờ Staff duyệt.
                if ("PRE_EXAM".equalsIgnoreCase(invoice.getInvoiceType())) {
                    appointmentDAO.finalizeHoldOnPaymentSubmit(invoice.getAppointmentId());
                }
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&success=ThanhToanChoXacNhan");
            } else {
                response.sendRedirect(request.getContextPath() + "/patient/payment?appointmentId=" + invoice.getAppointmentId() + "&type=" + invoice.getInvoiceType() + "&error=LoiCapNhatThanhToan");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LoiThanhToan");
        }
    }

    /** Lưu ảnh minh chứng chuyển khoản vào thư mục uploads/payment_proofs riêng (tách khỏi ultrasound). */
    private String saveProofImage(Part filePart) {
        try {
            String relativeUploadDir = "uploads/payment_proofs";
            String realPath = getServletContext().getRealPath("");
            String uploadPath = realPath + File.separator + relativeUploadDir;

            File uploadDirFile = new File(uploadPath);
            if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

            String originalFileName = getFileName(filePart);
            String extension = ".jpg";
            if (originalFileName != null && originalFileName.contains(".")) {
                extension = originalFileName.substring(originalFileName.lastIndexOf("."));
            }
            String storedFileName = UUID.randomUUID().toString() + extension;
            String filePath = uploadPath + File.separator + storedFileName;
            filePart.write(filePath);

            // Mirror sang thư mục nguồn web/ để không bị mất ảnh khi "ant clean" xoá build/
            // (build/web bị xoá và tạo lại từ web/ mỗi lần rebuild — xem log build của dự án).
            String sourceUploadPath = null;
            if (realPath != null) {
                if (realPath.contains("build" + File.separator + "web")) {
                    sourceUploadPath = realPath.replace("build" + File.separator + "web", "web") + File.separator + relativeUploadDir;
                } else if (realPath.contains("build\\web")) {
                    sourceUploadPath = realPath.replace("build\\web", "web") + File.separator + relativeUploadDir;
                } else if (realPath.contains("build/web")) {
                    sourceUploadPath = realPath.replace("build/web", "web") + File.separator + relativeUploadDir;
                }
            }
            if (sourceUploadPath != null) {
                try {
                    File sourceDir = new File(sourceUploadPath);
                    if (!sourceDir.exists()) sourceDir.mkdirs();
                    java.nio.file.Files.copy(
                        java.nio.file.Paths.get(filePath),
                        java.nio.file.Paths.get(sourceUploadPath + File.separator + storedFileName),
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception mirrorEx) {
                    System.err.println("[PatientPaymentServlet] Không mirror được ảnh sang web/ nguồn: " + mirrorEx.getMessage());
                }
            }

            // Đường dẫn có dấu "/" đầu — JSP dùng ${pageContext.request.contextPath}${invoice.proofImagePath}
            return "/" + relativeUploadDir + "/" + storedFileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}
