package com.clinic.service;

import com.clinic.dao.MedicineCategoryDAO;
import com.clinic.dao.MedicineDAO;
import com.clinic.dao.MedicinePriceHistoryDAO;
import com.clinic.model.Medicine;
import com.clinic.model.MedicineCategory;
import com.clinic.model.MedicinePriceHistory;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý biểu giá thuốc.
 * Có tracking lịch sử thay đổi giá.
 */
public class MedicineService {

    private final MedicineDAO medicineDAO;
    private final MedicinePriceHistoryDAO priceHistoryDAO;
    private final MedicineCategoryDAO categoryDAO;

    public MedicineService() {
        this.medicineDAO = new MedicineDAO();
        this.priceHistoryDAO = new MedicinePriceHistoryDAO();
        this.categoryDAO = new MedicineCategoryDAO();
    }

    // Backward-compatible
    @Deprecated
    public List<Medicine> getMedicines(int page, int pageSize,
                                        String search, Boolean activeFilter) {
        return getMedicines(page, pageSize, search, activeFilter, null);
    }

    /** Lấy danh sách thuốc có phân trang + filter + nhóm */
    public List<Medicine> getMedicines(int page, int pageSize,
                                        String search, Boolean activeFilter,
                                        Integer categoryId) {
        int offset = (page - 1) * pageSize;
        try {
            return medicineDAO.findAllWithCategory(offset, pageSize, search, activeFilter, categoryId);
        } catch (Exception e) {
            System.err.println("[MedicineService] getMedicines ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    @Deprecated
    public int getTotalMedicines(String search, Boolean activeFilter) {
        return getTotalMedicines(search, activeFilter, null);
    }

    /** Tổng số thuốc (có filter category) */
    public int getTotalMedicines(String search, Boolean activeFilter, Integer categoryId) {
        try {
            return medicineDAO.countAllWithFilter(search, activeFilter, categoryId);
        } catch (Exception e) {
            System.err.println("[MedicineService] getTotalMedicines ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Lấy thuốc theo id */
    public Medicine getMedicineById(int id) {
        return medicineDAO.findById(id);
    }

    // Backward-compatible overload
    @Deprecated
    public boolean createMedicine(String medicineCode, String name, String description,
                                   String dosage, String unit, String priceStr,
                                   String stockQuantityStr, Map<String, String> errors) {
        return createMedicine(medicineCode, name, description, dosage, unit, priceStr, stockQuantityStr, errors, null, null);
    }

    /** Tạo thuốc mới — tự động ghi lịch sử giá ban đầu */
    public boolean createMedicine(String medicineCode, String name, String description,
                                   String dosage, String unit, String priceStr,
                                   String stockQuantityStr, Map<String, String> errors,
                                   Integer createdBy, String categoryIdStr) {
        if (medicineCode == null || medicineCode.trim().isEmpty()) {
            errors.put("medicineCode", "Vui lòng nhập mã thuốc.");
            return false;
        }
        if (name == null || name.trim().isEmpty()) {
            errors.put("name", "Vui lòng nhập tên thuốc.");
            return false;
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceStr);
            if (price.compareTo(new BigDecimal("1000")) < 0) {
                errors.put("price", "Giá bán phải lớn hơn hoặc bằng 1.000 VNĐ.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Giá bán không hợp lệ.");
            return false;
        }
        if (medicineDAO.findByCode(medicineCode.trim()) != null) {
            errors.put("medicineCode", "Mã thuốc đã tồn tại.");
            return false;
        }

        Medicine med = new Medicine();
        med.setMedicineCode(medicineCode.trim());
        med.setName(name.trim());
        med.setDescription(description != null ? description.trim() : null);
        med.setDosage(dosage != null ? dosage.trim() : null);
        med.setUnit(unit != null ? unit.trim() : null);
        med.setPrice(price);
        try {
            med.setStockQuantity(Integer.parseInt(stockQuantityStr));
        } catch (NumberFormatException e) {
            med.setStockQuantity(0);
        }
        med.setActive(true);
        try {
            med.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) { med.setCategoryId(null); }

        try {
            int newId = medicineDAO.insert(med);
            priceHistoryDAO.insert(newId, null, price, "Khởi tạo thuốc mới", createdBy);
            return true;
        } catch (Exception e) {
            errors.put("general", "Lỗi khi tạo thuốc: " + e.getMessage());
            return false;
        }
    }

    // Backward-compatible overload
    @Deprecated
    public boolean updateMedicine(int id, String medicineCode, String name,
                                   String description, String dosage, String unit,
                                   String priceStr, String stockQuantityStr,
                                   boolean isActive, Map<String, String> errors) {
        return updateMedicine(id, medicineCode, name, description, dosage, unit, priceStr, stockQuantityStr, isActive, errors, null, null, null);
    }

    /** Cập nhật thuốc — tự động ghi lịch sử nếu giá thay đổi */
    public boolean updateMedicine(int id, String medicineCode, String name,
                                   String description, String dosage, String unit,
                                   String priceStr, String stockQuantityStr,
                                   boolean isActive, Map<String, String> errors,
                                   Integer changedBy, String changeReason, String categoryIdStr) {
        Medicine med = medicineDAO.findById(id);
        if (med == null) {
            errors.put("general", "Thuốc không tồn tại.");
            return false;
        }
        if (medicineCode == null || medicineCode.trim().isEmpty()) {
            errors.put("medicineCode", "Vui lòng nhập mã thuốc.");
            return false;
        }
        if (name == null || name.trim().isEmpty()) {
            errors.put("name", "Vui lòng nhập tên thuốc.");
            return false;
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceStr);
            if (price.compareTo(new BigDecimal("1000")) < 0) {
                errors.put("price", "Giá bán phải lớn hơn hoặc bằng 1.000 VNĐ.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Giá bán không hợp lệ.");
            return false;
        }
        Medicine existing = medicineDAO.findByCode(medicineCode.trim());
        if (existing != null && existing.getId() != id) {
            errors.put("medicineCode", "Mã thuốc đã được sử dụng bởi thuốc khác.");
            return false;
        }

        BigDecimal oldPrice = med.getPrice();

        med.setMedicineCode(medicineCode.trim());
        med.setName(name.trim());
        med.setDescription(description != null ? description.trim() : null);
        med.setDosage(dosage != null ? dosage.trim() : null);
        med.setUnit(unit != null ? unit.trim() : null);
        med.setPrice(price);
        try {
            med.setStockQuantity(Integer.parseInt(stockQuantityStr));
        } catch (NumberFormatException e) { }
        med.setActive(isActive);
        try {
            med.setCategoryId(categoryIdStr != null && !categoryIdStr.isEmpty()
                    ? Integer.parseInt(categoryIdStr) : null);
        } catch (NumberFormatException e) { med.setCategoryId(null); }

        boolean updated = medicineDAO.update(med);
        if (updated && oldPrice != null && oldPrice.compareTo(price) != 0) {
            String reason = (changeReason != null && !changeReason.trim().isEmpty())
                    ? changeReason.trim()
                    : "Cập nhật giá thuốc";
            priceHistoryDAO.insert(id, oldPrice, price, reason, changedBy);
        }
        return updated;
    }

    /** Vô hiệu hóa thuốc (soft delete) */
    public boolean deactivateMedicine(int id) {
        return medicineDAO.deactivate(id);
    }

    /** Kích hoạt lại thuốc */
    public boolean activateMedicine(int id) {
        return medicineDAO.activate(id);
    }

    /** Toggle trạng thái hoạt động */
    public boolean toggleMedicineStatus(int id) {
        Medicine med = medicineDAO.findById(id);
        if (med == null) return false;
        if (med.isActive()) {
            return medicineDAO.deactivate(id);
        } else {
            return medicineDAO.activate(id);
        }
    }

    /** Lấy tất cả thuốc đang hoạt động (dùng cho dropdown) */
    public List<Medicine> getActiveMedicines() {
        return medicineDAO.findAllActive();
    }

    /** Số thuốc đang hoạt động */
    public int getActiveMedicineCount() {
        return medicineDAO.countActive();
    }

    // ── Categories ──

    public List<MedicineCategory> getCategories() {
        return categoryDAO.findAll();
    }

    public List<MedicineCategory> getCategoriesWithStats() {
        return categoryDAO.findAllWithStats();
    }

    // ── Price History ──

    /** Lấy lịch sử giá của một thuốc */
    public List<MedicinePriceHistory> getPriceHistory(int medicineId) {
        return priceHistoryDAO.findByMedicineId(medicineId);
    }

    /** Lấy tất cả lịch sử giá thuốc (phân trang) */
    public List<MedicinePriceHistory> getAllPriceHistory(int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        return priceHistoryDAO.findAll(offset, pageSize);
    }

    /** Tổng số bản ghi lịch sử giá thuốc */
    public int getTotalPriceHistory() {
        return priceHistoryDAO.countAll();
    }

    // ── Cảnh báo tồn kho ──

    /**
     * Lấy danh sách thuốc sắp hết hàng cho Dashboard cảnh báo tồn kho.
     * Chỉ lấy thuốc đang active, sắp xếp theo tồn kho tăng dần.
     *
     * @param threshold Ngưỡng tồn kho (VD: 10 → thuốc có stock ≤ 10)
     * @param limit     Số lượng tối đa trả về
     * @return Danh sách thuốc sắp hết, rỗng nếu không có cảnh báo
     */
    public List<Medicine> getLowStockMedicines(int threshold, int limit) {
        try {
            return medicineDAO.findLowStock(threshold, limit);
        } catch (Exception e) {
            System.err.println("[MedicineService] getLowStockMedicines ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
