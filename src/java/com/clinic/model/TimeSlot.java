package com.clinic.model;

import com.clinic.model.enums.SlotStatus;

import java.math.BigDecimal;
import java.sql.Time;
import java.time.LocalDateTime;

/**
 * Model biểu diễn một khung giờ khám bệnh (20 phút).
 *
 * <p>Khung giờ được sinh tự động từ {@code doctor_schedules}
 * khi Admin/Manager duyệt lịch trực. Mỗi khung giờ cách nhau 20 phút,
 * trải dài từ start_time đến end_time của ca làm việc.
 */
public class TimeSlot {

    private int id;
    private int scheduleId;
    private Time startTime;
    private Time endTime;
    private String timeLabel;
    private SlotStatus status;
    private BigDecimal price;
    private String bookedByName;
    private LocalDateTime createdAt;

    public TimeSlot() {}

    public TimeSlot(int id, int scheduleId, Time startTime, Time endTime,
                    SlotStatus status, BigDecimal price,
                    String bookedByName, LocalDateTime createdAt) {
        this.id = id;
        this.scheduleId = scheduleId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.timeLabel = startTime.toString().substring(0, 5)
                + " - " + endTime.toString().substring(0, 5);
        this.status = status;
        this.price = price;
        this.bookedByName = bookedByName;
        this.createdAt = createdAt;
    }

    // ── Getters & Setters ──

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) {
        this.startTime = startTime;
        updateTimeLabel();
    }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) {
        this.endTime = endTime;
        updateTimeLabel();
    }

    public String getTimeLabel() { return timeLabel; }
    public void setTimeLabel(String timeLabel) { this.timeLabel = timeLabel; }

    public SlotStatus getStatus() { return status; }
    public void setStatus(SlotStatus status) { this.status = status; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getBookedByName() { return bookedByName; }
    public void setBookedByName(String bookedByName) { this.bookedByName = bookedByName; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    private void updateTimeLabel() {
        if (startTime != null && endTime != null) {
            this.timeLabel = startTime.toString().substring(0, 5)
                    + " - " + endTime.toString().substring(0, 5);
        }
    }
}
