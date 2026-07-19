package com.clinic.config;

import com.clinic.dao.AppointmentDAO;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Releases booking holds that have passed their payment deadline. This keeps
 * time slots available even when no user opens a booking page afterwards.
 */
@WebListener
public class SlotHoldExpiryListener implements ServletContextListener {

    private static final long INTERVAL_SECONDS = 60;
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread = new Thread(runnable, "slot-hold-expiry-sweeper");
            thread.setDaemon(true);
            return thread;
        });

        AppointmentDAO appointmentDAO = new AppointmentDAO();
        scheduler.scheduleWithFixedDelay(() -> {
            try {
                int released = appointmentDAO.releaseExpiredHolds();
                if (released > 0) {
                    System.out.println("[SlotHoldExpiryListener] Released " + released + " expired slot hold(s).");
                }
            } catch (Exception e) {
                System.err.println("[SlotHoldExpiryListener] Expired-hold cleanup failed: " + e.getMessage());
            }
        }, INTERVAL_SECONDS, INTERVAL_SECONDS, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }
}
