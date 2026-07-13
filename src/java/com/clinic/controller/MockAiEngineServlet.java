package com.clinic.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Mock AI Engine Servlet.
 * Cung cấp API giả lập kết quả phân tích siêu âm của AI Engine qua kết nối HTTP thực tế.
 */
@WebServlet("/mock-ai-engine")
public class MockAiEngineServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đọc JSON payload từ request
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String jsonPayload = sb.toString();
        System.out.println("[MockAiEngineServlet] Received request payload: " + jsonPayload);

        // Tách đường dẫn ảnh và orderId bằng regex
        String imagePath = extractJsonField(jsonPayload, "image_path");
        String orderIdStr = extractJsonField(jsonPayload, "order_id");

        if (imagePath == null) {
            imagePath = "uploads/ultrasound/default.png";
        }

        // Tạo JSON kết quả giả lập
        // Trả về kết quả phát hiện bất thường ngẫu nhiên hoặc mặc định là có (true) để bác sĩ dễ test
        boolean detected = true;
        double confidence = 0.88 + Math.random() * 0.11; // 88% - 99%
        String message = "Phát hiện túi thai có kích thước bình thường, có vùng nghi ngờ xuất huyết nhẹ dưới màng đệm (khoảng 3x5mm). Cần theo dõi thêm.";

        // Sử dụng chính đường dẫn ảnh đầu vào làm ảnh kết quả/mask để hiển thị động chuẩn xác trên JSP
        String resultJson = String.format(
            "{\n" +
            "  \"status\": \"Success\",\n" +
            "  \"detected\": %b,\n" +
            "  \"confidence\": %.2f,\n" +
            "  \"message\": \"%s\",\n" +
            "  \"inputImage\": \"%s\",\n" +
            "  \"resultImage\": \"%s\",\n" +
            "  \"maskImage\": \"%s\",\n" +
            "  \"rawMaskImage\": \"%s\",\n" +
            "  \"xmin\": 120,\n" +
            "  \"ymin\": 90,\n" +
            "  \"xmax\": 320,\n" +
            "  \"ymax\": 390\n" +
            "}",
            detected, confidence, message, imagePath, imagePath, imagePath, imagePath
        );

        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Mô phỏng thời gian xử lý của AI (1.5 giây)
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(resultJson);
            out.flush();
        }
        System.out.println("[MockAiEngineServlet] Returned mock AI response successfully for orderId=" + orderIdStr);
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
}
