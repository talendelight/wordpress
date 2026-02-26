<?php
/**
 * Environment-Specific Configuration
 * 
 * This file defines environment-specific constants that vary between
 * local development and production environments.
 * 
 * Include this file in wp-config.php:
 * require_once(__DIR__ . '/config/env-config.php');
 */

// Detect environment - you can customize this logic
// Option 1: Check database host (most reliable for both web and CLI)
$is_local = (defined('DB_HOST') && DB_HOST === 'wp-db');

// Option 2: Check if we're on localhost
if (!$is_local && isset($_SERVER['HTTP_HOST'])) {
    $is_local = (
        strpos($_SERVER['HTTP_HOST'], 'localhost') !== false || 
        strpos($_SERVER['HTTP_HOST'], '127.0.0.1') !== false
    );
}

// Option 3: Check for specific server name (more reliable for containers)
if (!$is_local && isset($_SERVER['SERVER_NAME']) && $_SERVER['SERVER_NAME'] === 'localhost') {
    $is_local = true;
}

// Option 4: Use environment variable if set
if (getenv('WP_ENV')) {
    $is_local = (getenv('WP_ENV') === 'development' || getenv('WP_ENV') === 'local');
}

// Define environment type
if (!defined('TD_ENVIRONMENT')) {
    define('TD_ENVIRONMENT', $is_local ? 'local' : 'production');
}

// Forminator Form IDs
if (!defined('TD_PERSON_REGISTRATION_FORM_ID')) {
    define('TD_PERSON_REGISTRATION_FORM_ID', $is_local ? 364 : 80);
}

// Page IDs (if needed in the future)
if (!defined('TD_WELCOME_PAGE_ID')) {
    define('TD_WELCOME_PAGE_ID', $is_local ? 20 : 14);
}

if (!defined('TD_SELECT_ROLE_PAGE_ID')) {
    define('TD_SELECT_ROLE_PAGE_ID', $is_local ? 379 : 78);
}

if (!defined('TD_REGISTER_PROFILE_PAGE_ID')) {
    define('TD_REGISTER_PROFILE_PAGE_ID', $is_local ? 365 : 79);
}

if (!defined('TD_MANAGER_ADMIN_PAGE_ID')) {
    define('TD_MANAGER_ADMIN_PAGE_ID', $is_local ? 386 : 86);
}

if (!defined('TD_MANAGERS_PAGE_ID')) {
    define('TD_MANAGERS_PAGE_ID', $is_local ? 469 : 0); // TBD for production
}

// Debug flag
if (!defined('TD_DEBUG')) {
    define('TD_DEBUG', $is_local);
}

// Log environment detection (only in debug mode)
if (defined('WP_DEBUG') && WP_DEBUG && TD_DEBUG) {
    error_log(sprintf(
        'TalenDelight Environment: %s (Form ID: %d)',
        TD_ENVIRONMENT,
        TD_PERSON_REGISTRATION_FORM_ID
    ));
}
