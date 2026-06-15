package com.clinic.service;

import com.clinic.dao.PasswordResetTokenDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.PasswordResetToken;
import com.clinic.model.User;
import com.clinic.utils.BCryptUtil;
import com.clinic.utils.EmailUtil;
import com.clinic.utils.ValidationUtil;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Service xử lý nghiệp vụ quên mật khẩu, đặt lại mật khẩu và đổi mật khẩu.
 * Validate input tại Service layer theo kiến trúc chuẩn.
 */
public class PasswordService {

    /** Thời gian hết hạn token: 1 giờ */
    private static final int TOKEN_EXPIRY_HOURS = 1;

    private final UserDAO userDAO;
    private final PasswordResetTokenDAO tokenDAO;

    public PasswordService() {
        this.userDAO = new UserDAO();
        this.tokenDAO = new PasswordResetTokenDAO();
    }

    /**
     * Xử lý yêu cầu quên mật khẩu.
     * Flow: validate email → tìm user → hủy token cũ → tạo token mới
     *       → lưu vào DB → gửi email reset.
     *
     * LƯU Ý BẢO MẬT: Luôn hiển thị thông báo thành công ngay cả khi
     * email không tồn tại, để tránh lộ thông tin người dùng.
     *
     * @param email email người dùng nhập
     * @return true nếu email hợp lệ và đã gửi (không tiết lộ email có tồn tại hay không)
     */
    public boolean forgotPassword(String email) {
        // Validate email không rỗng
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        email = email.trim().toLowerCase();

        // Kiểm tra định dạng email
        if (!ValidationUtil.isValidEmail(email)) {
            return false;
        }

        // Tìm user theo email
        User user = userDAO.findByEmail(email);
        if (user == null) {
            // Email không tồn tại: vẫn trả về true để không lộ thông tin
            // Nhưng không gửi email
            System.out.println(">>> Yêu cầu quên mật khẩu cho email không tồn tại: " + email);
            return true;
        }

        // Hủy tất cả token cũ của user này
        tokenDAO.invalidateAllTokensForUser(user.getId());

        // Tạo token mới
        String tokenValue = UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plusHours(TOKEN_EXPIRY_HOURS);

        PasswordResetToken resetToken = new PasswordResetToken(user.getId(), tokenValue, expiresAt);
        tokenDAO.insert(resetToken);

        // Gửi email đặt lại mật khẩu
        try {
            EmailUtil.sendPasswordResetEmail(user.getEmail(), user.getFullName(), tokenValue);
        } catch (Exception e) {
            System.err.println("Cảnh báo: Không gửi được email đặt lại mật khẩu đến " + email);
        }

        System.out.println(">>> Đã tạo token đặt lại mật khẩu cho user: " + user.getEmail()
                + " (userId=" + user.getId() + ")");
        return true;
    }

    /**
     * Xác thực token và đặt lại mật khẩu mới.
     *
     * @param token           token từ link email
     * @param newPassword     mật khẩu mới
     * @param confirmPassword xác nhận mật khẩu mới
     * @param errors          Map để chứa lỗi nếu có
     * @return User nếu đặt lại mật khẩu thành công, null nếu thất bại
     */
    public User resetPassword(String token, String newPassword,
                              String confirmPassword, Map<String, String> errors) {

        // Bước 1: Validate token không rỗng
        if (token == null || token.trim().isEmpty()) {
            errors.put("token", "Token không hợp lệ hoặc đã hết hạn.");
            return null;
        }

        // Bước 2: Validate mật khẩu mới
        if (newPassword == null || newPassword.isEmpty()) {
            errors.put("newPassword", "Mật khẩu mới không được để trống.");
            return null;
        }
        if (newPassword.length() < 6) {
            errors.put("newPassword", "Mật khẩu phải có ít nhất 6 ký tự.");
            return null;
        }
        if (!newPassword.matches(".*[A-Za-z].*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 chữ cái.");
            return null;
        }
        if (!newPassword.matches(".*\\d.*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 chữ số.");
            return null;
        }
        if (!newPassword.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~].*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (VD: !@#$%).");
            return null;
        }

        // Bước 3: Validate xác nhận mật khẩu
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không được để trống.");
            return null;
        }
        if (!confirmPassword.equals(newPassword)) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không khớp với mật khẩu mới.");
            return null;
        }

        // Bước 4: Tìm token trong database
        PasswordResetToken resetToken = tokenDAO.findByToken(token.trim());
        if (resetToken == null) {
            errors.put("token", "Link đặt lại mật khẩu không hợp lệ.");
            return null;
        }

        // Bước 5: Kiểm tra token còn hợp lệ không
        if (resetToken.isUsed()) {
            errors.put("token", "Link đặt lại mật khẩu đã được sử dụng. Vui lòng gửi yêu cầu mới.");
            return null;
        }
        if (resetToken.isExpired()) {
            errors.put("token", "Link đặt lại mật khẩu đã hết hạn (quá 1 giờ). Vui lòng gửi yêu cầu mới.");
            return null;
        }

        // Bước 6: Tìm user
        User user = userDAO.findById(resetToken.getUserId());
        if (user == null) {
            errors.put("token", "Tài khoản không tồn tại.");
            return null;
        }

        // Bước 7: Hash mật khẩu mới và cập nhật
        String newPasswordHash = BCryptUtil.hashPassword(newPassword);
        boolean updated = userDAO.updatePassword(user.getId(), newPasswordHash);

        if (!updated) {
            errors.put("token", "Có lỗi xảy ra khi đặt lại mật khẩu. Vui lòng thử lại.");
            return null;
        }

        // Bước 8: Đánh dấu token đã sử dụng
        tokenDAO.markAsUsed(resetToken.getId());

        // Xóa password hash trước khi trả về
        user.setPasswordHash(null);

        System.out.println(">>> Đặt lại mật khẩu thành công cho user: " + user.getEmail()
                + " (userId=" + user.getId() + ")");
        return user;
    }

    /**
     * Đổi mật khẩu cho người dùng đã đăng nhập.
     * Yêu cầu nhập mật khẩu cũ để xác thực.
     *
     * @param userId          id của user
     * @param oldPassword     mật khẩu cũ
     * @param newPassword     mật khẩu mới
     * @param confirmPassword xác nhận mật khẩu mới
     * @param errors          Map để chứa lỗi nếu có
     * @return true nếu đổi mật khẩu thành công
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword,
                                  String confirmPassword, Map<String, String> errors) {

        // Bước 1: Lấy thông tin user hiện tại kèm password hash
        User user = userDAO.findById(userId);
        if (user == null) {
            errors.put("general", "Tài khoản không tồn tại.");
            return false;
        }

        // Bước 2: Validate mật khẩu cũ không rỗng
        if (oldPassword == null || oldPassword.isEmpty()) {
            errors.put("oldPassword", "Vui lòng nhập mật khẩu hiện tại.");
            return false;
        }

        // Bước 3: Kiểm tra mật khẩu cũ có đúng không
        if (!BCryptUtil.checkPassword(oldPassword, user.getPasswordHash())) {
            errors.put("oldPassword", "Mật khẩu hiện tại không chính xác.");
            return false;
        }

        // Bước 4: Validate mật khẩu mới
        if (newPassword == null || newPassword.isEmpty()) {
            errors.put("newPassword", "Mật khẩu mới không được để trống.");
            return false;
        }
        if (newPassword.length() < 6) {
            errors.put("newPassword", "Mật khẩu phải có ít nhất 6 ký tự.");
            return false;
        }
        if (!newPassword.matches(".*[A-Za-z].*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 chữ cái.");
            return false;
        }
        if (!newPassword.matches(".*\\d.*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 chữ số.");
            return false;
        }
        if (!newPassword.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~].*")) {
            errors.put("newPassword", "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (VD: !@#$%).");
            return false;
        }

        // Bước 5: Kiểm tra mật khẩu mới không trùng mật khẩu cũ
        if (BCryptUtil.checkPassword(newPassword, user.getPasswordHash())) {
            errors.put("newPassword", "Mật khẩu mới không được trùng với mật khẩu hiện tại.");
            return false;
        }

        // Bước 6: Validate xác nhận mật khẩu
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không được để trống.");
            return false;
        }
        if (!confirmPassword.equals(newPassword)) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không khớp với mật khẩu mới.");
            return false;
        }

        // Bước 7: Hash và cập nhật mật khẩu mới
        String newPasswordHash = BCryptUtil.hashPassword(newPassword);
        boolean updated = userDAO.updatePassword(userId, newPasswordHash);

        if (updated) {
            System.out.println(">>> Đổi mật khẩu thành công cho user: " + user.getEmail()
                    + " (userId=" + userId + ")");
        }

        return updated;
    }
}
