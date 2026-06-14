/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import DAO.AppointmentDAO;
import DAO.PatientDAO;
import com.clinic.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Appointment;

/**
 *
 * @author ADMIN
 */
@WebServlet("/patient/book-appointment")
public class BookAppointmentServlet extends HttpServlet {

    private PatientDAO patientDAO
            = new PatientDAO();

    private AppointmentDAO appointmentDAO
            = new AppointmentDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User user
                = (User) request.getSession()
                        .getAttribute("user");

        Integer patientId
                = patientDAO.getPatientIdByUserId(
                        user.getId());

        Appointment a = new Appointment();
        a.setPatientId(patientId);

        a.setDoctorId(
                Integer.parseInt(
                        request.getParameter(
                                "doctorId")));

        a.setServiceId(
                Integer.parseInt(
                        request.getParameter(
                                "serviceId")));

        a.setAppointmentDate(
                java.sql.Date.valueOf(
                        request.getParameter(
                                "appointmentDate")));

        a.setTimeSlot(
                java.sql.Time.valueOf(
                        request.getParameter(
                                "timeSlot") + ":00"));

        a.setSymptoms(
                request.getParameter(
                        "symptoms"));

        int appointmentId
                = appointmentDAO.createAppointment(a);

        response.sendRedirect(
                request.getContextPath()
                + "/patient/payment?appointmentId="
                + appointmentId);
    }
}
