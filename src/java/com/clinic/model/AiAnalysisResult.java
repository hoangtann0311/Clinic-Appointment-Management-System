package com.clinic.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model class mapping table ai_analysis_results.
 */
public class AiAnalysisResult implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int testOrderId;
    private String status;
    private boolean detected;
    private BigDecimal confidence;
    private String message;
    private String inputImage;
    private String resultImage;
    private String maskImage;
    private String rawMaskImage;
    private Integer xmin;
    private Integer ymin;
    private Integer xmax;
    private Integer ymax;
    private Timestamp analyzedAt;
    private String errorMessage;

    public AiAnalysisResult() {
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isDetected() {
        return detected;
    }

    public void setDetected(boolean detected) {
        this.detected = detected;
    }

    public BigDecimal getConfidence() {
        return confidence;
    }

    public void setConfidence(BigDecimal confidence) {
        this.confidence = confidence;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getInputImage() {
        return inputImage;
    }

    public void setInputImage(String inputImage) {
        this.inputImage = inputImage;
    }

    public String getResultImage() {
        return resultImage;
    }

    public void setResultImage(String resultImage) {
        this.resultImage = resultImage;
    }

    public String getMaskImage() {
        return maskImage;
    }

    public void setMaskImage(String maskImage) {
        this.maskImage = maskImage;
    }

    public String getRawMaskImage() {
        return rawMaskImage;
    }

    public void setRawMaskImage(String rawMaskImage) {
        this.rawMaskImage = rawMaskImage;
    }

    public Integer getXmin() {
        return xmin;
    }

    public void setXmin(Integer xmin) {
        this.xmin = xmin;
    }

    public Integer getYmin() {
        return ymin;
    }

    public void setYmin(Integer ymin) {
        this.ymin = ymin;
    }

    public Integer getXmax() {
        return xmax;
    }

    public void setXmax(Integer xmax) {
        this.xmax = xmax;
    }

    public Integer getymax() {
        return ymax;
    }

    public void setymax(Integer ymax) {
        this.ymax = ymax;
    }

    public Timestamp getAnalyzedAt() {
        return analyzedAt;
    }

    public void setAnalyzedAt(Timestamp analyzedAt) {
        this.analyzedAt = analyzedAt;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
}
