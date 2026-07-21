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

    // ──────────────────────────────────────────────
    //  Service Validation (theo đặc tả phòng khám)
    // ──────────────────────────────────────────────

    /**
     * Mã dịch vụ: chữ hoa, số, gạch ngang, gạch dưới — 3-30 ký tự.
     * Bắt đầu bằng chữ hoa hoặc số. Không khoảng trắng, không ký tự đặc biệt khác.
     * VD: SVC-SIEU-AM-4D, SVC_XN_MAU, DV01
     */
    private static final String SERVICE_CODE_REGEX = "^[A-Z0-9][A-Z0-9_\\-]{2,29}$";

    private static final int MIN_SERVICE_CODE_LENGTH = 3;
    private static final int MAX_SERVICE_CODE_LENGTH = 30;

    /** Tên dịch vụ: 2-100 ký tự, không được chỉ gồm chữ số hoặc ký tự đặc biệt */
    private static final int MIN_SERVICE_NAME_LENGTH = 2;
    private static final int MAX_SERVICE_NAME_LENGTH = 100;
    /** Tên không được chỉ chứa toàn chữ số */
    private static final String ONLY_DIGITS_REGEX = "^\\d+$";
    /** Tên không được chỉ chứa toàn ký tự đặc biệt / khoảng trắng */
    private static final String ONLY_SPECIAL_REGEX = "^[\\s!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~]+$";

    /** Đơn giá: 50.000đ → 100.000.000đ */
    public static final int MIN_SERVICE_PRICE = 50_000;
    public static final int MAX_SERVICE_PRICE = 100_000_000;

    /** Thời gian thực hiện: tối thiểu 5 phút, tối đa 480 phút (8 giờ) */
    public static final int MIN_DURATION_MINS = 5;
    public static final int MAX_DURATION_MINS = 480;
    /** Các mốc thời gian chuẩn (phút) để gợi ý */
    public static final int[] STANDARD_DURATIONS = {5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 360, 480};

    /** Độ dài tối đa các trường optional */
    private static final int MAX_DESC_LENGTH = 500;
    private static final int MAX_ROOM_LENGTH = 50;
    private static final int MAX_SPECIALTY_LENGTH = 255;

    /**
     * Validate mã dịch vụ:
     * - Không được để trống
     * - Chỉ chữ in hoa, số, gạch ngang (-), gạch dưới (_)
     * - Dài 3-30 ký tự, bắt đầu bằng chữ hoa hoặc số
     * - Không chứa khoảng trắng
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateServiceCode(String serviceCode) {
        if (serviceCode == null || serviceCode.trim().isEmpty()) {
            return "Mã dịch vụ không được để trống.";
        }
        String code = serviceCode.trim();
        if (code.contains(" ")) {
            return "Mã dịch vụ không được chứa khoảng trắng.";
        }
        if (code.length() < MIN_SERVICE_CODE_LENGTH) {
            return "Mã dịch vụ phải có ít nhất " + MIN_SERVICE_CODE_LENGTH + " ký tự.";
        }
        if (code.length() > MAX_SERVICE_CODE_LENGTH) {
            return "Mã dịch vụ không được vượt quá " + MAX_SERVICE_CODE_LENGTH + " ký tự.";
        }
        if (!code.matches(SERVICE_CODE_REGEX)) {
            return "Mã dịch vụ chỉ được chứa chữ IN HOA, số, gạch ngang (-) và gạch dưới (_). Bắt đầu bằng chữ hoa hoặc số.";
        }
        return null;
    }

    /**
     * Validate tên dịch vụ:
     * - Không được để trống
     * - Dài 2-100 ký tự sau khi trim
     * - Không được chỉ bao gồm chữ số
     * - Không được chỉ bao gồm ký tự đặc biệt
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateServiceName(String serviceName) {
        if (serviceName == null || serviceName.trim().isEmpty()) {
            return "Tên dịch vụ không được để trống.";
        }
        String name = serviceName.trim();
        if (name.length() < MIN_SERVICE_NAME_LENGTH) {
            return "Tên dịch vụ phải có ít nhất " + MIN_SERVICE_NAME_LENGTH + " ký tự.";
        }
        if (name.length() > MAX_SERVICE_NAME_LENGTH) {
            return "Tên dịch vụ không được vượt quá " + MAX_SERVICE_NAME_LENGTH + " ký tự.";
        }
        // Không được chỉ chứa toàn chữ số
        if (name.matches(ONLY_DIGITS_REGEX)) {
            return "Tên dịch vụ không được chỉ bao gồm chữ số. Vui lòng nhập tên rõ ràng, dễ hiểu.";
        }
        // Không được chỉ chứa toàn ký tự đặc biệt
        if (name.matches(ONLY_SPECIAL_REGEX)) {
            return "Tên dịch vụ không được chỉ bao gồm ký tự đặc biệt. Vui lòng nhập tên rõ ràng, dễ hiểu.";
        }
        return null;
    }

    /**
     * Validate đơn giá dịch vụ:
     * - Không được để trống
     * - Phải là số nguyên dương (không số âm, không số thập phân, không chữ)
     * - Trong khoảng [50.000 .. 100.000.000]
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateServicePrice(String priceStr) {
        if (priceStr == null || priceStr.trim().isEmpty()) {
            return "Đơn giá không được để trống.";
        }
        String raw = priceStr.trim();
        // Không cho phép số thập phân
        if (raw.contains(".") || raw.contains(",")) {
            return "Đơn giá phải là số nguyên dương, không được chứa số thập phân.";
        }
        try {
            java.math.BigDecimal price = new java.math.BigDecimal(raw);
            // Không cho số âm
            if (price.compareTo(java.math.BigDecimal.ZERO) < 0) {
                return "Đơn giá không được là số âm.";
            }
            if (price.compareTo(new java.math.BigDecimal(String.valueOf(MIN_SERVICE_PRICE))) < 0) {
                return "Đơn giá phải lớn hơn hoặc bằng " + formatCurrency(MIN_SERVICE_PRICE) + " VNĐ.";
            }
            if (price.compareTo(new java.math.BigDecimal(String.valueOf(MAX_SERVICE_PRICE))) > 0) {
                return "Đơn giá không được vượt quá " + formatCurrency(MAX_SERVICE_PRICE) + " VNĐ.";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Đơn giá không hợp lệ. Vui lòng chỉ nhập số nguyên dương (VD: 500000).";
        }
    }

    /**
     * Validate thời gian thực hiện dịch vụ (phút).
     * - Bắt buộc nhập
     * - Phải là số nguyên dương
     * - Tối thiểu 5 phút, tối đa 480 phút (8 giờ)
     * - Khuyến khích dùng các mốc chuẩn: 5, 10, 15, 20, 30, 45, 60, 90 phút
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateDurationMins(String durationStr) {
        if (durationStr == null || durationStr.trim().isEmpty()) {
            return "Thời gian thực hiện không được để trống.";
        }
        String raw = durationStr.trim();
        try {
            int mins = Integer.parseInt(raw);
            if (mins < MIN_DURATION_MINS) {
                return "Thời gian thực hiện tối thiểu là " + MIN_DURATION_MINS + " phút.";
            }
            if (mins > MAX_DURATION_MINS) {
                return "Thời gian thực hiện không được vượt quá " + MAX_DURATION_MINS + " phút (8 giờ).";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Thời gian thực hiện không hợp lệ. Vui lòng nhập số nguyên (VD: 30).";
        }
    }

    /**
     * Validate mô tả dịch vụ (optional):
     * - Nếu có thì không vượt quá 500 ký tự
     * - Không được chỉ chứa khoảng trắng
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateServiceDescription(String description) {
        if (description == null || description.trim().isEmpty()) {
            return null; // optional field
        }
        String desc = description.trim();
        if (desc.length() > MAX_DESC_LENGTH) {
            return "Mô tả không được vượt quá " + MAX_DESC_LENGTH + " ký tự.";
        }
        // Nếu chỉ toàn 1 ký tự lặp lại vô nghĩa
        if (desc.matches("^(.)\\1{4,}$") && desc.length() >= 5) {
            return "Mô tả không hợp lệ — không được chỉ chứa ký tự lặp lại vô nghĩa.";
        }
        return null;
    }

    /**
     * Validate nhóm dịch vụ — bắt buộc phải chọn.
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateCategoryRequired(String categoryIdStr) {
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            return "Vui lòng chọn nhóm dịch vụ.";
        }
        try {
            Integer.parseInt(categoryIdStr.trim());
            return null;
        } catch (NumberFormatException e) {
            return "Nhóm dịch vụ không hợp lệ.";
        }
    }

    /**
     * Validate phòng thực hiện (optional): nếu có thì không vượt quá maxLength.
     */
    public static String validateRoomType(String roomType) {
        if (roomType == null || roomType.trim().isEmpty()) {
            return null;
        }
        if (roomType.trim().length() > MAX_ROOM_LENGTH) {
            return "Phòng thực hiện không được vượt quá " + MAX_ROOM_LENGTH + " ký tự.";
        }
        return null;
    }

    /**
     * Validate chuyên khoa áp dụng (optional): nếu có thì không vượt quá maxLength.
     */
    public static String validateAllowedSpecialties(String specialties) {
        if (specialties == null || specialties.trim().isEmpty()) {
            return null;
        }
        if (specialties.trim().length() > MAX_SPECIALTY_LENGTH) {
            return "Chuyên khoa áp dụng không được vượt quá " + MAX_SPECIALTY_LENGTH + " ký tự.";
        }
        return null;
    }

    // ──────────────────────────────────────────────
    //  Medicine Validation (theo đặc tả phòng khám)
    // ──────────────────────────────────────────────

    /**
     * Mã thuốc: chữ hoa, số, gạch ngang, gạch dưới — 3-30 ký tự.
     * Bắt đầu bằng chữ hoa hoặc số. Không khoảng trắng, không ký tự đặc biệt khác.
     * VD: THUOC-SAT-01, PARACETAMOL_500, A01
     */
    private static final String MEDICINE_CODE_REGEX = "^[A-Z0-9][A-Z0-9_\\-]{2,29}$";
    private static final int MIN_MEDICINE_CODE_LENGTH = 3;
    private static final int MAX_MEDICINE_CODE_LENGTH = 30;

    /** Tên thuốc: 2-150 ký tự, không được chỉ gồm chữ số hoặc ký tự đặc biệt */
    private static final int MIN_MEDICINE_NAME_LENGTH = 2;
    private static final int MAX_MEDICINE_NAME_LENGTH = 150;

    /** Đơn giá thuốc: 1.000đ → 100.000.000đ, bước nhảy 100đ */
    public static final int MIN_MEDICINE_PRICE = 1_000;
    public static final int MAX_MEDICINE_PRICE = 100_000_000;
    public static final int MEDICINE_PRICE_STEP = 100;

    /** Tồn kho: 0 → 999.999 */
    public static final int MAX_STOCK_QUANTITY = 999_999;

    /** Độ dài tối đa các trường medicine */
    private static final int MAX_MEDICINE_DESC_LENGTH = 500;
    private static final int MAX_DOSAGE_LENGTH = 100;
    private static final int MAX_UNIT_LENGTH = 50;

    /**
     * Validate mã thuốc:
     * - Không được để trống
     * - Chỉ chữ IN HOA, số, gạch ngang (-), gạch dưới (_)
     * - Dài 3-30 ký tự, bắt đầu bằng chữ hoa hoặc số
     * - Không chứa khoảng trắng
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateMedicineCode(String medicineCode) {
        if (medicineCode == null || medicineCode.trim().isEmpty()) {
            return "Mã thuốc không được để trống.";
        }
        String code = medicineCode.trim();
        if (code.contains(" ")) {
            return "Mã thuốc không được chứa khoảng trắng.";
        }
        if (code.length() < MIN_MEDICINE_CODE_LENGTH) {
            return "Mã thuốc phải có ít nhất " + MIN_MEDICINE_CODE_LENGTH + " ký tự.";
        }
        if (code.length() > MAX_MEDICINE_CODE_LENGTH) {
            return "Mã thuốc không được vượt quá " + MAX_MEDICINE_CODE_LENGTH + " ký tự.";
        }
        if (!code.matches(MEDICINE_CODE_REGEX)) {
            return "Mã thuốc chỉ được chứa chữ IN HOA, số, gạch ngang (-) và gạch dưới (_). Bắt đầu bằng chữ hoa hoặc số.";
        }
        return null;
    }

    /**
     * Validate tên thuốc:
     * - Không được để trống
     * - Dài 2-150 ký tự sau khi trim
     * - Không được chỉ bao gồm chữ số
     * - Không được chỉ bao gồm ký tự đặc biệt / khoảng trắng
     * - Không được chỉ là 1 ký tự lặp lại vô nghĩa
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateMedicineName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "Tên thuốc không được để trống.";
        }
        String trimmed = name.trim();
        if (trimmed.length() < MIN_MEDICINE_NAME_LENGTH) {
            return "Tên thuốc phải có ít nhất " + MIN_MEDICINE_NAME_LENGTH + " ký tự.";
        }
        if (trimmed.length() > MAX_MEDICINE_NAME_LENGTH) {
            return "Tên thuốc không được vượt quá " + MAX_MEDICINE_NAME_LENGTH + " ký tự.";
        }
        // Không được chỉ chứa toàn chữ số
        if (trimmed.matches(ONLY_DIGITS_REGEX)) {
            return "Tên thuốc không được chỉ bao gồm chữ số. Vui lòng nhập tên thuốc rõ ràng.";
        }
        // Không được chỉ chứa toàn ký tự đặc biệt
        if (trimmed.matches(ONLY_SPECIAL_REGEX)) {
            return "Tên thuốc không được chỉ bao gồm ký tự đặc biệt. Vui lòng nhập tên thuốc rõ ràng.";
        }
        // Không được là chuỗi 1 ký tự lặp lại (VD: "aaaaa", "-----")
        if (trimmed.matches("^(.)\\1{4,}$") && trimmed.length() >= 5) {
            return "Tên thuốc không hợp lệ — không được chỉ chứa ký tự lặp lại vô nghĩa.";
        }
        return null;
    }

    /**
     * Validate đơn giá thuốc:
     * - Không được để trống
     * - Phải là số nguyên dương (không số âm, không số thập phân, không chữ)
     * - Trong khoảng [1.000 .. 100.000.000]
     * - Phải là bội số của 100 VNĐ
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateMedicinePrice(String priceStr) {
        if (priceStr == null || priceStr.trim().isEmpty()) {
            return "Giá bán không được để trống.";
        }
        String raw = priceStr.trim();
        // Không cho phép số thập phân
        if (raw.contains(".") || raw.contains(",")) {
            return "Giá bán phải là số nguyên dương, không được chứa số thập phân.";
        }
        try {
            java.math.BigDecimal price = new java.math.BigDecimal(raw);
            // Không cho số âm hoặc bằng 0
            if (price.compareTo(java.math.BigDecimal.ZERO) <= 0) {
                return "Giá bán phải lớn hơn 0.";
            }
            if (price.compareTo(new java.math.BigDecimal(String.valueOf(MIN_MEDICINE_PRICE))) < 0) {
                return "Giá bán phải lớn hơn hoặc bằng " + formatCurrency(MIN_MEDICINE_PRICE) + " VNĐ.";
            }
            if (price.compareTo(new java.math.BigDecimal(String.valueOf(MAX_MEDICINE_PRICE))) > 0) {
                return "Giá bán không được vượt quá " + formatCurrency(MAX_MEDICINE_PRICE) + " VNĐ.";
            }
            // Enforce bước nhảy 100 VNĐ
            java.math.BigDecimal[] divAndRem = price.divideAndRemainder(new java.math.BigDecimal(String.valueOf(MEDICINE_PRICE_STEP)));
            if (divAndRem[1].compareTo(java.math.BigDecimal.ZERO) != 0) {
                return "Giá bán phải là bội số của " + formatCurrency(MEDICINE_PRICE_STEP) + " VNĐ (VD: 1000, 1500, 2000...).";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Giá bán không hợp lệ. Vui lòng chỉ nhập số nguyên dương (VD: 5000).";
        }
    }

    /**
     * Validate số lượng tồn kho:
     * - Nếu để trống → mặc định 0 (không báo lỗi)
     * - Nếu có giá trị → phải là số nguyên >= 0, <= MAX_STOCK_QUANTITY
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ (hoặc để trống)
     */
    public static String validateStockQuantity(String stockStr) {
        if (stockStr == null || stockStr.trim().isEmpty()) {
            return null; // Cho phép để trống, sẽ mặc định 0
        }
        String raw = stockStr.trim();
        try {
            int qty = Integer.parseInt(raw);
            if (qty < 0) {
                return "Tồn kho không được là số âm.";
            }
            if (qty > MAX_STOCK_QUANTITY) {
                return "Tồn kho không được vượt quá " + formatNumber(MAX_STOCK_QUANTITY) + ".";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Tồn kho không hợp lệ. Vui lòng nhập số nguyên không âm (VD: 200).";
        }
    }

    /**
     * Validate mô tả thuốc (optional):
     * - Nếu có thì không vượt quá 500 ký tự
     * - Không được chỉ chứa khoảng trắng
     * - Không được chỉ toàn ký tự lặp lại vô nghĩa
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateMedicineDescription(String description) {
        if (description == null || description.trim().isEmpty()) {
            return null; // optional field
        }
        String desc = description.trim();
        if (desc.length() > MAX_MEDICINE_DESC_LENGTH) {
            return "Mô tả không được vượt quá " + MAX_MEDICINE_DESC_LENGTH + " ký tự.";
        }
        // Nếu chỉ toàn 1 ký tự lặp lại vô nghĩa
        if (desc.matches("^(.)\\1{4,}$") && desc.length() >= 5) {
            return "Mô tả không hợp lệ — không được chỉ chứa ký tự lặp lại vô nghĩa.";
        }
        return null;
    }

    /**
     * Validate hàm lượng (optional):
     * - Nếu có thì không vượt quá 100 ký tự
     * - Không được chỉ chứa khoảng trắng
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateDosage(String dosage) {
        if (dosage == null || dosage.trim().isEmpty()) {
            return null;
        }
        String d = dosage.trim();
        if (d.length() > MAX_DOSAGE_LENGTH) {
            return "Hàm lượng không được vượt quá " + MAX_DOSAGE_LENGTH + " ký tự.";
        }
        return null;
    }

    /**
     * Validate đơn vị tính (optional):
     * - Nếu có thì không vượt quá 50 ký tự
     * - Không được chỉ chứa chữ số
     * - Không được chỉ chứa ký tự đặc biệt
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateUnit(String unit) {
        if (unit == null || unit.trim().isEmpty()) {
            return null;
        }
        String u = unit.trim();
        if (u.length() > MAX_UNIT_LENGTH) {
            return "Đơn vị tính không được vượt quá " + MAX_UNIT_LENGTH + " ký tự.";
        }
        if (u.matches(ONLY_DIGITS_REGEX)) {
            return "Đơn vị tính không được chỉ bao gồm chữ số.";
        }
        if (u.matches(ONLY_SPECIAL_REGEX)) {
            return "Đơn vị tính không được chỉ bao gồm ký tự đặc biệt.";
        }
        return null;
    }

    /**
     * Validate chọn nhóm thuốc (optional):
     * - Nếu có chọn thì phải là số nguyên hợp lệ
     *
     * @return thông báo lỗi hoặc null nếu hợp lệ
     */
    public static String validateCategoryId(String categoryIdStr) {
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            return null; // Cho phép không chọn nhóm
        }
        try {
            int catId = Integer.parseInt(categoryIdStr.trim());
            if (catId <= 0) {
                return "Nhóm thuốc không hợp lệ.";
            }
            return null;
        } catch (NumberFormatException e) {
            return "Nhóm thuốc không hợp lệ.";
        }
    }

    /** Định dạng số nguyên để hiển thị trong thông báo lỗi */
    private static String formatNumber(int number) {
        java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        return nf.format(number);
    }

    /** Định dạng số tiền để hiển thị trong thông báo lỗi */
    private static String formatCurrency(int amount) {
        java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        return nf.format(amount);
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
