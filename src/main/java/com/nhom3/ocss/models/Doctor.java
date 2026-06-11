package com.nhom3.ocss.models;

public class Doctor {
    private int id;
    private String name;
    private String specialization;
    private String degree;
    private int experienceYears;
    private double price;
    private String avatar;

    public Doctor(int id, String name, String specialization, String degree, int experienceYears, double price, String avatar) {
        this.id = id;
        this.name = name;
        this.specialization = specialization;
        this.degree = degree;
        this.experienceYears = experienceYears;
        this.price = price;
        this.avatar = avatar;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    public String getDegree() { return degree; }
    public void setDegree(String degree) { this.degree = degree; }
    public int getExperienceYears() { return experienceYears; }
    public void setExperienceYears(int experienceYears) { this.experienceYears = experienceYears; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
}
