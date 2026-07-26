package com.clinic.listener;

import com.clinic.dao.AppointmentDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class BackgroundJobListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        // Chạy mỗi 1 phút
        scheduler.scheduleAtFixedRate(() -> {
            try {
                // Lấy các appointment chưa thanh toán và đã quá Deadline tính toán
                List<Integer> expiredIds = appointmentDAO.getExpiredUnpaidAppointments();
                for (Integer id : expiredIds) {
                    // Hủy lịch và nhả slot (cancelledByUserId = 0 nghĩa là hệ thống tự hủy)
                    appointmentDAO.cancelAppointmentAndReleaseSlot(id, 0, "Hệ thống tự động hủy do chưa thanh toán sau 15 phút");
                    System.out.println("[BackgroundJob] Đã tự động hủy lịch hẹn ID = " + id);
                }
            } catch (Exception e) {
                System.err.println("[BackgroundJob] Lỗi khi dọn dẹp lịch hẹn: " + e.getMessage());
            }
        }, 1, 1, TimeUnit.MINUTES);
        System.out.println("[BackgroundJob] Đã khởi động trình dọn dẹp lịch hẹn tự động.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
        System.out.println("[BackgroundJob] Đã tắt trình dọn dẹp.");
    }
}
