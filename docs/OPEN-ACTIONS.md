# Consolidated Open Actions

This document consolidates all open actions from standalone open actions files (excluding those within feature documents).

---

## Forminator Integration - Approver & Comments Mapping

**Status**: Database schema updated (2026-01-20), field mapping pending

The `td_user_data_change_requests` table now includes:
- `approver_id` (bigint) - References wp_users.ID for the manager who approved/rejected
- `comments` (text) - Approval/rejection notes from manager

### Open Actions
1. **Map approver_id in Manager Admin page**
   - When manager approves/rejects a request, populate approver_id with current user ID
   - Update: `UPDATE td_user_data_change_requests SET approver_id = %d, status = 'approved' WHERE id = %d`
   
2. **Add comments field to approval workflow**
   - Add textarea in Manager Admin page for approval/rejection comments
   - Store comments when changing status (approve/reject/undo actions)
   - Display comments in request history/audit trail

3. **Display approver information**
   - Show approver name in Manager Admin table (JOIN with wp_users)
   - Show approval timestamp (updated_date)
   - Show comments in modal/expanded view

---

## Manager & Operator Registration

- As of 2026-01-18, the Select Role page only allows self-registration for Candidate, Employer, and Scout roles.
- Manager and Operator accounts are not available for self-registration.
- These accounts will be created by an admin or via a separate, restricted screen.

### Open Actions
1. **Design and implement a secure Manager/Operator creation screen**
   - Accessible only to authorized users (e.g., Super Admin).
   - Should allow input of required fields (name, email, role, etc.).
   - Should trigger notification to the new user with login details or activation link.
   - Must log all actions for audit/compliance.
2. **Document the workflow for admin-created users**
   - Update feature specs and onboarding documentation.
   - Add instructions for admins on how to use the new screen.
3. **Update UI/UX to clarify registration restrictions**
   - Add notes to the Select Role and registration pages indicating that Manager/Operator accounts are created by admin only.
4. **Test and validate the restricted registration flow**
   - Ensure only authorized users can access the creation screen.
   - Verify audit trail and notification delivery.

---

*Last consolidated: 2026-01-18*
