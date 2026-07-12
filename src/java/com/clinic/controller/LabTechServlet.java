package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.TestOrderDAO;
import com.clinic.model.TestOrder;
import com.clinic.model.User;
import com.clinic.utils.NotificationHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.List;

/**
 * KTV xét nghiệm (roleId = 7) nhận danh sách chỉ định chờ xử lý
 * và nhập kết quả xét nghiệm.
 *
 * GET  /lab/orders            → danh sách chỉ định đang chờ (pending)
 * GET  /lab/orders?id=X       → chi tiết 1 chỉ định, form nhập kết quả
 * POST /lab/orders            → lưu kết quả (orderId, resultDetails, imageUrl)
 */
@WebServlet("/lab/orders")
public class LabTechServlet extends HttpServlet {

    private final TestOrderDAO testOrderDAO = new TestOrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        String idStr = req.getParameter("id");

        if (idStr != null && !idStr.isBlank()) {
            // Xem chi tiết + form nhập kết quả
            int orderId;
            try { orderId = Integer.parseInt(idStr); }
            catch (NumberFormatException e) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return; }

            TestOrder order = testOrderDAO.getById(orderId);
            if (order == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

            req.setAttribute("order", order);
            req.getRequestDispatcher("/views/lab/order_detail.jsp").forward(req, resp);
        } else {
            // Danh sách tất cả chỉ định pending
            List<TestOrder> orders = testOrderDAO.getPending();
            req.setAttribute("orders",     orders);
            req.setAttribute("doctorName", user.getFullName());
            req.getRequestDispatcher("/views/lab/order_list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        Integer labTechId = getUserId(user.getId());
        if (labTechId == null) labTechId = user.getId(); // fallback dùng user_id thẳng

        String orderIdStr     = req.getParameter("orderId");
        String resultDetails  = req.getParameter("resultDetails");
        String imageUrl       = req.getParameter("imageUrl");
        String serviceIdStr   = req.getParameter("serviceId");

        int orderId, serviceId;
        try {
            orderId   = Integer.parseInt(orderIdStr);
            serviceId = Integer.parseInt(serviceIdStr);
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "orderId hoặc serviceId không hợp lệ.");
            return;
        }

        if (resultDetails == null || resultDetails.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập nội dung kết quả xét nghiệm.");
            TestOrder order = testOrderDAO.getById(orderId);
            req.setAttribute("order", order);
            req.getRequestDispatcher("/views/lab/order_detail.jsp").forward(req, resp);
            return;
        }

        testOrderDAO.saveResult(orderId, serviceId, labTechId, resultDetails.trim(), imageUrl);

        // Loại 1: Thông báo cho bác sĩ khi có kết quả XN
        try {
            TestOrder order = testOrderDAO.getById(orderId);
            if (order != null) {
                int doctorUserId = NotificationHelper.getDoctorUserId(order.getDoctorId());
                if (doctorUserId > 0) {
                    NotificationHelper.labResultReady(doctorUserId,
                        order.getServiceName(), order.getMedicalRecordId());
                }
            }
        } catch (Exception ignored) {}

        resp.sendRedirect(req.getContextPath() + "/lab/orders?saved=1");
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private User getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return null;
        }
        return (User) s.getAttribute("user");
    }

    private Integer getUserId(int userId) { return userId; }
}