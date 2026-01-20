<?php
/**
 * Plugin Name: Forminator -> Custom Table Sync
 * Description: Syncs Forminator form submissions to td_user_data_change_requests table
 * Version: 1.0.0
 */
if (!defined('ABSPATH')) exit;

add_action('forminator_form_after_save_entry', 'td_forminator_to_custom_table', 10, 2);

function td_forminator_to_custom_table($form_id, $response) {
    // 1) Only run for Person Registration Form
    $target_form_id = 364;
    if ((int) $form_id !== (int) $target_form_id) {
        return;
    }

    // 2) Ensure submission succeeded
    if (!is_array($response) || empty($response['success'])) {
        return;
    }

    // 3) Get the entry_id - it's not always in response, so fetch latest entry for this form
    $entry_id = isset($response['entry_id']) ? absint($response['entry_id']) : 0;
    
    if (!$entry_id) {
        // Entry ID not in response, fetch the most recent entry for this form
        global $wpdb;
        $entry_id = $wpdb->get_var($wpdb->prepare(
            "SELECT entry_id FROM {$wpdb->prefix}frmt_form_entry 
             WHERE form_id = %d 
             ORDER BY date_created DESC, entry_id DESC 
             LIMIT 1",
            $form_id
        ));
        
        if (!$entry_id) {
            return;
        }
    }

    // 4) Fetch the entry via Forminator API
    if (!class_exists('Forminator_API')) {
        return;
    }

    $entry = Forminator_API::get_entry($form_id, $entry_id);
    if (empty($entry)) {
        return;
    }

    // 5) Extract submitted fields using Forminator's meta_data structure
    $meta = is_object($entry) && isset($entry->meta_data) ? $entry->meta_data : null;

    $first_name = td_forminator_meta_value($meta, 'name-1');
    $middle_name = td_forminator_meta_value($meta, 'name-2');
    $last_name = td_forminator_meta_value($meta, 'name-3');
    $email = td_forminator_meta_value($meta, 'email-1');
    $phone = td_forminator_meta_value($meta, 'phone-1');
    $checkbox = td_forminator_meta_value($meta, 'checkbox-1'); // "LinkedIn, CV / Resume file"
    $linkedin_url = td_forminator_meta_value($meta, 'url-2');
    $cv_upload = td_forminator_meta_value($meta, 'upload-1');
    $citizenship_upload = td_forminator_meta_value($meta, 'upload-2');
    $residence_upload = td_forminator_meta_value($meta, 'upload-3');
    $eu_resident = td_forminator_meta_value($meta, 'radio-1');
    $consent = td_forminator_meta_value($meta, 'consent-1');

    // Parse profile method from checkbox
    $has_linkedin = strpos($checkbox, 'LinkedIn') !== false;
    $has_cv = strpos($checkbox, 'CV / Resume file') !== false;
    $profile_method = $has_linkedin ? 'linkedin' : 'cv';
    
    // Extract file paths from upload data
    $cv_file_path = td_extract_file_path($cv_upload);
    $citizenship_file = td_extract_file_path($citizenship_upload);
    $residence_file = td_extract_file_path($residence_upload);

    // 6) Insert into custom table (aligned with exact table structure)
    global $wpdb;
    $table = 'td_user_data_change_requests'; // No prefix (matches table structure)

    $result = $wpdb->insert(
        $table,
        [
            // user_id - NULL for new registrations (will be set after approval)
            'user_id' => null,
            
            // Role and request type
            'role' => 'candidate', // Default for registration form (can be changed based on form field)
            'request_type' => 'register',
            
            // Name fields
            'prefix' => null, // TODO: Add prefix field to form (Mr./Ms./Dr.)
            'first_name' => $first_name,
            'middle_name' => $middle_name ?: null,
            'last_name' => $last_name,
            
            // Contact fields
            'email' => $email,
            'phone' => $phone,
            
            // Profile method
            'profile_method' => $profile_method,
            'has_linkedin' => $has_linkedin ? 1 : 0,
            'has_cv' => $has_cv ? 1 : 0,
            'linkedin_url' => $linkedin_url ?: null,
            'cv_file_path' => $cv_file_path ?: null,
            
            // ID documents
            'citizenship_id_file' => $citizenship_file,
            'residence_id_file' => $residence_file ?: null,
            'ids_are_same' => empty($residence_file) ? 1 : 0,
            
            // Consent and verification
            'consent' => ($consent === 'checked') ? 1 : 0,
            'captcha_passed' => 1, // Forminator handles captcha, if entry exists it passed
            
            // Status and assignment
            'status' => 'new',
            'assigned_to' => null, // Will be assigned by manager
            
            // Timestamps (submitted_date has default, updated_date auto-updates)
            'submitted_date' => current_time('mysql'),
        ],
        [
            '%d', // user_id
            '%s', '%s', // role, request_type
            '%s', '%s', '%s', '%s', // prefix, first_name, middle_name, last_name
            '%s', '%s', // email, phone
            '%s', '%d', '%d', '%s', '%s', // profile_method, has_linkedin, has_cv, linkedin_url, cv_file_path
            '%s', '%s', '%d', // citizenship_id_file, residence_id_file, ids_are_same
            '%d', '%d', // consent, captcha_passed
            '%s', '%d', // status, assigned_to
            '%s' // submitted_date
        ]
    );

    if ($result === false) {
        file_put_contents($log_file, "INSERT FAILED: " . $wpdb->last_error . "\n", FILE_APPEND);
            error_log('Forminator custom table insert failed: ' . $wpdb->last_error);
    } else {
        $new_id = $wpdb->insert_id;
    }
}

/**
 * Helper function to extract field value from Forminator meta_data
 * meta_data is an associative array where keys are field names
 */
function td_forminator_meta_value($meta, $field_key) {
    if (isset($meta[$field_key])) {
        $field_data = $meta[$field_key];
        
        // Extract value - it's in $field_data['value']
        if (is_array($field_data) && isset($field_data['value'])) {
            $value = $field_data['value'];
            
            // For upload fields, value is a nested array
            if (is_array($value)) {
                return $value; // Return raw array for upload fields
            }
            
            return (string)$value;
        }
    }
    
    return '';
}

function td_extract_file_path($field_value) {
    if (empty($field_value)) return null;
    
    // For upload fields from meta_data, structure is ['file' => ['file_path' => '...']]
    if (is_array($field_value) && isset($field_value['file']['file_path'])) {
        return $field_value['file']['file_path'];
    }
    
    return null;
}
