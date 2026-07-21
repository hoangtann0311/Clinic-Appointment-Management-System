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

    // DB_URL tùy chọn từ biến môi trường hoặc system property
    private static final String CUSTOM_DB_URL = getSetting("DB_URL", null);

    // SQL Server Authentication credentials (chỉ dùng khi được cấu hình đầy đủ)
    private static final String DB_USER = getSetting("DB_USER", "sa");
    private static final String DB_PASSWORD = getSetting("DB_PASSWORD", "sa");

    // Danh sách các URL kết nối dự phòng
    private static final String[] CONNECTION_URLS = {
        "jdbc:sqlserver://localhost:1433;databaseName=" + DATABASE_NAME + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=" + DATABASE_NAME + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        "jdbc:sqlserver://localhost\\MSSQLSERVER;databaseName=" + DATABASE_NAME + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        "jdbc:sqlserver://localhost;databaseName=" + DATABASE_NAME + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        "jdbc:sqlserver://localhost:1433;databaseName=" + DATABASE_NAME + ";encrypt=true;trustServerCertificate=true;",
        "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=" + DATABASE_NAME + ";encrypt=true;trustServerCertificate=true;"
    };

    private static String activeUrl = null;
    private static boolean useSqlAuth = false;

    private static String getSetting(String name, String defaultValue) {
        String property = System.getProperty(name);
        if (property != null && !property.isBlank()) {
            return property;
        }
        String environment = System.getenv(name);
        if (environment != null && !environment.isBlank()) {
            return environment;
        }
        String appConfigVal = AppConfig.get(name.toLowerCase().replace('_', '.'), null);
        if (appConfigVal != null && !appConfigVal.isBlank()) {
            return appConfigVal;
        }
        return defaultValue;
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
     * Lấy connection đến database.
     * Uu tiên DB_URL nếu được cấu hình, sau đó thử các URL mặc định.
     *
     * @return Connection object
     * @throws SQLException nếu tất cả phương thức kết nối thất bại
     */
    public static Connection getConnection() throws SQLException {
        boolean hasValidCredentials = DB_USER != null && !DB_USER.isBlank() 
                                   && DB_PASSWORD != null && !DB_PASSWORD.isBlank();

        // 1. Ưu tiên sử dụng DB_URL nếu được khai báo
        if (CUSTOM_DB_URL != null && !CUSTOM_DB_URL.isBlank()) {
            try {
                Connection conn;
                if (hasValidCredentials) {
                    conn = DriverManager.getConnection(CUSTOM_DB_URL, DB_USER, DB_PASSWORD);
                    System.out.println("Database connected using SQL Authentication.");
                } else {
                    conn = DriverManager.getConnection(CUSTOM_DB_URL);
                    System.out.println("Database connected using Windows Authentication.");
                }
                return conn;
            } catch (SQLException e) {
                System.err.println("Database connection failed. SQLState=" + e.getSQLState() + ", errorCode=" + e.getErrorCode());
            }
        }

        // 2. Tái sử dụng activeUrl đã xác minh thành công
        if (activeUrl != null) {
            try {
                if (useSqlAuth) {
                    if (hasValidCredentials) {
                        return DriverManager.getConnection(activeUrl, DB_USER, DB_PASSWORD);
                    } else {
                        activeUrl = null;
                    }
                } else {
                    return DriverManager.getConnection(activeUrl);
                }
            } catch (SQLException e) {
                activeUrl = null;
            }
        }

        // 3. Thử lần lượt các URL dự phòng
        SQLException lastException = null;

        for (int i = 0; i < CONNECTION_URLS.length; i++) {
            String url = CONNECTION_URLS[i];
            boolean isSqlAuth = (i >= 4);

            // Bỏ qua SQL Auth nếu thiếu credential
            if (isSqlAuth && !hasValidCredentials) {
                continue;
            }

            try {
                Connection conn;
                if (isSqlAuth) {
                    conn = DriverManager.getConnection(url, DB_USER, DB_PASSWORD);
                    System.out.println("Database connected using SQL Authentication.");
                } else {
                    conn = DriverManager.getConnection(url);
                    System.out.println("Database connected using Windows Authentication.");
                }
                activeUrl = url;
                useSqlAuth = isSqlAuth;
                return conn;
            } catch (SQLException e) {
                lastException = e;
                System.err.println("Database connection failed. SQLState=" + e.getSQLState() + ", errorCode=" + e.getErrorCode());
            }
        }

        throw new SQLException(
                "Database connection failed. SQLState=" 
                + (lastException != null ? lastException.getSQLState() : "N/A") 
                + ", errorCode=" + (lastException != null ? lastException.getErrorCode() : 0),
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
                System.err.println("Lỗi khi đóng connection: SQLState=" + e.getSQLState());
            }
        }
    }
}
