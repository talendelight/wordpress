-- Migration: Add assigned_by Column
-- Date: 2026-01-31 14:00
-- Purpose: Track who assigned the request (assignor) for audit trail
-- Related: Assignment workflow implementation

ALTER TABLE wp_td_user_data_change_requests
ADD COLUMN assigned_by BIGINT(20) NULL COMMENT 'User ID of who assigned this request' AFTER assigned_to;

-- Add index for performance
CREATE INDEX idx_assigned_by ON wp_td_user_data_change_requests(assigned_by);
