# Technical Recommendations: Employer Registration & Request Storage

**Date:** January 1, 2026  
**Context:** WP-01.2 Employers Page Implementation  
**Decision Needed:** Registration flow and database storage approach

---

## Q2: Employer Registration Flow

### Requirements:
- Self-registration with email verification
- Can request candidates after email verification
- KYC (Know Your Customer) required before receiving candidate information
- Need to support future multi-user company accounts (WP-04.10)

### Option A: Standard WordPress Registration + Customization ✅ **RECOMMENDED**

**Pros:**
- ✅ Built-in user management (wp_users, wp_usermeta tables)
- ✅ Email verification plugins readily available (e.g., WP User Manager, Email Verification for WooCommerce)
- ✅ Integrates with WordPress roles and capabilities system
- ✅ Faster MVP implementation (1-2 days vs 5-7 days)
- ✅ Login/logout/password reset all built-in
- ✅ Compatible with future passwordless login plugins (WP-04.5)
- ✅ Can customize registration form fields via hooks/plugins
- ✅ Supports redirect-back after login (built-in WordPress feature)

**Cons:**
- ⚠️ Registration page styling needs customization
- ⚠️ Default WordPress registration is basic (but extensible)
- ⚠️ Email templates need customization

**Implementation Approach:**
1. Enable WordPress user registration: `Settings → General → Membership`
2. Install email verification plugin (e.g., [WP User Manager](https://wordpress.org/plugins/wp-user-manager/) - free, 100k+ installs)
3. Create custom "Employer" role via plugin or custom code
4. Customize registration form to add fields:
   - Company Name
   - Company Website
   - Phone Number (optional)
   - How did you hear about us? (optional)
5. Add email verification requirement before login
6. Customize email templates (verification, welcome)
7. Add KYC workflow:
   - User meta flag: `kyc_status` (pending/verified/rejected)
   - Employers can submit requests after email verification
   - Operators/Admins can view/download candidate details only if employer KYC = verified
   - Display KYC status in employer dashboard (future WP-01.8)

**Estimated Time:** 2-3 days

---

### Option B: Custom Registration Form

**Pros:**
- ✅ Full control over UX and fields
- ✅ Can build exactly what you need
- ✅ No plugin dependencies

**Cons:**
- ❌ Must build email verification from scratch
- ❌ Must handle user creation, login, password reset manually
- ❌ More code to maintain
- ❌ Longer implementation time
- ❌ Security risks if not implemented correctly

**Implementation Approach:**
1. Create custom registration form page
2. Handle form submission with PHP
3. Create user in wp_users table
4. Generate verification token, store in wp_usermeta
5. Send verification email with link
6. Build verification handler page
7. Build custom login form
8. Build password reset flow

**Estimated Time:** 5-7 days

---

### Recommendation: **Option A - Standard WordPress Registration + Customization**

**Rationale:**
- MVP-friendly (faster to market)
- Leverages WordPress core capabilities
- Easier to maintain and extend
- Better security (battle-tested WordPress core)
- Plugins like WP User Manager provide professional email verification
- Future-compatible with passwordless login and other auth methods

**Next Steps:**
1. Install WP User Manager (or similar)
2. Create "Employer" custom role
3. Configure registration form fields
4. Set up email verification
5. Add KYC workflow logic
6. Customize email templates

---

## Q4: Database Storage for Employer Requests

### Requirements:
- Store employer hiring requests
- Fields: Company name, company website, role title, tech stack, urgency, description
- Support multiple roles per request
- MVP: Submit only (no editing)
- Future: Request history dashboard (WP-01.8)
- Future: Status tracking (submitted, in-progress, shortlist-sent, completed)

### Option A: Custom Post Type (CPT) ✅ **RECOMMENDED**

**Pros:**
- ✅ WordPress-native approach
- ✅ Built-in workflow support (post_status: draft, publish, custom statuses)
- ✅ Revision history automatically tracked
- ✅ Easy to add custom columns to admin list view
- ✅ Integrates with WordPress search and filters
- ✅ Can use Advanced Custom Fields (ACF) or custom meta boxes for fields
- ✅ Supports attachments (if employer wants to attach documents later)
- ✅ Easy RBAC: use post_author to link to employer user
- ✅ Can add comments for internal notes (future)
- ✅ Export plugins (WP All Export) work out of the box

**Cons:**
- ⚠️ wp_posts table gets larger (but WordPress handles millions of posts fine)
- ⚠️ Post meta queries can be slower than custom table (but acceptable for MVP scale)

**Implementation Approach:**
1. Register custom post type: `td_employer_request`
   ```php
   - post_title: Auto-generated (e.g., "Request #12345 - Acme Corp")
   - post_content: Main description field
   - post_author: Employer user ID (automatic)
   - post_status: pending (submitted), processing, shortlist-sent, completed, cancelled
   ```

2. Custom fields (post meta):
   ```
   _company_name: string
   _company_website: URL
   _company_details: text
   _urgency: dropdown (urgent/normal/flexible)
   _roles: repeater field (array of roles)
     - role_title: string
     - tech_stack: text/array
   _submitted_date: datetime
   _response_due_date: datetime (submitted + 2 business days)
   _kyc_required: boolean (always true initially)
   _internal_notes: text (operators only)
   ```

3. Custom admin columns:
   - Company Name
   - Submitted Date
   - Urgency
   - Status
   - Assigned To (operator)

4. RBAC:
   - Employers can only view their own requests (post_author check)
   - Operators/Admins can view all requests
   - Custom capabilities: `read_employer_requests`, `edit_employer_requests`

**Estimated Time:** 3-4 days

---

### Option B: Custom Database Table

**Pros:**
- ✅ Cleaner data model
- ✅ Better performance for complex queries (if thousands of requests)
- ✅ More control over schema

**Cons:**
- ❌ Must build admin UI from scratch (list view, edit screen)
- ❌ No built-in revision history
- ❌ Must handle RBAC manually
- ❌ Export functionality must be custom-built
- ❌ No integration with existing WordPress tools
- ❌ More code to maintain

**Implementation Approach:**
1. Create custom table: `wp_employer_requests`
2. Create custom table: `wp_employer_request_roles` (many-to-many)
3. Build admin list page
4. Build edit/view page
5. Handle form submissions
6. Build export functionality
7. Implement RBAC checks

**Estimated Time:** 7-10 days

---

### Recommendation: **Option A - Custom Post Type**

**Rationale:**
- WordPress-native approach = faster MVP
- Built-in workflow and status management
- Easier to build admin UI (use WordPress admin customization hooks)
- Post author linking gives automatic RBAC foundation
- Easy to display in employer dashboard (future WP-01.8)
- Better for MVP scale (< 10,000 requests = CPT is fine)
- Can migrate to custom table later if performance becomes issue

**Schema Design:**

```
Custom Post Type: td_employer_request
- post_title: "Request #{ID} - {Company Name}"
- post_content: Main description
- post_author: Employer user ID
- post_status: 
  - pending (submitted, waiting for review)
  - processing (operator assigned, working on it)
  - shortlist_sent (candidates shared with employer)
  - completed (employer hired or closed)
  - cancelled (employer cancelled request)
  - on_hold (paused by employer or ops)

Post Meta:
- _company_name: text
- _company_website: URL
- _company_details: textarea
- _urgency: select (urgent|normal|flexible)
- _roles: serialized array or JSON
  [
    {
      "role_title": "Senior Backend Engineer",
      "tech_stack": "Java, Spring Boot, PostgreSQL, AWS"
    },
    {
      "role_title": "DevOps Engineer",
      "tech_stack": "Kubernetes, Terraform, GitHub Actions"
    }
  ]
- _submitted_at: datetime
- _sla_due_date: datetime (submitted + 2 business days)
- _assigned_to: user ID (operator)
- _internal_notes: text (operator notes, not visible to employer)
- _kyc_verified: boolean
```

**Implementation Steps:**
1. Create custom post type registration
2. Register custom meta boxes for fields
3. Build form submission handler
4. Customize admin list columns
5. Add status badges and filters
6. Set up email notifications (confirmation + ops notification)
7. Add RBAC restrictions

---

## Supporting Features Needed

### Email Verification Plugin
**Recommended:** [WP User Manager](https://wordpress.org/plugins/wp-user-manager/)
- Free, actively maintained
- Email verification with customizable templates
- Custom registration fields
- Login/registration form customization
- Role assignment on registration

**Alternative:** [Email Verification for WordPress](https://wordpress.org/plugins/email-verification/)

---

### Custom Post Type Management
**Recommended:** Build custom code (better control for MVP)

**Alternative:** [Custom Post Type UI](https://wordpress.org/plugins/custom-post-type-ui/) (faster for prototyping)

---

### Form Builder for Request Form
**Recommended:** Custom form (better control, lighter weight)

**Alternative:** [WPForms](https://wordpress.org/plugins/wpforms-lite/) (already installed, can use for MVP)

---

## Implementation Order

1. **Phase 1: Role & Registration** (Days 1-2)
   - Create Employer custom role
   - Install/configure WP User Manager
   - Customize registration form
   - Set up email verification

2. **Phase 2: Request Storage** (Days 3-4)
   - Create custom post type
   - Build request form
   - Set up form submission handler
   - Add post meta fields

3. **Phase 3: Admin Interface** (Days 5-6)
   - Customize admin list view
   - Add status badges
   - Set up email notifications
   - Add RBAC restrictions

4. **Phase 4: Testing** (Day 7)
   - Test registration flow
   - Test request submission
   - Test email notifications
   - Test RBAC (employers can only see own requests)

**Total Estimated Time:** 7-8 days for complete implementation

---

## Security Considerations

1. **Email Verification:**
   - Generate secure token (32+ characters)
   - Set token expiry (24 hours)
   - Single-use tokens (delete after verification)

2. **Request Form:**
   - Use WordPress nonces for CSRF protection
   - Sanitize all inputs
   - Validate email format, URLs
   - Rate limit submissions (prevent spam)

3. **RBAC:**
   - Check `current_user_can()` before showing any request data
   - Use post_author check for employer own-data access
   - Never expose employer data to other employers
   - Operators need `edit_others_posts` capability

4. **KYC Workflow:**
   - Store KYC status in user meta: `kyc_status`
   - Check KYC status before showing candidate details
   - Display "KYC pending" message to employers
   - Admin can update KYC status via user edit screen

---

## Open Questions for Clarification

1. **KYC Process:**
   - What information do you need from employers for KYC? (Company registration number, documents?)
   - Who performs KYC verification? (Operator manually, or automated service?)
   - How long does KYC typically take?

2. **Multiple Roles:**
   - Should there be a limit on number of roles per request? (e.g., max 5?)
   - Can employer add roles after initial submission, or locked after submit?

3. **Urgency Field:**
   - Does urgency affect SLA? (Still 2 business days regardless?)
   - How do operators prioritize urgent requests?

4. **Company Accounts (WP-04.10 future):**
   - When multiple users from same company, do they share requests or each has own?
   - Primary account holder vs invited users - different permissions?

---

## Recommendation Summary

✅ **Use Standard WordPress Registration with WP User Manager plugin**  
✅ **Use Custom Post Type for employer requests**  
✅ **Implement KYC as user meta flag with manual verification workflow**  
✅ **Use WordPress roles and capabilities for RBAC**

This approach gives you:
- Fastest path to MVP (7-8 days full implementation)
- Built on WordPress core principles
- Easy to extend for future features
- Professional email verification
- Solid security foundation
- Good performance for expected scale

---

**Next Steps:**
1. Confirm KYC process details
2. Finalize request form fields
3. Begin implementation Phase 1 (roles & registration)
4. Continue with wireframe session for Employers public marketing page

**Document Version:** 1.0  
**Status:** Pending Approval
