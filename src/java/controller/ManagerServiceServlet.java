package controller;

import com.clinic.model.PriceHistory;
import com.clinic.model.Service;
import com.clinic.model.ServiceCategory;
import com.clinic.model.User;
import com.clinic.service.ServiceService;
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
 * Servlet quản lý Dịch Vụ Y Tế cho Manager — đầy đủ CRUD + thống kê + lịch sử giá.
 *
 * GET  → hiển thị danh sách dịch vụ (phân trang + tìm kiếm + lọc + thống kê)
 * POST → xử lý thêm / sửa / vô hiệu hóa / kích hoạt / xem chi tiết
 */
@WebServlet(urlPatterns = {"/manager/services/", "/manager/services"})
public class ManagerServiceServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private ServiceService serviceService;

    @Override
    public void init() throws ServletException {
        serviceService = new ServiceService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Xem chi tiết dịch vụ
        if ("detail".equals(action)) {
            handleDetail(req, resp);
            return;
        }

        // Xem lịch sử giá toàn hệ thống
        if ("price-history".equals(action)) {
            handlePriceHistory(req, resp);
            return;
        }

        // Trang chính — danh sách + thống kê
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

        List<Service> services = serviceService.getServices(page, PAGE_SIZE, search, activeFilter, categoryId);
        int totalServices = serviceService.getTotalServices(search, activeFilter, categoryId);
        int totalPages = (int) Math.ceil((double) totalServices / PAGE_SIZE);
        int activeServicesCount = serviceService.getActiveServiceCount();
        List<ServiceCategory> categories = serviceService.getCategoriesWithStats();
        List<Service> revenueByCategory = serviceService.getRevenueByCategory();

        req.setAttribute("services", services);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalServices", totalServices);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("activeFilter", activeStr);
        req.setAttribute("categoryFilter", categoryStr);
        req.setAttribute("activeServicesCount", activeServicesCount);
        req.setAttribute("categories", categories);
        req.setAttribute("revenueByCategory", revenueByCategory);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/manager/services/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/manager/services/";

        // Lấy user hiện tại từ session + IP client để ghi audit log
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        Integer changedBy = (currentUser != null) ? currentUser.getId() : null;
        String clientIp = getClientIp(req);

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
                            requiredRoomType, allowedSpecialties, categoryId, errors, changedBy)) {
                        AuditUtil.log(changedBy,
                                "Tạo mới dịch vụ: " + serviceName + " (mã: " + serviceCode + ")",
                                "services", null, "price=" + price, clientIp);
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
                    // Lưu ý: serviceCode từ request bị Service layer bỏ qua
                    // để bảo vệ khóa định danh (không cho phép sửa mã DV)
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
                    String changeReason = req.getParameter("changeReason");

                    Map<String, String> errors = new HashMap<>();
                    if (serviceService.updateService(id, serviceCode, serviceName, description,
                            price, durationMins, requiresFasting, requiresFullBladder,
                            requiredRoomType, allowedSpecialties, categoryId, isActive, errors,
                            changedBy, changeReason)) {
                        AuditUtil.log(changedBy,
                                "Cập nhật dịch vụ ID=" + id + ": " + serviceName,
                                "services", null, "price=" + price + ", active=" + isActive, clientIp);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildFormData(req));
                        req.setAttribute("showEditModal", true);
                        req.setAttribute("editServiceId", id);
                        doGet(req, resp);
                    }
                    return;
                }

                case "toggle": {
                    int id = parseInt(req.getParameter("id"), -1);
                    Service svc = serviceService.getServiceById(id);
                    if (svc == null) {
                        resp.sendRedirect(redirectUrl + "?error=Dịch+vụ+không+tồn+tại");
                        return;
                    }
                    if (serviceService.toggleServiceStatus(id)) {
                        String msg = svc.isActive() ? "deactivated" : "activated";
                        String actionLabel = svc.isActive() ? "Vô hiệu hóa dịch vụ: " : "Kích hoạt dịch vụ: ";
                        AuditUtil.log(changedBy, actionLabel + svc.getServiceName(),
                                "services", null, null, clientIp);
                        resp.sendRedirect(redirectUrl + "?success=" + msg);
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Thay+đổi+trạng+thái+thất+bại");
                    }
                    return;
                }

                case "deactivate": {
                    int id = parseInt(req.getParameter("id"), -1);
                    if (serviceService.deactivateService(id)) {
                        AuditUtil.log(changedBy, "Vô hiệu hóa dịch vụ ID=" + id,
                                "services", null, null, clientIp);
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
            System.err.println("[ManagerServiceServlet] POST error: " + e.getMessage());
            e.printStackTrace(System.err);
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống:+vui+lòng+thử+lại");
        }
    }

    /**
     * Trích xuất địa chỉ IP thực của client (hỗ trợ sau proxy/load balancer).
     */
    private String getClientIp(HttpServletRequest req) {
        String xForwardedFor = req.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()
                && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            int commaIdx = xForwardedFor.indexOf(',');
            return commaIdx > 0 ? xForwardedFor.substring(0, commaIdx).trim() : xForwardedFor.trim();
        }
        String remoteAddr = req.getRemoteAddr();
        return (remoteAddr != null && !remoteAddr.isEmpty()) ? remoteAddr : "unknown";
    }

    /** Xử lý xem chi tiết dịch vụ (AJAX/trang riêng) */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = parseInt(req.getParameter("id"), -1);
        if (id < 1) {
            resp.sendRedirect(req.getContextPath() + "/manager/services/?error=Không+tìm+thấy+dịch+vụ");
            return;
        }

        Service service = serviceService.getServiceById(id);
        if (service == null) {
            resp.sendRedirect(req.getContextPath() + "/manager/services/?error=Không+tìm+thấy+dịch+vụ");
            return;
        }

        List<PriceHistory> priceHistory = serviceService.getPriceHistory(id);
        int usageCount = serviceService.getUsageCount(id);

        req.setAttribute("detailService", service);
        req.setAttribute("priceHistory", priceHistory);
        req.setAttribute("detailUsageCount", usageCount);

        // Load categories cho hiển thị
        req.setAttribute("categories", serviceService.getCategories());

        req.getRequestDispatcher("/views/manager/services/detail.jsp").forward(req, resp);
    }

    /** Xử lý xem toàn bộ lịch sử giá */
    private void handlePriceHistory(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int page = parseInt(req.getParameter("page"), 1);
        List<PriceHistory> historyList = serviceService.getAllPriceHistory(page, PAGE_SIZE);
        int total = serviceService.getTotalPriceHistory();
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("historyList", historyList);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalHistory", total);
        req.setAttribute("categories", serviceService.getCategories());

        req.getRequestDispatcher("/views/manager/services/price-history.jsp").forward(req, resp);
    }

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
        data.put("changeReason", req.getParameter("changeReason"));
        return data;
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}
