package com.clinic.model.enums;

/**
 * Enum biểu diễn trạng thái của khung giờ khám.
 * <ul>
 *   <li>AVAILABLE — Còn trống</li>
 *   <li>BOOKED    — Đã đặt</li>
 *   <li>COMPLETED — Hoàn thành</li>
 *   <li>CANCELLED — Đã hủy</li>
 * </ul>
 */
public enum SlotStatus {

    AVAILABLE("Còn trống"),
    BOOKED("Đã đặt"),
    COMPLETED("Hoàn thành"),
    CANCELLED("Đã hủy");

    private final String label;

    SlotStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

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
