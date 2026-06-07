package com.clinic.service;

import com.clinic.dao.MedicineDAO;
import com.clinic.model.Medicine;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ quản lý biểu giá thuốc.
 */
public class MedicineService {

    private final MedicineDAO medicineDAO;

    public MedicineService() {
        this.medicineDAO = new MedicineDAO();
    }

    /** Lấy danh sách thuốc có phân trang + filter */
    public List<Medicine> getMedicines(int page, int pageSize,
                                        String search, Boolean activeFilter) {
        int offset = (page - 1) * pageSize;
        try {
            return medicineDAO.findAll(offset, pageSize, search, activeFilter);
        } catch (Exception e) {
            System.err.println("[MedicineService] getMedicines ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số thuốc (để tính số trang) */
    public int getTotalMedicines(String search, Boolean activeFilter) {
        try {
            return medicineDAO.countAll(search, activeFilter);
        } catch (Exception e) {
            System.err.println("[MedicineService] getTotalMedicines ERROR: " + e.getMessage());
            return 0;
        }
    }

    /** Lấy thuốc theo id */
    public Medicine getMedicineById(int id) {
        return medicineDAO.findById(id);
    }

    /** Tạo thuốc mới */
    public boolean createMedicine(String medicineCode, String name, String description,
                                   String dosage, String unit, String priceStr,
                                   String stockQuantityStr, Map<String, String> errors) {
        // Validate
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
            if (price.compareTo(BigDecimal.ZERO) < 0) {
                errors.put("price", "Giá bán không được âm.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Giá bán không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã
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
            medicineDAO.insert(med);
            return true;
        } catch (Exception e) {
            errors.put("general", "Lỗi khi tạo thuốc: " + e.getMessage());
            return false;
        }
    }

    /** Cập nhật thuốc */
    public boolean updateMedicine(int id, String medicineCode, String name,
                                   String description, String dosage, String unit,
                                   String priceStr, String stockQuantityStr,
                                   boolean isActive, Map<String, String> errors) {
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
            if (price.compareTo(BigDecimal.ZERO) < 0) {
                errors.put("price", "Giá bán không được âm.");
                return false;
            }
        } catch (NumberFormatException e) {
            errors.put("price", "Giá bán không hợp lệ.");
            return false;
        }
        // Kiểm tra trùng mã (ngoại trừ chính nó)
        Medicine existing = medicineDAO.findByCode(medicineCode.trim());
        if (existing != null && existing.getId() != id) {
            errors.put("medicineCode", "Mã thuốc đã được sử dụng bởi thuốc khác.");
            return false;
        }

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

        return medicineDAO.update(med);
    }

    /** Vô hiệu hóa thuốc (soft delete) */
    public boolean deactivateMedicine(int id) {
        return medicineDAO.deactivate(id);
    }

    /** Lấy tất cả thuốc đang hoạt động (dùng cho dropdown) */
    public List<Medicine> getActiveMedicines() {
        return medicineDAO.findAllActive();
    }
}
