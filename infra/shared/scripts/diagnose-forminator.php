<?php
/**
 * Diagnostic script to check Forminator submission data flow
 */

global $wpdb;

echo "=== Forminator Data Flow Diagnostic ===\n\n";

// 1. Check Forminator entries for form 364
echo "1. Checking Forminator entries (form 364):\n";
$forminator_entries = $wpdb->get_results("
    SELECT entry_id, form_id, date_created, status 
    FROM {$wpdb->prefix}frmt_form_entry 
    WHERE form_id = 364 
    ORDER BY entry_id DESC 
    LIMIT 5
");

if ($forminator_entries) {
    echo "   Found " . count($forminator_entries) . " entries:\n";
    foreach ($forminator_entries as $entry) {
        echo "   - Entry ID: {$entry->entry_id}, Date: {$entry->date_created}, Status: {$entry->status}\n";
        
        // Get field data for this entry
        $meta_data = $wpdb->get_results($wpdb->prepare("
            SELECT meta_key, meta_value 
            FROM {$wpdb->prefix}frmt_form_entry_meta 
            WHERE entry_id = %d
        ", $entry->entry_id));
        
        if ($meta_data) {
            echo "     Field data:\n";
            foreach ($meta_data as $meta) {
                $value = strlen($meta->meta_value) > 50 
                    ? substr($meta->meta_value, 0, 50) . '...' 
                    : $meta->meta_value;
                echo "     - {$meta->meta_key}: {$value}\n";
            }
        }
    }
} else {
    echo "   ❌ No entries found in Forminator table\n";
}

echo "\n";

// 2. Check custom td_user_data_change_requests table
echo "2. Checking td_user_data_change_requests table:\n";

$table_exists = $wpdb->get_var("
    SELECT COUNT(*) 
    FROM information_schema.tables 
    WHERE table_schema = DATABASE() 
    AND table_name = '{$wpdb->prefix}td_user_data_change_requests'
");

if ($table_exists) {
    $custom_requests = $wpdb->get_results("
        SELECT id, user_id, request_type, role, status, created_at 
        FROM {$wpdb->prefix}td_user_data_change_requests 
        ORDER BY created_at DESC 
        LIMIT 5
    ");
    
    if ($custom_requests) {
        echo "   Found " . count($custom_requests) . " requests:\n";
        foreach ($custom_requests as $request) {
            echo "   - ID: {$request->id}, User: {$request->user_id}, Type: {$request->request_type}, Role: {$request->role}, Status: {$request->status}, Date: {$request->created_at}\n";
        }
    } else {
        echo "   ⚠️  Table exists but no data found\n";
    }
} else {
    echo "   ❌ Table td_user_data_change_requests does NOT exist\n";
}

echo "\n";

// 3. Check if td-user-data-change-requests plugin is active
echo "3. Checking plugin status:\n";
$active_plugins = get_option('active_plugins', []);
$is_plugin_active = false;

foreach ($active_plugins as $plugin) {
    if (strpos($plugin, 'td-user-data-change-requests.php') !== false) {
        $is_plugin_active = true;
        echo "   ✅ Plugin is ACTIVE: {$plugin}\n";
        break;
    }
}

if (!$is_plugin_active) {
    echo "   ❌ Plugin 'td-user-data-change-requests.php' is NOT active\n";
}

echo "\n";

// 4. Summary
echo "=== DIAGNOSIS ===\n";
if (!$forminator_entries) {
    echo "❌ No Forminator entries found - submission may have failed\n";
} else {
    if ($table_exists) {
        if (!$custom_requests) {
            echo "❌ Data not transferred to custom table\n";
            if (!$is_plugin_active) {
                echo "   → Plugin is NOT active - ACTIVATE IT!\n";
            } else {
                echo "   → Plugin active but field mapping may be failing\n";
            }
        } else {
            echo "✅ Data flow working\n";
        }
    } else {
        echo "❌ Custom table doesn't exist - run migration\n";
    }
}
