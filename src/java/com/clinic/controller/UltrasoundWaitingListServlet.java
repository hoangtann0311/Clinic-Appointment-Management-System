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
 * Servlet hiển thị danh sách chờ siêu âm có phân trang và bộ lọc nâng cao.
 */
@WebServlet(urlPatterns = {
    "/sonographer/waiting-list",
    "/sonographer/waiting-list/"
})
public class UltrasoundWaitingListServlet extends HttpServlet {

    private UltrasoundOrderService ultrasoundOrderService;
    private static final int PAGE_SIZE = 10;

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

        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        if (status == null) {
            status = "Pending";
        }
        String date = request.getParameter("date");
        String sortBy = ultrasoundOrderService.normalizeSortBy(request.getParameter("sortBy"));
        String sortDir = ultrasoundOrderService.normalizeSortDir(request.getParameter("sortDir"));

        // Lấy danh sách chỉ định siêu âm theo bộ lọc và phân trang
        List<UltrasoundWaitingPatient> waitingPatients =
                ultrasoundOrderService.getOrders(page, PAGE_SIZE, search, status, date, null, sortBy, sortDir);

        int totalOrders = ultrasoundOrderService.countOrders(search, status, date, null);
        int totalPages = (int) Math.ceil((double) totalOrders / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;

        request.setAttribute("waitingPatients", waitingPatients);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        
        request.setAttribute("searchParam", search);
        request.setAttribute("statusParam", status);
        request.setAttribute("dateParam", date);

        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortDir", sortDir);
        request.setAttribute("nextSortDir", "asc".equals(sortDir) ? "desc" : "asc");
        request.setAttribute("actionUrl", request.getContextPath() + getRequestPath(request));
        request.setAttribute("success", request.getParameter("success"));
        request.setAttribute("error", request.getParameter("error"));

        // Sidebar stats
        request.setAttribute("currentDisplayDate", java.time.LocalDate.now().toString());

        request.getRequestDispatcher("/views/sonographer/waiting-list.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Không cho đánh dấu hoàn tất tại danh sách chờ: bắt buộc đi qua upload,
        // phân tích AI và bước bác sĩ xác nhận ở trang chi tiết.
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                "Hãy thực hiện ca siêu âm theo quy trình tại trang chi tiết.");
    }

    private User getAuthorizedUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 6) {
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

}
