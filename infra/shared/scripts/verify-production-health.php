<?php
/**
 * Production Health Check Script
 * 
 * Verifies critical components exist and are properly configured on production
 * 
 * Usage:
 *   wp eval-file verify-production-health.php
 *   wp eval-file verify-production-health.php --verbose
 * 
 * Exit codes:
 *   0 = All checks passed
 *   1 = One or more checks failed
 */

$verbose = in_array('--verbose', $argv);
$failed_checks = [];
$passed_checks = [];

function check($name, $condition, $success_msg, $failure_msg, &$passed, &$failed, $verbose) {
    if ($condition) {
        $passed[] = $name;
        if ($verbose) {
            echo "âœ… {$name}: {$success_msg}\n";
        }
        return true;
    } else {
        $failed[] = $name;
        echo "âŒ {$name}: {$failure_msg}\n";
        return false;
    }
}

echo "=== Production Health Check ===\n";
echo "Time: " . date('Y-m-d H:i:s') . "\n\n";

// ============================================================================
// 1. REQUIRED PAGES
// ============================================================================
echo "--- Required Pages ---\n";

$required_pages = [
    'welcome' => 'Welcome (landing page)',
    'employers' => 'Employers (role landing)',
    'candidates' => 'Candidates (role landing)',
    'scouts' => 'Scouts (role landing)',
    'managers' => 'Managers (role landing)',
    'operators' => 'Operators (role landing)',
    'help' => 'Help page',
    'log-in' => 'Login page (WPUM)',
    'register' => 'Registration page (WPUM)',
    'account' => 'Account page (WPUM)',
];

foreach ($required_pages as $slug => $description) {
    $page = get_page_by_path($slug);
    check(
        "Page: {$slug}",
        $page && $page->post_status === 'publish',
        "{$description} exists (ID: {$page->ID})",
        "{$description} missing or not published",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// 2. REQUIRED PLUGINS
// ============================================================================
echo "\n--- Required Plugins ---\n";

$required_plugins = [
    'talendelight-roles/talendelight-roles.php' => 'TalenDelight Custom Roles',
    'wp-user-manager/wp-user-manager.php' => 'WP User Manager',
    'blocksy-companion/blocksy-companion.php' => 'Blocksy Companion',
];

foreach ($required_plugins as $plugin_file => $plugin_name) {
    check(
        "Plugin: {$plugin_name}",
        is_plugin_active($plugin_file),
        "Active",
        "Inactive or missing",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// 3. REQUIRED MU-PLUGINS
// ============================================================================
echo "\n--- Required MU-Plugins ---\n";

$required_mu_plugins = [
    'td-api-security.php' => 'API Security',
    'td-env-config.php' => 'Environment Config',
    'record-id-generator.php' => 'Record ID Generator',
];

$mu_plugins = get_mu_plugins();
foreach ($required_mu_plugins as $file => $name) {
    check(
        "MU-Plugin: {$name}",
        isset($mu_plugins[$file]),
        "Loaded",
        "Missing from mu-plugins directory",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// 4. CUSTOM ROLES
// ============================================================================
echo "\n--- Custom Roles ---\n";

$required_roles = [
    'td_candidate' => 'Candidate',
    'td_employer' => 'Employer',
    'td_scout' => 'Scout',
    'td_operator' => 'Operator',
    'td_manager' => 'Manager',
];

foreach ($required_roles as $role_slug => $role_name) {
    $role = get_role($role_slug);
    check(
        "Role: {$role_name}",
        $role !== null,
        "Exists",
        "Missing (plugin may be inactive)",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// 5. MENUS
// ============================================================================
echo "\n--- Navigation Menus ---\n";

$primary_menu = wp_get_nav_menu_object('Primary Menu');
check(
    "Primary Menu",
    $primary_menu !== false,
    "Exists (ID: {$primary_menu->term_id})",
    "Missing",
    $passed_checks,
    $failed_checks,
    $verbose
);

if ($primary_menu) {
    $menu_items = wp_get_nav_menu_items($primary_menu->term_id);
    $item_count = count($menu_items);
    check(
        "Primary Menu Items",
        $item_count >= 7,
        "{$item_count} items configured",
        "Only {$item_count} items (expected 7+)",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

$locations = get_theme_mod('nav_menu_locations');
check(
    "Menu Locations",
    !empty($locations),
    count($locations) . " locations configured",
    "No menu locations assigned",
    $passed_checks,
    $failed_checks,
    $verbose
);

// ============================================================================
// 6. DATABASE TABLES
// ============================================================================
echo "\n--- Database Tables ---\n";

global $wpdb;

$required_tables = [
    'td_user_data_change_requests' => 'User data change requests',
    'td_audit_log' => 'Audit log',
    'td_id_sequences' => 'ID sequence generator',
];

foreach ($required_tables as $table_name => $description) {
    $full_table_name = $wpdb->prefix . $table_name;
    // Note: td_id_sequences doesn't have wp_ prefix
    if ($table_name === 'td_id_sequences') {
        $full_table_name = $table_name;
    }
    
    $exists = $wpdb->get_var("SHOW TABLES LIKE '{$full_table_name}'") === $full_table_name;
    check(
        "Table: {$table_name}",
        $exists,
        "{$description}",
        "Missing (migration may not be applied)",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// 7. CRITICAL CONFIGURATIONS
// ============================================================================
echo "\n--- Critical Configurations ---\n";

// Permalink structure
$permalink_structure = get_option('permalink_structure');
check(
    "Permalinks",
    !empty($permalink_structure),
    "Custom permalinks enabled: {$permalink_structure}",
    "Using default permalinks (should be custom)",
    $passed_checks,
    $failed_checks,
    $verbose
);

// Active theme
$theme = wp_get_theme();
check(
    "Theme",
    $theme->get('Name') === 'Blocksy Child',
    "Blocksy Child active (v{$theme->get('Version')})",
    "Wrong theme: {$theme->get('Name')}",
    $passed_checks,
    $failed_checks,
    $verbose
);

// XML-RPC disabled (security)
check(
    "XML-RPC Security",
    !apply_filters('xmlrpc_enabled', true),
    "XML-RPC disabled (secure)",
    "XML-RPC enabled (security risk)",
    $passed_checks,
    $failed_checks,
    $verbose
);

// File editing disabled
check(
    "File Editing",
    defined('DISALLOW_FILE_EDIT') && DISALLOW_FILE_EDIT === true,
    "File editing disabled (secure)",
    "File editing allowed (security risk)",
    $passed_checks,
    $failed_checks,
    $verbose
);

// ============================================================================
// 8. ENVIRONMENT CONSTANTS
// ============================================================================
echo "\n--- Environment Constants ---\n";

$required_constants = [
    'TD_PERSON_REGISTRATION_FORM_ID' => 'Person registration form ID',
    'TD_DEFAULT_ASSIGNED_BY_ID' => 'Default assigner user ID',
];

foreach ($required_constants as $constant => $description) {
    check(
        "Constant: {$constant}",
        defined($constant),
        "{$description} = " . (defined($constant) ? constant($constant) : 'N/A'),
        "Missing (td-env-config.php may not be loaded)",
        $passed_checks,
        $failed_checks,
        $verbose
    );
}

// ============================================================================
// SUMMARY
// ============================================================================
echo "\n=== Summary ===\n";
echo "âœ… Passed: " . count($passed_checks) . "\n";
echo "âŒ Failed: " . count($failed_checks) . "\n";

if (!empty($failed_checks)) {
    echo "\nFailed Checks:\n";
    foreach ($failed_checks as $check) {
        echo "  - {$check}\n";
    }
    echo "\n";
    exit(1);
}

echo "\nâœ… All health checks passed!\n";
exit(0);
