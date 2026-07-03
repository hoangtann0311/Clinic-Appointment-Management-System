package controller;

import com.clinic.model.Medicine;
import com.clinic.service.MedicineService;
import com.clinic.utils.AuditUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý biểu giá thuốc cho Admin/Manager.
 * GET  → hiển thị danh sách thuốc (phân trang + tìm kiếm + lọc)
 * POST → xử lý thêm / sửa / vô hiệu hóa
 */
@WebServlet(urlPatterns = {"/admin/medicines/", "/admin/medicines"})
public class AdminMedicineServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private MedicineService medicineService;

    @Override
    public void init() throws ServletException {
        medicineService = new MedicineService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int page = parseInt(req.getParameter("page"), 1);
        String search = req.getParameter("search");
        String activeStr = req.getParameter("active");
        Boolean activeFilter = null;
        if (activeStr != null && !activeStr.isEmpty()) {
            activeFilter = "1".equals(activeStr);
        }

        List<Medicine> medicines = medicineService.getMedicines(page, PAGE_SIZE, search, activeFilter);
        int totalMedicines = medicineService.getTotalMedicines(search, activeFilter);
        int totalPages = (int) Math.ceil((double) totalMedicines / PAGE_SIZE);

        req.setAttribute("medicines", medicines);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalMedicines", totalMedicines);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("search", search);
        req.setAttribute("activeFilter", activeStr);

        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/views/admin/medicines/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/medicines/";

        try {
            switch (action != null ? action : "") {

                case "create": {
                    String medicineCode = req.getParameter("medicineCode");
                    String name = req.getParameter("name");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String price = req.getParameter("price");
                    String stockQuantity = req.getParameter("stockQuantity");

                    Map<String, String> errors = new HashMap<>();
                    if (medicineService.createMedicine(medicineCode, name, description,
                            dosage, unit, price, stockQuantity, errors)) {
                        AuditUtil.log(req, "Tạo mới thuốc: " + name, "medicines",
                                null, "price=" + price);
                        resp.sendRedirect(redirectUrl + "?success=created");
                    } else {
                        req.setAttribute("errors", errors);
                        req.setAttribute("formData", buildFormData(req));
                        req.setAttribute("showCreateModal", true);
                        doGet(req, resp);
                    }
                    return;
                }

                case "edit": {
                    int id = parseInt(req.getParameter("id"), -1);
                    String medicineCode = req.getParameter("medicineCode");
                    String name = req.getParameter("name");
                    String description = req.getParameter("description");
                    String dosage = req.getParameter("dosage");
                    String unit = req.getParameter("unit");
                    String price = req.getParameter("price");
                    String stockQuantity = req.getParameter("stockQuantity");
                    boolean isActive = "on".equals(req.getParameter("isActive"));

                    Map<String, String> errors = new HashMap<>();
                    if (medicineService.updateMedicine(id, medicineCode, name, description,
                            dosage, unit, price, stockQuantity, isActive, errors)) {
                        AuditUtil.log(req, "Cập nhật thuốc: " + name, "medicines",
                                null, "price=" + price + ", active=" + isActive);
                        resp.sendRedirect(redirectUrl + "?success=updated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=" + java.net.URLEncoder.encode(
                            errors.getOrDefault("general", "Cập nhật thất bại"), "UTF-8"));
                    }
                    return;
                }

                case "deactivate": {
                    int id = parseInt(req.getParameter("id"), -1);
                    if (medicineService.deactivateMedicine(id)) {
                        resp.sendRedirect(redirectUrl + "?success=deactivated");
                    } else {
                        resp.sendRedirect(redirectUrl + "?error=Vô+hiệu+hóa+thất+bại");
                    }
                    return;
                }

                default:
                    resp.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            System.err.println("AdminMedicineServlet POST: " + e.getMessage());
            resp.sendRedirect(redirectUrl + "?error=Lỗi+hệ+thống");
        }
    }

    private Map<String, String> buildFormData(HttpServletRequest req) {
        Map<String, String> data = new HashMap<>();
        data.put("medicineCode", req.getParameter("medicineCode"));
        data.put("name", req.getParameter("name"));
        data.put("description", req.getParameter("description"));
        data.put("dosage", req.getParameter("dosage"));
        data.put("unit", req.getParameter("unit"));
        data.put("price", req.getParameter("price"));
        data.put("stockQuantity", req.getParameter("stockQuantity"));
        return data;
    }

    private int parseInt(String s, int defaultVal) {
        if (s == null || s.isEmpty()) return defaultVal;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return defaultVal; }
    }
}
