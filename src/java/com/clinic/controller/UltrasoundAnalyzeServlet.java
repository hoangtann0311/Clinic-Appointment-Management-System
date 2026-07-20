package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet tiếp nhận yêu cầu phân tích ảnh bằng AI (Sonographer)
 */
@WebServlet("/sonographer/analyze")
public class UltrasoundAnalyzeServlet extends HttpServlet {

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

        try {
            if (!orderService.isReadyForSonographer(orderId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Chỉ định chưa đủ điều kiện thanh toán để phân tích.");
                return;
            }
            boolean success = orderService.runAiAnalysis(orderId, user.getId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&success=analyzed");
            } else {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                        + "&error=" + java.net.URLEncoder.encode("Phân tích AI thất bại hoặc kết nối AI Engine bị lỗi. Vui lòng kiểm tra lại.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                    + "&error=" + java.net.URLEncoder.encode("Lỗi hệ thống khi gọi phân tích AI: " + e.getMessage(), "UTF-8"));
        }
    }
}
