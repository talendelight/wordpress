# Forminator Upload Handler Plugin

Moves Forminator file uploads to custom directories with per-form logic and custom naming.

## Features
- Per-form configuration: set different upload directories and field IDs for each Forminator form
- Custom file naming: includes CandidateID and timestamp
- Easy to extend for more forms and fields
- No changes required to Forminator UI

## Data Storage & Approval Workflow

### Where Forminator Stores Submissions
- Forminator does NOT create WordPress users by default.
- All form submissions are stored in custom database tables:
  - `wp_frmt_form_entry` — each row is a form submission (entry)
  - `wp_frmt_form_entry_meta` — stores field values for each entry
- No data is written to `wp_users` or `wp_usermeta` unless you add custom code or use a user registration plugin.

### Staging Area & Approval
- These tables act as a "staging area" for candidate data.
- Actual WordPress users should be created (in `wp_users`/`wp_usermeta`) only after manager approval.
- This keeps your user base clean and supports a robust approval workflow.

### Approval Process (Future Implementation)
- Review candidate entries in Forminator submissions (admin panel or via custom UI).
- On manager approval, programmatically create a WordPress user from the entry data.
- Move or flag the entry as "approved" to avoid duplicate processing.

1. Place this plugin folder in `wp-content/plugins/forminator-upload-handler/`
2. Activate the plugin in WordPress admin
3. Edit `forminator-upload-handler.php` to configure `$form_map` for your forms:
   - Example:
     ```php
     $form_map = [
         364 => ['field_id' => 'upload-1', 'dir' => '/uploads/people/'],
         400 => ['field_id' => 'upload-2', 'dir' => '/uploads/employers/'],
     ];
     ```
4. The plugin will move uploaded files after submission to your specified directory

## Environment-based Notifications
- Use `WP_ENVIRONMENT_TYPE` in your custom notification code to enable/disable emails/SMS in production vs local/dev

## Troubleshooting
- Ensure correct form and field IDs
- Check file/folder permissions
- Review PHP error logs if files are not moved

## Author
HireAccord

## License
MIT
