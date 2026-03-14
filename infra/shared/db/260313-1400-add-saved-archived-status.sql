-- Migration: Add 'saved' and 'archived' status values
-- Date: 2026-03-13 14:00
-- Description: Add new status values for Save and Archive actions
--              Requests with these statuses will not appear in normal tabs
--              and will be shown in separate future feature screens

ALTER TABLE wp_td_user_data_change_requests 
MODIFY COLUMN status ENUM('new','pending','approved','rejected','saved','archived') 
DEFAULT 'new';
