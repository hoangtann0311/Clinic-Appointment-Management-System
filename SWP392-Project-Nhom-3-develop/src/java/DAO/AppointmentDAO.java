/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;
import com.clinic.config.DatabaseConfig;
import model.Appointment;

import java.sql.*;
/**
 *
 * @author ADMIN
 */
public class AppointmentDAO {
    public int createAppointment(Appointment a){

        String sql =
        "INSERT INTO appointments " +
        "(patient_id,doctor_id,appointment_date,symptoms,status,service_id,time_slot) " +
        "VALUES(?,?,?,?,?,?,?)";

        try(Connection con = DatabaseConfig.getConnection();
            PreparedStatement ps =
            con.prepareStatement(sql,
            Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1,a.getPatientId());
            ps.setInt(2,a.getDoctorId());
            ps.setDate(3,a.getAppointmentDate());
            ps.setString(4,a.getSymptoms());
            ps.setString(5,"Pending");
            ps.setInt(6,a.getServiceId());
            ps.setTime(7,a.getTimeSlot());
ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();

            if(rs.next()){
                return rs.getInt(1);
            }

        } catch(Exception e){
            e.printStackTrace();
        }

        return -1;
    }
}
