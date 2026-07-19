package com.clinic.model;

/**
 * Model ánh xạ bảng [prescription_items].
 * Một dòng thuốc trong đơn: loại thuốc, số lượng, liều dùng.
 */
public class PrescriptionItem {

    private int id;
    private int prescriptionId;
    private int medicineId;
    private int quantity;
    private String dosage;        // Liều dùng: VD "2 viên/ngày, sáng-tối"

    // Trường trung gian từ JOIN medicines
    private String medicineName;
    private String medicineUnit;     // đơn vị tính (viên, gói, ml…)
    private String medicineCategory; // nhóm thuốc (từ medicine_categories)
    private java.math.BigDecimal price; // đơn giá từ medicines

    public PrescriptionItem() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(int prescriptionId) { this.prescriptionId = prescriptionId; }

    public int getMedicineId() { return medicineId; }
    public void setMedicineId(int medicineId) { this.medicineId = medicineId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getDosage() { return dosage; }
    public void setDosage(String dosage) { this.dosage = dosage; }

    public String getMedicineName() { return medicineName; }
    public void setMedicineName(String medicineName) { this.medicineName = medicineName; }

    public String getMedicineUnit() { return medicineUnit; }
    public void setMedicineUnit(String medicineUnit) { this.medicineUnit = medicineUnit; }

    public String getMedicineCategory() { return medicineCategory; }
    public void setMedicineCategory(String medicineCategory) { this.medicineCategory = medicineCategory; }

    public java.math.BigDecimal getPrice() { return price; }
    public void setPrice(java.math.BigDecimal price) { this.price = price; }
}