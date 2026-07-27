package com.clinic.controller;

import com.clinic.dao.UserProfileDAO;
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
    /**
     * DAO hẹp: câu UPDATE chỉ có full_name và phone.
     * Trước đây chỗ này dùng UserDAO.update(), mà câu lệnh của nó có cả
     * role_id và status — tuy giá trị lấy từ session nên chưa khai thác được,
     * nhưng để cột vai trò xuất hiện trong câu UPDATE của trang hồ sơ là rủi ro
     * leo thang quyền không cần thiết. Năm trang hồ sơ còn lại đều đã tránh.
     */
    private final UserProfileDAO userProfileDAO = new UserProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        try {
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
        } catch (Exception e) {
            System.err.println("[PatientProfileServlet] doGet ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải hồ sơ. Vui lòng thử lại sau.");
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
        String cccd = request.getParameter("cccd");

        // ── Validate bắt buộc ──
        // ── Giữ lại dữ liệu vừa nhập khi validate lỗi ──
        request.setAttribute("formName", fullName);
        request.setAttribute("formPhone", phone);
        request.setAttribute("formDob", dobStr);
        request.setAttribute("formAddress", address);
        request.setAttribute("formCccd", cccd);

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

        if (cccd == null || cccd.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập số CCCD/CMND.");
            renderProfileWithError(request, response, user);
            return;
        }
        String cccdClean = cccd.trim().replaceAll("[^0-9]", "");
        if (cccdClean.length() != 9 && cccdClean.length() != 12) {
            request.setAttribute("error", "Số CCCD/CMND không hợp lệ (phải có 9 hoặc 12 chữ số).");
            renderProfileWithError(request, response, user);
            return;
        }

        // Update DB
        boolean ok = patientDAO.updatePatient(patientId, fullName.trim(), phone != null ? phone.trim() : "", dob,
                address != null ? address.trim() : "", cccdClean);
        if (ok) {
            // Sync with users table — chỉ full_name và phone.
            user.setFullName(fullName.trim());
            user.setPhone(phone != null ? phone.trim() : "");
            userProfileDAO.updateBasicInfo(user.getId(), user.getFullName(), user.getPhone());
            
            // Log action
            new com.clinic.dao.AuditLogDAO().logAction(
                    "Cập nhật thông tin cá nhân của Bệnh nhân",
                    "Patient",
                    "patients",
                    user.getFullName(),
                    fullName.trim()
            );

            session.setAttribute("user", user);
            // Quay lại chính trang hồ sơ và báo tại chỗ, đồng nhất với 5 vai trò kia.
            // Tham số saved=1 khớp khối <c:if test="${not empty saved}"> sẵn có trong
            // patient_profile.jsp, và doGet đã nạp sẵn tham số này vào request.
            response.sendRedirect(request.getContextPath() + "/patient/profile?saved=1");
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
