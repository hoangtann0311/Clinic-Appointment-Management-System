package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.model.Medicine;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.PrescriptionItem;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Quản lý đơn thuốc cho bác sĩ.
 *
 * URL patterns:
 *   GET  /doctor/prescriptions?recordId=X   → form kê đơn / xem đơn thuốc đã có
 *   POST /doctor/prescriptions               → lưu đơn thuốc (tạo mới hoặc cập nhật)
 */
@WebServlet("/doctor/prescriptions")
public class PrescriptionServlet extends HttpServlet {

    private final PrescriptionDAO    prescriptionDAO = new PrescriptionDAO();
    private final MedicalRecordDAO   recordDAO       = new MedicalRecordDAO();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAuthenticatedDoctor(request, response);
        if (user == null) return;

        Integer doctorId = getDoctorIdByUserId(user.getId());
        if (doctorId == null) {
            sendError(request, response, "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        String recordIdParam = request.getParameter("recordId");
        if (recordIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
            return;
        }

        int recordId;
        try { recordId = Integer.parseInt(recordIdParam); }
        catch (NumberFormatException e) {
            sendError(request, response, "recordId không hợp lệ."); return;
        }

        // Bảo mật: hồ sơ phải thuộc bác sĩ này
        if (!recordDAO.recordBelongsToDoctor(recordId, doctorId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        MedicalRecord record = recordDAO.getById(recordId);
        if (record == null) {
            sendError(request, response, "Không tìm thấy hồ sơ bệnh án."); return;
        }

        Prescription prescription = prescriptionDAO.getByMedicalRecordId(recordId);

        List<Medicine> medicines = prescriptionDAO.getAllMedicines();

        request.setAttribute("record",       record);
        request.setAttribute("prescription", prescription);   // null = chưa có
        request.setAttribute("medicines",    medicines);
        request.setAttribute("doctorName",   user.getFullName());

        request.getRequestDispatcher("/views/doctors/prescription_form.jsp")
               .forward(request, response);
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAuthenticatedDoctor(request, response);
        if (user == null) return;

        Integer doctorId = getDoctorIdByUserId(user.getId());
        if (doctorId == null) {
            sendError(request, response, "Tài khoản chưa liên kết hồ sơ bác sĩ."); return;
        }

        String recordIdStr      = request.getParameter("recordId");
        String prescriptionIdStr = request.getParameter("prescriptionId"); // rỗng = tạo mới

        if (recordIdStr == null || recordIdStr.isBlank()) {
            sendError(request, response, "Thiếu recordId."); return;
        }
        int recordId = Integer.parseInt(recordIdStr);

        if (!recordDAO.recordBelongsToDoctor(recordId, doctorId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        // Thu thập danh sách thuốc từ form (mảng song song: medicineId[], quantity[], dosage[])
        String[] medicineIds = request.getParameterValues("medicineId[]");
        String[] quantities  = request.getParameterValues("quantity[]");
        String[] dosages     = request.getParameterValues("dosage[]");

        // ── Validate backend đơn thuốc ───────────────────────────────────────
        if (medicineIds == null || medicineIds.length == 0) {
            sendError(request, response, "Đơn thuốc phải có ít nhất một dòng thuốc."); return;
        }

        java.util.Set<String> seenMedicineIds = new java.util.HashSet<>();
        List<PrescriptionItem> items = new ArrayList<>();
        for (int i = 0; i < medicineIds.length; i++) {
            String midStr = medicineIds[i] == null ? "" : medicineIds[i].trim();
            if (midStr.isEmpty()) continue; // bỏ qua dòng chưa chọn thuốc

            // Validate medicineId là số nguyên dương
            int medicineId;
            try {
                medicineId = Integer.parseInt(midStr);
                if (medicineId <= 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                sendError(request, response, "ID thuốc không hợp lệ ở dòng " + (i + 1) + "."); return;
            }

            // Validate trùng lặp
            if (!seenMedicineIds.add(midStr)) {
                sendError(request, response, "Đơn thuốc có thuốc bị trùng lặp. Vui lòng kiểm tra lại."); return;
            }

            // Validate số lượng
            int quantity;
            try {
                quantity = Integer.parseInt(quantities[i].trim());
                if (quantity < 1 || quantity > 9999) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                sendError(request, response, "Số lượng không hợp lệ ở dòng " + (i + 1) + " (phải từ 1–9999)."); return;
            }

            String dosage = (dosages != null && i < dosages.length) ? dosages[i].trim() : "";
            if (dosage.length() > 500) {
                sendError(request, response, "Liều dùng quá dài ở dòng " + (i + 1) + " (tối đa 500 ký tự)."); return;
            }

            PrescriptionItem item = new PrescriptionItem();
            item.setMedicineId(medicineId);
            item.setQuantity(quantity);
            item.setDosage(dosage);
            items.add(item);
        }

        if (items.isEmpty()) {
            sendError(request, response, "Đơn thuốc phải có ít nhất một thuốc được chọn."); return;
        }

        // Validate các medicineId đều tồn tại và đang được phép kê (is_active = 1)
        java.util.Set<Integer> idsToCheck = new java.util.HashSet<>();
        for (PrescriptionItem item : items) idsToCheck.add(item.getMedicineId());
        if (!prescriptionDAO.allMedicineIdsValid(idsToCheck)) {
            sendError(request, response, "Một hoặc nhiều thuốc đã chọn không còn khả dụng. Vui lòng tải lại trang và chọn lại.");
            return;
        }

        boolean success;
        int finalPrescriptionId;

        if (prescriptionIdStr != null && !prescriptionIdStr.isBlank()) {
            // Cập nhật đơn thuốc đã có
            finalPrescriptionId = Integer.parseInt(prescriptionIdStr);
            if (!prescriptionDAO.prescriptionBelongsToDoctor(finalPrescriptionId, doctorId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }
            success = prescriptionDAO.replaceItems(finalPrescriptionId, items);
        } else {
            // Tạo mới đơn thuốc
            String code = "RX-" + LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
            finalPrescriptionId = prescriptionDAO.create(recordId, code);
            success = finalPrescriptionId > 0;
            if (success && !items.isEmpty()) {
                prescriptionDAO.replaceItems(finalPrescriptionId, items);
            }
        }

        if (success) {
            response.sendRedirect(request.getContextPath()
                + "/doctor/prescriptions?recordId=" + recordId + "&saved=1");
        } else {
            sendError(request, response, "Lưu đơn thuốc thất bại. Vui lòng thử lại.");
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private User getAuthenticatedDoctor(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private void sendError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws ServletException, IOException {
        req.setAttribute("errorMessage", msg);
        req.getRequestDispatcher("/views/doctors/prescription_form.jsp").forward(req, resp);
    }

    private Integer getDoctorIdByUserId(int userId) {
        String sql = "SELECT id FROM doctors WHERE user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}