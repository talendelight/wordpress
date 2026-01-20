<?php
/**
 * Script to delete Forminator form entries
 * Since we're using Option B (custom table only), this cleans up redundant Forminator data
 * 
 * Usage via WP-CLI:
 * 
 * 1. Dry-run (see what will be deleted):
 *    wp eval-file wp-content/mu-plugins/cleanup-forminator-entries.php --allow-root
 * 
 * 2. Actually delete entries for form 364:
 *    FORMINATOR_DELETE=true FORM_ID=364 wp eval-file wp-content/mu-plugins/cleanup-forminator-entries.php --allow-root
 * 
 * 3. Delete all Forminator entries (all forms):
 *    FORMINATOR_DELETE=true FORM_ID=all wp eval-file wp-content/mu-plugins/cleanup-forminator-entries.php --allow-root
 * 
 * 4. Delete entries older than 30 days:
 *    FORMINATOR_DELETE=true FORM_ID=364 DAYS_OLD=30 wp eval-file wp-content/mu-plugins/cleanup-forminator-entries.php --allow-root
 */

global $wpdb;

// Configuration from environment variables
$dry_run = !getenv('FORMINATOR_DELETE'); // Default to dry-run unless explicitly set
$form_id = getenv('FORM_ID') ?: '364'; // Default to form 364 (Person Registration)
$days_old = getenv('DAYS_OLD') ?: null; // Optional: only delete entries older than X days

echo "=== Forminator Entry Cleanup Script ===\n\n";

if ($dry_run) {
    echo "⚠️  DRY-RUN MODE (no data will be deleted)\n";
    echo "   To actually delete, run: FORMINATOR_DELETE=true wp eval-file ...\n\n";
} else {
    echo "🔥 DELETION MODE ACTIVE\n";
    echo "   Data will be permanently deleted!\n\n";
}

// Build query based on parameters
$entry_table = $wpdb->prefix . 'frmt_form_entry';
$meta_table = $wpdb->prefix . 'frmt_form_entry_meta';

if ($form_id === 'all') {
    echo "Target: ALL forms\n";
    $where_clause = "1=1";
    $where_params = [];
} else {
    echo "Target: Form ID {$form_id}\n";
    $where_clause = "form_id = %d";
    $where_params = [(int)$form_id];
}

if ($days_old) {
    echo "Age filter: Older than {$days_old} days\n";
    $where_clause .= " AND date_created < DATE_SUB(NOW(), INTERVAL %d DAY)";
    $where_params[] = (int)$days_old;
}

echo "\n";

// Get entries to delete
$query = "SELECT entry_id, form_id, date_created, status FROM {$entry_table} WHERE {$where_clause} ORDER BY entry_id DESC";
if (!empty($where_params)) {
    $entries = $wpdb->get_results($wpdb->prepare($query, $where_params));
} else {
    $entries = $wpdb->get_results($query);
}

if (empty($entries)) {
    echo "✅ No entries found matching criteria.\n";
    exit(0);
}

echo "Found " . count($entries) . " entries to delete:\n\n";

// Show first 10 entries as preview
$preview_count = min(10, count($entries));
echo "Preview (showing first {$preview_count}):\n";
for ($i = 0; $i < $preview_count; $i++) {
    $entry = $entries[$i];
    echo "  - Entry #{$entry->entry_id} (Form {$entry->form_id}) - {$entry->date_created} - {$entry->status}\n";
}

if (count($entries) > 10) {
    echo "  ... and " . (count($entries) - 10) . " more\n";
}

echo "\n";

// Count metadata rows that will be deleted
$entry_ids = array_map(function($e) { return $e->entry_id; }, $entries);
$entry_ids_str = implode(',', $entry_ids);
$meta_count = $wpdb->get_var("SELECT COUNT(*) FROM {$meta_table} WHERE entry_id IN ({$entry_ids_str})");

echo "Associated metadata rows: {$meta_count}\n\n";

if ($dry_run) {
    echo "=== DRY-RUN SUMMARY ===\n";
    echo "Would delete:\n";
    echo "  - " . count($entries) . " entries from {$entry_table}\n";
    echo "  - {$meta_count} metadata rows from {$meta_table}\n";
    echo "\nTo actually delete, run with FORMINATOR_DELETE=true\n";
    exit(0);
}

// Actual deletion
echo "=== DELETING DATA ===\n";

// Delete metadata first (foreign key constraint)
echo "Deleting metadata... ";
$meta_deleted = $wpdb->query("DELETE FROM {$meta_table} WHERE entry_id IN ({$entry_ids_str})");
echo "✅ Deleted {$meta_deleted} rows\n";

// Delete entries
echo "Deleting entries... ";
if (!empty($where_params)) {
    $entries_deleted = $wpdb->query($wpdb->prepare("DELETE FROM {$entry_table} WHERE {$where_clause}", $where_params));
} else {
    $entries_deleted = $wpdb->query("DELETE FROM {$entry_table} WHERE {$where_clause}");
}
echo "✅ Deleted {$entries_deleted} rows\n";

echo "\n=== CLEANUP COMPLETE ===\n";
echo "Total deleted:\n";
echo "  - {$entries_deleted} entries\n";
echo "  - {$meta_deleted} metadata rows\n";
echo "\n";
