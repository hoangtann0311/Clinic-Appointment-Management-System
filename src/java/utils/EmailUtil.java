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
        // Sử dụng reflection để không crash nếu thiếu JAR
        try {
            sendEmailWithJakartaMail(toEmail, subject, htmlContent);
        } catch (ClassNotFoundException e) {
            throw new Exception("Thiếu thư viện Jakarta Mail. "
                    + "Vui lòng thêm angus-mail-2.0.3.jar và angus-activation-2.0.2.jar "
                    + "vào WEB-INF/lib/.", e);
        }
    }

    /**
     * Gửi email sử dụng Jakarta Mail API qua reflection.
     * Dùng reflection để tránh lỗi biên dịch khi IDE không nhận diện được JAR,
     * mặc dù JAR đã có trong WEB-INF/lib/ và được khai báo trong javac.classpath.
     */
    private static void sendEmailWithJakartaMail(String toEmail, String subject, String htmlContent)
            throws Exception {

        // Tạo Properties cho SMTP
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(SMTP_PORT));
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        // Cache các class để dùng nhiều lần
        Class<?> sessionClass = Class.forName("jakarta.mail.Session");
        Class<?> messageClass = Class.forName("jakarta.mail.Message");        // Interface cha của MimeMessage
        Class<?> mimeMessageClass = Class.forName("jakarta.mail.internet.MimeMessage");
        Class<?> internetAddressClass = Class.forName("jakarta.mail.internet.InternetAddress");
        Class<?> addressClass = Class.forName("jakarta.mail.Address");
        Class<?> messageRecipientsType = Class.forName("jakarta.mail.Message$RecipientType");
        Class<?> transportClass = Class.forName("jakarta.mail.Transport");

        // Tạo Session (không cần Authenticator vì sẽ dùng Transport.connect)
        Object session = sessionClass
                .getMethod("getInstance", Properties.class)
                .invoke(null, props);

        // Tạo MimeMessage
        Object message = mimeMessageClass.getConstructor(sessionClass).newInstance(session);

        // Set From: message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME, "UTF-8"))
        Object fromAddress = internetAddressClass.getConstructor(String.class, String.class, String.class)
                .newInstance(FROM_EMAIL, FROM_NAME, "UTF-8");
        mimeMessageClass.getMethod("setFrom", addressClass)
                .invoke(message, fromAddress);

        // Set To: message.setRecipient(RecipientType.TO, new InternetAddress(toEmail))
        // Dùng setRecipient (số ít, tham số Address đơn) — KHÔNG phải setRecipients (số nhiều, tham số Address[])
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

        // Gửi email với xác thực SMTP:
        // Transport transport = session.getTransport("smtp");
        // transport.connect(host, port, user, password);
        // transport.sendMessage(message, message.getAllRecipients());
        // transport.close();
        Object transport = sessionClass.getMethod("getTransport", String.class)
                .invoke(session, "smtp");

        transportClass.getMethod("connect", String.class, int.class, String.class, String.class)
                .invoke(transport, SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD);

        // Lấy danh sách người nhận
        Object allRecipients = mimeMessageClass.getMethod("getAllRecipients").invoke(message);

        // sendMessage(Message, Address[]) - tham số đầu là jakarta.mail.Message (interface)
        Class<?> addressArrayClass = java.lang.reflect.Array.newInstance(addressClass, 0).getClass();
        transportClass.getMethod("sendMessage", messageClass, addressArrayClass)
                .invoke(transport, message, allRecipients);

        transportClass.getMethod("close").invoke(transport);

        LOGGER.info("Email đã được gửi thành công đến " + toEmail);
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
     * Kiểm tra xem cấu hình email đã được thiết lập chưa.
     * @return true nếu email đã được cấu hình
     */
    public static boolean isConfigured() {
        return configured;
    }
}
