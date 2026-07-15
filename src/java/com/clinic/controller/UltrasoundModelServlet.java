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
 * Servlet hiển thị thông tin Model AI và mã nguồn quét u xơ tử cung.
 */
@WebServlet("/sonographer/ai-model")
public class UltrasoundModelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 1 && user.getRoleId() != 6) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorTitle", "Truy Cập Bị Từ Chối");
            request.setAttribute("errorDetail", "Bạn không có quyền truy cập trang thông tin Model AI.");
            request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/views/sonographer/ai-model.jsp").forward(request, response);
    }
}
