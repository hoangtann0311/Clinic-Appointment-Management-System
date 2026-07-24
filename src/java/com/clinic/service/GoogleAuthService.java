package com.clinic.service;

import com.clinic.config.GoogleConfig;
import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;
import com.clinic.utils.EmailUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Service xử lý đăng nhập bằng Google OAuth 2.0.
 *
 * Flow:
 * 1. Frontend gửi Google ID token (credential) lên backend
 * 2. Backend gọi Google tokeninfo API để xác thực token
 * 3. Trích xuất thông tin user (googleId, email, name, picture)
 * 4. Tìm user trong DB theo googleId hoặc email
 * 5. Nếu chưa có → tạo user mới với auth_provider='google'
 * 6. Nếu email đã tồn tại → liên kết googleId với user hiện có
 */
public class GoogleAuthService {

    private final UserDAO userDAO;

    public GoogleAuthService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Xác thực Google ID token bằng Google Token Info API.
     * Endpoint: https://oauth2.googleapis.com/tokeninfo?id_token=TOKEN
     *
     * @param idToken Google ID token (JWT) từ frontend
     * @return GoogleUserInfo nếu token hợp lệ
     * @throws GoogleAuthException nếu token không hợp lệ hoặc có lỗi mạng
     */
    public GoogleUserInfo verifyGoogleToken(String idToken) throws GoogleAuthException {
        if (idToken == null || idToken.trim().isEmpty()) {
            throw new GoogleAuthException("Token đăng nhập Google không được để trống.");
        }

        HttpURLConnection conn = null;
        try {
            // Gọi Google tokeninfo endpoint
            String tokenInfoUrl = GoogleConfig.TOKEN_INFO_URL + "?id_token=" + idToken;
            URL url = new URL(tokenInfoUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                throw new GoogleAuthException("Token Google không hợp lệ hoặc đã hết hạn.");
            }

            // Đọc response JSON
            StringBuilder response = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }

            // Parse JSON thủ công (không cần thư viện JSON)
            String jsonStr = response.toString();
            Map<String, String> tokenInfo = parseSimpleJson(jsonStr);

            // Kiểm tra lỗi từ Google
            String error = tokenInfo.get("error");
            if (error != null) {
                String errorDesc = tokenInfo.getOrDefault("error_description", error);
                throw new GoogleAuthException("Lỗi xác thực Google: " + errorDesc);
            }

            // Trích xuất thông tin
            String googleId = tokenInfo.get("sub");       // Google user ID
            String email = tokenInfo.get("email");
            String name = tokenInfo.get("name");
            String picture = tokenInfo.get("picture");
            String emailVerified = tokenInfo.get("email_verified");
            String audience = tokenInfo.get("aud");        // Client ID
            String issuer = tokenInfo.get("iss");
            String expiresIn = tokenInfo.get("exp");

            // Validate các trường bắt buộc
            if (googleId == null || email == null) {
                throw new GoogleAuthException("Không thể trích xuất thông tin người dùng từ token Google.");
            }

            // Kiểm tra email đã được Google xác thực
            if (!"true".equals(emailVerified)) {
                throw new GoogleAuthException(
                        "Email Google của bạn chưa được xác thực. Vui lòng xác thực email trước khi đăng nhập.");
            }

            // Kiểm tra issuer
            if (issuer != null && !GoogleConfig.GOOGLE_ISSUER.equals(issuer)
                    && !"accounts.google.com".equals(issuer)) {
                throw new GoogleAuthException("Token Google không hợp lệ (sai issuer).");
            }

            // Kiểm tra audience (Client ID) - chỉ kiểm tra nếu đã cấu hình
            if (GoogleConfig.isConfigured() && !GoogleConfig.getClientId().equals(audience)) {
                System.err.println("Cảnh báo: Token audience không khớp với GOOGLE_CLIENT_ID.");
                System.err.println("  Expected: " + GoogleConfig.getClientId());
                System.err.println("  Got: " + audience);
            }

            return new GoogleUserInfo(googleId, email, name, picture);

        } catch (IOException e) {
            throw new GoogleAuthException("Lỗi kết nối đến máy chủ Google: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * Server-side flow: Đổi authorization code lấy ID token từ Google.
     * Dùng khi frontend không thể dùng Google Identity Services (GIS).
     *
     * Flow:
     * 1. User click link → redirect đến Google OAuth authorization endpoint
     * 2. User approve → Google redirect về /google-login-server?code=xxx
     * 3. Servlet gọi method này để đổi code lấy token
     *
     * @param code        authorization code từ Google
     * @param redirectUri redirect URI đã dùng khi gọi authorization endpoint
     * @return GoogleUserInfo nếu thành công
     * @throws GoogleAuthException nếu thất bại
     */
    public GoogleUserInfo exchangeAuthCode(String code, String redirectUri) throws GoogleAuthException {
        if (!GoogleConfig.isServerSideConfigured()) {
            throw new GoogleAuthException(
                    "Server-side Google login chưa được cấu hình trên máy chủ.");
        }

        HttpURLConnection conn = null;
        try {
            // Gọi Google token endpoint để đổi code lấy token
            URL url = new URL(GoogleConfig.TOKEN_ENDPOINT);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");

            // Build POST body
            String body = "code=" + URLEncoder.encode(code, "UTF-8")
                    + "&client_id=" + URLEncoder.encode(GoogleConfig.getClientId(), "UTF-8")
                    + "&client_secret=" + URLEncoder.encode(GoogleConfig.getClientSecret(), "UTF-8")
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8")
                    + "&grant_type=authorization_code";

            try (OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream(), "UTF-8")) {
                writer.write(body);
                writer.flush();
            }

            int responseCode = conn.getResponseCode();
            StringBuilder response = new StringBuilder();

            if (responseCode == 200) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                }
            } else {
                // Đọc lỗi
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream(), "UTF-8"))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                }
            }

            Map<String, String> tokenResponse = parseSimpleJson(response.toString());

            if (responseCode != 200) {
                String error = tokenResponse.getOrDefault("error", "unknown_error");
                String errorDesc = tokenResponse.getOrDefault("error_description", error);
                throw new GoogleAuthException("Lỗi đổi code lấy token: " + errorDesc);
            }

            // Lấy id_token từ response
            String idToken = tokenResponse.get("id_token");
            if (idToken == null) {
                throw new GoogleAuthException("Không nhận được ID token từ Google.");
            }

            // Xác thực id_token
            return verifyGoogleToken(idToken);

        } catch (IOException e) {
            throw new GoogleAuthException("Lỗi kết nối đến máy chủ Google: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * Tạo URL authorization để bắt đầu server-side OAuth flow.
     *
     * @param redirectUri URL callback (phải khớp với Authorized redirect URIs trong Google Cloud Console)
     * @return URL để redirect user đến Google login
     */
    public static String buildAuthorizationUrl(String redirectUri) {
        return GoogleConfig.AUTH_ENDPOINT
                + "?client_id=" + java.net.URLEncoder.encode(GoogleConfig.getClientId(), java.nio.charset.StandardCharsets.UTF_8)
                + "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&scope=" + java.net.URLEncoder.encode("openid email profile", java.nio.charset.StandardCharsets.UTF_8)
                + "&access_type=online"
                + "&prompt=select_account";
    }

    /**
     * Đăng nhập bằng Google: tìm user theo googleId hoặc email,
     * liên kết nếu cần, hoặc tạo user mới.
     *
     * @param googleInfo thông tin user từ Google (đã xác thực)
     * @return User đã đăng nhập hoặc mới tạo
     */
    public User loginWithGoogle(GoogleUserInfo googleInfo) throws GoogleAuthException {
        String googleId = googleInfo.getGoogleId();
        String email = googleInfo.getEmail();
        String name = googleInfo.getName();

        // Luôn resolve bằng cả 2 cách: email và googleId.
        // findByEmail có ORDER BY ưu tiên Active → tránh tình trạng
        // googleId gắn với tk cũ/Inactive/Patient mà email lại có tk Manager Active.
        User emailUser = userDAO.findByEmail(email);
        User googleUser = userDAO.findByGoogleId(googleId);

        // Hợp nhất: nếu cả 2 cùng tồn tại nhưng khác user, merge về user "tốt nhất"
        User resolvedUser = resolveBestUser(emailUser, googleUser, email, googleId);

        if (resolvedUser != null) {
            // Nếu INACTIVE: Google đã xác thực danh tính → tự động kích hoạt lại
            if (UserStatus.INACTIVE.getValue().equalsIgnoreCase(resolvedUser.getStatus())) {
                reactivateUser(resolvedUser);
            } else {
                checkAccountStatus(resolvedUser);
            }
            clearSensitiveData(resolvedUser);
            System.out.println(">>> Google login: resolved user - " + resolvedUser.getEmail()
                    + " (id=" + resolvedUser.getId()
                    + ", role=" + resolvedUser.getRoleId()
                    + ", status=" + resolvedUser.getStatus() + ")");
            return resolvedUser;
        }

        // Bước 3: Tài khoản Google lần đầu — tạo user với trạng thái PENDING_VERIFICATION.
        // Gửi email xác nhận. Người dùng phải click link trong email để kích hoạt,
        // sau đó mới có thể đăng nhập bằng Google và vào hệ thống.
        String verificationToken = UUID.randomUUID().toString();

        User newUser = new User();
        newUser.setFullName(name != null ? name : "Google User");
        newUser.setEmail(email);
        newUser.setPasswordHash(null);          // Google user không có mật khẩu
        newUser.setPhone(null);
        newUser.setRoleId(AuthService.ROLE_PATIENT);
        newUser.setStatus(UserStatus.PENDING_VERIFICATION.getValue());
        newUser.setVerified(false);             // Cần xác nhận email trước
        newUser.setVerificationToken(verificationToken);
        newUser.setGoogleId(googleId);
        newUser.setUsername(email);
        newUser.setAuthProvider("google");

        int generatedId = userDAO.insert(newUser);
        newUser.setId(generatedId);
        System.out.println(">>> Google login: created pending user - " + newUser.getEmail()
                + " (id=" + newUser.getId() + ", status=PENDING_VERIFICATION)");

        // Gửi email xác nhận đăng ký Google (đồng bộ để bắt lỗi ngay)
        String verificationLink = "http://localhost:8080/ClinicAppointmentManagementSystem"
                + "/verify-email?token=" + verificationToken;
        String emailError = null;
        try {
            EmailUtil.sendGoogleConfirmationSync(email,
                    name != null ? name : "Google User", verificationToken);
            System.out.println(">>> Google login: verification email SENT to " + email);
        } catch (Exception e) {
            emailError = e.getMessage();
            System.err.println(">>> Google login: FAILED to send email to " + email
                    + " - " + emailError);
            e.printStackTrace(System.err);
        }

        // Thông báo cho người dùng (kèm link nếu email không gửi được)
        String message = "Tài khoản Google của bạn cần xác nhận email trước khi đăng nhập. ";
        if (emailError != null) {
            message += "Hệ thống không gửi được email xác nhận (" + emailError + "). "
                    + "Vui lòng dùng link sau để xác nhận: " + verificationLink;
        } else {
            message += "Một email xác nhận đã được gửi đến " + email
                    + ". Vui lòng kiểm tra hộp thư (cả Spam) và nhấp vào link để kích hoạt tài khoản. "
                    + "Sau khi xác nhận, hãy đăng nhập lại bằng Google.";
        }
        throw new GoogleAuthException(message);
    }

    /**
     * Chọn user tốt nhất khi có nhiều tài khoản cùng email.
     * Ưu tiên: Active > Pending > Inactive/Locked.
     * Nếu cùng trạng thái: emailUser được ưu tiên (vì findByEmail đã ORDER BY).
     * Merge googleId về user thắng cuộc nếu cần.
     */
    private User resolveBestUser(User emailUser, User googleUser,
                                  String email, String googleId) {
        // Chỉ có 1 user hoặc không có user nào
        if (emailUser == null && googleUser == null) return null;
        if (emailUser == null) return googleUser;
        if (googleUser == null) {
            // Email user tồn tại, chưa có googleId → liên kết
            linkGoogleId(emailUser, googleId);
            return emailUser;
        }

        // Cả 2 cùng tồn tại và là cùng 1 user
        if (emailUser.getId() == googleUser.getId()) return emailUser;

        // 2 user khác nhau cùng email → chọn user tốt nhất
        int emailScore = statusScore(emailUser.getStatus());
        int googleScore = statusScore(googleUser.getStatus());

        System.out.println(">>> Google login: duplicate email " + email
                + " — emailUser(id=" + emailUser.getId() + ", status=" + emailUser.getStatus()
                + ", score=" + emailScore + ")"
                + " vs googleUser(id=" + googleUser.getId() + ", status=" + googleUser.getStatus()
                + ", score=" + googleScore + ")");

        if (emailScore <= googleScore) {
            // emailUser tốt hơn hoặc bằng → merge googleId về emailUser
            linkGoogleId(emailUser, googleId);
            System.out.println(">>> Google login: chose emailUser id=" + emailUser.getId());
            return emailUser;
        } else {
            // googleUser tốt hơn → dùng googleUser
            System.out.println(">>> Google login: chose googleUser id=" + googleUser.getId());
            return googleUser;
        }
    }

    /** Điểm trạng thái: càng thấp càng tốt. */
    private int statusScore(String status) {
        if (UserStatus.ACTIVE.getValue().equalsIgnoreCase(status)) return 0;
        if (UserStatus.PENDING_VERIFICATION.getValue().equalsIgnoreCase(status)) return 1;
        return 2; // INACTIVE, LOCKED, etc.
    }

    /** Liên kết googleId với user + cập nhật auth_provider. */
    private void linkGoogleId(User user, String googleId) {
        if (googleId == null || googleId.isEmpty()) return;
        if (googleId.equals(user.getGoogleId())) return; // đã liên kết
        userDAO.updateGoogleId(user.getId(), googleId);
        user.setGoogleId(googleId);
        user.setAuthProvider("google");
        System.out.println(">>> Google login: linked googleId to user id=" + user.getId());
    }

    /**
     * Kích hoạt lại tài khoản INACTIVE khi người dùng đăng nhập qua Google.
     * Google đã xác thực danh tính → đủ tin cậy để mở lại tài khoản.
     */
    private void reactivateUser(User user) {
        userDAO.updateStatus(user.getId(), UserStatus.ACTIVE.getValue());
        user.setStatus(UserStatus.ACTIVE.getValue());
        System.out.println(">>> Google login: reactivated INACTIVE account - " + user.getEmail()
                + " (id=" + user.getId() + ")");
    }

    /**
     * Kiểm tra trạng thái tài khoản trước khi cho phép đăng nhập.
     */
    private void checkAccountStatus(User user) throws GoogleAuthException {
        if (UserStatus.LOCKED.getValue().equalsIgnoreCase(user.getStatus())) {
            throw new GoogleAuthException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
        }
        if (UserStatus.INACTIVE.getValue().equalsIgnoreCase(user.getStatus())) {
            throw new GoogleAuthException("Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.");
        }
        if (UserStatus.PENDING_VERIFICATION.getValue().equalsIgnoreCase(user.getStatus())) {
            // Tài khoản Google đang chờ xác nhận email → gửi lại email xác nhận
            String token = user.getVerificationToken();
            if (token == null || token.isEmpty()) {
                token = UUID.randomUUID().toString();
                user.setVerificationToken(token);
                updateVerificationToken(user.getId(), token);
            }
            String verifyLink = "http://localhost:8080/ClinicAppointmentManagementSystem"
                    + "/verify-email?token=" + token;
            String emailError = null;
            try {
                EmailUtil.sendGoogleConfirmationSync(
                        user.getEmail(), user.getFullName(), token);
            } catch (Exception e) {
                emailError = e.getMessage();
                System.err.println(">>> Google login: FAILED to resend email - " + e.getMessage());
            }
            String message = "Tài khoản Google của bạn đang chờ xác nhận. ";
            if (emailError != null) {
                message += "Không gửi được email (" + emailError + "). "
                        + "Dùng link sau để xác nhận: " + verifyLink;
            } else {
                message += "Một email xác nhận mới đã được gửi đến " + user.getEmail()
                        + ". Vui lòng kiểm tra hộp thư và nhấp vào link để kích hoạt tài khoản.";
            }
            throw new GoogleAuthException(message);
        }
    }

    /**
     * Cập nhật verification token cho user trong DB.
     */
    private void updateVerificationToken(int userId, String token) {
        try {
            java.sql.Connection conn = null;
            java.sql.PreparedStatement ps = null;
            try {
                conn = com.clinic.config.DatabaseConfig.getConnection();
                String sql = "UPDATE users SET verification_token = ? WHERE id = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, token);
                ps.setInt(2, userId);
                ps.executeUpdate();
            } finally {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        } catch (Exception e) {
            System.err.println("[GoogleAuthService] updateVerificationToken error: " + e.getMessage());
        }
    }

    /**
     * Xóa thông tin nhạy cảm trước khi trả về cho controller.
     */
    private void clearSensitiveData(User user) {
        user.setPasswordHash(null);
        user.setVerificationToken(null);
    }

    /**
     * Parse JSON đơn giản bằng cách tách chuỗi.
     * Chỉ dùng cho response từ Google tokeninfo (cấu trúc đơn giản, không lồng).
     *
     * @param json chuỗi JSON
     * @return Map các cặp key-value
     */
    private Map<String, String> parseSimpleJson(String json) {
        Map<String, String> result = new HashMap<>();

        // Loại bỏ dấu ngoặc nhọn bao ngoài
        json = json.trim();
        if (json.startsWith("{")) {
            json = json.substring(1);
        }
        if (json.endsWith("}")) {
            json = json.substring(0, json.length() - 1);
        }

        // Tách các cặp key-value bằng dấu phẩy (xử lý đơn giản)
        // Không xử lý dấu phẩy trong string value (tokeninfo response không có)
        String[] pairs = json.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");

        for (String pair : pairs) {
            pair = pair.trim();
            if (pair.isEmpty()) {
                continue;
            }

            // Tìm dấu : đầu tiên (key: value)
            int colonIndex = pair.indexOf(':');
            if (colonIndex < 0) {
                continue;
            }

            String key = pair.substring(0, colonIndex).trim();
            String value = pair.substring(colonIndex + 1).trim();

            // Bỏ dấu ngoặc kép bao quanh key
            if (key.startsWith("\"") && key.endsWith("\"")) {
                key = key.substring(1, key.length() - 1);
            }

            // Bỏ dấu ngoặc kép bao quanh value (nếu là string)
            if (value.startsWith("\"") && value.endsWith("\"")) {
                value = value.substring(1, value.length() - 1);
            }

            result.put(key, value);
        }

        return result;
    }
}
