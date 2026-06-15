package com.clinic.utils;

/**
 * Tiện ích mã hoá/giải mã email và phone trong database.
 * Sử dụng ENCRYPTBYPASSPHRASE/DECRYPTBYPASSPHRASE của SQL Server.
 *
 * LƯU Ý BẢO MẬT:
 * - Passphrase NÊN được lưu trong biến môi trường hoặc file config,
 *   không hardcode trong source code.
 * - Đổi passphrase định kỳ và re-encrypt dữ liệu.
 */
public class EncryptionUtil {

    /**
     * Passphrase dùng để mã hoá dữ liệu.
     * Trong production, nên đọc từ System.getenv("DB_ENCRYPTION_KEY")
     * hoặc từ file cấu hình.
     */
    private static final String PASSPHRASE = "ClinicAppKey2026!";

    /**
     * Lấy passphrase hiện tại.
     * Ưu tiên biến môi trường CLINIC_DB_ENCRYPTION_KEY.
     */
    public static String getPassphrase() {
        String envKey = System.getenv("CLINIC_DB_ENCRYPTION_KEY");
        return (envKey != null && !envKey.isEmpty()) ? envKey : PASSPHRASE;
    }

    /**
     * Tạo biểu thức SQL ENCRYPTBYPASSPHRASE để mã hoá giá trị.
     * Dùng trong INSERT/UPDATE.
     *
     * @param value giá trị cần mã hoá (có thể null)
     * @return chuỗi SQL "ENCRYPTBYPASSPHRASE('key', N'value')" hoặc "NULL"
     */
    public static String encryptSql(String value) {
        if (value == null) {
            return "NULL";
        }
        // Escape single quote trong passphrase và value
        String escapedKey = getPassphrase().replace("'", "''");
        String escapedValue = value.replace("'", "''");
        return "ENCRYPTBYPASSPHRASE('" + escapedKey + "', N'" + escapedValue + "')";
    }

    /**
     * Tạo biểu thức SQL DECRYPTBYPASSPHRASE để giải mã cột.
     * Dùng trong SELECT.
     *
     * @param columnName tên cột cần giải mã
     * @param sqlType    kiểu dữ liệu gốc (VARCHAR, NVARCHAR, ...)
     * @param length     độ dài tối đa của dữ liệu gốc
     * @return chuỗi SQL "CONVERT(sqlType(length), DECRYPTBYPASSPHRASE('key', columnName))"
     */
    public static String decryptSql(String columnName, String sqlType, int length) {
        String escapedKey = getPassphrase().replace("'", "''");
        return "CONVERT(" + sqlType + "(" + length + "), "
                + "DECRYPTBYPASSPHRASE('" + escapedKey + "', " + columnName + "))";
    }

    /**
     * Giải mã cột email (NVARCHAR(100)).
     */
    public static String decryptEmailSql(String columnName) {
        return decryptSql(columnName, "NVARCHAR", 100);
    }

    /**
     * Giải mã cột phone (NVARCHAR(20)).
     */
    public static String decryptPhoneSql(String columnName) {
        return decryptSql(columnName, "NVARCHAR", 20);
    }

    /**
     * Tạo điều kiện WHERE để so sánh với giá trị đã mã hoá.
     * Dùng cho tìm kiếm chính xác theo email hoặc phone.
     *
     * Cách dùng: WHERE column = encryptValue(?)
     * Nhưng vì ENCRYPTBYPASSPHRASE không deterministic (có salt ngẫu nhiên),
     * nên ta phải giải mã cột rồi so sánh: WHERE DECRYPTBYPASSPHRASE('key', column) = ?
     *
     * @param columnName tên cột đã mã hoá
     * @param sqlType    kiểu dữ liệu gốc
     * @param length     độ dài tối đa
     * @return chuỗi SQL điều kiện WHERE
     */
    public static String decryptWhereEqual(String columnName, String sqlType, int length) {
        String escapedKey = getPassphrase().replace("'", "''");
        return "CONVERT(" + sqlType + "(" + length + "), "
                + "DECRYPTBYPASSPHRASE('" + escapedKey + "', " + columnName + "))";
    }

    /**
     * Điều kiện WHERE cho email.
     */
    public static String decryptEmailWhere(String columnName) {
        return decryptWhereEqual(columnName, "NVARCHAR", 100);
    }

    /**
     * Điều kiện WHERE cho phone.
     */
    public static String decryptPhoneWhere(String columnName) {
        return decryptWhereEqual(columnName, "NVARCHAR", 20);
    }

    /**
     * Điều kiện LIKE cho tìm kiếm (dùng cho email/phone đã mã hoá).
     */
    public static String decryptWhereLike(String columnName, String sqlType, int length) {
        return decryptWhereEqual(columnName, sqlType, length) + " LIKE ?";
    }
}
