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
                System.out.println("[AppConfig] Loaded config.properties from classpath");
            }
        } catch (Exception e) {
            System.err.println("[AppConfig] Error loading config.properties: " + e.getMessage());
        }

        // Hỗ trợ nạp file cấu hình bên ngoài project/WAR thông qua OCSS_CONFIG_FILE hoặc ocss.config.file
        String externalPath = System.getProperty("ocss.config.file");
        if (externalPath == null || externalPath.isBlank()) {
            externalPath = System.getenv("OCSS_CONFIG_FILE");
        }
        if (externalPath != null && !externalPath.isBlank()) {
            java.io.File extFile = new java.io.File(externalPath.trim());
            if (extFile.exists() && extFile.isFile()) {
                try (InputStream extInput = new java.io.FileInputStream(extFile)) {
                    props.load(extInput);
                    System.out.println("[AppConfig] Loaded external configuration file from: " + extFile.getAbsolutePath());
                } catch (Exception e) {
                    System.err.println("[AppConfig] Failed to load external config file: " + e.getMessage());
                }
            }
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
