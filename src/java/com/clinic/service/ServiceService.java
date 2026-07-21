package com.clinic.service;

import com.clinic.dao.PriceHistoryDAO;
import com.clinic.dao.ServiceCategoryDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.model.PriceHistory;
import com.clinic.model.Service;
import com.clinic.model.ServiceCategory;
import com.clinic.utils.ValidationUtil;

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

    /**
     * Tạo dịch vụ mới — validate chuẩn theo đặc tả phòng khám.
     *
     * Quy tắc:
     * - Mã DV: bắt buộc, 3-30 ký tự, chỉ chữ hoa + số + gạch ngang/gạch dưới, không trùng
     * - Tên DV: bắt buộc, 2-100 ký tự, không chỉ gồm số/KTĐB, không trùng (case-insensitive)
     * - Nhóm DV: bắt buộc chọn, phải tồn tại trong DB
     * - Đơn giá: bắt buộc, số nguyên dương, 50.000đ – 100.000.000đ
     * - Thời gian: bắt buộc, 5 – 480 phút
     * - Mô tả: optional, max 500 ký tự, không được vô nghĩa
     * - Phòng: optional (chọn từ danh sách), max 50 ký tự
     * - Chuyên khoa: optional (chọn nhiều), max 255 ký tự
     *
     * @return true nếu tạo thành công (có ghi audit + lịch sử giá)
     */
    public boolean createService(String serviceCode, String serviceName, String description,
                                  String priceStr, String durationMinsStr,
                                  boolean requiresFasting, boolean requiresFullBladder,
                                  String requiredRoomType, String allowedSpecialties,
                                  String categoryIdStr, Map<String, String> errors,
                                  Integer createdBy) {

        // ── 1. Validate mã dịch vụ (bắt buộc, định dạng, không trùng) ──
        String codeErr = ValidationUtil.validateServiceCode(serviceCode);
        if (codeErr != null) {
            errors.put("serviceCode", codeErr);
            return false;
        }
        String code = serviceCode.trim();
        if (serviceDAO.findByCode(code) != null) {
            errors.put("serviceCode", "Mã dịch vụ «" + code + "» đã tồn tại. Vui lòng chọn mã khác.");
            return false;
        }

        // ── 2. Validate tên dịch vụ (bắt buộc, định dạng, không trùng) ──
        String nameErr = ValidationUtil.validateServiceName(serviceName);
        if (nameErr != null) {
            errors.put("serviceName", nameErr);
            return false;
        }
        String name = serviceName.trim();
        // Kiểm tra trùng tên (case-insensitive)
        Service duplicateName = serviceDAO.findByName(name);
        if (duplicateName != null) {
            errors.put("serviceName", "Tên dịch vụ «" + name + "» đã tồn tại (mã: "
                    + duplicateName.getServiceCode() + "). Vui lòng nhập tên khác.");
            return false;
        }

        // ── 3. Validate nhóm dịch vụ (bắt buộc) ──
        String catErr = ValidationUtil.validateCategoryRequired(categoryIdStr);
        if (catErr != null) {
            errors.put("categoryId", catErr);
            return false;
        }
        int categoryId = Integer.parseInt(categoryIdStr.trim());
        if (categoryDAO.findById(categoryId) == null) {
            errors.put("categoryId", "Nhóm dịch vụ đã chọn không tồn tại trong hệ thống.");
            return false;
        }

        // ── 4. Validate đơn giá (bắt buộc, số nguyên dương, trong khoảng) ──
        String priceErr = ValidationUtil.validateServicePrice(priceStr);
        if (priceErr != null) {
            errors.put("price", priceErr);
            return false;
        }
        BigDecimal price = new BigDecimal(priceStr.trim());

        // ── 5. Validate thời gian thực hiện (bắt buộc, 5-480 phút) ──
        String durationErr = ValidationUtil.validateDurationMins(durationMinsStr);
        if (durationErr != null) {
            errors.put("durationMins", durationErr);
            return false;
        }
        int durationMins = Integer.parseInt(durationMinsStr.trim());

        // ── 6. Validate mô tả (optional, max 500, không vô nghĩa) ──
        String descErr = ValidationUtil.validateServiceDescription(description);
        if (descErr != null) {
            errors.put("description", descErr);
            return false;
        }

        // ── 7. Validate phòng thực hiện (optional, chọn từ danh sách) ──
        String roomErr = ValidationUtil.validateRoomType(requiredRoomType);
        if (roomErr != null) {
            errors.put("requiredRoomType", roomErr);
            return false;
        }

        // ── 8. Validate chuyên khoa (optional, chọn nhiều) ──
        String specErr = ValidationUtil.validateAllowedSpecialties(allowedSpecialties);
        if (specErr != null) {
            errors.put("allowedSpecialties", specErr);
            return false;
        }

        // ── 9. Tạo entity & lưu (có rollback nếu lỗi) ──
        Service svc = new Service();
        svc.setServiceCode(code);
        svc.setServiceName(name);
        svc.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        svc.setPrice(price);
        svc.setDurationMins(durationMins);
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null && !requiredRoomType.trim().isEmpty() ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null && !allowedSpecialties.trim().isEmpty() ? allowedSpecialties.trim() : null);
        svc.setCategoryId(categoryId);
        svc.setActive(true);

        try {
            int newId = serviceDAO.insert(svc);
            if (newId <= 0) {
                errors.put("general", "Không thể tạo dịch vụ — lỗi từ database. Vui lòng thử lại.");
                return false;
            }
            // Ghi nhận giá khởi tạo vào lịch sử giá
            priceHistoryDAO.insert(newId, null, price, "Khởi tạo dịch vụ mới", createdBy);
            return true;
        } catch (Exception e) {
            // Rollback: dữ liệu đã được commit từng phần sẽ được ghi log, không thể rollback
            // ở tầng JDBC thuần nếu không dùng transaction. Ghi log lỗi đầy đủ.
            System.err.println("[ServiceService] createService ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            errors.put("general", "Lỗi hệ thống khi tạo dịch vụ. Giao dịch đã bị hủy. Vui lòng thử lại.");
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

    /**
     * Cập nhật dịch vụ — validate chuẩn theo đặc tả phòng khám.
     *
     * QUAN TRỌNG: Mã dịch vụ là khóa định danh, KHÔNG được phép chỉnh sửa sau khi tạo.
     * Tham số serviceCode được giữ lại để tương thích ngược nhưng sẽ bị bỏ qua —
     * hệ thống luôn dùng mã gốc từ DB.
     *
     * @param serviceCode bị bỏ qua (dùng mã gốc từ DB để đảm bảo toàn vẹn)
     */
    public boolean updateService(int id, String serviceCode, String serviceName,
                                  String description, String priceStr,
                                  String durationMinsStr, boolean requiresFasting,
                                  boolean requiresFullBladder, String requiredRoomType,
                                  String allowedSpecialties, String categoryIdStr,
                                  boolean isActive, Map<String, String> errors,
                                  Integer changedBy, String changeReason) {
        Service svc = serviceDAO.findById(id);
        if (svc == null) {
            errors.put("general", "Dịch vụ không tồn tại hoặc đã bị xóa.");
            return false;
        }

        // ── 1. Mã dịch vụ: KHÔNG cho phép thay đổi (khóa định danh) ──
        // Luôn giữ nguyên mã gốc từ DB, bỏ qua serviceCode từ request
        String originalCode = svc.getServiceCode();

        // ── 2. Validate tên dịch vụ (bắt buộc, định dạng, không trùng) ──
        String nameErr = ValidationUtil.validateServiceName(serviceName);
        if (nameErr != null) {
            errors.put("serviceName", nameErr);
            return false;
        }
        String name = serviceName.trim();
        // Kiểm tra trùng tên (case-insensitive, ngoại trừ chính nó)
        Service duplicateName = serviceDAO.findByName(name);
        if (duplicateName != null && duplicateName.getId() != id) {
            errors.put("serviceName", "Tên dịch vụ «" + name + "» đã tồn tại (mã: "
                    + duplicateName.getServiceCode() + "). Vui lòng nhập tên khác.");
            return false;
        }

        // ── 3. Validate nhóm dịch vụ (bắt buộc) ──
        Integer categoryId;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
                if (categoryDAO.findById(categoryId) == null) {
                    errors.put("categoryId", "Nhóm dịch vụ đã chọn không tồn tại.");
                    return false;
                }
            } catch (NumberFormatException e) {
                errors.put("categoryId", "Nhóm dịch vụ không hợp lệ.");
                return false;
            }
        } else if (svc.getCategoryId() != null) {
            // Giữ nguyên category cũ nếu không được gửi lên
            categoryId = svc.getCategoryId();
        } else {
            errors.put("categoryId", "Vui lòng chọn nhóm dịch vụ.");
            return false;
        }

        // ── 4. Validate đơn giá (bắt buộc, số nguyên dương, trong khoảng) ──
        String priceErr = ValidationUtil.validateServicePrice(priceStr);
        if (priceErr != null) {
            errors.put("price", priceErr);
            return false;
        }
        BigDecimal price = new BigDecimal(priceStr.trim());

        // ── 5. Validate thời gian thực hiện (bắt buộc, 5-480 phút) ──
        String durationErr = ValidationUtil.validateDurationMins(durationMinsStr);
        if (durationErr != null) {
            errors.put("durationMins", durationErr);
            return false;
        }
        int durationMins = Integer.parseInt(durationMinsStr.trim());

        // ── 6. Validate mô tả (optional) ──
        String descErr = ValidationUtil.validateServiceDescription(description);
        if (descErr != null) {
            errors.put("description", descErr);
            return false;
        }

        // ── 7. Validate phòng thực hiện (optional) ──
        String roomErr = ValidationUtil.validateRoomType(requiredRoomType);
        if (roomErr != null) {
            errors.put("requiredRoomType", roomErr);
            return false;
        }

        // ── 8. Validate chuyên khoa (optional) ──
        String specErr = ValidationUtil.validateAllowedSpecialties(allowedSpecialties);
        if (specErr != null) {
            errors.put("allowedSpecialties", specErr);
            return false;
        }

        // ── 9. Cập nhật entity (giữ nguyên serviceCode gốc) ──
        BigDecimal oldPrice = svc.getPrice();

        svc.setServiceCode(originalCode);             // KHÔNG thay đổi mã
        svc.setServiceName(name);
        svc.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        svc.setPrice(price);
        svc.setDurationMins(durationMins);
        svc.setRequiresFasting(requiresFasting);
        svc.setRequiresFullBladder(requiresFullBladder);
        svc.setRequiredRoomType(requiredRoomType != null && !requiredRoomType.trim().isEmpty() ? requiredRoomType.trim() : null);
        svc.setAllowedSpecialties(allowedSpecialties != null && !allowedSpecialties.trim().isEmpty() ? allowedSpecialties.trim() : null);
        svc.setCategoryId(categoryId);
        svc.setActive(isActive);

        try {
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
        } catch (Exception e) {
            System.err.println("[ServiceService] updateService ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            errors.put("general", "Lỗi hệ thống khi cập nhật dịch vụ. Giao dịch đã bị hủy. Vui lòng thử lại.");
            return false;
        }
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
