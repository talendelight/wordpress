# GitHub Issues for Migration Tasks

## Completed Issues (Closed)

### Issue #1: PENG-055 - Design System Foundation
**Status:** ✅ Closed (v3.5.0 - Feb 8, 2026)
```
Title: [MIGRATION] Design System Foundation (CSS variables + GenerateBlocks)
Labels: migration, gutenberg, done, v3.5.0
Milestone: v3.5.0
```

**Deliverables:**
- CSS custom properties in `blocksy-child/style.css`
- GenerateBlocks plugin installed
- Typography scale defined
- Spacing system defined
- Button styles (50px border-radius)

---

### Issue #2: PENG-056 - Block Patterns Library
**Status:** ✅ Closed (v3.5.1 - Feb 9, 2026)
```
Title: [MIGRATION] Create reusable block patterns (hero, cards, CTA, footer)
Labels: migration, gutenberg, done, v3.5.1
Milestone: v3.5.1
```

**Deliverables:**
- 10 production patterns registered
- Pattern documentation in `docs/PATTERN-LIBRARY.md`
- Patterns: card-grid-3, card-grid-2-2, hero-single-cta, cta-primary, footer-trust-badges, etc.

---

### Issue #3: PENG-057 - Welcome Page Migration
**Status:** ✅ Closed (v3.5.1 - Feb 8, 2026)
```
Title: [MIGRATION] Migrate Welcome page (ID 6) to Gutenberg
Labels: migration, gutenberg, done, v3.5.1, page-migration
Milestone: v3.5.1
```

**Deliverables:**
- Welcome page migrated to Gutenberg blocks
- First successful pattern usage
- Performance improvement documented
- Export: `restore/pages/welcome-6-gutenberg.html`

---

### Issue #4: PENG-058 - Register Profile Page Migration
**Status:** ✅ Closed (v3.6.1 - Feb 11, 2026)
```
Title: [MIGRATION] Migrate Register Profile page (ID 79) to Gutenberg
Labels: migration, gutenberg, done, v3.6.1, page-migration, critical
Milestone: v3.6.1
```

**Deliverables:**
- Register Profile page migrated
- Forminator shortcode integration
- Trust badges pattern applied
- Export: `restore/pages/register-profile-79.html`

---

### Issue #5: PENG-059 - Managers Landing Page Migration
**Status:** ✅ Closed (v3.6.1 - Feb 10, 2026)
```
Title: [MIGRATION] Migrate Managers landing page (ID 8) to Gutenberg
Labels: migration, gutenberg, done, v3.6.1, page-migration
Milestone: v3.6.1
```

**Deliverables:**
- Managers page migrated with 9-card grid
- Navigation tiles using card-grid-3 pattern
- Export: `restore/pages/managers-8.html`

---

### Issue #6: PENG-060 - Manager Admin Page Migration
**Status:** ✅ Closed (v3.6.2 - Feb 12, 2026)
```
Title: [MIGRATION] Migrate Manager Admin page (ID 10) to Gutenberg
Labels: migration, gutenberg, done, v3.6.2, page-migration, complex
Milestone: v3.6.2
```

**Deliverables:**
- Manager Admin page with 4-tab dashboard
- Shortcode integration for user requests table
- JavaScript tab switching
- Export: `restore/pages/manager-admin-10.html`

---

### Issue #7: PENG-061 - Manager Actions Page Migration
**Status:** ✅ Closed (v3.6.2 - Feb 12, 2026)
```
Title: [MIGRATION] Migrate Manager Actions page (ID 84) to Gutenberg
Labels: migration, gutenberg, done, v3.6.2, page-migration, complex
Milestone: v3.6.2
```

**Deliverables:**
- Manager Actions page with 5-tab workflow
- AJAX-driven action buttons
- Color-coded tab backgrounds
- Export: `restore/pages/manager-actions-84.html`

---

## Open Issues (To Do)

### Issue #8: PENG-062 - Simple Pages Migration
**Status:** 📋 Open (v3.7.0 - Feb 15-16, 2026)
```
Title: [MIGRATION] Migrate simple pages (Help, 403, Sample, Privacy)
Labels: migration, gutenberg, todo, v3.7.0, page-migration
Milestone: v3.7.0
Assignee: Manager
Priority: Medium
```

**Scope:**
- Help page (ID 15)
- 403 Forbidden (ID 44)
- Sample Page (ID 2)
- Privacy Policy (ID 3)

**Dependencies:** PENG-055, PENG-056

---

### Issue #9: PENG-063 - Candidates Page Migration
**Status:** 📋 Open (v3.7.0 - Feb 17, 2026)
```
Title: [MIGRATION] Migrate Candidates landing page (ID 7) to Gutenberg
Labels: migration, gutenberg, todo, v3.7.0, page-migration, high-priority
Milestone: v3.7.0
Assignee: Manager
Priority: High
```

**Scope:**
- Candidates landing page with CV submission form
- Forminator integration

**Dependencies:** PENG-055, PENG-056, PENG-017

---

### Issue #10: PENG-064 - Employers Page Migration
**Status:** 📋 Open (v3.7.0 - Feb 18, 2026)
```
Title: [MIGRATION] Migrate Employers landing page (ID 64) to Gutenberg
Labels: migration, gutenberg, todo, v3.7.0, page-migration, high-priority
Milestone: v3.7.0
Assignee: Manager
Priority: High
```

**Scope:**
- Employers landing page with request candidates form
- Forminator integration

**Dependencies:** PENG-055, PENG-056, PENG-018

---

### Issue #11: PENG-065 - Scouts Page Migration
**Status:** 📋 Open (v3.7.0 - Feb 19, 2026)
```
Title: [MIGRATION] Migrate Scouts landing page (ID 76) to Gutenberg
Labels: migration, gutenberg, todo, v3.7.0, page-migration
Milestone: v3.7.0
Assignee: Manager
Priority: Medium
```

**Scope:**
- Scouts landing page with partner submission
- Forminator integration

**Dependencies:** PENG-055, PENG-056, PENG-019

---

### Issue #12: PENG-066 - Operators Page Migration
**Status:** 📋 Open (v3.7.0 - Feb 20, 2026)
```
Title: [MIGRATION] Migrate Operators landing page (ID 9) to Gutenberg
Labels: migration, gutenberg, todo, v3.7.0, page-migration
Milestone: v3.7.0
Assignee: Manager
Priority: Medium
```

**Scope:**
- Operators landing page with dashboard navigation

**Dependencies:** PENG-055, PENG-056

---

### Issue #13: PENG-067 - Select Role Page Migration
**Status:** 📋 Open (v3.7.0 - Feb 21, 2026)
```
Title: [MIGRATION] Migrate Select Role page (ID 78) to Gutenberg
Labels: migration, gutenberg, todo, v3.7.0, page-migration, critical
Milestone: v3.7.0
Assignee: Manager
Priority: Critical
```

**Scope:**
- Select Role page (registration flow entry point)
- Custom PHP template migration

**Dependencies:** PENG-055, PENG-056

---

### Issue #14: PENG-068 - Auth Pages Styling
**Status:** 📋 Open (v3.7.0 - Feb 22-23, 2026)
```
Title: [MIGRATION] Style WPUM auth pages (Login, Reset, Register, Account, Profile)
Labels: migration, gutenberg, todo, v3.7.0, styling
Milestone: v3.7.0
Assignee: Manager
Priority: Medium
```

**Scope:**
- CSS overrides for WPUM shortcode pages
- Login (ID 26)
- Password Reset (ID 27)
- Register (ID 28)
- Account (ID 29)
- Profile (ID 30)

**Dependencies:** PENG-055

---

### Issue #15: PENG-069 - Migration Testing & Optimization
**Status:** 📋 Open (v3.7.0 - Feb 24-26, 2026)
```
Title: [MIGRATION] Migration testing & optimization (all pages)
Labels: migration, gutenberg, todo, v3.7.0, testing, critical
Milestone: v3.7.0
Assignee: Manager
Priority: Critical
```

**Scope:**
- Responsive testing (all breakpoints)
- Cross-browser testing
- Performance benchmarking (Lighthouse)
- Accessibility audit (WCAG 2.1 AA)
- Load testing

**Dependencies:** All PENG-055 through PENG-068

---

### Issue #16: PENG-070 - Elementor Plugin Removal & Cleanup
**Status:** 📋 Open (v3.7.0 - Feb 27-28, 2026)
```
Title: [MIGRATION] Remove Elementor plugin & cleanup
Labels: migration, gutenberg, todo, v3.7.0, cleanup, critical
Milestone: v3.7.0
Assignee: Manager
Priority: Critical
```

**Scope:**
- Deactivate Elementor plugin
- Remove Elementor data from database
- Clean up unused assets
- Update documentation
- Git commit with migration complete notes

**Dependencies:** PENG-069

---

## Milestones

### v3.5.0 - Design System Foundation (Done)
- PENG-055: Design System ✅

### v3.5.1 - Pattern Library & First Migration (Done)
- PENG-056: Block Patterns ✅
- PENG-057: Welcome Page ✅

### v3.6.1 - Registration Flow Pages (Done)
- PENG-058: Register Profile ✅
- PENG-059: Managers Landing ✅

### v3.6.2 - Complex Dashboard Pages (Done)
- PENG-060: Manager Admin ✅
- PENG-061: Manager Actions ✅

### v3.7.0 - Complete Migration & Cleanup (In Progress)
- PENG-062: Simple Pages 📋
- PENG-063: Candidates Page 📋
- PENG-064: Employers Page 📋
- PENG-065: Scouts Page 📋
- PENG-066: Operators Page 📋
- PENG-067: Select Role Page 📋
- PENG-068: Auth Pages Styling 📋
- PENG-069: Testing & Optimization 📋
- PENG-070: Elementor Cleanup 📋

---

## Labels

- `migration` - Elementor to Gutenberg migration work
- `gutenberg` - Gutenberg block editor related
- `done` - Task completed
- `todo` - Task not yet started
- `in-progress` - Task currently being worked on
- `page-migration` - Specific page migration
- `styling` - CSS/design work only (no content migration)
- `testing` - Testing and quality assurance
- `cleanup` - Cleanup and documentation work
- `critical` - Blocks MVP or registration flow
- `high-priority` - Important but not blocking
- `complex` - Complex page with tabs, AJAX, or custom functionality

---

## How to Create Issues

**Via GitHub CLI:**
```bash
# Create issue for PENG-062
gh issue create \
  --title "[MIGRATION] Migrate simple pages (Help, 403, Sample, Privacy)" \
  --body "See migration-task template in docs/templates/TEMPLATE-MIGRATION-TASK.md" \
  --label "migration,gutenberg,todo,v3.7.0,page-migration" \
  --milestone "v3.7.0" \
  --assignee "@me"
```

**Via GitHub Web:**
1. Go to repository Issues tab
2. Click "New Issue"
3. Select "Gutenberg Migration Task" template
4. Fill in details from this guide
5. Assign labels and milestone

---

## Progress Tracking

**Completed:** 7 of 16 tasks (44%)  
**Remaining:** 9 of 16 tasks (56%)  
**Target Completion:** February 28, 2026

**Timeline:**
- Feb 7-12: Foundation & Early Migrations (7 tasks) ✅
- Feb 15-23: Remaining Page Migrations (7 tasks) 📋
- Feb 24-28: Testing & Cleanup (2 tasks) 📋
