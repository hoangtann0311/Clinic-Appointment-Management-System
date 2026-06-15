package com.clinic.service;

import com.clinic.dao.UltrasoundOrderDAO;
import com.clinic.model.UltrasoundWaitingPatient;

import java.util.List;
import java.util.Set;

/**
 * Business layer for ultrasound waiting orders.
 */
public class UltrasoundOrderService {

    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of(
        "appointmentDate",
        "patientName",
        "serviceName",
        "createdAt",
        "emergency",
        "orderId"
    );

    private final UltrasoundOrderDAO ultrasoundOrderDAO;

    public UltrasoundOrderService() {
        this.ultrasoundOrderDAO = new UltrasoundOrderDAO();
    }

    public List<UltrasoundWaitingPatient> getWaitingPatients(String sortBy, String sortDir) {
        return ultrasoundOrderDAO.findWaiting(normalizeSortBy(sortBy), normalizeSortDir(sortDir));
    }

    public int countWaitingPatients() {
        return ultrasoundOrderDAO.countWaiting();
    }

    public boolean markAsUltrasounded(int orderId) {
        if (orderId <= 0) {
            return false;
        }
        return ultrasoundOrderDAO.markCompleted(orderId);
    }

    public String normalizeSortBy(String sortBy) {
        if (sortBy == null || !ALLOWED_SORT_FIELDS.contains(sortBy)) {
            return "appointmentDate";
        }
        return sortBy;
    }

    public String normalizeSortDir(String sortDir) {
        return "desc".equalsIgnoreCase(sortDir) ? "desc" : "asc";
    }
}
