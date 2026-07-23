package com.clinic.service;

import com.clinic.config.GoogleConfig;
import com.clinic.dao.UserDAO;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

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

        // Bước 1: Tìm user theo google_id
        User user = userDAO.findByGoogleId(googleId);
        if (user != null) {
            // Đã từng đăng nhập bằng Google → kiểm tra trạng thái tài khoản
            checkAccountStatus(user);
            clearSensitiveData(user);
            System.out.println(">>> Google login: existing Google user - " + user.getEmail()
                    + " (id=" + user.getId() + ")");
            return user;
        }

        // Bước 2: Tìm user theo email (có thể đã đăng ký bằng form local)
        user = userDAO.findByEmail(email);
        if (user != null) {
            // Email đã tồn tại → liên kết Google ID với tài khoản này
            userDAO.updateGoogleId(user.getId(), googleId);
            user.setGoogleId(googleId);
            user.setAuthProvider("google");
            checkAccountStatus(user);
            clearSensitiveData(user);
            System.out.println(">>> Google login: linked Google ID to existing user - " + user.getEmail()
                    + " (id=" + user.getId() + ")");
            return user;
        }

        // Bước 3: Không tìm thấy → tạo user mới với role Patient
        User newUser = new User();
        newUser.setFullName(name != null ? name : "Google User");
        newUser.setEmail(email);
        newUser.setPasswordHash(null);          // Google user không có mật khẩu
        newUser.setPhone(null);
        newUser.setRoleId(AuthService.ROLE_PATIENT);
        newUser.setStatus(UserStatus.ACTIVE.getValue());
        newUser.setVerified(true);              // Google đã xác thực email
        newUser.setVerificationToken(null);
        newUser.setGoogleId(googleId);
        newUser.setUsername(email);
        newUser.setAuthProvider("google");

        int generatedId = userDAO.insert(newUser);
        newUser.setId(generatedId);
        clearSensitiveData(newUser);
        System.out.println(">>> Google login: created new user - " + newUser.getEmail()
                + " (id=" + newUser.getId() + ", role=Patient)");
        return newUser;
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
        // Google user không cần kiểm tra PENDING_VERIFICATION vì email đã được Google xác thực
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
