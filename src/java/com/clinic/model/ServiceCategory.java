package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng service_categories — nhóm dịch vụ y tế.
 * Dùng cho phòng khám sản phụ khoa:
 *   Khám sản, Siêu âm, Tư vấn, Thủ thuật
 */
public class ServiceCategory implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String categoryName;
    private String description;
    private String icon;          // Bootstrap Icons class
    private int sortOrder;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient — thống kê
    private int serviceCount;
    private long totalUsage;

    public ServiceCategory() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getServiceCount() {
        return serviceCount;
    }

    public void setServiceCount(int serviceCount) {
        this.serviceCount = serviceCount;
    }

    public long getTotalUsage() {
        return totalUsage;
    }

    public void setTotalUsage(long totalUsage) {
        this.totalUsage = totalUsage;
    }
}
