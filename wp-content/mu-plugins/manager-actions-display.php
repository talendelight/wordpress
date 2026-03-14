<?php
/**
 * Plugin Name: Manager Actions Display
 * Description: Manager Actions page approval workflow - 5 tab interface (New, Assigned, Approved, Rejected, All)
 * Version: 1.0.0
 * Author: TalenDelight
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Load audit logger
require_once __DIR__ . '/audit-logger.php';

// ============================================================================
// AJAX HANDLERS - Use same endpoints as user-requests-display.php
// ============================================================================
// Note: All AJAX handlers are already defined in user-requests-display.php:
// - td_approve_request_ajax()
// - td_reject_request_ajax()
// - td_undo_approve_ajax()
// - td_undo_reject_ajax()
// - td_assign_request_ajax()

// ============================================================================
// SHORTCODE FOR MANAGER ACTIONS PAGE
// ============================================================================

/**
 * Manager Actions table shortcode
 * Usage: [manager_actions_table status="new"]
 * 
 * Status values: new, assigned, approved, rejected, all
 * 
 * Key difference from user-requests-display.php:
 * - Uses 'assigned' status instead of 'pending'
 * - Designed for Manager Actions page 5-tab interface
 * - Managers see ALL requests (no role filtering)
 */
function td_manager_actions_table_shortcode($atts) {
    // Verify user is Manager or Administrator
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        return '<div class="notice notice-error" style="padding: 20px; background: #f8d7da; border-left: 4px solid #dc3545; margin: 20px 0;">
            <p><strong>⛔ Access Denied</strong></p>
            <p>You do not have permission to view this content. Manager role required.</p>
        </div>';
    }
    
    // Parse attributes
    $atts = shortcode_atts(array(
        'status' => 'new',
        'limit' => 50,
        'days' => 90
    ), $atts);
    
    global $wpdb;
    $table = $wpdb->prefix . 'td_user_data_change_requests';
    
    // Check if table exists
    if ($wpdb->get_var("SHOW TABLES LIKE '{$table}'") != $table) {
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
    $date_filter = "";
    
    if ($atts['status'] === 'new') {
        // New = unassigned requests (assigned_to IS NULL)
        $where_clause = "(status = 'new' OR (status = 'pending' AND assigned_to IS NULL))";
    } elseif ($atts['status'] === 'assigned') {
        // Assigned = pending status with assigned_to set
        $where_clause = "(status = 'pending' AND assigned_to IS NOT NULL)";
    } elseif ($atts['status'] === 'approved') {
        $where_clause = "status = 'approved'";
        $date_filter = "AND updated_date >= DATE_SUB(NOW(), INTERVAL {$atts['days']} DAY)";
    } elseif ($atts['status'] === 'rejected') {
        $where_clause = "status = 'rejected'";
        $date_filter = "AND updated_date >= DATE_SUB(NOW(), INTERVAL {$atts['days']} DAY)";
    }
    // 'all' shows everything with date filter
    if ($atts['status'] === 'all') {
        $date_filter = "AND submitted_date >= DATE_SUB(NOW(), INTERVAL {$atts['days']} DAY)";
    }
    
    // Exclude saved and archived statuses from all queries
    $where_clause .= " AND status NOT IN ('saved', 'archived')";
    
    $query = $wpdb->prepare(
        "SELECT * FROM $table 
         WHERE $where_clause $date_filter 
         ORDER BY submitted_date DESC
         LIMIT %d",
        $atts['limit']
    );
    
    $requests = $wpdb->get_results($query);
    
    // Count statistics (exclude saved and archived)
    $stats = $wpdb->get_row("
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN status = 'new' OR (status = 'pending' AND assigned_to IS NULL) THEN 1 ELSE 0 END) as new_count,
            SUM(CASE WHEN status = 'pending' AND assigned_to IS NOT NULL THEN 1 ELSE 0 END) as assigned_count,
            SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_count,
            SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_count
        FROM $table 
        WHERE $where_clause $date_filter AND status NOT IN ('saved', 'archived')
    ");
    
    $current_user_id = get_current_user_id();
    
    ob_start();
    ?>
    
    <style>
        .td-action-btn {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            border: none !important;
            padding: 0 !important;
            width: 32px !important;
            height: 32px !important;
            min-width: 32px !important;
            max-width: 32px !important;
            border-radius: 5px !important;
            cursor: pointer !important;
            font-size: 12px !important;
            line-height: 1 !important;
            vertical-align: middle !important;
            color: white !important;
            box-sizing: border-box !important;
            transition: transform 0.2s, box-shadow 0.2s !important;
        }
        .td-action-btn:hover {
            transform: scale(1.15) !important;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2) !important;
        }
        .td-action-btn:disabled {
            opacity: 0.5 !important;
            cursor: not-allowed !important;
            transform: none !important;
        }
        .td-action-btn.td-action-assign { background: #063970 !important; }
        .td-action-btn.td-action-approve { background: #4caf50 !important; margin-right: 4px !important; }
        .td-action-btn.td-action-reject { background: #f44336 !important; }
        .td-action-btn.td-action-undo { background: #ff9800 !important; margin-right: 4px !important; }
        .td-action-btn.td-action-onboard { background: #2196F3 !important; }
        .td-action-btn.td-action-archive { background: #9E9E9E !important; }
        
        .ma-table-container {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        .ma-status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .ma-status-new { background: #E3F2FD; color: #1565C0; }
        .ma-status-assigned { background: #FFF9C4; color: #F57C00; }
        .ma-status-approved { background: #C8E6C9; color: #2E7D32; }
        .ma-status-rejected { background: #FFCDD2; color: #C62828; }
    </style>
    
    <div class="ma-table-container">
        
        <?php if (empty($requests)): ?>
            <!-- Empty State -->
            <div style="padding: 60px 20px; text-align: center; background: white; border-radius: 8px; border: 2px dashed #ddd;">
                <div style="font-size: 48px; margin-bottom: 20px;">📭</div>
                <h3 style="color: #063970; margin-bottom: 10px;">No Requests Found</h3>
                <p style="color: #666;">There are no <?php echo esc_html($atts['status']); ?> requests at this time.</p>
            </div>
        <?php else: ?>
            <!-- Requests Table -->
            <div style="overflow-x: auto; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8f9fa; border-bottom: 2px solid #dee2e6;">
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 6%;">ID</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 18%;">Name</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 8%;">Role</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 20%;">Email</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 10%;">Phone</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 6%;">Type</th>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 8%;">Submitted</th>
                            <?php if ($atts['status'] !== 'new'): ?>
                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #063970; font-size: 13px; width: 10%;">Assigned</th>
                            <?php endif; ?>
                            <th style="padding: 12px; text-align: center; font-weight: 600; color: #063970; font-size: 13px; width: 8%;">Status</th>
                            <th style="padding: 12px; text-align: center; font-weight: 600; color: #063970; font-size: 13px; width: 6%;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($requests as $request): 
                            $full_name = trim(($request->prefix ? $request->prefix . ' ' : '') . 
                                            $request->first_name . ' ' . 
                                            ($request->middle_name ? $request->middle_name . ' ' : '') . 
                                            $request->last_name);
                            
                            // Determine display status
                            $display_status = $request->status;
                            if ($request->status === 'pending' && $request->assigned_to) {
                                $display_status = 'assigned';
                            } elseif ($request->status === 'new' || ($request->status === 'pending' && !$request->assigned_to)) {
                                $display_status = 'new';
                            }
                        ?>
                        <tr style="border-bottom: 1px solid #dee2e6;" data-request-id="<?php echo $request->id; ?>">
                            <td style="padding: 12px;">
                                <span style="font-family: monospace; font-size: 12px; color: #666;">#<?php echo str_pad($request->id, 5, '0', STR_PAD_LEFT); ?></span>
                            </td>
                            <td style="padding: 12px;">
                                <div style="font-weight: 600; color: #063970; font-size: 13px;"><?php echo esc_html($full_name); ?></div>
                            </td>
                            <td style="padding: 12px;">
                                <span style="display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; background: #e3f2fd; color: #1565c0; text-transform: uppercase;">
                                    <?php echo esc_html(ucfirst($request->role ?? 'N/A')); ?>
                                </span>
                            </td>
                            <td style="padding: 12px;">
                                <span style="font-size: 13px; color: #666;"><?php echo esc_html($request->email); ?></span>
                            </td>
                            <td style="padding: 12px;">
                                <span style="font-size: 13px; color: #666;"><?php echo esc_html($request->phone); ?></span>
                            </td>
                            <td style="padding: 12px;">
                                <span style="font-size: 13px; color: #666; font-weight: 500;"><?php echo esc_html(ucwords($request->request_type)); ?></span>
                            </td>
                            <td style="padding: 12px;">
                                <span style="font-size: 12px; color: #666;"><?php echo human_time_diff(strtotime($request->submitted_date), current_time('timestamp')) . ' ago'; ?></span>
                            </td>
                            <?php if ($atts['status'] !== 'new'): ?>
                            <td style="padding: 12px;">
                                <?php 
                                if ($request->assigned_to) {
                                    $assignee = get_user_by('id', $request->assigned_to);
                                    $is_me = ($request->assigned_to == $current_user_id);
                                    echo '<span style="font-size: 13px; color: ' . ($is_me ? '#2E7D32' : '#063970') . '; font-weight: ' . ($is_me ? '600' : '500') . ';">' . 
                                         esc_html($assignee ? $assignee->display_name : 'User #' . $request->assigned_to) . 
                                         ($is_me ? ' (Me)' : '') . 
                                         '</span>';
                                } else {
                                    echo '<span style="font-size: 13px; color: #999; font-style: italic;">Unassigned</span>';
                                }
                                ?>
                            </td>
                            <?php endif; ?>
                            <td style="padding: 12px; text-align: center;">
                                <span class="ma-status-badge ma-status-<?php echo $display_status; ?>">
                                    <?php echo esc_html(ucfirst($display_status)); ?>
                                </span>
                            </td>
                            <td style="padding: 12px; text-align: center; white-space: nowrap;">
                                <?php if ($atts['status'] === 'new'): ?>
                                    <!-- New Tab: Assign to Me button -->
                                    <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Assign to Me">
                                        ▶
                                    </button>
                                    
                                <?php elseif ($atts['status'] === 'assigned'): ?>
                                    <!-- Assigned Tab: Approve/Reject if assigned to me, else Reassign -->
                                    <?php if ($request->assigned_to == $current_user_id): ?>
                                        <button class="td-approve-btn td-action-btn td-action-approve" data-id="<?php echo $request->id; ?>" title="Approve">
                                            ✓
                                        </button>
                                        <button class="td-reject-btn td-action-btn td-action-reject" data-id="<?php echo $request->id; ?>" title="Reject">
                                            ✗
                                        </button>
                                    <?php else: ?>
                                        <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Reassign to Me">
                                            ▶
                                        </button>
                                    <?php endif; ?>
                                    
                                <?php elseif ($atts['status'] === 'approved'): ?>
                                    <!-- Approved Tab: Undo Approval + Save -->
                                    <button class="td-undo-approve-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Approval">
                                        ↶
                                    </button>
                                    <button class="td-onboard-btn td-action-btn td-action-onboard" data-id="<?php echo $request->id; ?>" title="Save">
                                        +
                                    </button>
                                    
                                <?php elseif ($atts['status'] === 'rejected'): ?>
                                    <!-- Rejected Tab: Undo Rejection + Archive -->
                                    <button class="td-undo-reject-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Rejection">
                                        ↶
                                    </button>
                                    <button class="td-archive-btn td-action-btn td-action-archive" data-id="<?php echo $request->id; ?>" title="Archive">
                                        ▼
                                    </button>
                                    
                                <?php elseif ($atts['status'] === 'all'): ?>
                                    <!-- All Tab: Show appropriate actions based on status -->
                                    <?php if ($display_status === 'new'): ?>
                                        <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Assign to Me">
                                            ▶
                                        </button>
                                    <?php elseif ($display_status === 'assigned'): ?>
                                        <?php if ($request->assigned_to == $current_user_id): ?>
                                            <button class="td-approve-btn td-action-btn td-action-approve" data-id="<?php echo $request->id; ?>" title="Approve">
                                                ✓
                                            </button>
                                            <button class="td-reject-btn td-action-btn td-action-reject" data-id="<?php echo $request->id; ?>" title="Reject">
                                                ✗
                                            </button>
                                        <?php else: ?>
                                            <button class="td-assign-btn td-action-btn td-action-assign" data-id="<?php echo $request->id; ?>" title="Reassign to Me">
                                                ▶
                                            </button>
                                        <?php endif; ?>
                                    <?php elseif ($display_status === 'approved'): ?>
                                        <button class="td-undo-approve-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Approval">
                                            ↶
                                        </button>
                                        <button class="td-onboard-btn td-action-btn td-action-onboard" data-id="<?php echo $request->id; ?>" title="Save">
                                            +
                                        </button>
                                    <?php elseif ($display_status === 'rejected'): ?>
                                        <button class="td-undo-reject-btn td-action-btn td-action-undo" data-id="<?php echo $request->id; ?>" title="Undo Rejection">
                                            ↶
                                        </button>
                                        <button class="td-archive-btn td-action-btn td-action-archive" data-id="<?php echo $request->id; ?>" title="Archive">
                                            ▼
                                        </button>
                                    <?php endif; ?>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            
            <?php if (count($requests) >= $atts['limit']): ?>
            <div style="margin-top: 20px; padding: 15px; background: #fff3cd; border-radius: 4px; text-align: center;">
                <p style="color: #856404; font-size: 14px; margin: 0;">
                    <strong>ℹ️ Showing first <?php echo $atts['limit']; ?> requests.</strong> 
                    More requests may be available. Consider filtering by date range.
                </p>
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
            console.warn('tdShowNotification not found - using fallback alert');
            window.tdShowNotification = function(msg, type) {
                alert(msg);
            };
        }
        
        var currentAssignRequestId = null;
        
        // Assign button handler - show modal
        $(document).off('click', '.td-assign-btn').on('click', '.td-assign-btn', function() {
            currentAssignRequestId = $(this).data('id');
            $('#td-assign-modal').show();
        });
        
        // Assign to self handler
        $(document).off('click', '#td-assign-self').on('click', '#td-assign-self', function() {
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
                    setTimeout(function() { location.reload(); }, 500);
                } else {
                    tdShowNotification('Error: ' + response.data.message, 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Cancel button handler
        $(document).off('click', '#td-assign-cancel').on('click', '#td-assign-cancel', function() {
            $('#td-assign-modal').hide();
            currentAssignRequestId = null;
        });
        
        // Close modal on background click
        $(document).off('click', '#td-assign-modal').on('click', '#td-assign-modal', function(e) {
            if (e.target.id === 'td-assign-modal') {
                $(this).hide();
                currentAssignRequestId = null;
            }
        });
        
        // Approve button handler
        $(document).off('click', '.td-approve-btn').on('click', '.td-approve-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
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
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Reject button handler
        $(document).off('click', '.td-reject-btn').on('click', '.td-reject-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
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
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Undo approval button handler
        $(document).off('click', '.td-undo-approve-btn').on('click', '.td-undo-approve-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_undo_approve',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Undo rejection button handler
        $(document).off('click', '.td-undo-reject-btn').on('click', '.td-undo-reject-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
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
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Save button handler (create WordPress user)
        $(document).off('click', '.td-onboard-btn').on('click', '.td-onboard-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_save_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('User saved successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
        
        // Archive button handler
        $(document).off('click', '.td-archive-btn').on('click', '.td-archive-btn', function() {
            var btn = $(this);
            var requestId = btn.data('id');
            
            btn.prop('disabled', true).css('opacity', '0.5');
            
            $.post('<?php echo admin_url('admin-ajax.php'); ?>', {
                action: 'td_archive_request',
                request_id: requestId,
                nonce: '<?php echo wp_create_nonce('td_request_action'); ?>'
            }, function(response) {
                if (response.success) {
                    tdShowNotification('Request archived successfully', 'success');
                    btn.closest('tr').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    tdShowNotification('Error: ' + (response.data ? response.data.message : 'Unknown error'), 'error');
                    btn.prop('disabled', false).css('opacity', '1');
                }
            }).fail(function() {
                tdShowNotification('Network error', 'error');
                btn.prop('disabled', false).css('opacity', '1');
            });
        });
    });
    </script>
    
    <?php
    return ob_get_clean();
}
add_shortcode('manager_actions_table', 'td_manager_actions_table_shortcode');
