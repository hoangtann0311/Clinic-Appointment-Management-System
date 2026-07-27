package com.clinic.utils;

import com.clinic.config.AppConfig;
import com.clinic.model.User;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Phần dùng chung cho trang Hồ Sơ Cá Nhân của ba vai trò còn lại:
 * Bác sĩ siêu âm, Nhân viên lễ tân và Quản lý.
 *
 * <p><b>Phạm vi:</b> lấy người dùng từ phiên đăng nhập, chuẩn hoá và kiểm tra dữ liệu
 * nhập, lưu ảnh đại diện, gói giá trị cho nhật ký hoạt động. Lớp này KHÔNG chạm CSDL
 * và KHÔNG biết vai trò nào đang gọi mình.
 *
 * <p><b>Ảnh đại diện là tuỳ chọn:</b> vai trò không có ảnh thì đơn giản là không gọi
 * {@link #saveAvatar}. Không có cờ bật/tắt nào cần truyền, và khi làm Nhân viên hay
 * Quản lý sẽ không phải mở lại lớp này.
 *
 * <p><b>Quy ước trả về của nhóm hàm kiểm tra:</b> trả {@code null} nghĩa là hợp lệ;
 * trả chuỗi nghĩa là thông báo lỗi hiển thị thẳng cho người dùng.
 *
 * <p>Lớp này KHÔNG được dùng bởi trang hồ sơ của Quản trị viên, Bệnh nhân hay
 * Bác sĩ lâm sàng — ba trang đó giữ nguyên code cũ.
 */
public final class ProfileFormSupport {

    private ProfileFormSupport() {
        // Utility class — không khởi tạo
    }

    /** Họ tên tối đa 100 ký tự — cùng giới hạn với trang hồ sơ Quản trị viên. */
    public static final int MAX_FULL_NAME_LENGTH = 100;

    // ══════════════════════════════════════════════════════════
    // 1. PHIÊN ĐĂNG NHẬP
    // ══════════════════════════════════════════════════════════

    /**
     * Lấy người dùng từ session. Trả về {@code null} và đã tự chuyển hướng sang
     * trang đăng nhập nếu chưa đăng nhập — nơi gọi chỉ cần {@code return}.
     *
     * <p>Đây là nguồn DUY NHẤT để biết mình là ai. Id và vai trò không bao giờ
     * được đọc từ tham số request.
     */
    public static User requireSessionUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        Object obj = session.getAttribute("user");
        if (!(obj instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return (User) obj;
    }

    // ══════════════════════════════════════════════════════════
    // 2. CHUẨN HOÁ
    // ══════════════════════════════════════════════════════════

    public static String trimToEmpty(String value) {
        return (value == null) ? "" : value.trim();
    }

    public static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    // ══════════════════════════════════════════════════════════
    // 3. KIỂM TRA DỮ LIỆU
    // ══════════════════════════════════════════════════════════

    /** Họ tên: bắt buộc, tối đa 100 ký tự. Dùng cho cả ba vai trò. */
    public static String validateFullName(String fullName) {
        String value = trimToEmpty(fullName);
        if (value.isEmpty()) {
            return "Vui lòng nhập họ và tên.";
        }
        if (value.length() > MAX_FULL_NAME_LENGTH) {
            return "Họ và tên không được vượt quá " + MAX_FULL_NAME_LENGTH + " ký tự.";
        }
        return null;
    }

    /**
     * Số điện thoại lưu ở cột {@code users.phone}: để trống, hoặc đúng 10 chữ số
     * bắt đầu bằng 0.
     *
     * <p>Giữ đúng luật mà trang hồ sơ Quản trị viên đang áp cho chính cột này, để
     * hai trang cùng ghi vào một cột không sinh ra hai dạng dữ liệu khác nhau.
     */
    public static String validateUserPhone(String phone) {
        String value = trimToEmpty(phone);
        if (value.isEmpty()) {
            return null;
        }
        if (!value.matches("^0[0-9]{9}$")) {
            return "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng 0. "
                 + "Hoặc để trống nếu bạn không muốn cung cấp.";
        }
        return null;
    }

    /**
     * Số điện thoại lưu ở cột {@code doctors.phone_number}: để trống, hoặc 7–15 ký tự
     * gồm chữ số, dấu cộng, gạch ngang và khoảng trắng.
     *
     * <p>Luật này khác {@link #validateUserPhone} vì hai cột đang có hai dạng dữ liệu
     * khác nhau trong hệ thống. Gộp lại thành một luật là âm thầm đổi hành vi của cột,
     * nên giữ tách riêng.
     */
    public static String validateDoctorPhone(String phone) {
        String value = trimToEmpty(phone);
        if (value.isEmpty()) {
            return null;
        }
        if (!value.matches("^[0-9+\\-\\s]{7,15}$")) {
            return "Số điện thoại không hợp lệ.";
        }
        return null;
    }

    /** Giá trị bắt buộc nằm trong danh sách cho phép — dùng cho chuyên khoa, học vị. */
    public static String validateOneOf(String value, Set<String> allowed, String errorMessage) {
        String trimmed = trimToEmpty(value);
        if (trimmed.isEmpty()) {
            return null;
        }
        if (allowed == null || !allowed.contains(trimmed)) {
            return errorMessage;
        }
        return null;
    }

    /** Văn bản tự do có giới hạn độ dài — dùng cho giới thiệu bản thân, chứng chỉ. */
    public static String validateMaxLength(String value, int max, String fieldLabel) {
        String trimmed = trimToEmpty(value);
        if (trimmed.length() > max) {
            return fieldLabel + " không được vượt quá " + max + " ký tự.";
        }
        return null;
    }

    /** Số nguyên trong khoảng, cho phép để trống — dùng cho số năm kinh nghiệm. */
    public static String validateIntRange(String raw, int min, int max, String fieldLabel) {
        String trimmed = trimToEmpty(raw);
        if (trimmed.isEmpty()) {
            return null;
        }
        int parsed;
        try {
            parsed = Integer.parseInt(trimmed);
        } catch (NumberFormatException e) {
            return fieldLabel + " phải là một số nguyên.";
        }
        if (parsed < min || parsed > max) {
            return fieldLabel + " không hợp lệ (" + min + "–" + max + ").";
        }
        return null;
    }

    /** Chuyển chuỗi thành số nguyên, trả 0 nếu rỗng hoặc không parse được. */
    public static int parseIntOrZero(String raw) {
        String trimmed = trimToEmpty(raw);
        if (trimmed.isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(trimmed);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // ══════════════════════════════════════════════════════════
    // 4. ẢNH ĐẠI DIỆN — TUỲ CHỌN
    // Vai trò không có ảnh thì KHÔNG gọi saveAvatar().
    // ══════════════════════════════════════════════════════════

    /** Kiểu MIME được chấp nhận — giữ đúng danh sách trang hồ sơ Bác sĩ lâm sàng đang dùng. */
    private static final Set<String> ALLOWED_CONTENT_TYPES =
            Set.of("image/jpeg", "image/jpg", "image/png", "image/webp");

    /**
     * Đuôi file được phép ghi xuống đĩa.
     *
     * <p>Trang hồ sơ Bác sĩ lâm sàng KHÔNG có bước này — nó lấy nguyên đuôi từ tên
     * file người dùng gửi lên. Ở đây chốt lại bằng danh sách trắng để không ghi được
     * đuôi lạ vào thư mục webapp.
     */
    private static final Set<String> ALLOWED_EXTENSIONS =
            Set.of(".jpg", ".jpeg", ".png", ".webp");

    /** Kết quả của một lần lưu ảnh đại diện. */
    public static final class AvatarUploadResult {

        private final boolean skipped;
        private final String errorMessage;
        private final String avatarUrl;

        private AvatarUploadResult(boolean skipped, String errorMessage, String avatarUrl) {
            this.skipped = skipped;
            this.errorMessage = errorMessage;
            this.avatarUrl = avatarUrl;
        }

        /** Người dùng không chọn file mới → giữ nguyên ảnh cũ. */
        public boolean isSkipped() {
            return skipped;
        }

        public boolean isSuccess() {
            return !skipped && errorMessage == null;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        /** Đường dẫn ảnh mới. Chỉ có ý nghĩa khi {@link #isSuccess()} trả true. */
        public String getAvatarUrl() {
            return avatarUrl;
        }
    }

    /**
     * Nhận ảnh đại diện từ form multipart, kiểm tra và ghi xuống thư mục cấu hình.
     *
     * <p>Giữ nguyên cách làm của trang hồ sơ Bác sĩ lâm sàng: cùng giới hạn dung lượng
     * ({@link AppConfig#getMaxAvatarFileSize()}), cùng danh sách MIME, cùng thư mục
     * ({@link AppConfig#getAvatarUploadDirectory()}), cùng khuôn tên
     * {@code <prefix>-<id>-<uuid><ext>}.
     *
     * <p>Bổ sung hai chốt mà bản của Bác sĩ lâm sàng chưa có: danh sách trắng đuôi file,
     * và đối chiếu chữ ký byte thật của ảnh thay vì chỉ tin header Content-Type do
     * trình duyệt gửi lên.
     *
     * @param partName       tên field file trong form
     * @param fileNamePrefix tiền tố tên file lưu xuống, VD "sonographer"
     * @param ownerId        id chủ sở hữu, luôn suy ra từ session ở tầng servlet
     */
    public static AvatarUploadResult saveAvatar(HttpServletRequest request, ServletContext context,
                                                String partName, String fileNamePrefix, int ownerId)
            throws IOException, ServletException {

        // Request không phải multipart thì không có phần file nào để đọc.
        // Gọi thẳng getPart() trong trường hợp này sẽ ném ServletException và
        // làm văng HTTP 500. Coi như "không gửi ảnh mới" → giữ nguyên ảnh cũ.
        String requestContentType = request.getContentType();
        if (requestContentType == null
                || !requestContentType.toLowerCase(Locale.ROOT).startsWith("multipart/")) {
            return new AvatarUploadResult(true, null, null);
        }

        Part part = request.getPart(partName);
        if (part == null || part.getSize() <= 0) {
            return new AvatarUploadResult(true, null, null);
        }

        String originalFileName = extractFileName(part);
        if (originalFileName == null || originalFileName.isEmpty()) {
            return new AvatarUploadResult(false, "File ảnh không hợp lệ.", null);
        }

        String contentType = part.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            return new AvatarUploadResult(false,
                    "Chỉ hỗ trợ ảnh định dạng JPG, PNG hoặc WEBP.", null);
        }

        if (part.getSize() > AppConfig.getMaxAvatarFileSize()) {
            return new AvatarUploadResult(false,
                    "Kích thước ảnh không được vượt quá 5MB.", null);
        }

        int dot = originalFileName.lastIndexOf('.');
        String extension = (dot >= 0) ? originalFileName.substring(dot).toLowerCase(Locale.ROOT) : "";
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            return new AvatarUploadResult(false,
                    "Tên file phải kết thúc bằng .jpg, .jpeg, .png hoặc .webp.", null);
        }

        if (!looksLikeRealImage(part)) {
            return new AvatarUploadResult(false,
                    "Nội dung file không phải ảnh JPG, PNG hoặc WEBP hợp lệ.", null);
        }

        String relativeUploadDir = AppConfig.getAvatarUploadDirectory();
        String uploadPath = context.getRealPath("") + File.separator + relativeUploadDir;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            return new AvatarUploadResult(false,
                    "Không tạo được thư mục lưu ảnh. Vui lòng thử lại sau.", null);
        }

        String storedFileName = fileNamePrefix + "-" + ownerId + "-" + UUID.randomUUID() + extension;
        part.write(uploadPath + File.separator + storedFileName);

        String url = request.getContextPath() + "/" + relativeUploadDir + "/" + storedFileName;
        return new AvatarUploadResult(false, null, url);
    }

    /**
     * Đối chiếu vài byte đầu file với chữ ký thật của JPEG, PNG và WEBP.
     * Header Content-Type do phía gửi tự đặt nên không đủ tin cậy.
     */
    private static boolean looksLikeRealImage(Part part) throws IOException {
        byte[] head = new byte[12];
        int read = 0;
        try (InputStream in = part.getInputStream()) {
            int n;
            while (read < head.length && (n = in.read(head, read, head.length - read)) != -1) {
                read += n;
            }
        }
        if (read < 12) {
            return false;
        }

        // JPEG: FF D8 FF
        if ((head[0] & 0xFF) == 0xFF && (head[1] & 0xFF) == 0xD8 && (head[2] & 0xFF) == 0xFF) {
            return true;
        }

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        byte[] png = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A};
        boolean isPng = true;
        for (int i = 0; i < png.length; i++) {
            if (head[i] != png[i]) {
                isPng = false;
                break;
            }
        }
        if (isPng) {
            return true;
        }

        // WEBP: "RIFF" ở byte 0–3 và "WEBP" ở byte 8–11
        return head[0] == 'R' && head[1] == 'I' && head[2] == 'F' && head[3] == 'F'
            && head[8] == 'W' && head[9] == 'E' && head[10] == 'B' && head[11] == 'P';
    }

    /**
     * Lấy tên file gốc từ header content-disposition, đã cắt bỏ mọi thành phần
     * đường dẫn. Giữ đúng cách trang hồ sơ Bác sĩ lâm sàng đang làm.
     */
    private static String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) {
            return null;
        }
        for (String token : contentDisposition.split(";")) {
            String trimmed = token.trim();
            if (trimmed.startsWith("filename")) {
                int start = trimmed.indexOf('=');
                if (start < 0 || trimmed.length() < start + 3) {
                    return null;
                }
                String raw = trimmed.substring(start + 2, trimmed.length() - 1);
                if (raw.isEmpty()) {
                    return null;
                }
                // Cắt cả kiểu Windows lẫn Unix — Paths.get() chỉ hiểu kiểu của HĐH đang chạy.
                raw = raw.replace('\\', '/');
                int slash = raw.lastIndexOf('/');
                if (slash >= 0) {
                    raw = raw.substring(slash + 1);
                }
                return Paths.get(raw).getFileName().toString();
            }
        }
        return null;
    }

    // ══════════════════════════════════════════════════════════
    // 5. NHẬT KÝ HOẠT ĐỘNG
    // ══════════════════════════════════════════════════════════

    /**
     * Gói các trường thành JSON cho cột {@code old_value} / {@code new_value} của
     * bảng {@code audit_logs}. Dùng {@link LinkedHashMap} để thứ tự trường ổn định
     * giữa hai lần gọi, nhờ đó dòng cũ và dòng mới so sánh được với nhau.
     */
    public static String buildAuditJson(Map<String, String> fields) {
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, String> entry : fields.entrySet()) {
            if (!first) {
                json.append(',');
            }
            first = false;
            json.append('"').append(escapeJson(entry.getKey())).append("\":\"")
                .append(escapeJson(entry.getValue())).append('"');
        }
        return json.append('}').toString();
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
