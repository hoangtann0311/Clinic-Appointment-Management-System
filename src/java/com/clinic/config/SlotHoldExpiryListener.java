package com.clinic.config;

import com.clinic.dao.AppointmentDAO;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background job: quét định kỳ (mỗi 60 giây) các slot đang GIỮ CHỖ TẠM THỜI (status='HELD')
 * đã quá 15 phút mà bệnh nhân chưa gửi thông tin thanh toán — tự huỷ appointment 'Pending'
 * tương ứng và trả slot về AVAILABLE cho người khác đặt.
 *
 * Đây là phần "GIỮ SLOT TẠM THỜI (15 phút) → hết hạn → tự nhả" trong luồng đặt lịch:
 *   Chọn slot → Giữ tạm 15' → (nếu không thanh toán kịp) → tự huỷ, nhả slot
 *   Chọn slot → Giữ tạm 15' → (thanh toán kịp) → BOOKED hẳn → chờ Staff duyệt/từ chối
 */
@WebListener
public class SlotHoldExpiryListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private static final long INTERVAL_SECONDS = 60;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "slot-hold-expiry-sweeper");
            t.setDaemon(true);
            return t;
        });

        AppointmentDAO appointmentDAO = new AppointmentDAO();

        scheduler.scheduleWithFixedDelay(() -> {
            try {
                int released = appointmentDAO.releaseExpiredHolds();
                if (released > 0) {
                    System.out.println(">>> [SlotHoldExpiryListener] Đã tự nhả " + released + " slot hết hạn giữ chỗ.");
                }
            } catch (Exception e) {
                System.err.println(">>> [SlotHoldExpiryListener] Lỗi khi quét slot hết hạn: " + e.getMessage());
                e.printStackTrace();
            }
        }, INTERVAL_SECONDS, INTERVAL_SECONDS, TimeUnit.SECONDS);

        System.out.println(">>> SlotHoldExpiryListener initialized — quét slot hết hạn mỗi " + INTERVAL_SECONDS + " giây.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
        System.out.println(">>> SlotHoldExpiryListener destroyed.");
    }
}