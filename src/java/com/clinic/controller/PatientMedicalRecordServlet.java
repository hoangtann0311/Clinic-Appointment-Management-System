package com.clinic.controller;

import com.clinic.dao.MedicalRecordDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.Prescription;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Cho phép bệnh nhân xem lịch sử hồ sơ bệnh án và đơn thuốc của bản thân.
 *
 * URL patterns:
 *   GET /patient/medical-records              → danh sách hồ sơ của bệnh nhân đang đăng nhập
 *   GET /patient/medical-records?recordId=X   → chi tiết 1 hồ sơ + đơn thuốc
 */
@WebServlet("/patient/medical-records")
public class PatientMedicalRecordServlet extends HttpServlet {

    private final MedicalRecordDAO recordDAO       = new MedicalRecordDAO();
    private final PrescriptionDAO  prescriptionDAO = new PrescriptionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
        String recordIdParam = request.getParameter("recordId");
        if (recordIdParam == null || recordIdParam.trim().isEmpty()) {
            recordIdParam = request.getParameter("id");
        }

        if (recordIdParam != null && !recordIdParam.trim().isEmpty()) {
            // Chi tiết 1 hồ sơ
            if (patientId <= 0) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }
            int recordId;
            try { recordId = Integer.parseInt(recordIdParam.trim()); }
            catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID hồ sơ không hợp lệ."); return;
            }

            MedicalRecord ownedRecord = recordDAO.getById(recordId);
            // 1. Không tồn tại hoặc KHÔNG thuộc quyền sở hữu của Patient hiện tại -> trả HTTP 404
            if (ownedRecord == null || ownedRecord.getPatientId() != patientId) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bệnh án.");
                return;
            }

            // 2. Chỉ công bố khi cả hồ sơ đã final và ca khám đã hoàn tất.
            MedicalRecord record = recordDAO.getByIdAndPatientId(recordId, patientId);
            if (record == null) {
                request.setAttribute("unreleasedNotice", "Hồ sơ bệnh án này đang trong quá trình xử lý và chưa được bác sĩ công bố.");
                request.setAttribute("mode", "unreleased");
                request.getRequestDispatcher("/views/patient/medical_record_detail.jsp").forward(request, response);
                return;
            }

            Prescription prescription = prescriptionDAO.getByMedicalRecordId(recordId);

            // Chỉ công bố chỉ định đã được bác sĩ lâm sàng xác nhận.
            // Kèm theo annotation source (AI / Sonographer) để JSP hiển thị
            // đúng loại ảnh: AI nếu được chấp nhận, hoặc ảnh gốc nếu từ chối/sửa.
            List<com.clinic.model.UltrasoundWaitingPatient> allUsOrders = new com.clinic.dao.UltrasoundOrderDAO().getByMedicalRecordId(recordId);
            List<com.clinic.model.UltrasoundWaitingPatient> usOrders = new java.util.ArrayList<>();
            java.util.Map<Integer, List<com.clinic.model.UltrasoundImage>> orderImages = new java.util.HashMap<>();
            java.util.Map<Integer, com.clinic.model.UltrasoundReport> orderReports = new java.util.HashMap<>();
            java.util.Map<Integer, String> orderAnnotationSources = new java.util.HashMap<>();
            java.util.Map<Integer, String> orderAiResultImages = new java.util.HashMap<>();
            com.clinic.dao.UltrasoundImageDAO imgDAO = new com.clinic.dao.UltrasoundImageDAO();
            com.clinic.dao.UltrasoundReviewDAO reviewDAO = new com.clinic.dao.UltrasoundReviewDAO();
            com.clinic.dao.AiAnalysisResultDAO aiDAO = new com.clinic.dao.AiAnalysisResultDAO();

            for (com.clinic.model.UltrasoundWaitingPatient order : allUsOrders) {
                if (!"Confirmed".equalsIgnoreCase(order.getStatus())) continue;
                com.clinic.model.UltrasoundReport report = reviewDAO.getCurrentReport(order.getOrderId());
                if (report == null || report.getDoctorConfirmedAt() == null) continue;
                usOrders.add(order);

                // Ảnh gốc
                List<com.clinic.model.UltrasoundImage> images = imgDAO.getByTestOrderId(order.getOrderId());
                orderImages.put(order.getOrderId(), images);

                // Annotation hiện tại → xác định nguồn (AI / Sonographer)
                com.clinic.model.UltrasoundAnnotation annotation = reviewDAO.getCurrentAnnotation(order.getOrderId());
                String source = (annotation != null && annotation.getAnnotationSource() != null)
                        ? annotation.getAnnotationSource() : "None";
                orderAnnotationSources.put(order.getOrderId(), source);

                // Ảnh có đánh dấu chẩn đoán:
                // - AI accepted → dùng ảnh result_image từ AI (có bounding box overlay)
                // - Sonographer corrected/rejected → annotation là polygon, KHÔNG có ảnh riêng.
                //   Hiển thị ảnh gốc + ghi chú "Bác sĩ siêu âm đánh dấu thủ công".
                if ("AI".equalsIgnoreCase(source)) {
                    com.clinic.model.AiAnalysisResult aiResult = aiDAO.getByTestOrderId(order.getOrderId());
                    if (aiResult != null && aiResult.getResultImage() != null) {
                        orderAiResultImages.put(order.getOrderId(), aiResult.getResultImage());
                    }
                }

                orderReports.put(order.getOrderId(), report);
            }

            request.setAttribute("record",       record);
            request.setAttribute("prescription", prescription);
            request.setAttribute("usOrders", usOrders);
            request.setAttribute("orderImages", orderImages);
            request.setAttribute("orderReports", orderReports);
            request.setAttribute("orderAnnotationSources", orderAnnotationSources);
            request.setAttribute("orderAiResultImages", orderAiResultImages);
            request.setAttribute("mode",         "detail");
            request.getRequestDispatcher("/views/patient/medical_record_detail.jsp")
                   .forward(request, response);

        } else {
            // Danh sách tất cả hồ sơ
            List<MedicalRecord> records = java.util.Collections.emptyList();
            if (patientId > 0) {
                records = recordDAO.getReleasedByPatientId(patientId);
            }
            request.setAttribute("records", records);
            request.setAttribute("mode",    "list");
            request.getRequestDispatcher("/views/patient/medical_record_detail.jsp")
                   .forward(request, response);
        }
    }
}
