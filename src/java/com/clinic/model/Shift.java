package com.clinic.model;

import java.io.Serializable;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Model đại diện cho bảng shifts — ca làm việc được định nghĩa trước.
 *
 * <p>Manager có thể CRUD các ca làm việc (vd: Ca sáng 07:00-11:00).
 * Bác sĩ sẽ chọn ca có sẵn thay vì nhập giờ tự do, đảm bảo dữ liệu nhất quán.
 */
public class Shift implements Serializable {

    private int id;
    private String name;
    private Time startTime;
    private Time endTime;
    private String description;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Shift() {
        this.active = true;
    }

    // ── Convenience methods ──

    /**
     * @return label hiển thị của ca (vd: "Ca sáng (07:00 - 11:00)").
     */
    public String getShiftLabel() {
        if (name == null) return "";
        if (startTime == null || endTime == null) return name;
        return name + " (" + formatTime(startTime) + " - " + formatTime(endTime) + ")";
    }

    /**
     * @return true nếu ca đang hoạt động.
     */
    public boolean isActive() {
        return active;
    }

    private String formatTime(Time time) {
        if (time == null) return "";
        return time.toString().substring(0, 5); // HH:mm
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = (name != null) ? name.trim() : null;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = (description != null) ? description.trim() : null;
    }

    public boolean getActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Shift{id=" + id + ", name='" + name + "', time=" + getShiftLabel() + "}";
    }
}
