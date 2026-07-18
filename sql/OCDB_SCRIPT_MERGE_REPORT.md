# OCDB / script.sql merge assessment

## Inputs and decision

- Canonical source read in full: `C:\Users\admin\Documents\OCDB.sql` (1,762 lines, SHA-256 `33DF...A82`).
- Supplement read in full: `C:\Users\admin\Documents\script.sql` (2,137 lines, SHA-256 `7E03...AB8`).
- Final database name remains `ObstetricsClinicDB`, matching `DatabaseConfig`.
- `OCDB.sql` remains the schema/data baseline. No SQL was run against SQL Server.

## Schema reconciliation

`OCDB.sql` alone contains `ai_analysis_results` and `ultrasound_images`; both are retained for the Sonographer and AI flows. `script.sql` has no exclusive table.

| Object | Decision |
|---|---|
| `appointments.queue_number`, `appointments.slot_id` | Retained from OCDB; required by reception/SOS/time-slot code. |
| `invoices` payment-confirmation fields | Retained from OCDB; required by `InvoiceDAO`. |
| `medical_records.updated_at`, `updated_by` | Added from script and extended with the complete obstetric fields actually used by `MedicalRecordDAO`/`PregnancyDAO`. |
| `doctors.degree`, `experience_years`, `avatar_url`, `bio` | Added because `DoctorDAO` selects and updates them. |
| `invoice_items.amount` | Added as a computed compatibility column from `subtotal` (or quantity × unit price), used by `ServiceDAO`. |
| Script dashboard/auth indexes | Added idempotently by migration. |
| `doctor_schedules.version` nullability | OCDB retained; `timestamp` is database-generated and changing nullability would be destructive. |

## Data inventory and conflicts

## Implemented source-user mapping

| script user IDs | Source role/person | Final action |
|---|---|---|
| 18–20 | `staff.anh`, `staff.binh`, `staff.cuc` | Insert as new OCDB users; the existing OCDB IDs 18–20 remain Doctors. |
| 21–23 | `sono.linh`, `sono.hai`, `sono.thanh` | Insert as new OCDB users, then insert/map sonographer rows by mapped user ID. |
| 24–28 | `doctor.huong` … `doctor.anhh` | Deduplicate to OCDB Doctor users 18–22 by username/full name; map source doctor IDs 1–5 by that mapped user. |

`migration_OCDB_merge_script.sql` now stages the raw source rows in `#Src*` tables and persists `#UserMap`, `#PatientMap`, `#DoctorMap`, `#SonographerMap`, `#ServiceMap`, and `#AppointmentMap` into `dbo.ocdb_merge_id_map`. It maps appointments by remapped patient + doctor + date/time + service and maps invoices through `#AppointmentMap`, so source numeric IDs are never assumed final IDs.

| Entity | OCDB INSERT rows | script INSERT rows | Disposition |
|---|---:|---:|---|
| users | 26 | 28 | IDs 18–26 represent different people between snapshots. Do not merge by ID. |
| patients | 8 | 13 | IDs 5–8 conflict with different business entities. |
| doctors | 5 | 5 | Same doctor names, but script user IDs 24–28 conflict with OCDB user IDs 18–22. |
| sonographers | 0 | 3 | Requires user-ID remap by username before import. |
| appointments | 0 | 123 | Requires patient-ID remap and doctor remap before import. |
| invoices | 0 | 87 | Requires appointment-ID remap before import. |
| permissions | 37 | 42 | Supplement has five additional candidates; merge by `permission_key` after staging. |
| role_permissions | 96 | 107 | Merge only after role/permission business-key maps exist. |
| audit_logs | 24 | 75 | Preserve only through a staged user-ID remap; logs must not point to a different person. |

The requested source and deduplicated/remapped counts cannot be truthfully reported as final counts until a staged import maps encrypted user email values and all dependent records. The verification script deliberately does not fabricate `OCDB_count`, `script_count`, `deduplicated_count`, `remapped_count`, or `conflict_count`.

## Data not automatically replayed

Transactional rows unique to `script.sql` are intentionally **not** inserted by `migration_OCDB_merge_script.sql`. Direct replay would attach appointments, invoices, audit logs, and sonographers to unrelated OCDB users/patients. This is an unresolved data conflict, not a code/schema defect.

Required safe staged-import order: roles/permissions → users (username or decrypted email) → patients/doctors/sonographers → schedules/time slots → appointments → invoices → audit logs. Record old-to-new mappings in persistent staging tables, validate every foreign key, then import children. This needs a reviewed data-migration input; it must not be guessed from colliding IDs.

## Files and execution order

1. Back up the target database.
2. For a new database, run `OCDB_MERGED_FINAL.sql` in SQLCMD mode; it builds OCDB then includes the additive migration.
3. For an existing OCDB database, run `migration_OCDB_merge_script.sql` once (it is additive/idempotent within reasonable schema scope).
4. Run `verify_OCDB_MERGED.sql` and resolve any non-zero integrity/duplicate result.
5. Only then run Tomcat/SQL Server integration tests for all roles and AI uploads.

## Runtime validation still required

Test Admin role/permission management and audit log; Manager dashboard/report/pricing/schedule; Doctor profile, appointments, medical records and prescriptions; Staff reception/SOS/payment; Sonographer upload/result; Patient booking/history/invoice; and AI original/result/mask path persistence.
