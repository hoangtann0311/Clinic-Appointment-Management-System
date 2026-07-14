package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity class ánh xạ bảng ultrasound_results — kết quả siêu âm.
 * Lưu thông tin ảnh siêu âm và kết quả do KTV Siêu Âm upload.
 */
public class UltrasoundResult implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Integer medicalRecordId;      // FK → medical_records.id
    private Integer sonographerId;        // FK → sonographers.id
    private String rawImageUrl;           // đường dẫn ảnh gốc
    private String aiProcessedImageUrl;   // đường dẫn ảnh AI xử lý (dự phòng)
    private String aiSuggestedLabel;      // nhãn gợi ý từ AI (dự phòng)
    private BigDecimal aiConfidenceScore; // độ tin cậy AI (dự phòng)
    private String findings;              // kết quả/phát hiện (text)
    private String conclusion;            // kết luận
    private Timestamp createdAt;

    public UltrasoundResult() {
    }

    // ── Getters & Setters ──

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getMedicalRecordId() { return medicalRecordId; }
    public void setMedicalRecordId(Integer medicalRecordId) { this.medicalRecordId = medicalRecordId; }

    public Integer getSonographerId() { return sonographerId; }
    public void setSonographerId(Integer sonographerId) { this.sonographerId = sonographerId; }

    public String getRawImageUrl() { return rawImageUrl; }
    public void setRawImageUrl(String rawImageUrl) { this.rawImageUrl = rawImageUrl; }

    public String getAiProcessedImageUrl() { return aiProcessedImageUrl; }
    public void setAiProcessedImageUrl(String aiProcessedImageUrl) { this.aiProcessedImageUrl = aiProcessedImageUrl; }

    public String getAiSuggestedLabel() { return aiSuggestedLabel; }
    public void setAiSuggestedLabel(String aiSuggestedLabel) { this.aiSuggestedLabel = aiSuggestedLabel; }

    public BigDecimal getAiConfidenceScore() { return aiConfidenceScore; }
    public void setAiConfidenceScore(BigDecimal aiConfidenceScore) { this.aiConfidenceScore = aiConfidenceScore; }

    public String getFindings() { return findings; }
    public void setFindings(String findings) { this.findings = findings; }

    public String getConclusion() { return conclusion; }
    public void setConclusion(String conclusion) { this.conclusion = conclusion; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "UltrasoundResult{" +
                "id=" + id +
                ", medicalRecordId=" + medicalRecordId +
                ", rawImageUrl='" + rawImageUrl + '\'' +
                '}';
    }
}
