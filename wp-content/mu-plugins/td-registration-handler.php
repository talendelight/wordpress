<?php
/**
 * Plugin Name: TalenDelight Registration Handler
 * Description: Handles custom registration form submissions
 * Version: 1.0.0
 */

add_action('wp_ajax_td_process_registration', 'td_process_registration');
add_action('wp_ajax_nopriv_td_process_registration', 'td_process_registration');

function td_process_registration() {
    // Verify nonce
    if (!isset($_POST['td_registration_nonce']) || !wp_verify_nonce($_POST['td_registration_nonce'], 'td_registration_form')) {
        wp_send_json_error(['message' => 'Security verification failed.']);
        return;
    }
    
    // Validate required fields
    $required_fields = ['first_name', 'last_name', 'email', 'phone', 'td_user_role'];
    foreach ($required_fields as $field) {
        if (empty($_POST[$field])) {
            wp_send_json_error(['message' => "Required field missing: $field"]);
            return;
        }
    }
    
    // Validate email
    $email = sanitize_email($_POST['email']);
    if (!is_email($email)) {
        wp_send_json_error(['message' => 'Invalid email address.']);
        return;
    }
    
    // Check if email already exists
    if (email_exists($email)) {
        wp_send_json_error(['message' => 'An account with this email already exists.']);
        return;
    }
    
    // Validate LinkedIn OR CV requirement
    $has_linkedin = isset($_POST['has_linkedin']) && $_POST['has_linkedin'] === 'on';
    $has_cv = isset($_FILES['cv_file']) && $_FILES['cv_file']['size'] > 0;
    
    if (!$has_linkedin && !$has_cv) {
        wp_send_json_error(['message' => 'Please provide either your LinkedIn profile or upload your CV.']);
        return;
    }
    
    // Validate consent
    if (!isset($_POST['consent']) || $_POST['consent'] !== 'on') {
        wp_send_json_error(['message' => 'You must agree to the Privacy Policy and Terms & Conditions.']);
        return;
    }
    
    // Prepare user data
    $first_name = sanitize_text_field($_POST['first_name']);
    $middle_name = sanitize_text_field($_POST['middle_name'] ?? '');
    $last_name = sanitize_text_field($_POST['last_name']);
    $phone = sanitize_text_field($_POST['phone']);
    $role = sanitize_text_field($_POST['td_user_role']);
    
    $display_name = trim("$first_name $middle_name $last_name");
    $username = strtolower(str_replace(' ', '_', $display_name)) . '_' . rand(1000, 9999);
    
    // Create user with pending status
    $user_data = [
        'user_login' => $username,
        'user_email' => $email,
        'first_name' => $first_name,
        'last_name' => $last_name,
        'display_name' => $display_name,
        'role' => $role, // Will be td_candidate, td_employer, etc.
        'user_pass' => wp_generate_password(16, true, true)
    ];
    
    $user_id = wp_insert_user($user_data);
    
    if (is_wp_error($user_id)) {
        wp_send_json_error(['message' => 'Failed to create user: ' . $user_id->get_error_message()]);
        return;
    }
    
    // Save additional meta data
    update_user_meta($user_id, 'td_middle_name', $middle_name);
    update_user_meta($user_id, 'td_phone', $phone);
    update_user_meta($user_id, 'td_registration_status', 'pending'); // pending, approved, rejected
    update_user_meta($user_id, 'td_registration_date', current_time('mysql'));
    
    // Save LinkedIn if provided
    if ($has_linkedin && !empty($_POST['linkedin_url'])) {
        $linkedin_url = esc_url_raw($_POST['linkedin_url']);
        update_user_meta($user_id, 'td_linkedin_url', $linkedin_url);
    }
    
    // Save residence status
    if (isset($_POST['live_in_citizenship_country'])) {
        $lives_in_citizenship = sanitize_text_field($_POST['live_in_citizenship_country']);
        update_user_meta($user_id, 'td_lives_in_citizenship_country', $lives_in_citizenship);
    }
    
    // Handle file uploads
    require_once(ABSPATH . 'wp-admin/includes/file.php');
    require_once(ABSPATH . 'wp-admin/includes/image.php');
    require_once(ABSPATH . 'wp-admin/includes/media.php');
    
    $upload_errors = [];
    
    // Upload CV if provided
    if ($has_cv) {
        $cv_id = media_handle_upload('cv_file', 0);
        if (is_wp_error($cv_id)) {
            $upload_errors[] = 'CV upload failed: ' . $cv_id->get_error_message();
        } else {
            update_user_meta($user_id, 'td_cv_attachment_id', $cv_id);
        }
    }
    
    // Upload National ID (Citizenship) - required
    if (isset($_FILES['national_id_citizenship']) && $_FILES['national_id_citizenship']['size'] > 0) {
        $nid_citizenship_id = media_handle_upload('national_id_citizenship', 0);
        if (is_wp_error($nid_citizenship_id)) {
            $upload_errors[] = 'National ID (Citizenship) upload failed: ' . $nid_citizenship_id->get_error_message();
        } else {
            update_user_meta($user_id, 'td_national_id_citizenship_attachment_id', $nid_citizenship_id);
        }
    }
    
    // Upload National ID (Residence) if provided
    if (isset($_FILES['national_id_residence']) && $_FILES['national_id_residence']['size'] > 0) {
        $nid_residence_id = media_handle_upload('national_id_residence', 0);
        if (is_wp_error($nid_residence_id)) {
            $upload_errors[] = 'National ID (Residence) upload failed: ' . $nid_residence_id->get_error_message();
        } else {
            update_user_meta($user_id, 'td_national_id_residence_attachment_id', $nid_residence_id);
        }
    }
    
    // Send notification emails (TODO: implement email templates)
    // 1. Confirmation email to user
    // 2. Notification email to admin/operator
    
    // Log the registration
    error_log("New registration: User ID $user_id, Email: $email, Role: $role, Status: pending");
    
    $response_message = 'Registration submitted successfully! Your account is pending approval. You will receive an email notification once your account is reviewed.';
    
    if (!empty($upload_errors)) {
        $response_message .= ' Note: Some file uploads encountered issues: ' . implode(', ', $upload_errors);
    }
    
    wp_send_json_success([
        'message' => $response_message,
        'user_id' => $user_id,
        'status' => 'pending'
    ]);
}
