package com.clinic.controller;

import com.clinic.dao.DoctorDAO;
import com.clinic.model.Doctor;
import com.clinic.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet Quản Lý Bác Sĩ cho Manager — CHỈ XEM.
 *
 * Manager không có quyền thêm, sửa, xóa, khóa hoặc thay đổi trạng thái bác sĩ.
 *
 * GET  → hiển thị danh sách bác sĩ (phân trang + tìm kiếm)
 *        ?action=detail&id=X → xem chi tiết bác sĩ
 * POST → không hỗ trợ (chỉ xem)
 */
@WebServlet(urlPatterns = {"/manager/doctors/", "/manager/doctors"})
public class ManagerDoctorServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Xem chi tiết bác sĩ
        if ("detail".equals(action)) {
            handleDetail(req, resp);
            return;
        }

        // ── Trang chính: danh sách bác sĩ ──
        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");

        int offset = (page - 1) * PAGE_SIZE;
        List<Doctor> doctors = doctorDAO.findAllWithUserInfo(
                search, offset, PAGE_SIZE);
        int totalDoctors = doctorDAO.countAllDoctors(search);
        int totalPages = (int) Math.ceil((double) totalDoctors / PAGE_SIZE);

        // ── Set attributes ──
        req.setAttribute("doctors", doctors);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalDoctors", totalDoctors);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);

        // Success/error messages
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/doctors/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Manager chỉ xem — không có POST action.
        resp.sendRedirect(req.getContextPath() + "/manager/doctors/");
    }

    /** Xử lý xem chi tiết bác sĩ */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = parseInt(req.getParameter("id"), -1);
        if (id < 1) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/doctors/?error=Không+tìm+thấy+bác+sĩ");
            return;
        }

        Doctor doctor = doctorDAO.findByIdWithUserInfo(id);
        if (doctor == null) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/doctors/?error=Không+tìm+thấy+bác+sĩ");
            return;
        }

        req.setAttribute("doctor", doctor);
        req.getRequestDispatcher("/views/manager/doctors/detail.jsp").forward(req, resp);
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}
