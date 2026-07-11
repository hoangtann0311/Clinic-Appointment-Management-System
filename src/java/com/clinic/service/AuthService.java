package com.clinic.service;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;
import com.clinic.utils.BCryptUtil;
import com.clinic.utils.EmailUtil;
import com.clinic.utils.ValidationUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;
import java.util.UUID;

/**
 * Service xử lý nghiệp vụ xác thực: đăng ký, đăng nhập.
 * Validate input tại Service layer theo kiến trúc chuẩn.
 */
public class AuthService {

    // Role ID cho Patient (theo seed data trong script1.sql)
    public static final int ROLE_PATIENT = 5;

    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Đăng ký tài khoản mới với role Patient.
     * Flow: validate input → kiểm tra email tồn tại → kiểm tra phone tồn tại
     *       → hash password → tạo token xác thực
     *       → insert user (PENDING_VERIFICATION) → gửi email xác thực
     *
     * @param fullName        họ tên người dùng
     * @param email           email đăng ký
     * @param password        mật khẩu
     * @param confirmPassword xác nhận mật khẩu
     * @param phone           số điện thoại
     * @param errors          Map để chứa lỗi nếu có
     * @return User đã tạo nếu thành công, null nếu thất bại
     */
    public User register(String fullName, String email, String password,
                         String confirmPassword, String phone, String terms,
                         Map<String, String> errors) {

        // Bước 1: Validate input
        Map<String, String> validationErrors = ValidationUtil.validateRegistration(
                fullName, email, password, confirmPassword, phone, terms);

        if (!validationErrors.isEmpty()) {
            errors.putAll(validationErrors);
            return null;
        }

        // Trim các giá trị
        fullName = fullName.trim();
        email = email.trim().toLowerCase();
        if (phone != null) {
            phone = phone.trim();
        }

        // Bước 2: Kiểm tra email đã tồn tại chưa
        User existingUser = userDAO.findByEmail(email);
        if (existingUser != null) {
            errors.put("email", "Email này đã được đăng ký. Vui lòng sử dụng email khác.");
            return null;
        }

        // Bước 3: Kiểm tra số điện thoại đã tồn tại chưa
        User existingPhone = userDAO.findByPhone(phone);
        if (existingPhone != null) {
            errors.put("phone", "Số điện thoại này đã được đăng ký. Vui lòng sử dụng số khác.");
            return null;
        }

        // Bước 4: Hash mật khẩu với BCrypt
        String passwordHash = BCryptUtil.hashPassword(password);

        // Bước 4.5: Tạo username từ email (phần trước @)
        // Nếu username đã tồn tại, thêm hậu tố số (VD: ten.ten → ten.ten1)
        String baseUsername = email.substring(0, email.indexOf('@'));
        String generatedUsername = baseUsername;
        int suffix = 1;
        while (userDAO.findByUsername(generatedUsername.toLowerCase()) != null) {
            generatedUsername = baseUsername + suffix;
            suffix++;
        }

        // Bước 5: Tạo verification token (UUID ngẫu nhiên)
        String verificationToken = UUID.randomUUID().toString();

        // Bước 6: Tạo User entity với trạng thái PENDING_VERIFICATION
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setUsername(generatedUsername);  // Username tự động từ email
        newUser.setPasswordHash(passwordHash);
        newUser.setPhone(phone);
        newUser.setRoleId(ROLE_PATIENT);         // Luôn là Patient khi tự đăng ký
        newUser.setStatus(UserStatus.PENDING_VERIFICATION.getValue());
        newUser.setVerificationToken(verificationToken);
        newUser.setVerified(false);
        newUser.setUsername(email);
        newUser.setAuthProvider("local");  // Đăng ký thường = local, không phải Google OAuth

        System.out.println("[AuthService] register: fullName=" + fullName
                + ", email=" + email + ", roleId=" + ROLE_PATIENT);

        // Bước 7: Insert vào database
        int generatedId = userDAO.insert(newUser);
        newUser.setId(generatedId);

        System.out.println("[AuthService] register SUCCESS: id=" + generatedId
                + ", username=" + generatedUsername + ", roleId=" + ROLE_PATIENT);

        // ── Tự động tạo record trong bảng patients ──
        insertPatientRecord(generatedId, fullName, phone);

        // Bước 8: Gửi email xác thực (trong thread riêng, không chặn response)
        // Nếu email chưa được cấu hình, link sẽ được in ra console (dev mode)
        try {
            EmailUtil.sendVerificationEmail(email, fullName, verificationToken);
        } catch (Exception e) {
            // Gửi email thất bại không làm hỏng quá trình đăng ký
            // Link xác thực sẽ được in ra console qua fallback trong EmailUtil
            System.err.println("Cảnh báo: Không gửi được email xác thực đến " + email);
        }

        // Xóa password hash và token trước khi trả về (bảo mật)
        newUser.setPasswordHash(null);
        newUser.setVerificationToken(null);

        return newUser;
    }

    /**
     * Đăng nhập: xác thực email và mật khẩu, kiểm tra trạng thái tài khoản.
     *
     * @param email    email đăng nhập
     * @param password mật khẩu
     * @param errors   Map để chứa lỗi nếu có
     * @return User nếu đăng nhập thành công, null nếu thất bại
     */
    public User login(String email, String password, Map<String, String> errors) {

        // Bước 1: Validate input không rỗng
        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Vui lòng nhập email.");
            return null;
        }
        if (password == null || password.isEmpty()) {
            errors.put("password", "Vui lòng nhập mật khẩu.");
            return null;
        }

        email = email.trim().toLowerCase();

        // Bước 2: Kiểm tra định dạng email
        if (!ValidationUtil.isValidEmail(email)) {
            errors.put("email", "Email không đúng định dạng.");
            return null;
        }

        // Bước 3: Tìm user theo email
        User user = userDAO.findByEmail(email);
        if (user == null) {
            errors.put("login", "Email hoặc mật khẩu không chính xác.");
            return null;
        }

        // Bước 4: Kiểm tra trạng thái tài khoản
        if (UserStatus.LOCKED.getValue().equalsIgnoreCase(user.getStatus())) {
            errors.put("login", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
            return null;
        }
        if (UserStatus.INACTIVE.getValue().equalsIgnoreCase(user.getStatus())) {
            errors.put("login", "Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.");
            return null;
        }
        if (UserStatus.PENDING_VERIFICATION.getValue().equalsIgnoreCase(user.getStatus())) {
            errors.put("login", "Tài khoản chưa được xác thực. Vui lòng kiểm tra email để xác thực tài khoản.");
            return null;
        }

        // Bước 5: Kiểm tra mật khẩu với BCrypt
        if (!BCryptUtil.checkPassword(password, user.getPasswordHash())) {
            errors.put("login", "Email hoặc mật khẩu không chính xác.");
            return null;
        }

        // Bước 6: Xóa password hash trước khi trả về (bảo mật)
        user.setPasswordHash(null);
        user.setVerificationToken(null);

        return user;
    }

    /**
     * Đăng nhập bằng Google OAuth: xác thực token, tìm hoặc tạo user.
     * Flow được ủy thác hoàn toàn cho GoogleAuthService.
     *
     * @param googleInfo thông tin user đã xác thực từ Google tokeninfo
     * @param errors     Map để chứa lỗi nếu có
     * @return User nếu đăng nhập thành công, null nếu thất bại
     */
    public User loginWithGoogle(GoogleUserInfo googleInfo, Map<String, String> errors) {
        GoogleAuthService googleAuth = new GoogleAuthService();
        try {
            return googleAuth.loginWithGoogle(googleInfo);
        } catch (GoogleAuthException e) {
            errors.put("googleLogin", e.getMessage());
            System.err.println("Google login failed: " + e.getMessage());
            return null;
        }
    }

    /**
     * Xác thực email cho user bằng verification token.
     *
     * @param token verification token từ link email
     * @return User đã xác thực nếu thành công, null nếu token không hợp lệ
     */
    public User verifyEmail(String token) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }

        User user = userDAO.findByVerificationToken(token.trim());
        if (user == null) {
            return null; // Token không tồn tại hoặc đã được sử dụng
        }

        // Cập nhật trạng thái user: đánh dấu đã xác thực
        boolean updated = userDAO.verifyUser(user.getId());
        if (updated) {
            user.setVerified(true);
            user.setStatus(UserStatus.ACTIVE.getValue());
            user.setVerificationToken(null);
            return user;
        }

        return null;
    }

    // ═══════════════════════════════════════════════════════════
    // PATIENT TABLE AUTO-INSERT
    // ═══════════════════════════════════════════════════════════

    /**
     * Tự động tạo record trong bảng patients sau khi đăng ký thành công.
     * Không làm fail registration nếu insert này gặp lỗi.
     */
    private void insertPatientRecord(int userId, String fullName, String phone) {
        String sql = "INSERT INTO patients (user_id, full_name, phone_number) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[AuthService] Đã tạo patient record: userId=" + userId);
            } else {
                System.err.println("[AuthService] CẢNH BÁO: Không tạo được patient record cho userId=" + userId);
            }
        } catch (SQLException e) {
            System.err.println("[AuthService] Lỗi insert patient: " + e.getMessage());
        } finally {
            if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
            DatabaseConfig.closeConnection(conn);
        }
    }
}
