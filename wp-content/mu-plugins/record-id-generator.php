<?php
/**
 * Record ID Generator
 * 
 * Generates unique IDs for user requests and records with daily-reset sequences.
 * 
 * ID Formats:
 * - Request ID: USRQ-260131-1, USRQ-260131-2 (tracks submission attempts)
 * - Record ID: PRSN-260131-1, CMPY-260131-1 (permanent user identity)
 * 
 * Related: PENG-016 (Record ID generation implementation)
 * Related: PENG-001 v2.0 (Simplified entity types: PRSN/CMPY)
 * 
 * @package TalenDelight
 * @since 3.2.0
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Generate Request ID (USRQ format)
 * 
 * Creates a unique ID for each user submission attempt.
 * Used for audit trail - every form submission gets a new request_id.
 * 
 * @param string|null $date Optional date string in YYMMDD format. Uses today if null.
 * @return string|null Request ID (e.g., "USRQ-260131-1") or null on failure
 */
function td_generate_request_id($date = null) {
    global $wpdb;
    
    // Use provided date or generate from current date
    $date_str = $date ?? date('ymd'); // Format: YYMMDD (e.g., 260131)
    $entity_type = 'USRQ';
    
    // Start transaction for atomic operation
    $wpdb->query('START TRANSACTION');
    
    try {
        // Atomic increment: Insert new row or increment existing
        $result = $wpdb->query($wpdb->prepare(
            "INSERT INTO td_id_sequences (entity_type, date_str, last_sequence)
             VALUES (%s, %s, 1)
             ON DUPLICATE KEY UPDATE last_sequence = last_sequence + 1",
            $entity_type,
            $date_str
        ));
        
        if ($result === false) {
            throw new Exception("Failed to increment sequence for $entity_type-$date_str");
        }
        
        // Retrieve the sequence number that was just set
        $sequence = $wpdb->get_var($wpdb->prepare(
            "SELECT last_sequence FROM td_id_sequences 
             WHERE entity_type = %s AND date_str = %s",
            $entity_type,
            $date_str
        ));
        
        if ($sequence === null) {
            throw new Exception("Failed to retrieve sequence for $entity_type-$date_str");
        }
        
        // Commit transaction
        $wpdb->query('COMMIT');
        
        // Format: USRQ-YYMMDD-N (no zero padding)
        $request_id = "$entity_type-$date_str-$sequence";
        
        error_log("Generated request_id: $request_id");
        return $request_id;
        
    } catch (Exception $e) {
        // Rollback on error
        $wpdb->query('ROLLBACK');
        error_log("Error generating request_id: " . $e->getMessage());
        return null;
    }
}

/**
 * Generate Record ID (PRSN or CMPY format)
 * 
 * Creates a permanent ID for a user upon first approval.
 * This ID becomes the user's permanent identifier and never changes,
 * even when they submit future update requests.
 * 
 * @param string $role User role (candidate, employer, scout, etc.)
 * @param string|null $date Optional date string in YYMMDD format. Uses today if null.
 * @return string|null Record ID (e.g., "PRSN-260131-1" or "CMPY-260131-1") or null on failure
 */
function td_generate_record_id($role, $date = null) {
    global $wpdb;
    
    // Determine entity type based on role
    $entity_type = td_get_entity_type($role);
    
    if (!$entity_type) {
        error_log("Invalid role for record_id generation: $role");
        return null;
    }
    
    // Use provided date or generate from current date
    $date_str = $date ?? date('ymd'); // Format: YYMMDD (e.g., 260131)
    
    // Start transaction for atomic operation
    $wpdb->query('START TRANSACTION');
    
    try {
        // Atomic increment: Insert new row or increment existing
        $result = $wpdb->query($wpdb->prepare(
            "INSERT INTO td_id_sequences (entity_type, date_str, last_sequence)
             VALUES (%s, %s, 1)
             ON DUPLICATE KEY UPDATE last_sequence = last_sequence + 1",
            $entity_type,
            $date_str
        ));
        
        if ($result === false) {
            throw new Exception("Failed to increment sequence for $entity_type-$date_str");
        }
        
        // Retrieve the sequence number that was just set
        $sequence = $wpdb->get_var($wpdb->prepare(
            "SELECT last_sequence FROM td_id_sequences 
             WHERE entity_type = %s AND date_str = %s",
            $entity_type,
            $date_str
        ));
        
        if ($sequence === null) {
            throw new Exception("Failed to retrieve sequence for $entity_type-$date_str");
        }
        
        // Commit transaction
        $wpdb->query('COMMIT');
        
        // Format: PRSN-YYMMDD-N or CMPY-YYMMDD-N (no zero padding)
        $record_id = "$entity_type-$date_str-$sequence";
        
        error_log("Generated record_id: $record_id for role: $role");
        return $record_id;
        
    } catch (Exception $e) {
        // Rollback on error
        $wpdb->query('ROLLBACK');
        error_log("Error generating record_id: " . $e->getMessage());
        return null;
    }
}

/**
 * Get Entity Type from User Role
 * 
 * Maps user roles to entity type prefixes:
 * - PRSN: Individual users (candidate, scout, operator, manager, employee)
 * - CMPY: Organizational users (employer)
 * 
 * @param string $role User role
 * @return string|null Entity type ('PRSN' or 'CMPY') or null if invalid role
 */
function td_get_entity_type($role) {
    // Entity type mapping based on PENG-001 v2.0 simplified strategy
    $entity_map = array(
        // Person (PRSN) - All individual users
        'candidate' => 'PRSN',
        'scout'     => 'PRSN',
        'operator'  => 'PRSN',
        'manager'   => 'PRSN',
        'employee'  => 'PRSN',
        
        // Company (CMPY) - Organizational users
        'employer'  => 'CMPY',
    );
    
    $role_lower = strtolower(trim($role));
    
    if (isset($entity_map[$role_lower])) {
        return $entity_map[$role_lower];
    }
    
    error_log("Unknown role for entity type mapping: $role");
    return null;
}

/**
 * Validate ID Format
 * 
 * Checks if an ID follows the expected format:
 * - Request ID: USRQ-YYMMDD-N
 * - Record ID: PRSN-YYMMDD-N or CMPY-YYMMDD-N
 * 
 * @param string $id ID to validate
 * @param string $type Expected type: 'request' or 'record'
 * @return bool True if valid format, false otherwise
 */
function td_validate_id_format($id, $type = 'record') {
    if (empty($id)) {
        return false;
    }
    
    if ($type === 'request') {
        // Request ID: USRQ-YYMMDD-N
        return preg_match('/^USRQ-\d{6}-\d+$/', $id) === 1;
    } else {
        // Record ID: PRSN-YYMMDD-N or CMPY-YYMMDD-N
        return preg_match('/^(PRSN|CMPY)-\d{6}-\d+$/', $id) === 1;
    }
}

/**
 * Get Sequence Statistics
 * 
 * Retrieves current sequence counts for a given date.
 * Useful for debugging and monitoring.
 * 
 * @param string|null $date Date string in YYMMDD format. Uses today if null.
 * @return array Associative array with entity_type => last_sequence
 */
function td_get_sequence_stats($date = null) {
    global $wpdb;
    
    $date_str = $date ?? date('ymd');
    
    $results = $wpdb->get_results($wpdb->prepare(
        "SELECT entity_type, last_sequence, created_at, updated_at 
         FROM td_id_sequences 
         WHERE date_str = %s 
         ORDER BY entity_type",
        $date_str
    ), ARRAY_A);
    
    $stats = array();
    foreach ($results as $row) {
        $stats[$row['entity_type']] = array(
            'last_sequence' => (int)$row['last_sequence'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at']
        );
    }
    
    return $stats;
}
