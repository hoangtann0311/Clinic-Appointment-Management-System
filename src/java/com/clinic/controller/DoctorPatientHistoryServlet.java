package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.List;

/**
 * Xem lịch sử khám của một bệnh nhân cụ thể (theo góc nhìn bác sĩ).
 * (Đã chuyển hướng sang /doctor/medical-records?patientId=X)
 *
 * GET /doctor/patient-history?patientId=X → redirect /doctor/medical-records?patientId=X
 */
@WebServlet("/doctor/patient-history")
public class DoctorPatientHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String patientId = req.getParameter("patientId");
        if (patientId == null || patientId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records");
        } else {
            resp.sendRedirect(req.getContextPath() + "/doctor/medical-records?patientId=" + patientId.trim());
        }
    }
}
