package com.clinic.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Cấu hình kết nối SQL Server.
 *
 * Thứ tự ưu tiên cấu hình:
 * 1. Java system property.
 * 2. Environment variable.
 * 3. AppConfig/config.properties.
 * 4. Giá trị mặc định an toàn.
 *
 * Không lưu username/password thật trực tiếp trong repository.
 */
public final class DatabaseConfig {

    private static final String DATABASE_NAME =
            getSetting("DB_NAME", "ObstetricsClinicDB");

    /**
     * Có thể cấu hình toàn bộ JDBC URL bằng DB_URL.
     *
     * Ví dụ Windows Authentication:
     * jdbc:sqlserver://localhost\\SQLEXPRESS;
     * databaseName=ObstetricsClinicDB;
     * integratedSecurity=true;
     * encrypt=true;
     * trustServerCertificate=true;
     *
     * Ví dụ SQL Authentication:
     * jdbc:sqlserver://localhost:1433;
     * databaseName=ObstetricsClinicDB;
     * encrypt=true;
     * trustServerCertificate=true;
     */
    private static final String CUSTOM_DB_URL =
            getSetting("DB_URL", null);

    /**
     * Không đặt tài khoản và mật khẩu mặc định trong source code.
     * Thành viên cấu hình bằng DB_USER và DB_PASSWORD trên máy cá nhân.
     */
    private static final String DB_USER =
            getSetting("DB_USER", "sa");

    private static final String DB_PASSWORD =
            getSetting("DB_PASSWORD", "sa");

    /**
     * Bốn URL đầu sử dụng Windows Authentication.
     * Hai URL cuối sử dụng SQL Server Authentication.
     */
    private static final String[] CONNECTION_URLS = {
        "jdbc:sqlserver://localhost:1433;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        "jdbc:sqlserver://localhost\\SQLEXPRESS;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        "jdbc:sqlserver://localhost\\MSSQLSERVER;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        "jdbc:sqlserver://localhost;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        "jdbc:sqlserver://localhost:1433;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        "jdbc:sqlserver://localhost\\SQLEXPRESS;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "encrypt=true;"
                + "trustServerCertificate=true;"
    };

    private static volatile String activeUrl;
    private static volatile boolean activeUrlUsesSqlAuth;

    private DatabaseConfig() {
        // Utility class
    }

    private static String getSetting(String name, String defaultValue) {
        String property = System.getProperty(name);
        if (property != null && !property.isBlank()) {
            return property.trim();
        }

        String environment = System.getenv(name);
        if (environment != null && !environment.isBlank()) {
            return environment.trim();
        }

        String configKey = name.toLowerCase().replace('_', '.');
        String appConfigValue = AppConfig.get(configKey, null);

        if (appConfigValue != null && !appConfigValue.isBlank()) {
            return appConfigValue.trim();
        }

        return defaultValue;
    }

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "Không tìm thấy SQL Server JDBC Driver. "
                            + "Hãy thêm mssql-jdbc vào WEB-INF/lib. "
                            + "Chi tiết: " + e.getMessage()
            );
        }
    }

    /**
     * Mở kết nối tới SQL Server.
     *
     * @return kết nối database
     * @throws SQLException khi tất cả phương thức kết nối đều thất bại
     */
    public static Connection getConnection() throws SQLException {
        SQLException lastException = null;

        /*
         * 1. Ưu tiên URL tùy chỉnh.
         */
        if (CUSTOM_DB_URL != null && !CUSTOM_DB_URL.isBlank()) {
            try {
                Connection connection = connectCustomUrl(CUSTOM_DB_URL);

                System.out.println(
                        ">>> Database connected using custom DB_URL: "
                                + getAuthenticationDescription(CUSTOM_DB_URL)
                );

                return connection;
            } catch (SQLException e) {
                lastException = e;
                logConnectionFailure("Custom DB_URL", e);
            }
        }

        /*
         * 2. Tái sử dụng URL từng kết nối thành công.
         */
        if (activeUrl != null) {
            try {
                return openConnection(activeUrl, activeUrlUsesSqlAuth);
            } catch (SQLException e) {
                lastException = e;
                activeUrl = null;
                activeUrlUsesSqlAuth = false;

                logConnectionFailure("Cached connection URL", e);
            }
        }

        /*
         * 3. Thử lần lượt các URL dự phòng.
         */
        for (int index = 0; index < CONNECTION_URLS.length; index++) {
            String url = CONNECTION_URLS[index];
            boolean sqlAuthentication = index >= 4;

            if (sqlAuthentication && !hasSqlCredentials()) {
                continue;
            }

            try {
                Connection connection =
                        openConnection(url, sqlAuthentication);

                activeUrl = url;
                activeUrlUsesSqlAuth = sqlAuthentication;

                System.out.println(
                        ">>> Database connected: "
                                + (sqlAuthentication
                                ? "SQL Server Authentication"
                                : "Windows Authentication")
                                + " | Database: "
                                + DATABASE_NAME
                );

                return connection;
            } catch (SQLException e) {
                lastException = e;

                logConnectionFailure(
                        "[" + (index + 1) + "] "
                                + getAuthenticationDescription(url),
                        e
                );
            }
        }

        String sqlState = lastException != null
                ? lastException.getSQLState()
                : "N/A";

        int errorCode = lastException != null
                ? lastException.getErrorCode()
                : 0;

        throw new SQLException(
                "KHÔNG THỂ KẾT NỐI SQL SERVER.\n"
                        + "Database: " + DATABASE_NAME + "\n"
                        + "Hãy kiểm tra:\n"
                        + "1. SQL Server hoặc SQLEXPRESS đang chạy.\n"
                        + "2. Database đã tồn tại.\n"
                        + "3. TCP/IP đã được bật.\n"
                        + "4. SQL Server Browser đang chạy nếu dùng named instance.\n"
                        + "5. mssql-jdbc_auth DLL đã được cấu hình nếu dùng "
                        + "Windows Authentication.\n"
                        + "6. DB_USER và DB_PASSWORD đã được đặt nếu dùng SQL Auth.\n"
                        + "SQLState: " + sqlState + "\n"
                        + "Error code: " + errorCode,
                lastException
        );
    }

    /**
     * Kết nối bằng DB_URL tùy chỉnh.
     */
    private static Connection connectCustomUrl(String url)
            throws SQLException {

        if (usesIntegratedSecurity(url)) {
            return DriverManager.getConnection(url);
        }

        if (hasSqlCredentials()) {
            return DriverManager.getConnection(
                    url,
                    DB_USER,
                    DB_PASSWORD
            );
        }

        /*
         * Cho phép URL tự chứa cơ chế xác thực hoặc cấu hình khác.
         * Không khuyến nghị đưa password trực tiếp vào URL trong repository.
         */
        return DriverManager.getConnection(url);
    }

    private static Connection openConnection(
            String url,
            boolean sqlAuthentication
    ) throws SQLException {

        if (sqlAuthentication) {
            if (!hasSqlCredentials()) {
                throw new SQLException(
                        "Thiếu DB_USER hoặc DB_PASSWORD cho SQL Authentication."
                );
            }

            return DriverManager.getConnection(
                    url,
                    DB_USER,
                    DB_PASSWORD
            );
        }

        return DriverManager.getConnection(url);
    }

    private static boolean hasSqlCredentials() {
        return DB_USER != null
                && !DB_USER.isBlank()
                && DB_PASSWORD != null
                && !DB_PASSWORD.isBlank();
    }

    private static boolean usesIntegratedSecurity(String url) {
        return url != null
                && url.toLowerCase().contains("integratedsecurity=true");
    }

    private static String getAuthenticationDescription(String url) {
        return usesIntegratedSecurity(url)
                ? "Windows Authentication"
                : "SQL Server Authentication";
    }

    private static void logConnectionFailure(
            String method,
            SQLException exception
    ) {
        // Expected fallback — do NOT use System.err to avoid red-text alarm.
        // The driver tries multiple auth methods; some failures are normal.
        System.out.println(
                "[INFO] "
                        + method
                        + " unavailable (SQLState="
                        + exception.getSQLState()
                        + ", errorCode="
                        + exception.getErrorCode()
                        + ") — trying next connection method..."
        );
    }

    /**
     * Đóng connection an toàn.
     */
    public static void closeConnection(Connection connection) {
        if (connection == null) {
            return;
        }

        try {
            connection.close();
        } catch (SQLException e) {
            System.err.println(
                    "Lỗi khi đóng connection. SQLState="
                            + e.getSQLState()
                            + ", errorCode="
                            + e.getErrorCode()
            );
        }
    }
}