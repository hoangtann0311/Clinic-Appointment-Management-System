package com.clinic.controller;

import com.clinic.dao.InvoiceDAO;
import com.clinic.model.Invoice;
import com.clinic.model.User;
import com.clinic.service.ServiceStatisticsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Servlet Báo Cáo Doanh Thu cho Manager.
 *
 * GET  → hiển thị danh sách giao dịch đã thanh toán (Paid) + KPI tổng quan
 *        Hỗ trợ tìm kiếm, lọc theo trạng thái và khoảng ngày.
 *        ?action=detail&id=X → xem chi tiết một giao dịch.
 */
@WebServlet(urlPatterns = {"/manager/revenue/", "/manager/revenue"})
public class ManagerRevenueServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private InvoiceDAO invoiceDAO;

    @Override
    public void init() throws ServletException {
        invoiceDAO = new InvoiceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Xem chi tiết giao dịch
        if ("detail".equals(action)) {
            handleDetail(req, resp);
            return;
        }

        // ── Trang chính: danh sách giao dịch ──
        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String status = req.getParameter("status");
        String dateFrom = req.getParameter("dateFrom");
        String dateTo = req.getParameter("dateTo");

        // Mặc định: hiển thị giao dịch Paid
        if (status == null || status.trim().isEmpty()) {
            status = "Paid";
        }

        // ── Lấy danh sách hóa đơn ──
        int offset = (page - 1) * PAGE_SIZE;
        List<Invoice> invoices = invoiceDAO.getRevenueInvoices(
                offset, PAGE_SIZE, search, status, dateFrom, dateTo);
        int totalInvoices = invoiceDAO.countRevenueInvoices(
                search, status, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalInvoices / PAGE_SIZE);

        // ── KPI: Tổng giao dịch Paid và tổng doanh thu ──
        Object[] summary = invoiceDAO.getRevenueSummary(dateFrom, dateTo);
        int totalPaidCount = 0;
        double totalPaidRevenue = 0.0;
        if (summary != null) {
            totalPaidCount = (Integer) summary[0];
            totalPaidRevenue = (Double) summary[1];
        }

        // ── Format ngày hiển thị ──
        LocalDate today = LocalDate.now();
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String dateRangeLabel;
        if ((dateFrom == null || dateFrom.isEmpty()) && (dateTo == null || dateTo.isEmpty())) {
            dateRangeLabel = "Tất cả thời gian";
        } else if (dateFrom != null && dateFrom.equals(dateTo)) {
            dateRangeLabel = "Ngày " + dateFrom;
        } else {
            dateRangeLabel = (dateFrom != null ? dateFrom : "∞")
                    + " → " + (dateTo != null ? dateTo : "∞");
        }

        // ── Set attributes ──
        req.setAttribute("invoices", invoices);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalInvoices", totalInvoices);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("statusFilter", status);
        req.setAttribute("dateFrom", dateFrom);
        req.setAttribute("dateTo", dateTo);
        req.setAttribute("today", today.toString());
        req.setAttribute("dateRangeLabel", dateRangeLabel);

        // KPI
        req.setAttribute("totalPaidCount", totalPaidCount);
        req.setAttribute("totalPaidRevenue", totalPaidRevenue);
        req.setAttribute("totalPaidRevenueFormatted",
                ServiceStatisticsService.formatCurrency(totalPaidRevenue));

        // Success/error messages
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/revenue/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Manager chỉ xem, không có POST action.
        // Nếu có POST, redirect về GET.
        resp.sendRedirect(req.getContextPath() + "/manager/revenue/");
    }

    /** Xử lý xem chi tiết giao dịch */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = parseInt(req.getParameter("id"), -1);
        if (id < 1) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/revenue/?error=Không+tìm+thấy+giao+dịch");
            return;
        }

        Invoice invoice = invoiceDAO.getById(id);
        if (invoice == null) {
            resp.sendRedirect(req.getContextPath()
                    + "/manager/revenue/?error=Không+tìm+thấy+giao+dịch");
            return;
        }

        req.setAttribute("invoice", invoice);
        req.getRequestDispatcher("/views/manager/revenue/detail.jsp").forward(req, resp);
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}
