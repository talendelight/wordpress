# Profile Management Feature Specification

**Feature ID:** WP-15  
**Feature Name:** View and Edit Profile  
**Status:** Backlog (Post-MVP)  
**Priority:** High  
**Estimated Effort:** 5 days (10 hours)  
**Dependencies:** Registration & Approval system (PENG-01), User Roles (PENG-03)  
**Version Target:** v3.8.0+  

---

## Overview

Two-page profile management system allowing users to view their complete profile information and submit edits for Manager approval.

**Key Pages:**
1. **View Profile** - Read-only display of user information
2. **Edit Profile** - Form to submit profile changes (requires approval)

---

## User Stories

**As a user**, I want to:
- View my complete profile information including my role
- Navigate to my role-specific home page from my profile
- Edit my profile information when needed
- See my changes submitted for approval before they go live

**As a Manager**, I want to:
- Approve or reject profile change requests
- See what fields changed before/after
- Maintain data quality through approval workflow

---

## Page 1: View Profile (Read-Only)

### URL
`/profile/` (existing Profile menu item)

### Layout
**Header Section:**
- Page title: "Your Profile"
- User's full name (from database)
- User's role badge (Candidate, Employer, Scout, Manager, Operator)

**Profile Information Section:**
- Display all fields from Register Profile page (read-only)
- Additional field: **Role** (displays user's current role)
- Fields organized in logical groups:
  - Personal Information (Name, Email, Phone)
  - Professional Information (varies by role - see Register Profile page)
  - Account Status (Registration date, Last updated)

**Navigation Buttons:**
1. **"Home" button** (primary, navy background)
   - Redirects to role-specific landing page
   - Uses same logic as Home menu item (candidates → /candidates/, etc.)
2. **"Edit Profile" button** (secondary, white background with navy border)
   - Opens Edit Profile page

### Design Requirements
- Use design tokens from global CSS (font-size, colors, spacing)
- Navy section headers (var(--color-navy))
- Grey field labels (var(--color-grey-medium-text))
- White background cards with rounded corners (var(--border-radius-md))
- Consistent spacing (var(--space-lg), var(--space-xl))
- Trust badges in footer

### Data Source
- Pull data from `wp_users` table (email, display_name, user_registered)
- Pull data from `wp_usermeta` table (all custom fields created during registration)
- Role from `wp_usermeta` where `meta_key = 'wp_capabilities'`

---

## Page 2: Edit Profile (Form)

### URL
`/profile/edit/`

### Layout
**Header Section:**
- Page title: "Edit Your Profile"
- Info message: "Changes require Manager approval before they take effect."

**Form Section:**
- Display all fields from Register Profile page (editable)
- **Exclude:** Role field (not editable by user)
- **Exclude:** Email (cannot be changed after registration)
- Pre-populate all fields with current user data
- Same field types and validation as Register Profile page
- Form uses WPForms or Forminator (consistent with Register Profile)

**Navigation Buttons:**
1. **"Save Changes" button** (primary, navy background)
   - Submits form
   - Creates change request in `wp_td_user_data_change_requests` table
   - Status: "Pending" (awaits Manager approval)
   - Shows success message: "Changes submitted for approval"
   - Redirects to View Profile page after 3 seconds
2. **"Cancel" button** (secondary, white background with navy border)
   - Discards changes
   - Redirects to View Profile page immediately

### Design Requirements
- Match Register Profile page layout
- Use same form styling (input fields, dropdowns, checkboxes)
- Error messages in red (var(--color-error))
- Success messages in green (var(--color-success))
- Loading spinner during save operation

### Data Handling
**On Save:**
1. Validate all fields (required checks, format validation)
2. Create record in `wp_td_user_data_change_requests`:
   - `user_id` (current user ID)
   - `field_name` (which field changed)
   - `old_value` (current value)
   - `new_value` (requested value)
   - `status` ('pending')
   - `request_date` (now())
   - `requested_by` (user_id)
3. Send notification to Manager (email + dashboard alert)
4. Redirect to View Profile with success message

**On Cancel:**
1. No database changes
2. Redirect to View Profile immediately

---

## Approval Workflow

### Manager Actions Dashboard
**New Tab:** "Profile Changes" (alongside Submitted, Approved, Rejected tabs)

**Display:**
- List of pending profile change requests
- Each row shows:
  - User name
  - Role
  - Fields changed (count)
  - Request date
  - "Review" button

**Review Modal:**
- Show before/after comparison for each changed field
- Approve button → Updates `wp_usermeta` with new values, sets request status to 'approved'
- Reject button → Sets request status to 'rejected', no data changes
- Comments field (optional feedback to user)

### User Notifications
- Email on approval: "Your profile changes have been approved"
- Email on rejection: "Your profile changes were not approved" + Manager comments
- Dashboard alert on login (if pending changes exist)

---

## Database Schema

### Existing Table (Already Created)
`wp_td_user_data_change_requests` (from PENG-017, January 2026)

**Columns:**
- `id` INT PRIMARY KEY AUTO_INCREMENT
- `user_id` BIGINT (FK to wp_users.ID)
- `field_name` VARCHAR(100) (e.g., 'first_name', 'phone', 'company')
- `old_value` TEXT (current value)
- `new_value` TEXT (requested new value)
- `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending'
- `request_date` DATETIME
- `reviewed_date` DATETIME NULL
- `reviewed_by` BIGINT NULL (FK to wp_users.ID - Manager who reviewed)
- `reviewer_comments` TEXT NULL
- `requested_by` BIGINT (FK to wp_users.ID - who made the request)

---

## Implementation Tasks

### Backend (4 days)
1. **PENG-104:** View Profile page PHP template
   - Query user data from database
   - Render read-only display
   - Home button logic (role-specific routing)
2. **PENG-105:** Edit Profile form setup
   - Pre-populate form with current user data
   - Form validation rules
3. **PENG-106:** Profile edit submission logic
   - Insert change requests into wp_td_user_data_change_requests table
   - Send Manager notification
4. **PENG-107:** Manager approval workflow (Profile Changes tab)
   - Display pending profile changes
   - Before/after comparison view
   - Approve/reject actions
   - Update wp_usermeta on approval

### Frontend (1 day)
5. **PENG-108:** Design token migration for Profile pages
   - Apply design tokens to View Profile layout
   - Apply design tokens to Edit Profile form
   - Button styles and hover states
   - Responsive layout

---

## Navigation Changes

### Profile Menu Item
**Current:** Links to WP User Manager profile page (ID 18)  
**New:** Links to View Profile page  

**Implementation:**
- Update Primary Menu item URL from `/profile/` to new View Profile page
- OR: Replace content of existing page ID 18 with View Profile template

---

## Security Considerations

1. **Authentication Required**
   - Both pages require logged-in user
   - Redirect to login if not authenticated

2. **Authorization**
   - Users can only view/edit their own profile
   - Managers can view any profile (from Manage Users)

3. **Data Validation**
   - Server-side validation (not just client-side)
   - Sanitize all inputs before database insert
   - XSS prevention

4. **Change Tracking**
   - Audit log of all profile changes
   - Who requested, who approved, when

---

## Testing Scenarios

### View Profile Page
- ✓ Logged-in user sees their data correctly
- ✓ Role field displays correct role
- ✓ Home button routes to correct landing page
- ✓ Edit button opens Edit Profile page

### Edit Profile Form
- ✓ Form pre-populated with current data
- ✓ Required validation works
- ✓ Save creates change request (not immediate update)
- ✓ Cancel discards changes
- ✓ Success message displays on save

### Manager Approval
- ✓ Pending changes appear in Manager Actions dashboard
- ✓ Before/after comparison accurate
- ✓ Approve updates wp_usermeta
- ✓ Reject does not update wp_usermeta
- ✓ User receives notification (approve/reject)

### Edge Cases
- ✓ User edits, then edits again before approval (multiple pending requests)
- ✓ Manager approves one of two pending changes
- ✓ User logs out during edit (form data preserved?)
- ✓ Concurrent edits by same user (handle race conditions)

---

## Future Enhancements (Post-v3.8.0)

1. **Profile Photo Upload**
   - Add avatar upload field
   - Image validation and resizing
   - Display in View Profile

2. **Bulk Profile Changes**
   - Manager can edit multiple profiles at once
   - CSV import for bulk updates

3. **Profile History**
   - View all historical changes (audit trail)
   - "Revert to previous version" option

4. **Self-Service Fields**
   - Allow some fields to update without approval (e.g., phone number)
   - Different approval rules per field type

5. **Profile Completeness**
   - Progress bar showing profile completion %
   - Nudges to complete missing fields

---

## Related Documentation

- [PENG-01: Registration & Approval](./PENG-01-REGISTRATION-APPROVAL.md)
- [PENG-017: User Data Change Requests Table](../docs/DATABASE.md)
- [Manager Actions Dashboard](./PENG-02-MANAGER-ACTIONS-DASHBOARD.md)
- [WORDPRESS-MVP-REQUIREMENTS.md](../../Documents/WORDPRESS-MVP-REQUIREMENTS.md)

---

**Last Updated:** March 11, 2026  
**Author:** Manager (AI-assisted)  
**Status:** Documented for Post-MVP implementation
