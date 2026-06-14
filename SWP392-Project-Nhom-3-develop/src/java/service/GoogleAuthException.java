package com.clinic.service;

/**
 * Exception cho lỗi xác thực Google OAuth.
 */
public class GoogleAuthException extends Exception {

    public GoogleAuthException(String message) {
        super(message);
    }

    public GoogleAuthException(String message, Throwable cause) {
        super(message, cause);
    }
}
