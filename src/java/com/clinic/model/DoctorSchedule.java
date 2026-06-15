package com.clinic.model;

import com.clinic.model.enums.ScheduleStatus;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Model đại diện cho bảng doctor_schedules — lịch trực của bác sĩ.
 *
 * <p>Trạng thái nghiệp vụ:
 * <ul>
 *   <li>PENDING   — Chờ Admin/Manager duyệt</li>
 *   <li>APPROVED  — Đã duyệt, đưa vào lịch làm việc chính thức</li>
 *   <li>REJECTED  — Bị từ chối, kèm rejection_reason</li>
 *   <li>CANCELLED  — Đã bị hủy bỏ</li>
 * </ul>
 */
public class DoctorSchedule implements Serializable {

    private int id;
    private int doctorId;
    private Date workDate;
    private Time startTime;
    private Time endTime;
    private int maxSlots;
    private ScheduleStatus status;
    private String rejectionReason;
    private Integer approvedBy;
    private Timestamp approvedAt;
    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isApproved; // tương thích ngược với schema cũ (BIT)
    private String notes;

    // ── Transient fields (join từ bảng khác, dùng để hiển thị) ──
    private String doctorName;
    private String doctorSpecialization;
    private String approvedByName;
    private String createdByName;
    private String shiftLabel;

    public DoctorSchedule() {
        this.status = ScheduleStatus.PENDING;
    }

    // ── Convenience methods ──

    /**
     * @return true nếu lịch trực đang ở trạng thái PENDING (có thể duyệt/từ chối).
     */
    public boolean isPending() {
        return status == ScheduleStatus.PENDING;
    }

    /**
     * @return true nếu lịch trực đã được duyệt.
     */
    public boolean isApprovedSchedule() {
        return status == ScheduleStatus.APPROVED;
    }

    /**
     * @return label của ca trực (ví dụ: "Ca sáng", "Ca chiều", "Ca tối").
     */
    public String getShiftLabel() {
        if (shiftLabel != null) return shiftLabel;
        if (startTime == null || endTime == null) return "";
        return buildShiftLabel(startTime.toString(), endTime.toString());
    }

    /**
     * Tính label ca trực từ start_time và end_time.
     */
    public static String buildShiftLabel(String startTimeStr, String endTimeStr) {
        if (startTimeStr == null || endTimeStr == null) return "";
        String start = startTimeStr.substring(0, 5); // HH:mm
        String end = endTimeStr.substring(0, 5);
        return start + " - " + end;
    }

    // ── Getters & Setters ──

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public int getMaxSlots() {
        return maxSlots;
    }

    public void setMaxSlots(int maxSlots) {
        this.maxSlots = maxSlots;
    }

    public ScheduleStatus getStatus() {
        return status;
    }

    public void setStatus(ScheduleStatus status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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

    public boolean isApproved() {
        return isApproved;
    }

    public void setApproved(boolean approved) {
        isApproved = approved;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getDoctorSpecialization() {
        return doctorSpecialization;
    }

    public void setDoctorSpecialization(String doctorSpecialization) {
        this.doctorSpecialization = doctorSpecialization;
    }

    public String getApprovedByName() {
        return approvedByName;
    }

    public void setApprovedByName(String approvedByName) {
        this.approvedByName = approvedByName;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public void setShiftLabel(String shiftLabel) {
        this.shiftLabel = shiftLabel;
    }

    @Override
    public String toString() {
        return "DoctorSchedule{id=" + id + ", doctorId=" + doctorId
                + ", workDate=" + workDate + ", shift=" + getShiftLabel()
                + ", status=" + status + "}";
    }
}
