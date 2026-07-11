package com.clinic.controller;

import com.clinic.model.Service;
import com.clinic.service.ServiceService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý biểu giá dịch vụ cho Admin/Manager.
 * GET  → hiển thị danh sách dịch vụ (phân trang + tìm kiếm + lọc)
 * POST → xử lý thêm / sửa / vô hiệu hóa
 */
@WebServlet(urlPatterns = {"/admin/services/", "/admin/services"})
public class AdminServiceServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private ServiceService serviceService;

    @Override
    public void init() throws ServletException {
        serviceService = new ServiceService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String activeStr = req.getParameter("active");
        Boolean activeFilter = null;
        if (activeStr != null && !activeStr.isEmpty()) {
            activeFilter = "1".equals(activeStr);
        }

        List<Service> services = serviceService.getServices(page, PAGE_SIZE, search, activeFilter);
        int totalServices = serviceService.getTotalServices(search, activeFilter);
        int totalPages = (int) Math.ceil((double) totalServices / PAGE_SIZE);

        req.setAttribute("services", services);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalServices", totalServices);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("activeFilter", activeStr);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/admin/services/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/services/";

        try {
            switch (action != null ? action : "") {

                case "create": {
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
                            requiredRoomType, allowedSpecialties, categoryId, errors)) {
                        AuditUtil.log(req, "Tạo mới dịch vụ: " + serviceName, "services",
                                null, "price=" + price);
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
                    boolean isActive = "on".equals(req.getParameter("isActive"));

                    Map<String, String> errors = new HashMap<>();
                    if (serviceService.updateService(id, serviceCode, serviceName, description,
                            price, durationMins, requiresFasting, requiresFullBladder,
                            requiredRoomType, allowedSpecialties, categoryId, isActive, errors)) {
                        AuditUtil.log(req, "Cập nhật dịch vụ: " + serviceName, "services",
                                null, "price=" + price + ", active=" + isActive);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=" + java.net.URLEncoder.encode(
                            errors.getOrDefault("general", "Cập nhật thất bại"), "UTF-8"));
                    }
                    return;
                }

                case "deactivate": {
                    int id = parseInt(req.getParameter("id"), -1);
                    if (serviceService.deactivateService(id)) {
                        AuditUtil.log(req, "Vô hiệu hóa dịch vụ #" + id, "services", null, null);
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
            System.err.println("AdminServiceServlet POST: " + e.getMessage());
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống");
        }
    }

    /** Lưu dữ liệu form để hiển thị lại khi validation fail */
    private Map<String, String> buildFormData(HttpServletRequest req) {
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

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}

