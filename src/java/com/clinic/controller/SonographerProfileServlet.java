package com.clinic.controller;

import com.clinic.dao.SonographerProfileDAO;
import com.clinic.model.Sonographer;
import com.clinic.model.User;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.ProfileFormSupport;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

/**
 * Servlet trang Hồ Sơ Cá Nhân của Bác sĩ siêu âm (role_id = 6).
 *
 * <p><b>URL:</b> {@code /sonographer/profile} — nằm trong zone {@code /sonographer}
 * của vai trò 6 ({@link com.clinic.config.AuthorizationConfig#ROLE_ZONES}), và đã được
 * thêm vào whitelist với permission key {@code user.view} — đúng key mà
 * {@code /doctor/profile} đang dùng, và vai trò 6 đã có sẵn key này.
 *
 * <p><b>Nơi cất dữ liệu:</b> bảng {@code sonographers}, KHÔNG phải {@code doctors}.
 * Bác sĩ siêu âm không có dòng trong {@code doctors}; nếu cấp dòng ở đó họ sẽ lọt vào
 * danh sách bác sĩ khám của lễ tân, vì {@code DoctorDAO.getAllDoctors()} không lọc
 * {@code role_id}. Họ tên và số điện thoại đọc/ghi thẳng ở bảng {@code users}.
 *
 * <p><b>Bảo mật:</b> id người dùng LUÔN lấy từ session, không bao giờ đọc từ tham số
 * request. Servlet KHÔNG gọi {@code getParameter} cho email hay vai trò, và
 * {@link SonographerProfileDAO} cũng không có hai cột đó trong bất kỳ câu UPDATE nào —
 * khoá ở cả hai phía. Tham số lạ gửi kèm (kể cả tham số của trang hồ sơ vai trò khác)
 * đơn giản là không được đọc tới.
 *
 * <p><b>Tái sử dụng:</b> {@link ProfileFormSupport} (kiểm tra dữ liệu + lưu ảnh),
 * {@link AuditUtil} (nhật ký), {@code /change-password} (đổi mật khẩu). Không viết mới
 * lớp kết nối, hàm băm hay hàm ghi nhật ký nào, và không sửa file nào của Bác sĩ lâm sàng.
 */
@WebServlet("/sonographer/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize       = 1024 * 1024 * 5, // 5MB — khớp AppConfig.getMaxAvatarFileSize()
    maxRequestSize    = 1024 * 1024 * 10 // 10MB
)
public class SonographerProfileServlet extends HttpServlet {

    private static final String VIEW = "/views/sonographer/profile.jsp";
    private static final String SELF_PATH = "/sonographer/profile";

    /** Bảng bị tác động — trùng giá trị mà trang Lịch Sử Hoạt Động đang lọc. */
    private static final String AUDIT_TABLE = "sonographers";

    /** Tiền tố tên file ảnh lưu xuống đĩa. */
    private static final String AVATAR_PREFIX = "sonographer";

    /** Chuyên khoa — giữ đúng danh sách mà trang hồ sơ Bác sĩ lâm sàng đang chấp nhận. */
    private static final Set<String> ALLOWED_SPECIALIZATIONS = Set.of(
            "Sản phụ khoa",
            "Sản khoa",
            "Phụ khoa",
            "Thai sản & Y học bào thai",
            "Siêu âm sản phụ khoa",
            "Hiếm muộn & IVF"
    );

    /** Học vị — cùng danh sách với ô chọn ở trang hồ sơ Bác sĩ lâm sàng. */
    private static final Set<String> ALLOWED_DEGREES = Set.of(
            "Bác sĩ", "Thạc sĩ", "Tiến sĩ", "Phó Giáo sư",
            "Giáo sư", "Bác sĩ CKI", "Bác sĩ CKII"
    );

    private static final int MAX_BIO_LENGTH = 2000;

    /** Chứng chỉ siêu âm — cột sonographers.qualification là NVARCHAR(100). */
    private static final int MAX_QUALIFICATION_LENGTH = 100;

    private final SonographerProfileDAO profileDAO = new SonographerProfileDAO();

    // ══════════════════════════════════════════════════════════
    // GET — hiển thị trang. KHÔNG ghi bất cứ thứ gì xuống CSDL.
    // ══════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User sessionUser = ProfileFormSupport.requireSessionUser(request, response);
        if (sessionUser == null) {
            return;
        }

        if ("1".equals(request.getParameter("saved"))) {
            request.setAttribute("pf_infoSuccess", "Đã cập nhật hồ sơ cá nhân thành công.");
        }

        forwardToView(request, response, sessionUser.getId(), sessionUser);
    }

    // ══════════════════════════════════════════════════════════
    // POST — lưu thay đổi
    // ══════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đặt UTF-8 TRƯỚC khi đọc tham số, nếu không tiếng Việt có dấu sẽ hỏng.
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User sessionUser = ProfileFormSupport.requireSessionUser(request, response);
        if (sessionUser == null) {
            return;
        }

        // id LUÔN từ session — không bao giờ từ tham số request.
        int userId = sessionUser.getId();

        // ── Đọc CHỈ các trường được phép sửa ────────────────────────────────
        // Không có getParameter cho email, vai trò, room_no hay status.
        String fullName       = ProfileFormSupport.trimToEmpty(request.getParameter("pf_fullName"));
        String phone          = ProfileFormSupport.trimToEmpty(request.getParameter("pf_phone"));
        String specialization = ProfileFormSupport.trimToEmpty(request.getParameter("pf_specialization"));
        String degree         = ProfileFormSupport.trimToEmpty(request.getParameter("pf_degree"));
        String experienceRaw  = ProfileFormSupport.trimToEmpty(request.getParameter("pf_experienceYears"));
        String bio            = ProfileFormSupport.trimToEmpty(request.getParameter("pf_bio"));
        String qualification  = ProfileFormSupport.trimToEmpty(request.getParameter("pf_qualification"));

        // Giữ lại giá trị vừa nhập để hiển thị lại khi có lỗi.
        request.setAttribute("pf_formFullName", fullName);
        request.setAttribute("pf_formPhone", phone);
        request.setAttribute("pf_formSpecialization", specialization);
        request.setAttribute("pf_formDegree", degree);
        request.setAttribute("pf_formExperienceYears", experienceRaw);
        request.setAttribute("pf_formBio", bio);
        request.setAttribute("pf_formQualification", qualification);

        // ── Kiểm tra ────────────────────────────────────────────────────────
        String error = ProfileFormSupport.validateFullName(fullName);
        if (error == null) {
            error = ProfileFormSupport.validateUserPhone(phone);
        }
        if (error == null && specialization.isEmpty()) {
            error = "Vui lòng chọn chuyên khoa.";
        }
        if (error == null) {
            error = ProfileFormSupport.validateOneOf(specialization, ALLOWED_SPECIALIZATIONS,
                    "Chuyên khoa không thuộc phạm vi sản phụ khoa, thai sản và siêu âm của hệ thống.");
        }
        if (error == null) {
            error = ProfileFormSupport.validateOneOf(degree, ALLOWED_DEGREES,
                    "Học vị không nằm trong danh sách cho phép.");
        }
        if (error == null) {
            error = ProfileFormSupport.validateIntRange(experienceRaw, 0, 60, "Số năm kinh nghiệm");
        }
        if (error == null) {
            error = ProfileFormSupport.validateMaxLength(bio, MAX_BIO_LENGTH, "Giới thiệu bản thân");
        }
        if (error == null) {
            error = ProfileFormSupport.validateMaxLength(qualification, MAX_QUALIFICATION_LENGTH,
                    "Chứng chỉ siêu âm");
        }
        if (error != null) {
            failInfo(request, response, userId, sessionUser, error);
            return;
        }

        // ── Trạng thái hiện tại, dùng cho ảnh cũ và cho nhật ký ─────────────
        Sonographer current = profileDAO.findByUserId(userId);
        String avatarUrl = (current != null) ? current.getAvatarUrl() : null;

        // ── Ảnh đại diện (tuỳ chọn) ─────────────────────────────────────────
        ProfileFormSupport.AvatarUploadResult upload =
                ProfileFormSupport.saveAvatar(request, getServletContext(),
                        "pf_avatarFile", AVATAR_PREFIX, userId);
        if (upload.getErrorMessage() != null) {
            failInfo(request, response, userId, sessionUser, upload.getErrorMessage());
            return;
        }
        if (upload.isSuccess()) {
            avatarUrl = upload.getAvatarUrl();
        }

        // ── Giá trị cũ cho nhật ký ──────────────────────────────────────────
        String[] contact = profileDAO.findContactByUserId(userId);
        String oldPhone = contact[1];
        String oldValueJson = buildJson(
                sessionUser.getFullName(), oldPhone,
                current != null ? current.getSpecialization() : null,
                current != null ? current.getDegree() : null,
                current != null ? String.valueOf(current.getExperienceYears()) : null,
                current != null ? current.getQualification() : null);

        // ── Lưu ─────────────────────────────────────────────────────────────
        Sonographer profile = new Sonographer();
        profile.setUserId(userId);
        profile.setSpecialization(specialization);
        profile.setDegree(degree.isEmpty() ? null : degree);
        profile.setExperienceYears(ProfileFormSupport.parseIntOrZero(experienceRaw));
        profile.setBio(bio.isEmpty() ? null : bio);
        profile.setAvatarUrl(avatarUrl);
        profile.setQualification(qualification.isEmpty() ? null : qualification);

        boolean saved = profileDAO.saveProfile(userId, profile, fullName,
                phone.isEmpty() ? null : phone);
        if (!saved) {
            failInfo(request, response, userId, sessionUser,
                    "Không lưu được thay đổi. Vui lòng thử lại.");
            return;
        }

        // ── Nhật ký hoạt động ───────────────────────────────────────────────
        AuditUtil.log(request, "Cập nhật hồ sơ cá nhân bác sĩ siêu âm", AUDIT_TABLE,
                oldValueJson,
                buildJson(fullName, phone, specialization, degree, experienceRaw, qualification));

        // ── Đồng bộ session để header/sidebar hiện ngay ─────────────────────
        HttpSession session = request.getSession(false);
        if (session != null) {
            sessionUser.setFullName(fullName);
            sessionUser.setPhone(phone.isEmpty() ? null : phone);
            sessionUser.setAvatarUrl(avatarUrl);
            session.setAttribute("user", sessionUser);
        }

        // Redirect (không forward) để F5 không gửi lại form.
        response.sendRedirect(request.getContextPath() + SELF_PATH + "?saved=1");
    }

    // ══════════════════════════════════════════════════════════
    // HELPER
    // ══════════════════════════════════════════════════════════

    /** Nạp dữ liệu hiển thị rồi forward sang JSP. */
    private void forwardToView(HttpServletRequest request, HttpServletResponse response,
                               int userId, User sessionUser)
            throws ServletException, IOException {

        Sonographer profile = profileDAO.findByUserId(userId);
        if (profile == null) {
            // Chưa có dòng trong bảng sonographers. KHÔNG tạo ở đây — GET không được
            // phép ghi. Dòng sẽ được tạo ở luồng POST khi người dùng bấm Lưu.
            profile = new Sonographer();
            profile.setUserId(userId);
        }

        String[] contact = profileDAO.findContactByUserId(userId);

        request.setAttribute("pf_profile", profile);
        request.setAttribute("pf_user", sessionUser);
        request.setAttribute("pf_email", contact[0]);
        request.setAttribute("pf_phone", contact[1]);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /** Lỗi ở form thông tin — hiển thị lại trang kèm thông báo. */
    private void failInfo(HttpServletRequest request, HttpServletResponse response,
                          int userId, User sessionUser, String message)
            throws ServletException, IOException {
        request.setAttribute("pf_infoError", message);
        forwardToView(request, response, userId, sessionUser);
    }

    /** Gói các trường thành JSON cho cột old_value/new_value của audit_logs. */
    private String buildJson(String fullName, String phone, String specialization,
                             String degree, String experienceYears, String qualification) {
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("full_name", fullName);
        fields.put("phone", phone);
        fields.put("specialization", specialization);
        fields.put("degree", degree);
        fields.put("experience_years", experienceYears);
        fields.put("qualification", qualification);
        return ProfileFormSupport.buildAuditJson(fields);
    }
}
