package com.clinic.controller;

import com.clinic.dao.AdminProfileDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.BCryptUtil;
import com.clinic.utils.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet trang Hồ Sơ Cá Nhân của Quản trị viên.
 *
 * <p>Phạm vi: xem/sửa họ tên, email, số điện thoại; đổi mật khẩu;
 * hiển thị vai trò ở dạng chỉ đọc. Không có chức năng nào khác.
 *
 * <p><b>URL:</b> {@code /admin/users/profile}. Đường dẫn nằm dưới tiền tố
 * {@code /admin/users/} đã có trong whitelist của
 * {@link com.clinic.config.AuthorizationConfig}, nên không cần khai báo thêm
 * quyền mới. AdminUserServlet chỉ map các pattern chính xác
 * ({@code /admin/users}, {@code /admin/users/}, {@code /admin/staff},
 * {@code /admin/staff/}) nên không xung đột.
 *
 * <p><b>Bảo mật:</b> id của người dùng LUÔN lấy từ session, không bao giờ
 * đọc từ tham số request. Mọi kiểm tra dữ liệu đều thực hiện ở phía server.
 *
 * <p><b>Tái sử dụng:</b> {@link UserDAO} (kết nối CSDL + mã hoá email/phone),
 * {@link BCryptUtil} (băm và so sánh mật khẩu), {@link AuditUtil} (ghi nhật ký).
 * Không viết mới bất kỳ lớp kết nối, hàm băm hay hàm ghi nhật ký nào.
 */
@WebServlet("/admin/users/profile")
public class AdminProfileServlet extends HttpServlet {

    /** Đường dẫn JSP của trang hồ sơ. */
    private static final String VIEW = "/views/admin/profile/index.jsp";

    /** Đường dẫn tương đối dùng khi redirect sau khi lưu thành công. */
    private static final String SELF_PATH = "/admin/users/profile";

    /** Bảng bị tác động — trùng với giá trị mà trang Lịch Sử Hoạt Động đang lọc. */
    private static final String AUDIT_TABLE = "users";

    // ── Lý do đổi mật khẩu thất bại, dùng cho nhật ký hoạt động ──
    // CHỈ ghi lý do. TUYỆT ĐỐI không ghi mật khẩu người dùng vừa nhập,
    // kể cả một phần hay đã băm.
    private static final String PW_FAIL_WRONG_CURRENT =
            "Đổi mật khẩu thất bại: sai mật khẩu hiện tại";
    private static final String PW_FAIL_INVALID_NEW =
            "Đổi mật khẩu thất bại: mật khẩu mới không hợp lệ";
    private static final String PW_FAIL_CONFIRM_MISMATCH =
            "Đổi mật khẩu thất bại: xác nhận không khớp";

    /** Họ tên tối đa 100 ký tự. */
    private static final int MAX_FULL_NAME_LENGTH = 100;

    // Độ dài tối thiểu và các yêu cầu khác của mật khẩu nay do
    // ValidationUtil.validatePassword() quy định chung cho toàn hệ thống.

    /** Số điện thoại: rỗng, hoặc đúng 10 chữ số bắt đầu bằng 0. */
    private static final String PROFILE_PHONE_REGEX = "^0[0-9]{9}$";

    private final UserDAO userDAO;
    private final AdminProfileDAO adminProfileDAO;

    public AdminProfileServlet() {
        this.userDAO = new UserDAO();
        this.adminProfileDAO = new AdminProfileDAO();
    }

    // ══════════════════════════════════════════════════════════
    // GET — hiển thị trang hồ sơ
    // ══════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User sessionUser = getSessionUser(request);
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Nạp lại từ CSDL để chắc chắn hiển thị dữ liệu mới nhất
        // (session không giữ password_hash và có thể đã cũ).
        User fresh = userDAO.findById(sessionUser.getId());
        if (fresh == null) {
            request.setAttribute("pf_infoError",
                    "Không tải được hồ sơ của bạn. Vui lòng thử lại sau.");
            forwardToView(request, response, sessionUser);
            return;
        }

        if ("1".equals(request.getParameter("pf_saved"))) {
            request.setAttribute("pf_infoSuccess",
                    "Đã cập nhật thông tin cá nhân thành công.");
        }

        forwardToView(request, response, fresh);
    }

    // ══════════════════════════════════════════════════════════
    // POST — lưu thông tin hoặc đổi mật khẩu
    // ══════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Bắt buộc đặt UTF-8 TRƯỚC khi đọc bất kỳ tham số nào,
        // nếu không tiếng Việt có dấu sẽ bị hỏng.
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User sessionUser = getSessionUser(request);
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // id LUÔN lấy từ session — không bao giờ từ tham số request.
        int userId = sessionUser.getId();

        String action = request.getParameter("pf_action");
        if ("password".equals(action)) {
            handlePasswordChange(request, response, userId);
        } else {
            handleInfoUpdate(request, response, userId);
        }
    }

    // ══════════════════════════════════════════════════════════
    // LUỒNG 1 — CẬP NHẬT HỌ TÊN / EMAIL / SỐ ĐIỆN THOẠI
    // ══════════════════════════════════════════════════════════

    private void handleInfoUpdate(HttpServletRequest request, HttpServletResponse response,
                                  int userId)
            throws ServletException, IOException {

        // Chỉ đọc trường DUY NHẤT được phép sửa. KHÔNG có getParameter cho
        // pf_email, pf_phone hay vai trò — ba trường đó là chỉ-xem, và
        // AdminProfileDAO cũng không có chúng trong câu UPDATE.
        String fullName = trimToEmpty(request.getParameter("pf_fullName"));

        // Giữ lại giá trị người dùng vừa nhập để hiển thị lại khi có lỗi.
        request.setAttribute("pf_formFullName", fullName);

        User current = userDAO.findById(userId);
        if (current == null) {
            failInfo(request, response, userId,
                    "Không tìm thấy tài khoản của bạn. Vui lòng đăng nhập lại.");
            return;
        }

        // ── Kiểm tra họ tên: không rỗng, tối đa 100 ký tự ──
        if (fullName.isEmpty()) {
            failInfo(request, response, userId, "Vui lòng nhập họ và tên.");
            return;
        }
        if (fullName.length() > MAX_FULL_NAME_LENGTH) {
            failInfo(request, response, userId,
                    "Họ và tên không được vượt quá " + MAX_FULL_NAME_LENGTH + " ký tự.");
            return;
        }

        // ── Giá trị cũ dùng cho nhật ký ──
        String oldFullName = current.getFullName();

        // Không thay đổi gì → không ghi nhật ký, không cần UPDATE.
        if (fullName.equals(oldFullName)) {
            response.sendRedirect(request.getContextPath() + SELF_PATH + "?pf_saved=1");
            return;
        }

        // ── Ghi xuống CSDL ──
        // Dùng AdminProfileDAO: câu UPDATE chỉ chứa full_name và updated_at.
        // KHÔNG có email/phone/role_id/status/username trong câu lệnh.
        boolean saved = adminProfileDAO.updateBasicInfo(userId, fullName);
        if (!saved) {
            failInfo(request, response, userId,
                    "Không lưu được thay đổi. Vui lòng thử lại.");
            return;
        }

        // ── Ghi nhật ký hoạt động (bảng users — đúng phân hệ trang Lịch Sử đang lọc) ──
        AuditUtil.log(request, "Cập nhật hồ sơ cá nhân quản trị viên", AUDIT_TABLE,
                buildInfoJson(oldFullName), buildInfoJson(fullName));

        // ── Đồng bộ lại session để header/sidebar hiện tên mới ──
        HttpSession session = request.getSession(false);
        if (session != null) {
            User sessionUser = (User) session.getAttribute("user");
            if (sessionUser != null) {
                // Chỉ họ tên thay đổi — email và số điện thoại là trường chỉ-xem.
                sessionUser.setFullName(fullName);
                session.setAttribute("user", sessionUser);
            }
        }

        // Redirect (không forward) để F5 không gửi lại form.
        response.sendRedirect(request.getContextPath() + SELF_PATH + "?pf_saved=1");
    }

    // ══════════════════════════════════════════════════════════
    // LUỒNG 2 — ĐỔI MẬT KHẨU
    // ══════════════════════════════════════════════════════════

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response,
                                      int userId)
            throws ServletException, IOException {

        String currentPassword = nullToEmpty(request.getParameter("pf_currentPassword"));
        String newPassword     = nullToEmpty(request.getParameter("pf_newPassword"));
        String confirmPassword = nullToEmpty(request.getParameter("pf_confirmPassword"));

        User current = userDAO.findById(userId);
        if (current == null) {
            failPassword(request, response, userId,
                    "Không tìm thấy tài khoản của bạn. Vui lòng đăng nhập lại.", null);
            return;
        }

        // ══ XÁC MINH MẬT KHẨU HIỆN TẠI TRƯỚC MỌI BƯỚC KIỂM TRA KHÁC ══
        if (currentPassword.isEmpty()) {
            // Bỏ trống thì chưa phải một lần thử mật khẩu → không ghi nhật ký.
            failPassword(request, response, userId,
                    "Vui lòng nhập mật khẩu hiện tại.", null);
            return;
        }
        if (!BCryptUtil.checkPassword(currentPassword, current.getPasswordHash())) {
            failPassword(request, response, userId,
                    "Mật khẩu hiện tại không chính xác.", PW_FAIL_WRONG_CURRENT);
            return;
        }

        // ── Kiểm tra mật khẩu mới ──
        if (newPassword.isEmpty()) {
            failPassword(request, response, userId,
                    "Vui lòng nhập mật khẩu mới.", PW_FAIL_INVALID_NEW);
            return;
        }
        // Luật mật khẩu chung của toàn hệ thống.
        // Trước đây trang này đòi riêng ≥8 ký tự có chữ HOA + thường + số nhưng không
        // cần ký tự đặc biệt — lệch với 4 nơi còn lại, khiến một mật khẩu đặt được ở
        // đây lại bị /change-password từ chối và ngược lại.
        String newPasswordError = ValidationUtil.validatePassword(newPassword);
        if (newPasswordError != null) {
            failPassword(request, response, userId, newPasswordError, PW_FAIL_INVALID_NEW);
            return;
        }
        if (BCryptUtil.checkPassword(newPassword, current.getPasswordHash())) {
            failPassword(request, response, userId,
                    "Mật khẩu mới không được trùng với mật khẩu hiện tại.", PW_FAIL_INVALID_NEW);
            return;
        }

        // ── Kiểm tra nhập lại mật khẩu ──
        if (confirmPassword.isEmpty()) {
            failPassword(request, response, userId,
                    "Vui lòng nhập lại mật khẩu mới.", PW_FAIL_CONFIRM_MISMATCH);
            return;
        }
        if (!confirmPassword.equals(newPassword)) {
            failPassword(request, response, userId,
                    "Mật khẩu nhập lại không khớp với mật khẩu mới.", PW_FAIL_CONFIRM_MISMATCH);
            return;
        }

        // ── Băm và cập nhật (dùng lại BCryptUtil + UserDAO sẵn có) ──
        String newHash = BCryptUtil.hashPassword(newPassword);
        boolean updated = userDAO.updatePassword(userId, newHash);
        if (!updated) {
            failPassword(request, response, userId,
                    "Không đổi được mật khẩu. Vui lòng thử lại.", null);
            return;
        }

        // Ghi nhật ký TRƯỚC khi huỷ session — AuditUtil lấy userId từ session.
        AuditUtil.log(request, "Đổi mật khẩu hồ sơ cá nhân quản trị viên",
                AUDIT_TABLE, null, null);

        // ── Huỷ session và chuyển về trang đăng nhập ──
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("successMessage",
                "Đổi mật khẩu thành công! Vui lòng đăng nhập lại bằng mật khẩu mới.");

        response.sendRedirect(request.getContextPath() + "/login");
    }

    // ══════════════════════════════════════════════════════════
    // HELPER
    // ══════════════════════════════════════════════════════════

    /** Lấy user từ session. Trả về null nếu chưa đăng nhập. */
    private User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object obj = session.getAttribute("user");
        return (obj instanceof User) ? (User) obj : null;
    }

    /** Nạp dữ liệu cần thiết rồi forward sang JSP. */
    private void forwardToView(HttpServletRequest request, HttpServletResponse response,
                               User user)
            throws ServletException, IOException {
        request.setAttribute("pf_user", user);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /** Lỗi ở form thông tin — hiển thị lại trang kèm thông báo. */
    private void failInfo(HttpServletRequest request, HttpServletResponse response,
                          int userId, String message)
            throws ServletException, IOException {
        request.setAttribute("pf_infoError", message);
        User user = userDAO.findById(userId);
        forwardToView(request, response, user);
    }

    /**
     * Lỗi ở form đổi mật khẩu — hiển thị lại trang kèm thông báo.
     *
     * @param message   thông báo hiển thị cho người dùng
     * @param logReason lý do ghi vào nhật ký hoạt động, hoặc null nếu không ghi.
     *                  Chỉ ghi lý do — KHÔNG BAO GIỜ ghi mật khẩu vừa nhập.
     */
    private void failPassword(HttpServletRequest request, HttpServletResponse response,
                              int userId, String message, String logReason)
            throws ServletException, IOException {

        // Ghi nhật ký lần đổi mật khẩu thất bại. Dùng đúng AuditUtil.log() sẵn có,
        // cùng cặp giá trị với dòng "Đổi mật khẩu ... thành công" (table_name =
        // "users") để trang Lịch Sử Hoạt Động lọc ra được. AuditUtil tự lấy userId
        // từ session và tự trích xuất IP từ request, giống mọi dòng log khác.
        if (logReason != null) {
            AuditUtil.log(request, logReason, AUDIT_TABLE, null, null);
        }

        request.setAttribute("pf_pwError", message);
        User user = userDAO.findById(userId);
        forwardToView(request, response, user);
    }

    /**
     * Gói 3 trường thông tin thành JSON cho cột old_value/new_value của audit_logs.
     */
    private String buildInfoJson(String fullName) {
        return "{\"full_name\":\"" + escapeJson(fullName) + "\"}";
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
