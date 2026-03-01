<?php
/**
 * Restore Register Profile Page (ID 28) - Direct database update
 * Avoid WordPress sanitization that encodes HTML
 */

require_once(__DIR__ . '/wp-load.php');

$page_id = 28;
$html_file = __DIR__ . '/restore/pages/register-profile-28.html';

if (!file_exists($html_file)) {
    echo "ERROR: HTML file not found: $html_file\n";
    exit(1);
}

$new_content = file_get_contents($html_file);

if (empty($new_content)) {
    echo "ERROR: HTML file is empty\n";
    exit(1);
}

echo "=== Restoring Register Profile Page (ID $page_id) - Database Direct ===\n";
echo "Content length: " . strlen($new_content) . " bytes\n";
echo "Content lines: " . substr_count($new_content, "\n") . "\n";
echo "Has form tag: " . (strpos($new_content, '<form id="td-registration-form"') !== false ? 'YES âœ“' : 'NO âœ—') . "\n\n";

global $wpdb;

// Direct database update to bypass WordPress sanitization
$result = $wpdb->update(
    $wpdb->posts,
    [
        'post_content' => $new_content,
        'post_modified' => current_time('mysql'),
        'post_modified_gmt' => current_time('mysql', 1)
    ],
    ['ID' => $page_id],
    ['%s', '%s', '%s'],
    ['%d']
);

if ($result === false) {
    echo "ERROR: Database update failed: " . $wpdb->last_error . "\n";
    exit(1);
}

echo "SUCCESS: Page $page_id updated via direct database query\n";
echo "Rows affected: $result\n\n";

// Verify
$check = $wpdb->get_var($wpdb->prepare("SELECT post_content FROM $wpdb->posts WHERE ID = %d", $page_id));
$has_form = strpos($check, '<form id="td-registration-form"') !== false;
$has_encoded = strpos($check, '&lt;input') !== false;

echo "Verification:\n";
echo "- Content length: " . strlen($check) . " bytes\n";
echo "- Form tag: " . ($has_form ? 'FOUND âœ“' : 'NOT FOUND âœ—') . "\n";
echo "- Encoded HTML: " . ($has_encoded ? 'YES âœ—' : 'NO âœ“') . "\n";
