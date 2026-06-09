package com.clinic.controller;

import com.clinic.model.UltrasoundWaitingPatient;
import com.clinic.model.User;
import com.clinic.service.UltrasoundOrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Shows ultrasound orders waiting to be performed and lets sonographers mark them done.
 */
@WebServlet(urlPatterns = {
    "/sonographer/waiting-list",
    "/sonographer/waiting-list/",
    "/admin/sonographer/waiting-list",
    "/admin/sonographer/waiting-list/"
})
public class UltrasoundWaitingListServlet extends HttpServlet {

    private UltrasoundOrderService ultrasoundOrderService;

    @Override
    public void init() throws ServletException {
        ultrasoundOrderService = new UltrasoundOrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAuthorizedUser(request, response);
        if (user == null) {
            return;
        }

        String sortBy = ultrasoundOrderService.normalizeSortBy(request.getParameter("sortBy"));
        String sortDir = ultrasoundOrderService.normalizeSortDir(request.getParameter("sortDir"));

        List<UltrasoundWaitingPatient> waitingPatients =
                ultrasoundOrderService.getWaitingPatients(sortBy, sortDir);

        request.setAttribute("waitingPatients", waitingPatients);
        request.setAttribute("totalWaiting", waitingPatients.size());
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortDir", sortDir);
        request.setAttribute("nextSortDir", "asc".equals(sortDir) ? "desc" : "asc");
        request.setAttribute("actionUrl", request.getContextPath() + getRequestPath(request));
        request.setAttribute("success", request.getParameter("success"));
        request.setAttribute("error", request.getParameter("error"));

        request.getRequestDispatcher("/views/admin/sonographer/waiting-list.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAuthorizedUser(request, response);
        if (user == null) {
            return;
        }

        String sortBy = ultrasoundOrderService.normalizeSortBy(request.getParameter("sortBy"));
        String sortDir = ultrasoundOrderService.normalizeSortDir(request.getParameter("sortDir"));
        String action = request.getParameter("action");

        String messageParam = "error=invalidAction";
        if ("markCompleted".equals(action)) {
            int orderId = parseInt(request.getParameter("orderId"), -1);
            boolean updated = ultrasoundOrderService.markAsUltrasounded(orderId);
            messageParam = updated ? "success=completed" : "error=updateFailed";
        }

        response.sendRedirect(buildRedirectUrl(request, sortBy, sortDir, messageParam));
    }

    private User getAuthorizedUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 1 && user.getRoleId() != 6) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorTitle", "Truy Cập Bị Từ Chối");
            request.setAttribute("errorDetail", "Bạn không có quyền truy cập danh sách chờ siêu âm.");
            request.getRequestDispatcher("/views/errors/403.jsp").forward(request, response);
            return null;
        }
        return user;
    }

    private String buildRedirectUrl(HttpServletRequest request, String sortBy, String sortDir, String messageParam) {
        String requestPath = getRequestPath(request);
        return request.getContextPath() + requestPath
                + "?sortBy=" + encode(sortBy)
                + "&sortDir=" + encode(sortDir)
                + "&" + messageParam;
    }

    private String getRequestPath(HttpServletRequest request) {
        return request.getRequestURI().substring(request.getContextPath().length());
    }

    private String encode(String value) {
        return URLEncoder.encode(value != null ? value : "", StandardCharsets.UTF_8);
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
