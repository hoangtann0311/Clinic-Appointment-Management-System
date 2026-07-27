package com.clinic.controller;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.User;
import com.clinic.utils.ProfileFormSupport;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

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

    // Danh sách MIME cho phép nay do ProfileFormSupport.saveAvatar() quản lý,
    // dùng chung với ba vai trò còn lại.

    private static final java.util.Set<String> ALLOWED_SPECIALIZATIONS = java.util.Set.of(
            "Sản phụ khoa",
            "Sản khoa",
            "Phụ khoa",
            "Thai sản & Y học bào thai",
            "Siêu âm sản phụ khoa",
            "Hiếm muộn & IVF"
    );

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DoctorScheduleDAO scheduleDAO = new DoctorScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        try {
            Doctor doctor = doctorDAO.findByUserId(user.getId());
            if (doctor == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Tài khoản chưa liên kết hồ sơ bác sĩ.");
                return;
            }

            req.setAttribute("doctor",     doctor);
            req.setAttribute("doctorName", user.getFullName());

            // Get upcoming schedules
            List<DoctorSchedule> doctorSchedules = scheduleDAO.findAll(
                    0, 5, "APPROVED", doctor.getId(), Date.valueOf(LocalDate.now()), null);
            req.setAttribute("doctorSchedules", doctorSchedules);
            req.setAttribute("saved",      req.getParameter("saved"));
            req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
        } catch (Exception ex) {
            System.err.println("[DoctorProfileServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            req.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/doctors/doctor_profile.jsp").forward(req, resp);
        }
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

        if (specialization == null || !ALLOWED_SPECIALIZATIONS.contains(specialization)) {
            showError(req, resp, doctor,
                    "Chuyên khoa không thuộc phạm vi sản phụ khoa, thai sản và siêu âm của hệ thống.");
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
        // Dùng ProfileFormSupport.saveAvatar() — cùng một chỗ với ba vai trò mới.
        // Giữ nguyên hành vi cũ: cùng thư mục lưu, cùng giới hạn 5MB, cùng danh sách
        // MIME, và cùng khuôn tên file "doctor-<id>-<uuid><ext>".
        //
        // Bổ sung hai chốt mà bản cũ tại chỗ này thiếu:
        //   1. Danh sách trắng ĐUÔI file (.jpg .jpeg .png .webp). Bản cũ lấy nguyên
        //      đuôi từ tên người dùng gửi lên, nên tải lên "x.svg" khai
        //      Content-Type: image/png là ghi được file .svg vào thư mục webapp.
        //      Đuôi .svg nằm trong AuthorizationConfig.STATIC_EXTENSIONS nên URL đó
        //      truy cập được KHÔNG CẦN đăng nhập; SVG chứa <script> chạy trên chính
        //      origin của ứng dụng → stored XSS.
        //   2. Đối chiếu chữ ký byte thật của JPEG/PNG/WEBP, thay vì chỉ tin header
        //      Content-Type do phía gửi tự đặt.
        String avatarUrl = doctor.getAvatarUrl(); // mặc định giữ nguyên ảnh cũ
        ProfileFormSupport.AvatarUploadResult upload = ProfileFormSupport.saveAvatar(
                req, getServletContext(), "avatarFile", "doctor", doctor.getId());
        if (upload.getErrorMessage() != null) {
            showError(req, resp, doctor, upload.getErrorMessage());
            return;
        }
        if (upload.isSuccess()) {
            avatarUrl = upload.getAvatarUrl();
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
            // Đồng bộ full_name sang bảng users — nếu không làm bước này,
            // tên chỉ đổi tạm trong session và sẽ quay về tên cũ sau khi đăng xuất/đăng nhập lại,
            // vì các nơi khác (login, header, danh sách...) đọc full_name từ bảng users chứ không phải doctors.
            if (!fullName.equals(user.getFullName())) {
                boolean userNameSynced = userDAO.updateFullName(user.getId(), fullName);
                if (!userNameSynced) {
                    System.err.println("[DoctorProfileServlet] Cảnh báo: không đồng bộ được full_name sang bảng users cho userId=" + user.getId());
                }
            }

            // Cập nhật lại fullName + avatarUrl trong session để hiển thị ngay
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
}
