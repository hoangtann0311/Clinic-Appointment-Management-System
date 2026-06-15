package com.clinic.utils;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Tiện ích mã hóa và kiểm tra mật khẩu sử dụng BCrypt.
 */
public class BCryptUtil {

    // Workload factor (10-12 là cân bằng tốt giữa bảo mật và hiệu năng)
    private static final int WORKLOAD = 12;

    /**
     * Hash mật khẩu plain text bằng BCrypt.
     * @param plainPassword mật khẩu chưa mã hóa
     * @return chuỗi hash đã mã hóa
     */
    public static String hashPassword(String plainPassword) {
        String salt = BCrypt.gensalt(WORKLOAD);
        return BCrypt.hashpw(plainPassword, salt);
    }

    /**
     * Kiểm tra mật khẩu plain text khớp với hash.
     * @param plainPassword  mật khẩu chưa mã hóa
     * @param hashedPassword mật khẩu đã mã hóa
     * @return true nếu khớp
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            System.err.println("Lỗi kiểm tra BCrypt: " + e.getMessage());
            return false;
        }
    }
}
