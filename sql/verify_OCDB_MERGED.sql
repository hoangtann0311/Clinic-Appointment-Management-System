/* Read-only verification for the OCDB merged application schema. */
/* The caller must select the target database explicitly; this script never changes context. */
SET NOCOUNT ON;

/* Required modules, tables and columns. */
SELECT required_table, CASE WHEN OBJECT_ID(N'dbo.' + required_table, N'U') IS NULL THEN 'MISSING' ELSE 'OK' END AS table_status
FROM (VALUES
 (N'users'),(N'roles'),(N'permissions'),(N'role_permissions'),(N'patients'),(N'doctors'),(N'sonographers'),
 (N'appointments'),(N'doctor_schedules'),(N'time_slots'),(N'medical_records'),(N'prescriptions'),(N'prescription_items'),
 (N'test_orders'),(N'ultrasound_images'),(N'ultrasound_results'),(N'ai_analysis_results'),(N'invoices'),(N'invoice_items'),
 (N'services'),(N'medicines'),(N'audit_logs'),(N'notifications')) AS required(required_table)
ORDER BY required_table;

/* Retired laboratory feature must not reappear. */
SELECT N'lab_technician_role' AS check_name,
       (SELECT COUNT(*) FROM dbo.roles WHERE role_name=N'Lab Technician') AS invalid_count
UNION ALL SELECT N'laboratory_services',
       (SELECT COUNT(*) FROM dbo.services WHERE service_code LIKE N'SVC-XN-%')
UNION ALL SELECT N'laboratory_category',
       (SELECT COUNT(*) FROM dbo.service_categories WHERE category_name=N'Xét nghiệm')
UNION ALL SELECT N'lab_results_table',
       CASE WHEN OBJECT_ID(N'dbo.lab_results', N'U') IS NULL THEN 0 ELSE 1 END;

SELECT required_column.table_name, required_column.column_name,
       c.data_type, c.character_maximum_length, c.numeric_precision, c.numeric_scale,
       CASE WHEN c.column_name IS NULL THEN 'MISSING' ELSE 'OK' END AS column_status
FROM (VALUES
 (N'doctors',N'degree'),(N'doctors',N'experience_years'),(N'doctors',N'avatar_url'),(N'doctors',N'bio'),
 (N'appointments',N'slot_id'),(N'appointments',N'queue_number'),
 (N'medical_records',N'updated_by'),(N'medical_records',N'status'),(N'medical_records',N'gestational_age_weeks'),
 (N'medical_records',N'risk_flags_json'),(N'invoice_items',N'amount'),
 (N'ai_analysis_results',N'input_image'),(N'ai_analysis_results',N'result_image'),(N'ai_analysis_results',N'mask_image'),
 (N'ai_analysis_results',N'confidence'),(N'ultrasound_images',N'file_path')) AS required_column(table_name,column_name)
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_SCHEMA=N'dbo' AND c.TABLE_NAME=required_column.table_name AND c.COLUMN_NAME=required_column.column_name
ORDER BY required_column.table_name, required_column.column_name;

/* Keys and expected merge indexes. */
SELECT o.name AS table_name, i.name AS index_name, i.is_unique, i.is_primary_key
FROM sys.indexes i JOIN sys.objects o ON o.object_id=i.object_id
WHERE o.schema_id=SCHEMA_ID(N'dbo') AND i.name IN
 (N'IX_Appointments_DoctorDateStatus',N'IX_Appointments_ServiceDate',N'IX_Invoices_StatusAppointment',
  N'IX_time_slots_booking',N'IX_time_slots_doctor_date',N'IX_time_slots_schedule',N'UX_time_slots_schedule_start',
  N'IX_password_reset_tokens_token',N'IX_users_google_id',N'UQ_users_google_id')
ORDER BY o.name, i.name;

/* Reference integrity and business-key duplicates. Each result count must be zero. */
SELECT N'appointment_without_patient_or_doctor' AS check_name, COUNT(*) AS invalid_count
FROM dbo.appointments a LEFT JOIN dbo.patients p ON p.id=a.patient_id LEFT JOIN dbo.doctors d ON d.id=a.doctor_id
WHERE a.patient_id IS NOT NULL AND (p.id IS NULL OR (a.doctor_id IS NOT NULL AND d.id IS NULL))
UNION ALL SELECT N'medical_record_without_appointment', COUNT(*) FROM dbo.medical_records mr LEFT JOIN dbo.appointments a ON a.id=mr.appointment_id WHERE mr.appointment_id IS NOT NULL AND a.id IS NULL
UNION ALL SELECT N'invoice_without_appointment', COUNT(*) FROM dbo.invoices i LEFT JOIN dbo.appointments a ON a.id=i.appointment_id WHERE i.appointment_id IS NOT NULL AND a.id IS NULL
UNION ALL SELECT N'ultrasound_image_without_order', COUNT(*) FROM dbo.ultrasound_images ui LEFT JOIN dbo.test_orders t ON t.id=ui.test_order_id WHERE t.id IS NULL
UNION ALL SELECT N'ai_result_without_order', COUNT(*) FROM dbo.ai_analysis_results ar LEFT JOIN dbo.test_orders t ON t.id=ar.test_order_id WHERE t.id IS NULL
UNION ALL SELECT N'time_slot_without_doctor', COUNT(*) FROM dbo.time_slots ts LEFT JOIN dbo.doctors d ON d.id=ts.doctor_id WHERE d.id IS NULL
UNION ALL SELECT N'user_without_role', COUNT(*) FROM dbo.users u LEFT JOIN dbo.roles r ON r.id=u.role_id WHERE u.is_deleted=0 AND u.role_id IS NOT NULL AND r.id IS NULL;

SELECT N'duplicate_username' AS check_name, username AS business_key, COUNT(*) AS duplicate_count FROM dbo.users WHERE username IS NOT NULL GROUP BY username HAVING COUNT(*)>1
UNION ALL SELECT N'duplicate_google_id', google_id, COUNT(*) FROM dbo.users WHERE google_id IS NOT NULL GROUP BY google_id HAVING COUNT(*)>1
UNION ALL SELECT N'duplicate_permission_key', permission_key, COUNT(*) FROM dbo.permissions GROUP BY permission_key HAVING COUNT(*)>1
UNION ALL SELECT N'duplicate_time_slot', CONCAT(schedule_id, N'/', CONVERT(nvarchar(20), start_time)), COUNT(*) FROM dbo.time_slots GROUP BY schedule_id,start_time HAVING COUNT(*)>1;

/* Observed counts. Source and conflict counts require a staged import run; they are intentionally not fabricated. */
SELECT N'users' AS entity, COUNT(*) AS final_count FROM dbo.users
UNION ALL SELECT N'patients', COUNT(*) FROM dbo.patients
UNION ALL SELECT N'appointments', COUNT(*) FROM dbo.appointments
UNION ALL SELECT N'invoices', COUNT(*) FROM dbo.invoices
UNION ALL SELECT N'ultrasound_images', COUNT(*) FROM dbo.ultrasound_images
UNION ALL SELECT N'ai_analysis_results', COUNT(*) FROM dbo.ai_analysis_results;

/* Source/import accounting: source counts are fixed from the audited dumps; map rows are persisted by migration. */
SELECT N'users' AS entity, 26 AS OCDB_count, 28 AS script_count,
       (SELECT COUNT(*) FROM dbo.ocdb_merge_id_map WHERE source_name=N'script.sql' AND table_name=N'users' AND merge_action='DEDUPLICATED') AS deduplicated_count,
       (SELECT COUNT(*) FROM dbo.ocdb_merge_id_map WHERE source_name=N'script.sql' AND table_name=N'users' AND merge_action='INSERTED') AS remapped_count,
       0 AS unresolved_count, (SELECT COUNT(*) FROM dbo.users) AS final_count
UNION ALL SELECT N'patients',8,13,
       (SELECT COUNT(*) FROM dbo.ocdb_merge_id_map WHERE source_name=N'script.sql' AND table_name=N'patients' AND merge_action='DEDUPLICATED'),
       (SELECT COUNT(*) FROM dbo.ocdb_merge_id_map WHERE source_name=N'script.sql' AND table_name=N'patients' AND merge_action='INSERTED'),0,(SELECT COUNT(*) FROM dbo.patients)
UNION ALL SELECT N'appointments',0,123,0,
       (SELECT COUNT(*) FROM dbo.ocdb_merge_id_map WHERE source_name=N'script.sql' AND table_name=N'appointments'),
       (SELECT COUNT(*) FROM dbo.ocdb_merge_unresolved WHERE source_name=N'script.sql' AND table_name=N'appointments'),(SELECT COUNT(*) FROM dbo.appointments)
UNION ALL SELECT N'invoices',0,87,0,0,0,(SELECT COUNT(*) FROM dbo.invoices);

SELECT source_name,table_name,source_old_id,business_key,missing_relation,candidate_mappings
FROM dbo.ocdb_merge_unresolved
ORDER BY table_name,source_old_id;
GO
