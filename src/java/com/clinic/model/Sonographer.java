package com.clinic.model;

import java.io.Serializable;

/**
 * Model ánh xạ bảng sonographers — thông tin nghiệp vụ của Bác sĩ siêu âm (role_id = 6).
 *
 * <p><b>Vì sao không dùng lại {@link Doctor}:</b> bác sĩ siêu âm KHÔNG có dòng trong
 * bảng {@code doctors}. Nếu cấp dòng ở đó, họ sẽ lọt vào danh sách bác sĩ khám mà
 * lễ tân dùng để đặt lịch — {@code DoctorDAO.getAllDoctors()} chỉ lọc
 * {@code users.status='Active'}, không lọc {@code role_id}.
 *
 * <p><b>Họ tên và số điện thoại KHÔNG nằm ở đây</b> mà đọc thẳng từ bảng {@code users}
 * ({@code full_name}, {@code phone}). Bảng này chỉ giữ phần chuyên môn.
 *
 * <p>Hai cột {@code room_no} và {@code status} có sẵn trong bảng nhưng NGOÀI phạm vi
 * trang hồ sơ — không đọc, không ghi, không hiển thị.
 */
public class Sonographer implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;

    /** Chứng chỉ siêu âm — cột qualification đã có sẵn trong bảng. */
    private String qualification;

    private String specialization;
    private String degree;
    private int experienceYears;
    private String bio;
    private String avatarUrl;

    public Sonographer() {
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

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = (qualification != null) ? qualification.trim() : null;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
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

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    @Override
    public String toString() {
        return "Sonographer{id=" + id + ", userId=" + userId
             + ", specialization='" + specialization + "'}";
    }
}
