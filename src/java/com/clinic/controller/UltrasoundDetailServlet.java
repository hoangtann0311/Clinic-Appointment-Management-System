package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import com.clinic.model.UltrasoundImage;

/** Detail and state-changing actions for the assigned Bác sĩ Siêu âm. */
@WebServlet("/sonographer/detail")
public class UltrasoundDetailServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = sessionUser(request);
        if (user == null || user.getRoleId() != 6) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
            return;
        }

        Integer orderId = positiveInt(request.getParameter("orderId"));
        if (orderId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chỉ định siêu âm không hợp lệ.");
            return;
        }
        UltrasoundWaitingPatient order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chỉ định siêu âm.");
            return;
        }
        if (!orderService.isReadyForSonographer(orderId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ định chưa đủ điều kiện thanh toán để xử lý.");
            return;
        }

        String state = order.getStatus() == null ? "" : order.getStatus().trim();
        boolean unassignedState = state.equalsIgnoreCase("Pending")
                || state.equalsIgnoreCase("Waiting") || state.equalsIgnoreCase("Ordered");
        if (!unassignedState && !orderService.checkSonographerOwnership(orderId, user.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Ca siêu âm này đang do Bác sĩ siêu âm khác phụ trách.");
            return;
        }

        request.setAttribute("order", order);
        List<UltrasoundImage> images = orderService.getUltrasoundImages(orderId);
        if (orderService.isReviewSchemaSupported()) {
            for (UltrasoundImage image : images) {
                orderService.ensureImageDimensions(image, getServletContext().getRealPath(""));
            }
        }
        com.clinic.model.UltrasoundAnnotation currentAnnotation = orderService.getCurrentAnnotation(orderId);
        com.clinic.model.UltrasoundReport currentReport = orderService.getCurrentReport(orderId);
        UltrasoundImage selectedImage = images.isEmpty() ? null : images.get(0);
        if (currentAnnotation != null) {
            for (UltrasoundImage image : images) {
                if (image.getId() == currentAnnotation.getUltrasoundImageId()) {
                    selectedImage = image;
                    break;
                }
            }
        }
        request.setAttribute("images", images);
        request.setAttribute("selectedImage", selectedImage);
        request.setAttribute("aiResult", selectedImage == null ? null : orderService.getAiResult(orderId));
        request.setAttribute("currentAnnotation", currentAnnotation);
        request.setAttribute("currentReport", currentReport);
        request.setAttribute("ownershipSupported", orderService.isSonographerOwnershipSupported());
        request.setAttribute("reviewSchemaSupported", orderService.isReviewSchemaSupported());
        request.getRequestDispatcher("/views/sonographer/detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = sessionUser(request);
        if (user == null || user.getRoleId() != 6) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
            return;
        }
        Integer orderId = positiveInt(request.getParameter("orderId"));
        if (orderId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chỉ định siêu âm không hợp lệ.");
            return;
        }
        if (!orderService.isSonographerOwnershipSupported()) {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Cơ sở dữ liệu chưa hỗ trợ quản lý người phụ trách siêu âm.");
            return;
        }
        if (!orderService.isReadyForSonographer(orderId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ định chưa đủ điều kiện thanh toán để xử lý.");
            return;
        }

        String action = safe(request.getParameter("action"));
        if ("start".equalsIgnoreCase(action)) {
            if (orderService.startUltrasoundOrder(orderId, user.getId())) {
                redirect(response, request, orderId, "success=started");
            } else {
                redirect(response, request, orderId, "error=startConflict");
            }
            return;
        }

        boolean sign = "sign".equalsIgnoreCase(action) || "complete".equalsIgnoreCase(action);
        if (!sign) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thao tác không hợp lệ.");
            return;
        }
        if (!orderService.isReviewSchemaSupported()) {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Chưa áp dụng migration V13 cho quy trình duyệt và ký kết quả siêu âm.");
            return;
        }
        if (!orderService.checkSonographerOwnership(orderId, user.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không phải người phụ trách ca siêu âm này.");
            return;
        }

        Integer imageId = positiveInt(request.getParameter("imageId"));
        Integer imageWidth = positiveInt(request.getParameter("imageWidth"));
        Integer imageHeight = positiveInt(request.getParameter("imageHeight"));
        if (imageId == null || imageWidth == null || imageHeight == null) {
            redirect(response, request, orderId, "error=invalidImageMetadata");
            return;
        }
        UltrasoundImage storedImage = orderService.getUltrasoundImageById(imageId);
        if (storedImage == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy ảnh siêu âm đã chọn.");
            return;
        }
        if (storedImage.getTestOrderId() != orderId) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Ảnh siêu âm đã chọn không thuộc chỉ định đang xử lý.");
            return;
        }
        if (!orderService.ensureImageDimensions(storedImage, getServletContext().getRealPath(""))) {
            redirect(response, request, orderId, "error=invalidImageMetadata");
            return;
        }

        String reviewStatus = safe(request.getParameter("reviewStatus"));
        if ("Accepted".equals(reviewStatus)
                && !orderService.hasAcceptableAiResultForImage(orderId, imageId)) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("Ảnh được chọn chưa có kết quả AI hợp lệ để xác nhận.");
            return;
        }

        boolean saved = orderService.saveSonographerReview(
                orderId, user.getId(), user.getFullName(), imageId, imageWidth, imageHeight,
                reviewStatus, request.getParameter("annotationData"),
                request.getParameter("rejectionReason"), request.getParameter("imageDescription"),
                request.getParameter("professionalFindings"), request.getParameter("conclusion"), sign);

        if (saved) {
            redirect(response, request, orderId, "success=signed");
        } else {
            redirect(response, request, orderId, "error=signFailed");
        }
    }

    private User sessionUser(HttpServletRequest request) {
        Object value = request.getSession(false) == null ? null
                : request.getSession(false).getAttribute("user");
        return value instanceof User ? (User) value : null;
    }

    private Integer positiveInt(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : null;
        } catch (Exception ignored) {
            return null;
        }
    }

    private String safe(String value) { return value == null ? "" : value.trim(); }

    private void redirect(HttpServletResponse response, HttpServletRequest request,
                          int orderId, String query) throws IOException {
        response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId="
                + orderId + "&" + query + "#review-workspace");
    }
}
