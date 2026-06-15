package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Database Context - Quản lý kết nối SQL Server.
 * Sử dụng Singleton pattern và tự động thử nhiều cách kết nối.
 *
 * @author han
 */
public class DBContext {

    private static final String DATABASE_NAME = "ObstetricsClinicDB";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "admin";

    private static DBContext instance;
    private Connection connection;

    // Các URL kết nối sẽ thử lần lượt
    private static final String[] URLS = {
        // Windows Auth - Default instance
        "jdbc:sqlserver://localhost:1433;databaseName=" + DATABASE_NAME
                + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        // Windows Auth - SQLEXPRESS
        "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=" + DATABASE_NAME
                + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        // Windows Auth - MSSQLSERVER
        "jdbc:sqlserver://localhost\\MSSQLSERVER;databaseName=" + DATABASE_NAME
                + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        // Windows Auth - auto resolve
        "jdbc:sqlserver://localhost;databaseName=" + DATABASE_NAME
                + ";integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
        // SQL Auth - Default instance
        "jdbc:sqlserver://localhost:1433;databaseName=" + DATABASE_NAME
                + ";encrypt=true;trustServerCertificate=true;",
        // SQL Auth - SQLEXPRESS
        "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=" + DATABASE_NAME
                + ";encrypt=true;trustServerCertificate=true;",
    };

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy SQL Server JDBC Driver", e);
        }
    }

    public static DBContext getInstance() {
        if (instance == null) {
            instance = new DBContext();
        }
        return instance;
    }

    private DBContext() {
        // Không tự động kết nối trong constructor
    }

    public Connection getConnection() {
        try {
            // Nếu đã có kết nối hoạt động, dùng lại
            if (connection != null && !connection.isClosed()) {
                return connection;
            }
        } catch (SQLException e) {
            connection = null;
        }

        // Thử tất cả các URL
        SQLException lastEx = null;

        for (int i = 0; i < URLS.length; i++) {
            String url = URLS[i];
            boolean isSqlAuth = (i >= 4);

            try {
                if (isSqlAuth) {
                    connection = DriverManager.getConnection(url, DB_USER, DB_PASSWORD);
                } else {
                    connection = DriverManager.getConnection(url);
                }
                System.out.println(">>> DBContext connected: "
                        + (isSqlAuth ? "SQL Auth (sa)" : "Windows Auth"));
                return connection;

            } catch (SQLException e) {
                lastEx = e;
                if (i == 0) {
                    System.err.println("DBContext: Đang thử các cách kết nối...");
                }
                System.err.println("  [" + (i + 1) + "] "
                        + (isSqlAuth ? "SQL Auth" : "Windows Auth") + " - Thất bại");
            }
        }

        // Tất cả đều thất bại → báo lỗi chi tiết
        connection = null;
        System.err.println("\n========== LỖI KẾT NỐI SQL SERVER ==========");
        System.err.println("Không thể kết nối đến SQL Server sau khi thử " + URLS.length + " cách.");
        System.err.println("\nVUI LÒNG KIỂM TRA CÁC BƯỚC SAU:");
        System.err.println("1. Mở Services.msc → tìm dịch vụ 'SQL Server (...)'");
        System.err.println("   Đảm bảo dịch vụ đang chạy (Running)");
        System.err.println("2. Mở SQL Server Configuration Manager");
        System.err.println("   SQL Server Network Configuration → Protocols for <Instance>");
        System.err.println("   → TCP/IP → Click phải → Enable");
        System.err.println("   → TCP/IP → Properties → Tab 'IP Addresses'");
        System.err.println("   → Cuộn xuống 'IPAll' → TCP Port = 1433");
        System.err.println("3. Restart SQL Server service sau khi đổi cấu hình");
        System.err.println("4. Nếu dùng named instance, khởi động SQL Server Browser service");
        System.err.println("5. Mở Windows Defender Firewall → Allow an app →");
        System.err.println("   Thêm port 1433 TCP inbound");
        System.err.println("================================================");

        if (lastEx != null) {
            System.err.println("\nLỗi gốc: " + lastEx.getMessage());
        }
        return null;
    }

    public boolean testConnection() {
        Connection c = getConnection();
        if (c != null) {
            try {
                if (!c.isClosed()) {
                    System.out.println("Kết nối database hoạt động tốt!");
                    return true;
                }
            } catch (SQLException e) {
                System.err.println("Lỗi kiểm tra kết nối: " + e.getMessage());
            }
        }
        System.out.println("Kết nối database KHÔNG hoạt động.");
        return false;
    }

    /**
     * Đếm số dòng trong bảng - an toàn với SQL Injection.
     */
    public static int getRowCount(String tableName) {
        if (tableName == null || tableName.contains(";") || !tableName.matches("^[a-zA-Z_][a-zA-Z0-9_]*$")) {
            System.err.println("Tên bảng không hợp lệ: " + tableName);
            return -1;
        }
        String sql = "SELECT COUNT(*) AS total FROM " + tableName;
        DBContext db = DBContext.getInstance();
        Connection conn = db.getConnection();
        if (conn == null) {
            return -1;
        }
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getRowCount: " + e.getMessage());
            return -1;
        }
        return -1;
    }

    public static void main(String[] args) {
        DBContext db = DBContext.getInstance();
        db.testConnection();
        System.out.println("Rows in roles: " + DBContext.getRowCount("roles"));
    }
}