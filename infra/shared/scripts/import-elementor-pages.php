<?php
/**
 * Generic Elementor Page Import Script
 * 
 * Imports Elementor pages from JSON files using manifest for mapping.
 * 
 * Usage: 
 *   wp eval-file import-elementor-pages.php
 *   
 * Environment:
 *   ELEMENTOR_IMPORT_DIR - Directory containing manifest.json and page files (default: ~/elementor-exports)
 *   ELEMENTOR_DRY_RUN - Set to "true" to simulate without actual import
 * 
 * @version 1.0.0
 */

global $wpdb;

// Configuration
$import_dir = getenv('ELEMENTOR_IMPORT_DIR') ?: (getenv('HOME') . '/elementor-exports');
$manifest_file = $import_dir . '/manifest.json';
$dry_run = getenv('ELEMENTOR_DRY_RUN') === 'true';

// Validate environment
if (!file_exists($manifest_file)) {
    echo "ERROR: Manifest file not found: $manifest_file\n";
    echo "Set ELEMENTOR_IMPORT_DIR environment variable or place manifest in ~/elementor-exports/\n";
    exit(1);
}

// Read manifest
$manifest = json_decode(file_get_contents($manifest_file), true);
if (!$manifest || !isset($manifest['pages'])) {
    echo "ERROR: Invalid manifest format. Expected JSON with 'pages' array.\n";
    exit(1);
}

echo "=================================================\n";
echo "Elementor Page Import Script v1.0.0\n";
echo "=================================================\n";
echo "Version: {$manifest['version']}\n";
echo "Pages: " . count($manifest['pages']) . "\n";
echo "Mode: " . ($dry_run ? "DRY RUN (no changes)" : "LIVE") . "\n";
echo "=================================================\n\n";

$success_count = 0;
$error_count = 0;
$skipped_count = 0;

foreach ($manifest['pages'] as $page) {
    echo "Processing: {$page['title']} (ID: {$page['prod_id']})\n";
    
    // Validate page exists
    $post = get_post($page['prod_id']);
    if (!$post) {
        echo "  WARNING: Page ID {$page['prod_id']} does not exist. Skipping.\n\n";
        $skipped_count++;
        continue;
    }
    
    // Validate file
    $file_path = $import_dir . '/' . $page['file'];
    if (!file_exists($file_path)) {
        echo "  ERROR: File not found: $file_path\n\n";
        $error_count++;
        continue;
    }
    
    // Read data
    $data = file_get_contents($file_path);
    if ($data === false || empty($data)) {
        echo "  ERROR: Could not read file or file is empty\n\n";
        $error_count++;
        continue;
    }
    
    $data_size = strlen($data);
    echo "  File: {$page['file']} ($data_size bytes)\n";
    
    // Validate JSON (loose check - Elementor data may be escaped JSON)
    $json_test = json_decode($data);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo "  INFO: JSON validation failed (may be normal for escaped Elementor data)\n";
    }
    
    if ($dry_run) {
        echo "  DRY RUN: Would import $data_size bytes\n\n";
        $success_count++;
        continue;
    }
    
    // Delete existing data
    $deleted = $wpdb->delete(
        $wpdb->postmeta,
        ['post_id' => $page['prod_id'], 'meta_key' => '_elementor_data'],
        ['%d', '%s']
    );
    
    echo "  Deleted existing: " . ($deleted ? "$deleted row(s)" : "none") . "\n";
    
    // Insert new data
    $result = $wpdb->insert(
        $wpdb->postmeta,
        [
            'post_id' => $page['prod_id'],
            'meta_key' => '_elementor_data',
            'meta_value' => $data
        ],
        ['%d', '%s', '%s']
    );
    
    if ($result === false) {
        echo "  ERROR: Database insert failed\n";
        echo "  Details: " . $wpdb->last_error . "\n\n";
        $error_count++;
        continue;
    }
    
    // Ensure Elementor metadata is set
    update_post_meta($page['prod_id'], '_elementor_edit_mode', 'builder');
    update_post_meta($page['prod_id'], '_elementor_page_settings', '');
    
    echo "  SUCCESS: Imported (meta_id: {$wpdb->insert_id})\n\n";
    $success_count++;
}

// Clear Elementor cache
if (!$dry_run && class_exists('\Elementor\Plugin')) {
    try {
        \Elementor\Plugin::instance()->files_manager->clear_cache();
        echo "Cleared Elementor cache\n";
    } catch (Exception $e) {
        echo "WARNING: Could not clear Elementor cache: " . $e->getMessage() . "\n";
    }
}

echo "\n=================================================\n";
echo "Deployment Summary\n";
echo "=================================================\n";
echo "Success: $success_count\n";
echo "Errors: $error_count\n";
echo "Skipped: $skipped_count\n";
echo "=================================================\n";

if ($dry_run) {
    echo "\nDRY RUN complete. No changes were made.\n";
    echo "Remove ELEMENTOR_DRY_RUN environment variable to execute.\n";
}

exit($error_count > 0 ? 1 : 0);
