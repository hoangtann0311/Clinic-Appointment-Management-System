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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý biểu giá cho Manager.
 * Hiển thị danh sách dịch vụ y tế + thuốc trong một giao diện thống nhất.
 *
 * GET  → hiển thị danh sách biểu giá (dịch vụ + thuốc) với phân trang + tìm kiếm + lọc
 * POST → xử lý sửa giá + thêm mới
 */
@WebServlet(urlPatterns = {"/manager/pricing/", "/manager/pricing"})
public class ManagerPricingServlet extends HttpServlet {

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

        String tab = req.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "services";

        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String activeStr = req.getParameter("active");
        Boolean activeFilter = null;
        if (activeStr != null && !activeStr.isEmpty()) {
            activeFilter = "1".equals(activeStr);
        }

        if ("medicines".equals(tab)) {
            List<Medicine> medicines = medicineService.getMedicines(page, PAGE_SIZE, search, activeFilter, null);
            int totalMedicines = medicineService.getTotalMedicines(search, activeFilter, (Integer) null);
            int totalPages = (int) Math.ceil((double) totalMedicines / PAGE_SIZE);

            req.setAttribute("medicines", medicines);
            req.setAttribute("totalMedicines", totalMedicines);
            req.setAttribute("totalPages", totalPages);
        } else {
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

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/pricing/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String tab = req.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "services";
        String redirectUrl = req.getContextPath() + "/manager/pricing/?tab=" + tab;

        User loggedInUser = (User) req.getSession().getAttribute("user");
        Integer currentUserId = (loggedInUser != null) ? loggedInUser.getId() : null;

        try {
            switch (action != null ? action : "") {

                case "updateServicePrice": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String newPriceStr = req.getParameter("price");
                    String serviceName = req.getParameter("serviceName");
                    String serviceCode = req.getParameter("serviceCode");
                    String description = req.getParameter("description");
                    String durationMins = req.getParameter("durationMins");
                    boolean isActive = "on".equals(req.getParameter("isActive"));

                    // Validate price > 50,000 VNĐ
                    BigDecimal newPrice;
                    try {
                        if (newPriceStr == null || newPriceStr.trim().isEmpty()) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Vui lòng nhập đơn giá!", "UTF-8"));
                            return;
                        }
                        newPrice = new BigDecimal(newPriceStr.trim());
                        if (newPrice.compareTo(new BigDecimal("50000")) < 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Đơn giá dịch vụ phải lớn hơn hoặc bằng 50.000 VNĐ!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Đơn giá dịch vụ không hợp lệ!", "UTF-8"));
                        return;
                    }

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
                            "Sửa giá dịch vụ (Manager)");

                    if (success) {
                        logAudit(req, "UPDATE_SERVICE_PRICE",
                                "Sửa giá dịch vụ #" + id + " \"" + existing.getServiceName() + "\": " +
                                oldPrice + " → " + newPrice);
                        resp.sendRedirect(redirectUrl + "&success=updated");
                    } else {
                        // Lấy lỗi cụ thể từ Service layer
                        String errMsg = errors.get("price");
                        if (errMsg == null) errMsg = errors.get("serviceCode");
                        if (errMsg == null) errMsg = errors.get("general");
                        if (errMsg == null) errMsg = "Cập nhật thất bại!";
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode(errMsg, "UTF-8"));
                    }
                    return;
                }

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

                    // Validate price > 50,000 VNĐ
                    BigDecimal newPrice;
                    try {
                        if (newPriceStr == null || newPriceStr.trim().isEmpty()) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Vui lòng nhập đơn giá!", "UTF-8"));
                            return;
                        }
                        newPrice = new BigDecimal(newPriceStr.trim());
                        if (newPrice.compareTo(new BigDecimal("50000")) < 0) {
                            resp.sendRedirect(redirectUrl + "&error=" +
                                java.net.URLEncoder.encode("Đơn giá thuốc phải lớn hơn hoặc bằng 50.000 VNĐ!", "UTF-8"));
                            return;
                        }
                    } catch (NumberFormatException e) {
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode("Đơn giá thuốc không hợp lệ!", "UTF-8"));
                        return;
                    }

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
                            "Sửa giá thuốc (Manager)",
                            existing.getCategoryId() != null ? String.valueOf(existing.getCategoryId()) : "");

                    if (success) {
                        logAudit(req, "UPDATE_MEDICINE_PRICE",
                                "Sửa giá thuốc #" + id + " \"" + existing.getName() + "\": " +
                                oldPrice + " → " + newPrice);
                        resp.sendRedirect(redirectUrl + "&success=updated");
                    } else {
                        // Lấy lỗi cụ thể từ Service layer
                        String errMsg = errors.get("price");
                        if (errMsg == null) errMsg = errors.get("medicineCode");
                        if (errMsg == null) errMsg = errors.get("general");
                        if (errMsg == null) errMsg = "Cập nhật thất bại!";
                        resp.sendRedirect(redirectUrl + "&error=" +
                            java.net.URLEncoder.encode(errMsg, "UTF-8"));
                    }
                    return;
                }

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

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("ManagerPricingServlet POST: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "&error=Lỗi+hệ+thống");
        }
    }

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

    private void logAudit(HttpServletRequest req, String action, String detail) {
        try {
            User actor = (User) req.getSession().getAttribute("user");
            String actorName = actor != null ? actor.getFullName() : "System";
            System.out.println("[AUDIT-MANAGER-PRICING] " + action + " | By: " + actorName + " | " + detail);
        } catch (Exception e) {
            System.err.println("Lỗi ghi audit log: " + e.getMessage());
        }
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}

