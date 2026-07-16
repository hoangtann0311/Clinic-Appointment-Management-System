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

        if (recordIdParam != null) {
            // Chi tiết 1 hồ sơ
            if (patientId <= 0) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }
            int recordId;
            try { recordId = Integer.parseInt(recordIdParam); }
            catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST); return;
            }

            MedicalRecord record = recordDAO.getById(recordId);
            if (record == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND); return;
            }

            // Bảo mật: chỉ xem được hồ sơ của chính mình
            List<MedicalRecord> myRecords = recordDAO.getByPatientId(patientId);
            boolean mine = myRecords.stream().anyMatch(r -> r.getId() == recordId);
            if (!mine) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }

            Prescription prescription = prescriptionDAO.getByMedicalRecordId(recordId);

            // Fetch general lab test orders and results
            List<com.clinic.model.TestOrder> testOrders = new com.clinic.dao.TestOrderDAO().getByMedicalRecordId(recordId);

            // Retrieve ultrasound orders, images, and AI findings
            List<com.clinic.model.UltrasoundWaitingPatient> usOrders = new com.clinic.dao.UltrasoundOrderDAO().getByMedicalRecordId(recordId);
            java.util.Map<Integer, List<com.clinic.model.UltrasoundImage>> orderImages = new java.util.HashMap<>();
            java.util.Map<Integer, com.clinic.model.AiAnalysisResult> orderAiResults = new java.util.HashMap<>();
            
            com.clinic.dao.UltrasoundImageDAO imgDAO = new com.clinic.dao.UltrasoundImageDAO();
            com.clinic.dao.AiAnalysisResultDAO aiDAO = new com.clinic.dao.AiAnalysisResultDAO();
            
            for (com.clinic.model.UltrasoundWaitingPatient order : usOrders) {
                List<com.clinic.model.UltrasoundImage> images = imgDAO.getByTestOrderId(order.getOrderId());
                orderImages.put(order.getOrderId(), images);
                
                com.clinic.model.AiAnalysisResult aiRes = aiDAO.getByTestOrderId(order.getOrderId());
                if (aiRes != null) {
                    orderAiResults.put(order.getOrderId(), aiRes);
                }
            }

            request.setAttribute("record",       record);
            request.setAttribute("prescription", prescription);
            request.setAttribute("testOrders",   testOrders);
            request.setAttribute("usOrders", usOrders);
            request.setAttribute("orderImages", orderImages);
            request.setAttribute("orderAiResults", orderAiResults);
            request.setAttribute("mode",         "detail");
            request.getRequestDispatcher("/views/patient/medical_record_detail.jsp")
                   .forward(request, response);

        } else {
            // Danh sách tất cả hồ sơ
            List<MedicalRecord> records = java.util.Collections.emptyList();
            if (patientId > 0) {
                records = recordDAO.getByPatientId(patientId);
            }
            request.setAttribute("records", records);
            request.setAttribute("mode",    "list");
            request.getRequestDispatcher("/views/patient/medical_record_detail.jsp")
                   .forward(request, response);
        }
    }
}
