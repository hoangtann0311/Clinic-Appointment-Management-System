package com.nhom3.ocss.models;

import java.time.LocalDate;

public class Patient {
    private int id;
    private String fullName;
    private String phone;
    private LocalDate dateOfBirth;
    private String zaloUserId;

    public Patient(int id, String fullName, String phone, LocalDate dateOfBirth, String zaloUserId) {
        this.id = id;
        this.fullName = fullName;
        this.phone = phone;
        this.dateOfBirth = dateOfBirth;
        this.zaloUserId = zaloUserId;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getZaloUserId() { return zaloUserId; }
    public void setZaloUserId(String zaloUserId) { this.zaloUserId = zaloUserId; }
}
