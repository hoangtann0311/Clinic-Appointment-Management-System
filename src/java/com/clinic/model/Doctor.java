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

    // Transient fields (join từ bảng users hoặc map cứng)
    private String email;
    private String username;
    
    // Additional fields from receptionist/manual booking features
    private String degree;
    private int experienceYears;
    private double price;
    private String avatar;      // legacy alias
    private String avatarUrl;   // cột thật trong DB
    private String bio;

    public Doctor() {
    }

    public Doctor(int id, int userId, String fullName, String specialization, String phoneNumber) {
        this.id = id;
        this.userId = userId;
        this.fullName = fullName;
        this.specialization = specialization;
        this.phoneNumber = phoneNumber;
    }

    public Doctor(int id, String name, String specialization, String degree, int experienceYears, double price, String avatar) {
        this.id = id;
        this.fullName = name;
        this.specialization = specialization;
        this.degree = degree;
        this.experienceYears = experienceYears;
        this.price = price;
        this.avatar = avatar;
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

    // Alias for compatibility
    public String getName() {
        return fullName;
    }

    public void setName(String name) {
        this.fullName = name;
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

    public String getDegree() {
        return degree;
    }

    public void setDegree(String degree) {
        this.degree = degree;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getAvatar() { return avatarUrl != null ? avatarUrl : avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    @Override
    public String toString() {
        return "Doctor{id=" + id + ", fullName='" + fullName + "', specialization='" + specialization + "'}";
    }
}