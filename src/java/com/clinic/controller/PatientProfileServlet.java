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
                    user.getId()
            );
        }

        request.setAttribute("patient", patient);
        request.setAttribute("user", user);
        request.setAttribute("saved", request.getParameter("saved"));
        // Hiển thị thông báo bắt buộc cập nhật nếu có
        Object profileRequired = session.getAttribute("profileRequired");
        if (profileRequired != null) {
            request.setAttribute("profileRequired", profileRequired);
            session.removeAttribute("profileRequired");
        }
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
        String address = request.getParameter("address");

        // ── Validate bắt buộc ──
        // ── Giữ lại dữ liệu vừa nhập khi validate lỗi ──
        request.setAttribute("formName", fullName);
        request.setAttribute("formPhone", phone);
        request.setAttribute("formDob", dobStr);
        request.setAttribute("formAddress", address);

        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập họ và tên.");
            renderProfileWithError(request, response, user);
            return;
        }
        if (fullName.trim().length() < 2) {
            request.setAttribute("error", "Họ và tên quá ngắn. Vui lòng nhập đầy đủ.");
            renderProfileWithError(request, response, user);
            return;
        }

        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập số điện thoại.");
            renderProfileWithError(request, response, user);
            return;
        }
        if (!phone.trim().matches("^0\\d{9,10}$")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ (phải bắt đầu bằng 0, 10-11 chữ số).");
            renderProfileWithError(request, response, user);
            return;
        }

        LocalDate dob = null;
        if (dobStr == null || dobStr.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập ngày sinh.");
            renderProfileWithError(request, response, user);
            return;
        }
        try {
            dob = LocalDate.parse(dobStr.trim());
        } catch (Exception e) {
            request.setAttribute("error", "Ngày sinh không hợp lệ.");
            renderProfileWithError(request, response, user);
            return;
        }
        if (dob.isAfter(LocalDate.now())) {
            request.setAttribute("error", "Ngày sinh không được ở tương lai.");
            renderProfileWithError(request, response, user);
            return;
        }
        int age = java.time.Period.between(dob, LocalDate.now()).getYears();
        if (age < 10) {
            request.setAttribute("error", "Bệnh nhân phải từ 10 tuổi trở lên.");
            renderProfileWithError(request, response, user);
            return;
        }
        if (age > 65) {
            request.setAttribute("error", "Tuổi vượt quá 65. Vui lòng liên hệ phòng khám để được tư vấn.");
            renderProfileWithError(request, response, user);
            return;
        }

        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ.");
            renderProfileWithError(request, response, user);
            return;
        }
        if (address.trim().length() < 10) {
            request.setAttribute("error", "Địa chỉ quá ngắn. Vui lòng nhập đầy đủ số nhà, đường, phường/xã, quận/huyện, tỉnh/thành.");
            renderProfileWithError(request, response, user);
            return;
        }

        // Update DB
        boolean ok = patientDAO.updatePatient(patientId, fullName.trim(), phone != null ? phone.trim() : "", dob,
                address != null ? address.trim() : "");
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
            session.setAttribute("successMessage", "Hồ sơ cá nhân đã được cập nhật thành công!");
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
            renderProfileWithError(request, response, user);
        }
    }

    /** Hiển thị lại form profile kèm lỗi, giữ nguyên dữ liệu vừa nhập */
    private void renderProfileWithError(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Lấy patient từ DB để hiển thị song song
        int patientId = patientDAO.getPatientIdByUserId(user.getId());
        if (patientId > 0) request.setAttribute("patient", patientDAO.findById(patientId));
        request.setAttribute("user", user);
        request.getRequestDispatcher("/views/patient/patient_profile.jsp").forward(request, response);
    }
}
