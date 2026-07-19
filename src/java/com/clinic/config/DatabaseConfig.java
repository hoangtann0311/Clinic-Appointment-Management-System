package com.clinic.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Cấu hình kết nối SQL Server Database.
 * Tự động thử nhiều phương thức kết nối để tìm cấu hình hoạt động.
 * <p>
 * Các kiểu kết nối được thử:
 * 1. Windows Auth - Default instance (localhost:1433)
 * 2. Windows Auth - Named instance SQLEXPRESS
 * 3. Windows Auth - Named instance MSSQLSERVER
 * 4. SQL Auth (sa) - Default instance
 * 5. SQL Auth (sa) - Named instance SQLEXPRESS
 */
public class DatabaseConfig {

    // Shared team database export is named ObstetricsClinicDB. Developers can
    // override this locally with DB_NAME=ObstetricsClinicDB_Merge_Test.
    private static final String DATABASE_NAME = getSetting("DB_NAME", "ObstetricsClinicDB");

    // SQL Server Authentication credentials (chỉ dùng khi Windows Auth thất bại)
    private static final String DB_USER = getSetting("DB_USER", "sa");
    // Keep the repository password-free. Each member sets only this fallback locally,
    // or supplies DB_PASSWORD as an environment variable.
    private static final String DB_PASSWORD = getSetting("DB_PASSWORD", "");

    // Danh sách các URL kết nối sẽ thử lần lượt
    private static final String[] CONNECTION_URLS = {
        // Windows Authentication - Default instance port 1433
        "jdbc:sqlserver://localhost:1433;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        // Windows Authentication - Named instance SQLEXPRESS
        "jdbc:sqlserver://localhost\\SQLEXPRESS;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        // Windows Authentication - Named instance MSSQLSERVER
        "jdbc:sqlserver://localhost\\MSSQLSERVER;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        // Windows Auth - Không chỉ định port (tự động)
        "jdbc:sqlserver://localhost;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "integratedSecurity=true;"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        // SQL Server Authentication - Default instance
        "jdbc:sqlserver://localhost:1433;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "encrypt=true;"
                + "trustServerCertificate=true;",

        // SQL Server Authentication - Named instance SQLEXPRESS
        "jdbc:sqlserver://localhost\\SQLEXPRESS;"
                + "databaseName=" + DATABASE_NAME + ";"
                + "encrypt=true;"
                + "trustServerCertificate=true;",
    };

    private static String activeUrl = null;
    private static boolean useSqlAuth = false;

    private static String getSetting(String name, String defaultValue) {
        String property = System.getProperty(name);
        if (property != null && !property.isBlank()) {
            return property;
        }
        String environment = System.getenv(name);
        return environment != null && !environment.isBlank() ? environment : defaultValue;
    }

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy SQL Server JDBC Driver. "
                    + "Hãy thêm mssql-jdbc vào WEB-INF/lib.", e);
        }
    }

    /**
     * Lấy connection đến database. Tự động thử các URL cho đến khi kết nối thành công.
     *
     * @return Connection object
     * @throws SQLException nếu tất cả các cách kết nối đều thất bại
     */
    public static Connection getConnection() throws SQLException {
        // Nếu đã biết URL hoạt động, dùng lại luôn
        if (activeUrl != null) {
            try {
                if (useSqlAuth) {
                    return DriverManager.getConnection(activeUrl, DB_USER, DB_PASSWORD);
                }
                return DriverManager.getConnection(activeUrl);
            } catch (SQLException e) {
                // URL cũ không hoạt động nữa, reset để thử lại
                System.err.println("URL đã lưu không hoạt động, thử lại tất cả...");
                activeUrl = null;
            }
        }

        // Thử lần lượt từng URL
        SQLException lastException = null;

        // Phase 1: Thử Windows Authentication
        for (int i = 0; i < CONNECTION_URLS.length; i++) {
            String url = CONNECTION_URLS[i];
            boolean isSqlAuth = (i >= 4); // 4 URL đầu là Windows Auth, còn lại là SQL Auth

            try {
                Connection conn;
                if (isSqlAuth) {
                    conn = DriverManager.getConnection(url, DB_USER, DB_PASSWORD);
                } else {
                    conn = DriverManager.getConnection(url);
                }
                // Kết nối thành công
                activeUrl = url;
                useSqlAuth = isSqlAuth;
                System.out.println(">>> Database connected: " + (isSqlAuth ? "SQL Auth" : "Windows Auth"));
                return conn;
            } catch (SQLException e) {
                lastException = e;
                // In ra lỗi để debug (chỉ in lần đầu)
                if (i == 0) {
                    System.err.println("Đang thử các phương thức kết nối SQL Server...");
                }
                System.err.println("  [" + (i + 1) + "] Thất bại: " + getShortUrl(url)
                        + " - " + e.getMessage().split("\n")[0]);
            }
        }

        // Tất cả đều thất bại
        throw new SQLException(
                "KHÔNG THỂ KẾT NỐI SQL SERVER.\n"
                + "Vui lòng kiểm tra:\n"
                + "1. SQL Server đã được cài đặt và đang chạy chưa?\n"
                + "   Mở Services.msc, tìm 'SQL Server (MSSQLSERVER)' hoặc 'SQL Server (SQLEXPRESS)'\n"
                + "2. TCP/IP đã được bật trong SQL Server Configuration Manager chưa?\n"
                + "   SQL Server Configuration Manager > SQL Server Network Configuration\n"
                + "   > Protocols for MSSQLSERVER > TCP/IP > Enable = Yes\n"
                + "3. SQL Server Browser service đã chạy chưa? (nếu dùng named instance)\n"
                + "   Services.msc > SQL Server Browser > Start\n"
                + "4. Windows Firewall có đang chặn port 1433 không?\n"
                + "5. Nếu dùng SQL Auth (sa/123), SQL Server đã bật Mixed Mode chưa?\n"
                + "   SSMS > Click phải Server > Properties > Security > SQL Server and Windows Authentication mode\n\n"
                + "Lỗi gốc: " + lastException.getMessage(),
                lastException);
    }

    /**
     * Đóng connection an toàn.
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Lỗi khi đóng connection: " + e.getMessage());
            }
        }
    }

    /**
     * Lấy URL rút gọn để hiển thị log.
     */
    private static String getShortUrl(String url) {
        if (url.contains("integratedSecurity=true")) {
            return "Windows Auth";
        }
        return "SQL Auth (sa)";
    }
}
