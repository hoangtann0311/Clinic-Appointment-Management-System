package com.clinic.controller;

import com.clinic.dao.UserProfileDAO;
import com.clinic.model.User;
import com.clinic.model.UserProfile;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.ProfileFormSupport;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Servlet trang Hồ Sơ Cá Nhân của Nhân viên lễ tân (role_id = 4).
 *
 * <p><b>URL:</b> {@code /staff/profile} — nằm trong zone {@code /staff} của vai trò 4
 * ({@link com.clinic.config.AuthorizationConfig#ROLE_ZONES}), đã thêm vào whitelist với
 * permission key {@code user.view} mà vai trò 4 có sẵn.
 *
 * <p><b>Nơi cất dữ liệu:</b> chỉ bảng {@code users}. Vai trò này không có bảng mở rộng.
 *
 * <p><b>Phạm vi:</b> sửa được họ tên và số điện thoại. Chỉ-xem: email, bộ phận,
 * chức danh, vai trò. Đổi mật khẩu qua {@code /change-password} sẵn có.
 * KHÔNG có ảnh đại diện — bảng {@code users} không có cột lưu ảnh.
 *
 * <p><b>Bảo mật:</b> id LUÔN lấy từ session, không bao giờ từ tham số request.
 * Servlet chỉ gọi {@code getParameter} cho đúng hai trường sửa được;
 * {@link UserProfileDAO} cũng không có cột chỉ-xem nào trong câu UPDATE — khoá cả
 * hai phía. Tham số lạ gửi kèm (kể cả tham số của trang hồ sơ vai trò khác) không
 * được đọc tới, không lưu, không lỗi.
 *
 * <p><b>Tái sử dụng:</b> {@link ProfileFormSupport} và ba fragment trong
 * {@code views/common} — đúng những thứ đã viết cho Bác sĩ siêu âm, không sửa lại.
 * Phần ảnh đại diện được "tắt" đơn giản bằng cách không gọi
 * {@code ProfileFormSupport.saveAvatar}.
 */
@WebServlet("/staff/profile")
public class StaffProfileServlet extends HttpServlet {

    private static final String VIEW = "/views/staff/profile.jsp";
    private static final String SELF_PATH = "/staff/profile";

    /** Dữ liệu nằm ở bảng users — trùng giá trị trang Lịch Sử Hoạt Động đang lọc. */
    private static final String AUDIT_TABLE = "users";

    private final UserProfileDAO profileDAO = new UserProfileDAO();

    // ══════════════════════════════════════════════════════════
    // GET — hiển thị trang
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
            request.setAttribute("pf_infoSuccess", "Đã cập nhật thông tin cá nhân thành công.");
        }

        forwardToView(request, response, sessionUser);
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

        // ── Đọc CHỈ hai trường được phép sửa ────────────────────────────────
        // Không có getParameter cho email, bộ phận, chức danh hay vai trò.
        String fullName = ProfileFormSupport.trimToEmpty(request.getParameter("pf_fullName"));
        String phone    = ProfileFormSupport.trimToEmpty(request.getParameter("pf_phone"));

        // Giữ lại giá trị vừa nhập để hiển thị lại khi có lỗi.
        request.setAttribute("pf_formFullName", fullName);
        request.setAttribute("pf_formPhone", phone);

        // ── Kiểm tra ────────────────────────────────────────────────────────
        String error = ProfileFormSupport.validateFullName(fullName);
        if (error == null) {
            error = ProfileFormSupport.validateUserPhone(phone);
        }
        if (error != null) {
            failInfo(request, response, sessionUser, error);
            return;
        }

        UserProfile current = profileDAO.findByUserId(userId);
        if (current == null) {
            failInfo(request, response, sessionUser,
                    "Không tìm thấy tài khoản của bạn. Vui lòng đăng nhập lại.");
            return;
        }

        // Không thay đổi gì → không ghi nhật ký, không cần UPDATE.
        String currentPhone = current.getPhone() == null ? "" : current.getPhone();
        if (fullName.equals(current.getFullName()) && phone.equals(currentPhone)) {
            response.sendRedirect(request.getContextPath() + SELF_PATH + "?saved=1");
            return;
        }

        // ── Lưu ─────────────────────────────────────────────────────────────
        boolean saved = profileDAO.updateBasicInfo(userId, fullName,
                phone.isEmpty() ? null : phone);
        if (!saved) {
            failInfo(request, response, sessionUser,
                    "Không lưu được thay đổi. Vui lòng thử lại.");
            return;
        }

        // ── Nhật ký hoạt động ───────────────────────────────────────────────
        AuditUtil.log(request, "Cập nhật hồ sơ cá nhân nhân viên lễ tân", AUDIT_TABLE,
                buildJson(current.getFullName(), currentPhone),
                buildJson(fullName, phone));

        // ── Đồng bộ session để topbar/sidebar hiện tên mới ──────────────────
        HttpSession session = request.getSession(false);
        if (session != null) {
            sessionUser.setFullName(fullName);
            sessionUser.setPhone(phone.isEmpty() ? null : phone);
            session.setAttribute("user", sessionUser);
        }

        // Redirect (không forward) để F5 không gửi lại form.
        response.sendRedirect(request.getContextPath() + SELF_PATH + "?saved=1");
    }

    // ══════════════════════════════════════════════════════════
    // HELPER
    // ══════════════════════════════════════════════════════════

    private void forwardToView(HttpServletRequest request, HttpServletResponse response,
                               User sessionUser)
            throws ServletException, IOException {

        UserProfile profile = profileDAO.findByUserId(sessionUser.getId());
        request.setAttribute("pf_profile", profile);
        request.setAttribute("pf_user", sessionUser);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private void failInfo(HttpServletRequest request, HttpServletResponse response,
                          User sessionUser, String message)
            throws ServletException, IOException {
        request.setAttribute("pf_infoError", message);
        forwardToView(request, response, sessionUser);
    }

    /** Gói các trường thành JSON cho cột old_value/new_value của audit_logs. */
    private String buildJson(String fullName, String phone) {
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("full_name", fullName);
        fields.put("phone", phone);
        return ProfileFormSupport.buildAuditJson(fields);
    }
}
