<?php
/*
Plugin Name: Forminator Upload Handler
Description: Moves Forminator file uploads to custom directories with per-form logic and custom naming.
Version: 1.0
Author: HireAccord
*/

if (!defined('ABSPATH')) exit;

add_action('forminator_custom_form_after_save_entry', function($entry_id, $form_id) {
    // Define per-form logic here
    $form_map = [
        // Example: 'FORM_ID' => ['field_id' => 'upload-1', 'dir' => '/uploads/people/'],
        364 => ['field_id' => 'upload-1', 'dir' => '/uploads/people/'], // Candidate Submission Form
        // Add more forms as needed
        // 400 => ['field_id' => 'upload-2', 'dir' => '/uploads/employers/'],
    ];

    if (!isset($form_map[$form_id])) {
        error_log("[Forminator Upload Handler] Form ID $form_id not in form_map");
        return;
    }
    $field_id = $form_map[$form_id]['field_id'];
    $custom_dir = WP_CONTENT_DIR . $form_map[$form_id]['dir'];
    $entry = Forminator_API::get_entry($entry_id, $form_id);
    if (!$entry) {
        error_log("[Forminator Upload Handler] No entry found for entry_id $entry_id, form_id $form_id");
        return;
    }
    $fields = $entry->get_fields();
    if (empty($fields[$field_id]['value'])) {
        error_log("[Forminator Upload Handler] Field $field_id empty for entry_id $entry_id");
        return;
    }
    $file_url = $fields[$field_id]['value'];
    $file_path = ABSPATH . str_replace(site_url() . '/', '', $file_url);
    if (!file_exists($custom_dir)) {
        if (!mkdir($custom_dir, 0755, true)) {
            error_log("[Forminator Upload Handler] Failed to create directory $custom_dir");
            return;
        }
    }
    $candidate_id = $entry->meta_data['candidateid']['value'] ?? 'unknown';
    $timestamp = time();
    $filename = basename($file_path);
    $new_filename = $candidate_id . '_' . $timestamp . '_' . $filename;
    $new_path = $custom_dir . $new_filename;
    if (!file_exists($file_path)) {
        error_log("[Forminator Upload Handler] Source file does not exist: $file_path");
        return;
    }
    if (!rename($file_path, $new_path)) {
        error_log("[Forminator Upload Handler] Failed to move $file_path to $new_path");
        return;
    }
    // Optionally update entry meta or send new file path in notifications

    // Environment-based notification logic
    if (defined('WP_ENVIRONMENT_TYPE') && WP_ENVIRONMENT_TYPE === 'production') {
        // Example: Send email notification (customize as needed)
        $to = $fields['email-1']['value'] ?? '';
        $subject = 'Thank you for your submission - CandidateID ' . $candidate_id;
        $message = "Hi " . ($fields['first_name-1']['value'] ?? '') . ",\n\n";
        $message .= "Thank you for sharing your profile with TalenDelight!\n\n";
        $message .= "Your submission has been received successfully.\nCandidate ID: $candidate_id\n\n";
        $message .= "What happens next:\n1. Our team will review your profile within 2-3 business days\n2. If there's a good match, we'll contact you at $to\n3. You can reference your Candidate ID in any communication with us\n\n";
        $message .= "Best regards,\nTalenDelight Team";
        if (!empty($to)) {
            $mail_result = wp_mail($to, $subject, $message, ['From: noreply@talendelight.com']);
            if (!$mail_result) {
                error_log("[Forminator Upload Handler] Failed to send email to $to");
            }
        } else {
            error_log("[Forminator Upload Handler] Email address empty for entry_id $entry_id");
        }
        // Add SMS logic here if needed
    } else {
        error_log("[Forminator Upload Handler] Skipping notifications (not production environment)");
    }
}, 10, 2);

// Optional: Add admin notice if plugin is active
add_action('admin_notices', function() {
    if (!is_plugin_active('forminator-upload-handler/forminator-upload-handler.php')) return;
    echo '<div class="notice notice-success"><p>Forminator Upload Handler plugin is active.</p></div>';
});
