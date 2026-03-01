<?php
// Quick security verification for v3.6.0
define('WP_USE_THEMES', false);
require('./wp-load.php');

echo "=== v3.6.0 Security Verification ===\n\n";

// Test 1: XML-RPC
$xmlrpc_enabled = apply_filters('xmlrpc_enabled', true);
echo "XML-RPC: " . ($xmlrpc_enabled ? "âŒ ENABLED" : "âœ… DISABLED") . "\n";

// Test 2: File editing
echo "File Editing: " . (defined('DISALLOW_FILE_EDIT') && DISALLOW_FILE_EDIT ? "âœ… DISABLED" : "âŒ ENABLED") . "\n";

// Test 3: MU-Plugin loaded
$mu_plugins = get_mu_plugins();
$security_loaded = isset($mu_plugins['td-api-security.php']);
echo "API Security Plugin: " . ($security_loaded ? "âœ… LOADED" : "âŒ NOT LOADED") . "\n";

// Test 4: Record ID generator loaded
$record_id_loaded = isset($mu_plugins['record-id-generator.php']);
echo "Record ID Generator: " . ($record_id_loaded ? "âœ… LOADED" : "âŒ NOT LOADED") . "\n";

echo "\n=== Deployment Status: " . ($xmlrpc_enabled === false && $security_loaded ? "âœ… SUCCESS" : "âš ï¸ INCOMPLETE") . " ===\n";
