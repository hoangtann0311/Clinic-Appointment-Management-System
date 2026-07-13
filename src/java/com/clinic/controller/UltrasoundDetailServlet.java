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
 * Servlet hiển thị chi tiết ca chỉ định siêu âm và thực hiện chuyển trạng thái ban đầu.
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

        int orderId = Integer.parseInt(orderIdStr);
        UltrasoundWaitingPatient order = orderService.getById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chỉ định siêu âm.");
            return;
        }

        // Xử lý action=start (Bắt đầu thực hiện siêu âm)
        String action = request.getParameter("action");
        if ("start".equalsIgnoreCase(action)) {
            if ("Pending".equalsIgnoreCase(order.getStatus()) || "Waiting".equalsIgnoreCase(order.getStatus()) || "Ordered".equalsIgnoreCase(order.getStatus())) {
                boolean success = orderService.updateOrderStatus(orderId, "InProgress");
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&success=started");
                    return;
                } else {
                    request.setAttribute("error", "Không thể bắt đầu thực hiện siêu âm.");
                }
            }
        }

        // Load danh sách ảnh siêu âm đã upload
        List<UltrasoundImage> images = orderService.getUltrasoundImages(orderId);
        
        // Load kết quả phân tích AI nếu có
        AiAnalysisResult aiResult = orderService.getAiResult(orderId);

        request.setAttribute("order", order);
        request.setAttribute("images", images);
        request.setAttribute("aiResult", aiResult);

        request.getRequestDispatcher("/views/sonographer/detail.jsp").forward(request, response);
    }
}
