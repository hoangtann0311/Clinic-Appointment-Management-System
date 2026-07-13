package com.clinic.controller;

import com.clinic.model.Invoice;
import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet quản lý và xác nhận thanh toán (Staff / Lễ tân)
 */
@WebServlet(urlPatterns = {"/admin/reception/payments", "/admin/reception/payments/"})
public class StaffPaymentServlet extends HttpServlet {

    private final StaffReceptionService receptionService = new StaffReceptionService();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
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
        String type = request.getParameter("type");
        String date = request.getParameter("date");

        List<Invoice> invoices = receptionService.getInvoices(page, PAGE_SIZE, search, status, type, date);
        int totalInvoices = receptionService.countInvoices(search, status, type, date);
        int totalPages = (int) Math.ceil((double) totalInvoices / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;

        request.setAttribute("invoices", invoices);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("searchParam", search);
        request.setAttribute("statusParam", status);
        request.setAttribute("typeParam", type);
        request.setAttribute("dateParam", date);

        // Sidebar stats
        request.setAttribute("currentDisplayDate", java.time.LocalDate.now().toString());

        request.getRequestDispatcher("/views/staff/reception-payments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền thực hiện.");
            return;
        }

        String invoiceIdStr = request.getParameter("invoiceId");
        String paymentMethod = request.getParameter("paymentMethod");
        String transactionCode = request.getParameter("transactionCode");
        String paymentNote = request.getParameter("paymentNote");

        // Retain filters in redirect
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String type = request.getParameter("type");
        String date = request.getParameter("date");
        String page = request.getParameter("page");

        StringBuilder qs = new StringBuilder();
        if (search != null && !search.isEmpty()) qs.append("&search=").append(java.net.URLEncoder.encode(search, "UTF-8"));
        if (status != null && !status.isEmpty()) qs.append("&status=").append(status);
        if (type != null && !type.isEmpty()) qs.append("&type=").append(type);
        if (date != null && !date.isEmpty()) qs.append("&date=").append(date);
        if (page != null && !page.isEmpty()) qs.append("&page=").append(page);
        String suffix = qs.toString();

        try {
            int invoiceId = Integer.parseInt(invoiceIdStr);
            boolean success = receptionService.confirmPayment(invoiceId, paymentMethod, transactionCode, paymentNote, user.getId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/reception/payments?success=confirmed" + suffix);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/reception/payments?error=" 
                        + java.net.URLEncoder.encode("Không thể cập nhật trạng thái thanh toán hóa đơn.", "UTF-8") + suffix);
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/admin/reception/payments?error=" 
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + suffix);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/reception/payments?error=" 
                    + java.net.URLEncoder.encode("Lỗi hệ thống khi xác nhận thanh toán: " + e.getMessage(), "UTF-8") + suffix);
        }
    }
}
