-- Migration: Add ID Sequences Helper Table
-- Date: 2026-01-31 13:00
-- Purpose: Create helper table for atomic ID sequence generation
-- Related: PENG-016 (Record ID generation implementation)
--
-- This table manages daily-reset sequences for 3 entity types:
-- - USRQ: User request IDs (tracks submission attempts)
-- - PRSN: Person record IDs (permanent user identity for individuals)
-- - CMPY: Company record IDs (permanent user identity for organizations)
--
-- Composite primary key (entity_type, date_str) ensures:
-- 1. Atomic sequence increments (prevents race conditions)
-- 2. Automatic daily reset (new date = new row)
-- 3. Independent sequences per entity type

CREATE TABLE IF NOT EXISTS wp_td_id_sequences (
    entity_type ENUM('USRQ', 'PRSN', 'CMPY') NOT NULL COMMENT 'ID prefix type: User Request, Person, Company',
    date_str CHAR(6) NOT NULL COMMENT 'YYMMDD format (e.g., 260131 for Jan 31, 2026)',
    last_sequence INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Last used sequence number for this entity+date',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'First ID generated for this entity+date',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last ID generated',
    PRIMARY KEY (entity_type, date_str)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Atomic sequence management for daily-reset ID generation';

-- Example usage pattern:
-- INSERT INTO wp_td_id_sequences (entity_type, date_str, last_sequence)
-- VALUES ('USRQ', '260131', 1)
-- ON DUPLICATE KEY UPDATE last_sequence = last_sequence + 1;
--
-- Result:
-- - First call: Creates row with last_sequence=1, returns 1
-- - Second call: Updates to last_sequence=2, returns 2
-- - Next day: New date_str creates new row, sequence resets to 1
