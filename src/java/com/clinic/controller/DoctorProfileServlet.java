package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.DoctorScheduleDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.Doctor;
import com.clinic.model.DoctorSchedule;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
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
        String avatarUrl = doctor.getAvatarUrl(); // mặc định giữ nguyên ảnh cũ
        Part avatarPart = req.getPart("avatarFile");
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String originalFileName = getFileName(avatarPart);

            if (originalFileName == null || originalFileName.isEmpty()) {
                showError(req, resp, doctor, "File ảnh không hợp lệ.");
                return;
            }

            // Giới hạn kích thước trước khi đọc vào bộ nhớ
            if (avatarPart.getSize() > AppConfig.getMaxAvatarFileSize()) {
                showError(req, resp, doctor, "Kích thước ảnh không được vượt quá 5MB.");
                return;
            }

            // Validate nội dung thật bằng ImageIO — không tin Content-Type do client gửi.
            // Cơ chế giống hệt UltrasoundUploadServlet.validateJpegOrPng().
            ValidatedImage validated;
            try {
                validated = validateJpegOrPng(avatarPart, originalFileName);
            } catch (IllegalArgumentException ex) {
                showError(req, resp, doctor, ex.getMessage());
                return;
            }

            // Phần mở rộng lấy từ định dạng ảnh THẬT do ImageIO phát hiện,
            // KHÔNG lấy từ tên file gốc do client gửi lên.
            String extension = "image/png".equals(validated.contentType) ? ".png" : ".jpg";
            String storedFileName = "doctor-" + doctor.getId() + "-" + UUID.randomUUID() + extension;

            String relativeUploadDir = AppConfig.getAvatarUploadDirectory();
            String uploadPath = getServletContext().getRealPath("") + File.separator + relativeUploadDir;
            File uploadDirFile = new File(uploadPath);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            String filePath = uploadPath + File.separator + storedFileName;

            // Giải mã và ghi lại ảnh qua ImageIO — loại bỏ mọi dữ liệu lạ nhét kèm.
            try {
                java.awt.image.BufferedImage image = javax.imageio.ImageIO.read(
                        avatarPart.getInputStream());
                if (image == null) {
                    showError(req, resp, doctor, "Không thể giải mã nội dung ảnh.");
                    return;
                }
                String formatName = "image/png".equals(validated.contentType) ? "png" : "jpg";
                boolean written = javax.imageio.ImageIO.write(image, formatName, new java.io.File(filePath));
                if (!written) {
                    showError(req, resp, doctor, "Không thể lưu ảnh đại diện.");
                    return;
                }
            } catch (IOException e) {
                showError(req, resp, doctor, "Lỗi xử lý ảnh: " + e.getMessage());
                return;
            }

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

    /**
     * Validate nội dung thật của file ảnh bằng ImageIO — giống hệt cơ chế
     * của UltrasoundUploadServlet. Không tin Content-Type do client gửi.
     *
     * @throws IllegalArgumentException nếu file không phải ảnh JPEG/PNG hợp lệ
     */
    private ValidatedImage validateJpegOrPng(Part part, String originalFileName) {
        try (java.io.InputStream input = part.getInputStream();
             javax.imageio.stream.ImageInputStream imageInput =
                     javax.imageio.ImageIO.createImageInputStream(input)) {
            if (imageInput == null) {
                throw new IllegalArgumentException("Nội dung file không phải ảnh JPG/PNG hợp lệ.");
            }
            java.util.Iterator<javax.imageio.ImageReader> readers =
                    javax.imageio.ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) {
                throw new IllegalArgumentException("Nội dung file không phải ảnh JPG/PNG hợp lệ.");
            }

            javax.imageio.ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                String format = reader.getFormatName().toUpperCase(java.util.Locale.ROOT);
                boolean jpeg = "JPEG".equals(format) || "JPG".equals(format);
                boolean png = "PNG".equals(format);
                if (!jpeg && !png) {
                    throw new IllegalArgumentException("Chỉ chấp nhận ảnh JPEG hoặc PNG.");
                }

                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0) {
                    throw new IllegalArgumentException("Kích thước ảnh không hợp lệ.");
                }
                if ((long) width * height > 40_000_000L) {
                    throw new IllegalArgumentException("Kích thước ảnh vượt giới hạn an toàn.");
                }

                // Giải mã thật để loại bỏ file header-only
                java.awt.image.BufferedImage decoded = reader.read(0);
                if (decoded == null || decoded.getWidth() != width || decoded.getHeight() != height) {
                    throw new IllegalArgumentException("Không thể giải mã đầy đủ nội dung ảnh.");
                }

                String actualContentType = png ? "image/png" : "image/jpeg";
                return new ValidatedImage(width, height, actualContentType);
            } finally {
                reader.dispose();
            }
        } catch (IllegalArgumentException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new IllegalArgumentException("Không thể đọc định dạng hình ảnh, vui lòng thử file khác.");
        }
    }

    private static final class ValidatedImage {
        final int width;
        final int height;
        final String contentType;

        ValidatedImage(int width, int height, String contentType) {
            this.width = width;
            this.height = height;
            this.contentType = contentType;
        }
    }
}
