-- v3.4.0: Add audit log table for compliance tracking
-- Created: January 18, 2026
-- Purpose: Track all manager actions on user data change requests for compliance and accountability

-- Create audit log table
CREATE TABLE IF NOT EXISTS wp_td_audit_log (
    id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    event_type VARCHAR(50) NOT NULL COMMENT 'Type of event (request_approved, request_rejected, etc.)',
    entity_type VARCHAR(50) NOT NULL COMMENT 'Type of entity affected (user_data_change_request, user, etc.)',
    entity_id BIGINT(20) UNSIGNED NOT NULL COMMENT 'ID of the affected entity',
    user_id BIGINT(20) UNSIGNED NOT NULL COMMENT 'User who initiated the original request',
    manager_id BIGINT(20) UNSIGNED COMMENT 'Manager who performed the action',
    action VARCHAR(50) NOT NULL COMMENT 'Action performed (approve, reject, delete, etc.)',
    old_value TEXT COMMENT 'Previous value before change',
    new_value TEXT COMMENT 'New value after change',
    ip_address VARCHAR(45) COMMENT 'IP address of the manager performing action',
    user_agent TEXT COMMENT 'Browser/client user agent string',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of action',
    PRIMARY KEY (id),
    KEY entity_type_id (entity_type, entity_id),
    KEY user_id (user_id),
    KEY manager_id (manager_id),
    KEY created_at (created_at),
    KEY event_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for all manager actions on user requests (GDPR compliance)';

-- Add priority column to existing requests table
ALTER TABLE wp_td_user_data_change_requests
ADD COLUMN priority VARCHAR(20) NOT NULL DEFAULT 'normal' COMMENT 'Priority level: normal, high, critical' AFTER status;

-- Add index for priority-based queries
ALTER TABLE wp_td_user_data_change_requests
ADD KEY priority (priority);

-- Add index for combined status+priority queries (common use case)
ALTER TABLE wp_td_user_data_change_requests
ADD KEY status_priority (status, priority);

-- Verify tables
SELECT 'Audit log table created' AS Status, COUNT(*) AS RowCount FROM wp_td_audit_log;
SELECT 'Priority column added' AS Status, COUNT(*) AS AffectedRows FROM wp_td_user_data_change_requests;
