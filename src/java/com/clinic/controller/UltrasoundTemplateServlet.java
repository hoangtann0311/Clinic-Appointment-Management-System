package com.clinic.controller;

import com.clinic.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet quản lý mẫu phiếu siêu âm.
 * GET  → hiển thị danh sách mẫu phiếu siêu âm
 * POST → xử lý thêm / sửa / xóa mẫu phiếu
 */
@WebServlet(urlPatterns = {
    "/admin/sonographer/templates",
    "/admin/sonographer/templates/",
    "/admin/templates/ultrasound",
    "/admin/templates/ultrasound/"
})
public class UltrasoundTemplateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Kiểm tra phiên đăng nhập
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Kiểm tra quyền truy cập - chỉ Admin (roleId=1) và Sonographer (roleId=6) được truy cập
        if (user.getRoleId() != 1 && user.getRoleId() != 6) {
            resp.sendRedirect(req.getContextPath() + "/error?code=403");
            return;
        }

        // Forward tới JSP template
        req.getRequestDispatcher("/views/admin/sonographer/ultrasound-templates.jsp")
            .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Kiểm tra phiên đăng nhập
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Kiểm tra quyền truy cập
        if (user.getRoleId() != 1 && user.getRoleId() != 6) {
            resp.sendRedirect(req.getContextPath() + "/error?code=403");
            return;
        }

        String action = req.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "create":
                    // TODO: Thêm logic tạo mẫu phiếu
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Mẫu phiếu đã được tạo\"}");
                    break;

                case "update":
                    // TODO: Thêm logic cập nhật mẫu phiếu
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Mẫu phiếu đã được cập nhật\"}");
                    break;

                case "delete":
                    // TODO: Thêm logic xóa mẫu phiếu
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Mẫu phiếu đã được xóa\"}");
                    break;

                default:
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không hợp lệ\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi máy chủ: " + e.getMessage() + "\"}");
        }
    }
}
