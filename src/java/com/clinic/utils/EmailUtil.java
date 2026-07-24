package com.clinic.utils;

import java.util.Properties;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Tiện ích gửi email sử dụng Jakarta Mail (SMTP).
 * <p>
 * Yêu cầu: Thêm các file JAR vào WEB-INF/lib/:
 * <ul>
 *   <li>jakarta.mail-2.0.1.jar (Jakarta Mail API + implementation)</li>
 *   <li>jakarta.activation-api-2.0.1.jar (Jakarta Activation API)</li>
 *   <li>jakarta.activation-2.0.1.jar (Jakarta Activation implementation - com.sun.activation)</li>
 * </ul>
 * <p>
 * Cấu hình SMTP: Sửa các hằng số SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD
 * bên dưới cho đúng với mail server của bạn.
 */
public class EmailUtil {

    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    // ==================== CẤU HÌNH SMTP ====================
    // Thay đổi các giá trị này để khớp với mail server của bạn

    /** SMTP Host - Gmail: smtp.gmail.com */
    private static final String SMTP_HOST = "smtp.gmail.com";

    /** SMTP Port - Gmail TLS: 587, SSL: 465 */
    private static final int SMTP_PORT = 587;

    /** Tài khoản email gửi đi */
    private static final String SMTP_USERNAME = "trunghieu23092004@gmail.com";

    /**
     * Mật khẩu ứng dụng (App Password) - KHÔNG phải mật khẩu Gmail thông thường.
     * Với Gmail: vào Google Account > Security > 2-Step Verification > App passwords
     * để tạo App Password riêng cho ứng dụng này.
     */
    private static final String SMTP_PASSWORD = "lfqf yger itub dhma";

    /** Tên hiển thị khi gửi email */
    private static final String FROM_NAME = "Ph\u00f2ng Kh\u00e1m S\u1ea3n - CAMS";

    /** Email gửi đi (thường giống SMTP_USERNAME) */
    private static final String FROM_EMAIL = SMTP_USERNAME;

    // ========================================================

    /** App URL dùng trong link xác thực */
    private static final String APP_BASE_URL = "http://localhost:8080/ClinicAppointmentManagementSystem";

    /** Cờ đánh dấu email đã được cấu hình hay chưa */
    private static boolean configured = false;

    static {
        configured = !"trunghieu23092004@gmail.com".equals(SMTP_USERNAME)
                && !"lfqf yger itub dhma".equals(SMTP_PASSWORD);
        if (!configured) {
            LOGGER.warning("Email chưa được cấu hình. Link xác thực sẽ được in ra console thay vì gửi email.");
            LOGGER.warning("Mở EmailUtil.java và cập nhật SMTP_USERNAME, SMTP_PASSWORD để gửi email thật.");
        }
    }

    /**
     * Gửi email xác thực tài khoản cho người dùng mới đăng ký.
     * Việc gửi email được thực hiện trong một thread riêng để không chặn response.
     *
     * @param toEmail email người nhận
     * @param toName  tên người nhận
     * @param token   verification token
     */
    public static void sendVerificationEmail(String toEmail, String toName, String token) {
        String verificationLink = APP_BASE_URL + "/verify-email?token=" + token;
        String subject = "X\u00e1c Th\u1ef1c T\u00e0i Kho\u1ea3n - Ph\u00f2ng Kh\u00e1m S\u1ea3n";

        // Nội dung email HTML
        String htmlContent = buildVerificationEmailHtml(toName, verificationLink);

        // Gửi email trong thread riêng để không chặn response đăng ký
        new Thread(() -> {
            try {
                sendEmail(toEmail, subject, htmlContent);
                LOGGER.info("Đã gửi email xác thực đến: " + toEmail);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email xác thực đến " + toEmail, e);
                // Fallback: in link ra console để dev có thể test
                fallbackToConsole(toEmail, toName, verificationLink);
            }
        }, "EmailSender-Thread").start();
    }

    /**
     * Gửi email với nội dung HTML qua SMTP.
     */
    private static void sendEmail(String toEmail, String subject, String htmlContent) throws Exception {
        System.out.println("[EmailUtil] sendEmail: gửi đến " + toEmail + ", subject: " + subject);
        sendEmailWithJakartaMail(toEmail, subject, htmlContent);
    }

    /**
     * Gửi email sử dụng Jakarta Mail API qua reflection.
     * Dùng reflection để tránh lỗi biên dịch khi IDE không nhận diện được JAR,
     * mặc dù JAR đã có trong WEB-INF/lib/ và được khai báo trong javac.classpath.
     */
    private static void sendEmailWithJakartaMail(String toEmail, String subject, String htmlContent)
            throws Exception {

        System.out.println("[EmailUtil] sendEmailWithJakartaMail: bắt đầu gửi đến " + toEmail);
        System.out.println("[EmailUtil] SMTP: " + SMTP_HOST + ":" + SMTP_PORT
                + " user=" + SMTP_USERNAME);

        // Tạo Properties cho SMTP
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(SMTP_PORT));
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");
        props.put("mail.debug", "true");  // In log SMTP ra console

        // Cache các class để dùng nhiều lần
        Class<?> sessionClass = Class.forName("jakarta.mail.Session");
        Class<?> messageClass = Class.forName("jakarta.mail.Message");
        Class<?> mimeMessageClass = Class.forName("jakarta.mail.internet.MimeMessage");
        Class<?> internetAddressClass = Class.forName("jakarta.mail.internet.InternetAddress");
        Class<?> addressClass = Class.forName("jakarta.mail.Address");
        Class<?> messageRecipientsType = Class.forName("jakarta.mail.Message$RecipientType");
        Class<?> transportClass = Class.forName("jakarta.mail.Transport");

        // Tạo Session
        Object session = sessionClass
                .getMethod("getInstance", Properties.class)
                .invoke(null, props);

        // Tạo MimeMessage
        Object message = mimeMessageClass.getConstructor(sessionClass).newInstance(session);

        // Set From
        Object fromAddress = internetAddressClass.getConstructor(String.class, String.class, String.class)
                .newInstance(FROM_EMAIL, FROM_NAME, "UTF-8");
        mimeMessageClass.getMethod("setFrom", addressClass).invoke(message, fromAddress);

        // Set To
        Object toAddress = internetAddressClass.getConstructor(String.class).newInstance(toEmail);
        Object toType = messageRecipientsType.getField("TO").get(null);
        mimeMessageClass.getMethod("setRecipient", messageRecipientsType, addressClass)
                .invoke(message, toType, toAddress);

        // Set Subject
        mimeMessageClass.getMethod("setSubject", String.class, String.class)
                .invoke(message, subject, "UTF-8");

        // Set Content (HTML)
        mimeMessageClass.getMethod("setContent", Object.class, String.class)
                .invoke(message, htmlContent, "text/html; charset=UTF-8");

        // Gửi email với xác thực SMTP
        System.out.println("[EmailUtil] Đang kết nối SMTP...");
        Object transport = sessionClass.getMethod("getTransport", String.class)
                .invoke(session, "smtp");

        transportClass.getMethod("connect", String.class, int.class, String.class, String.class)
                .invoke(transport, SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD);
        System.out.println("[EmailUtil] Đã kết nối SMTP, đang gửi...");

        // Lấy danh sách người nhận
        Object allRecipients = mimeMessageClass.getMethod("getAllRecipients").invoke(message);

        // sendMessage(Message, Address[])
        Class<?> addressArrayClass = java.lang.reflect.Array.newInstance(addressClass, 0).getClass();
        transportClass.getMethod("sendMessage", messageClass, addressArrayClass)
                .invoke(transport, message, allRecipients);

        transportClass.getMethod("close").invoke(transport);
        System.out.println("[EmailUtil] Email đã gửi thành công đến " + toEmail);
    }

    /**
     * Fallback: in link xác thực ra console khi không gửi được email.
     */
    private static void fallbackToConsole(String toEmail, String toName, String verificationLink) {
        System.out.println("\n================================================");
        System.out.println("  KHÔNG GỬI ĐƯỢC EMAIL - LINK XÁC THỰC (DEV MODE)");
        System.out.println("================================================");
        System.out.println("  Người nhận: " + toName + " <" + toEmail + ">");
        System.out.println("  Link xác thực:");
        System.out.println("  " + verificationLink);
        System.out.println("================================================\n");
        LOGGER.info("Link xác thực đã được in ra console cho: " + toEmail);
    }

    /**
     * Tạo nội dung HTML cho email xác thực.
     */
    private static String buildVerificationEmailHtml(String toName, String verificationLink) {
        String template = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px;">
    <table align="center" width="100%" cellpadding="0" cellspacing="0"
           style="max-width: 600px; background: #ffffff; border-radius: 12px;
                  box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden;">
        <!-- Header -->
        <tr>
            <td style="background: linear-gradient(135deg, #0d6efd, #6610f2);
                       padding: 30px 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">
                    🏥 Phòng Khám Sản
                </h1>
                <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 14px;">
                    Hệ Thống Quản Lý Lịch Hẹn Khám
                </p>
            </td>
        </tr>
        <!-- Body -->
        <tr>
            <td style="padding: 30px 25px;">
                <h2 style="color: #333; margin-top: 0;">Chào {{toName}},</h2>
                <p style="color: #555; font-size: 15px; line-height: 1.6;">
                    Cảm ơn bạn đã đăng ký tài khoản tại <strong>Phòng Khám Sản</strong>.
                    Vui lòng xác thực email của bạn bằng cách nhấn vào nút bên dưới:
                </p>

                <!-- Nút xác thực -->
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{{verificationLink}}"
                       style="display: inline-block; background: #0d6efd; color: #ffffff;
                              text-decoration: none; padding: 14px 40px; border-radius: 6px;
                              font-size: 16px; font-weight: bold;">
                        ✅ Xác Thực Email
                    </a>
                </div>

                <p style="color: #888; font-size: 13px; line-height: 1.6;">
                    Hoặc copy và dán link sau vào trình duyệt:<br>
                    <a href="{{verificationLink}}"
                       style="color: #0d6efd; word-break: break-all; font-size: 12px;">
                        {{verificationLink}}
                    </a>
                </p>

                <p style="color: #888; font-size: 13px; line-height: 1.6;">
                    <strong>Lưu ý:</strong> Link xác thực này sẽ hết hạn sau 24 giờ.
                    Nếu bạn không thực hiện đăng ký tài khoản này, vui lòng bỏ qua email này.
                </p>

                <hr style="border: none; border-top: 1px solid #eee; margin: 25px 0;">

                <p style="color: #aaa; font-size: 12px; text-align: center;">
                    © 2026 Phòng Khám Sản. Mọi quyền được bảo lưu.<br>
                    Email này được gửi tự động, vui lòng không trả lời.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>""";

        return template
                .replace("{{toName}}", toName)
                .replace("{{verificationLink}}", verificationLink);
    }

    /**
     * Gửi email đặt lại mật khẩu cho người dùng quên mật khẩu.
     *
     * @param toEmail email người nhận
     * @param toName  tên người nhận
     * @param token   password reset token
     */
    public static void sendPasswordResetEmail(String toEmail, String toName, String token) {
        String resetLink = APP_BASE_URL + "/reset-password?token=" + token;
        String subject = "\u0110\u1eb7t L\u1ea1i M\u1eadt Kh\u1ea9u - Ph\u00f2ng Kh\u00e1m S\u1ea3n";

        // Nội dung email HTML
        String htmlContent = buildResetPasswordEmailHtml(toName, resetLink);

        // Gửi email trong thread riêng để không chặn response
        new Thread(() -> {
            try {
                sendEmail(toEmail, subject, htmlContent);
                LOGGER.info("Đã gửi email đặt lại mật khẩu đến: " + toEmail);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email đặt lại mật khẩu đến " + toEmail, e);
                // Fallback: in link ra console để dev có thể test
                fallbackToConsoleReset(toEmail, toName, resetLink);
            }
        }, "EmailSender-ResetPassword-Thread").start();
    }

    /**
     * Tạo nội dung HTML cho email đặt lại mật khẩu.
     */
    private static String buildResetPasswordEmailHtml(String toName, String resetLink) {
        String template = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px;">
    <table align="center" width="100%" cellpadding="0" cellspacing="0"
           style="max-width: 600px; background: #ffffff; border-radius: 12px;
                  box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden;">
        <!-- Header -->
        <tr>
            <td style="background: linear-gradient(135deg, #fd7e14, #ffc107);
                       padding: 30px 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">
                    🔑 Đặt Lại Mật Khẩu
                </h1>
                <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 14px;">
                    Phòng Khám Sản - Hệ Thống Quản Lý Lịch Hẹn Khám
                </p>
            </td>
        </tr>
        <!-- Body -->
        <tr>
            <td style="padding: 30px 25px;">
                <h2 style="color: #333; margin-top: 0;">Chào {{toName}},</h2>
                <p style="color: #555; font-size: 15px; line-height: 1.6;">
                    Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn tại
                    <strong>Phòng Khám Sản</strong>.
                    Vui lòng nhấn vào nút bên dưới để đặt lại mật khẩu:
                </p>

                <!-- Nút đặt lại mật khẩu -->
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{{resetLink}}"
                       style="display: inline-block; background: #fd7e14; color: #ffffff;
                              text-decoration: none; padding: 14px 40px; border-radius: 6px;
                              font-size: 16px; font-weight: bold;">
                        🔑 Đặt Lại Mật Khẩu
                    </a>
                </div>

                <p style="color: #888; font-size: 13px; line-height: 1.6;">
                    Hoặc copy và dán link sau vào trình duyệt:<br>
                    <a href="{{resetLink}}"
                       style="color: #fd7e14; word-break: break-all; font-size: 12px;">
                        {{resetLink}}
                    </a>
                </p>

                <div style="background: #fff3cd; border-left: 4px solid #ffc107;
                            padding: 12px 16px; border-radius: 4px; margin: 20px 0;">
                    <p style="color: #856404; font-size: 13px; margin: 0; line-height: 1.6;">
                        <strong>⚠️ Lưu ý quan trọng:</strong><br>
                        • Link đặt lại mật khẩu này sẽ hết hạn sau <strong>1 giờ</strong>.<br>
                        • Nếu bạn <strong>không</strong> yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.
                        Tài khoản của bạn vẫn được bảo mật.
                    </p>
                </div>

                <hr style="border: none; border-top: 1px solid #eee; margin: 25px 0;">

                <p style="color: #aaa; font-size: 12px; text-align: center;">
                    © 2026 Phòng Khám Sản. Mọi quyền được bảo lưu.<br>
                    Email này được gửi tự động, vui lòng không trả lời.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>""";

        return template
                .replace("{{toName}}", toName)
                .replace("{{resetLink}}", resetLink);
    }

    /**
     * Fallback: in link đặt lại mật khẩu ra console khi không gửi được email.
     */
    private static void fallbackToConsoleReset(String toEmail, String toName, String resetLink) {
        System.out.println("\n================================================");
        System.out.println("  KHÔNG GỬI ĐƯỢC EMAIL - LINK ĐẶT LẠI MK (DEV)");
        System.out.println("================================================");
        System.out.println("  Người nhận: " + toName + " <" + toEmail + ">");
        System.out.println("  Link đặt lại mật khẩu:");
        System.out.println("  " + resetLink);
        System.out.println("================================================\n");
        LOGGER.info("Link đặt lại mật khẩu đã được in ra console cho: " + toEmail);
    }

    /**
     * Gửi email thông báo tài khoản mới được tạo bởi Admin.
     * Email chứa thông tin đăng nhập và mật khẩu.
     *
     * @param toEmail  email người nhận
     * @param toName   tên người nhận
     * @param password mật khẩu (plain text) được admin tạo
     */
    public static void sendNewAccountEmail(String toEmail, String toName, String password) {
        String loginUrl = APP_BASE_URL + "/login?prompt=1";
        String subject = "Tài Khoản Đã Được Tạo - Phòng Khám Sản";

        String htmlContent = buildNewAccountEmailHtml(toName, toEmail, password, loginUrl);

        new Thread(() -> {
            try {
                sendEmail(toEmail, subject, htmlContent);
                LOGGER.info("Đã gửi email thông tin tài khoản mới đến: " + toEmail);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email tài khoản mới đến " + toEmail, e);
                fallbackToConsoleNewAccount(toEmail, toName, password);
            }
        }, "EmailSender-NewAccount-Thread").start();
    }

    /**
     * Tạo nội dung HTML cho email thông báo tài khoản mới.
     */
    private static String buildNewAccountEmailHtml(String toName, String email, String password, String loginUrl) {
        String template = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px;">
    <table align="center" width="100%" cellpadding="0" cellspacing="0"
           style="max-width: 600px; background: #ffffff; border-radius: 12px;
                  box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden;">
        <!-- Header -->
        <tr>
            <td style="background: linear-gradient(135deg, #d27b9f, #b86689);
                       padding: 30px 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">
                    🏥 Phòng Khám Sản
                </h1>
                <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 14px;">
                    Hệ Thống Quản Lý Lịch Hẹn Khám - CAMS
                </p>
            </td>
        </tr>
        <!-- Body -->
        <tr>
            <td style="padding: 30px 25px;">
                <h2 style="color: #333; margin-top: 0;">Chào {{toName}},</h2>
                <p style="color: #555; font-size: 15px; line-height: 1.6;">
                    Quản trị viên đã tạo một tài khoản cho bạn trên hệ thống
                    <strong>Phòng Khám Sản (CAMS)</strong>.
                    Dưới đây là thông tin đăng nhập của bạn:
                </p>

                <!-- Bảng thông tin tài khoản -->
                <table align="center" width="100%" cellpadding="10" cellspacing="0"
                       style="background: #f8f9fa; border-radius: 8px; border: 1px solid #e0e0e0;
                              margin: 20px 0;">
                    <tr>
                        <td style="color: #888; font-size: 13px; width: 100px; font-weight: bold;">
                            📧 Email:
                        </td>
                        <td style="color: #333; font-size: 14px;">
                            <strong>{{email}}</strong>
                        </td>
                    </tr>
                    <tr>
                        <td style="color: #888; font-size: 13px; width: 100px; font-weight: bold;">
                            🔑 Mật khẩu:
                        </td>
                        <td style="color: #333; font-size: 14px; font-family: 'Courier New', monospace;
                                   letter-spacing: 1px;">
                            <strong>{{password}}</strong>
                        </td>
                    </tr>
                </table>

                <!-- Nút đăng nhập -->
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{{loginUrl}}"
                       style="display: inline-block; background: #b86689; color: #ffffff;
                              text-decoration: none; padding: 14px 40px; border-radius: 6px;
                              font-size: 16px; font-weight: bold;">
                        🔗 Đăng Nhập Ngay
                    </a>
                </div>

                <div style="background: #fff3cd; border-left: 4px solid #ffc107;
                            padding: 12px 16px; border-radius: 4px; margin: 20px 0;">
                    <p style="color: #856404; font-size: 13px; margin: 0; line-height: 1.6;">
                        <strong>⚠️ Lưu ý quan trọng:</strong><br>
                        • Vui lòng <strong>đổi mật khẩu</strong> ngay sau khi đăng nhập lần đầu.<br>
                        • Không chia sẻ thông tin đăng nhập này với bất kỳ ai.<br>
                        • Nếu bạn không mong đợi tài khoản này, vui lòng liên hệ quản trị viên.
                    </p>
                </div>

                <hr style="border: none; border-top: 1px solid #eee; margin: 25px 0;">

                <p style="color: #aaa; font-size: 12px; text-align: center;">
                    © 2026 Phòng Khám Sản. Mọi quyền được bảo lưu.<br>
                    Email này được gửi tự động, vui lòng không trả lời.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>""";

        return template
                .replace("{{toName}}", toName)
                .replace("{{email}}", email)
                .replace("{{password}}", password)
                .replace("{{loginUrl}}", loginUrl);
    }

    /**
     * Fallback: in thông tin tài khoản ra console khi không gửi được email.
     */
    private static void fallbackToConsoleNewAccount(String toEmail, String toName, String password) {
        System.out.println("\n================================================");
        System.out.println("  KHÔNG GỬI ĐƯỢC EMAIL - TÀI KHOẢN MỚI (DEV MODE)");
        System.out.println("================================================");
        System.out.println("  Người nhận: " + toName + " <" + toEmail + ">");
        System.out.println("  Email: " + toEmail);
        System.out.println("  Mật khẩu: " + password);
        System.out.println("================================================\n");
        LOGGER.info("Thông tin tài khoản mới đã được in ra console cho: " + toEmail);
    }

    /**
     * Gửi email xác nhận đăng ký cho người dùng đăng nhập Google lần đầu.
     * Họ cần click link trong email để xác nhận và kích hoạt tài khoản.
     *
     * @param toEmail email người nhận (Google email)
     * @param toName  tên người nhận
     * @param token   verification token
     */
    /**
     * Gửi email xác nhận đăng ký Google một cách ĐỒNG BỘ (không thread).
     * Ném exception ngay nếu gửi thất bại để caller xử lý.
     *
     * @param toEmail email người nhận
     * @param toName  tên người nhận
     * @param token   verification token
     * @throws Exception nếu không gửi được email
     */
    public static void sendGoogleConfirmationSync(String toEmail, String toName, String token)
            throws Exception {
        String verificationLink = APP_BASE_URL + "/verify-email?token=" + token;
        String subject = "Xác Nhận Đăng Ký Google - Phòng Khám Sản";
        String htmlContent = buildGoogleRegistrationEmailHtml(toName, verificationLink);

        System.out.println("[EmailUtil] Gửi đồng bộ email xác nhận Google đến: " + toEmail);
        System.out.println("[EmailUtil] Verification link: " + verificationLink);
        sendEmail(toEmail, subject, htmlContent);
        System.out.println("[EmailUtil] ĐÃ GỬI THÀNH CÔNG email xác nhận Google đến: " + toEmail);
    }

    public static void sendGoogleRegistrationConfirmationEmail(String toEmail, String toName, String token) {
        String verificationLink = APP_BASE_URL + "/verify-email?token=" + token;
        String subject = "Xác Nhận Đăng Ký Google - Phòng Khám Sản";

        String htmlContent = buildGoogleRegistrationEmailHtml(toName, verificationLink);

        System.out.println("[EmailUtil] Bắt đầu gửi email xác nhận Google đến: " + toEmail);
        System.out.println("[EmailUtil] Verification link: " + verificationLink);

        new Thread(() -> {
            try {
                sendEmail(toEmail, subject, htmlContent);
                System.out.println("[EmailUtil] ĐÃ GỬI THÀNH CÔNG email xác nhận Google đến: " + toEmail);
                LOGGER.info("Đã gửi email xác nhận đăng ký Google đến: " + toEmail);
            } catch (Exception e) {
                System.err.println("[EmailUtil] LỖI khi gửi email xác nhận Google đến " + toEmail + ": " + e.getMessage());
                e.printStackTrace(System.err);
                LOGGER.log(Level.SEVERE, "Lỗi khi gửi email xác nhận Google đến " + toEmail, e);
                fallbackToConsoleGoogleRegistration(toEmail, toName, verificationLink);
            }
        }, "EmailSender-GoogleRegistration-Thread").start();
    }

    /**
     * Tạo nội dung HTML cho email xác nhận đăng ký Google.
     */
    private static String buildGoogleRegistrationEmailHtml(String toName, String verificationLink) {
        String template = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px;">
    <table align="center" width="100%" cellpadding="0" cellspacing="0"
           style="max-width: 600px; background: #ffffff; border-radius: 12px;
                  box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden;">
        <!-- Header -->
        <tr>
            <td style="background: linear-gradient(135deg, #4285f4, #34a853);
                       padding: 30px 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">
                    <span style="font-size:28px;">G</span> Google Sign-In
                </h1>
                <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 14px;">
                    Phòng Khám Sản - Hệ Thống Quản Lý Lịch Hẹn Khám
                </p>
            </td>
        </tr>
        <!-- Body -->
        <tr>
            <td style="padding: 30px 25px;">
                <h2 style="color: #333; margin-top: 0;">Chào {{toName}},</h2>
                <p style="color: #555; font-size: 15px; line-height: 1.6;">
                    Bạn vừa đăng nhập lần đầu bằng tài khoản <strong>Google</strong> tại
                    <strong>Phòng Khám Sản (CAMS)</strong>.
                    Vui lòng nhấn vào nút bên dưới để <strong>xác nhận và kích hoạt</strong> tài khoản:
                </p>

                <!-- Nút xác nhận -->
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{{verificationLink}}"
                       style="display: inline-block; background: #4285f4; color: #ffffff;
                              text-decoration: none; padding: 14px 40px; border-radius: 6px;
                              font-size: 16px; font-weight: bold;">
                        ✅ Xác Nhận Đăng Ký
                    </a>
                </div>

                <p style="color: #888; font-size: 13px; line-height: 1.6;">
                    Hoặc copy và dán link sau vào trình duyệt:<br>
                    <a href="{{verificationLink}}"
                       style="color: #4285f4; word-break: break-all; font-size: 12px;">
                        {{verificationLink}}
                    </a>
                </p>

                <div style="background: #e8f0fe; border-left: 4px solid #4285f4;
                            padding: 12px 16px; border-radius: 4px; margin: 20px 0;">
                    <p style="color: #174ea6; font-size: 13px; margin: 0; line-height: 1.6;">
                        <strong>ℹ️ Lưu ý:</strong><br>
                        • Sau khi xác nhận, bạn có thể đăng nhập bằng Google ngay lập tức.<br>
                        • Link xác nhận này sẽ hết hạn sau <strong>24 giờ</strong>.<br>
                        • Nếu bạn <strong>không</strong> thực hiện đăng nhập này, vui lòng bỏ qua email.
                    </p>
                </div>

                <hr style="border: none; border-top: 1px solid #eee; margin: 25px 0;">

                <p style="color: #aaa; font-size: 12px; text-align: center;">
                    © 2026 Phòng Khám Sản. Mọi quyền được bảo lưu.<br>
                    Email này được gửi tự động, vui lòng không trả lời.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>""";

        return template
                .replace("{{toName}}", toName)
                .replace("{{verificationLink}}", verificationLink);
    }

    /**
     * Fallback: in link xác nhận Google ra console khi không gửi được email.
     */
    private static void fallbackToConsoleGoogleRegistration(String toEmail, String toName, String verificationLink) {
        System.out.println("\n================================================");
        System.out.println("  KHÔNG GỬI ĐƯỢC EMAIL - XÁC NHẬN GOOGLE (DEV MODE)");
        System.out.println("================================================");
        System.out.println("  Người nhận: " + toName + " <" + toEmail + ">");
        System.out.println("  Link xác nhận:");
        System.out.println("  " + verificationLink);
        System.out.println("================================================\n");
        LOGGER.info("Link xác nhận Google đã được in ra console cho: " + toEmail);
    }

    /**
     * Kiểm tra xem cấu hình email đã được thiết lập chưa.
     * @return true nếu email đã được cấu hình
     */
    public static boolean isConfigured() {
        return configured;
    }
}
