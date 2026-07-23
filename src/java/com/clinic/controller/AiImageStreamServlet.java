package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.model.AiAnalysisResult;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

/**
 * Streams internal AI images only to the ordering clinical doctor or the
 * ultrasound specialist assigned to the order.  AI images are never exposed
 * through the public static uploads directory or to patients.
 */
@WebServlet("/medical/ai-image")
public class AiImageStreamServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Yêu cầu đăng nhập.");
            return;
        }

        int orderId;
        int imageId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
            imageId = Integer.parseInt(request.getParameter("imageId"));
            if (orderId <= 0 || imageId <= 0) throw new NumberFormatException();
        } catch (Exception ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã chỉ định hoặc mã ảnh không hợp lệ.");
            return;
        }

        int roleId = user.getRoleId();
        boolean authorized = (roleId == 2 && orderService.checkDoctorOwnership(orderId, user.getId()))
                || (roleId == 6 && orderService.isReadyForSonographer(orderId)
                    && orderService.checkSonographerOwnership(orderId, user.getId()));
        if (!authorized) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem ảnh phân tích AI của ca này.");
            return;
        }

        // Never serve the newest result of the whole order blindly. The result
        // must identify exactly the requested database image.
        AiAnalysisResult result = orderService.getAiResultForImage(orderId, imageId);
        if (result == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ảnh này chưa có kết quả AI hợp lệ.");
            return;
        }

        String type = request.getParameter("type");
        String relativePath;
        if ("result".equals(type)) {
            relativePath = result.getResultImage();
        } else if ("mask".equals(type)) {
            relativePath = result.getMaskImage();
        } else if ("raw-mask".equals(type)) {
            relativePath = result.getRawMaskImage();
        } else if ("input".equals(type) || "raw".equals(type)) {
            relativePath = result.getInputImage();
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Loại ảnh AI không hợp lệ.");
            return;
        }

        File imageFile = resolveAiImage(relativePath);
        if (imageFile == null || !imageFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy tệp ảnh AI.");
            return;
        }

        String contentType = Files.probeContentType(imageFile.toPath());
        response.setContentType(contentType == null ? "image/png" : contentType);
        response.setContentLengthLong(imageFile.length());
        response.setHeader("Cache-Control", "private, no-store");
        try (var output = response.getOutputStream()) {
            Files.copy(imageFile.toPath(), output);
        }
    }

    private File resolveAiImage(String relativePath) throws IOException {
        if (relativePath == null || relativePath.isBlank()) return null;
        String normalized = relativePath.replace('\\', '/');
        String aiRoot = "uploads/ai-results";
        String uploadRoot = AppConfig.getUploadDirectory();
        if (!normalized.startsWith(aiRoot + "/") && !normalized.startsWith(uploadRoot + "/")) return null;

        String realPath = getServletContext().getRealPath("");
        if (realPath == null) return null;

        File deployedFile = new File(realPath, normalized).getCanonicalFile();
        File deployedAiRoot = new File(realPath, aiRoot).getCanonicalFile();
        File deployedUploadRoot = new File(realPath, uploadRoot).getCanonicalFile();
        if ((isInside(deployedAiRoot, deployedFile) || isInside(deployedUploadRoot, deployedFile)) && deployedFile.isFile()) {
            return deployedFile;
        }

        if (realPath.contains("build\\web") || realPath.contains("build/web")) {
            String sourceRootPath = realPath.replace("build\\web", "web").replace("build/web", "web");
            File sourceFile = new File(sourceRootPath, normalized).getCanonicalFile();
            File sourceAiRoot = new File(sourceRootPath, aiRoot).getCanonicalFile();
            File sourceUploadRoot = new File(sourceRootPath, uploadRoot).getCanonicalFile();
            if ((isInside(sourceAiRoot, sourceFile) || isInside(sourceUploadRoot, sourceFile)) && sourceFile.isFile()) {
                return sourceFile;
            }
        }
        return null;
    }

    private boolean isInside(File root, File candidate) {
        return candidate.getPath().startsWith(root.getPath() + File.separator);
    }
}
