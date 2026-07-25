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

        com.clinic.model.UltrasoundWaitingPatient order = orderService.getById(orderId);
        String state = order == null || order.getStatus() == null ? "" : order.getStatus().trim();
        boolean completedState = state.equalsIgnoreCase("Completed") || state.equalsIgnoreCase("Confirmed");

        int roleId = user.getRoleId();
        boolean authorized = (roleId == 2 && orderService.checkDoctorOwnership(orderId, user.getId()))
                || (roleId == 6 && (completedState || (orderService.isReadyForSonographer(orderId)
                    && orderService.checkSonographerOwnership(orderId, user.getId()))))
                || (roleId == 5 && orderService.checkPatientOwnership(orderId, user.getId()));
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

        if ("mask".equals(type) || "raw-mask".equals(type)) {
            try {
                java.awt.image.BufferedImage img = javax.imageio.ImageIO.read(imageFile);
                if (img != null) {
                    int w = img.getWidth(), h = img.getHeight();
                    java.awt.image.BufferedImage transparentMask = new java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_INT_ARGB);
                    for (int y = 0; y < h; y++) {
                        for (int x = 0; x < w; x++) {
                            int pixel = img.getRGB(x, y);
                            int red = (pixel >> 16) & 0xFF;
                            int green = (pixel >> 8) & 0xFF;
                            int blue = pixel & 0xFF;
                            int alpha = img.getColorModel().hasAlpha() ? ((pixel >> 24) & 0xFF) : 255;
                            // Nếu là pixel vùng tổn thương (nền trắng hoặc có điểm màu)
                            if (alpha > 0 && (red > 50 || green > 50 || blue > 50)) {
                                // Màu đỏ thẫm bán trong suốt ARGB: (alpha=140, red=220, green=38, blue=38)
                                int argb = (140 << 24) | (220 << 16) | (38 << 8) | 38;
                                transparentMask.setRGB(x, y, argb);
                            } else {
                                // Nền trong suốt hoàn toàn ARGB = 0
                                transparentMask.setRGB(x, y, 0);
                            }
                        }
                    }
                    response.setContentType("image/png");
                    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                    response.setHeader("Pragma", "no-cache");
                    response.setDateHeader("Expires", 0);
                    javax.imageio.ImageIO.write(transparentMask, "png", response.getOutputStream());
                    return;
                }
            } catch (Exception ex) {
                System.err.println("[AiImageStreamServlet] Render transparent mask error: " + ex.getMessage());
            }
        }

        String contentType = Files.probeContentType(imageFile.toPath());
        response.setContentType(contentType == null ? "image/png" : contentType);
        response.setContentLengthLong(imageFile.length());
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
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

        // 0. Absolute configured path (persistent storage, survives redeploy)
        String absDir = AppConfig.getAiResultsAbsoluteDir();
        if (absDir != null && !absDir.isBlank()) {
            // Trích xuất phần tương đối sau "uploads/ai-results/" hoặc uploadRoot
            String relPart = normalized;
            if (normalized.startsWith(aiRoot + "/")) relPart = normalized.substring(aiRoot.length() + 1);
            else if (normalized.startsWith(uploadRoot + "/")) relPart = normalized.substring(uploadRoot.length() + 1);
            File absFile = new File(new File(absDir.trim()), relPart).getCanonicalFile();
            if (absFile.isFile()) return absFile;
        }

        String realPath = getServletContext().getRealPath("");
        if (realPath == null) return null;

        // 1. Deployed path
        File deployedFile = new File(realPath, normalized).getCanonicalFile();
        if (deployedFile.isFile()) return deployedFile;

        // 2. Source web dir fallback — hỗ trợ IntelliJ, NetBeans
        String normalizedRp = realPath.replace('\\', '/');
        String projectWebDir = null;
        int idx = normalizedRp.indexOf("/out/artifacts/");
        if (idx >= 0) { projectWebDir = normalizedRp.substring(0, idx) + "/web"; }
        if (projectWebDir == null) {
            idx = normalizedRp.indexOf("/build/web");
            if (idx >= 0) { projectWebDir = normalizedRp.substring(0, idx) + "/web"; }
        }
        if (projectWebDir == null) {
            String configured = AppConfig.get("web.source.dir", null);
            if (configured != null && !configured.isBlank()) projectWebDir = configured.trim();
        }
        if (projectWebDir == null) {
            String userDir = System.getProperty("user.dir");
            if (userDir != null) {
                File webCandidate = new File(userDir, "web");
                if (webCandidate.isDirectory()) projectWebDir = webCandidate.getAbsolutePath();
            }
        }
        if (projectWebDir != null) {
            File sourceFile = new File(projectWebDir, normalized).getCanonicalFile();
            if (sourceFile.isFile()) return sourceFile;
        }

        return null;
    }

    private boolean isInside(File root, File candidate) {
        return candidate.getPath().startsWith(root.getPath() + File.separator);
    }
}
