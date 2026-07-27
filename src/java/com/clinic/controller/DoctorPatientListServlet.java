package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.DoctorDAO;
import com.clinic.model.User;
import com.clinic.utils.EncryptionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Danh sách bệnh nhân từng khám với bác sĩ này.
 * (Đã chuyển hướng sang /doctor/medical-records)
 *
 * GET /doctor/patients → redirect /doctor/medical-records
 */
@WebServlet("/doctor/patients")
public class DoctorPatientListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String query = req.getQueryString();
        String target = req.getContextPath() + "/doctor/medical-records";
        if (query != null && !query.isBlank()) {
            target += "?" + query;
        }
        resp.sendRedirect(target);
    }
}