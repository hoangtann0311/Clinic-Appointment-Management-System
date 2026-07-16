package com.clinic.config;

import java.io.InputStream;
import java.util.Properties;

/**
 * Cấu hình tập trung cho hệ thống (AI Engine, Uploads, v.v.)
 */
public class AppConfig {

    private static final Properties props = new Properties();

    static {
        try (InputStream input = AppConfig.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input != null) {
                props.load(input);
                System.out.println("[AppConfig] Đã tải thành công file config.properties");
            } else {
                System.err.println("[AppConfig] Không tìm thấy file config.properties, sử dụng cấu hình mặc định");
            }
        } catch (Exception e) {
            System.err.println("[AppConfig] Lỗi khi load file config.properties: " + e.getMessage());
        }
    }

    private AppConfig() {
    }

    public static String get(String key, String defaultValue) {
        String val = props.getProperty(key);
        return (val != null) ? val.trim() : defaultValue;
    }

    public static int getInt(String key, int defaultValue) {
        String val = props.getProperty(key);
        if (val == null) return defaultValue;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static long getLong(String key, long defaultValue) {
        String val = props.getProperty(key);
        if (val == null) return defaultValue;
        try {
            return Long.parseLong(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    // AI Engine settings
    public static String getAiBaseUrl() {
        return get("ai.engine.baseUrl", "http://localhost:8080/ClinicAppointmentManagementSystem/mock-ai-engine");
    }

    public static String getAiAnalyzePath() {
        return get("ai.engine.analyzePath", "");
    }

    public static int getAiConnectTimeout() {
        return getInt("ai.engine.connectTimeout", 5000);
    }

    public static int getAiReadTimeout() {
        return getInt("ai.engine.readTimeout", 30000);
    }

    // Upload settings
    public static String getUploadDirectory() {
        return get("ultrasound.uploadDirectory", "uploads/ultrasound");
    }

    public static long getMaxFileSize() {
        return getLong("ultrasound.maxFileSize", 10485760L); // 10MB
    }

    // Avatar upload settings (dùng cho hồ sơ Bác sĩ, có thể tái sử dụng cho vai trò khác sau này)
    public static String getAvatarUploadDirectory() {
        return get("avatar.uploadDirectory", "uploads/avatars");
    }

    public static long getMaxAvatarFileSize() {
        return getLong("avatar.maxFileSize", 5242880L); // 5MB
    }
}