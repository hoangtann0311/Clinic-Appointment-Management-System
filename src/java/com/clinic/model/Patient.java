package com.clinic.model;

import java.time.LocalDate;

public class Patient {
    private int id;
    private String fullName;
    private String phone;
    private LocalDate dateOfBirth;
    private String address;
    private String cccd;

    public Patient() {}

    public Patient(int id, String fullName, String phone, LocalDate dateOfBirth) {
        this.id = id;
        this.fullName = fullName;
        this.phone = phone;
        this.dateOfBirth = dateOfBirth;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFullName() { return fullName != null ? fullName : ""; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getCccd() { return cccd; }
    public void setCccd(String cccd) { this.cccd = cccd; }
}
