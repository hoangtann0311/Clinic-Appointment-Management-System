package com.clinic.service;

import com.clinic.dao.MedicineCategoryDAO;
import com.clinic.dao.MedicineDAO;
import com.clinic.dao.MedicinePriceHistoryDAO;
import com.clinic.model.Medicine;
import com.clinic.model.MedicineCategory;
import com.clinic.model.MedicinePriceHistory;
import com.clinic.utils.AuditUtil;
import com.clinic.utils.ValidationUtil;

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
        return getTotalMedicines(search, activeFilter, (Integer) null);
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

    /**
     * Tổng số thuốc tồn tại đến ngày maxDate.
     * Dùng cho dashboard khi lọc theo khoảng ngày.
     * @param maxDate null → đếm tất cả (không lọc ngày)
     */
    public int getTotalMedicines(String search, Boolean activeFilter, java.time.LocalDate maxDate) {
        try {
            return medicineDAO.countAllOnOrBefore(search, activeFilter, maxDate);
        } catch (Exception e) {
            System.err.println("[MedicineService] getTotalMedicines (date) ERROR: " + e.getMessage());
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

    /** Tạo thuốc mới — validate toàn diện + tự động ghi lịch sử giá ban đầu */
    public boolean createMedicine(String medicineCode, String name, String description,
                                   String dosage, String unit, String priceStr,
                                   String stockQuantityStr, Map<String, String> errors,
                                   Integer createdBy, String categoryIdStr) {

        // ── Validate từng trường bằng ValidationUtil ──
        String codeError = ValidationUtil.validateMedicineCode(medicineCode);
        if (codeError != null) { errors.put("medicineCode", codeError); }

        String nameError = ValidationUtil.validateMedicineName(name);
        if (nameError != null) { errors.put("name", nameError); }

        String priceError = ValidationUtil.validateMedicinePrice(priceStr);
        if (priceError != null) { errors.put("price", priceError); }

        String stockError = ValidationUtil.validateStockQuantity(stockQuantityStr);
        if (stockError != null) { errors.put("stockQuantity", stockError); }

        String descError = ValidationUtil.validateMedicineDescription(description);
        if (descError != null) { errors.put("description", descError); }

        String dosageError = ValidationUtil.validateDosage(dosage);
        if (dosageError != null) { errors.put("dosage", dosageError); }

        String unitError = ValidationUtil.validateUnit(unit);
        if (unitError != null) { errors.put("unit", unitError); }

        String catError = ValidationUtil.validateCategoryId(categoryIdStr);
        if (catError != null) { errors.put("categoryId", catError); }

        // Nếu có bất kỳ lỗi validate nào → dừng ngay, không cần check trùng
        if (!errors.isEmpty()) {
            return false;
        }

        // ── Check trùng mã thuốc ──
        if (medicineDAO.findByCode(medicineCode.trim()) != null) {
            errors.put("medicineCode", "Mã thuốc \"" + medicineCode.trim() + "\" đã tồn tại trong hệ thống.");
            return false;
        }

        // ── Parse các giá trị đã validated ──
        BigDecimal price = new BigDecimal(priceStr.trim());
        int stockQuantity = 0;
        if (stockQuantityStr != null && !stockQuantityStr.trim().isEmpty()) {
            stockQuantity = Integer.parseInt(stockQuantityStr.trim());
        }

        Medicine med = new Medicine();
        med.setMedicineCode(medicineCode.trim());
        med.setName(name.trim());
        med.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        med.setDosage(dosage != null && !dosage.trim().isEmpty() ? dosage.trim() : null);
        med.setUnit(unit != null && !unit.trim().isEmpty() ? unit.trim() : null);
        med.setPrice(price);
        med.setStockQuantity(stockQuantity);
        med.setActive(true);
        med.setCategoryId(categoryIdStr != null && !categoryIdStr.trim().isEmpty()
                ? Integer.parseInt(categoryIdStr.trim()) : null);

        try {
            int newId = medicineDAO.insert(med);
            priceHistoryDAO.insert(newId, null, price, "Khởi tạo thuốc mới", createdBy);
            // Ghi audit log
            AuditUtil.log(createdBy, "Tạo mới thuốc: " + name.trim(),
                    "medicines", null, "id=" + newId + ", price=" + priceStr.trim(), null);
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

    /** Cập nhật thuốc — validate toàn diện + tự động ghi lịch sử nếu giá thay đổi */
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

        // ── Validate từng trường ──
        String codeError = ValidationUtil.validateMedicineCode(medicineCode);
        if (codeError != null) { errors.put("medicineCode", codeError); }

        String nameError = ValidationUtil.validateMedicineName(name);
        if (nameError != null) { errors.put("name", nameError); }

        String priceError = ValidationUtil.validateMedicinePrice(priceStr);
        if (priceError != null) { errors.put("price", priceError); }

        String stockError = ValidationUtil.validateStockQuantity(stockQuantityStr);
        if (stockError != null) { errors.put("stockQuantity", stockError); }

        String descError = ValidationUtil.validateMedicineDescription(description);
        if (descError != null) { errors.put("description", descError); }

        String dosageError = ValidationUtil.validateDosage(dosage);
        if (dosageError != null) { errors.put("dosage", dosageError); }

        String unitError = ValidationUtil.validateUnit(unit);
        if (unitError != null) { errors.put("unit", unitError); }

        String catError = ValidationUtil.validateCategoryId(categoryIdStr);
        if (catError != null) { errors.put("categoryId", catError); }

        if (!errors.isEmpty()) {
            return false;
        }

        // ── Check trùng mã thuốc (ngoại trừ chính nó) ──
        Medicine existing = medicineDAO.findByCode(medicineCode.trim());
        if (existing != null && existing.getId() != id) {
            errors.put("medicineCode", "Mã thuốc \"" + medicineCode.trim() + "\" đã được sử dụng bởi thuốc khác.");
            return false;
        }

        BigDecimal oldPrice = med.getPrice();
        BigDecimal price = new BigDecimal(priceStr.trim());
        int stockQuantity = 0;
        if (stockQuantityStr != null && !stockQuantityStr.trim().isEmpty()) {
            stockQuantity = Integer.parseInt(stockQuantityStr.trim());
        }

        med.setMedicineCode(medicineCode.trim());
        med.setName(name.trim());
        med.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
        med.setDosage(dosage != null && !dosage.trim().isEmpty() ? dosage.trim() : null);
        med.setUnit(unit != null && !unit.trim().isEmpty() ? unit.trim() : null);
        med.setPrice(price);
        med.setStockQuantity(stockQuantity);
        med.setActive(isActive);
        med.setCategoryId(categoryIdStr != null && !categoryIdStr.trim().isEmpty()
                ? Integer.parseInt(categoryIdStr.trim()) : null);

        boolean updated = medicineDAO.update(med);
        if (updated && oldPrice != null && oldPrice.compareTo(price) != 0) {
            String reason = (changeReason != null && !changeReason.trim().isEmpty())
                    ? changeReason.trim()
                    : "Cập nhật giá thuốc";
            priceHistoryDAO.insert(id, oldPrice, price, reason, changedBy);
        }
        if (updated) {
            // Ghi audit log
            AuditUtil.log(changedBy, "Cập nhật thuốc: " + name.trim(),
                    "medicines", "price=" + (oldPrice != null ? oldPrice.toString() : "—"),
                    "price=" + priceStr + ", active=" + isActive, null);
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
    public boolean toggleMedicineStatus(int id, Integer changedBy) {
        Medicine med = medicineDAO.findById(id);
        if (med == null) return false;
        boolean result;
        String action;
        if (med.isActive()) {
            result = medicineDAO.deactivate(id);
            action = "Vô hiệu hóa thuốc: " + med.getName();
        } else {
            result = medicineDAO.activate(id);
            action = "Kích hoạt thuốc: " + med.getName();
        }
        if (result) {
            AuditUtil.log(changedBy, action, "medicines",
                    "active=" + med.isActive(), "active=" + !med.isActive(), null);
        }
        return result;
    }

    /** @deprecated dùng toggleMedicineStatus(id, changedBy) để có audit log */
    @Deprecated
    public boolean toggleMedicineStatus(int id) {
        return toggleMedicineStatus(id, null);
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
