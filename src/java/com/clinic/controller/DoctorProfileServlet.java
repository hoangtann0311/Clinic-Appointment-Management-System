package com.clinic.controller;

import com.clinic.dao.DoctorDAO;
import com.clinic.model.Doctor;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Bác sĩ xem và cập nhật hồ sơ cá nhân.
 *
 * GET  /doctor/profile  → hiện form hồ sơ
 * POST /doctor/profile  → lưu thay đổi
 */
@WebServlet("/doctor/profile")
public class DoctorProfileServlet extends HttpServlet {

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
        String avatarUrl   = trim(req.getParameter("avatarUrl"));

        // Validate cơ bản
        if (fullName == null || fullName.isEmpty()) {
            req.setAttribute("error",  "Họ tên không được để trống.");
            req.setAttribute("doctor", doctor);
            req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
            return;
        }
        if (phoneNumber != null && !phoneNumber.isEmpty()
                && !phoneNumber.matches("^[0-9+\\-\\s]{7,15}$")) {
            req.setAttribute("error",  "Số điện thoại không hợp lệ.");
            req.setAttribute("doctor", doctor);
            req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
            return;
        }

        int experienceYears = 0;
        try {
            if (expStr != null && !expStr.isEmpty()) {
                experienceYears = Integer.parseInt(expStr);
                if (experienceYears < 0 || experienceYears > 60) {
                    req.setAttribute("error", "Số năm kinh nghiệm không hợp lệ (0–60).");
                    req.setAttribute("doctor", doctor);
                    req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
                    return;
                }
            }
        } catch (NumberFormatException e) {
            experienceYears = 0;
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
            // Cập nhật lại fullName trong session nếu cần
            user.setFullName(fullName);
            req.getSession().setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + "/doctor/profile?saved=1");
        } else {
            req.setAttribute("error",  "Lưu thất bại. Vui lòng thử lại.");
            req.setAttribute("doctor", doctor);
            req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

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
}