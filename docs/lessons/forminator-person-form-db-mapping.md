# Mapping: Person Registration Form Fields to Database Schema & Approval Logic

## 1. Form Fields (Forminator ID: 364)
- Prefix
- First Name
- Middle Name
- Last Name/Surname
- Email Address (with confirmation)
- Phone
- Profile Sharing Method (LinkedIn or CV/Resume)
- LinkedIn Profile (conditional)
- CV/Resume Upload (conditional)
- Citizenship ID Upload
- Residence ID Upload (conditional)
- Option: Citizenship ID and Residence ID are same
- Consent
- CAPTCHA

## 2. Database Schema Mapping
- Table: `td_user_data_change_requests` (stores registration and profile change requests for all user roles)
- Columns:
  - `id` (PK)
  - `prefix` (varchar)
  - `first_name` (varchar)
  - `middle_name` (varchar)
  - `last_name` (varchar)
  - `email` (varchar, unique)
  - `phone` (varchar)
  - `profile_method` (enum: linkedin, cv)
  - `linkedin_url` (varchar, nullable)
  - `cv_file_path` (varchar, nullable)
  - `citizenship_id_file` (varchar)
  - `residence_id_file` (varchar, nullable)
  - `ids_are_same` (boolean)
  - `consent` (boolean/timestamp)
  - `captcha_passed` (boolean/timestamp)
  - `status` (enum: new, pending, approved, rejected)
  - `assigned_to` (manager/operator id)
  - `submitted_date`, `updated_date`

## 3. Approval Logic Mapping
- On registration or profile change:
  - Fields requiring manager approval:
    - Prefix, First Name, Middle Name, Last Name/Surname
    - Citizenship ID, Residence ID (and 'ids_are_same' option)
    - Email Address (also triggers OTP verification)
    - Phone (also triggers OTP verification)
  - Fields requiring self-approval:
    - Consent (form only)
    - CAPTCHA (form only)
  - Fields not requiring approval:
    - Profile sharing method, LinkedIn URL, CV upload
- All approval requests and changes logged in `td_user_registration_approvals`:
  - `user_id`, `field`, `old_value`, `new_value`, `approval_required`, `approval_status`, `requested_by`, `requested_at`, `approved_by`, `approved_at`, `audit_comment`
- Manager reviews and approves/rejects requests via dashboard or notification.
- OTP verification required for email/phone changes before approval.

## 4. Compliance & Audit
- All changes (pending, approved, rejected) are logged for audit.
- Consent and CAPTCHA status stored for compliance.
- File uploads (ID docs, CV) stored securely and referenced in DB.

---
_Last updated: January 17, 2026_