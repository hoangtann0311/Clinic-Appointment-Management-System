package com.clinic.controller;

import com.clinic.config.AppConfig;
import com.clinic.model.UltrasoundImage;
import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

/**
 * Servlet bảo vệ quyền truy cập và phục vụ luồng byte của ảnh siêu âm y tế.
 * Thay thế việc truy cập URL tĩnh trực tiếp qua thư mục public /uploads/ultrasound.
 */
@WebServlet("/medical/ultrasound-image")
public class UltrasoundImageStreamServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = request.getSession(false) == null ? null
                : (User) request.getSession(false).getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Yêu cầu đăng nhập.");
            return;
        }

        String imageIdStr = request.getParameter("id");
        if (imageIdStr == null || imageIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số ID ảnh.");
            return;
        }

        int imageId;
        try {
            imageId = Integer.parseInt(imageIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID ảnh không hợp lệ.");
            return;
        }

        // Tìm thông tin ảnh siêu âm từ Database theo imageId
        UltrasoundImage img = orderService.getUltrasoundImageById(imageId);

        if (img == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy tệp ảnh y tế trong cơ sở dữ liệu.");
            return;
        }

        int orderId = img.getTestOrderId();
        UltrasoundWaitingPatient order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn chỉ định tương ứng.");
            return;
        }

        // Phân quyền chi tiết theo Role:
        int roleId = user.getRoleId();
        boolean authorized = false;

        if (roleId == 6) { // Sonographer
            String state = order.getStatus() == null ? "" : order.getStatus().trim();
            boolean completedState = state.equalsIgnoreCase("Completed") || state.equalsIgnoreCase("Confirmed");
            authorized = (orderService.isReadyForSonographer(orderId) 
                    && orderService.checkSonographerOwnership(orderId, user.getId()))
                    || completedState;
        } else if (roleId == 2) { // Doctor
            authorized = orderService.checkDoctorOwnership(orderId, user.getId());
        } else if (roleId == 5) { // Patient
            authorized = orderService.checkPatientOwnership(orderId, user.getId());
        }

        if (!authorized) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập tệp ảnh y tế này.");
            return;
        }

        // Xử lý và kiểm tra đường dẫn file vật lý trên đĩa
        String relativeUploadDir = AppConfig.getUploadDirectory(); // "uploads/ultrasound"
        String realPath = getServletContext().getRealPath("");
        if (realPath == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không xác định được vùng lưu trữ ảnh y tế.");
            return;
        }

        File targetFile = resolveFile(realPath, relativeUploadDir, img.getStoredFilename());

        if (targetFile == null || !targetFile.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Tệp ảnh y tế không tồn tại trên hệ thống lưu trữ.");
            return;
        }

        // Kiểm tra chống Path Traversal — so sánh với thư mục upload gốc, không phải thư mục cha của file
        File absUploadRoot = new File(AppConfig.getUltrasoundAbsoluteDir()).getCanonicalFile();
        File deployedUploadRoot = new File(new File(realPath, relativeUploadDir).getCanonicalPath());
        try {
            String absRoot = absUploadRoot.getPath() + File.separator;
            String depRoot = deployedUploadRoot.getPath() + File.separator;
            String targetPath = targetFile.getCanonicalFile().getPath();
            if (!targetPath.startsWith(absRoot) && !targetPath.startsWith(depRoot)) {
                // Thử thêm source web dir
                boolean inSource = false;
                String srcDir = resolveSourceWebDir(realPath);
                if (srcDir != null) {
                    String srcRoot = new File(srcDir, relativeUploadDir).getCanonicalPath() + File.separator;
                    if (targetPath.startsWith(srcRoot)) inSource = true;
                }
                if (!inSource) {
                    System.err.println("[UltrasoundImageStreamServlet] PHÁT HIỆN TẤN CÔNG PATH TRAVERSAL: " + targetFile.getPath());
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Đường dẫn tệp không hợp lệ.");
                    return;
                }
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không thể xác minh tính an toàn của tệp.");
            return;
        }

        // Đặt header Content-Type và ghi byte ảnh ra output stream
        String contentType = img.getContentType();
        if (contentType == null || contentType.isEmpty()) {
            contentType = Files.probeContentType(targetFile.toPath());
        }
        if (contentType == null) {
            contentType = "image/jpeg";
        }

        response.setContentType(contentType);
        response.setContentLengthLong(targetFile.length());
        response.setHeader("Cache-Control", "private, max-age=86400");

        try (var os = response.getOutputStream()) {
            Files.copy(targetFile.toPath(), os);
            os.flush();
        }
    }

    /**
     * Tìm file ảnh — thử deployed path trước, sau đó fallback về source web dir.
     * Hỗ trợ cả IntelliJ (out/artifacts), NetBeans (build/web), và production.
     */
    private File resolveFile(String realPath, String relativeDir, String filename) {
        // 0. Absolute configured path (persistent, survives redeploy)
        String absUploadDir = AppConfig.getUltrasoundAbsoluteDir();
        File absFile = new File(new File(absUploadDir), filename);
        if (absFile.isFile()) return absFile;

        // 1. Deployed path
        File deployed = new File(new File(realPath, relativeDir), filename);
        if (deployed.isFile()) return deployed;

        // 2. Source web directory fallback — thử nhiều pattern cho các IDE
        String normalized = realPath.replace('\\', '/');
        String projectWebDir = null;

        // IntelliJ: out/artifacts/..._war_exploded → web/
        int idx = normalized.indexOf("/out/artifacts/");
        if (idx >= 0) {
            projectWebDir = normalized.substring(0, idx) + "/web";
        }
        // NetBeans: build/web → web/
        if (projectWebDir == null) {
            idx = normalized.indexOf("/build/web");
            if (idx >= 0) {
                projectWebDir = normalized.substring(0, idx) + "/web";
            }
        }
        // Generic: tìm thư mục web/ trong project
        if (projectWebDir == null) {
            // Fallback: dùng user.dir nếu trùng với project
            String userDir = System.getProperty("user.dir");
            if (userDir != null) {
                File webCandidate = new File(userDir, "web");
                if (webCandidate.isDirectory()) {
                    projectWebDir = webCandidate.getAbsolutePath();
                }
            }
        }
        // Dùng web.source.dir từ config nếu được cấu hình
        if (projectWebDir == null) {
            String configured = AppConfig.get("web.source.dir", null);
            if (configured != null && !configured.isBlank()) {
                projectWebDir = configured.trim();
            }
        }

        if (projectWebDir != null) {
            File source = new File(new File(projectWebDir, relativeDir), filename);
            if (source.isFile()) return source;
        }

        // 3. Thử trực tiếp từ config nếu là absolute path
        String absDir = AppConfig.get("ultrasound.absoluteUploadDir", null);
        if (absDir != null && !absDir.isBlank()) {
            File abs = new File(new File(absDir.trim()), filename);
            if (abs.isFile()) return abs;
        }

        return deployed; // Trả về deployed để có thông báo lỗi rõ ràng
    }

    /** Trích xuất thư mục web source từ realPath (hỗ trợ IntelliJ, NetBeans). */
    private String resolveSourceWebDir(String realPath) {
        String normalized = realPath.replace('\\', '/');
        int idx = normalized.indexOf("/out/artifacts/");
        if (idx >= 0) return normalized.substring(0, idx) + "/web";
        idx = normalized.indexOf("/build/web");
        if (idx >= 0) return normalized.substring(0, idx) + "/web";
        String configured = AppConfig.get("web.source.dir", null);
        if (configured != null && !configured.isBlank()) return configured.trim();
        String userDir = System.getProperty("user.dir");
        if (userDir != null) {
            File webCandidate = new File(userDir, "web");
            if (webCandidate.isDirectory()) return webCandidate.getAbsolutePath();
        }
        return null;
    }
}
