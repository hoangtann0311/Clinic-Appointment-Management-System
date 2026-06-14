package com.clinic.model;

import java.io.Serializable;

/**
 * Model đại diện cho bảng doctors — thông tin bác sĩ.
 */
public class Doctor implements Serializable {

    private int id;
    private int userId;
    private String fullName;
    private String specialization;
    private String phoneNumber;

    // ── Transient fields (join từ bảng users) ──
    private String email;
    private String username;

    public Doctor() {
    }

    public Doctor(int id, int userId, String fullName, String specialization, String phoneNumber) {
        this.id = id;
        this.userId = userId;
        this.fullName = fullName;
        this.specialization = specialization;
        this.phoneNumber = phoneNumber;
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public String toString() {
        return "Doctor{id=" + id + ", fullName='" + fullName + "', specialization='" + specialization + "'}";
    }
}
