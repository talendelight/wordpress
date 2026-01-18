# Consolidated Open Actions

This document consolidates all open actions from standalone open actions files (excluding those within feature documents).

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
