package com.clinic.service;

import com.clinic.config.AppConfig;
import com.clinic.dao.UltrasoundOrderDAO;
import com.clinic.dao.UltrasoundImageDAO;
import com.clinic.dao.AiAnalysisResultDAO;
import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.model.UltrasoundImage;
import com.clinic.model.AiAnalysisResult;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
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

    public UltrasoundOrderService() {
        this.ultrasoundOrderDAO = new UltrasoundOrderDAO();
        this.ultrasoundImageDAO = new UltrasoundImageDAO();
        this.aiAnalysisResultDAO = new AiAnalysisResultDAO();
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

    /**
     * Cập nhật trạng thái thủ công (có kiểm tra quy tắc chuyển đổi)
     */
    public boolean updateOrderStatus(int orderId, String targetStatus) {
        UltrasoundWaitingPatient order = ultrasoundOrderDAO.getById(orderId);
        if (order == null) return false;

        if (!checkTransition(order.getStatus(), targetStatus)) {
            System.err.println("[UltrasoundOrderService] Trạng thái chuyển đổi không hợp lệ: " + order.getStatus() + " -> " + targetStatus);
            return false;
        }

        return ultrasoundOrderDAO.updateStatus(orderId, targetStatus);
    }

    /**
     * Tạo chỉ định siêu âm mới (được gọi từ Doctor)
     */
    public int createUltrasoundRequest(int medicalRecordId, int doctorId, int serviceId) {
        return ultrasoundOrderDAO.insert(medicalRecordId, doctorId, serviceId, "Pending");
    }

    /**
     * Thêm hình ảnh siêu âm do Sonographer tải lên và tự động chuyển sang Uploaded
     */
    public boolean uploadUltrasoundImage(UltrasoundImage img) {
        int imgId = ultrasoundImageDAO.insert(img);
        if (imgId > 0) {
            // Cập nhật trạng thái chỉ định sang Uploaded
            ultrasoundOrderDAO.updateStatus(img.getTestOrderId(), "Uploaded");
            return true;
        }
        return false;
    }

    /**
     * Lấy các ảnh siêu âm đã tải lên
     */
    public List<UltrasoundImage> getUltrasoundImages(int testOrderId) {
        return ultrasoundImageDAO.getByTestOrderId(testOrderId);
    }

    /**
     * Gửi yêu cầu phân tích hình ảnh sang AI Engine qua HTTP
     */
    public boolean runAiAnalysis(int orderId, int actorUserId) {
        UltrasoundWaitingPatient order = ultrasoundOrderDAO.getById(orderId);
        if (order == null) return false;

        // Kiểm tra quy tắc chuyển trạng thái
        if (!checkTransition(order.getStatus(), "Analyzing")) {
            return false;
        }

        // Lấy danh sách ảnh đã tải lên
        List<UltrasoundImage> images = ultrasoundImageDAO.getByTestOrderId(orderId);
        if (images.isEmpty()) {
            System.err.println("[UltrasoundOrderService] Không có hình ảnh nào được upload cho orderId=" + orderId);
            return false;
        }

        // Cập nhật trạng thái sang Analyzing
        ultrasoundOrderDAO.updateStatus(orderId, "Analyzing");

        // Chọn ảnh đầu tiên làm ảnh đầu vào cho AI
        UltrasoundImage targetImg = images.get(0);
        String inputImagePath = targetImg.getFilePath();

        // Chuẩn bị URL AI Engine
        String aiUrl = AppConfig.getAiBaseUrl() + AppConfig.getAiAnalyzePath();
        System.out.println("[UltrasoundOrderService] Đang gửi yêu cầu phân tích tới AI Engine tại: " + aiUrl);

        // Tạo JSON body đơn giản
        String jsonPayload = String.format(
            "{\"image_path\":\"%s\",\"order_id\":%d,\"original_filename\":\"%s\"}",
            inputImagePath.replace("\\", "/"), orderId, targetImg.getOriginalFilename()
        );

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofMillis(AppConfig.getAiConnectTimeout()))
                .build();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(aiUrl))
                .timeout(Duration.ofMillis(AppConfig.getAiReadTimeout()))
                .header("Content-Type", "application/json; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        AiAnalysisResult result = new AiAnalysisResult();
        result.setTestOrderId(orderId);

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            String responseBody = response.body();
            int statusCode = response.statusCode();

            if (statusCode == 200 && responseBody != null) {
                System.out.println("[UltrasoundOrderService] AI Response: " + responseBody);
                
                String status = extractJsonField(responseBody, "status");
                if ("Success".equalsIgnoreCase(status) || "Ok".equalsIgnoreCase(status)) {
                    boolean detected = "true".equalsIgnoreCase(extractJsonField(responseBody, "detected"));
                    String confidenceStr = extractJsonField(responseBody, "confidence");
                    BigDecimal confidence = confidenceStr != null ? new BigDecimal(confidenceStr) : BigDecimal.ZERO;
                    if (confidence.compareTo(BigDecimal.ONE) <= 0 && confidence.compareTo(BigDecimal.ZERO) > 0) {
                        confidence = confidence.multiply(new BigDecimal("100"));
                    }
                    String message = extractJsonField(responseBody, "message");
                    String resultImage = extractJsonField(responseBody, "resultImage");
                    String maskImage = extractJsonField(responseBody, "maskImage");
                    String rawMaskImage = extractJsonField(responseBody, "rawMaskImage");
                    
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
                    result.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));

                    // Xóa kết quả AI cũ nếu có
                    aiAnalysisResultDAO.deleteByTestOrderId(orderId);
                    // Lưu kết quả AI mới
                    aiAnalysisResultDAO.insert(result);

                    // Chuyển trạng thái sang Completed
                    ultrasoundOrderDAO.updateStatus(orderId, "Completed");
                    return true;
                } else {
                    throw new Exception("AI Engine trả về lỗi: " + extractJsonField(responseBody, "errorMessage"));
                }
            } else {
                throw new Exception("AI HTTP Status code: " + statusCode);
            }
        } catch (Exception e) {
            System.err.println("[UltrasoundOrderService] Lỗi khi gọi AI Engine: " + e.getMessage());
            
            // Lưu kết quả lỗi vào DB
            result.setStatus("Failed");
            result.setErrorMessage(e.getMessage());
            result.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));
            
            aiAnalysisResultDAO.deleteByTestOrderId(orderId);
            aiAnalysisResultDAO.insert(result);

            // Rollback trạng thái về Uploaded để kỹ thuật viên có thể bấm phân tích lại
            ultrasoundOrderDAO.updateStatus(orderId, "Uploaded");
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
     * Bác sĩ xác nhận kết quả phân tích AI và ghi kết luận chính thức.
     * Cập nhật trạng thái đơn từ Completed → confirmed
     * và lưu kết luận chính thức của bác sĩ vào trường message.
     */
    public boolean confirmUltrasoundResult(int orderId, String doctorMessage) {
        UltrasoundWaitingPatient order = ultrasoundOrderDAO.getById(orderId);
        if (order == null) return false;

        // Cho phép xác nhận từ Completed, Uploaded hoặc Failed (đảm bảo luồng khám không bị gián đoạn khi AI lỗi)
        if (!"Completed".equalsIgnoreCase(order.getStatus()) 
                && !"Uploaded".equalsIgnoreCase(order.getStatus())
                && !"Failed".equalsIgnoreCase(order.getStatus())) {
            System.err.println("[UltrasoundOrderService] confirmUltrasoundResult: Đơn " + orderId
                    + " không thể xác nhận ở trạng thái hiện tại: " + order.getStatus());
            return false;
        }

        // Kiểm tra xem đã có bản ghi trong bảng ai_analysis_results chưa
        AiAnalysisResult existingResult = aiAnalysisResultDAO.getByTestOrderId(orderId);
        if (existingResult == null) {
            // Nếu chưa có (ví dụ AI lỗi hoặc không chạy AI), tạo một bản ghi rỗng để lưu kết luận của bác sĩ
            AiAnalysisResult newResult = new AiAnalysisResult();
            newResult.setTestOrderId(orderId);
            newResult.setStatus("ManualConfirmed"); // Đánh dấu là bác sĩ xác nhận thủ công
            newResult.setDetected(false); // Mặc định
            newResult.setConfidence(BigDecimal.ZERO);
            newResult.setMessage(doctorMessage != null ? doctorMessage.trim() : "Bác sĩ chốt kết luận thủ công.");
            
            // Lấy ảnh gốc đầu tiên làm ảnh đầu vào nếu có
            List<UltrasoundImage> images = ultrasoundImageDAO.getByTestOrderId(orderId);
            if (!images.isEmpty()) {
                newResult.setInputImage(images.get(0).getFilePath());
                newResult.setResultImage(images.get(0).getFilePath()); // Dùng ảnh gốc làm ảnh kết quả luôn
            }
            newResult.setAnalyzedAt(new Timestamp(System.currentTimeMillis()));
            aiAnalysisResultDAO.insert(newResult);
        } else {
            // Nếu đã có, chỉ cần cập nhật nội dung kết luận của bác sĩ
            if (doctorMessage != null && !doctorMessage.trim().isEmpty()) {
                aiAnalysisResultDAO.updateMessage(orderId, doctorMessage.trim());
            }
        }

        // Cập nhật trạng thái đơn siêu âm thành 'confirmed'
        return ultrasoundOrderDAO.updateStatus(orderId, "confirmed");
    }

    /**
     * Kiểm tra quy tắc chuyển đổi trạng thái của máy trạng thái
     */
    public boolean checkTransition(String currentStatus, String targetStatus) {
        if (currentStatus == null) return "Pending".equalsIgnoreCase(targetStatus);
        
        currentStatus = currentStatus.trim();
        targetStatus = targetStatus.trim();
        
        if (currentStatus.equalsIgnoreCase(targetStatus)) return true;
        
        if ("Cancelled".equalsIgnoreCase(targetStatus)) {
            return !"Completed".equalsIgnoreCase(currentStatus);
        }
        
        switch (currentStatus.toLowerCase()) {
            case "pending":
            case "waiting":
            case "ordered":
                return "inprogress".equalsIgnoreCase(targetStatus);
            case "inprogress":
                return "uploaded".equalsIgnoreCase(targetStatus);
            case "uploaded":
                return "analyzing".equalsIgnoreCase(targetStatus) || "uploaded".equalsIgnoreCase(targetStatus);
            case "analyzing":
                return "completed".equalsIgnoreCase(targetStatus) || "uploaded".equalsIgnoreCase(targetStatus);
            case "completed":
                return "confirmed".equalsIgnoreCase(targetStatus);
            case "confirmed":
                return false;
            default:
                return false;
        }
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

    public boolean markAsUltrasounded(int orderId) {
        return updateOrderStatus(orderId, "Completed");
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
