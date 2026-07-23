package com.clinic.service;

import com.clinic.config.AppConfig;
import com.clinic.config.DatabaseConfig;
import com.clinic.dao.UltrasoundOrderDAO;
import com.clinic.dao.UltrasoundImageDAO;
import com.clinic.dao.AiAnalysisResultDAO;
import com.clinic.dao.UltrasoundReviewDAO;
import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.model.UltrasoundImage;
import com.clinic.model.AiAnalysisResult;
import com.clinic.model.UltrasoundAnnotation;
import com.clinic.model.UltrasoundReport;

import java.math.BigDecimal;
import java.io.File;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Phân hệ Nghiệp vụ quản lý chỉ định siêu âm và tích hợp AI Engine.
 */
public class UltrasoundOrderService {

    /** Returned when the same ultrasound service already has an active order. */
    public static final int ACTIVE_ORDER_EXISTS = -2;

    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of(
        "appointmentDate",
        "patientName",
        "serviceName",
        "createdAt",
        "emergency",
        "orderId"
    );

    private final UltrasoundOrderDAO ultrasoundOrderDAO;
    private final UltrasoundImageDAO ultrasoundImageDAO;
    private final AiAnalysisResultDAO aiAnalysisResultDAO;
    private final UltrasoundReviewDAO ultrasoundReviewDAO;

    public UltrasoundOrderService() {
        this.ultrasoundOrderDAO = new UltrasoundOrderDAO();
        this.ultrasoundImageDAO = new UltrasoundImageDAO();
        this.aiAnalysisResultDAO = new AiAnalysisResultDAO();
        this.ultrasoundReviewDAO = new UltrasoundReviewDAO();
    }

    public List<UltrasoundWaitingPatient> getWaitingPatients(String sortBy, String sortDir) {
        return ultrasoundOrderDAO.findWaiting(normalizeSortBy(sortBy), normalizeSortDir(sortDir));
    }

    public int countWaitingPatients() {
        return ultrasoundOrderDAO.countWaiting();
    }

    public UltrasoundWaitingPatient getById(int orderId) {
        return ultrasoundOrderDAO.getById(orderId);
    }

    /** True only after the order passes the same payment gate as the work queue. */
    public boolean isReadyForSonographer(int orderId) {
        return ultrasoundOrderDAO.isReadyForSonographer(orderId);
    }

    /**
     * Lọc và phân trang danh sách chỉ định siêu âm cho Sonographer
     */
    public List<UltrasoundWaitingPatient> getOrders(int page, int pageSize, String search, String status, String date, Boolean isEmergency, String sortBy, String sortDir) {
        int offset = (page - 1) * pageSize;
        return ultrasoundOrderDAO.findAll(offset, pageSize, search, status, date, isEmergency, normalizeSortBy(sortBy), normalizeSortDir(sortDir));
    }

    public int countOrders(String search, String status, String date, Boolean isEmergency) {
        return ultrasoundOrderDAO.countAll(search, status, date, isEmergency);
    }

    public boolean startUltrasoundOrder(int orderId, int sonographerUserId) {
        if (!ultrasoundOrderDAO.isReadyForSonographer(orderId)) return false;
        return ultrasoundOrderDAO.startUltrasoundOrder(orderId, sonographerUserId);
    }

    public boolean checkSonographerOwnership(int orderId, int sonographerUserId) {
        return ultrasoundOrderDAO.checkSonographerOwnership(orderId, sonographerUserId);
    }

    public boolean checkDoctorOwnership(int orderId, int doctorUserId) {
        return ultrasoundOrderDAO.checkDoctorOwnership(orderId, doctorUserId);
    }

    public boolean checkPatientOwnership(int orderId, int patientUserId) {
        return ultrasoundOrderDAO.checkPatientOwnership(orderId, patientUserId);
    }

    public boolean isReviewSchemaSupported() {
        return ultrasoundReviewDAO.isSchemaSupported();
    }

    public UltrasoundAnnotation getCurrentAnnotation(int orderId) {
        return ultrasoundReviewDAO.getCurrentAnnotation(orderId);
    }

    public UltrasoundReport getCurrentReport(int orderId) {
        return ultrasoundReviewDAO.getCurrentReport(orderId);
    }

    public boolean saveSonographerReview(int orderId, int actorUserId, String signedName,
                                         int imageId, int imageWidth, int imageHeight,
                                         String reviewStatus, String annotationData,
                                         String rejectionReason, String imageDescription,
                                         String professionalFindings, String conclusion,
                                         boolean sign) {
        if (!isSonographerOwnershipSupported() || !isReviewSchemaSupported()
                || !checkSonographerOwnership(orderId, actorUserId)
                || !ultrasoundOrderDAO.isReadyForSonographer(orderId)) return false;

        UltrasoundWaitingPatient order = ultrasoundOrderDAO.getById(orderId);
        UltrasoundImage storedImage = ultrasoundImageDAO.getById(imageId);
        if (order == null || !"Uploaded".equalsIgnoreCase(order.getStatus())
                || storedImage == null || storedImage.getTestOrderId() != orderId
                || storedImage.getImageWidth() == null || storedImage.getImageHeight() == null
                || storedImage.getImageWidth() <= 0 || storedImage.getImageHeight() <= 0) return false;
        // Không tin naturalWidth/naturalHeight từ hidden input; dùng metadata đã
        // kiểm tra bằng ImageIO và lưu cùng ảnh lúc upload.
        imageWidth = storedImage.getImageWidth();
        imageHeight = storedImage.getImageHeight();

        String review = trimToLimit(reviewStatus, 30);
        String reason = trimToLimit(rejectionReason, 500);
        String description = trimToLimit(imageDescription, 8000);
        String findings = trimToLimit(professionalFindings, 8000);
        String finalConclusion = trimToLimit(conclusion, 8000);
        if (!Set.of("Accepted", "Corrected", "Rejected").contains(review)) return false;
        if (sign && (description.length() < 5 || findings.length() < 5 || finalConclusion.length() < 10)) {
            return false;
        }

        String source;
        String type;
        String data;
        Integer acceptedAiResultId = null;
        if ("Accepted".equals(review)) {
            AiAnalysisResult ai = aiAnalysisResultDAO
                    .getSuccessfulByImagePath(orderId, storedImage.getFilePath());
            if (ai == null || !ai.isDetected() || !isValidBoundingBox(ai, storedImage)) return false;
            source = "AI";
            type = "BoundingBox";
            data = normalizedBoundingBox(ai, imageWidth, imageHeight);
            acceptedAiResultId = ai.getId();
        } else if ("Corrected".equals(review)) {
            if (!isValidNormalizedPolygon(annotationData)) return false;
            source = "Sonographer";
            type = "Polygon";
            data = annotationData.trim();
        } else {
            if (reason.length() < 5) return false;
            source = "Sonographer";
            if (annotationData != null && !annotationData.isBlank()) {
                if (!isValidNormalizedPolygon(annotationData)) return false;
                type = "Polygon";
                data = annotationData.trim();
            } else {
                type = "None";
                data = null;
            }
        }

        return ultrasoundReviewDAO.saveReviewAndReport(orderId, actorUserId,
                trimToLimit(signedName, 200), imageId, source, type, data,
                acceptedAiResultId, imageWidth, imageHeight, review, reason.isEmpty() ? null : reason,
                description, findings, finalConclusion, sign);
    }

    /** True only when the selected database image has an acceptable AI bounding box. */
    public boolean hasAcceptableAiResultForImage(int orderId, int imageId) {
        UltrasoundImage image = ultrasoundImageDAO.getById(imageId);
        if (image == null || image.getTestOrderId() != orderId
                || image.getImageWidth() == null || image.getImageHeight() == null
                || image.getImageWidth() <= 0 || image.getImageHeight() <= 0) return false;
        AiAnalysisResult ai = aiAnalysisResultDAO
                .getSuccessfulByImagePath(orderId, image.getFilePath());
        return ai != null && ai.isDetected() && isValidBoundingBox(ai, image);
    }

    /**
     * Prevents duplicate active orders and performs order insertion + invoice creation
     * in a single atomic database transaction using WITH (UPDLOCK, HOLDLOCK).
     */
    public int createUltrasoundRequestInTransaction(int apptId, int medicalRecordId, int doctorId, int serviceId,
                                                    boolean includedInBookedAppointment, BigDecimal price, String reorderReason) {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // Khóa theo cùng thứ tự với luồng chốt hồ sơ để không thể tạo chỉ
            // định mới đồng thời với việc chuyển appointment sang Completed.
            String appointmentState = null;
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT status FROM appointments WITH (UPDLOCK, ROWLOCK) WHERE id = ? AND doctor_id = ?")) {
                ps.setInt(1, apptId);
                ps.setInt(2, doctorId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) appointmentState = rs.getString(1);
                }
            }
            if (!"InProgress".equalsIgnoreCase(appointmentState)) {
                conn.rollback();
                return -1;
            }
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT status FROM medical_records WITH (UPDLOCK, ROWLOCK) "
                            + "WHERE id = ? AND appointment_id = ?")) {
                ps.setInt(1, medicalRecordId);
                ps.setInt(2, apptId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"draft".equalsIgnoreCase(rs.getString(1))) {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            // 1. Kiểm tra active order với UPDLOCK, HOLDLOCK
            UltrasoundWaitingPatient activeOrder = ultrasoundOrderDAO.findActiveOrder(conn, medicalRecordId, serviceId);
            if (activeOrder != null) {
                conn.rollback();
                return ACTIVE_ORDER_EXISTS;
            }

            // 2. Insert test_orders
            String reason = reorderReason == null ? null : reorderReason.trim();
            int orderId = ultrasoundOrderDAO.insert(conn, medicalRecordId, doctorId, serviceId, "Pending", reason);
            if (orderId <= 0) {
                conn.rollback();
                return -1;
            }

            // 3. Tạo/Cộng dồn hóa đơn POST_EXAM nếu là dịch vụ bổ sung ngoài lịch hẹn
            if (!includedInBookedAppointment) {
                com.clinic.dao.InvoiceDAO invoiceDAO = new com.clinic.dao.InvoiceDAO();
                int invoiceId = invoiceDAO.createOrAppendPostExamServiceInvoice(conn, apptId, serviceId, price);
                if (invoiceId <= 0) {
                    conn.rollback();
                    return -1;
                }
            }

            // 4. Commit toàn bộ transaction khi cả order và invoice thành công
            conn.commit();
            return orderId;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) { }
            }
            System.err.println("[UltrasoundOrderService] createUltrasoundRequestInTransaction ERROR: " + e.getMessage());
            return -1;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) {}
                DatabaseConfig.closeConnection(conn);
            }
        }
    }

    /**
     * Thêm hình ảnh siêu âm do Sonographer tải lên và tự động chuyển sang Uploaded
     */
    public boolean uploadUltrasoundImage(UltrasoundImage img) {
        if (!isSonographerOwnershipSupported() || img == null || img.getTestOrderId() <= 0
                || img.getUploadedBy() <= 0 || !ultrasoundOrderDAO.isReadyForSonographer(img.getTestOrderId())) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            String state = null;
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT status FROM test_orders WITH (UPDLOCK, ROWLOCK) "
                            + "WHERE id = ? AND sonographer_user_id = ?")) {
                ps.setInt(1, img.getTestOrderId());
                ps.setInt(2, img.getUploadedBy());
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) state = rs.getString(1);
                }
            }
            if (!"InProgress".equalsIgnoreCase(state) && !"Uploaded".equalsIgnoreCase(state)) {
                conn.rollback();
                return false;
            }
            if (ultrasoundImageDAO.insert(conn, img) <= 0) {
                conn.rollback();
                return false;
            }
            if ("InProgress".equalsIgnoreCase(state)) {
                try (java.sql.PreparedStatement ps = conn.prepareStatement(
                        "UPDATE test_orders SET status = 'Uploaded' WHERE id = ? "
                                + "AND sonographer_user_id = ? AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) = 'INPROGRESS'")) {
                    ps.setInt(1, img.getTestOrderId());
                    ps.setInt(2, img.getUploadedBy());
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) { }
            System.err.println("[UltrasoundOrderService] upload metadata failed: " + e.getClass().getSimpleName());
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            DatabaseConfig.closeConnection(conn);
        }
    }

    /**
     * Lấy các ảnh siêu âm đã tải lên
     */
    public List<UltrasoundImage> getUltrasoundImages(int testOrderId) {
        return ultrasoundImageDAO.getByTestOrderId(testOrderId);
    }

    public UltrasoundImage getUltrasoundImageById(int imageId) {
        return ultrasoundImageDAO.getById(imageId);
    }

    /** Backfills trusted dimensions for images uploaded before V13. */
    public boolean ensureImageDimensions(UltrasoundImage image, String deployedWebRoot) {
        if (image == null) return false;
        if (image.getImageWidth() != null && image.getImageHeight() != null
                && image.getImageWidth() > 0 && image.getImageHeight() > 0) return true;
        if (deployedWebRoot == null || image.getStoredFilename() == null) return false;
        try {
            File root = new File(deployedWebRoot, AppConfig.getUploadDirectory()).getCanonicalFile();
            File file = new File(root, image.getStoredFilename()).getCanonicalFile();
            if (!file.getPath().startsWith(root.getPath() + File.separator) || !file.isFile()) return false;
            java.awt.image.BufferedImage decoded = javax.imageio.ImageIO.read(file);
            if (decoded == null || decoded.getWidth() <= 0 || decoded.getHeight() <= 0
                    || (long) decoded.getWidth() * decoded.getHeight() > 40_000_000L) return false;
            image.setImageWidth(decoded.getWidth());
            image.setImageHeight(decoded.getHeight());
            return ultrasoundImageDAO.updateDimensions(image.getId(), decoded.getWidth(), decoded.getHeight());
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isSonographerOwnershipSupported() {
        return ultrasoundOrderDAO.isSonographerOwnershipSupported();
    }

    /**
     * Gửi yêu cầu phân tích hình ảnh sang AI Engine qua HTTP
     */
    public boolean runAiAnalysis(int orderId, int actorUserId) {
        if (!isSonographerOwnershipSupported()) return false;
        UltrasoundWaitingPatient order = ultrasoundOrderDAO.getById(orderId);
        if (order == null || !ultrasoundOrderDAO.isReadyForSonographer(orderId)
                || !checkSonographerOwnership(orderId, actorUserId)
                || !"Uploaded".equalsIgnoreCase(order.getStatus())) return false;

        // Lấy danh sách ảnh đã tải lên
        List<UltrasoundImage> images = ultrasoundImageDAO.getByTestOrderId(orderId);
        if (images.isEmpty()) {
            System.err.println("[UltrasoundOrderService] Không có hình ảnh nào được upload cho orderId=" + orderId);
            return false;
        }

        // Chọn ảnh đầu tiên làm ảnh đầu vào cho AI
        UltrasoundImage targetImg = images.get(0);
        String inputImagePath = targetImg.getFilePath();

        // Chuẩn bị URL AI Engine
        String aiUrl = AppConfig.getAiBaseUrl() + AppConfig.getAiAnalyzePath();
        // Tạo JSON body đơn giản
        String jsonPayload = String.format(
            "{\"image_path\":\"%s\",\"order_id\":%d,\"original_filename\":\"%s\"}",
            escapeJson(inputImagePath.replace("\\", "/")), orderId,
            escapeJson(targetImg.getOriginalFilename())
        );

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofMillis(AppConfig.getAiConnectTimeout()))
                .build();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(aiUrl))
                .timeout(Duration.ofMillis(AppConfig.getAiReadTimeout()))
                .header("Content-Type", "application/json; charset=UTF-8")
                .header("X-OCSS-AI-Key", AppConfig.getAiInternalToken())
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        AiAnalysisResult result = new AiAnalysisResult();
        result.setTestOrderId(orderId);
        result.setStatus("Analyzing");
        result.setInputImage(inputImagePath);
        result.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));
        long staleAfterMillis = Math.max(60_000L,
                (long) AppConfig.getAiConnectTimeout() + AppConfig.getAiReadTimeout() + 30_000L);
        int aiRunId = aiAnalysisResultDAO.beginRun(orderId, inputImagePath, staleAfterMillis);
        if (aiRunId <= 0) return false;
        result.setId(aiRunId);

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            String responseBody = response.body();
            int statusCode = response.statusCode();

            if (statusCode == 200 && responseBody != null) {
                String status = extractJsonField(responseBody, "status");
                if ("Success".equalsIgnoreCase(status) || "Ok".equalsIgnoreCase(status)) {
                    boolean detected = "true".equalsIgnoreCase(extractJsonField(responseBody, "detected"));
                    String confidenceStr = extractJsonField(responseBody, "confidence");
                    BigDecimal confidence = confidenceStr != null ? new BigDecimal(confidenceStr) : BigDecimal.ZERO;
                    if (confidence.compareTo(BigDecimal.ONE) <= 0 && confidence.compareTo(BigDecimal.ZERO) > 0) {
                        confidence = confidence.multiply(new BigDecimal("100"));
                    }
                    if (confidence.compareTo(BigDecimal.ZERO) < 0 || confidence.compareTo(new BigDecimal("100")) > 0) {
                        throw new IllegalArgumentException("Độ tin cậy AI nằm ngoài khoảng hợp lệ.");
                    }
                    String message = extractJsonField(responseBody, "message");
                    String resultImage = extractJsonField(responseBody, "resultImage");
                    String maskImage = extractJsonField(responseBody, "maskImage");
                    String rawMaskImage = extractJsonField(responseBody, "rawMaskImage");
                    if (!isAllowedAiOutputPath(resultImage, orderId)
                            || !isAllowedAiOutputPath(maskImage, orderId)
                            || !isAllowedAiOutputPath(rawMaskImage, orderId)) {
                        throw new IllegalArgumentException("AI trả về đường dẫn output không hợp lệ.");
                    }
                    
                    String xminStr = extractJsonField(responseBody, "xmin");
                    String yminStr = extractJsonField(responseBody, "ymin");
                    String xmaxStr = extractJsonField(responseBody, "xmax");
                    String ymaxStr = extractJsonField(responseBody, "ymax");
                    
                    result.setStatus("Success");
                    result.setDetected(detected);
                    result.setConfidence(confidence);
                    result.setMessage(message != null ? message : "Phân tích AI hoàn tất.");
                    result.setInputImage(inputImagePath);
                    result.setResultImage(resultImage);
                    result.setMaskImage(maskImage);
                    result.setRawMaskImage(rawMaskImage);
                    if (xminStr != null) result.setXmin(Integer.parseInt(xminStr));
                    if (yminStr != null) result.setYmin(Integer.parseInt(yminStr));
                    if (xmaxStr != null) result.setXmax(Integer.parseInt(xmaxStr));
                    if (ymaxStr != null) result.setymax(Integer.parseInt(ymaxStr));
                    if (detected && !isValidBoundingBox(result, targetImg)) {
                        throw new IllegalArgumentException("Vùng AI không hợp lệ so với ảnh gốc.");
                    }
                    result.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));

                    // AI chỉ cập nhật bản ghi phân tích. Chỉ Bác sĩ Siêu âm ký mới
                    // được phép chuyển test_orders từ Uploaded sang Completed.
                    return aiAnalysisResultDAO.update(result);
                } else {
                    throw new Exception("AI Engine trả về lỗi: " + extractJsonField(responseBody, "errorMessage"));
                }
            } else {
                throw new Exception("AI HTTP Status code: " + statusCode);
            }
        } catch (Exception e) {
            System.err.println("[UltrasoundOrderService] AI analysis failed: " + e.getClass().getSimpleName());
            
            // Lưu kết quả lỗi vào DB
            result.setStatus("Failed");
            result.setErrorMessage("AI Engine tạm thời không thể hoàn tất phân tích.");
            result.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));
            aiAnalysisResultDAO.update(result);
            return false;
        }
    }

    /**
     * Lấy kết quả phân tích AI
     */
    public AiAnalysisResult getAiResult(int testOrderId) {
        return aiAnalysisResultDAO.getByTestOrderId(testOrderId);
    }

    /**
     * Returns the successful AI run bound to one concrete stored ultrasound
     * image.  Clinical screens must use this lookup instead of the newest run
     * of the order, otherwise a later analysis of another image can be shown
     * next to a signed annotation that belongs to the previous image.
     */
    public AiAnalysisResult getAiResultForImage(int testOrderId, int imageId) {
        UltrasoundImage image = ultrasoundImageDAO.getById(imageId);
        if (image == null || image.getTestOrderId() != testOrderId) return null;
        return aiAnalysisResultDAO.getSuccessfulByImagePath(testOrderId, image.getFilePath());
    }

    /**
     * Bác sĩ xác nhận kết quả phân tích AI và ghi kết luận chính thức.
     * Cập nhật trạng thái đơn từ Completed → confirmed
     * và lưu kết luận chính thức của bác sĩ vào trường message.
     */
    public boolean confirmUltrasoundResult(int orderId, int doctorUserId, String doctorMessage) {
        String notes = trimToLimit(doctorMessage, 2000);
        if (notes.length() < 20) return false;
        return ultrasoundReviewDAO.confirmSignedReport(orderId, doctorUserId, notes);
    }

    private String normalizedBoundingBox(AiAnalysisResult ai, int width, int height) {
        double x1 = clamp(ai.getXmin() / (double) width);
        double y1 = clamp(ai.getYmin() / (double) height);
        double x2 = clamp(ai.getXmax() / (double) width);
        double y2 = clamp(ai.getymax() / (double) height);
        return String.format(java.util.Locale.ROOT,
                "{\"xMin\":%.6f,\"yMin\":%.6f,\"xMax\":%.6f,\"yMax\":%.6f}",
                Math.min(x1, x2), Math.min(y1, y2), Math.max(x1, x2), Math.max(y1, y2));
    }

    private double clamp(double value) {
        return Math.max(0d, Math.min(1d, value));
    }

    private boolean isValidNormalizedPolygon(String json) {
        if (json == null || json.isBlank() || json.length() > 20000) return false;
        String compact = json.trim();
        if (!compact.startsWith("{\"points\":[") || !compact.endsWith("]}")) return false;
        Pattern pair = Pattern.compile("\\{\\s*\"x\"\\s*:\\s*(-?(?:\\d+(?:\\.\\d+)?|\\.\\d+))\\s*,\\s*\"y\"\\s*:\\s*(-?(?:\\d+(?:\\.\\d+)?|\\.\\d+))\\s*}");
        Matcher matcher = pair.matcher(compact);
        int count = 0;
        while (matcher.find()) {
            double x = Double.parseDouble(matcher.group(1));
            double y = Double.parseDouble(matcher.group(2));
            if (!Double.isFinite(x) || !Double.isFinite(y) || x < 0 || x > 1 || y < 0 || y > 1) return false;
            count++;
        }
        String structureOnly = pair.matcher(compact).replaceAll("P")
                .replaceAll("\\s+", "");
        return count >= 3 && structureOnly.matches("\\{\"points\":\\[P(?:,P)*]}" );
    }

    private String trimToLimit(String value, int maxLength) {
        if (value == null) return "";
        String trimmed = value.trim();
        return trimmed.length() <= maxLength ? trimmed : trimmed.substring(0, maxLength);
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }

    private boolean isAllowedAiOutputPath(String path, int orderId) {
        if (path == null || path.isBlank()) return true;
        String normalized = path.replace('\\', '/');
        return normalized.startsWith("uploads/ai-results/" + orderId + "/")
                && !normalized.contains("../") && !normalized.contains("/..")
                && normalized.length() <= 1000;
    }

    private boolean isValidBoundingBox(AiAnalysisResult result, UltrasoundImage image) {
        Integer x1 = result.getXmin(), y1 = result.getYmin(), x2 = result.getXmax(), y2 = result.getymax();
        if (x1 == null || y1 == null || x2 == null || y2 == null
                || x1 < 0 || y1 < 0 || x2 <= x1 || y2 <= y1) return false;
        if (image.getImageWidth() != null && image.getImageHeight() != null) {
            return x2 <= image.getImageWidth() && y2 <= image.getImageHeight();
        }
        return true;
    }

    public String normalizeSortBy(String sortBy) {
        if (sortBy == null || !ALLOWED_SORT_FIELDS.contains(sortBy)) {
            return "appointmentDate";
        }
        return sortBy;
    }

    public List<UltrasoundWaitingPatient> getOrdersByMedicalRecordId(int recordId) {
        return ultrasoundOrderDAO.getByMedicalRecordId(recordId);
    }

    public String normalizeSortDir(String sortDir) {
        return "desc".equalsIgnoreCase(sortDir) ? "desc" : "asc";
    }

    /**
     * Helper tách trường JSON thủ công bằng Regex (tránh dùng thư viện ngoài)
     */
    private String extractJsonField(String json, String fieldName) {
        Pattern pattern = Pattern.compile("\"" + fieldName + "\"\\s*:\\s*(?:\"([^\"]*)\"|([^,}\\s]*))");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            if (matcher.group(1) != null) {
                return matcher.group(1); // giá trị chuỗi
            } else if (matcher.group(2) != null) {
                String val = matcher.group(2).trim();
                if ("null".equalsIgnoreCase(val)) return null;
                return val; // giá trị số hoặc boolean
            }
        }
        return null;
    }
}
