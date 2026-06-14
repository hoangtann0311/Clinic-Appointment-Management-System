package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng medicine_categories — nhóm thuốc.
 */
public class MedicineCategory implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String categoryName;
    private String description;
    private String icon;
    private int sortOrder;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient
    private int medicineCount;

    public MedicineCategory() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public int getMedicineCount() { return medicineCount; }
    public void setMedicineCount(int medicineCount) { this.medicineCount = medicineCount; }
}
