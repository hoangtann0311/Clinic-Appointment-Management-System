package com.clinic.controller;

import com.clinic.model.AiAnalysisResult;
import com.clinic.model.UltrasoundImage;
import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet hiển thị chi tiết ca chỉ định siêu âm và khởi động ca qua POST.
 */
@WebServlet("/sonographer/detail")
public class UltrasoundDetailServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 6) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
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
        UltrasoundWaitingPatient order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chỉ định siêu âm.");
            return;
        }

        // Load danh sách ảnh siêu âm đã upload
        if (!orderService.isReadyForSonographer(orderId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ định chưa đủ điều kiện thanh toán để xử lý.");
            return;
        }

        List<UltrasoundImage> images = orderService.getUltrasoundImages(orderId);
        
        // Load kết quả phân tích AI nếu có
        AiAnalysisResult aiResult = orderService.getAiResult(orderId);

        request.setAttribute("order", order);
        request.setAttribute("images", images);
        request.setAttribute("aiResult", aiResult);

        request.getRequestDispatcher("/views/sonographer/detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 6) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (NumberFormatException | NullPointerException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chỉ định siêu âm không hợp lệ.");
            return;
        }

        if (!"start".equalsIgnoreCase(request.getParameter("action"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thao tác không hợp lệ.");
            return;
        }

        if (!orderService.isReadyForSonographer(orderId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ định chưa đủ điều kiện thanh toán để xử lý.");
            return;
        }

        if (orderService.updateOrderStatus(orderId, "InProgress")) {
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&success=started");
        } else {
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&error=cannotStart");
        }
    }
}
