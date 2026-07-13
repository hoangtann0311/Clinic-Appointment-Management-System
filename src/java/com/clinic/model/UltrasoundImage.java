package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class mapping table ultrasound_images.
 */
public class UltrasoundImage implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int testOrderId;
    private String originalFilename;
    private String storedFilename;
    private String filePath;
    private long fileSize;
    private String contentType;
    private int uploadedBy;
    private Timestamp uploadedAt;

    // Transient
    private String uploaderName;

    public UltrasoundImage() {
    }

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

    public int getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(int uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    public String getUploaderName() {
        return uploaderName;
    }

    public void setUploaderName(String uploaderName) {
        this.uploaderName = uploaderName;
    }
}
