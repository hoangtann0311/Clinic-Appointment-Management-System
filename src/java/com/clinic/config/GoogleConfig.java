package com.clinic.config;

/**
 * Cấu hình Google OAuth 2.0 — runtime config không chứa credential trong source.
 *
 * Giá trị được khởi tạo bởi GoogleConfigListener (ServletContextListener)
 * khi ứng dụng startup. Mỗi môi trường tự cấu hình Client ID/Secret bằng
 * system property hoặc biến môi trường.
 *
 * Fallback: nếu không có listener, đọc từ System property:
 *   -Dgoogle.client.id=xxx.apps.googleusercontent.com
 *   -Dgoogle.client.secret=GOCSPX-xxx
 */
public class GoogleConfig {

    // === Google API Endpoints (không thay đổi) ===
    public static final String TOKEN_INFO_URL    = "https://oauth2.googleapis.com/tokeninfo";
    public static final String TOKEN_ENDPOINT    = "https://oauth2.googleapis.com/token";
    public static final String AUTH_ENDPOINT     = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String GOOGLE_ISSUER     = "https://accounts.google.com";
    public static final String CERTS_URL         = "https://www.googleapis.com/oauth2/v3/certs";

    // === Runtime values (set by GoogleConfigListener or System properties) ===
    private static String clientId;
    private static String clientSecret;

    static {
        // Fallback: đọc từ System property nếu listener chưa chạy
        clientId = System.getProperty("google.client.id");
        clientSecret = System.getProperty("google.client.secret");
    }

    private GoogleConfig() {}

    // === Setters (gọi bởi GoogleConfigListener) ===
    public static void setClientId(String id) {
        clientId = (id != null) ? id.trim() : null;
    }

    public static void setClientSecret(String secret) {
        clientSecret = (secret != null) ? secret.trim() : null;
    }

    // === Getters ===
    public static String getClientId() {
        return clientId;
    }

    public static String getClientSecret() {
        return clientSecret;
    }

    /**
     * @return true nếu Client ID đã được cấu hình hợp lệ
     */
    public static boolean isConfigured() {
        return clientId != null
                && !clientId.isEmpty()
                && !clientId.startsWith("YOUR_GOOGLE_CLIENT_ID");
    }

    /**
     * @return true nếu Client Secret đã được cấu hình (cho server-side flow)
     */
    public static boolean isServerSideConfigured() {
        return isConfigured()
                && clientSecret != null
                && !clientSecret.isEmpty()
                && !clientSecret.startsWith("YOUR_GOOGLE_CLIENT_SECRET");
    }
}
