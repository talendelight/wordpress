-- Add approver_id and comments columns to td_user_data_change_requests table
-- Migration: 260120-1945
-- Purpose: Support approval workflow with approver tracking and comments

USE wordpress;

-- Add approver_id column (foreign key to wp_users.ID for the manager who approved/rejected)
ALTER TABLE td_user_data_change_requests
ADD COLUMN approver_id bigint(20) NULL AFTER assigned_to,
ADD INDEX idx_approver_id (approver_id);

-- Add comments column for approval/rejection notes
ALTER TABLE td_user_data_change_requests
ADD COLUMN comments text NULL AFTER approver_id;

-- Verify changes
DESCRIBE td_user_data_change_requests;
