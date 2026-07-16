package controller;

import com.clinic.config.AuthorizationConfig;
import com.clinic.model.UltrasoundImage;
import com.clinic.service.UltrasoundImageService;
import com.clinic.service.UltrasoundImageService.UploadResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.Collection;
import java.util.List;

/**
 * Servlet xử lý upload ảnh siêu âm cho Sonographer và Doctor.
 * <p>
 * <b>GET</b>  → hiển thị form upload ảnh siêu âm
 * <b>POST</b> → xử lý upload nhiều ảnh (multipart/form-data)
 * <p>
 * Yêu cầu quyền: ultrasound.upload (Sonographer, Doctor có quyền upload)
 * <p>
 * Cấu hình upload:
 * <ul>
 *   <li>Max file size: 10 MB / file</li>
 *   <li>Max request size: 100 MB / request</li>
 *   <li>Max files: 10 ảnh / lần upload</li>
 *   <li>File size threshold: 1 MB (ghi vào disk nếu vượt quá)</li>
 * </ul>
 */
@WebServlet(urlPatterns = {"/sonographer/upload", "/sonographer/upload/",
                            "/doctor/upload", "/doctor/upload/"})
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,       // 10 MB / file
    maxRequestSize = 100 * 1024 * 1024,    // 100 MB / request
    fileSizeThreshold = 1024 * 1024        // 1 MB buffer
)
public class SonographerUploadServlet extends HttpServlet {

    private UltrasoundImageService ultrasoundImageService;

    @Override
    public void init() throws ServletException {
        ultrasoundImageService = new UltrasoundImageService();
    }

    /**
     * GET — hiển thị form upload ảnh siêu âm.
     * Hỗ trợ tham số:
     * <ul>
     *   <li>testOrderId — ID của test_order (bắt buộc)</li>
     *   <li>patientId — ID bệnh nhân (bắt buộc)</li>
     *   <li>appointmentId — ID lịch hẹn (bắt buộc)</li>
     * </ul>
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đọc tham số từ query string
        String testOrderIdStr = req.getParameter("testOrderId");
        String patientIdStr = req.getParameter("patientId");
        String appointmentIdStr = req.getParameter("appointmentId");

        req.setAttribute("testOrderId", testOrderIdStr);
        req.setAttribute("patientId", patientIdStr);
        req.setAttribute("appointmentId", appointmentIdStr);

        // Lấy danh sách ảnh đã upload (nếu có testOrderId)
        if (testOrderIdStr != null && !testOrderIdStr.isEmpty()) {
            try {
                int testOrderId = Integer.parseInt(testOrderIdStr);
                List<UltrasoundImage> existingImages =
                        ultrasoundImageService.getImagesByTestOrderId(testOrderId);
                req.setAttribute("existingImages", existingImages);
            } catch (NumberFormatException e) {
                // Bỏ qua — không load ảnh cũ
            }
        }

        // Hiển thị thông báo từ query string (sau redirect)
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        // Forward đến JSP phù hợp theo role
        String servletPath = req.getServletPath();
        if (servletPath.startsWith("/doctor")) {
            req.getRequestDispatcher("/views/doctor/ultrasound-upload.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/views/sonographer/upload.jsp").forward(req, resp);
        }
    }

    /**
     * POST — xử lý upload ảnh siêu âm.
     * Form gửi lên dạng multipart/form-data với các trường:
     * <ul>
     *   <li>images — một hoặc nhiều file ảnh (Part name="images")</li>
     *   <li>testOrderId — ID test_order (hidden field)</li>
     *   <li>patientId — ID bệnh nhân (hidden field)</li>
     *   <li>appointmentId — ID lịch hẹn (hidden field)</li>
     * </ul>
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đọc tham số từ form (multipart — getParameter vẫn hoạt động với @MultipartConfig)
        String testOrderIdStr = req.getParameter("testOrderId");
        String patientIdStr = req.getParameter("patientId");
        String appointmentIdStr = req.getParameter("appointmentId");

        // Base redirect URL
        String servletPath = req.getServletPath();
        String redirectBase = req.getContextPath() + servletPath;

        // Validate tham số bắt buộc
        int testOrderId, patientId, appointmentId;
        try {
            testOrderId = Integer.parseInt(testOrderIdStr != null ? testOrderIdStr : "0");
            patientId = Integer.parseInt(patientIdStr != null ? patientIdStr : "0");
            appointmentId = Integer.parseInt(appointmentIdStr != null ? appointmentIdStr : "0");
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirectBase
                    + "?error=Tham+số+không+hợp+lệ&testOrderId="
                    + (testOrderIdStr != null ? testOrderIdStr : "")
                    + "&patientId=" + (patientIdStr != null ? patientIdStr : "")
                    + "&appointmentId=" + (appointmentIdStr != null ? appointmentIdStr : ""));
            return;
        }

        if (testOrderId <= 0 || patientId <= 0 || appointmentId <= 0) {
            resp.sendRedirect(redirectBase
                    + "?error=Thiếu+thông+tin+bắt+buộc+(testOrderId,+patientId,+appointmentId)");
            return;
        }

        // Lấy danh sách file upload
        Collection<Part> fileParts;
        try {
            fileParts = req.getParts();
        } catch (ServletException | IOException e) {
            resp.sendRedirect(redirectBase
                    + "?error=Lỗi+đọc+dữ+liệu+upload:+"
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
                    + "&testOrderId=" + testOrderId + "&patientId=" + patientId
                    + "&appointmentId=" + appointmentId);
            return;
        }

        if (fileParts == null || fileParts.isEmpty()) {
            resp.sendRedirect(redirectBase
                    + "?error=Vui+lòng+chọn+ít+nhất+một+ảnh+để+upload"
                    + "&testOrderId=" + testOrderId + "&patientId=" + patientId
                    + "&appointmentId=" + appointmentId);
            return;
        }

        // Thực hiện upload
        UploadResult result = ultrasoundImageService.uploadImages(
                req, fileParts, testOrderId, patientId, appointmentId);

        // Redirect với kết quả
        if (result.hasSavedImages()) {
            int count = result.getSavedImages().size();
            String msg = "Upload+thành+công+" + count + "+ảnh+siêu+âm";
            if (!result.getErrors().isEmpty()) {
                msg += "+(có+" + result.getErrors().size() + "+lỗi)";
            }
            resp.sendRedirect(redirectBase
                    + "?success=" + msg
                    + "&testOrderId=" + testOrderId
                    + "&patientId=" + patientId
                    + "&appointmentId=" + appointmentId);
        } else {
            String errorMsg = result.getErrors().isEmpty()
                    ? "Upload+thất+bại+không+xác+định"
                    : java.net.URLEncoder.encode(
                            String.join("; ", result.getErrors()), "UTF-8");
            resp.sendRedirect(redirectBase
                    + "?error=" + errorMsg
                    + "&testOrderId=" + testOrderId
                    + "&patientId=" + patientId
                    + "&appointmentId=" + appointmentId);
        }
    }
}
