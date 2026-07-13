package com.clinic.model;

import java.time.LocalDateTime;

/**
 * Ánh xạ bảng lab_results — kết quả xét nghiệm do KTV nhập.
 *
 * lab_results: id, test_order_id, service_id, result_details, image_url,
 *              lab_technician_id, updated_at
 */
public class LabResult {

    private int id;
    private int testOrderId;
    private int serviceId;
    private String resultDetails;  // NVARCHAR(MAX): mô tả kết quả dạng text
    private String imageUrl;
    private Integer labTechnicianId;
    private LocalDateTime updatedAt;

    // Trường tiện ích từ JOIN
    private String labTechnicianName;
    private String serviceName;

    public LabResult() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTestOrderId() { return testOrderId; }
    public void setTestOrderId(int testOrderId) { this.testOrderId = testOrderId; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public String getResultDetails() { return resultDetails; }
    public void setResultDetails(String resultDetails) { this.resultDetails = resultDetails; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Integer getLabTechnicianId() { return labTechnicianId; }
    public void setLabTechnicianId(Integer labTechnicianId) { this.labTechnicianId = labTechnicianId; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getLabTechnicianName() { return labTechnicianName; }
    public void setLabTechnicianName(String labTechnicianName) { this.labTechnicianName = labTechnicianName; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
}