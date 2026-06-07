package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng services — biểu giá dịch vụ y tế.
 */
public class Service implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String serviceCode;
    private String serviceName;
    private String description;
    private BigDecimal price;
    private int durationMins;
    private boolean requiresFasting;
    private boolean requiresFullBladder;
    private String requiredRoomType;
    private String allowedSpecialties;
    private Integer categoryId;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient — không map từ DB, dùng cho hiển thị
    private String categoryName;

    public Service() {
    }

    // Getters và Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getServiceCode() {
        return serviceCode;
    }

    public void setServiceCode(String serviceCode) {
        this.serviceCode = serviceCode;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getDurationMins() {
        return durationMins;
    }

    public void setDurationMins(int durationMins) {
        this.durationMins = durationMins;
    }

    public boolean isRequiresFasting() {
        return requiresFasting;
    }

    public void setRequiresFasting(boolean requiresFasting) {
        this.requiresFasting = requiresFasting;
    }

    public boolean isRequiresFullBladder() {
        return requiresFullBladder;
    }

    public void setRequiresFullBladder(boolean requiresFullBladder) {
        this.requiresFullBladder = requiresFullBladder;
    }

    public String getRequiredRoomType() {
        return requiredRoomType;
    }

    public void setRequiredRoomType(String requiredRoomType) {
        this.requiredRoomType = requiredRoomType;
    }

    public String getAllowedSpecialties() {
        return allowedSpecialties;
    }

    public void setAllowedSpecialties(String allowedSpecialties) {
        this.allowedSpecialties = allowedSpecialties;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
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

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    @Override
    public String toString() {
        return "Service{" +
                "id=" + id +
                ", serviceCode='" + serviceCode + '\'' +
                ", serviceName='" + serviceName + '\'' +
                ", price=" + price +
                ", isActive=" + isActive +
                '}';
    }
}
