package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.model.UltrasoundImage;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Collection;
import java.util.UUID;

/**
 * Servlet xử lý upload ảnh siêu âm (Bác sĩ Siêu âm)
 */
@WebServlet("/sonographer/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UltrasoundUploadServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!orderService.isSonographerOwnershipSupported()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Cơ sở dữ liệu chưa được nâng cấp để quản lý người phụ trách siêu âm.");
            return;
        }

        User user = request.getSession(false) == null ? null
                : (User) request.getSession(false).getAttribute("user");
        if (user == null || user.getRoleId() != 6) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền thực hiện.");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID chỉ định siêu âm.");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chỉ định siêu âm không hợp lệ.");
            return;
        }

        // Mỗi chỉ định chỉ nhận đúng một ảnh, ở bước đang thực hiện.
        var order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chỉ định siêu âm.");
            return;
        }

        if (!orderService.isReadyForSonographer(orderId) || !orderService.checkSonographerOwnership(orderId, user.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền tải ảnh cho ca siêu âm này (đã được phụ trách bởi Bác sĩ siêu âm khác).");
            return;
        }

        if (!orderService.getUltrasoundImages(orderId).isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId
                    + "&error=" + java.net.URLEncoder.encode("Mỗi chỉ định chỉ được lưu một ảnh siêu âm.", "UTF-8"));
            return;
        }

        if (!"InProgress".equalsIgnoreCase(order.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                    + "&error=" + java.net.URLEncoder.encode("Chỉ có thể tải một ảnh khi ca đang ở bước chụp ảnh.", "UTF-8"));
            return;
        }

        // Đường dẫn thư mục upload
        String relativeUploadDir = AppConfig.getUploadDirectory();
        String realPath = getServletContext().getRealPath("");
        if (realPath == null) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Không xác định được vùng lưu trữ ảnh siêu âm.");
            return;
        }
        String uploadPath = realPath + File.separator + relativeUploadDir;
        
        File uploadDirFile = new File(uploadPath);
        if (!uploadDirFile.exists() && !uploadDirFile.mkdirs()) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Không thể chuẩn bị vùng lưu trữ ảnh siêu âm.");
            return;
        }

        // Đường dẫn thư mục nguồn (source) để tránh mất ảnh khi redeploy/rebuild
        String sourceUploadPath = null;
        if (realPath != null) {
            if (realPath.contains("build" + File.separator + "web")) {
                sourceUploadPath = realPath.replace("build" + File.separator + "web", "web") + File.separator + relativeUploadDir;
            } else if (realPath.contains("build\\web")) {
                sourceUploadPath = realPath.replace("build\\web", "web") + File.separator + relativeUploadDir;
            } else if (realPath.contains("build/web")) {
                sourceUploadPath = realPath.replace("build/web", "web") + File.separator + relativeUploadDir;
            }
        }

        try {
            Collection<Part> parts = request.getParts();
            boolean fileUploaded = false;
            boolean duplicateSkipped = false;

            for (Part part : parts) {
                if (part.getName().equals("file") && part.getSize() > 0) {
                    String originalFileName = getFileName(part);
                    if (originalFileName == null || originalFileName.isEmpty()) continue;

                    if (part.getSize() > AppConfig.getMaxFileSize()) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                                "Kích thước file vượt quá giới hạn cho phép.");
                        return;
                    }

                    // MIME/đuôi file chỉ là dữ liệu do client khai báo. Nội dung
                    // thực tế vẫn phải được ImageIO nhận diện đúng là JPEG/PNG.
                    String declaredContentType = part.getContentType();
                    if (declaredContentType == null || (!declaredContentType.equals("image/jpeg") && !declaredContentType.equals("image/png") && !declaredContentType.equals("image/jpg"))) {
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                                + "&error=" + java.net.URLEncoder.encode("Chỉ hỗ trợ file ảnh định dạng JPEG, JPG hoặc PNG.", "UTF-8"));
                        return;
                    }

                    ValidatedImage validated;
                    try {
                        validated = validateJpegOrPng(part, originalFileName, declaredContentType);
                    } catch (IllegalArgumentException ex) {
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                                    + "&error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
                        return;
                    }
                    int naturalWidth = validated.width;
                    int naturalHeight = validated.height;
                    String contentType = validated.contentType;

                    // Kiểm tra xem file ảnh trùng lặp đã được tải lên trước đó chưa (cùng tên và cùng dung lượng)
                    boolean isDuplicate = false;
                    java.util.List<com.clinic.model.UltrasoundImage> existingImages = orderService.getUltrasoundImages(orderId);
                    if (existingImages != null) {
                        for (com.clinic.model.UltrasoundImage existing : existingImages) {
                            if (originalFileName.equalsIgnoreCase(existing.getOriginalFilename()) && part.getSize() == existing.getFileSize()) {
                                isDuplicate = true;
                                break;
                            }
                        }
                    }

                    if (isDuplicate) {
                        duplicateSkipped = true;
                        continue;
                    }

                    // Tạo tên file ngẫu nhiên để tránh trùng
                    String extension = "image/png".equals(contentType) ? ".png" : ".jpg";
                    String storedFileName = UUID.randomUUID().toString() + extension;
                    File targetFile = new File(uploadPath, storedFileName);

                    // Kiểm tra chống Path Traversal
                    File canonicalDir = new File(uploadPath).getCanonicalFile();
                    if (!targetFile.getCanonicalFile().getPath().startsWith(canonicalDir.getPath())) {
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                                + "&error=" + java.net.URLEncoder.encode("Đường dẫn file không hợp lệ (Path Traversal).", "UTF-8"));
                        return;
                    }

                    String filePath = targetFile.getAbsolutePath();
                    String webPath = relativeUploadDir + "/" + storedFileName;

                    // Lưu file lên disk
                    part.write(filePath);

                    // Đồng thời lưu vào thư mục source để tránh bị xóa khi NetBeans tự động redeploy/rebuild
                    String sourceFilePath = null;
                    if (sourceUploadPath != null) {
                        try {
                            File sourceDir = new File(sourceUploadPath);
                            if (!sourceDir.exists()) {
                                sourceDir.mkdirs();
                            }
                            sourceFilePath = sourceUploadPath + File.separator + storedFileName;
                            java.nio.file.Files.copy(
                                java.nio.file.Paths.get(filePath),
                                java.nio.file.Paths.get(sourceFilePath),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING
                            );
                            System.out.println("[UltrasoundUploadServlet] Đã copy ảnh sang thư mục nguồn: " + sourceFilePath);
                        } catch (Exception e) {
                            System.err.println("[UltrasoundUploadServlet] Không thể copy ảnh sang thư mục nguồn: " + e.getMessage());
                        }
                    }

                    // Lưu metadata vào DB
                    UltrasoundImage img = new UltrasoundImage();
                    img.setTestOrderId(orderId);
                    img.setOriginalFilename(originalFileName);
                    img.setStoredFilename(storedFileName);
                    img.setFilePath(webPath);
                    img.setFileSize(part.getSize());
                    img.setContentType(contentType);
                    img.setUploadedBy(user.getId());
                    img.setImageWidth(naturalWidth);
                    img.setImageHeight(naturalHeight);

                    if (!orderService.uploadUltrasoundImage(img)) {
                        targetFile.delete();
                        if (sourceFilePath != null) {
                            try { java.nio.file.Files.deleteIfExists(java.nio.file.Paths.get(sourceFilePath)); }
                            catch (Exception ignored) { }
                        }
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId
                                + "&error=" + java.net.URLEncoder.encode("Ca siêu âm đã thay đổi trạng thái; ảnh chưa được lưu.", "UTF-8"));
                        return;
                    }
                    fileUploaded = true;
                }
            }

            if (fileUploaded) {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&success=uploaded");
            } else if (duplicateSkipped) {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                        + "&error=" + java.net.URLEncoder.encode("Hình ảnh này đã được tải lên trước đó (Trùng lặp tên file và dung lượng).", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                        + "&error=" + java.net.URLEncoder.encode("Không tìm thấy file tải lên hoặc file rỗng.", "UTF-8"));
            }

        } catch (Exception e) {
            System.err.println("[UltrasoundUploadServlet] requestId=" + request.getAttribute("requestId")
                    + " error=" + e.getClass().getSimpleName());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể tải ảnh. Vui lòng dùng mã đối chiếu để liên hệ hỗ trợ.");
        }
    }

    private String getFileName(Part part) {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.isBlank()) return null;
        try { return Paths.get(submitted).getFileName().toString(); }
        catch (Exception ignored) { return null; }
    }

    private ValidatedImage validateJpegOrPng(Part part, String originalFileName,
                                              String declaredContentType) {
        String lowerName = originalFileName == null ? "" : originalFileName.toLowerCase(java.util.Locale.ROOT);
        try (java.io.InputStream input = part.getInputStream();
             javax.imageio.stream.ImageInputStream imageInput = javax.imageio.ImageIO.createImageInputStream(input)) {
            if (imageInput == null) throw new IllegalArgumentException("Nội dung file không phải ảnh JPG/PNG hợp lệ.");
            java.util.Iterator<javax.imageio.ImageReader> readers = javax.imageio.ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) throw new IllegalArgumentException("Nội dung file không phải ảnh JPG/PNG hợp lệ.");

            javax.imageio.ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                String format = reader.getFormatName().toUpperCase(java.util.Locale.ROOT);
                boolean jpeg = "JPEG".equals(format) || "JPG".equals(format);
                boolean png = "PNG".equals(format);
                if (!jpeg && !png) {
                    throw new IllegalArgumentException("Chỉ chấp nhận nội dung ảnh JPEG/JPG hoặc PNG thực sự.");
                }
                if ((jpeg && !(lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg")))
                        || (png && !lowerName.endsWith(".png"))) {
                    throw new IllegalArgumentException("Đuôi file không khớp với định dạng ảnh thực tế.");
                }
                String normalizedDeclared = "image/jpg".equals(declaredContentType)
                        ? "image/jpeg" : declaredContentType;
                String actualContentType = png ? "image/png" : "image/jpeg";
                if (!actualContentType.equals(normalizedDeclared)) {
                    throw new IllegalArgumentException("Loại nội dung file không khớp với ảnh thực tế.");
                }

                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || (long) width * height > 40_000_000L) {
                    throw new IllegalArgumentException("Kích thước ảnh không hợp lệ hoặc vượt giới hạn an toàn.");
                }
                // Force a real decode so a header-only/truncated fake image is
                // rejected before any bytes are persisted.
                java.awt.image.BufferedImage decoded = reader.read(0);
                if (decoded == null || decoded.getWidth() != width || decoded.getHeight() != height) {
                    throw new IllegalArgumentException("Không thể giải mã đầy đủ nội dung ảnh.");
                }
                return new ValidatedImage(width, height, actualContentType);
            } finally {
                reader.dispose();
            }
        } catch (IllegalArgumentException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new IllegalArgumentException("Không thể đọc định dạng hình ảnh.");
        }
    }

    private static final class ValidatedImage {
        private final int width;
        private final int height;
        private final String contentType;

        private ValidatedImage(int width, int height, String contentType) {
            this.width = width;
            this.height = height;
            this.contentType = contentType;
        }
    }
}
