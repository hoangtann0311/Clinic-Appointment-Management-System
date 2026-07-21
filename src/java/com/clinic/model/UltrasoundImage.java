package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng ultrasound_images — ảnh siêu âm.
 * Lưu metadata của mỗi ảnh siêu âm được upload lên hệ thống.
 * Liên kết với test_order → medical_record → appointment → patient.
 */
public class UltrasoundImage implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int testOrderId;            // FK → test_orders.id
    private String originalFilename;    // tên gốc của file
    private String storedFilename;      // tên file sau khi lưu (UUID)
    private String filePath;            // đường dẫn tương đối đến file
    private long fileSize;              // kích thước file (bytes)
    private String contentType;         // MIME type (image/jpeg, image/png...)
    private Integer uploadedBy;         // FK → users.id (người upload)
    private Timestamp uploadedAt;       // thời điểm upload

    // ── Transient fields (không map từ DB, dùng để truyền dữ liệu) ──
    private String uploaderName;        // tên người upload (JOIN từ users)
    private String uploaderRole;        // vai trò người upload (JOIN từ roles)

    public UltrasoundImage() {
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTestOrderId() {
        return testOrderId;
    }

    public void setTestOrderId(int testOrderId) {
        this.testOrderId = testOrderId;
    }

    public String getOriginalFilename() {
        return originalFilename;
    }

    public void setOriginalFilename(String originalFilename) {
        this.originalFilename = originalFilename;
    }

    public String getStoredFilename() {
        return storedFilename;
    }

    public void setStoredFilename(String storedFilename) {
        this.storedFilename = storedFilename;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public Integer getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(Integer uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    // ── Transient getters/setters ──

    public String getUploaderName() {
        return uploaderName;
    }

    public void setUploaderName(String uploaderName) {
        this.uploaderName = uploaderName;
    }

    public String getUploaderRole() {
        return uploaderRole;
    }

    public void setUploaderRole(String uploaderRole) {
        this.uploaderRole = uploaderRole;
    }

    @Override
    public String toString() {
        return "UltrasoundImage{" +
                "id=" + id +
                ", testOrderId=" + testOrderId +
                ", originalFilename='" + originalFilename + '\'' +
                ", storedFilename='" + storedFilename + '\'' +
                ", fileSize=" + fileSize +
                ", contentType='" + contentType + '\'' +
                '}';
    }
}
