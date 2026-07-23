package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.service.AiPredictionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Mock AI Engine Servlet - Now integrated with the real Python script prediction.
 */
@WebServlet("/mock-ai-engine")
public class MockAiEngineServlet extends HttpServlet {

    private final AiPredictionService aiPredictionService = new AiPredictionService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Endpoint này chỉ là cầu nối nội bộ cho môi trường demo. Không cho
        // phép client bên ngoài gọi trực tiếp để chạy tiến trình AI/Python.
        if (!isLoopbackRequest(request.getRemoteAddr())
                || !constantTimeEquals(AppConfig.getAiInternalToken(), request.getHeader("X-OCSS-AI-Key"))) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    "AI mock chỉ nhận yêu cầu nội bộ từ máy chủ ứng dụng.");
            return;
        }

        // Đọc JSON payload từ request
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String jsonPayload = sb.toString();
        // Tách đường dẫn ảnh và orderId bằng regex
        String imagePath = extractJsonField(jsonPayload, "image_path");
        String orderIdStr = extractJsonField(jsonPayload, "order_id");

        if (imagePath == null || imagePath.isBlank() || orderIdStr == null || orderIdStr.isBlank()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Thiếu ảnh đầu vào hoặc mã chỉ định.");
            return;
        }

        try {
            if (Integer.parseInt(orderIdStr) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException ex) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Mã chỉ định không hợp lệ.");
            return;
        }

        // Tạo đường dẫn tuyệt đối cho file đầu vào và thư mục đầu ra
        String realPath = getServletContext().getRealPath("");
        if (realPath == null) {
            writeError(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE, "Không xác định được vùng lưu trữ ảnh.");
            return;
        }

        File inputImage;
        try {
            String normalizedImagePath = imagePath.replace('\\', '/');
            String uploadDirectory = AppConfig.getUploadDirectory().replace('\\', '/');
            while (uploadDirectory.startsWith("/")) uploadDirectory = uploadDirectory.substring(1);
            if (!normalizedImagePath.startsWith(uploadDirectory + "/")) {
                writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Đường dẫn ảnh đầu vào không hợp lệ.");
                return;
            }

            File uploadRoot = new File(realPath, uploadDirectory).getCanonicalFile();
            inputImage = new File(realPath, normalizedImagePath).getCanonicalFile();
            String rootPath = uploadRoot.getPath() + File.separator;
            if (!inputImage.getPath().startsWith(rootPath) || !inputImage.isFile()) {
                writeError(response, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy ảnh đầu vào hợp lệ.");
                return;
            }
        } catch (IOException ex) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Không thể xác minh đường dẫn ảnh đầu vào.");
            return;
        }

        String absoluteInputPath = inputImage.getPath();
        String relativeOutputDir = "uploads/ai-results/" + orderIdStr;
        String absoluteOutputDir = realPath + File.separator + relativeOutputDir;

        boolean detected = false;
        double confidence = 0.0;
        String message = "Không phát hiện u xơ tử cung.";
        String resultImageWeb = imagePath;
        String maskImageWeb = imagePath;
        String rawMaskImageWeb = imagePath;
        int xmin = 0, ymin = 0, xmax = 0, ymax = 0;
        boolean success = false;

        // Xác định thư mục source để copy lưu trữ phòng hờ rebuild xóa mất
        String sourceOutputDir = null;
        if (realPath != null) {
            if (realPath.contains("build" + File.separator + "web")) {
                sourceOutputDir = realPath.replace("build" + File.separator + "web", "web") + File.separator + relativeOutputDir;
            } else if (realPath.contains("build\\web")) {
                sourceOutputDir = realPath.replace("build\\web", "web") + File.separator + relativeOutputDir;
            } else if (realPath.contains("build/web")) {
                sourceOutputDir = realPath.replace("build/web", "web") + File.separator + relativeOutputDir;
            }
        }

        try {
            System.out.println("[MockAiEngineServlet] Calling Python script for: " + absoluteInputPath);
            aiPredictionService.predict(absoluteInputPath, absoluteOutputDir);

            // Đọc kết quả từ result.json
            File resultJsonFile = new File(absoluteOutputDir, "result.json");
            if (resultJsonFile.exists()) {
                String jsonContent = Files.readString(resultJsonFile.toPath(), java.nio.charset.StandardCharsets.UTF_8);
                System.out.println("[MockAiEngineServlet] Python output JSON: " + jsonContent);

                detected = "true".equalsIgnoreCase(extractJsonField(jsonContent, "detected"));
                String confidenceStr = extractJsonField(jsonContent, "confidence");
                if (confidenceStr != null) {
                    confidence = Double.parseDouble(confidenceStr);
                }
                message = extractJsonField(jsonContent, "message");
                
                resultImageWeb = relativeOutputDir + "/result.png";
                maskImageWeb = relativeOutputDir + "/mask.png";
                rawMaskImageWeb = relativeOutputDir + "/raw_mask.png";

                String xminStr = extractJsonField(jsonContent, "xmin");
                String yminStr = extractJsonField(jsonContent, "ymin");
                String xmaxStr = extractJsonField(jsonContent, "xmax");
                String ymaxStr = extractJsonField(jsonContent, "ymax");

                if (xminStr != null) xmin = Integer.parseInt(xminStr);
                if (yminStr != null) ymin = Integer.parseInt(yminStr);
                if (xmaxStr != null) xmax = Integer.parseInt(xmaxStr);
                if (ymaxStr != null) ymax = Integer.parseInt(ymaxStr);

                success = true;
            }
        } catch (Exception e) {
            System.err.println("[MockAiEngineServlet] Lỗi khi chạy Python: " + e.getMessage());
        }

        // Đồng bộ lưu trữ sang thư mục source (phòng hờ rebuild)
        if (success && sourceOutputDir != null) {
            try {
                File srcDirFile = new File(sourceOutputDir);
                if (!srcDirFile.exists()) {
                    srcDirFile.mkdirs();
                }
                for (String fileName : new String[]{"result.json", "result.png", "mask.png", "raw_mask.png"}) {
                    File fromFile = new File(absoluteOutputDir, fileName);
                    if (fromFile.exists()) {
                        File toFile = new File(sourceOutputDir, fileName);
                        Files.copy(fromFile.toPath(), toFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                    }
                }
                System.out.println("[MockAiEngineServlet] Copied AI results to source folder successfully.");
            } catch (Exception e) {
                System.err.println("[MockAiEngineServlet] Failed to copy AI results to source folder: " + e.getMessage());
            }
        }

        // Không được biến lỗi AI thành một kết quả lâm sàng giả. Ca sẽ quay
        // về bước tải ảnh để Bác sĩ Siêu âm thử lại hoặc xử lý theo quy trình.
        if (!success) {
            writeError(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "AI Engine chưa tạo được kết quả. Vui lòng thử lại hoặc kiểm tra dịch vụ AI.");
            return;
        }

        // Tạo JSON kết quả trả về
        String resultJson = String.format(
            "{\n" +
            "  \"status\": \"Success\",\n" +
            "  \"detected\": %b,\n" +
            "  \"confidence\": %.4f,\n" +
            "  \"message\": \"%s\",\n" +
            "  \"inputImage\": \"%s\",\n" +
            "  \"resultImage\": \"%s\",\n" +
            "  \"maskImage\": \"%s\",\n" +
            "  \"rawMaskImage\": \"%s\",\n" +
            "  \"xmin\": %d,\n" +
            "  \"ymin\": %d,\n" +
            "  \"xmax\": %d,\n" +
            "  \"ymax\": %d\n" +
            "}",
            detected, confidence, escapeJson(message), escapeJson(imagePath), escapeJson(resultImageWeb),
            escapeJson(maskImageWeb), escapeJson(rawMaskImageWeb), xmin, ymin, xmax, ymax
        );

        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            out.print(resultJson);
            out.flush();
        }
        System.out.println("[MockAiEngineServlet] Returned response successfully for orderId=" + orderIdStr);
    }

    private String extractJsonField(String json, String fieldName) {
        Pattern pattern = Pattern.compile("\"" + fieldName + "\"\\s*:\\s*(?:\"([^\"]*)\"|([^,}\\s]*))");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            if (matcher.group(1) != null) {
                return matcher.group(1);
            } else if (matcher.group(2) != null) {
                return matcher.group(2).trim();
            }
        }
        return null;
    }

    private boolean isLoopbackRequest(String remoteAddress) {
        return "127.0.0.1".equals(remoteAddress)
                || "0:0:0:0:0:0:0:1".equals(remoteAddress)
                || "::1".equals(remoteAddress)
                || "::ffff:127.0.0.1".equalsIgnoreCase(remoteAddress);
    }

    private boolean constantTimeEquals(String expected, String supplied) {
        if (expected == null || supplied == null) return false;
        return java.security.MessageDigest.isEqual(
                expected.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                supplied.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\r", "\\r").replace("\n", "\\n");
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"status\":\"Error\",\"errorMessage\":\"" + message + "\"}");
        }
    }
}
