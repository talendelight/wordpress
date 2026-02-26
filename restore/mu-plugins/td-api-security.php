<?php
/**
 * Plugin Name: TalenDelight API Security
 * Description: Centralized AJAX and REST API security hardening (PENG-054)
 * Version: 1.0.0
 * Author: TalenDelight
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * PENG-054: AJAX/REST API Security Hardening
 * 
 * This plugin provides centralized security enforcement for:
 * 1. AJAX endpoint capability validation
 * 2. REST API route capability validation
 * 3. WordPress admin API surface protection
 * 4. Security monitoring and logging
 */

class TD_API_Security {
    
    /**
     * Initialize security hooks
     */
    public static function init() {
        // Block REST API for unauthorized users (except public endpoints)
        add_filter('rest_authentication_errors', [__CLASS__, 'restrict_rest_api_access']);
        
        // Monitor AJAX requests for security violations
        add_action('admin_init', [__CLASS__, 'monitor_ajax_security']);
        
        // Disable XML-RPC (common attack vector)
        add_filter('xmlrpc_enabled', '__return_false');
        
        // Remove WordPress version from headers
        remove_action('wp_head', 'wp_generator');
        
        // Disable file editing from admin
        if (!defined('DISALLOW_FILE_EDIT')) {
            define('DISALLOW_FILE_EDIT', true);
        }
    }
    
    /**
     * Restrict REST API access based on authentication and capabilities
     * 
     * @param WP_Error|null|bool $result Error from another authentication handler, null if we should handle it, or true if already authenticated.
     * @return WP_Error|null|bool
     */
    public static function restrict_rest_api_access($result) {
        // If another handler already authenticated, allow
        if (true === $result || is_wp_error($result)) {
            return $result;
        }
        
        // Get current route
        $current_route = self::get_current_rest_route();
        
        // Allow public routes (these are intentionally public)
        $public_routes = [
            '/wp/v2/media',           // Media library (for forms)
            '/wp/v2/users/me',        // Current user info
            '/oembed/',               // oEmbed endpoints
            '/wpforms/v1/',           // WPForms public endpoints
            '/forminator/v1/',        // Forminator public endpoints (if used)
        ];
        
        foreach ($public_routes as $public_route) {
            if (strpos($current_route, $public_route) !== false) {
                return $result; // Allow public access
            }
        }
        
        // Require authentication for all other routes
        if (!is_user_logged_in()) {
            return new WP_Error(
                'rest_not_logged_in',
                __('You must be logged in to access this endpoint.'),
                ['status' => 401]
            );
        }
        
        // Block custom roles from admin API surfaces
        $user = wp_get_current_user();
        $custom_roles = ['td_candidate', 'td_employer', 'td_scout', 'td_operator', 'td_manager'];
        
        if (array_intersect($custom_roles, $user->roles)) {
            // Custom roles can only access specific namespaced routes
            $allowed_custom_namespaces = [
                '/td/v1/',              // TalenDelight custom API (future)
                '/wpforms/v1/submit',   // Form submissions only
            ];
            
            $has_access = false;
            foreach ($allowed_custom_namespaces as $namespace) {
                if (strpos($current_route, $namespace) !== false) {
                    $has_access = true;
                    break;
                }
            }
            
            if (!$has_access) {
                error_log("REST API access denied for user {$user->ID} ({$user->user_email}) to route: {$current_route}");
                return new WP_Error(
                    'rest_forbidden',
                    __('You do not have permission to access this endpoint.'),
                    ['status' => 403]
                );
            }
        }
        
        return $result;
    }
    
    /**
     * Get the current REST API route
     * 
     * @return string
     */
    private static function get_current_rest_route() {
        $rest_route = '';
        
        if (isset($_SERVER['REQUEST_URI'])) {
            $rest_prefix = rest_get_url_prefix();
            $request_uri = esc_url_raw(wp_unslash($_SERVER['REQUEST_URI']));
            
            // Extract route from URL
            if (strpos($request_uri, $rest_prefix) !== false) {
                $rest_route = substr($request_uri, strpos($request_uri, $rest_prefix) + strlen($rest_prefix));
                $rest_route = '/' . ltrim($rest_route, '/');
            }
        }
        
        return $rest_route;
    }
    
    /**
     * Monitor AJAX requests for security violations
     */
    public static function monitor_ajax_security() {
        // Only monitor AJAX requests
        if (!defined('DOING_AJAX') || !DOING_AJAX) {
            return;
        }
        
        // Get action
        $action = isset($_REQUEST['action']) ? sanitize_text_field($_REQUEST['action']) : '';
        
        if (empty($action)) {
            return;
        }
        
        // Check for TalenDelight custom AJAX actions
        $td_ajax_actions = [
            'td_approve_request',
            'td_reject_request',
            'td_undo_reject',
            'td_undo_approve',
            'td_assign_request',
        ];
        
        if (in_array($action, $td_ajax_actions, true)) {
            // Verify nonce (redundant check - handlers also check)
            if (!isset($_REQUEST['nonce']) || !wp_verify_nonce($_REQUEST['nonce'], 'td_request_action')) {
                error_log("AJAX Security: Invalid nonce for action '{$action}' from IP: " . self::get_client_ip());
            }
            
            // Verify user authentication
            if (!is_user_logged_in()) {
                error_log("AJAX Security: Unauthenticated request for action '{$action}' from IP: " . self::get_client_ip());
            }
            
            // Verify role capabilities
            $user = wp_get_current_user();
            $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
            
            if (!array_intersect($allowed_roles, $user->roles)) {
                error_log("AJAX Security: Unauthorized role attempt for action '{$action}' by user {$user->ID} ({$user->user_email}) with roles: " . implode(', ', $user->roles));
            }
        }
    }
    
    /**
     * Get client IP address (behind proxies)
     * 
     * @return string
     */
    private static function get_client_ip() {
        $ip = '';
        
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        } elseif (!empty($_SERVER['REMOTE_ADDR'])) {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        
        return sanitize_text_field($ip);
    }
    
    /**
     * Validate capability for AJAX action
     * 
     * Helper function for use in AJAX handlers
     * 
     * @param string $capability Required capability
     * @param string $action AJAX action name (for logging)
     * @return bool
     */
    public static function validate_ajax_capability($capability, $action = '') {
        if (!current_user_can($capability)) {
            error_log("AJAX Security: Capability check failed for '{$capability}' in action '{$action}' by user " . get_current_user_id());
            return false;
        }
        
        return true;
    }
    
    /**
     * Validate role for AJAX action
     * 
     * Helper function for use in AJAX handlers
     * 
     * @param array $allowed_roles Array of allowed role slugs
     * @param string $action AJAX action name (for logging)
     * @return bool
     */
    public static function validate_ajax_role($allowed_roles, $action = '') {
        $user = wp_get_current_user();
        
        if (!array_intersect($allowed_roles, $user->roles)) {
            error_log("AJAX Security: Role check failed for action '{$action}' by user {$user->ID} ({$user->user_email}) with roles: " . implode(', ', $user->roles));
            return false;
        }
        
        return true;
    }
}

// Initialize security system
TD_API_Security::init();

/**
 * SECURITY AUDIT: Custom AJAX Endpoints
 * 
 * All TalenDelight AJAX handlers are defined in:
 * - wp-content/mu-plugins/user-requests-display.php
 * 
 * Verified security measures:
 * ✅ td_approve_request_ajax()   - Nonce + Role check (Manager, Operator)
 * ✅ td_reject_request_ajax()    - Nonce + Role check (Manager, Operator)
 * ✅ td_undo_reject_ajax()       - Nonce + Role check (Manager, Operator)
 * ✅ td_undo_approve_ajax()      - Nonce + Role check (Manager, Operator)
 * ✅ td_assign_request_ajax()    - Nonce + Role check (Manager, Operator)
 * 
 * All handlers implement:
 * 1. check_ajax_referer('td_request_action', 'nonce')
 * 2. Role verification: ['administrator', 'td_manager', 'td_operator']
 * 3. Input sanitization: intval() for IDs
 * 4. Prepared statements for database queries
 * 5. Audit logging via TD_Audit_Logger
 * 
 * SECURITY STATUS: ✅ HARDENED
 */

/**
 * SECURITY AUDIT: REST API Endpoints
 * 
 * Current status: No custom REST API endpoints registered.
 * 
 * Third-party plugins with REST API:
 * - WPForms: Has own capability checks built-in
 * - Akismet: Has own capability checks built-in
 * - GenerateBlocks: Editor-only routes (restricted by WordPress core)
 * - Blocksy Theme: Public search endpoint (intentionally public)
 * 
 * Protection strategy:
 * 1. Block all REST API for unauthenticated users (except public routes)
 * 2. Block custom roles from WordPress admin API surfaces
 * 3. Allow only specific namespaced routes for custom roles
 * 4. Monitor and log suspicious access attempts
 * 
 * SECURITY STATUS: ✅ HARDENED
 */
