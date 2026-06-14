package com.clinic.model.enums;

/**
 * Enum biểu diễn trạng thái của lịch trực bác sĩ.
 * <ul>
 *   <li>PENDING   — Chờ duyệt (bác sĩ vừa gửi yêu cầu)</li>
 *   <li>APPROVED  — Đã duyệt (Admin/Manager chấp thuận)</li>
 *   <li>REJECTED  — Đã từ chối (Admin/Manager từ chối, kèm lý do)</li>
 *   <li>CANCELLED  — Đã hủy (bác sĩ hoặc admin hủy lịch trực)</li>
 * </ul>
 */
public enum ScheduleStatus {

    PENDING("Chờ duyệt"),
    APPROVED("Đã duyệt"),
    REJECTED("Đã từ chối"),
    CANCELLED("Đã hủy");

    private final String label;

    ScheduleStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /**
     * Parse từ chuỗi (không phân biệt hoa thường).
     */
    public static ScheduleStatus fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return PENDING;
        }
        for (ScheduleStatus s : values()) {
            if (s.name().equalsIgnoreCase(value.trim())) {
                return s;
            }
        }
        return PENDING;
    }
}
