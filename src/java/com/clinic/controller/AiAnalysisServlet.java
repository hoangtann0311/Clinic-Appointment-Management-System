package com.clinic.controller;

import com.clinic.service.AiPredictionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.UUID;

/**
 * Servlet tiếp nhận upload ảnh siêu âm và gửi tới Python script để chạy AI cục bộ.
 */
@WebServlet("/ai/analyze")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 20 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class AiAnalysisServlet extends HttpServlet {

    private final AiPredictionService aiPredictionService = new AiPredictionService();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Part imagePart = request.getPart("image");

        if (imagePart == null || imagePart.getSize() == 0) {
            request.setAttribute("error", "Vui lòng chọn ảnh siêu âm.");
            request.getRequestDispatcher("/ai-result.jsp").forward(request, response);
            return;
        }

        // Đọc toàn bộ bytes của ảnh để tính toán mã hash MD5
        byte[] imageBytes;
        try (java.io.InputStream is = imagePart.getInputStream()) {
            imageBytes = is.readAllBytes();
        }

        String uploadId = getMD5(imageBytes);
        String uploadRoot = getServletContext().getRealPath("/uploads");

        File originalDir = new File(uploadRoot, "original");
        File resultDir = new File(uploadRoot, "ai-results/" + uploadId);

        if (!originalDir.exists()) {
            originalDir.mkdirs();
        }

        if (!resultDir.exists()) {
            resultDir.mkdirs();
        }

        String submittedFileName = imagePart.getSubmittedFileName();
        String extension = getFileExtension(submittedFileName);

        if (extension == null) {
            extension = ".jpg";
        }

        File inputFile = new File(originalDir, uploadId + extension);
        
        // Chỉ lưu tệp tin gốc nếu chưa tồn tại
        if (!inputFile.exists()) {
            Files.write(inputFile.toPath(), imageBytes);
        }

        try {
            File resultJson = new File(resultDir, "result.json");
            
            // Chỉ chạy phân tích AI nếu chưa có kết quả lưu trữ trước đó
            if (!resultJson.exists()) {
                aiPredictionService.predict(
                        inputFile.getAbsolutePath(),
                        resultDir.getAbsolutePath()
                );
            }

            String jsonContent = Files.readString(resultJson.toPath());

            String originalImageUrl =
                    request.getContextPath() + "/uploads/original/" + inputFile.getName();

            String resultImageUrl =
                    request.getContextPath() + "/uploads/ai-results/" + uploadId + "/result.png";

            request.setAttribute("jsonContent", jsonContent);
            request.setAttribute("originalImageUrl", originalImageUrl);
            request.setAttribute("resultImageUrl", resultImageUrl);

            request.getRequestDispatcher("/ai-result.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/ai-result.jsp").forward(request, response);
        }
    }

    private String getMD5(byte[] bytes) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(bytes);
            StringBuilder sb = new StringBuilder();
            for (byte b : messageDigest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            return UUID.randomUUID().toString(); // Fallback nếu không hỗ trợ MD5
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null) {
            return null;
        }

        int dotIndex = fileName.lastIndexOf(".");

        if (dotIndex == -1) {
            return null;
        }

        return fileName.substring(dotIndex);
    }
}
