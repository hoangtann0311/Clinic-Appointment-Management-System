package com.clinic.model;

import java.util.Date;

public class PatientMedicalSummary {
    private int patientId;
    private String patientName;
    private String patientPhone;
    private String patientDob; // format YYYY-MM-DD
    private int totalVisits;
    private Date lastVisitDate;
    private String lastDiagnosis;
    private boolean hasRisk;

    // Getters and Setters
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientPhone() { return patientPhone; }
    public void setPatientPhone(String patientPhone) { this.patientPhone = patientPhone; }

    public String getPatientDob() { return patientDob; }
    public void setPatientDob(String patientDob) { this.patientDob = patientDob; }

    public int getTotalVisits() { return totalVisits; }
    public void setTotalVisits(int totalVisits) { this.totalVisits = totalVisits; }

    public Date getLastVisitDate() { return lastVisitDate; }
    public void setLastVisitDate(Date lastVisitDate) { this.lastVisitDate = lastVisitDate; }

    public String getLastDiagnosis() { return lastDiagnosis; }
    public void setLastDiagnosis(String lastDiagnosis) { this.lastDiagnosis = lastDiagnosis; }

    public boolean isHasRisk() { return hasRisk; }
    public void setHasRisk(boolean hasRisk) { this.hasRisk = hasRisk; }
}
