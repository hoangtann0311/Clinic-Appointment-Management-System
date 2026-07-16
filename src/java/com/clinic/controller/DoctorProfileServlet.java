package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.dao.DoctorDAO;
import com.clinic.model.Doctor;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * Bác sĩ xem và cập nhật hồ sơ cá nhân — bao gồm upload ảnh đại diện từ máy.
 *
 * GET  /doctor/profile  → hiện form hồ sơ
 * POST /doctor/profile  → lưu thay đổi (multipart/form-data, hỗ trợ field "avatarFile")
 */
@WebServlet("/doctor/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 5,       // 5MB — khớp AppConfig.getMaxAvatarFileSize()
    maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class DoctorProfileServlet extends HttpServlet {

    private static final java.util.Set<String> ALLOWED_CONTENT_TYPES =
            java.util.Set.of("image/jpeg", "image/jpg", "image/png", "image/webp");

    private final DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Tài khoản chưa liên kết hồ sơ bác sĩ.");
            return;
        }

        req.setAttribute("doctor",     doctor);
        req.setAttribute("doctorName", user.getFullName());
        req.setAttribute("saved",      req.getParameter("saved"));
        req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        // ── Đọc và validate ─────────────────────────────────────────────────
        String fullName    = trim(req.getParameter("fullName"));
        String specialization = trim(req.getParameter("specialization"));
        String phoneNumber = trim(req.getParameter("phoneNumber"));
        String degree      = trim(req.getParameter("degree"));
        String expStr      = trim(req.getParameter("experienceYears"));
        String bio         = trim(req.getParameter("bio"));

        if (fullName == null || fullName.isEmpty()) {
            showError(req, resp, doctor, "Họ tên không được để trống.");
            return;
        }
        if (phoneNumber != null && !phoneNumber.isEmpty()
                && !phoneNumber.matches("^[0-9+\\-\\s]{7,15}$")) {
            showError(req, resp, doctor, "Số điện thoại không hợp lệ.");
            return;
        }

        int experienceYears = 0;
        try {
            if (expStr != null && !expStr.isEmpty()) {
                experienceYears = Integer.parseInt(expStr);
                if (experienceYears < 0 || experienceYears > 60) {
                    showError(req, resp, doctor, "Số năm kinh nghiệm không hợp lệ (0–60).");
                    return;
                }
            }
        } catch (NumberFormatException e) {
            experienceYears = 0;
        }

        // ── Xử lý ảnh đại diện tải lên từ máy (nếu có) ────────────────────────
        String avatarUrl = doctor.getAvatarUrl(); // mặc định giữ nguyên ảnh cũ
        Part avatarPart = req.getPart("avatarFile");
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String originalFileName = getFileName(avatarPart);
            String contentType = avatarPart.getContentType();

            if (originalFileName == null || originalFileName.isEmpty()) {
                showError(req, resp, doctor, "File ảnh không hợp lệ.");
                return;
            }
            if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
                showError(req, resp, doctor, "Chỉ hỗ trợ ảnh định dạng JPG, PNG hoặc WEBP.");
                return;
            }
            if (avatarPart.getSize() > AppConfig.getMaxAvatarFileSize()) {
                showError(req, resp, doctor, "Kích thước ảnh không được vượt quá 5MB.");
                return;
            }

            String relativeUploadDir = AppConfig.getAvatarUploadDirectory();
            String uploadPath = getServletContext().getRealPath("") + File.separator + relativeUploadDir;
            File uploadDirFile = new File(uploadPath);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }

            String extension = originalFileName.contains(".")
                    ? originalFileName.substring(originalFileName.lastIndexOf("."))
                    : "";
            String storedFileName = "doctor-" + doctor.getId() + "-" + UUID.randomUUID() + extension;
            String filePath = uploadPath + File.separator + storedFileName;

            avatarPart.write(filePath);

            avatarUrl = req.getContextPath() + "/" + relativeUploadDir + "/" + storedFileName;
        }

        // ── Lưu ─────────────────────────────────────────────────────────────
        doctor.setFullName(fullName);
        doctor.setSpecialization(specialization);
        doctor.setPhoneNumber(phoneNumber);
        doctor.setDegree(degree);
        doctor.setExperienceYears(experienceYears);
        doctor.setBio(bio);
        doctor.setAvatarUrl(avatarUrl);

        boolean ok = doctorDAO.updateProfile(doctor);

        if (ok) {
            // Cập nhật lại fullName + avatarUrl trong session nếu cần
            user.setFullName(fullName);
            user.setAvatarUrl(avatarUrl);
            req.getSession().setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + "/doctor/profile?saved=1");
        } else {
            showError(req, resp, doctor, "Lưu thất bại. Vui lòng thử lại.");
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private void showError(HttpServletRequest req, HttpServletResponse resp, Doctor doctor, String message)
            throws ServletException, IOException {
        req.setAttribute("error",  message);
        req.setAttribute("doctor", doctor);
        req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
    }

    private User getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return (User) s.getAttribute("user");
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }

    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) return null;
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                String filename = token.substring(token.indexOf("=") + 2, token.length() - 1);
                return Paths.get(filename).getFileName().toString();
            }
        }
        return null;
    }
}