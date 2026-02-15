<?php
/**
 * TalenDelight Notification System
 * 
 * Provides a reusable floating notification system for success/error messages
 * across all WordPress pages.
 * 
 * Usage in JavaScript:
 * tdShowNotification('Your message here', 'success'); // or 'error'
 */

if (!defined('ABSPATH')) {
    exit;
}

/**
 * Enqueue notification styles and scripts
 */
function td_enqueue_notification_assets() {
    // Only load on admin and frontend pages where users are logged in
    if (!is_user_logged_in()) {
        return;
    }
    
    // Add inline CSS for notifications
    add_action('wp_head', 'td_notification_styles');
    add_action('admin_head', 'td_notification_styles');
    
    // Add inline JavaScript for notifications
    add_action('wp_footer', 'td_notification_scripts');
    add_action('admin_footer', 'td_notification_scripts');
}
add_action('init', 'td_enqueue_notification_assets');

/**
 * Output notification CSS
 */
function td_notification_styles() {
    ?>
    <style>
        #td-notification-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 999999;
            max-width: 400px;
        }
        
        .td-notification {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            padding: 16px 20px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: tdSlideIn 0.3s ease-out;
            border-left: 4px solid #ccc;
        }
        
        .td-notification.success {
            border-left-color: #4caf50;
        }
        
        .td-notification.error {
            border-left-color: #f44336;
        }
        
        .td-notification.warning {
            border-left-color: #ff9800;
        }
        
        .td-notification-icon {
            font-size: 20px;
            line-height: 1;
            flex-shrink: 0;
        }
        
        .td-notification.success .td-notification-icon {
            color: #4caf50;
        }
        
        .td-notification.error .td-notification-icon {
            color: #f44336;
        }
        
        .td-notification.warning .td-notification-icon {
            color: #ff9800;
        }
        
        .td-notification-message {
            flex: 1;
            font-size: 14px;
            color: #333;
            line-height: 1.4;
        }
        
        .td-notification-close {
            background: none;
            border: none;
            color: #999;
            font-size: 18px;
            cursor: pointer;
            padding: 0;
            width: 20px;
            height: 20px;
            line-height: 1;
            flex-shrink: 0;
        }
        
        .td-notification-close:hover {
            color: #333;
        }
        
        .td-notification.removing {
            animation: tdSlideOut 0.3s ease-in forwards;
        }
        
        @keyframes tdSlideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes tdSlideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }
    </style>
    <?php
}

/**
 * Output notification JavaScript
 */
function td_notification_scripts() {
    ?>
    <script>
    (function() {
        // Create notification container if it doesn't exist
        function getNotificationContainer() {
            var container = document.getElementById('td-notification-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'td-notification-container';
                document.body.appendChild(container);
            }
            return container;
        }
        
        // Show notification
        window.tdShowNotification = function(message, type) {
            type = type || 'success';
            var container = getNotificationContainer();
            
            var notification = document.createElement('div');
            notification.className = 'td-notification ' + type;
            
            var icon = document.createElement('span');
            icon.className = 'td-notification-icon';
            if (type === 'success') {
                icon.textContent = '✓';
            } else if (type === 'warning') {
                icon.textContent = '⚠';
            } else {
                icon.textContent = '✗';
            }
            
            var messageEl = document.createElement('span');
            messageEl.className = 'td-notification-message';
            messageEl.textContent = message;
            
            var closeBtn = document.createElement('button');
            closeBtn.className = 'td-notification-close';
            closeBtn.textContent = '×';
            closeBtn.setAttribute('aria-label', 'Close');
            
            notification.appendChild(icon);
            notification.appendChild(messageEl);
            notification.appendChild(closeBtn);
            
            container.appendChild(notification);
            
            // Auto-remove after 5 seconds
            var autoRemoveTimer = setTimeout(function() {
                removeNotification(notification);
            }, 5000);
            
            // Manual close
            closeBtn.addEventListener('click', function() {
                clearTimeout(autoRemoveTimer);
                removeNotification(notification);
            });
        };
        
        // Remove notification with animation
        function removeNotification(notification) {
            notification.classList.add('removing');
            setTimeout(function() {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }
    })();
    </script>
    <?php
}
