package com.clinic.model.enums;

/**
 * Trạng thái tài khoản người dùng.
 */
public enum UserStatus {
    ACTIVE("Active"),
    INACTIVE("Inactive"),
    LOCKED("Locked"),
    PENDING_VERIFICATION("Pending Verification");

    private final String value;

    UserStatus(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static UserStatus fromString(String text) {
        if (text != null) {
            for (UserStatus s : UserStatus.values()) {
                if (s.value.equalsIgnoreCase(text)) {
                    return s;
                }
            }
        }
        return ACTIVE;
    }
}
