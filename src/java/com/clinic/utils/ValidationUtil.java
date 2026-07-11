package com.clinic.utils;

import java.util.HashMap;
import java.util.Map;

/**
 * Tiện ích validate input cho toàn hệ thống.
 * Validate ở Service layer theo kiến trúc chuẩn.
 */
public class ValidationUtil {

    /**
     * Regex email chuẩn RFC 5322 (đơn giản hóa).
     * Hỗ trợ: chữ cái, số, dấu cộng (+), gạch dưới (_), dấu chấm (.), dấu gạch ngang (-)
     * trong phần local. Domain hỗ trợ chữ cái, số, dấu chấm, dấu gạch ngang.
     * TLD yêu cầu ít nhất 2 ký tự chữ cái.
     *
     * LƯU Ý: Dấu gạch ngang (-) được đặt ở đầu mỗi character class để tránh
     * ambiguity với range operator (A-Z, a-z, 0-9) trên mọi regex engine.
     * Điều này đảm bảo email có dấu chấm (.) như "ten.ten@gmail.com" luôn khớp.
     */
    private static final String EMAIL_REGEX = "^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\\.[A-Za-z]{2,}$";

    /**
     * Số điện thoại Việt Nam: bắt đầu 03|05|07|08|09 và chính xác 10 chữ số.
     */
    private static final String PHONE_REGEX = "^(0[3|5|7|8|9])[0-9]{8}$";

    private static final int MIN_PASSWORD_LENGTH = 6;
    private static final int MAX_NAME_LENGTH = 100;
    private static final int MIN_NAME_LENGTH = 2;

    // Mật khẩu: ít nhất 6 ký tự, phải có ít nhất 1 chữ cái, 1 chữ số và 1 ký tự đặc biệt
    private static final String PASSWORD_REGEX =
            "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~])[A-Za-z\\d!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~]{6,}$";

    /**
     * Validate email định dạng.
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return email.trim().matches(EMAIL_REGEX);
    }

    /**
     * Validate mật khẩu:
     * - Ít nhất 6 ký tự
     * - Phải có ít nhất 1 chữ cái (a-z, A-Z)
     * - Phải có ít nhất 1 chữ số (0-9)
     * - Phải có ít nhất 1 ký tự đặc biệt
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }
        return password.matches(PASSWORD_REGEX);
    }

    /**
     * Validate số điện thoại Việt Nam: bắt buộc, bắt đầu 03|05|07|08|09,
     * chính xác 10 chữ số, không hơn không kém.
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false; // Số điện thoại là bắt buộc
        }
        return phone.trim().matches(PHONE_REGEX);
    }

    /**
     * Validate họ tên không được trống, từ 2-100 ký tự.
     */
    public static boolean isValidFullName(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return false;
        }
        fullName = fullName.trim();
        return fullName.length() >= MIN_NAME_LENGTH && fullName.length() <= MAX_NAME_LENGTH;
    }

    /**
     * Validate tất cả các trường đăng ký.
     * Tất cả các trường đều bắt buộc, không được để trống.
     *
     * @param fullName         họ tên
     * @param email            email
     * @param password         mật khẩu
     * @param confirmPassword  xác nhận mật khẩu
     * @param phone            số điện thoại (bắt buộc)
     * @return Map chứa các lỗi (key = tên trường, value = thông báo lỗi)
     */
    public static Map<String, String> validateRegistration(
            String fullName, String email, String password,
            String confirmPassword, String phone, String terms) {

        Map<String, String> errors = new HashMap<>();

        // Họ tên: không được để trống, từ 2-100 ký tự
        if (!isValidFullName(fullName)) {
            if (fullName == null || fullName.trim().isEmpty()) {
                errors.put("fullName", "Họ tên không được để trống.");
            } else if (fullName.trim().length() < MIN_NAME_LENGTH) {
                errors.put("fullName", "Họ tên phải có ít nhất " + MIN_NAME_LENGTH + " ký tự.");
            } else {
                errors.put("fullName", "Họ tên không được vượt quá " + MAX_NAME_LENGTH + " ký tự.");
            }
        }

        // Email: không được để trống, đúng định dạng
        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Email không được để trống.");
        } else if (!isValidEmail(email)) {
            errors.put("email", "Email không đúng định dạng (VD: ten@domain.com).");
        }

        // Mật khẩu: tối thiểu 6 ký tự, có chữ, số và ký tự đặc biệt
        if (password == null || password.isEmpty()) {
            errors.put("password", "Mật khẩu không được để trống.");
        } else if (password.length() < MIN_PASSWORD_LENGTH) {
            errors.put("password", "Mật khẩu phải có ít nhất " + MIN_PASSWORD_LENGTH + " ký tự.");
        } else if (!password.matches(".*[A-Za-z].*")) {
            errors.put("password", "Mật khẩu phải chứa ít nhất 1 chữ cái.");
        } else if (!password.matches(".*\\d.*")) {
            errors.put("password", "Mật khẩu phải chứa ít nhất 1 chữ số.");
        } else if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~].*")) {
            errors.put("password", "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (VD: !@#$%).");
        }

        // Xác nhận mật khẩu: không được để trống, khớp với mật khẩu
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không được để trống.");
        } else if (!confirmPassword.equals(password)) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không khớp với mật khẩu.");
        }

        // Số điện thoại: bắt buộc, đúng 10 chữ số, bắt đầu 03|05|07|08|09
        if (phone == null || phone.trim().isEmpty()) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!isValidPhone(phone)) {
            errors.put("phone", "Số điện thoại phải đúng 10 chữ số, bắt đầu bằng 03, 05, 07, 08 hoặc 09.");
        }

        // Điều khoản sử dụng: bắt buộc đồng ý
        if (terms == null || !"on".equals(terms)) {
            errors.put("terms", "Bạn phải đồng ý với Điều khoản sử dụng và Chính sách bảo mật.");
        }

        return errors;
    }

    /**
     * Gom các lỗi thành một chuỗi thông báo để hiển thị.
     */
    public static String getErrorMessage(Map<String, String> errors) {
        if (errors == null || errors.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (String msg : errors.values()) {
            if (sb.length() > 0) {
                sb.append("<br>");
            }
            sb.append(msg);
        }
        return sb.toString();
    }
}
