package com.clinic.config;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * ServletContextListener — khởi tạo GoogleConfig từ web.xml context-param khi app startup.
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

        // Đọc từ web.xml <context-param>
        String clientId = ctx.getInitParameter("google.client.id");
        String clientSecret = ctx.getInitParameter("google.client.secret");

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
            System.err.println(">>> CANH BAO: Google Sign-In chua duoc cau hinh.");
            System.err.println(">>> Vao Google Cloud Console lay Client ID va dat vao web.xml:");
            System.err.println(">>>   <context-param>");
            System.err.println(">>>     <param-name>google.client.id</param-name>");
            System.err.println(">>>     <param-value>YOUR_CLIENT_ID.apps.googleusercontent.com</param-value>");
            System.err.println(">>>   </context-param>");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        // Cleanup nếu cần
        System.out.println(">>> GoogleConfigListener destroyed.");
    }
}
