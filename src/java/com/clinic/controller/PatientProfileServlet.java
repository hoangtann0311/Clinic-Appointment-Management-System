package com.clinic.controller;

import com.clinic.dao.UserDAO;
import com.clinic.dao.PatientDAO;
import com.clinic.model.Patient;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/patient/profile")
public class PatientProfileServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int patientId = patientDAO.getPatientIdByUserId(user.getId());
        Patient patient = null;

        if (patientId > 0) {
            patient = patientDAO.findById(patientId);
        } else {
            // Automatically initialize a patient record if missing
            patient = patientDAO.createPatientWithUserId(
                    user.getFullName(),
                    user.getPhone(),
                    null,
                    "zalo_" + user.getPhone(),
                    user.getId()
            );
        }

        request.setAttribute("patient", patient);
        request.setAttribute("user", user);
        request.setAttribute("saved", request.getParameter("saved"));
        request.getRequestDispatcher("/views/patient/patient_profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int patientId = patientDAO.getPatientIdByUserId(user.getId());
        
        if (patientId <= 0) {
            response.sendRedirect(request.getContextPath() + "/patient/profile?error=1");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dateOfBirth");
        String zaloUserId = request.getParameter("zaloUserId");

        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ và tên không được để trống.");
            doGet(request, response);
            return;
        }

        LocalDate dob = null;
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr.trim());
                if (dob.isAfter(LocalDate.now())) {
                    request.setAttribute("error", "Ngày sinh không được ở tương lai.");
                    doGet(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("error", "Ngày sinh không hợp lệ.");
                doGet(request, response);
                return;
            }
        }

        // Update DB
        boolean ok = patientDAO.updatePatient(patientId, fullName.trim(), phone != null ? phone.trim() : "", dob, zaloUserId != null ? zaloUserId.trim() : "");
        if (ok) {
            // Sync with users table
            user.setFullName(fullName.trim());
            user.setPhone(phone != null ? phone.trim() : "");
            userDAO.update(user);
            
            // Log action
            new com.clinic.dao.AuditLogDAO().logAction(
                    "Cập nhật thông tin cá nhân của Bệnh nhân",
                    "Patient",
                    "patients",
                    user.getFullName(),
                    fullName.trim()
            );

            session.setAttribute("user", user);
            response.sendRedirect(request.getContextPath() + "/patient/profile?saved=1");
        } else {
            request.setAttribute("error", "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
            doGet(request, response);
        }
    }
}
