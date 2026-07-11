package com.clinic.service;

import com.clinic.dao.PriceHistoryDAO;
import com.clinic.dao.ServiceCategoryDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.model.PriceHistory;
import com.clinic.model.Service;
import com.clinic.model.ServiceCategory;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý biểu giá dịch vụ y tế.
 * Có tracking lịch sử thay đổi giá + thống kê.
 */
public class ServiceService {

    private final ServiceDAO serviceDAO;
    private final ServiceCategoryDAO categoryDAO;
    private final PriceHistoryDAO priceHistoryDAO;

    public ServiceService() {
        this.serviceDAO = new ServiceDAO();
        this.categoryDAO = new ServiceCategoryDAO();
        this.priceHistoryDAO = new PriceHistoryDAO();
    }

    // ──────────────────────────────────────────────
    //  Service CRUD
    // ──────────────────────────────────────────────

    // ── Backward-compatible overloads (không có categoryId) ──
    @Deprecated
    public List<Service> getServices(int page, int pageSize,
                                      String search, Boolean activeFilter) {
        return getServices(page, pageSize, search, activeFilter, null);
    }

    @Deprecated
    public int getTotalServices(String search, Boolean activeFilter) {
        return getTotalServices(search, activeFilter, (Integer) null);
    }

    /** Lấy danh sách dịch vụ có phân trang + filter + thống kê */
    public List<Service> getServices(int page, int pageSize,
                                      String search, Boolean activeFilter,
                                      Integer categoryId) {
        int offset = (page - 1) * pageSize;
        try {
            return serviceDAO.findAllWithUsage(offset, pageSize, search, activeFilter, categoryId);
        } catch (Exception e) {
            System.err.println("[ServiceService] getServices ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số dịch vụ (để tính số trang) */
    public int getTotalServices(String search, Boolean activeFilter, Integer categoryId) {
        try {
            return serviceDAO.countAllWithFilter(search, activeFilter, categoryId);
        } catch (Exception e) {
            System.err.println("[ServiceService] getTotalServices ERROR: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Tổng số dịch vụ tồn tại đến ngày maxDate.
     * Dùng cho dashboard khi lọc theo khoảng ngày.
     * @param maxDate null → đếm tất cả (không lọc ngày)
     */
    public int getTotalServices(String search, Boolean activeFilter, java.time.LocalDate maxDate) {
        try {
            return serviceDAO.countAllOnOrBefore(search, activeFilter, maxDate);
        } catch (Exception e) {
            System.err.println("[ServiceService] getTotalServices (date) ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Lấy dịch vụ theo id */
    public Service getServiceById(int id) {
        return serviceDAO.findById(id);
    }

    // ── Backward-compatible overloads (không có createdBy) ──
    @Deprecated
    public boolean createService(String serviceCode, String serviceName, String description,
                                  String priceStr, String durationMinsStr,
                                  boolean requiresFasting, boolean requiresFullBladder,
                                  String requiredRoomType, String allowedSpecialties,
                                  String categoryIdStr, Map<String, String> errors) {
        return createService(serviceCode, serviceName, description, priceStr, durationMinsStr,
                requiresFasting, requiresFullBladder, requiredRoomType, allowedSpecialties,
                categoryIdStr, errors, null);
    }

    /** Tạo dịch vụ mới — tự động ghi lịch sử giá ban đầu */
    public boolean createService(String serviceCode, String serviceName, String description,
                                  String priceStr, String durationMinsStr,
                                  boolean requiresFasting, boolean requiresFullBladder,
                                  String requiredRoomType, String allowedSpecialties,
                                  String categoryIdStr, Map<String, String> errors,
                                  Integer createdBy) {
        // Validate
        if (serviceCode == null || serviceCode.trim().isEmpty()) {
            errors.put("serviceCode", "Vui lòng nhập mã dịch vụ.");
            return false;
        }
        if (serviceName == null || serviceName.trim().isEmpty()) {
            errors.put("serviceName", "Vui lòng nhập tên dịch vụ.");
            return false;
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceStr);
            if (price.compareTo(new BigDecimal("50000")) < 0) {
                errors.put("price", "Đơn giá phải lớn hơn hoặc bằng 50.000 VNĐ.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Đơn giá không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã
        if (serviceDAO.findByCode(serviceCode.trim()) != null) {
            errors.put("serviceCode", "Mã dịch vụ đã tồn tại. Vui lòng chọn mã khác.");
            return false;
        }

        Service svc = new Service();
        svc.setServiceCode(serviceCode.trim());
        svc.setServiceName(serviceName.trim());
        svc.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        svc.setPrice(price);
        try {
            svc.setDurationMins(Integer.parseInt(durationMinsStr));
        } catch (NumberFormatException e) {
            svc.setDurationMins(0);
        }
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null && !requiredRoomType.trim().isEmpty() ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null && !allowedSpecialties.trim().isEmpty() ? allowedSpecialties.trim() : null);
        try {
            svc.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) {
            svc.setCategoryId(null);
        }
        svc.setActive(true);

        try {
            int newId = serviceDAO.insert(svc);
            // Ghi nhận giá khởi tạo vào lịch sử
            priceHistoryDAO.insert(newId, null, price, "Khởi tạo dịch vụ mới", createdBy);
            return true;
        } catch (Exception e) {
            System.err.println("[ServiceService] createService ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            errors.put("general", "Lỗi khi tạo dịch vụ: " + e.getMessage());
            return false;
        }
    }

    // ── Backward-compatible overload (không có changedBy, changeReason) ──
    @Deprecated
    public boolean updateService(int id, String serviceCode, String serviceName,
                                  String description, String priceStr,
                                  String durationMinsStr, boolean requiresFasting,
                                  boolean requiresFullBladder, String requiredRoomType,
                                  String allowedSpecialties, String categoryIdStr,
                                  boolean isActive, Map<String, String> errors) {
        return updateService(id, serviceCode, serviceName, description, priceStr,
                durationMinsStr, requiresFasting, requiresFullBladder, requiredRoomType,
                allowedSpecialties, categoryIdStr, isActive, errors, null, null);
    }

    /** Cập nhật dịch vụ — tự động ghi lịch sử nếu giá thay đổi */
    public boolean updateService(int id, String serviceCode, String serviceName,
                                  String description, String priceStr,
                                  String durationMinsStr, boolean requiresFasting,
                                  boolean requiresFullBladder, String requiredRoomType,
                                  String allowedSpecialties, String categoryIdStr,
                                  boolean isActive, Map<String, String> errors,
                                  Integer changedBy, String changeReason) {
        Service svc = serviceDAO.findById(id);
        if (svc == null) {
            errors.put("general", "Dịch vụ không tồn tại.");
            return false;
        }
        if (serviceCode == null || serviceCode.trim().isEmpty()) {
            errors.put("serviceCode", "Vui lòng nhập mã dịch vụ.");
            return false;
        }
        if (serviceName == null || serviceName.trim().isEmpty()) {
            errors.put("serviceName", "Vui lòng nhập tên dịch vụ.");
            return false;
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceStr);
            if (price.compareTo(new BigDecimal("50000")) < 0) {
                errors.put("price", "Đơn giá phải lớn hơn hoặc bằng 50.000 VNĐ.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Đơn giá không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã (ngoại trừ chính nó)
        Service existingByCode = serviceDAO.findByCode(serviceCode.trim());
        if (existingByCode != null && existingByCode.getId() != id) {
            errors.put("serviceCode", "Mã dịch vụ đã được sử dụng bởi dịch vụ khác.");
            return false;
        }

        BigDecimal oldPrice = svc.getPrice(); // Giá cũ trước khi cập nhật

        svc.setServiceCode(serviceCode.trim());
        svc.setServiceName(serviceName.trim());
        svc.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        svc.setPrice(price);
        try { svc.setDurationMins(Integer.parseInt(durationMinsStr)); } catch (NumberFormatException e) { }
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null && !requiredRoomType.trim().isEmpty() ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null && !allowedSpecialties.trim().isEmpty() ? allowedSpecialties.trim() : null);
        try {
            svc.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) { }
        svc.setActive(isActive);

        boolean updated = serviceDAO.update(svc);
        if (!updated) {
            errors.put("general", "Không thể cập nhật dịch vụ. Vui lòng thử lại.");
            return false;
        }

        // Ghi lịch sử nếu giá thay đổi
        if (oldPrice != null && oldPrice.compareTo(price) != 0) {
            String reason = (changeReason != null && !changeReason.trim().isEmpty())
                    ? changeReason.trim()
                    : "Cập nhật giá dịch vụ";
            priceHistoryDAO.insert(id, oldPrice, price, reason, changedBy);
        }

        return true;
    }

    /** Vô hiệu hóa dịch vụ (soft delete) */
    public boolean deactivateService(int id) {
        return serviceDAO.deactivate(id);
    }

    /** Kích hoạt lại dịch vụ */
    public boolean activateService(int id) {
        return serviceDAO.activate(id);
    }

    /** Toggle trạng thái hoạt động */
    public boolean toggleServiceStatus(int id) {
        Service svc = serviceDAO.findById(id);
        if (svc == null) return false;
        if (svc.isActive()) {
            return serviceDAO.deactivate(id);
        } else {
            return serviceDAO.activate(id);
        }
    }

    /** Lấy tất cả dịch vụ đang hoạt động (dùng cho dropdown) */
    public List<Service> getActiveServices() {
        return serviceDAO.findAllActive();
    }

    // ──────────────────────────────────────────────
    //  Categories
    // ──────────────────────────────────────────────

    /** Lấy danh sách nhóm dịch vụ */
    public List<ServiceCategory> getCategories() {
        return categoryDAO.findAll();
    }

    /** Lấy danh sách nhóm dịch vụ kèm thống kê */
    public List<ServiceCategory> getCategoriesWithStats() {
        return categoryDAO.findAllWithStats();
    }

    /** Lấy category theo id */
    public ServiceCategory getCategoryById(int id) {
        return categoryDAO.findById(id);
    }

    // ──────────────────────────────────────────────
    //  Price History
    // ──────────────────────────────────────────────

    /** Lấy lịch sử giá của một dịch vụ */
    public List<PriceHistory> getPriceHistory(int serviceId) {
        return priceHistoryDAO.findByServiceId(serviceId);
    }

    /** Lấy tất cả lịch sử giá (phân trang) */
    public List<PriceHistory> getAllPriceHistory(int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        return priceHistoryDAO.findAll(offset, pageSize);
    }

    /** Tổng số bản ghi lịch sử giá */
    public int getTotalPriceHistory() {
        return priceHistoryDAO.countAll();
    }

    // ──────────────────────────────────────────────
    //  Statistics
    // ──────────────────────────────────────────────

    /** Thống kê doanh thu theo nhóm dịch vụ */
    public List<Service> getRevenueByCategory() {
        return serviceDAO.getRevenueByCategory();
    }

    /** Số dịch vụ đang hoạt động */
    public int getActiveServiceCount() {
        return serviceDAO.countActive();
    }

    /** Lấy usage count cho một service */
    public int getUsageCount(int serviceId) {
        return serviceDAO.getUsageCount(serviceId);
    }
}
