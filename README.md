# Obstetric Clinic Scheduling & AI-Assisted Diagnostic System

## 1. Overview

Obstetric Clinic Scheduling & AI-Assisted Diagnostic System (OCSS) is a Java web application designed to support the daily operation of an obstetric clinic.

The system helps manage doctor schedules, patient appointments, reception workflows, medical examination queues, ultrasound requests, AI-assisted ultrasound image analysis, billing, payment confirmation and clinic revenue reports.

This project was developed as a team project. My main responsibilities include leading the team, developing the Staff module, developing the Sonographer workflow, and integrating the AI-assisted image analysis feature.

## 2. Main Objectives

- Manage doctor working schedules and appointment time slots.
- Support online and offline appointment booking.
- Handle patient reception, check-in and queue coordination.
- Prioritize emergency SOS cases.
- Manage ultrasound requests and uploaded ultrasound images.
- Use AI to support lesion localization and segmentation on ultrasound images.
- Support billing, payment confirmation and revenue tracking.
- Provide role-based access control for different users in the clinic.

## 3. Tech Stack

### Backend
- Java Servlet
- JSP / JSTL
- JDBC
- MVC Architecture
- DAO Pattern

### Frontend
- HTML5
- CSS3
- Bootstrap 5
- JavaScript

### Database
- Microsoft SQL Server

### Server
- Apache Tomcat

### AI Module
- Python
- YOLO
- SAM2
- U-Net

### Tools
- Git
- GitHub
- Jira
- IntelliJ IDEA / NetBeans
- SQL Server Management Studio

## 4. User Roles

### Admin
- Manage user accounts.
- Assign roles and permissions.
- Lock or unlock accounts.
- Manage doctor and staff information.
- View system activity logs.

### Manager
- Approve or reject doctor working schedules.
- Manage medical services and prices.
- Manage medicine and selling prices.
- View revenue reports.
- Monitor clinic performance.
- View doctor performance statistics.

### Staff
- View appointment lists.
- Create appointments for patients via phone.
- Check in patients.
- Assign queue numbers.
- Manage the examination queue.
- Handle emergency SOS alerts.
- Confirm cash or bank transfer payments.

### Doctor
- Register working schedules.
- View appointments and queue lists.
- Examine patients.
- View medical history.
- Create ultrasound requests.
- Review AI-assisted ultrasound results.
- Write medical conclusions and prescriptions.
- Complete examination cases.

### Sonographer
- View ultrasound requests.
- Perform ultrasound examinations.
- Upload ultrasound images.
- Send uploaded images to the AI Engine.
- Update ultrasound request status.

### Patient
- Register and log in.
- Manage personal information.
- Search doctors and available time slots.
- Book, cancel or reschedule appointments.
- Submit symptoms and last menstrual period.
- Trigger emergency SOS.
- View invoices and payment status.
- View examination results and prescriptions.
- Rate doctors after completed examinations.
- Receive appointment reminders.

### AI Engine
- Receive ultrasound images.
- Analyze images.
- Generate suspected lesion masks.
- Return prediction results and confidence scores for doctor reference.

## 5. Core Features

### Authentication and Authorization
- User registration and login.
- Session management.
- Role-based dashboard redirection.
- Role-based access control.

### Doctor Schedule Management
- Doctors can register working schedules.
- Managers can approve or reject schedules.
- Approved schedules are divided into appointment time slots.
- Patients can only book approved and available time slots.

### Appointment Management
- Patients can book, cancel or reschedule appointments.
- Staff can create appointments for patients via phone.
- The system validates available time slots before creating appointments.
- Appointment status is tracked during the full clinic workflow.

### Patient Reception and Queue Management
- Staff can check in patients.
- The system assigns queue numbers automatically.
- Checked-in patients are added to the waiting queue.
- Staff and doctors can view and manage the queue.

### Emergency SOS Handling
- Patients can trigger SOS in emergency situations.
- The system marks the appointment as an emergency case.
- Staff and doctors receive emergency alerts.
- SOS cases are prioritized in the queue.

### Ultrasound and AI-Assisted Image Analysis
- Doctors can create ultrasound requests.
- Sonographers can receive requests and upload ultrasound images.
- Uploaded images are sent to the AI Engine.
- AI returns suspected lesion masks and confidence results.
- Doctors review both the original image and AI-assisted result before making the final conclusion.

> Note: The AI result is used only as a supporting reference. The doctor is responsible for the final medical conclusion.

### Medical Record and Prescription
- Doctors can update examination results.
- Doctors can write medical conclusions.
- Doctors can prescribe medicines.
- Patients can view their results after the examination is completed.

### Billing and Payment
- The system generates invoices based on medical services and medicines.
- Patients can choose cash or bank transfer.
- Staff confirms payment manually.
- Paid invoices are used for revenue reporting.

### Revenue Report
- Managers and admins can view revenue by selected time range.
- The system summarizes paid invoices.
- Reports include examination count, revenue and clinic activity statistics.

## 6. Business Workflow

### Appointment Booking Flow

1. Patient selects doctor, date and available time slot.
2. Patient enters symptoms and last menstrual period.
3. The system checks slot availability.
4. The system creates an appointment.
5. Patient receives appointment confirmation.

### Reception Flow

1. Patient arrives at the clinic.
2. Staff searches for the appointment.
3. Staff checks in the patient.
4. The system assigns a queue number.
5. Patient is added to the waiting queue.

### Examination and Ultrasound Flow

1. Doctor calls the patient from the queue.
2. Doctor reviews patient information and medical history.
3. Doctor performs clinical examination.
4. Doctor creates an ultrasound request if needed.
5. Sonographer uploads ultrasound images.
6. AI Engine analyzes the images.
7. Doctor reviews AI-assisted results.
8. Doctor writes the final conclusion and prescription.

### Payment Flow

1. The system generates an invoice after the examination.
2. Patient views invoice information.
3. Patient selects cash or bank transfer.
4. Staff confirms the payment.
5. The system updates the invoice status to Paid.

## 7. Business Rules

- Each doctor time slot can only be booked once.
- Only approved doctor schedules can be used for appointment booking.
- Patients cannot select a time slot in the past.
- Patients can only cancel or reschedule appointments before the allowed time limit.
- Emergency SOS cases have higher priority than normal appointments.
- Patients must be checked in before entering the queue.
- Only doctors can create ultrasound requests.
- Only sonographers can upload ultrasound images.
- AI results are for reference only.
- Doctors are responsible for final medical conclusions.
- Managers cannot modify medical records.
- Service and medicine prices must be stored at the time of invoice creation.
- Patients can only rate doctors after a successful examination.
- Each examination can only be rated once.
- Only staff can confirm paid invoices.
- Revenue is calculated only from invoices with Paid status.

## 8. Main Statuses

### Appointment Status
- Pending
- Confirmed
- Waiting
- Emergency_SOS
- InProgress
- SUCCESS
- Cancelled
- NoShow

### Schedule Status
- Pending
- Approved
- Rejected

### Payment Status
- Unpaid
- PendingConfirmation
- Paid
- Cancelled

### Ultrasound Request Status
- Pending
- InProgress
- Uploaded
- Analyzing
- Completed
- Cancelled

## 9. My Responsibilities

As the Team Leader and Full-Stack Developer, I was responsible for:

- Leading a three-member development team.
- Analyzing requirements and dividing tasks using Jira.
- Coordinating module integration among team members.
- Designing and developing the Staff module.
- Implementing patient reception, check-in, queue coordination and SOS case handling.
- Designing and developing the Sonographer workflow.
- Implementing ultrasound request handling and medical image upload.
- Integrating the Java web application with the AI-assisted image analysis service.
- Managing Git branches, resolving merge conflicts and reviewing team code.
- Coordinating system testing and bug fixing.
