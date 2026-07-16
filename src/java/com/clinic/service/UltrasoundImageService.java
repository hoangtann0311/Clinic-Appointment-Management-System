package com.clinic.service;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.UltrasoundImageDAO;
import com.clinic.model.UltrasoundImage;
import com.clinic.utils.AuditUtil;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.*;
import java.util.*;

/**
 * Service xử lý nghiệp vụ upload ảnh siêu âm.
 * <p>
 * <b>Quy trình:</b>
 * <ol>
 *   <li>Kiểm tra quyền truy cập — Sonographer hoặc Doctor</li>
 *   <li>Kiểm tra tính hợp lệ của tệp tin (định dạng, kích thước, số lượng)</li>
 *   <li>Lưu tệp ảnh vào thư mục lưu trữ</li>
 *   <li>Tạo bản ghi trong bảng ultrasound_images</li>
 *   <li>Tự động ghi Audit Log (SUCCESS hoặc FAILED)</li>
 * </ol>
 */
public class UltrasoundImageService {

    private final UltrasoundImageDAO ultrasoundImageDAO;

    // ── Cấu hình upload ──
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png");
    private static final Set<String> ALLOWED_MIME_TYPES = Set.of(
            "image/jpeg", "image/png", "image/jpg"
    );
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB
    private static final int MAX_IMAGES_PER_UPLOAD = 10;
    private static final String UPLOAD_DIR = "assets" + File.separator + "uploads" + File.separator + "ultrasound";

    public UltrasoundImageService() {
        this.ultrasoundImageDAO = new UltrasoundImageDAO();
    }

    /**
     * Kết quả upload — chứa danh sách ảnh đã lưu thành công và danh sách lỗi.
     */
    public static class UploadResult {
        private final List<UltrasoundImage> savedImages = new ArrayList<>();
        private final List<String> errors = new ArrayList<>();
        private int patientId;
        private String patientName;
        private int appointmentId;
        private int testOrderId;
        private String allFilenames = "";

        public boolean isSuccess() { return errors.isEmpty(); }
        public boolean hasSavedImages() { return !savedImages.isEmpty(); }
        public List<UltrasoundImage> getSavedImages() { return savedImages; }
        public List<String> getErrors() { return errors; }
        public void addError(String error) { errors.add(error); }
        public void addSavedImage(UltrasoundImage img) { savedImages.add(img); }

        public int getPatientId() { return patientId; }
        public void setPatientId(int patientId) { this.patientId = patientId; }
        public String getPatientName() { return patientName; }
        public void setPatientName(String patientName) { this.patientName = patientName; }
        public int getAppointmentId() { return appointmentId; }
        public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }
        public int getTestOrderId() { return testOrderId; }
        public void setTestOrderId(int testOrderId) { this.testOrderId = testOrderId; }
        public String getAllFilenames() { return allFilenames; }
        public void setAllFilenames(String allFilenames) { this.allFilenames = allFilenames; }
    }

    /**
     * Thực hiện upload nhiều ảnh siêu âm.
     * <p>
     * <b>Quy trình đầy đủ:</b>
     * <ol>
     *   <li>Lấy thông tin ngữ cảnh (patient, appointment) từ DB</li>
     *   <li>Validate từng file (định dạng, kích thước)</li>
     *   <li>Tạo thư mục lưu trữ nếu chưa tồn tại</li>
     *   <li>Lưu từng file với tên UUID</li>
     *   <li>INSERT bản ghi vào ultrasound_images</li>
     *   <li>Ghi Audit Log (thành công hoặc thất bại)</li>
     * </ol>
     *
     * @param request       HttpServletRequest (để lấy user, IP, và servlet context path)
     * @param fileParts     danh sách các Part chứa file upload
     * @param testOrderId   ID của test_order
     * @param patientId     ID bệnh nhân (từ form)
     * @param appointmentId ID lịch hẹn (từ form)
     * @return UploadResult chứa kết quả upload
     */
    public UploadResult uploadImages(HttpServletRequest request, Collection<Part> fileParts,
                                      int testOrderId, int patientId, int appointmentId) {
        UploadResult result = new UploadResult();
        result.setTestOrderId(testOrderId);
        result.setPatientId(patientId);
        result.setAppointmentId(appointmentId);

        // Lấy thông tin bệnh nhân từ DB
        PatientContext patientCtx = lookupPatientContext(patientId);
        result.setPatientName(patientCtx.patientName);

        // Lấy userId từ session (người thực hiện upload)
        Integer uploadedBy = getUserIdFromSession(request);

        // Lọc và validate các file parts
        List<Part> validParts = new ArrayList<>();
        List<String> filenames = new ArrayList<>();

        for (Part part : fileParts) {
            String filename = extractFilename(part);
            if (filename == null || filename.isEmpty()) {
                continue; // Bỏ qua part không phải file
            }

            filenames.add(filename);

            // Validate định dạng file
            String ext = getFileExtension(filename).toLowerCase();
            if (!ALLOWED_EXTENSIONS.contains(ext)) {
                result.addError("Định dạng file không hợp lệ: " + filename
                        + " (chỉ chấp nhận JPG, JPEG, PNG)");
                continue;
            }

            // Validate MIME type
            String mimeType = part.getContentType();
            if (mimeType != null && !ALLOWED_MIME_TYPES.contains(mimeType.toLowerCase())) {
                result.addError("Loại file không được hỗ trợ: " + filename
                        + " (" + mimeType + ")");
                continue;
            }

            // Validate kích thước
            if (part.getSize() > MAX_FILE_SIZE) {
                result.addError("File vượt quá kích thước cho phép (10MB): " + filename
                        + " (" + formatFileSize(part.getSize()) + ")");
                continue;
            }

            validParts.add(part);
        }

        result.setAllFilenames(String.join(", ", filenames));

        // Kiểm tra số lượng
        if (validParts.size() > MAX_IMAGES_PER_UPLOAD) {
            result.addError("Số lượng ảnh vượt quá giới hạn: tối đa "
                    + MAX_IMAGES_PER_UPLOAD + " ảnh mỗi lần upload");
        }

        // Nếu không có file hợp lệ nào → ghi audit log FAILED và trả về
        if (validParts.isEmpty() || !result.getErrors().isEmpty()) {
            String errorSummary = String.join("; ", result.getErrors());
            AuditUtil.logUltrasoundUploadFailed(request, patientId, patientCtx.patientName,
                    appointmentId, testOrderId, result.getAllFilenames(), errorSummary);
            return result;
        }

        // Tạo thư mục upload
        String appRealPath = request.getServletContext().getRealPath("/");
        Path uploadDir = Paths.get(appRealPath, UPLOAD_DIR);
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            result.addError("Lỗi hệ thống: không thể tạo thư mục lưu trữ ảnh");
            AuditUtil.logUltrasoundUploadFailed(request, patientId, patientCtx.patientName,
                    appointmentId, testOrderId, result.getAllFilenames(),
                    "Lỗi tạo thư mục: " + e.getMessage());
            return result;
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());

        // Lưu từng file và tạo bản ghi DB
        for (Part part : validParts) {
            try {
                String originalFilename = extractFilename(part);
                String ext = getFileExtension(originalFilename).toLowerCase();
                String storedFilename = UUID.randomUUID().toString() + ext;
                Path destPath = uploadDir.resolve(storedFilename);

                // Ghi file ra đĩa
                part.write(destPath.toString());

                long fileSize = Files.size(destPath);
                String relativePath = UPLOAD_DIR + "/" + storedFilename;

                // Tạo bản ghi DB
                UltrasoundImage image = new UltrasoundImage();
                image.setTestOrderId(testOrderId);
                image.setOriginalFilename(originalFilename);
                image.setStoredFilename(storedFilename);
                image.setFilePath(relativePath);
                image.setFileSize(fileSize);
                image.setContentType(part.getContentType());
                image.setUploadedBy(uploadedBy);
                image.setUploadedAt(now);

                if (ultrasoundImageDAO.insert(image)) {
                    result.addSavedImage(image);
                } else {
                    // Rollback: xoá file nếu DB insert thất bại
                    try { Files.deleteIfExists(destPath); } catch (IOException ignored) { }
                    result.addError("Lỗi lưu thông tin ảnh vào database: " + originalFilename);
                }
            } catch (IOException e) {
                result.addError("Lỗi lưu file: " + extractFilename(part) + " - " + e.getMessage());
            }
        }

        // Ghi Audit Log
        int savedCount = result.getSavedImages().size();
        if (savedCount > 0) {
            AuditUtil.logUltrasoundUpload(request, patientId, patientCtx.patientName,
                    appointmentId, testOrderId, savedCount, result.getAllFilenames());

            // Nếu có một số file bị lỗi, ghi thêm log cảnh báo
            if (!result.getErrors().isEmpty()) {
                AuditUtil.logUltrasoundUploadFailed(request, patientId, patientCtx.patientName,
                        appointmentId, testOrderId, result.getAllFilenames(),
                        "Một số file bị lỗi: " + String.join("; ", result.getErrors()));
            }
        } else {
            // Toàn bộ thất bại
            String errorSummary = String.join("; ", result.getErrors());
            AuditUtil.logUltrasoundUploadFailed(request, patientId, patientCtx.patientName,
                    appointmentId, testOrderId, result.getAllFilenames(), errorSummary);
        }

        return result;
    }

    /**
     * Lấy danh sách ảnh siêu âm theo test_order_id.
     */
    public List<UltrasoundImage> getImagesByTestOrderId(int testOrderId) {
        return ultrasoundImageDAO.findByTestOrderId(testOrderId);
    }

    /**
     * Lấy thông tin chi tiết một ảnh siêu âm.
     */
    public UltrasoundImage getImageById(int id) {
        return ultrasoundImageDAO.findById(id);
    }

    /**
     * Xoá một ảnh siêu âm (kèm audit log).
     */
    public boolean deleteImage(int id, HttpServletRequest request) {
        UltrasoundImage image = ultrasoundImageDAO.findById(id);
        if (image == null) return false;

        // Xoá file trên đĩa
        try {
            String appRealPath = request.getServletContext().getRealPath("/");
            Path filePath = Paths.get(appRealPath, image.getFilePath());
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            System.err.println("[UltrasoundImageService] Không thể xoá file: " + e.getMessage());
        }

        boolean deleted = ultrasoundImageDAO.delete(id);
        if (deleted) {
            AuditUtil.log(request,
                    "Xoá ảnh siêu âm: " + image.getOriginalFilename(),
                    "ultrasound_images",
                    "id=" + id + ", file=" + image.getStoredFilename(),
                    null);
        }
        return deleted;
    }

    // ── Private helpers ──

    /**
     * Tra cứu thông tin bệnh nhân từ ID.
     */
    private PatientContext lookupPatientContext(int patientId) {
        String sql = "SELECT p.full_name AS patient_name "
                   + "FROM patients p WHERE p.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new PatientContext(rs.getString("patient_name"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundImageService] lookupPatientContext ERROR: " + e.getMessage());
        }
        return new PatientContext(null);
    }

    /**
     * Lấy userId từ session.
     */
    private Integer getUserIdFromSession(HttpServletRequest request) {
        try {
            Object userObj = request.getSession(false) != null
                    ? request.getSession(false).getAttribute("user") : null;
            if (userObj instanceof com.clinic.model.User) {
                return ((com.clinic.model.User) userObj).getId();
            }
        } catch (Exception e) {
            // Ignore
        }
        return null;
    }

    /**
     * Trích xuất tên file từ Part header Content-Disposition.
     */
    private String extractFilename(Part part) {
        String contentDisposition = part.getHeader("Content-Disposition");
        if (contentDisposition == null) return null;

        for (String token : contentDisposition.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                // Xử lý: filename="tenfile.jpg" hoặc filename=tenfile.jpg
                String filename = token.substring(token.indexOf('=') + 1).trim();
                if (filename.startsWith("\"") && filename.endsWith("\"")) {
                    filename = filename.substring(1, filename.length() - 1);
                }
                // Chỉ lấy tên file, bỏ đường dẫn (IE gửi full path)
                int lastSep = Math.max(filename.lastIndexOf('/'), filename.lastIndexOf('\\'));
                if (lastSep >= 0) {
                    filename = filename.substring(lastSep + 1);
                }
                return filename;
            }
        }
        return null;
    }

    /**
     * Lấy phần mở rộng của file (bao gồm dấu chấm).
     */
    private String getFileExtension(String filename) {
        if (filename == null) return "";
        int dotIdx = filename.lastIndexOf('.');
        return dotIdx >= 0 ? filename.substring(dotIdx) : "";
    }

    /**
     * Format kích thước file thành chuỗi dễ đọc.
     */
    private String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024.0));
    }

    /**
     * Internal class — ngữ cảnh bệnh nhân.
     */
    private static class PatientContext {
        final String patientName;
        PatientContext(String patientName) { this.patientName = patientName; }
    }
}
