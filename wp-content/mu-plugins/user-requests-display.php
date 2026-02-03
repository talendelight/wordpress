<?php
/**
 * Plugin Name: User Requests Display
 * Description: Display user data change requests in tabbed interface
 * Version: 1.2.0
 * Author: TalenDelight
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Load audit logger
require_once __DIR__ . '/audit-logger.php';

// ============================================================================
// AJAX HANDLERS (Shared by all roles)
// ============================================================================

/**
 * AJAX handler for approving a request
 */
function td_approve_request_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    // Allow managers and operators to approve requests
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
    
    $request_id = intval($_POST['request_id']);
    global $wpdb;
    
    // Get current data
    $request = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_user_data_change_requests WHERE id = %d",
        $request_id
    ));
    
    if (!$request) {
        wp_send_json_error(['message' => 'Request not found']);
    }
    
    // Generate record_id if this is first approval (PENG-016)
    // record_id is permanent user identifier, generated only once
    $record_id = $request->record_id;
    
    if (empty($record_id) && function_exists('td_generate_record_id')) {
        $record_id = td_generate_record_id($request->role);
        
        if (!$record_id) {
            error_log("Failed to generate record_id for request $request_id (role: {$request->role})");
            // Continue with approval even if record_id generation fails
            // record_id can be backfilled later
        }
    }
    
    // Update status and record_id (if generated)
    $update_data = ['status' => 'approved', 'assigned_to' => get_current_user_id()];
    $update_format = ['%s', '%d'];
    
    if ($record_id && empty($request->record_id)) {
        $update_data['record_id'] = $record_id;
        $update_format[] = '%s';
        error_log("Record ID $record_id assigned to request $request_id on approval");
    }
    
    $wpdb->update(
        'td_user_data_change_requests',
        $update_data,
        ['id' => $request_id],
        $update_format,
        ['%d']
    );
    
    // Log the action
    TD_Audit_Logger::log(
        'td_user_data_change_requests',
        $request_id,
        'approve',
        'pending',
        'approved',
        'status',
        'Request approved by ' . wp_get_current_user()->display_name
    );
    
    wp_send_json_success(['message' => 'Request approved successfully']);
}
add_action('wp_ajax_td_approve_request', 'td_approve_request_ajax');

/**
 * AJAX handler for rejecting a request
 */
function td_reject_request_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    // Allow managers and operators to reject requests
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
    
    $request_id = intval($_POST['request_id']);
    global $wpdb;
    
    $request = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_user_data_change_requests WHERE id = %d",
        $request_id
    ));
    
    if (!$request) {
        wp_send_json_error(['message' => 'Request not found']);
    }
    
    $wpdb->update(
        'td_user_data_change_requests',
        ['status' => 'rejected', 'assigned_to' => get_current_user_id()],
        ['id' => $request_id],
        ['%s', '%d'],
        ['%d']
    );
    
    TD_Audit_Logger::log(
        'td_user_data_change_requests',
        $request_id,
        'reject',
        'pending',
        'rejected',
        'status',
        'Request rejected by ' . wp_get_current_user()->display_name
    );
    
    wp_send_json_success(['message' => 'Request rejected successfully']);
}
add_action('wp_ajax_td_reject_request', 'td_reject_request_ajax');

/**
 * AJAX handler for undoing a rejection
 */
function td_undo_reject_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    // Allow managers and operators to undo rejections
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
    
    $request_id = intval($_POST['request_id']);
    global $wpdb;
    
    $request = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_user_data_change_requests WHERE id = %d",
        $request_id
    ));
    
    if (!$request || $request->status !== 'rejected') {
        wp_send_json_error(['message' => 'Can only undo rejected requests']);
    }
    
    $current_user_id = get_current_user_id();
    
    $wpdb->update(
        'td_user_data_change_requests',
        [
            'status' => 'pending',
            'assigned_by' => $current_user_id
        ],
        ['id' => $request_id],
        ['%s', '%d'],
        ['%d']
    );
    
    TD_Audit_Logger::log(
        'td_user_data_change_requests',
        $request_id,
        'undo',
        'rejected',
        'pending',
        'status',
        'Rejection undone by ' . wp_get_current_user()->display_name
    );
    
    wp_send_json_success(['message' => 'Rejection undone successfully']);
}
add_action('wp_ajax_td_undo_reject', 'td_undo_reject_ajax');

/**
 * AJAX handler for undoing an approval
 */
function td_undo_approve_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    // Allow managers and operators to undo approvals
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
    
    $request_id = intval($_POST['request_id']);
    global $wpdb;
    
    $request = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_user_data_change_requests WHERE id = %d",
        $request_id
    ));
    
    if (!$request || $request->status !== 'approved') {
        wp_send_json_error(['message' => 'Can only undo approved requests']);
    }
    
    $current_user_id = get_current_user_id();
    
    $wpdb->update(
        'td_user_data_change_requests',
        [
            'status' => 'pending',
            'assigned_by' => $current_user_id
        ],
        ['id' => $request_id],
        ['%s', '%d'],
        ['%d']
    );
    
    TD_Audit_Logger::log(
        'td_user_data_change_requests',
        $request_id,
        'undo',
        'approved',
        'pending',
        'status',
        'Approval undone by ' . wp_get_current_user()->display_name
    );
    
    wp_send_json_success(['message' => 'Approval undone successfully']);
}
add_action('wp_ajax_td_undo_approve', 'td_undo_approve_ajax');

/**
 * AJAX handler for assigning a request
 */
function td_assign_request_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    // Allow managers and operators to assign requests
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
    
    $request_id = intval($_POST['request_id']);
    $assign_to_self = isset($_POST['assign_to_self']) && $_POST['assign_to_self'] === 'true';
    $assign_to_user = !empty($_POST['assign_to_user']) ? intval($_POST['assign_to_user']) : null;
    
    global $wpdb;
    
    // Get current request
    $request = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_user_data_change_requests WHERE id = %d",
        $request_id
    ));
    
    if (!$request) {
        wp_send_json_error(['message' => 'Request not found']);
    }
    
    // Determine who to assign to
    $current_user_id = get_current_user_id();
    $assigned_to = $assign_to_self ? $current_user_id : $assign_to_user;
    
    if (!$assigned_to) {
        wp_send_json_error(['message' => 'No user specified for assignment']);
    }
    
    // Update request: assign to user, set assigned_by, change status to pending
    $wpdb->update(
        'td_user_data_change_requests',
        [
            'status' => 'pending',
            'assigned_to' => $assigned_to,
            'assigned_by' => $current_user_id
        ],
        ['id' => $request_id],
        ['%s', '%d', '%d'],
        ['%d']
    );
    
    // Get assignee name for logging
    $assignee_user = get_user_by('id', $assigned_to);
    $assignee_name = $assignee_user ? $assignee_user->display_name : "User ID $assigned_to";
    $assigner_name = wp_get_current_user()->display_name;
    
    // Log the action
    TD_Audit_Logger::log(
        'td_user_data_change_requests',
        $request_id,
        'assign',
        $request->status,
        'pending',
        'status',
        "Request assigned to $assignee_name by $assigner_name"
    );
    
    wp_send_json_success([
        'message' => 'Request assigned successfully',
        'assigned_to' => $assignee_name
    ]);
}
add_action('wp_ajax_td_assign_request', 'td_assign_request_ajax');

// ============================================================================
// SHORTCODES - Base (Backward Compatibility)
// ============================================================================

/**
 * Shortcode to display user requests table
 * Usage: [user_requests_table status="pending"]
 */
function td_user_requests_table_shortcode($atts) {
    // Parse attributes
    $atts = shortcode_atts(array(
        'status' => 'pending', // pending, approved, rejected, all
        'limit' => 20,
        'days' => 90
    ), $atts);
    
    global $wpdb;
    // Table name without wp_ prefix (as defined in migration)
    $table = 'td_user_data_change_requests';
    
    // Check if table exists
    if ($wpdb->get_var("SHOW TABLES LIKE '$table'") != $table) {
        return '<div class="notice notice-warning" style="padding: 20px; background: #fff3cd; border-left: 4px solid #ffc107; margin: 20px 0;">
            <p><strong>⚠️ Database Table Not Found</strong></p>
            <p>The user requests table has not been created yet. Please apply the database migration:</p>
            <code style="background: #f5f5f5; padding: 5px 10px; display: inline-block; margin-top: 10px;">
            infra/shared/db/260117-impl-add-td_user_data_change_requests.sql
            </code>
        </div>';
    }
    
    // Build query based on status
    $where_clause = "1=1";
    $date_filter = "AND submitted_date >= DATE_SUB(NOW(), INTERVAL {$atts['days']} DAY)";
    
    if ($atts['status'] === 'new') {
        $where_clause = "status = 'new'";
        $date_filter = ""; // No date limit for new
    } elseif ($atts['status'] === 'pending') {
        $where_clause = "status = 'pending'";
        $date_filter = ""; // No date limit for pending
    } elseif ($atts['status'] === 'approved') {
        $where_clause = "status = 'approved'";
    } elseif ($atts['status'] === 'rejected') {
        $where_clause = "status = 'rejected'";
    }
    // 'all' shows everything
    
    $query = $wpdb->prepare(
        "SELECT * FROM $table 
         WHERE $where_clause $date_filter 
         ORDER BY submitted_date ASC
         LIMIT %d",
        $atts['limit']
    );
    
    $requests = $wpdb->get_results($query);
    
    // Count statistics
    $stats = $wpdb->get_row("
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
            SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
            SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
            SUM(CASE WHEN DATE(updated_date) = CURDATE() THEN 1 ELSE 0 END) as reviewed_today
        FROM $table 
        WHERE $where_clause $date_filter
    ");
    
    ob_start();
    ?>
    
    <style>
        .td-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            padding: 0;
            width: 32px;
            height: 32px;
            min-width: 32px;
            max-width: 32px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            line-height: 1;
            vertical-align: middle;
            color: white;
            box-sizing: border-box;
        }
        .td-action-btn.td-action-assign { background: #2196F3; }
        .td-action-btn.td-action-approve { background: #4caf50; margin-right: 8px; }
        .td-action-btn.td-action-reject { background: #f44336; }
        .td-action-btn.td-action-undo { background: #ff9800; }
    </style>
    
    <div class="user-requests-container" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
        
        <!-- Summary Metrics -->
        <div class="request-metrics" style="display: flex; gap: 20px; margin-bottom: 30px; flex-wrap: wrap;">
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #f5f9fc; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 36px; font-weight: 700; color: #063970;"><?php echo number_format($stats->total ?? 0); ?></div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Total Requests</div>
            </div>
            
            <?php if ($atts['status'] === 'pending' || $atts['status'] === 'all'): ?>
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #fff3cd; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 24px; font-weight: 600; color: #063970;">
                    Register: <?php echo $wpdb->get_var("SELECT COUNT(*) FROM $table WHERE request_type='register' AND status='pending'"); ?> | 
                    Update: <?php echo $wpdb->get_var("SELECT COUNT(*) FROM $table WHERE request_type='update' AND status='pending'"); ?>
                </div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Request Type Distribution</div>
            </div>
            <?php endif; ?>
            
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #d4edda; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 36px; font-weight: 700; color: #155724;"><?php echo number_format($stats->reviewed_today ?? 0); ?></div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Reviewed Today</div>
            </div>
        </div>
        
        <?php if (empty($requests)): ?>
            <!-- Empty State -->
            <div style="padding: 60px 20px; text-align: center; background: white; border-radius: 8px; border: 2px dashed #ddd;">
                <div style="font-size: 48px; margin-bottom: 20px;">📭</div>
                <h3 style="color: #063970; margin-bottom: 10px;">No Requests Found</h3>
                <p style="color: #666;">There are no <?php echo esc_html($atts['status']); ?> requests in the last <?php echo $atts['days']; ?> days.</p>
            </div>
        <?php else: ?>
            <!-- Requests Table -->
            <div style="overflow-x: auto; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8f9fa; border-bottom: 2px solid #dee2e6;">
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Name</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Role</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Email</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Phone</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Type</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Profile</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Submitted</th>
                            <?php if ($atts['status'] === 'pending' || $atts['status'] === 'approved' || $atts['status'] === 'rejected' || $atts['status'] === 'all'): ?>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Assignee</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Assignor</th>
                            <?php endif; ?>
                            <th style="padding: 15px; text-align: center; font-weight: 600; color: #063970;">Status</th>
                            <?php if ($atts['status'] === 'new' || $atts['status'] === 'pending' || $atts['status'] === 'approved' || $atts['status'] === 'rejected' || $atts['status'] === 'all'): ?>
                            <th style="padding: 15px; text-align: center; font-weight: 600; color: #063970;">Actions</th>
                            <?php endif; ?>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($requests as $request): 
                            $full_name = trim(($request->prefix ? $request->prefix . ' ' : '') . 
                                            $request->first_name . ' ' . 
                                            ($request->middle_name ? $request->middle_name . ' ' : '') . 
                                            $request->last_name);
                            
                            // Status badge styling
                            $status_colors = [
                                'new' => ['bg' => '#e3f2fd', 'color' => '#1976d2'],
                                'pending' => ['bg' => '#fff3cd', 'color' => '#856404'],
                                'approved' => ['bg' => '#d4edda', 'color' => '#155724'],
                                'rejected' => ['bg' => '#f8d7da', 'color' => '#721c24']
                            ];
                            $status_style = $status_colors[$request->status] ?? $status_colors['pending'];
                        ?>
                        <tr style="border-bottom: 1px solid #dee2e6;" data-request-id="<?php echo $request->id; ?>">
                            <td style="padding: 15px;">
                                <div style="font-weight: 600; color: #063970; font-size: 13px;"><?php echo esc_html($full_name); ?></div>
                            </td>
                            <td style="padding: 15px;">
                                <span style="display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; background: #e3f2fd; color: #1565c0; text-transform: uppercase;">
                                    <?php echo esc_html($request->role ?? 'N/A'); ?>
                                </span>
                            </td>
                            <td style="padding: 15px;">
                                <span style="font-size: 13px; color: #666;"><?php echo esc_html($request->email); ?></span>
                            </td>
                            <td style="padding: 15px;">
                                <span style="font-size: 13px; color: #666;"><?php echo esc_html($request->phone); ?></span>
                            </td>
                            <td style="padding: 15px;">
                                <span style="font-size: 13px; color: #666; font-weight: 500;"><?php echo esc_html(ucwords($request->request_type)); ?></span>
                            </td>
                            <td style="padding: 15px;">
                                <div style="font-size: 13px; color: #666;">
                                    <?php 
                                    $methods = [];
                                    if ($request->has_linkedin) $methods[] = '🔗 LinkedIn';
                                    if ($request->has_cv) $methods[] = '📄 CV';
                                    echo implode(' + ', $methods) ?: 'N/A';
                                    ?>
                                </div>
                            </td>
                            <td style="padding: 15px;">
                                <span style="font-size: 13px; color: #666;"><?php echo human_time_diff(strtotime($request->submitted_date), current_time('timestamp')) . ' ago'; ?></span>
                            </td>
                            <?php if ($atts['status'] === 'pending' || $atts['status'] === 'approved' || $atts['status'] === 'rejected' || $atts['status'] === 'all'): ?>
                            <td style="padding: 15px;">
                                <?php 
                                if ($request->assigned_to) {
                                    $assignee = get_user_by('id', $request->assigned_to);
                                    echo '<span style="font-size: 13px; color: #063970; font-weight: 500;">' . esc_html($assignee ? $assignee->display_name : 'User #' . $request->assigned_to) . '</span>';
                                } else {
                                    echo '<span style="font-size: 13px; color: #999; font-style: italic;">Unassigned</span>';
                                }
                                ?>
                            </td>
                            <td style="padding: 15px;">
                                <?php 
                                if ($request->assigned_by) {
                                    $assignor = get_user_by('id', $request->assigned_by);
                                    echo '<span style="font-size: 13px; color: #666;">' . esc_html($assignor ? $assignor->display_name : 'User #' . $request->assigned_by) . '</span>';
                                } else {
                                    echo '<span style="font-size: 13px; color: #999;">-</span>';
                                }
                                ?>
                            </td>
                            <?php endif; ?>
                            <td style="padding: 15px; text-align: center;">
                                <span style="display: inline-block; padding: 6px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; background: <?php echo $status_style['bg']; ?>; color: <?php echo $status_style['color']; ?>;">
                                    <?php echo esc_html(ucfirst($request->status)); ?>
                                </span>
                            </td>
                            <?php if ($atts['status'] === 'new'): ?>
                            <td style="padding: 15px; text-align: center; white-space: nowrap;">
                                <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Assign this request">→</button>
                            </td>
                            <?php elseif ($atts['status'] === 'pending'): ?>
                            <td style="padding: 15px; text-align: center; white-space: nowrap;">
                                <?php
                                $current_user_id = get_current_user_id();
                                // Show approve/reject buttons only if assigned to me
                                if ($request->assigned_to == $current_user_id):
                                ?>
                                <button class="td-approve-btn td-action-btn td-action-approve" data-id="<?php echo $request->id; ?>" title="Approve">✓</button>
                                <button class="td-reject-btn td-action-btn td-action-reject" data-id="<?php echo $request->id; ?>" title="Reject">✗</button>
                                <?php else: ?>
                                <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="<?php echo $request->assigned_to ? 'Reassign to me' : 'Assign to me'; ?>">→</button>
                                <?php endif; ?>
                            </td>
                            <?php elseif ($atts['status'] === 'rejected'): ?>
                            <td style="padding: 15px; text-align: center;">
                                <button class="td-undo-reject-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Rejection">↶</button>
                            </td>
                            <?php elseif ($atts['status'] === 'approved'): ?>
                            <td style="padding: 15px; text-align: center;">
                                <button class="td-undo-approve-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Approval">↶</button>
                            </td>
                            <?php elseif ($atts['status'] === 'all'): ?>
                            <td style="padding: 15px; text-align: center; white-space: nowrap;">
                                <?php if ($request->status === 'new'): ?>
                                    <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Assign this request">→</button>
                                <?php elseif ($request->status === 'pending'): ?>
                                    <?php
                                    $current_user_id = get_current_user_id();
                                    if ($request->assigned_to == $current_user_id):
                                    ?>
                                    <button class="td-approve-btn td-action-btn td-action-approve" data-id="<?php echo $request->id; ?>" title="Approve">✓</button>
                                    <button class="td-reject-btn td-action-btn td-action-reject" data-id="<?php echo $request->id; ?>" title="Reject">✗</button>
                                    <?php else: ?>
                                    <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="<?php echo $request->assigned_to ? 'Reassign to me' : 'Assign to me'; ?>">→</button>
                                    <?php endif; ?>
                                <?php elseif ($request->status === 'rejected'): ?>
                                    <button class="td-undo-reject-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Rejection">↶</button>
                                <?php elseif ($request->status === 'approved'): ?>
                                    <button class="td-undo-approve-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Approval">↶</button>
                                <?php endif; ?>
                            </td>
                            <?php endif; ?>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            
            <?php if (count($requests) >= $atts['limit']): ?>
            <div style="margin-top: 20px; text-align: center;">
                <p style="color: #666; font-size: 14px;">Showing first <?php echo $atts['limit']; ?> requests. <a href="#" style="color: #3498db;">Load more...</a></p>
            </div>
            <?php endif; ?>
        <?php endif; ?>
    </div>
    
    <!-- Assignment Modal -->
    <div id="td-assign-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 10000;">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 30px; border-radius: 8px; max-width: 400px; width: 90%; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <h3 style="margin: 0 0 20px 0; color: #063970; font-size: 20px; font-weight: 600;">Assign Request</h3>
            <p style="margin: 0 0 20px 0; color: #666; font-size: 14px;">Assign this request to:</p>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <button id="td-assign-self" style="background: #2196F3; color: white; border: none; padding: 12px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: 500; width: 100%;">
                    Assign to Me
                </button>
                <button id="td-assign-cancel" style="background: #e0e0e0; color: #333; border: none; padding: 12px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: 500; width: 100%;">
                    Cancel
                </button>
            </div>
        </div>
    </div>    
    <script>
    jQuery(document).ready(function($) {
        // Ensure notification function exists
        if (typeof window.tdShowNotification !== 'function') {
            console.error('tdShowNotification function not found - notifications disabled');
            window.tdShowNotification = function(msg, type) {
                console.log('[' + type + '] ' + msg);
                alert(msg);
            };
        }
        
        var currentAssignRequestId = null;
        
        // Assign button handler - show modal (remove any previous handlers first)
        $('.td-assign-btn').off('click').on('click', function() {
            currentAssignRequestId = $(this).data('id');
            $('#td-assign-modal').show();
        });
        
        // Assign to self handler
        $('#td-assign-self').off('click').on('click', function() {
            var btn = $(this);
            
            if (!currentAssignRequestId) {
                alert('No request selected');
                return;
            }
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_assign_request',
                request_id: currentAssignRequestId,
                assign_to_self: 'true',
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    $('#td-assign-modal').hide();
                    tdShowNotification('Request assigned successfully to ' + response.data.assigned_to, 'success');
                    setTimeout(function() { location.reload(); }, 1000);
                } else {
                    tdShowNotification('Error: ' + response.data.message, 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            });
        });
        
        // Cancel button handler
        $('#td-assign-cancel').off('click').on('click', function() {
            $('#td-assign-modal').hide();
            currentAssignRequestId = null;
        });
        
        // Close modal on background click
        $('#td-assign-modal').off('click').on('click', function(e) {
            if (e.target.id === 'td-assign-modal') {
                $(this).hide();
                currentAssignRequestId = null;
            }
        });
        
        // Approve button handler
        $('.td-approve-btn').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_approve_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Request approved successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Reject button handler
        $('.td-reject-btn').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_reject_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Request rejected successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Undo rejection button handler
        $('.td-undo-reject-btn').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_undo_reject',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Rejection undone successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Undo approval button handler
        $('.td-undo-approve-btn').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_undo_approve',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Approval undone successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
    });
    </script>
    
    <?php
    return ob_get_clean();
}
add_shortcode('user_requests_table', 'td_user_requests_table_shortcode');

// ============================================================================
// SHORTCODES - Manager (No Filtering)
// ============================================================================

/**
 * Manager-specific shortcode - shows ALL requests (no filtering)
 * Usage: [manager_requests_table status="pending" days="90"]
 * 
 * @since 1.2.0
 */
function td_manager_requests_table_shortcode($atts) {
    // Verify user is Manager or Administrator
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        return '<div class="notice notice-error" style="padding: 20px; background: #f8d7da; border-left: 4px solid #dc3545; margin: 20px 0;">
            <p><strong>⛔ Access Denied</strong></p>
            <p>You do not have permission to view this content. Manager role required.</p>
        </div>';
    }
    
    // Managers see everything - just call the base shortcode
    return td_user_requests_table_shortcode($atts);
}
add_shortcode('manager_requests_table', 'td_manager_requests_table_shortcode');

// ============================================================================
// SHORTCODES - Operator (Role + Assignment Filtering)
// ============================================================================

/**
 * Operator-specific shortcode - shows FILTERED requests
 * - Only Candidate and Employer roles (NO Scout/Operator/Manager)
 * - Only unassigned OR assigned to current user
 * 
 * Usage: [operator_requests_table status="pending" days="90"]
 * 
 * @since 1.2.0
 */
function td_operator_requests_table_shortcode($atts) {
    // Verify user is Operator or Administrator
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        return '<div class="notice notice-error" style="padding: 20px; background: #f8d7da; border-left: 4px solid #dc3545; margin: 20px 0;">
            <p><strong>⛔ Access Denied</strong></p>
            <p>You do not have permission to view this content. Operator role required.</p>
        </div>';
    }
    
    // Parse attributes
    $atts = shortcode_atts(array(
        'status' => 'pending',
        'limit' => 20,
        'days' => 90
    ), $atts);
    
    global $wpdb;
    $table = 'td_user_data_change_requests';
    
    // Check if table exists
    if ($wpdb->get_var("SHOW TABLES LIKE '$table'") != $table) {
        return '<div class="notice notice-warning" style="padding: 20px; background: #fff3cd; border-left: 4px solid #ffc107; margin: 20px 0;">
            <p><strong>⚠️ Database Table Not Found</strong></p>
            <p>The user requests table has not been created yet.</p>
        </div>';
    }
    
    // SECURITY-CRITICAL: Operators can ONLY see Candidate and Employer requests
    $allowed_roles_filter = "('candidate', 'employer')";
    
    // SECURITY-CRITICAL: Operators see only unassigned OR assigned to themselves
    $current_user_id = get_current_user_id();
    $assignment_filter = "(assigned_to IS NULL OR assigned_to = 0 OR assigned_to = $current_user_id)";
    
    // Build status filter
    $where_clause = "1=1";
    $date_filter = "AND submitted_date >= DATE_SUB(NOW(), INTERVAL {$atts['days']} DAY)";
    
    if ($atts['status'] === 'new') {
        $where_clause = "status = 'new'";
        $date_filter = "";
    } elseif ($atts['status'] === 'pending') {
        $where_clause = "status = 'pending'";
        $date_filter = "";
    } elseif ($atts['status'] === 'approved') {
        $where_clause = "status = 'approved'";
    } elseif ($atts['status'] === 'rejected') {
        $where_clause = "status = 'rejected'";
    }
    
    // Build filtered query
    $query = $wpdb->prepare(
        "SELECT * FROM $table 
         WHERE $where_clause 
         AND requested_role IN $allowed_roles_filter
         AND $assignment_filter
         $date_filter 
         ORDER BY submitted_date ASC
         LIMIT %d",
        $atts['limit']
    );
    
    $requests = $wpdb->get_results($query);
    
    // Count statistics (with same filters)
    $stats = $wpdb->get_row("
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
            SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
            SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
            SUM(CASE WHEN DATE(updated_date) = CURDATE() THEN 1 ELSE 0 END) as reviewed_today
        FROM $table 
        WHERE $where_clause 
        AND requested_role IN $allowed_roles_filter
        AND $assignment_filter
        $date_filter
    ");
    
    // Use same rendering logic as base shortcode
    ob_start();
    ?>
    
    <style>
        .td-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            padding: 0;
            width: 32px;
            height: 32px;
            min-width: 32px;
            max-width: 32px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            line-height: 1;
            vertical-align: middle;
            color: white;
            box-sizing: border-box;
        }
        .td-action-btn.td-action-assign { background: #2196F3; }
        .td-action-btn.td-action-approve { background: #4caf50; margin-right: 8px; }
        .td-action-btn.td-action-reject { background: #f44336; }
        .td-action-btn.td-action-undo { background: #ff9800; }
    </style>
    
    <div class="user-requests-container" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
        
        <!-- Operator View Notice -->
        <div class="notice notice-info" style="padding: 15px; background: #d1ecf1; border-left: 4px solid #0c5460; margin-bottom: 20px;">
            <p style="margin: 0;"><strong>📋 Operator View:</strong> Showing only <strong>Candidate</strong> and <strong>Employer</strong> requests that are unassigned or assigned to you.</p>
        </div>
        
        <!-- Summary Metrics -->
        <div class="request-metrics" style="display: flex; gap: 20px; margin-bottom: 30px; flex-wrap: wrap;">
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #f5f9fc; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 36px; font-weight: 700; color: #063970;"><?php echo number_format($stats->total ?? 0); ?></div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Total Requests (Filtered)</div>
            </div>
            
            <?php if ($atts['status'] === 'pending' || $atts['status'] === 'all'): ?>
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #fff3cd; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 24px; font-weight: 600; color: #063970;">
                    Register: <?php echo $wpdb->get_var("SELECT COUNT(*) FROM $table WHERE request_type='register' AND status='pending' AND requested_role IN $allowed_roles_filter AND $assignment_filter"); ?> | 
                    Update: <?php echo $wpdb->get_var("SELECT COUNT(*) FROM $table WHERE request_type='update' AND status='pending' AND requested_role IN $allowed_roles_filter AND $assignment_filter"); ?>
                </div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Request Type Distribution</div>
            </div>
            <?php endif; ?>
            
            <div class="metric-card" style="flex: 1; min-width: 200px; background: #d4edda; padding: 20px; border-radius: 8px; text-align: center;">
                <div style="font-size: 36px; font-weight: 700; color: #155724;"><?php echo number_format($stats->reviewed_today ?? 0); ?></div>
                <div style="font-size: 14px; color: #898989; margin-top: 5px;">Reviewed Today</div>
            </div>
        </div>
        
        <?php if (empty($requests)): ?>
            <!-- Empty State -->
            <div style="padding: 60px 20px; text-align: center; background: white; border-radius: 8px; border: 2px dashed #ddd;">
                <div style="font-size: 48px; margin-bottom: 20px;">📭</div>
                <h3 style="color: #063970; margin-bottom: 10px;">No Requests Found</h3>
                <p style="color: #666;">There are no <?php echo esc_html($atts['status']); ?> requests matching your filters.</p>
            </div>
        <?php else: ?>
            <!-- Requests Table -->
            <div style="overflow-x: auto; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8f9fa; border-bottom: 2px solid #dee2e6;">
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Name</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Role</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Email</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Phone</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Type</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Status</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Submitted</th>
                            <th style="padding: 15px; text-align: left; font-weight: 600; color: #063970;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($requests as $request): ?>
                            <tr data-id="<?php echo $request->id; ?>" style="border-bottom: 1px solid #e9ecef;">
                                <td style="padding: 15px;"><?php echo esc_html($request->first_name . ' ' . $request->last_name); ?></td>
                                <td style="padding: 15px;">
                                    <span style="display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; background: <?php echo $request->requested_role === 'candidate' ? '#e3f2fd' : '#fff3e0'; ?>; color: <?php echo $request->requested_role === 'candidate' ? '#1976d2' : '#f57c00'; ?>;">
                                        <?php echo esc_html(ucfirst($request->requested_role)); ?>
                                    </span>
                                </td>
                                <td style="padding: 15px; font-size: 14px; color: #666;"><?php echo esc_html($request->email); ?></td>
                                <td style="padding: 15px; font-size: 14px; color: #666;"><?php echo esc_html($request->phone ?? 'N/A'); ?></td>
                                <td style="padding: 15px;">
                                    <span style="font-size: 12px; text-transform: uppercase; color: #999;"><?php echo esc_html($request->request_type); ?></span>
                                </td>
                                <td style="padding: 15px;">
                                    <?php
                                    $status_colors = [
                                        'new' => ['bg' => '#e3f2fd', 'text' => '#1976d2'],
                                        'pending' => ['bg' => '#fff3e0', 'text' => '#f57c00'],
                                        'approved' => ['bg' => '#e8f5e9', 'text' => '#388e3c'],
                                        'rejected' => ['bg' => '#ffebee', 'text' => '#d32f2f']
                                    ];
                                    $colors = $status_colors[$request->status] ?? ['bg' => '#f5f5f5', 'text' => '#666'];
                                    ?>
                                    <span style="display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; background: <?php echo $colors['bg']; ?>; color: <?php echo $colors['text']; ?>;">
                                        <?php echo esc_html(ucfirst($request->status)); ?>
                                    </span>
                                </td>
                                <td style="padding: 15px; font-size: 14px; color: #666;">
                                    <?php echo date('Y-m-d H:i', strtotime($request->submitted_date)); ?>
                                </td>
                                <td style="padding: 15px;">
                                    <?php if ($request->status === 'new' || $request->status === 'pending'): ?>
                                        <button class="td-action-btn td-action-approve" data-id="<?php echo $request->id; ?>" title="Approve">✓</button>
                                        <button class="td-action-btn td-action-reject" data-id="<?php echo $request->id; ?>" title="Reject">✗</button>
                                    <?php elseif ($request->status === 'approved'): ?>
                                        <button class="td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Approval">↶</button>
                                    <?php elseif ($request->status === 'rejected'): ?>
                                        <button class="td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Rejection">↶</button>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
        
    </div>
    
    <!-- Notification Container -->
    <div id="td-notification" style="position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); display: none; z-index: 9999; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;"></div>
    
    <script>
    jQuery(document).ready(function($) {
        function tdShowNotification(message, type) {
            var bgColor = type === 'success' ? '#4caf50' : '#f44336';
            $('#td-notification')
                .css('background-color', bgColor)
                .css('color', 'white')
                .html(message)
                .fadeIn()
                .delay(3000)
                .fadeOut();
        }
        
        // Approve button handler
        $('.td-action-btn.td-action-approve').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_approve_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Request approved successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Reject button handler
        $('.td-action-btn.td-action-reject').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_reject_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Request rejected successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Undo button handler
        $('.td-action-btn.td-action-undo').off('click').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_undo_reject',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Action undone successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function(xhr, status, error) {
                console.error('AJAX Error:', status, error);
                tdShowNotification('Network error: ' + error, 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
    });
    </script>
    
    <?php
    return ob_get_clean();
}
add_shortcode('operator_requests_table', 'td_operator_requests_table_shortcode');
