-- Add record_id and request_id columns to td_user_data_change_requests table
-- Implements PENG-001 v2.0: Simplified PRSN/CMPY Record ID system
-- Created: January 31, 2026
-- Author: Manager
-- References: docs/PENG-001-CANDIDATEID-STRATEGY-V2.md

-- Add request_id column (USRQ-YYMMDD-NNNN format)
-- Generated immediately on form submission for tracking purposes
ALTER TABLE wp_td_user_data_change_requests
ADD COLUMN request_id VARCHAR(20) NULL UNIQUE COMMENT 'USRQ-YYMMDD-NNNN: Request tracking ID (generated on submission)' AFTER id,
ADD INDEX idx_request_id (request_id);

-- Add record_id column (PRSN/CMPY-YYMMDD-NNNN format)
-- Generated only after approval for approved entities
-- PRSN = Person (candidate, scout, operator, manager, employee)
-- CMPY = Company (employer)
ALTER TABLE wp_td_user_data_change_requests
ADD COLUMN record_id VARCHAR(20) NULL UNIQUE COMMENT 'PRSN/CMPY-YYMMDD-NNNN: Record ID for approved entities (assigned post-approval)' AFTER request_id,
ADD INDEX idx_record_id (record_id);

-- Display status
SELECT 'Record ID columns added successfully' AS Status;
SELECT COUNT(*) AS TotalRecords FROM wp_td_user_data_change_requests;
DESCRIBE wp_td_user_data_change_requests;
