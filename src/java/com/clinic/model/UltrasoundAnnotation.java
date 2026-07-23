package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class UltrasoundAnnotation implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private int testOrderId;
    private int ultrasoundImageId;
    private String annotationSource;
    private String annotationType;
    private String annotationData;
    private int imageWidth;
    private int imageHeight;
    private String reviewStatus;
    private String rejectionReason;
    private int version;
    private boolean current;
    private int createdBy;
    private Timestamp createdAt;
    private Integer reviewedBy;
    private Timestamp reviewedAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public int getTestOrderId() { return testOrderId; }
    public void setTestOrderId(int testOrderId) { this.testOrderId = testOrderId; }
    public int getUltrasoundImageId() { return ultrasoundImageId; }
    public void setUltrasoundImageId(int ultrasoundImageId) { this.ultrasoundImageId = ultrasoundImageId; }
    public String getAnnotationSource() { return annotationSource; }
    public void setAnnotationSource(String annotationSource) { this.annotationSource = annotationSource; }
    public String getAnnotationType() { return annotationType; }
    public void setAnnotationType(String annotationType) { this.annotationType = annotationType; }
    public String getAnnotationData() { return annotationData; }
    public void setAnnotationData(String annotationData) { this.annotationData = annotationData; }
    public int getImageWidth() { return imageWidth; }
    public void setImageWidth(int imageWidth) { this.imageWidth = imageWidth; }
    public int getImageHeight() { return imageHeight; }
    public void setImageHeight(int imageHeight) { this.imageHeight = imageHeight; }
    public String getReviewStatus() { return reviewStatus; }
    public void setReviewStatus(String reviewStatus) { this.reviewStatus = reviewStatus; }
    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }
    public int getVersion() { return version; }
    public void setVersion(int version) { this.version = version; }
    public boolean isCurrent() { return current; }
    public void setCurrent(boolean current) { this.current = current; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(Integer reviewedBy) { this.reviewedBy = reviewedBy; }
    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }
}
