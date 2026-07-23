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
 * Servlet tiếp nhận yêu cầu phân tích ảnh bằng AI (Bác sĩ Siêu âm)
 */
@WebServlet("/sonographer/analyze")
public class UltrasoundAnalyzeServlet extends HttpServlet {

    private final UltrasoundOrderService orderService = new UltrasoundOrderService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!orderService.isSonographerOwnershipSupported()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Cơ sở dữ liệu chưa được nâng cấp để quản lý người phụ trách siêu âm.");
            return;
        }

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
            if (!orderService.isReadyForSonographer(orderId) || !orderService.checkSonographerOwnership(orderId, user.getId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền phân tích AI cho ca siêu âm này (đã được phụ trách bởi Bác sĩ siêu âm khác).");
                return;
            }
            if (orderService.getAiResult(orderId) != null) {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId
                        + "&error=aiAlreadyRun");
                return;
            }
            boolean success = orderService.runAiAnalysis(orderId, user.getId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId + "&success=analyzed");
            } else {
                response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                        + "&error=aiUnavailable");
            }
        } catch (Exception e) {
            System.err.println("[UltrasoundAnalyzeServlet] Phân tích AI không hoàn tất: " + e.getClass().getSimpleName());
            response.sendRedirect(request.getContextPath() + "/sonographer/detail?orderId=" + orderId 
                    + "&error=aiUnavailable");
        }
    }
}
