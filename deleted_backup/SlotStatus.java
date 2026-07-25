package com.clinic.model.enums;

/**
 * Enum biểu diễn trạng thái của khung giờ khám (time_slots).
 * <ul>
 *   <li>AVAILABLE           — Còn trống, có thể đặt lịch</li>
 *   <li>HELD                — Đang được 1 bệnh nhân giữ chỗ tạm thời (15 phút) chờ nộp thanh toán</li>
 *   <li>WAITING_VERIFICATION — Bệnh nhân đã gửi thông tin thanh toán, đang chờ Staff duyệt</li>
 *   <li>BOOKED              — Staff đã duyệt thanh toán — lịch hẹn đã được xác nhận chính thức</li>
 *   <li>COMPLETED           — Đã hoàn thành khám</li>
 *   <li>CANCELLED           — Đã bị hủy (bệnh nhân hoặc hệ thống)</li>
 * </ul>
 *
 * <p>Luồng trạng thái (state machine) khi bệnh nhân đặt lịch:
 * <pre>
 *  AVAILABLE ──(bệnh nhân đặt)──▶ HELD ──(gửi thanh toán)──▶ WAITING_VERIFICATION ──(Staff duyệt)──▶ BOOKED
 *      ▲                           │                              │
 *      └───────(hết hạn giữ chỗ)───┘◀─────────(Staff từ chối)──────┘
 * </pre>
 */
public enum SlotStatus {

    AVAILABLE("Còn trống"),
    HELD("Đang giữ chỗ"),
    WAITING_VERIFICATION("Đang chờ xác nhận thanh toán"),
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