package com.nhom3.ocss.utils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.time.Period;
import java.util.LinkedHashMap;
import java.util.Map;

public class StaffValidator {

    public static List<String> validateBooking(
            String name,
            String phone,
            String dob,
            String doctorId,
            String serviceId,
            String appointmentDate,
            String timeSlot,
            String symptoms,
            String lastMenstrualPeriod,
            boolean isEmergency
    ) {
        List<String> errors = new ArrayList<>();

        if (isEmpty(name)) {
            errors.add("Họ tên bệnh nhân không được để trống.");
        }

        if (isEmpty(phone)) {
            errors.add("Số điện thoại không được để trống.");
        } else if (!phone.matches("^0\\d{9,10}$")) {
            errors.add("Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số.");
        }

        if (!isEmpty(dob)) {
            try {
                LocalDate birthDate = LocalDate.parse(dob);
                LocalDate today = LocalDate.now();

                if (birthDate.isAfter(today)) {
                    errors.add("Ngày sinh sản phụ không được lớn hơn ngày hiện tại.");
                } else {
                    int age = java.time.Period.between(birthDate, today).getYears();

                    if (age < 12) {
                        errors.add("Tuổi sản phụ phải từ 12 tuổi trở lên để đặt lịch khám.");
                    }

                    if (age > 55) {
                        errors.add("Tuổi sản phụ không được vượt quá 55 tuổi khi đặt lịch khám sản/phụ khoa.");
                    }
                }

            } catch (Exception e) {
                errors.add("Ngày sinh sản phụ không hợp lệ.");
            }
        }

        if (isEmpty(doctorId)) {
            errors.add("Vui lòng chọn bác sĩ.");
        }

        if (isEmpty(serviceId)) {
            errors.add("Vui lòng chọn dịch vụ khám.");
        }

        if (isEmpty(appointmentDate)) {
            errors.add("Vui lòng chọn ngày khám.");
        } else {
            try {
                LocalDate appDate = LocalDate.parse(appointmentDate);
                if (appDate.isBefore(LocalDate.now())) {
                    errors.add("Không được đặt lịch trong quá khứ.");
                }
            } catch (Exception e) {
                errors.add("Ngày khám không hợp lệ.");
            }
        }

        if (!isEmergency && isEmpty(timeSlot)) {
            errors.add("Vui lòng chọn khung giờ khám.");
        }

        if (isEmpty(symptoms)) {
            errors.add("Vui lòng nhập triệu chứng hoặc lý do khám.");
        } else {
            String cleanSymptoms = symptoms.trim();

            if (cleanSymptoms.length() < 10) {
                errors.add("Triệu chứng/lý do khám quá ngắn. Vui lòng nhập tối thiểu 10 ký tự.");
            }

            if (cleanSymptoms.length() > 500) {
                errors.add("Triệu chứng/lý do khám không được vượt quá 500 ký tự.");
            }

            if (cleanSymptoms.matches("^[0-9\\s]+$")) {
                errors.add("Triệu chứng/lý do khám không được chỉ chứa số.");
            }

            if (!cleanSymptoms.matches("^[\\p{L}0-9\\s,.()/-]+$")) {
                errors.add("Triệu chứng/lý do khám chứa ký tự không hợp lệ.");
            }

            if (cleanSymptoms.toLowerCase().matches(".*(.)\\1{5,}.*")) {
                errors.add("Triệu chứng/lý do khám không hợp lệ. Vui lòng nhập nội dung rõ ràng hơn.");
            }

            if (cleanSymptoms.split("\\s+").length < 2) {
                errors.add("Triệu chứng/lý do khám cần có ít nhất 2 từ.");
            }
        }

        if (!isEmpty(lastMenstrualPeriod) && !isEmpty(appointmentDate)) {
            try {
                LocalDate lmp = LocalDate.parse(lastMenstrualPeriod);
                LocalDate appDate = LocalDate.parse(appointmentDate);

                long totalDays = java.time.temporal.ChronoUnit.DAYS.between(lmp, appDate);

                if (totalDays > 294) {
                    errors.add("Ngày kinh cuối quá xa ngày khám. Tuổi thai vượt quá 42 tuần, vui lòng kiểm tra lại LMP.");
                }

                if (lmp.isAfter(appDate)) {
                    errors.add("Ngày kinh cuối không được sau ngày khám.");
                }

                if (lmp.isAfter(LocalDate.now())) {
                    errors.add("Ngày kinh cuối không được lớn hơn ngày hiện tại.");
                }
            } catch (Exception e) {
                errors.add("Ngày kinh cuối không hợp lệ.");
            }
        }

        return errors;
    }

    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static Map<String, String> validateSosFieldErrors(String name, String phone, String symptoms) {
        Map<String, String> errors = new LinkedHashMap<>();

        if (isEmpty(name)) {
            errors.put("name", "Họ tên bệnh nhân không được để trống.");
        }

        if (isEmpty(phone)) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!phone.matches("^0\\d{9,10}$")) {
            errors.put("phone", "Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số.");
        }

        if (isEmpty(symptoms)) {
            errors.put("symptoms", "Triệu chứng khẩn cấp không được để trống.");
        } else {
            String cleanSymptoms = symptoms.trim();

            if (cleanSymptoms.length() < 5) {
                errors.put("symptoms", "Triệu chứng khẩn cấp quá ngắn, vui lòng nhập rõ hơn.");
            } else if (cleanSymptoms.length() > 500) {
                errors.put("symptoms", "Triệu chứng khẩn cấp không được vượt quá 500 ký tự.");
            } else if (cleanSymptoms.matches("^[0-9\\s]+$")) {
                errors.put("symptoms", "Triệu chứng khẩn cấp không được chỉ chứa số.");
            } else if (!cleanSymptoms.matches("^[\\p{L}0-9\\s,.()/-]+$")) {
                errors.put("symptoms", "Triệu chứng khẩn cấp chứa ký tự không hợp lệ.");
            } else if (cleanSymptoms.toLowerCase().matches(".*(.)\\1{5,}.*")) {
                errors.put("symptoms", "Triệu chứng khẩn cấp không hợp lệ. Vui lòng nhập nội dung rõ ràng hơn.");
            }
        }

        return errors;
    }

    public static List<String> validateSos(String name, String phone, String symptoms) {
        return new ArrayList<>(validateSosFieldErrors(name, phone, symptoms).values());
    }
}