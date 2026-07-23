package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.clinic.utils.StaffValidator;
import java.util.Map;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/reception/sos", "/admin/reception/sos/trigger", "/admin/reception/sos/dismiss"})
public class StaffSosServlet extends HttpServlet {

    private StaffReceptionService staffReceptionService;

    @Override
    public void init() throws ServletException {
        staffReceptionService = (StaffReceptionService) getServletContext().getAttribute("staffReceptionService");

        if (staffReceptionService == null) {
            staffReceptionService = new StaffReceptionService();
            getServletContext().setAttribute("staffReceptionService", staffReceptionService);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        setCurrentDisplayDate(req);
        setSosPageData(req);

        req.getRequestDispatcher("/views/staff/reception-sos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 4) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Thao tác kích hoạt và giải tỏa ca SOS chỉ dành cho nhân viên Lễ tân (Staff).");
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        if ("/admin/reception/sos/trigger".equals(path)) {
            String appointmentId = req.getParameter("appointmentId");
            String symptoms = req.getParameter("symptoms");

            Map<String, String> fieldErrors = new java.util.LinkedHashMap<>();
            if (appointmentId == null || appointmentId.isBlank()) {
                fieldErrors.put("appointmentId", "Vui lòng chọn bệnh nhân đang trong luồng khám hôm nay.");
            }
            String symptomsError = StaffValidator
                    .validateSosFieldErrors("Bệnh nhân", "0900000000", symptoms).get("symptoms");
            if (symptomsError != null) fieldErrors.put("symptoms", symptomsError);

            if (!fieldErrors.isEmpty()) {
                req.setAttribute("fieldErrors", fieldErrors);
                req.setAttribute("errors", fieldErrors.values());

                setCurrentDisplayDate(req);
                setSosPageData(req);

                req.getRequestDispatcher("/views/staff/reception-sos.jsp").forward(req, resp);
                return;
            }

            try {
                String queueNumber = staffReceptionService
                        .activateEmergencySosForAppointment(appointmentId, symptoms);
                resp.sendRedirect(req.getContextPath() + "/admin/reception/sos?success=activated&queue="
                        + java.net.URLEncoder.encode(queueNumber, "UTF-8"));
            } catch (IllegalArgumentException e) {
                forwardSosWithErrors(req, resp, e);
            }

            return;
        }

        if ("/admin/reception/sos/dismiss".equals(path)) {
            String id = req.getParameter("id");

            try {
                if (id == null || id.isEmpty()) {
                    throw new IllegalArgumentException("Mã ca SOS không được để trống.");
                }

                staffReceptionService.dismissSosAlarm(id);
                resp.sendRedirect(req.getContextPath() + "/admin/reception/sos?success=dismissed");
            } catch (IllegalArgumentException e) {
                forwardSosWithErrors(req, resp, e);
            }

            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reception/sos");
    }

    private void forwardSosWithErrors(HttpServletRequest req, HttpServletResponse resp, IllegalArgumentException e)
            throws ServletException, IOException {

        req.setAttribute("errors", Arrays.asList(e.getMessage().split("\\|")));

        setCurrentDisplayDate(req);
        setSosPageData(req);

        req.getRequestDispatcher("/views/staff/reception-sos.jsp").forward(req, resp);
    }

    private void setCurrentDisplayDate(HttpServletRequest req) {
        LocalDate currentDate = LocalDate.now();
        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy");

        req.setAttribute("currentDisplayDate", currentDate.format(displayFormatter));
    }

    private void setSosPageData(HttpServletRequest req) {
        List<com.clinic.model.Appointment> todayQueue = staffReceptionService.getSmartQueueByDate(LocalDate.now());
        req.setAttribute("sosAppointments", todayQueue.stream()
                .filter(a -> "Emergency_SOS".equalsIgnoreCase(a.getStatus()))
                .collect(Collectors.toList()));
        req.setAttribute("sosCandidates", todayQueue.stream()
                .filter(a -> "Confirmed".equalsIgnoreCase(a.getStatus())
                        || "Waiting".equalsIgnoreCase(a.getStatus())
                        || "InProgress".equalsIgnoreCase(a.getStatus()))
                .collect(Collectors.toList()));

        req.setAttribute("activeSos", staffReceptionService.getWidgetActiveSosByDate(LocalDate.now()));
    }
}
