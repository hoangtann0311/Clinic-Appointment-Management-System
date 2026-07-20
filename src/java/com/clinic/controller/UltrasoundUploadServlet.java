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
 * Servlet xử lý upload ảnh siêu âm (Sonographer)
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

        User user = (User) request.getSession().getAttribute("user");
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

        // Kiểm tra quyền chuyển đổi trạng thái
        // Cho phép upload nếu trạng thái là InProgress hoặc Uploaded (upload thêm ảnh)
        var order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chỉ định siêu âm.");
            return;
        }

        if (!"InProgress".equalsIgnoreCase(order.getStatus()) && !"Uploaded".equalsIgnoreCase(order.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                    + "&error=" + java.net.URLEncoder.encode("Chỉ có thể tải ảnh lên khi trạng thái là Đang thực hiện (InProgress) hoặc Đã tải ảnh (Uploaded).", "UTF-8"));
            return;
        }

        // Đường dẫn thư mục upload
        String relativeUploadDir = AppConfig.getUploadDirectory();
        String realPath = getServletContext().getRealPath("");
        String uploadPath = realPath + File.separator + relativeUploadDir;
        
        File uploadDirFile = new File(uploadPath);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
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

                    // Kiểm tra định dạng file
                    String contentType = part.getContentType();
                    if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/jpg"))) {
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                                + "&error=" + java.net.URLEncoder.encode("Chỉ hỗ trợ file ảnh định dạng JPEG, JPG hoặc PNG.", "UTF-8"));
                        return;
                    }

                    // Kiểm tra kích thước file
                    if (part.getSize() > AppConfig.getMaxFileSize()) {
                        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                                + "&error=" + java.net.URLEncoder.encode("Kích thước file không được vượt quá 10MB.", "UTF-8"));
                        return;
                    }

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
                    String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
                    String storedFileName = UUID.randomUUID().toString() + extension;
                    String filePath = uploadPath + File.separator + storedFileName;
                    String webPath = relativeUploadDir + "/" + storedFileName;

                    // Lưu file lên disk
                    part.write(filePath);

                    // Đồng thời lưu vào thư mục source để tránh bị xóa khi NetBeans tự động redeploy/rebuild
                    if (sourceUploadPath != null) {
                        try {
                            File sourceDir = new File(sourceUploadPath);
                            if (!sourceDir.exists()) {
                                sourceDir.mkdirs();
                            }
                            String sourceFilePath = sourceUploadPath + File.separator + storedFileName;
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

                    orderService.uploadUltrasoundImage(img);
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
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                    + "&error=" + java.net.URLEncoder.encode("Lỗi hệ thống khi tải ảnh lên: " + e.getMessage(), "UTF-8"));
        }
    }

    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                String filename = token.substring(token.indexOf("=") + 2, token.length() - 1);
                // Xử lý đường dẫn IE
                return Paths.get(filename).getFileName().toString();
            }
        }
        return null;
    }
}
