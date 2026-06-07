package com.clinic.service;

import com.clinic.dao.ServiceDAO;
import com.clinic.model.Service;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý biểu giá dịch vụ y tế.
 */
public class ServiceService {

    private final ServiceDAO serviceDAO;

    public ServiceService() {
        this.serviceDAO = new ServiceDAO();
    }

    /** Lấy danh sách dịch vụ có phân trang + filter */
    public List<Service> getServices(int page, int pageSize,
                                      String search, Boolean activeFilter) {
        int offset = (page - 1) * pageSize;
        try {
            return serviceDAO.findAll(offset, pageSize, search, activeFilter);
        } catch (Exception e) {
            System.err.println("[ServiceService] getServices ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số dịch vụ (để tính số trang) */
    public int getTotalServices(String search, Boolean activeFilter) {
        try {
            return serviceDAO.countAll(search, activeFilter);
        } catch (Exception e) {
            System.err.println("[ServiceService] getTotalServices ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Lấy dịch vụ theo id */
    public Service getServiceById(int id) {
        return serviceDAO.findById(id);
    }

    /** Tạo dịch vụ mới */
    public boolean createService(String serviceCode, String serviceName, String description,
                                  String priceStr, String durationMinsStr,
                                  boolean requiresFasting, boolean requiresFullBladder,
                                  String requiredRoomType, String allowedSpecialties,
                                  String categoryIdStr, Map<String, String> errors) {
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
            if (price.compareTo(BigDecimal.ZERO) < 0) {
                errors.put("price", "Đơn giá không được âm.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Đơn giá không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã
        if (serviceDAO.findByCode(serviceCode.trim()) != null) {
            errors.put("serviceCode", "Mã dịch vụ đã tồn tại.");
            return false;
        }

        Service svc = new Service();
        svc.setServiceCode(serviceCode.trim());
        svc.setServiceName(serviceName.trim());
        svc.setDescription(description != null ? description.trim() : null);
        svc.setPrice(price);
        try {
            svc.setDurationMins(Integer.parseInt(durationMinsStr));
        } catch (NumberFormatException e) {
            svc.setDurationMins(0);
        }
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null ? allowedSpecialties.trim() : null);
        try {
            svc.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) {
            svc.setCategoryId(null);
        }
        svc.setActive(true);

        try {
            serviceDAO.insert(svc);
            return true;
        } catch (Exception e) {
            errors.put("general", "Lỗi khi tạo dịch vụ: " + e.getMessage());
            return false;
        }
    }

    /** Cập nhật dịch vụ */
    public boolean updateService(int id, String serviceCode, String serviceName,
                                  String description, String priceStr,
                                  String durationMinsStr, boolean requiresFasting,
                                  boolean requiresFullBladder, String requiredRoomType,
                                  String allowedSpecialties, String categoryIdStr,
                                  boolean isActive, Map<String, String> errors) {
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
            if (price.compareTo(BigDecimal.ZERO) < 0) {
                errors.put("price", "Đơn giá không được âm.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Đơn giá không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã (ngoại trừ chính nó)
        Service existing = serviceDAO.findByCode(serviceCode.trim());
        if (existing != null && existing.getId() != id) {
            errors.put("serviceCode", "Mã dịch vụ đã được sử dụng bởi dịch vụ khác.");
            return false;
        }

        svc.setServiceCode(serviceCode.trim());
        svc.setServiceName(serviceName.trim());
        svc.setDescription(description != null ? description.trim() : null);
        svc.setPrice(price);
        try { svc.setDurationMins(Integer.parseInt(durationMinsStr)); } catch (NumberFormatException e) { }
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null ? allowedSpecialties.trim() : null);
        try {
            svc.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) { }
        svc.setActive(isActive);

        return serviceDAO.update(svc);
    }

    /** Vô hiệu hóa dịch vụ (soft delete) */
    public boolean deactivateService(int id) {
        return serviceDAO.deactivate(id);
    }

    /** Lấy tất cả dịch vụ đang hoạt động (dùng cho dropdown) */
    public List<Service> getActiveServices() {
        return serviceDAO.findAllActive();
    }
}
