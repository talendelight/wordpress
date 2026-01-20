-- Add role field and update profile method to support both LinkedIn and CV
-- Also add audit log table for comprehensive change tracking

-- Update user requests table
ALTER TABLE td_user_data_change_requests 
ADD COLUMN role ENUM('candidate', 'employer', 'scout', 'operator', 'manager') AFTER user_id,
ADD COLUMN has_linkedin BOOLEAN DEFAULT 0 AFTER profile_method,
ADD COLUMN has_cv BOOLEAN DEFAULT 0 AFTER has_linkedin;

-- Update existing records to set has_linkedin/has_cv based on profile_method
UPDATE td_user_data_change_requests 
SET has_linkedin = 1 WHERE profile_method = 'linkedin';

UPDATE td_user_data_change_requests 
SET has_cv = 1 WHERE profile_method = 'cv';

-- Create generic audit log table for tracking all database changes
CREATE TABLE IF NOT EXISTS td_audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL COMMENT 'Table being modified',
    record_id BIGINT NOT NULL COMMENT 'ID of the record being modified',
    action ENUM('insert', 'update', 'delete', 'approve', 'reject', 'undo') NOT NULL COMMENT 'Type of action',
    column_name VARCHAR(100) COMMENT 'Specific column changed (NULL for full record)',
    old_value TEXT COMMENT 'Previous value (JSON for multiple columns)',
    new_value TEXT COMMENT 'New value (JSON for multiple columns)',
    changed_by BIGINT NOT NULL COMMENT 'User ID who made the change',
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When the change occurred',
    ip_address VARCHAR(45) COMMENT 'IP address of user',
    user_agent VARCHAR(500) COMMENT 'Browser user agent',
    notes TEXT COMMENT 'Additional context or reason',
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_changed_by (changed_by),
    INDEX idx_changed_at (changed_at),
    INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Generic audit trail for all database changes';

-- Add sample role data to existing records
UPDATE td_user_data_change_requests SET role = 'candidate' WHERE id IN (1, 3, 6, 10);
UPDATE td_user_data_change_requests SET role = 'employer' WHERE id IN (2, 8, 12);
UPDATE td_user_data_change_requests SET role = 'scout' WHERE id IN (4, 7, 14);
UPDATE td_user_data_change_requests SET role = 'operator' WHERE id IN (5, 9);
UPDATE td_user_data_change_requests SET role = 'manager' WHERE id IN (11, 13, 15);
