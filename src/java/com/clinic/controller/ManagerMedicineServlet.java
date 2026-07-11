package com.clinic.controller;

import com.clinic.model.Medicine;
import com.clinic.model.MedicineCategory;
import com.clinic.model.MedicinePriceHistory;
import com.clinic.model.User;
import com.clinic.service.MedicineService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý Danh Mục Thuốc cho Manager — CRUD + lịch sử giá.
 *
 * GET  → hiển thị danh sách thuốc (phân trang + tìm kiếm + lọc)
 * POST → xử lý thêm / sửa / vô hiệu hóa / kích hoạt
 */
@WebServlet(urlPatterns = {"/manager/medicines/", "/manager/medicines"})
public class ManagerMedicineServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private MedicineService medicineService;

    @Override
    public void init() throws ServletException {
        medicineService = new MedicineService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Xem chi tiết thuốc
        if ("detail".equals(action)) {
            handleDetail(req, resp);
            return;
        }

        // Xem lịch sử giá thuốc toàn hệ thống
        if ("price-history".equals(action)) {
            handlePriceHistory(req, resp);
            return;
        }

        // Trang chính — danh sách + thống kê + lọc nhóm
        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String activeStr = req.getParameter("active");
        String categoryStr = req.getParameter("category");

        Boolean activeFilter = null;
        if (activeStr != null && !activeStr.isEmpty()) {
            activeFilter = "1".equals(activeStr);
        }

        Integer categoryId = null;
        if (categoryStr != null && !categoryStr.isEmpty()) {
            try { categoryId = Integer.parseInt(categoryStr); } catch (NumberFormatException e) { }
        }

        List<Medicine> medicines = medicineService.getMedicines(page, PAGE_SIZE, search, activeFilter, categoryId);
        int totalMedicines = medicineService.getTotalMedicines(search, activeFilter, categoryId);
        int totalPages = (int) Math.ceil((double) totalMedicines / PAGE_SIZE);
        int activeMedicinesCount = medicineService.getActiveMedicineCount();
        List<MedicineCategory> categories = medicineService.getCategoriesWithStats();

        req.setAttribute("medicines", medicines);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalMedicines", totalMedicines);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("activeFilter", activeStr);
        req.setAttribute("categoryFilter", categoryStr);
        req.setAttribute("activeMedicinesCount", activeMedicinesCount);
        req.setAttribute("categories", categories);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/medicines/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/manager/medicines/";

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        Integer changedBy = (currentUser != null) ? currentUser.getId() : null;

        try {
            switch (action != null ? action : "") {

                case "create": {
                    String medicineCode = req.getParameter("medicineCode");
                    String name = req.getParameter("name");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String price = req.getParameter("price");
                    String stockQuantity = req.getParameter("stockQuantity");
                    String categoryId = req.getParameter("categoryId");

                    Map<String, String> errors = new HashMap<>();
                    if (medicineService.createMedicine(medicineCode, name, description,
                            dosage, unit, price, stockQuantity, errors, changedBy, categoryId)) {
                        AuditUtil.log(changedBy, "Tạo mới thuốc: " + name, "medicines",
                                null, "price=" + price, null);
                        resp.sendRedirect(redirectUrl + "?success=created");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildFormData(req));
                        req.setAttribute("showCreateModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                case "edit": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String medicineCode = req.getParameter("medicineCode");
                    String name = req.getParameter("name");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String price = req.getParameter("price");
                    String stockQuantity = req.getParameter("stockQuantity");
                    boolean isActive = "on".equals(req.getParameter("isActive"));
                    String changeReason = req.getParameter("changeReason");
                    String categoryId = req.getParameter("categoryId");

                    Map<String, String> errors = new HashMap<>();
                    if (medicineService.updateMedicine(id, medicineCode, name, description,
                            dosage, unit, price, stockQuantity, isActive, errors, changedBy, changeReason, categoryId)) {
                        AuditUtil.log(changedBy, "Cập nhật thuốc: " + name, "medicines",
                                null, "price=" + price + ", active=" + isActive, null);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildFormData(req));
                        req.setAttribute("showEditModal", true);
                        req.setAttribute("editMedicineId", id);
                        doGet(req, resp);
                    }
                    return;
                }

                case "toggle": {
                    int id = parseInt(req.getParameter("id"), -1);
                    Medicine med = medicineService.getMedicineById(id);
                    if (med == null) {
                        resp.sendRedirect(redirectUrl + "?error=Thuốc+không+tồn+tại");
                        return;
                    }
                    if (medicineService.toggleMedicineStatus(id, changedBy)) {
                        String msg = med.isActive() ? "deactivated" : "activated";
                        resp.sendRedirect(redirectUrl + "?success=" + msg);
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Thay+đổi+trạng+thái+thất+bại");
                    }
                    return;
                }

                case "deactivate": {
                    int id = parseInt(req.getParameter("id"), -1);
                    if (medicineService.deactivateMedicine(id)) {
                        resp.sendRedirect(redirectUrl + "?success=deactivated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Vô+hiệu+hóa+thất+bại");
                    }
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("[ManagerMedicineServlet] POST error: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống:+vui+lòng+thử+lại");
        }
    }

    /** Xử lý xem chi tiết thuốc */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = parseInt(req.getParameter("id"), -1);
        if (id < 1) {
            resp.sendRedirect(req.getContextPath() + "/manager/medicines/?error=Không+tìm+thấy+thuốc");
            return;
        }

        Medicine medicine = medicineService.getMedicineById(id);
        if (medicine == null) {
            resp.sendRedirect(req.getContextPath() + "/manager/medicines/?error=Không+tìm+thấy+thuốc");
            return;
        }

        List<MedicinePriceHistory> priceHistory = medicineService.getPriceHistory(id);

        req.setAttribute("detailMedicine", medicine);
        req.setAttribute("priceHistory", priceHistory);

        // Load danh mục cho hiển thị
        req.setAttribute("categories", medicineService.getCategories());

        req.getRequestDispatcher("/views/manager/medicines/detail.jsp").forward(req, resp);
    }

    /** Xử lý xem toàn bộ lịch sử giá thuốc */
    private void handlePriceHistory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int page = parseInt(req.getParameter("page"), 1);
        List<MedicinePriceHistory> historyList = medicineService.getAllPriceHistory(page, PAGE_SIZE);
        int total = medicineService.getTotalPriceHistory();
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("historyList", historyList);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalHistory", total);

        req.getRequestDispatcher("/views/manager/medicines/price-history.jsp").forward(req, resp);
    }

    private Map<String, String> buildFormData(HttpServletRequest req) {
        Map<String, String> data = new HashMap<>();
        data.put("medicineCode", req.getParameter("medicineCode"));
        data.put("name", req.getParameter("name"));
        data.put("description", req.getParameter("description"));
        data.put("dosage", req.getParameter("dosage"));
        data.put("unit", req.getParameter("unit"));
        data.put("price", req.getParameter("price"));
        data.put("stockQuantity", req.getParameter("stockQuantity"));
        data.put("changeReason", req.getParameter("changeReason"));
        data.put("categoryId", req.getParameter("categoryId"));
        return data;
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}

