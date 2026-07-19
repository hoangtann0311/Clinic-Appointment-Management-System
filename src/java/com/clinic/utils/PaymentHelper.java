package com.clinic.utils;

import com.clinic.model.InvoiceItem;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

/** Common, module-independent helpers used by the invoice/payment flow. */
public final class PaymentHelper {

    private PaymentHelper() {
    }

    /**
     * Returns a non-null item list so payment views can render an empty invoice
     * safely.  It intentionally has no dependency on laboratory orders.
     */
    public static List<InvoiceItem> safeItems(List<InvoiceItem> items) {
        return items == null ? Collections.emptyList() : items;
    }

    /** Calculates the invoice line-item total using stored subtotals when present. */
    public static BigDecimal calculateItemsTotal(List<InvoiceItem> items) {
        BigDecimal total = BigDecimal.ZERO;
        for (InvoiceItem item : safeItems(items)) {
            if (item.getSubtotal() != null) {
                total = total.add(item.getSubtotal());
            } else if (item.getUnitPrice() != null && item.getQuantity() > 0) {
                total = total.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }
        return total;
    }
}
