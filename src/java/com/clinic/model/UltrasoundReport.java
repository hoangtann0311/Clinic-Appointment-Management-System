package com.clinic.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class UltrasoundReport implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private int testOrderId;
    private int version;
    private String imageDescription;
    private String professionalFindings;
    private String conclusion;
    private String reportStatus;
    private boolean current;
    private int createdBy;
    private Timestamp createdAt;
    private Integer signedByUserId;
    private String signedName;
    private Timestamp signedAt;
    private Integer doctorConfirmedBy;
    private Timestamp doctorConfirmedAt;
    private String doctorReviewNotes;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public int getTestOrderId() { return testOrderId; }
    public void setTestOrderId(int testOrderId) { this.testOrderId = testOrderId; }
    public int getVersion() { return version; }
    public void setVersion(int version) { this.version = version; }
    public String getImageDescription() { return imageDescription; }
    public void setImageDescription(String imageDescription) { this.imageDescription = imageDescription; }
    public String getProfessionalFindings() { return professionalFindings; }
    public void setProfessionalFindings(String professionalFindings) { this.professionalFindings = professionalFindings; }
    public String getConclusion() { return conclusion; }
    public void setConclusion(String conclusion) { this.conclusion = conclusion; }
    public String getReportStatus() { return reportStatus; }
    public void setReportStatus(String reportStatus) { this.reportStatus = reportStatus; }
    public boolean isCurrent() { return current; }
    public void setCurrent(boolean current) { this.current = current; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getSignedByUserId() { return signedByUserId; }
    public void setSignedByUserId(Integer signedByUserId) { this.signedByUserId = signedByUserId; }
    public String getSignedName() { return signedName; }
    public void setSignedName(String signedName) { this.signedName = signedName; }
    public Timestamp getSignedAt() { return signedAt; }
    public void setSignedAt(Timestamp signedAt) { this.signedAt = signedAt; }
    public Integer getDoctorConfirmedBy() { return doctorConfirmedBy; }
    public void setDoctorConfirmedBy(Integer doctorConfirmedBy) { this.doctorConfirmedBy = doctorConfirmedBy; }
    public Timestamp getDoctorConfirmedAt() { return doctorConfirmedAt; }
    public void setDoctorConfirmedAt(Timestamp doctorConfirmedAt) { this.doctorConfirmedAt = doctorConfirmedAt; }
    public String getDoctorReviewNotes() { return doctorReviewNotes; }
    public void setDoctorReviewNotes(String doctorReviewNotes) { this.doctorReviewNotes = doctorReviewNotes; }
}
