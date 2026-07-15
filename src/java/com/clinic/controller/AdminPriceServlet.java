package com.clinic.controller;

import com.clinic.model.Medicine;
import com.clinic.model.Service;
import com.clinic.model.User;
import com.clinic.service.MedicineService;
import com.clinic.service.ServiceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

/**
 * Servlet quản lý biểu giá cho Admin & Manager.
 * Hiển thị danh sách dịch vụ y tế + thuốc trong một giao diện thống nhất.
 *
 * GET  → hiển thị danh sách biểu giá (dịch vụ + thuốc) với phân trang + tìm kiếm + lọc
 * POST → xử lý sửa giá (từng mục hoặc hàng loạt)
 */
@WebServlet(urlPatterns = {"/admin/pricing/", "/admin/pricing"})
public class AdminPriceServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    private ServiceService serviceService;
    private MedicineService medicineService;

    @Override
    public void init() throws ServletException {
        serviceService = new ServiceService();
        medicineService = new MedicineService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String tab = req.getParameter("tab"); // "services" hoặc "medicines"
        if (tab == null || tab.isEmpty()) tab = "services";

        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String activeStr = req.getParameter("active");
        Boolean activeFilter = null;
        if (activeStr != null && !activeStr.isEmpty()) {
            activeFilter = "1".equals(activeStr);
        }

        if ("medicines".equals(tab)) {
            // Tab Thuốc
            List<Medicine> medicines = medicineService.getMedicines(page, PAGE_SIZE, search, activeFilter, null);
            int totalMedicines = medicineService.getTotalMedicines(search, activeFilter, (Integer) null);
            int totalPages = (int) Math.ceil((double) totalMedicines / PAGE_SIZE);

            req.setAttribute("medicines", medicines);
            req.setAttribute("totalMedicines", totalMedicines);
            req.setAttribute("totalPages", totalPages);
        } else {
            // Tab Dịch Vụ (mặc định)
            List<Service> services = serviceService.getServices(page, PAGE_SIZE, search, activeFilter, null);
            int totalServices = serviceService.getTotalServices(search, activeFilter, (Integer) null);
            int totalPages = (int) Math.ceil((double) totalServices / PAGE_SIZE);

            req.setAttribute("services", services);
            req.setAttribute("totalServices", totalServices);
            req.setAttribute("totalPages", totalPages);
        }

        req.setAttribute("tab", tab);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("activeFilter", activeStr);

        // Message từ redirect
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/admin/pricing/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String tab = req.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "services";
        String redirectUrl = req.getContextPath() + "/admin/pricing/?tab=" + tab;

        User loggedInUser = (User) req.getSession().getAttribute("user");
        Integer currentUserId = (loggedInUser != null) ? loggedInUser.getId() : null;

        try {
            switch (action != null ? action : "") {

                // ── SỬA GIÁ DỊCH VỤ ──
                case "updateServicePrice": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String newPriceStr = req.getParameter("price");
                    String serviceName = req.getParameter("serviceName");
                    String serviceCode = req.getParameter("serviceCode");
                    String description = req.getParameter("description");
                    String durationMins = req.getParameter("durationMins");
                    boolean isActive = "on".equals(req.getParameter("isActive"));

                    // Validate price
                    BigDecimal newPrice;
                    try {
                        newPrice = new BigDecimal(newPriceStr);
                        if (newPrice.compareTo(BigDecimal.ZERO) <= 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Giá dịch vụ phải lớn hơn 0!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Giá dịch vụ không hợp lệ!", "UTF-8"));
                        return;
                    }

                    // Lấy service hiện tại
                    Service existing = serviceService.getServiceById(id);
                    if (existing == null) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Dịch vụ không tồn tại!", "UTF-8"));
                        return;
                    }

                    BigDecimal oldPrice = existing.getPrice();
                    Map<String, String> errors = new HashMap<>();
                    boolean success = serviceService.updateService(id,
                            serviceCode != null ? serviceCode : existing.getServiceCode(),
                            serviceName != null ? serviceName : existing.getServiceName(),
                            description != null ? description : existing.getDescription(),
                            newPriceStr,
                            durationMins != null ? durationMins : String.valueOf(existing.getDurationMins()),
                            existing.isRequiresFasting(),
                            existing.isRequiresFullBladder(),
                            existing.getRequiredRoomType(),
                            existing.getAllowedSpecialties(),
                            existing.getCategoryId() != null ? String.valueOf(existing.getCategoryId()) : "",
                            isActive,
                            errors,
                            currentUserId,
                            "Sửa giá dịch vụ (Admin)");

                    if (success) {
                        logAudit(req, "UPDATE_SERVICE_PRICE",
                                "Sửa giá dịch vụ #" + id + " \"" + existing.getServiceName() + "\": " +
                                oldPrice + " → " + newPrice);
                        resp.sendRedirect(redirectUrl + "&success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode(
                                errors.getOrDefault("general", "Cập nhật thất bại!"), "UTF-8"));
                    }
                    return;
                }

                // ── SỬA GIÁ THUỐC ──
                case "updateMedicinePrice": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String newPriceStr = req.getParameter("price");
                    String medicineName = req.getParameter("name");
                    String medicineCode = req.getParameter("medicineCode");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String stockQuantity = req.getParameter("stockQuantity");
                    boolean isActive = "on".equals(req.getParameter("isActive"));

                    // Validate price
                    BigDecimal newPrice;
                    try {
                        newPrice = new BigDecimal(newPriceStr);
                        if (newPrice.compareTo(BigDecimal.ZERO) <= 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Giá thuốc phải lớn hơn 0!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Giá thuốc không hợp lệ!", "UTF-8"));
                        return;
                    }

                    // Lấy medicine hiện tại
                    Medicine existing = medicineService.getMedicineById(id);
                    if (existing == null) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Thuốc không tồn tại!", "UTF-8"));
                        return;
                    }

                    BigDecimal oldPrice = existing.getPrice();
                    Map<String, String> errors = new HashMap<>();
                    boolean success = medicineService.updateMedicine(id,
                            medicineCode != null ? medicineCode : existing.getMedicineCode(),
                            medicineName != null ? medicineName : existing.getName(),
                            description != null ? description : existing.getDescription(),
                            dosage != null ? dosage : existing.getDosage(),
                            unit != null ? unit : existing.getUnit(),
                            newPriceStr,
                            stockQuantity != null ? stockQuantity : String.valueOf(existing.getStockQuantity()),
                            isActive,
                            errors,
                            currentUserId,
                            "Sửa giá thuốc (Admin)",
                            existing.getCategoryId() != null ? String.valueOf(existing.getCategoryId()) : "");

                    if (success) {
                        logAudit(req, "UPDATE_MEDICINE_PRICE",
                                "Sửa giá thuốc #" + id + " \"" + existing.getName() + "\": " +
                                oldPrice + " → " + newPrice);
                        resp.sendRedirect(redirectUrl + "&success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode(
                                errors.getOrDefault("general", "Cập nhật thất bại!"), "UTF-8"));
                    }
                    return;
                }

                // ── SỬA NHANH GIÁ (chỉ cập nhật price, không đụng field khác) ──
                case "quickUpdateServicePrice": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String newPriceStr = req.getParameter("price");

                    BigDecimal newPrice;
                    try {
                        newPrice = new BigDecimal(newPriceStr);
                        if (newPrice.compareTo(BigDecimal.ZERO) <= 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Giá phải > 0!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=Giá+không+hợp+lệ!");
                        return;
                    }

                    Service existing = serviceService.getServiceById(id);
                    if (existing == null) {
                        resp.sendRedirect(redirectUrl + "&error=Dịch+vụ+không+tồn+tại!");
                        return;
                    }

                    BigDecimal oldPrice = existing.getPrice();
                    Map<String, String> errors = new HashMap<>();
                    boolean success = serviceService.updateService(id,
                            existing.getServiceCode(), existing.getServiceName(),
                            existing.getDescription(), newPriceStr,
                            String.valueOf(existing.getDurationMins()),
                            existing.isRequiresFasting(), existing.isRequiresFullBladder(),
                            existing.getRequiredRoomType(), existing.getAllowedSpecialties(),
                            existing.getCategoryId() != null ? String.valueOf(existing.getCategoryId()) : "",
                            existing.isActive(), errors,
                            currentUserId,
                            "Sửa nhanh giá dịch vụ (Admin)");

                    if (success) {
                        logAudit(req, "QUICK_UPDATE_SERVICE",
                                "Sửa nhanh giá DV #" + id + ": " + oldPrice + " → " + newPrice);
                    }
                    resp.sendRedirect(redirectUrl + (success ? "&success=updated" : "&error=Cập+nhật+thất+bại!"));
                    return;
                }

                // ── THÊM MỚI DỊCH VỤ ──
                case "createService": {
                    String serviceCode = req.getParameter("serviceCode");
                    String serviceName = req.getParameter("serviceName");
                    String description = req.getParameter("description");
                    String price = req.getParameter("price");
                    String durationMins = req.getParameter("durationMins");
                    boolean requiresFasting = "on".equals(req.getParameter("requiresFasting"));
                    boolean requiresFullBladder = "on".equals(req.getParameter("requiresFullBladder"));
                    String requiredRoomType = req.getParameter("requiredRoomType");
                    String allowedSpecialties = req.getParameter("allowedSpecialties");
                    String categoryId = req.getParameter("categoryId");

                    Map<String, String> errors = new HashMap<>();
                    if (serviceService.createService(serviceCode, serviceName, description,
                            price, durationMins, requiresFasting, requiresFullBladder,
                            requiredRoomType, allowedSpecialties, categoryId, errors,
                            currentUserId)) {
                        logAudit(req, "CREATE_SERVICE", "Thêm dịch vụ: " + serviceName + " (giá=" + price + ")");
                        resp.sendRedirect(redirectUrl + "&success=created");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildServiceFormData(req));
                        req.setAttribute("showCreateServiceModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                // ── THÊM MỚI THUỐC ──
                case "createMedicine": {
                    String medicineCode = req.getParameter("medicineCode");
                    String medicineName = req.getParameter("name");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String price = req.getParameter("price");
                    String stockQuantity = req.getParameter("stockQuantity");

                    Map<String, String> errors = new HashMap<>();
                    if (medicineService.createMedicine(medicineCode, medicineName, description,
                            dosage, unit, price, stockQuantity, errors,
                            currentUserId, null)) {
                        logAudit(req, "CREATE_MEDICINE", "Thêm thuốc: " + medicineName + " (giá=" + price + ")");
                        resp.sendRedirect(redirectUrl + "&success=created");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildMedicineFormData(req));
                        req.setAttribute("showCreateMedicineModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                case "quickUpdateMedicinePrice": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String newPriceStr = req.getParameter("price");

                    BigDecimal newPrice;
                    try {
                        newPrice = new BigDecimal(newPriceStr);
                        if (newPrice.compareTo(BigDecimal.ZERO) <= 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Giá phải > 0!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=Giá+không+hợp+lệ!");
                        return;
                    }

                    Medicine existing = medicineService.getMedicineById(id);
                    if (existing == null) {
                        resp.sendRedirect(redirectUrl + "&error=Thuốc+không+tồn+tại!");
                        return;
                    }

                    BigDecimal oldPrice = existing.getPrice();
                    Map<String, String> errors = new HashMap<>();
                    boolean success = medicineService.updateMedicine(id,
                            existing.getMedicineCode(), existing.getName(),
                            existing.getDescription(), existing.getDosage(), existing.getUnit(),
                            newPriceStr, String.valueOf(existing.getStockQuantity()),
                            existing.isActive(), errors,
                            currentUserId,
                            "Sửa nhanh giá thuốc (Admin)",
                            existing.getCategoryId() != null ? String.valueOf(existing.getCategoryId()) : "");

                    if (success) {
                        logAudit(req, "QUICK_UPDATE_MEDICINE",
                                "Sửa nhanh giá thuốc #" + id + ": " + oldPrice + " → " + newPrice);
                    }
                    resp.sendRedirect(redirectUrl + (success ? "&success=updated" : "&error=Cập+nhật+thất+bại!"));
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("AdminPriceServlet POST: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "&error=Lỗi+hệ+thống");
        }
    }

    /** Lưu form data dịch vụ để hiển thị lại khi validation fail */
    private Map<String, String> buildServiceFormData(HttpServletRequest req) {
        Map<String, String> data = new HashMap<>();
        data.put("serviceCode", req.getParameter("serviceCode"));
        data.put("serviceName", req.getParameter("serviceName"));
        data.put("description", req.getParameter("description"));
        data.put("price", req.getParameter("price"));
        data.put("durationMins", req.getParameter("durationMins"));
        data.put("requiredRoomType", req.getParameter("requiredRoomType"));
        data.put("allowedSpecialties", req.getParameter("allowedSpecialties"));
        data.put("categoryId", req.getParameter("categoryId"));
        return data;
    }

    /** Lưu form data thuốc để hiển thị lại khi validation fail */
    private Map<String, String> buildMedicineFormData(HttpServletRequest req) {
        Map<String, String> data = new HashMap<>();
        data.put("medicineCode", req.getParameter("medicineCode"));
        data.put("name", req.getParameter("name"));
        data.put("description", req.getParameter("description"));
        data.put("dosage", req.getParameter("dosage"));
        data.put("unit", req.getParameter("unit"));
        data.put("price", req.getParameter("price"));
        data.put("stockQuantity", req.getParameter("stockQuantity"));
        return data;
    }

    /** Ghi log thao tác sửa biểu giá */
    private void logAudit(HttpServletRequest req, String action, String detail) {
        com.clinic.utils.AuditUtil.log(req, detail, "services", null, null);
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}

