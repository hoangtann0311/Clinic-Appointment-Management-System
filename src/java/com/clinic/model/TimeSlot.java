package com.clinic.model;

import com.clinic.model.enums.SlotStatus;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Model đại diện cho bảng time_slots — khung giờ khám bệnh 20 phút.
 *
 * <p>Mỗi slot được tự động sinh từ lịch trực bác sĩ sau khi Admin/Manager duyệt (APPROVED).
 * Slot là đơn vị nhỏ nhất để bệnh nhân đặt lịch khám.
 *
 * <p>Trạng thái nghiệp vụ:
 * <ul>
 *   <li>AVAILABLE  — Còn trống, cho phép đặt lịch</li>
 *   <li>BOOKED     — Đã được đặt (sẽ dùng ở Phase 9 — Appointment)</li>
 *   <li>COMPLETED  — Đã hoàn thành khám</li>
 *   <li>CANCELLED  — Đã hủy (bởi bệnh nhân hoặc hệ thống)</li>
 * </ul>
 *
 * <p>Concurrency: Cột [version] (ROWVERSION) dùng cho optimistic locking.
 * Khi book/cancel slot, version được kiểm tra để tránh race condition.
 * Cột [booked_by] lưu patient_id, [booked_at] lưu thời điểm đặt.
 */
public class TimeSlot implements Serializable {

    private int id;
    private int scheduleId;
    private int doctorId;
    private Date workDate;
    private Time startTime;
    private Time endTime;
    private SlotStatus status;
    private String notes;
    private Integer bookedBy;      // patient_id (users.id), null nếu AVAILABLE
    private Timestamp bookedAt;    // thời điểm bệnh nhân đặt slot
    private byte[] version;        // ROWVERSION — optimistic lock
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // ── Transient fields (join từ bảng khác, dùng để hiển thị) ──
    private String doctorName;
    private String shiftLabel;
    private String bookedByName;   // tên bệnh nhân đã đặt (join users)

    public TimeSlot() {
        this.status = SlotStatus.AVAILABLE;
    }

    // ── Convenience methods ──

    /**
     * @return true nếu slot còn trống, có thể đặt lịch.
     */
    public boolean isAvailable() {
        return status == SlotStatus.AVAILABLE;
    }

    /**
     * @return true nếu slot đã được đặt.
     */
    public boolean isBooked() {
        return status == SlotStatus.BOOKED;
    }

    /**
     * @return label hiển thị giờ (VD: "07:00 - 07:20").
     */
    public String getTimeLabel() {
        if (startTime == null || endTime == null) return "";
        String start = startTime.toString().substring(0, 5);
        String end = endTime.toString().substring(0, 5);
        return start + " - " + end;
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public Date getWorkDate() {
        return workDate;
    }

    public void setWorkDate(Date workDate) {
        this.workDate = workDate;
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

    public SlotStatus getStatus() {
        return status;
    }

    public void setStatus(SlotStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getShiftLabel() {
        return shiftLabel;
    }

    public void setShiftLabel(String shiftLabel) {
        this.shiftLabel = shiftLabel;
    }

    public Integer getBookedBy() {
        return bookedBy;
    }

    public void setBookedBy(Integer bookedBy) {
        this.bookedBy = bookedBy;
    }

    public Timestamp getBookedAt() {
        return bookedAt;
    }

    public void setBookedAt(Timestamp bookedAt) {
        this.bookedAt = bookedAt;
    }

    public byte[] getVersion() {
        return version;
    }

    public void setVersion(byte[] version) {
        this.version = version;
    }

    public String getBookedByName() {
        return bookedByName;
    }

    public void setBookedByName(String bookedByName) {
        this.bookedByName = bookedByName;
    }

    @Override
    public String toString() {
        return "TimeSlot{id=" + id + ", scheduleId=" + scheduleId
                + ", doctorId=" + doctorId + ", workDate=" + workDate
                + ", time=" + getTimeLabel() + ", status=" + status + "}";
    }
}
