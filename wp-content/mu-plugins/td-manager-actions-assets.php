<?php
/**
 * Plugin Name: TalenDelight Manager Actions Assets
 * Description: Enqueues JavaScript for Manager Actions page tabs
 * Version: 1.0.0
 */

// Enqueue Manager Actions JavaScript on the Manager Actions page only
add_action('wp_enqueue_scripts', 'td_enqueue_manager_actions_assets');

function td_enqueue_manager_actions_assets() {
    // Only load on Manager Actions page (ID: 36)
    if (is_page(36)) {
        wp_enqueue_script(
            'td-manager-actions-tabs',
            get_stylesheet_directory_uri() . '/assets/js/manager-actions-tabs.js',
            array(), // No dependencies
            '1.0.0',
            true // Load in footer
        );
    }
}
