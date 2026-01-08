<?php
/**
 * Plugin Name: TalenDelight Custom Roles
 * Plugin URI: https://talendelight.com
 * Description: Custom WordPress roles for TalenDelight recruitment platform (Employer, Candidate, Scout, Operator, Manager) with 403 access control
 * Version: 1.0.0
 * Author: TalenDelight
 * Author URI: https://talendelight.com
 * License: GPL v2 or later
 * Text Domain: talendelight-roles
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Register custom TalenDelight roles
 * Roles: Employer, Candidate, Scout, Operator, Manager
 * These coexist with default WordPress roles (administrator, editor, etc.)
 */
function talendelight_register_custom_roles() {
    // Only run once on activation
    if (get_option('talendelight_roles_registered')) {
        return;
    }

    // Employer role - can request candidates, view submissions
    add_role('td_employer', 'Employer', [
        'read' => true,
        'td_view_own_requests' => true,
        'td_request_candidates' => true,
        'td_view_request_status' => true,
    ]);

    // Candidate role - can view/update own profile
    add_role('td_candidate', 'Candidate', [
        'read' => true,
        'td_view_own_profile' => true,
        'td_update_own_profile' => true,
        'td_upload_cv' => true,
    ]);

    // Scout role - can submit candidates on behalf
    add_role('td_scout', 'Scout', [
        'read' => true,
        'td_submit_candidate' => true,
        'td_view_own_submissions' => true,
        'td_upload_candidate_cv' => true,
    ]);

    // Operator role - can manage submissions, candidates, employers
    add_role('td_operator', 'Operator', [
        'read' => true,
        'edit_posts' => true,
        'edit_pages' => true,
        'td_manage_submissions' => true,
        'td_manage_candidates' => true,
        'td_manage_employers' => true,
        'td_view_all_data' => true,
        'td_export_data' => true,
        'td_update_candidate_status' => true,
    ]);

    // Manager role - can oversee operations, reports, analytics
    add_role('td_manager', 'Manager', [
        'read' => true,
        'edit_posts' => true,
        'edit_pages' => true,
        'td_view_all_data' => true,
        'td_view_analytics' => true,
        'td_view_reports' => true,
        'td_manage_operators' => true,
        'td_export_data' => true,
    ]);

    update_option('talendelight_roles_registered', true);
    
    // Log role creation
    error_log('TalenDelight: Custom roles registered successfully');
}
add_action('after_setup_theme', 'talendelight_register_custom_roles');

/**
 * 403 Access Control: Block logged-in users without TalenDelight roles
 * Allows default WordPress roles (administrator, editor, author) to pass through
 */
function talendelight_enforce_custom_roles() {
    // Skip if not logged in
    if (!is_user_logged_in()) {
        return;
    }

    // Skip for admin area
    if (is_admin()) {
        return;
    }

    // Skip for AJAX requests
    if (wp_doing_ajax()) {
        return;
    }

    // Skip for REST API requests
    if (defined('REST_REQUEST') && REST_REQUEST) {
        return;
    }

    // Skip for 403 forbidden page itself (avoid redirect loops)
    if (is_page('403-forbidden')) {
        return;
    }

    // Get current user
    $user = wp_get_current_user();

    // Define allowed roles - Only TalenDelight custom roles + administrator
    $allowed_roles = ['td_employer', 'td_candidate', 'td_scout', 'td_operator', 'td_manager', 'administrator'];

    // Check if user has at least one allowed role
    $has_allowed_role = false;
    foreach ($user->roles as $role) {
        if (in_array($role, $allowed_roles)) {
            $has_allowed_role = true;
            break;
        }
    }

    // If no allowed role, show 403
    if (!$has_allowed_role) {
        // Check if custom 403 page exists
        $forbidden_page = get_page_by_path('403-forbidden');
        
        if ($forbidden_page) {
            wp_redirect(home_url('/403-forbidden/'));
            exit;
        } else {
            // Fallback to styled wp_die
            wp_die(
                '<div style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; max-width: 600px; margin: 100px auto; padding: 40px; text-align: center; background: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <h1 style="color: #dc3545; font-size: 48px; margin-bottom: 20px;">Access Restricted</h1>
                    <p style="font-size: 18px; color: #6c757d; margin-bottom: 30px;">Your account does not have permission to access this platform.</p>
                    <p style="font-size: 16px; color: #495057; margin-bottom: 30px;">If you believe this is an error or need assistance, please contact our support team.</p>
                    <div style="margin: 30px 0;">
                        <a href="' . home_url() . '" style="display: inline-block; background: #0066cc; color: white; padding: 12px 30px; text-decoration: none; border-radius: 4px; font-weight: 600; margin-right: 10px;">Go to Home Page</a>
                        <a href="' . wp_logout_url(home_url()) . '" style="display: inline-block; background: #6c757d; color: white; padding: 12px 30px; text-decoration: none; border-radius: 4px; font-weight: 600;">Log Out</a>
                    </div>
                    <p style="font-size: 14px; color: #6c757d; margin-top: 40px;">Need help? Email <a href="mailto:support@talendelight.com" style="color: #0066cc;">support@talendelight.com</a></p>
                </div>',
                'Access Restricted - TalenDelight',
                ['response' => 403]
            );
        }
    }
}
add_action('template_redirect', 'talendelight_enforce_custom_roles');

/**
 * Role-based login redirect
 * Routes users to appropriate landing page based on TalenDelight role
 */
function talendelight_role_based_login_redirect($redirect_to, $request, $user) {
    // Check if user object exists and has roles
    if (!isset($user->roles) || !is_array($user->roles)) {
        error_log('TalenDelight Login Redirect: No user roles found');
        return $redirect_to;
    }

    error_log('TalenDelight Login Redirect: User ' . $user->user_login . ' has roles: ' . implode(', ', $user->roles));

    // Check if user has any allowed role
    $allowed_roles = ['td_employer', 'td_candidate', 'td_scout', 'td_operator', 'td_manager', 'administrator'];
    $has_allowed_role = false;
    foreach ($user->roles as $role) {
        if (in_array($role, $allowed_roles)) {
            $has_allowed_role = true;
            break;
        }
    }
    
    // If no allowed role, redirect to forbidden page
    if (!$has_allowed_role) {
        $forbidden_page = get_page_by_path('403-forbidden');
        $redirect_url = $forbidden_page ? home_url('/403-forbidden/') : home_url();
        error_log('TalenDelight Login Redirect: No allowed role, redirecting to ' . $redirect_url);
        return $redirect_url;
    }

    // Role-based redirect priority (first match wins)
    if (in_array('administrator', $user->roles)) {
        error_log('TalenDelight Login Redirect: Administrator -> /wp-admin/');
        return admin_url();
    } elseif (in_array('td_manager', $user->roles)) {
        // Future: Manager dashboard
        $manager_page = get_page_by_path('managers');
        return $manager_page ? home_url('/managers/') : home_url('/account/');
    } elseif (in_array('td_operator', $user->roles)) {
        // Future: Operator dashboard
        $operator_page = get_page_by_path('operators');
        return $operator_page ? home_url('/operators/') : home_url('/account/');
    } elseif (in_array('td_employer', $user->roles)) {
        // WP-01.2 Employers page
        $employers_page = get_page_by_path('employers');
        $redirect_url = $employers_page ? home_url('/employers/') : home_url('/account/');
        error_log('TalenDelight Login Redirect: Employer -> ' . $redirect_url . ' (page found: ' . ($employers_page ? 'yes' : 'no') . ')');
        return $redirect_url;
    } elseif (in_array('td_candidate', $user->roles)) {
        // WP-01.3 Candidates page (future)
        $candidates_page = get_page_by_path('candidates');
        return $candidates_page ? home_url('/candidates/') : home_url('/account/');
    } elseif (in_array('td_scout', $user->roles)) {
        // WP-03 Scout page (future)
        $scout_page = get_page_by_path('scouts');
        return $scout_page ? home_url('/scouts/') : home_url('/account/');
    }

    // Default: WP User Manager account page
    return home_url('/account/');
}
add_filter('login_redirect', 'talendelight_role_based_login_redirect', 100, 3);

// Also hook into WP User Manager specific filter (if available)
add_filter('wpum_login_redirect', 'talendelight_role_based_login_redirect', 100, 3);

/**
 * WP User Manager post-login redirect
 * This handles WPUM's custom login form which doesn't use standard WordPress login_redirect
 */
function talendelight_wpum_after_login($user_id, $user_data) {
    error_log('TalenDelight WPUM After Login: User ID ' . $user_id);
    
    $user = get_userdata($user_id);
    if (!$user || !isset($user->roles) || !is_array($user->roles)) {
        error_log('TalenDelight WPUM: No user roles found');
        return;
    }
    
    error_log('TalenDelight WPUM: User ' . $user->user_login . ' has roles: ' . implode(', ', $user->roles));
    
    // Check if user has any allowed role
    $allowed_roles = ['td_employer', 'td_candidate', 'td_scout', 'td_operator', 'td_manager', 'administrator'];
    $has_allowed_role = false;
    foreach ($user->roles as $role) {
        if (in_array($role, $allowed_roles)) {
            $has_allowed_role = true;
            break;
        }
    }
    
    // If no allowed role, redirect to forbidden page
    if (!$has_allowed_role) {
        $forbidden_page = get_page_by_path('403-forbidden');
        $redirect_url = $forbidden_page ? home_url('/403-forbidden/') : home_url();
        error_log('TalenDelight WPUM: No allowed role, redirecting to ' . $redirect_url);
        wp_redirect($redirect_url);
        exit;
    }
    
    // Role-based redirect
    if (in_array('administrator', $user->roles)) {
        error_log('TalenDelight WPUM: Administrator -> /wp-admin/');
        wp_redirect(admin_url());
        exit;
    } elseif (in_array('td_manager', $user->roles)) {
        $manager_page = get_page_by_path('managers');
        $redirect_url = $manager_page ? home_url('/managers/') : home_url('/account/');
        error_log('TalenDelight WPUM: Manager -> ' . $redirect_url);
        wp_redirect($redirect_url);
        exit;
    } elseif (in_array('td_operator', $user->roles)) {
        $operator_page = get_page_by_path('operators');
        $redirect_url = $operator_page ? home_url('/operators/') : home_url('/account/');
        error_log('TalenDelight WPUM: Operator -> ' . $redirect_url);
        wp_redirect($redirect_url);
        exit;
    } elseif (in_array('td_employer', $user->roles)) {
        $employers_page = get_page_by_path('employers');
        $redirect_url = $employers_page ? home_url('/employers/') : home_url('/account/');
        error_log('TalenDelight WPUM: Employer -> ' . $redirect_url . ' (page found: ' . ($employers_page ? 'yes' : 'no') . ')');
        wp_redirect($redirect_url);
        exit;
    } elseif (in_array('td_candidate', $user->roles)) {
        $candidates_page = get_page_by_path('candidates');
        $redirect_url = $candidates_page ? home_url('/candidates/') : home_url('/account/');
        error_log('TalenDelight WPUM: Candidate -> ' . $redirect_url);
        wp_redirect($redirect_url);
        exit;
    } elseif (in_array('td_scout', $user->roles)) {
        $scout_page = get_page_by_path('scouts');
        $redirect_url = $scout_page ? home_url('/scouts/') : home_url('/account/');
        error_log('TalenDelight WPUM: Scout -> ' . $redirect_url);
        wp_redirect($redirect_url);
        exit;
    }
    
    // Default fallback
    error_log('TalenDelight WPUM: Default fallback -> /account/');
    wp_redirect(home_url('/account/'));
    exit;
}
add_action('wpum_after_login', 'talendelight_wpum_after_login', 10, 2);

/**
 * Redirect from /account/ page to role-specific page
 * This handles cases where WPUM redirects to /account/ after login
 */
function talendelight_redirect_from_account_page() {
    // Only run on /account/ page
    if (!is_page('account')) {
        return;
    }
    
    // Only for logged-in users
    if (!is_user_logged_in()) {
        return;
    }
    
    $user = wp_get_current_user();
    
    // Check if user has any allowed role
    $allowed_roles = ['td_employer', 'td_candidate', 'td_scout', 'td_operator', 'td_manager', 'administrator'];
    $has_allowed_role = false;
    foreach ($user->roles as $role) {
        if (in_array($role, $allowed_roles)) {
            $has_allowed_role = true;
            break;
        }
    }
    
    // If no allowed role, redirect to forbidden page
    if (!$has_allowed_role) {
        $forbidden_page = get_page_by_path('403-forbidden');
        wp_redirect($forbidden_page ? home_url('/403-forbidden/') : home_url());
        exit;
    }
    
    // Check role and redirect
    if (in_array('administrator', $user->roles)) {
        wp_redirect(admin_url());
        exit;
    } elseif (in_array('td_manager', $user->roles)) {
        $manager_page = get_page_by_path('managers');
        if ($manager_page) {
            wp_redirect(home_url('/managers/'));
            exit;
        }
    } elseif (in_array('td_operator', $user->roles)) {
        $operator_page = get_page_by_path('operators');
        if ($operator_page) {
            wp_redirect(home_url('/operators/'));
            exit;
        }
    } elseif (in_array('td_employer', $user->roles)) {
        $employers_page = get_page_by_path('employers');
        if ($employers_page) {
            wp_redirect(home_url('/employers/'));
            exit;
        }
    } elseif (in_array('td_candidate', $user->roles)) {
        $candidates_page = get_page_by_path('candidates');
        if ($candidates_page) {
            wp_redirect(home_url('/candidates/'));
            exit;
        }
    } elseif (in_array('td_scout', $user->roles)) {
        $scout_page = get_page_by_path('scouts');
        if ($scout_page) {
            wp_redirect(home_url('/scouts/'));
            exit;
        }
    }
    
    // If no role-specific page exists, stay on /account/
}
add_action('template_redirect', 'talendelight_redirect_from_account_page');

/**
 * Plugin activation hook
 */
function talendelight_roles_activate() {
    // Force role registration on activation
    delete_option('talendelight_roles_registered');
    talendelight_register_custom_roles();
    
    // Flush rewrite rules
    flush_rewrite_rules();
}
register_activation_hook(__FILE__, 'talendelight_roles_activate');

/**
 * Plugin deactivation hook
 */
function talendelight_roles_deactivate() {
    // Note: Roles are NOT removed on deactivation to preserve user assignments
    // To remove roles, manually run: remove_role('td_employer'), etc.
    
    flush_rewrite_rules();
}
register_deactivation_hook(__FILE__, 'talendelight_roles_deactivate');

/**
 * Add custom capabilities to administrator role
 * Administrators should have all custom capabilities
 */
function talendelight_add_admin_capabilities() {
    $admin_role = get_role('administrator');
    
    if ($admin_role) {
        $custom_caps = [
            'td_view_own_requests', 'td_request_candidates', 'td_view_request_status',
            'td_view_own_profile', 'td_update_own_profile', 'td_upload_cv',
            'td_submit_candidate', 'td_view_own_submissions', 'td_upload_candidate_cv',
            'td_manage_submissions', 'td_manage_candidates', 'td_manage_employers',
            'td_view_all_data', 'td_export_data', 'td_update_candidate_status',
            'td_view_analytics', 'td_view_reports', 'td_manage_operators',
        ];
        
        foreach ($custom_caps as $cap) {
            $admin_role->add_cap($cap);
        }
    }
}
add_action('admin_init', 'talendelight_add_admin_capabilities');
