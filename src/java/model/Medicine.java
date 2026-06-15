package com.clinic.model;

import java.math.BigDecimal;

/**
 * Model ánh xạ bảng [medicines].
 */
public class Medicine {

    private int        id;
    private String     name;
    private BigDecimal price;
    private String     description;   // mô tả thuốc (ALTER TABLE vừa thêm)
    private String     category;      // nhóm thuốc  (ALTER TABLE vừa thêm)

    public Medicine() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}