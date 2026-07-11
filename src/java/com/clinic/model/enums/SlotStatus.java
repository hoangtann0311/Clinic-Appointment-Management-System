package com.clinic.model.enums;

/**
 * Enum biểu diễn trạng thái của khung giờ khám (time_slots).
 * <ul>
 *   <li>AVAILABLE  — Còn trống, có thể đặt lịch</li>
 *   <li>BOOKED     — Đã được bệnh nhân đặt</li>
 *   <li>COMPLETED  — Đã hoàn thành khám</li>
 *   <li>CANCELLED  — Đã bị hủy (bệnh nhân hoặc hệ thống)</li>
 * </ul>
 */
public enum SlotStatus {

    AVAILABLE("Còn trống"),
    BOOKED("Đã đặt"),
    COMPLETED("Đã hoàn thành"),
    CANCELLED("Đã hủy");

    private final String label;

    SlotStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /**
     * Parse từ chuỗi (không phân biệt hoa thường).
     * Mặc định trả về AVAILABLE nếu giá trị không hợp lệ.
     */
    public static SlotStatus fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return AVAILABLE;
        }
        for (SlotStatus s : values()) {
            if (s.name().equalsIgnoreCase(value.trim())) {
                return s;
            }
        }
        return AVAILABLE;
    }
}
