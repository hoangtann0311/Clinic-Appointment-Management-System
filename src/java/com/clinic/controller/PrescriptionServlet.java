package com.clinic.controller;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.model.Doctor;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Compatibility route for old prescription links. Prescription editing now
 * lives only inside the medical-record transaction, preventing a second flow
 * from changing a finalized record or desynchronizing its invoice.
 */
@WebServlet("/doctor/prescriptions")
public class PrescriptionServlet extends HttpServlet {
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = request.getSession(false) == null
                ? null : (User) request.getSession(false).getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int recordId;
        try {
            recordId = Integer.parseInt(request.getParameter("recordId"));
            if (recordId <= 0) throw new NumberFormatException();
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "recordId không hợp lệ.");
            return;
        }
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null || !medicalRecordDAO.recordBelongsToDoctor(recordId, doctor.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        MedicalRecord record = medicalRecordDAO.getById(recordId);
        if (record == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        response.sendRedirect(request.getContextPath()
                + "/doctor/medical-records?apptId=" + record.getAppointmentId());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_CONFLICT,
                "Đơn thuốc chỉ được lưu cùng giao dịch hồ sơ bệnh án.");
    }
}
