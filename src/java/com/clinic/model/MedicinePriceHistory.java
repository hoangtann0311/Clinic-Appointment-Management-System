package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng medicine_price_history — lịch sử điều chỉnh giá thuốc.
 * Lưu lại mỗi khi Manager thay đổi giá: giá cũ, giá mới, người thực hiện.
 */
public class MedicinePriceHistory implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int medicineId;
    private BigDecimal oldPrice;
    private BigDecimal newPrice;
    private String changeReason;
    private Integer changedBy;
    private Timestamp createdAt;

    // Transient — hiển thị
    private String medicineName;
    private String medicineCode;
    private String changedByName;

    public MedicinePriceHistory() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMedicineId() { return medicineId; }
    public void setMedicineId(int medicineId) { this.medicineId = medicineId; }

    public BigDecimal getOldPrice() { return oldPrice; }
    public void setOldPrice(BigDecimal oldPrice) { this.oldPrice = oldPrice; }

    public BigDecimal getNewPrice() { return newPrice; }
    public void setNewPrice(BigDecimal newPrice) { this.newPrice = newPrice; }

    public String getChangeReason() { return changeReason; }
    public void setChangeReason(String changeReason) { this.changeReason = changeReason; }

    public Integer getChangedBy() { return changedBy; }
    public void setChangedBy(Integer changedBy) { this.changedBy = changedBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getMedicineName() { return medicineName; }
    public void setMedicineName(String medicineName) { this.medicineName = medicineName; }

    public String getMedicineCode() { return medicineCode; }
    public void setMedicineCode(String medicineCode) { this.medicineCode = medicineCode; }

    public String getChangedByName() { return changedByName; }
    public void setChangedByName(String changedByName) { this.changedByName = changedByName; }
}
