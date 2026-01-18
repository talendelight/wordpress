# Lessons Learned: Forminator API & Person Registration Form

## 1. Forminator API Usage
- The Forminator API (Forminator_API class) provides direct access to forms and entries via PHP, not WP-CLI.
- Key methods for form data:
  - `get_forms()`: Returns all forms and their structure.
  - `get_entries($form_id)`: Returns all entries for a form.
  - `get_entry($form_id, $entry_id)`: Returns a specific entry.
  - `add_form_entry($form_id, $entry_meta)`: Adds a new entry.
  - `update_form_entry($form_id, $entry_id, $entry_meta)`: Updates entry meta.
- Entry meta is an array of field name/value pairs.
- Forminator does not natively support WP-CLI commands for form listing or export.

## 2. Person Registration Form Structure (ID: 364)
- Form name: Person Registration Form
- Used for: Candidate, Scout, Operator, Manager registration
- Key fields:
  - Prefix, First Name, Middle Name, Last Name (all required)
  - Email Address (required, with confirmation)
  - Phone (required)
  - Profile sharing method (LinkedIn or CV/Resume)
  - LinkedIn Profile (conditional)
  - CV/Resume upload (conditional)
  - Citizenship ID upload (required)
  - Residence ID upload (conditional)
  - Option to mark IDs as same
  - Consent (required)
  - CAPTCHA
- Field types: text, email, phone, checkbox, radio, upload, url, consent, captcha
- Conditional logic is used for LinkedIn/CV and residence ID fields.

## 3. API-based Form Inspection
- The form structure can be inspected using `Forminator_API::get_forms()` in PHP.
- Field details (slugs, types, labels, conditions) are available in the returned objects.
- Useful for programmatic validation, migration, or integration.

## 4. Documentation & Compliance
- Always document the exact form structure and field logic in the feature spec.
- Use lessons folder to track API limitations, integration patterns, and troubleshooting steps.
- Note: Forminator API is PHP-only; WP-CLI integration is not available by default.

---
_Last updated: January 17, 2026_