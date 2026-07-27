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
        try {
            User user = (User) session.getAttribute("user");

            int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
            String recordIdParam = request.getParameter("recordId");
            if (recordIdParam == null || recordIdParam.trim().isEmpty()) {
                recordIdParam = request.getParameter("id");
            }
            String apptIdParam = request.getParameter("apptId");

            if ((recordIdParam != null && !recordIdParam.trim().isEmpty()) || (apptIdParam != null && !apptIdParam.trim().isEmpty())) {
                // Chi tiết 1 hồ sơ / theo lịch hẹn
                if (patientId <= 0) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
                }

                MedicalRecord record = null;
                if (recordIdParam != null && !recordIdParam.trim().isEmpty()) {
                    int recordId = Integer.parseInt(recordIdParam.trim());
                    record = recordDAO.getById(recordId);
                } else if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    record = recordDAO.getByAppointmentId(apptId);
                }

                // 1. Không tồn tại hoặc KHÔNG thuộc quyền sở hữu của Patient hiện tại
                if (record == null) {
                    request.setAttribute("unreleasedNotice", "Bác sĩ chưa khởi tạo đơn thuốc hoặc hồ sơ bệnh án cho ca khám này.");
                    request.setAttribute("mode", "unreleased");
                    request.getRequestDispatcher("/views/patient/medical_record_detail.jsp").forward(request, response);
                    return;
                }

                if (record.getPatientId() != patientId) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem hồ sơ bệnh án này.");
                    return;
                }

                int recordId = record.getId();
                Prescription prescription = prescriptionDAO.getByMedicalRecordId(recordId);

                // Chỉ công bố chỉ định đã được bác sĩ lâm sàng xác nhận.
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
                    if (!"Confirmed".equalsIgnoreCase(order.getStatus()) && !"Completed".equalsIgnoreCase(order.getStatus())) continue;
                    com.clinic.model.UltrasoundReport report = reviewDAO.getCurrentReport(order.getOrderId());
                    if (report == null || (report.getSignedAt() == null && report.getDoctorConfirmedAt() == null)) continue;
                    usOrders.add(order);

                    List<com.clinic.model.UltrasoundImage> images = imgDAO.getByTestOrderId(order.getOrderId());
                    orderImages.put(order.getOrderId(), images);

                    com.clinic.model.UltrasoundAnnotation annotation = reviewDAO.getCurrentAnnotation(order.getOrderId());
                    String source = (annotation != null && annotation.getAnnotationSource() != null)
                            ? annotation.getAnnotationSource() : "AI";
                    if (annotation != null && "Approved".equalsIgnoreCase(annotation.getReviewStatus())) {
                        source = "AI";
                    }
                    orderAnnotationSources.put(order.getOrderId(), source);

                    com.clinic.model.AiAnalysisResult aiResult = aiDAO.getByTestOrderId(order.getOrderId());
                    if (aiResult != null && aiResult.getResultImage() != null) {
                        orderAiResultImages.put(order.getOrderId(), aiResult.getResultImage());
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
                // Danh sách tất cả hồ sơ bệnh án của bệnh nhân
                List<MedicalRecord> records = java.util.Collections.emptyList();
                if (patientId > 0) {
                    records = recordDAO.getByPatientId(patientId);
                }
                request.setAttribute("records", records);
                request.setAttribute("mode",    "list");
                request.getRequestDispatcher("/views/patient/medical_record_detail.jsp")
                       .forward(request, response);
            }
        } catch (Exception ex) {
            System.err.println("[PatientMedicalRecordServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/patient/medical_record_detail.jsp").forward(request, response);
        }
    }
}
