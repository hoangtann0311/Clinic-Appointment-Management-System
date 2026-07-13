package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.ServiceDAO;
import com.clinic.dao.TestOrderDAO;
import com.clinic.model.Service;
import com.clinic.model.TestOrder;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Bác sĩ chỉ định xét nghiệm và xem kết quả.
 *
 * GET  /doctor/lab-orders?recordId=X          → danh sách chỉ định + kết quả của hồ sơ X
 * POST /doctor/lab-orders (action=create)     → tạo chỉ định mới (serviceIds[])
 * POST /doctor/lab-orders (action=cancel)     → hủy 1 chỉ định (orderId)
 */
@WebServlet("/doctor/lab-orders")
public class DoctorLabOrderServlet extends HttpServlet {

    private final TestOrderDAO testOrderDAO = new TestOrderDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        String recordIdStr = req.getParameter("recordId");
        if (recordIdStr == null || recordIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }

        int recordId;
        try { recordId = Integer.parseInt(recordIdStr); }
        catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return;
        }

        // Kiểm tra hồ sơ thuộc bệnh nhân bác sĩ này có liên quan không
        // (loose check: bác sĩ có quyền xem kết quả xét nghiệm của hồ sơ mình tạo)
        List<TestOrder> orders = testOrderDAO.getByMedicalRecordId(recordId);

        // Lấy apptId từ medical_records để link "Quay lại hồ sơ" đúng
        Integer apptId = getApptIdByRecordId(recordId);

        // Danh sách dịch vụ xét nghiệm (category_id = 3) để bác sĩ chỉ định thêm
        List<Service> labServices = serviceDAO.findByCategoryId(3);

        req.setAttribute("orders",      orders);
        req.setAttribute("labServices", labServices);
        req.setAttribute("recordId",    recordId);
        req.setAttribute("apptId",      apptId);
        req.setAttribute("doctorName",  user.getFullName());
        req.getRequestDispatcher("/views/doctors/lab_orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;
        Integer doctorId = getDoctorId(user.getId());
        if (doctorId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }

        String action     = req.getParameter("action");
        String recordIdStr = req.getParameter("recordId");
        int recordId;
        try { recordId = Integer.parseInt(recordIdStr); }
        catch (Exception e) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return; }

        if ("create".equals(action)) {
            String[] sids = req.getParameterValues("serviceIds");
            if (sids != null && sids.length > 0) {
                List<Integer> ids = new ArrayList<>();
                for (String s : sids) {
                    try { ids.add(Integer.parseInt(s)); } catch (NumberFormatException ignored) {}
                }
                testOrderDAO.createBatch(recordId, doctorId, ids);
            }
        } else if ("cancel".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            try {
                int orderId = Integer.parseInt(orderIdStr);
                testOrderDAO.cancel(orderId);
            } catch (NumberFormatException ignored) {}
        }

        resp.sendRedirect(req.getContextPath() + "/doctor/lab-orders?recordId=" + recordId);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private User getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return null;
        }
        return (User) s.getAttribute("user");
    }

    private Integer getDoctorId(int userId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM doctors WHERE user_id=?")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private Integer getApptIdByRecordId(int recordId) {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT appointment_id FROM medical_records WHERE id=?")) {
            ps.setInt(1, recordId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("appointment_id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}