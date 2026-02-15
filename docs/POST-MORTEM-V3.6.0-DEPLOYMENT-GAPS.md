# Post-Mortem: v3.6.0 Deployment Gaps

**Date:** February 11, 2026  
**Version:** v3.6.0  
**Incident:** Critical components missing from production after deployment

---

## What Went Wrong

After deploying v3.6.0 (PENG-054 API Security Hardening), production was missing:

1. **Landing pages for all 5 user roles** (Employers, Candidates, Scouts, Managers, Operators)
2. **Primary menu** with all navigation items (only showed Welcome + Help)
3. **talendelight-roles plugin** was inactive (custom roles didn't exist)
4. **Help page** was missing

### Impact
- Users logging in were redirected to generic `/account/` page instead of role-specific landing pages
- Navigation menu was broken
- Login redirect logic couldn't work without pages existing
- First-time login experience was broken

---

## Root Cause Analysis

### 1. Pages Are Not in wp-content/

**Problem:** Landing pages are **WordPress database content**, not code in `wp-content/`

**What deploys automatically:**
```
wp-content/
├── themes/        ✅ Auto-deploys via Git
├── plugins/       ✅ Auto-deploys via Git
└── mu-plugins/    ✅ Auto-deploys via Git
```

**What doesn't deploy:**
- Pages (stored in `wp_posts` database table)
- Menus (stored in `wp_terms`, `wp_term_taxonomy`, `wp_term_relationships`)
- Options (stored in `wp_options`)

**Why this happened:**
- Our deployment process focuses on **code** (Git push → Hostinger auto-deploy)
- We have Elementor page export/import scripts for complex pages
- But **simple Gutenberg pages** were never documented in deployment process
- **Assumed pages would "just exist"** on production

### 2. No "Bootstrap Production" Checklist

**Problem:** We have deployment docs for **updates**, but not for **initial environment setup**

**Existing documentation:**
- ✅ DEPLOYMENT-WORKFLOW.md - How to deploy Elementor pages (incremental updates)
- ✅ QUICK-REFERENCE-DEPLOYMENT.md - Commands for existing pages
- ✅ RELEASE-NOTES-PROCESS.md - Release workflow for code changes
- ❌ Missing: "Production Bootstrap" - How to initialize a fresh production environment

**What we forgot:**
- Landing pages must be created on production (one-time setup)
- Menus must be configured (one-time setup)
- Plugins must be activated (one-time setup)
- Custom roles exist only after plugin activation

### 3. Local Development Masking the Problem

**Problem:** Local environment has full page history from development work

**Local pages (built over time):**
```bash
ID  Title           When Created        Why
64  Employers       Dec 2025           v3.1.0 feature
7   Candidates      Dec 2025           v3.1.0 feature
76  Scouts          Dec 2025           v3.1.0 feature
8   Managers        Jan 2026           v3.2.0 feature
9   Operators       Jan 2026           v3.3.0 feature
141 Help            Jan 2026           v3.4.0 feature
```

**Production pages (only WPUM auto-generated):**
```bash
ID  Title           Created
11  Log In          Feb 2026 (WPUM activation)
14  Account         Feb 2026 (WPUM activation)
6   Welcome         Unknown (manual?)
```

**Why this is a trap:**
- Local works perfectly → "Everything works, ship it!"
- Production doesn't have same page history
- No automated check for "required pages exist"
- Login redirects fail silently → Users just go to /account/

### 4. Plugin Activation Forgotten

**Problem:** `talendelight-roles` plugin wasn't active on production

**Why this happened:**
- Plugin was developed and added to Git
- Git auto-deployed the plugin file to production
- **But plugins don't auto-activate** - that's a WordPress database setting
- No checklist item for "Activate new plugins on production"

**Cascading failure:**
1. Plugin inactive → Custom roles don't exist
2. Can't create test users with `td_candidate` role → "Role doesn't exist" error
3. Login redirect logic exists in plugin → But never runs (plugin inactive)
4. Even if users existed, login redirects wouldn't work without pages

---

## Prevention Strategy

### Immediate Fix (Done)
✅ Created all 6 landing pages on production  
✅ Created Primary Menu with all 7 items  
✅ Activated talendelight-roles plugin  
✅ Created 5 test users for manual validation  
✅ Configured menu locations  
✅ Flushed caches and permalinks  

### Long-Term Fixes Needed

#### 1. Create Production Bootstrap Checklist

**New Document:** `docs/PRODUCTION-BOOTSTRAP-CHECKLIST.md`

**Contents:**
- [ ] One-time setup steps for fresh production environment
- [ ] Required plugins to activate
- [ ] Required pages to create (with export sources)
- [ ] Required menus to configure
- [ ] Required options to set
- [ ] Test user creation
- [ ] Verification tests

#### 2. Update Deployment Workflow

**Add to DEPLOYMENT-WORKFLOW.md:**
- Pre-deployment check: "Do required pages exist on production?"
- New section: "Deploying New Pages (First Time)"
- Reference to page export/import scripts for Gutenberg pages
- Plugin activation checklist

#### 3. Add Production Health Checks

**New Script:** `infra/shared/scripts/verify-production-health.php`

**Checks:**
- Required pages exist (by slug: employers, candidates, scouts, managers, operators, help, welcome)
- Required plugins active (talendelight-roles, wp-user-manager, blocksy-companion)
- Required custom roles exist (td_candidate, td_employer, td_scout, td_operator, td_manager)
- Primary menu exists and has items
- Menu locations are configured
- Login redirect logic is working

**Usage:**
```bash
pwsh infra/shared/scripts/wp-action.ps1 health-check
# Outputs: ✅ or ❌ for each requirement
```

#### 4. Automated Page Sync Script

**New Tool:** `infra/shared/scripts/sync-pages.ps1`

**Purpose:** Export Gutenberg pages from local → Import to production

**Features:**
- Reads page list from manifest: `infra/shared/page-manifest.json`
- Exports HTML from local (like Elementor export)
- Creates PHP import script (like Elementor import)
- Idempotent: Won't overwrite existing pages unless forced
- Includes menu creation

**Manifest Structure:**
```json
{
  "version": "3.6.0",
  "pages": [
    {
      "slug": "employers",
      "title": "Employers",
      "export_from_local_id": 64,
      "menu_order": 1,
      "menu_item": true
    },
    ...
  ],
  "menus": [
    {
      "name": "Primary Menu",
      "location": "primary",
      "items": ["welcome", "employers", "candidates", "scouts", "managers", "operators", "help"]
    }
  ]
}
```

**Usage:**
```powershell
# Export pages from local
pwsh infra/shared/scripts/sync-pages.ps1 -Action export

# Import to production
pwsh infra/shared/scripts/sync-pages.ps1 -Action import
```

#### 5. Update Release Process

**Add to RELEASE-NOTES-PROCESS.md:**

**New Phase:** "Environment Validation" (runs before deployment)

**Steps:**
1. Run health check on production
2. Identify missing components
3. Run bootstrap/sync scripts if needed
4. Re-run health check → All green
5. Proceed with code deployment

**Phase Workflow:**
```
Planning → Development → Pre-Release → Environment Validation → Deployment → Post-Deployment
                                        ^^^^ NEW PHASE ^^^^
```

---

## Key Lessons

### 1. Database Content ≠ Code
- Git only deploys **code** (themes, plugins, configs)
- Database content (pages, posts, options, menus) requires **separate deployment process**
- Can't assume production has same content as local

### 2. Local Success ≠ Production Success
- Local environment accumulates work over time
- Production starts from clean state (or last deployment)
- Need explicit checklist for "what must exist on production"

### 3. Silent Failures Are Dangerous
- Login redirects failed silently → Users just got generic /account/ page
- No error messages → "It works!" (but not as intended)
- Need automated checks for critical paths

### 4. One-Time Setup vs Incremental Updates
- Our process handles **incremental updates** well (code changes)
- Our process fails at **one-time setup** (new pages, plugins, menus)
- Need separate workflow for "bootstrap new features"

### 5. Activation is a Manual Step
- Deploying plugin code ≠ Activating plugin
- Deploying page HTML ≠ Creating page in database
- Deploying menu config ≠ Assigning menu to location
- Need explicit activation/creation steps in deployment checklist

---

## Action Items

**Priority 1 (This Week):**
- [ ] Create PRODUCTION-BOOTSTRAP-CHECKLIST.md
- [ ] Update DEPLOYMENT-WORKFLOW.md with page deployment section
- [ ] Create verify-production-health.php script
- [ ] Add health check to wp-action.ps1 dispatcher

**Priority 2 (Next Week):**
- [ ] Create page-manifest.json for all required pages
- [ ] Create sync-pages.ps1 script (export + import)
- [ ] Update RELEASE-NOTES-PROCESS.md with Environment Validation phase
- [ ] Document in copilot-instructions.md

**Priority 3 (Before Next Release):**
- [ ] Run health check on production before v3.6.1 deployment
- [ ] Test sync-pages.ps1 on staging environment (if available)
- [ ] Add automated health check to GitHub Actions workflow

---

## Timeline

**Incident Discovery:** February 11, 2026 - User reported missing menus after v3.6.0 deployment  
**Root Cause Identified:** Same day - Pages never deployed, plugin inactive  
**Immediate Fix Applied:** Same day - Manual creation of pages, menus, test users  
**Post-Mortem Written:** Same day  
**Prevention Plan:** In progress  

---

## Related Documentation

- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Current deployment process (code-focused)
- [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) - Release lifecycle
- [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) - Command reference
- [WORDPRESS-MVP-REQUIREMENTS.md](../../Documents/WORDPRESS-MVP-REQUIREMENTS.md) - What should exist in production
- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Database schema and content strategy
