<?php
/**
 * Plugin Name: User Requests Display
 * Description: Display user data change requests in tabbed interface
 * Version: 1.1.0
 * Author: TalenDelight
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Load audit logger
require_once __DIR__ . '/audit-logger.php';

/**
 * AJAX handler for approving a request
 */
function td_approve_request_ajax() {
    check_ajax_referer('td_request_action', 'nonce');
    
    if (!current_user_can('manage_options')) {
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
    
    // Update status
    $wpdb->update(
        'td_user_data_change_requests',
        ['status' => 'approved', 'assigned_to' => get_current_user_id()],
        ['id' => $request_id],
        ['%s', '%d'],
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
    
    if (!current_user_can('manage_options')) {
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
    
    if (!current_user_can('manage_options')) {
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
    
    $wpdb->update(
        'td_user_data_change_requests',
        ['status' => 'pending'],
        ['id' => $request_id],
        ['%s'],
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
                            <th style="padding: 15px; text-align: center; font-weight: 600; color: #063970;">Status</th>
                            <?php if ($atts['status'] === 'pending' || $atts['status'] === 'rejected'): ?>
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
                            <td style="padding: 15px; text-align: center;">
                                <span style="display: inline-block; padding: 6px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; background: <?php echo $status_style['bg']; ?>; color: <?php echo $status_style['color']; ?>;">
                                    <?php echo esc_html(ucfirst($request->status)); ?>
                                </span>
                            </td>
                            <?php if ($atts['status'] === 'pending'): ?>
                            <td style="padding: 15px; text-align: center; white-space: nowrap;">
                                <button class="td-approve-btn" data-id="<?php echo $request->id; ?>" style="display: inline-block; background: #4caf50; color: white; border: none; padding: 6px; width: 28px; height: 28px; border-radius: 4px; cursor: pointer; margin-right: 8px; font-size: 14px; line-height: 1; vertical-align: middle;" title="Approve">
                                    ✓
                                </button>
                                <button class="td-reject-btn" data-id="<?php echo $request->id; ?>" style="display: inline-block; background: #f44336; color: white; border: none; padding: 6px; width: 28px; height: 28px; border-radius: 4px; cursor: pointer; font-size: 14px; line-height: 1; vertical-align: middle;" title="Reject">
                                    ✗
                                </button>
                            </td>
                            <?php elseif ($atts['status'] === 'rejected'): ?>
                            <td style="padding: 15px; text-align: center;">
                                <button class="td-undo-btn" data-id="<?php echo $request->id; ?>" style="display: inline-block; background: #ff9800; color: white; border: none; padding: 6px; width: 28px; height: 28px; border-radius: 4px; cursor: pointer; font-size: 14px; line-height: 1; vertical-align: middle;" title="Undo Rejection">
                                    ↶
                                </button>
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
    
    <script>
    jQuery(document).ready(function($) {
        // Approve button handler
        $('.td-approve-btn').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            if (!confirm('Are you sure you want to approve this request?')) {
                return;
            }
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_approve_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    alert('Error: ' + response.data.message);
                    btn.prop('disabled', false).css('opacity', '1');
                }
            });
        });
        
        // Reject button handler
        $('.td-reject-btn').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            if (!confirm('Are you sure you want to reject this request?')) {
                return;
            }
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_reject_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    alert('Error: ' + response.data.message);
                    btn.prop('disabled', false).css('opacity', '1');
                }
            });
        });
        
        // Undo rejection button handler
        $('.td-undo-btn').on('click', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            if (!confirm('Undo this rejection and move back to pending?')) {
                return;
            }
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_undo_reject',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    alert('Error: ' + response.data.message);
                    btn.prop('disabled', false).css('opacity', '1');
                }
            });
        });
    });
    </script>
    
    <?php
    return ob_get_clean();
}
add_shortcode('user_requests_table', 'td_user_requests_table_shortcode');
