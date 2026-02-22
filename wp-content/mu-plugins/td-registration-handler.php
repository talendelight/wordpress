<?php
/**
 * Plugin Name: TalenDelight Registration Handler
 * Description: Handles custom registration form submissions - creates change requests, not WordPress users
 * Version: 2.1.0
 * 
 * IMPORTANT WORKFLOW NOTES:
 * - Registration creates records in td_user_data_change_requests table (status: 'new')
 * - Manager approval changes status to 'approved' but does NOT create WordPress users
 * - User account creation (WordPress or external system) is a SEPARATE process outside this handler
 * - See WORDPRESS-BACKLOG.md -> Epic WP-09.5 for external user provisioning
 */

// Register shortcode to generate nonce (since PHP in post_content doesn't execute)
add_shortcode('td_registration_nonce', function() {
    return wp_create_nonce('td_registration_form');
});

// AJAX endpoint to get nonce (for JavaScript to fetch on page load)
add_action('wp_ajax_td_get_registration_nonce', 'td_get_registration_nonce');
add_action('wp_ajax_nopriv_td_get_registration_nonce', 'td_get_registration_nonce');
function td_get_registration_nonce() {
    wp_send_json_success([
        'nonce' => wp_create_nonce('td_registration_form')
    ]);
}

// Enable shortcode processing in HTML blocks (Gutenberg)
add_filter('the_content', 'do_shortcode', 11);

add_action('wp_ajax_td_process_registration', 'td_process_registration');
add_action('wp_ajax_nopriv_td_process_registration', 'td_process_registration');

function td_process_registration() {
    global $wpdb;
    
    // Debug logging
    error_log('=== Registration Form Submission Debug ===');
    error_log('Nonce received: ' . (isset($_POST['td_registration_nonce']) ? $_POST['td_registration_nonce'] : 'NOT SET'));
    error_log('Nonce verification: ' . (isset($_POST['td_registration_nonce']) && wp_verify_nonce($_POST['td_registration_nonce'], 'td_registration_form') ? 'VALID' : 'INVALID'));
    
    // Verify nonce
    if (!isset($_POST['td_registration_nonce']) || !wp_verify_nonce($_POST['td_registration_nonce'], 'td_registration_form')) {
        error_log('Security verification failed - sending error response');
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
    
    // Check if email already exists in change requests (pending/approved)
    $existing = $wpdb->get_var($wpdb->prepare(
        "SELECT id FROM {$wpdb->prefix}td_user_data_change_requests 
         WHERE email = %s AND status IN ('new', 'pending', 'approved')
         LIMIT 1",
        $email
    ));
    
    if ($existing) {
        wp_send_json_error(['message' => 'A registration with this email is already being processed or has been approved.']);
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
    
    // Validate National ID (Citizenship) - required
    if (!isset($_FILES['national_id_citizenship']) || $_FILES['national_id_citizenship']['size'] == 0) {
        wp_send_json_error(['message' => 'National ID (Citizenship) is required.']);
        return;
    }
    
    // Prepare data
    $first_name = sanitize_text_field($_POST['first_name']);
    $middle_name = sanitize_text_field($_POST['middle_name'] ?? '');
    $last_name = sanitize_text_field($_POST['last_name']);
    $phone = sanitize_text_field($_POST['phone']);
    $role = sanitize_text_field($_POST['td_user_role']); // td_candidate, td_employer, etc.
    $prefix = sanitize_text_field($_POST['prefix'] ?? '');
    
    // Determine profile method
    $profile_method = $has_linkedin ? 'linkedin' : 'cv';
    
    // Handle file uploads to registration staging directory
    require_once(ABSPATH . 'wp-admin/includes/file.php');
    
    $upload_dir = wp_upload_dir();
    $registration_dir = $upload_dir['basedir'] . '/register';
    
    // Create directory if not exists
    if (!file_exists($registration_dir)) {
        wp_mkdir_p($registration_dir);
        // Protect with .htaccess to prevent direct access
        file_put_contents($registration_dir . '/.htaccess', "deny from all\n");
    }
    
    $upload_errors = [];
    $cv_file_path = null;
    $linkedin_url = null;
    $citizenship_id_file = null;
    $residence_id_file = null;
    $ids_are_same = isset($_POST['live_in_citizenship_country']) && $_POST['live_in_citizenship_country'] === 'yes' ? 1 : 0;
    
    // Generate request ID FIRST (will be used in filenames)
    $request_id = td_generate_request_id();
    
    // Upload CV if provided
    if ($has_cv) {
        $cv_upload = $_FILES['cv_file'];
        $cv_filename = sanitize_file_name($request_id . '_cv_' . $cv_upload['name']);
        $cv_destination = $registration_dir . '/' . $cv_filename;
        
        if (move_uploaded_file($cv_upload['tmp_name'], $cv_destination)) {
            $cv_file_path = '/wp-content/uploads/register/' . $cv_filename;
        } else {
            $upload_errors[] = 'CV upload failed';
        }
    }
    
    // Save LinkedIn URL if provided
    if ($has_linkedin && !empty($_POST['linkedin_url'])) {
        $linkedin_url = esc_url_raw($_POST['linkedin_url']);
    }
    
    // Upload National ID (Citizenship) - required
    $nid_citizenship = $_FILES['national_id_citizenship'];
    $nid_citizenship_filename = sanitize_file_name($request_id . '_citizenship_' . $nid_citizenship['name']);
    $nid_citizenship_destination = $registration_dir . '/' . $nid_citizenship_filename;
    
    if (move_uploaded_file($nid_citizenship['tmp_name'], $nid_citizenship_destination)) {
        $citizenship_id_file = '/wp-content/uploads/register/' . $nid_citizenship_filename;
    } else {
        $upload_errors[] = 'National ID (Citizenship) upload failed';
        wp_send_json_error(['message' => 'Required file upload failed. Please try again.']);
        return;
    }
    
    // Upload National ID (Residence) if provided
    if (!$ids_are_same && isset($_FILES['national_id_residence']) && $_FILES['national_id_residence']['size'] > 0) {
        $nid_residence = $_FILES['national_id_residence'];
        $nid_residence_filename = sanitize_file_name($request_id . '_residence_' . $nid_residence['name']);
        $nid_residence_destination = $registration_dir . '/' . $nid_residence_filename;
        
        if (move_uploaded_file($nid_residence['tmp_name'], $nid_residence_destination)) {
            $residence_id_file = '/wp-content/uploads/register/' . $nid_residence_filename;
        } else {
            $upload_errors[] = 'National ID (Residence) upload failed';
        }
    }
    
    // Insert into td_user_data_change_requests
    $insert_data = [
        'request_id' => $request_id,
        'record_id' => null, // Assigned after approval
        'user_id' => null, // No WordPress user exists yet
        'role' => str_replace('td_', '', $role), // Store as 'candidate', 'employer', etc.
        'request_type' => 'register',
        'prefix' => $prefix,
        'first_name' => $first_name,
        'middle_name' => $middle_name,
        'last_name' => $last_name,
        'email' => $email,
        'phone' => $phone,
        'profile_method' => $profile_method,
        'has_linkedin' => $has_linkedin ? 1 : 0,
        'has_cv' => $has_cv ? 1 : 0,
        'linkedin_url' => $linkedin_url,
        'cv_file_path' => $cv_file_path,
        'citizenship_id_file' => $citizenship_id_file,
        'residence_id_file' => $residence_id_file,
        'ids_are_same' => $ids_are_same,
        'consent' => 1,
        'captcha_passed' => 1, // Assuming client-side validation passed
        'status' => 'new',
        'submitted_date' => current_time('mysql')
    ];
    
    $result = $wpdb->insert($wpdb->prefix . 'td_user_data_change_requests', $insert_data);
    
    if ($result === false) {
        error_log("Registration insert failed: " . $wpdb->last_error);
        wp_send_json_error(['message' => 'Registration submission failed. Please try again.']);
        return;
    }
    
    $request_db_id = $wpdb->insert_id;
    
    // Send notification emails (TODO: implement email templates)
    // 1. Confirmation email to user
    // 2. Notification email to manager/operator
    
    // Log the registration
    error_log("New registration request: ID $request_db_id, Request ID: $request_id, Email: $email, Role: $role, Status: new");
    
    $response_message = 'Registration submitted successfully! Your request is being reviewed. You will receive an email notification once your account is processed.';
    
    if (!empty($upload_errors)) {
        $response_message .= ' Note: Some file uploads encountered issues: ' . implode(', ', $upload_errors);
    }
    
    wp_send_json_success([
        'message' => $response_message,
        'request_id' => $request_id,
        'status' => 'new'
    ]);
}
