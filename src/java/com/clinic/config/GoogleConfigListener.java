package com.clinic.config;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * ServletContextListener — khởi tạo GoogleConfig từ cấu hình runtime khi app startup.
 *
 * Đọc các tham số:
 *   - google.client.id      → GoogleConfig.setClientId()
 *   - google.client.secret  → GoogleConfig.setClientSecret()
 *
 * Đặt vào application scope để JSP có thể truy cập:
 *   - googleClientId
 *   - googleClientSecret
 */
@WebListener
public class GoogleConfigListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext ctx = event.getServletContext();

        // Ưu tiên cấu hình ngoài source; context-param chỉ là fallback dành
        // cho môi trường local và phải để placeholder trong repository.
        String clientId = firstConfigured(
                System.getProperty("google.client.id"),
                System.getenv("GOOGLE_CLIENT_ID"),
                AppConfig.get("google.client.id", null),
                ctx.getInitParameter("google.client.id"),
                "YOUR_GOOGLE_CLIENT_ID");
        String clientSecret = firstConfigured(
                System.getProperty("google.client.secret"),
                System.getenv("GOOGLE_CLIENT_SECRET"),
                AppConfig.get("google.client.secret", null),
                ctx.getInitParameter("google.client.secret"),
                "YOUR_GOOGLE_CLIENT_SECRET");

        // Set vào GoogleConfig
        GoogleConfig.setClientId(clientId);
        GoogleConfig.setClientSecret(clientSecret);

        // Đặt vào application scope để JSP dùng
        ctx.setAttribute("googleClientId", GoogleConfig.getClientId());
        ctx.setAttribute("googleConfigured", GoogleConfig.isConfigured());
        ctx.setAttribute("googleServerSideConfigured", GoogleConfig.isServerSideConfigured());

        // Log
        System.out.println("==================================================");
        System.out.println(">>> GoogleConfigListener initialized");
        System.out.println(">>> Google Client ID    : "
                + (GoogleConfig.isConfigured() ? GoogleConfig.getClientId() : "CHUA CAU HINH"));
        System.out.println(">>> Server-side flow    : "
                + (GoogleConfig.isServerSideConfigured() ? "ENABLED" : "disabled (thieu Client Secret)"));
        System.out.println("==================================================");

        if (!GoogleConfig.isConfigured()) {
            System.out.println(">>> CANH BAO: Google Sign-In chua duoc cau hinh.");
            System.out.println(">>> Cach cau hinh (chon 1 trong cac cach sau):");
            System.out.println(">>>   1. File cau hinh ngoai source (KHUYEN NGHI - an toan khi merge code):");
            System.out.println(">>>      Them vao " + System.getProperty("user.home") + "\\.ocss\\config.properties:");
            System.out.println(">>>        google.client.id=YOUR_CLIENT_ID.apps.googleusercontent.com");
            System.out.println(">>>        google.client.secret=GOCSPX-YOUR_CLIENT_SECRET");
            System.out.println(">>>   2. Bien moi truong: GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET");
            System.out.println(">>>   3. JVM property: -Dgoogle.client.id=... -Dgoogle.client.secret=...");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        // Cleanup nếu cần
        System.out.println(">>> GoogleConfigListener destroyed.");
    }

    private String firstConfigured(String systemValue, String environmentValue,
                                   String externalConfigValue, String contextValue,
                                   String placeholderPrefix) {
        for (String value : new String[]{
                systemValue, environmentValue, externalConfigValue, contextValue}) {
            if (value != null && !value.isBlank()
                    && !value.trim().startsWith(placeholderPrefix)) {
                return value.trim();
            }
        }
        return null;
    }
}
