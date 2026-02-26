<?php
/**
 * Audit Log Helper
 * Generic audit logging system for tracking all database changes
 */

class TD_Audit_Logger {
    
    /**
     * Log a database change
     * 
     * @param string $table_name Table being modified
     * @param int $record_id ID of the record
     * @param string $action Type of action (insert, update, delete, approve, reject, undo)
     * @param mixed $old_value Previous value(s) - can be array or string
     * @param mixed $new_value New value(s) - can be array or string
     * @param string|null $column_name Specific column (optional)
     * @param string|null $notes Additional context
     */
    public static function log($table_name, $record_id, $action, $old_value = null, $new_value = null, $column_name = null, $notes = null) {
        global $wpdb;
        
        $current_user_id = get_current_user_id();
        
        // Convert arrays to JSON
        $old_json = is_array($old_value) ? json_encode($old_value) : $old_value;
        $new_json = is_array($new_value) ? json_encode($new_value) : $new_value;
        
        // Get client info
        $ip_address = self::get_client_ip();
        $user_agent = isset($_SERVER['HTTP_USER_AGENT']) ? substr($_SERVER['HTTP_USER_AGENT'], 0, 500) : null;
        
        $wpdb->insert(
            'td_audit_log',
            [
                'table_name' => $table_name,
                'record_id' => $record_id,
                'action' => $action,
                'column_name' => $column_name,
                'old_value' => $old_json,
                'new_value' => $new_json,
                'changed_by' => $current_user_id,
                'ip_address' => $ip_address,
                'user_agent' => $user_agent,
                'notes' => $notes
            ],
            ['%s', '%d', '%s', '%s', '%s', '%s', '%d', '%s', '%s', '%s']
        );
    }
    
    /**
     * Get client IP address (supports proxies)
     */
    private static function get_client_ip() {
        $ip_keys = ['HTTP_CLIENT_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_FORWARDED', 'HTTP_FORWARDED_FOR', 'HTTP_FORWARDED', 'REMOTE_ADDR'];
        
        foreach ($ip_keys as $key) {
            if (array_key_exists($key, $_SERVER) === true) {
                foreach (explode(',', $_SERVER[$key]) as $ip) {
                    $ip = trim($ip);
                    if (filter_var($ip, FILTER_VALIDATE_IP) !== false) {
                        return $ip;
                    }
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get audit history for a specific record
     */
    public static function get_history($table_name, $record_id, $limit = 50) {
        global $wpdb;
        
        return $wpdb->get_results($wpdb->prepare(
            "SELECT a.*, u.display_name as changed_by_name 
             FROM td_audit_log a 
             LEFT JOIN wp_users u ON a.changed_by = u.ID 
             WHERE a.table_name = %s AND a.record_id = %d 
             ORDER BY a.changed_at DESC 
             LIMIT %d",
            $table_name,
            $record_id,
            $limit
        ));
    }
}
