<?php
/**
 * Plugin Name: TalenDelight User Data Change Requests
 * Description: Handles user registration/profile change requests, approval workflow, and audit trail for all user roles. (OTP integration deferred)
 * Version: 1.0.0
 * Author: TalenDelight Dev Team
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class TD_User_Data_Change_Requests {
    public function __construct() {
        // Hook into Forminator form submission (registration/profile update)
        add_action('forminator_custom_form_after_handle_submit', [$this, 'handle_form_submission'], 10, 2);
    }

    /**
     * Handles Forminator form submissions for registration/profile changes.
     * Inserts a new request into td_user_data_change_requests for manager approval.
     *
     * @param $form_id
     * @param $response
     */
    public function handle_form_submission($form_id, $response) {
        global $wpdb;
        $table = $wpdb->prefix . 'td_user_data_change_requests';

        // Map Forminator fields to DB columns (update as needed)
        $fields = $this->extract_fields_from_response($response);
        if (!$fields) {
            return;
        }

        $data = [
            'user_id' => get_current_user_id(),
            'request_type' => $fields['request_type'],
            'role' => $fields['role'],
            'data_json' => wp_json_encode($fields['data']),
            'status' => 'pending',
            'created_at' => current_time('mysql', 1),
            'updated_at' => current_time('mysql', 1),
            'manager_id' => null,
            'approved_at' => null,
            'audit_log' => null,
        ];

        $wpdb->insert($table, $data);
    }

    /**
     * Extracts and maps Forminator response fields to DB columns.
     * @param $response
     * @return array|null
     */
    private function extract_fields_from_response($response) {
        // Example mapping - update keys as per your Forminator form
        if (empty($response['data'])) {
            return null;
        }
        $data = $response['data'];
        return [
            'request_type' => isset($data['request_type']) ? $data['request_type'] : 'registration',
            'role' => isset($data['role']) ? $data['role'] : '',
            'data' => $data,
        ];
    }
}

new TD_User_Data_Change_Requests();
