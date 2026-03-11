# Release Notes - v3.7.1

**Version:** 3.7.1 (PATCH)  
**Release Date:** March 10, 2026  
**Status:** 🟡 In Progress  
**Session Date:** March 9-10, 2026

---

## 📦 Release Summary

**Theme:** Design Token Migration - Landing Pages

This release continues Phase 2B design token migration (Round 2: Landing Pages). Migrating 5 role-based landing pages: Candidates, Employers, Scouts, Managers, and Operators. All pages will use consistent design tokens for fonts, colors, spacing, and branding with HireAccord identity. Also includes logo layout improvement (horizontal: image left of text).

**Type:** PATCH (incremental migration work, no new features)

---

## 🎯 Features

### 1. Logo Layout Horizontal (MKTB-036)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Changes:**
- Modified `.site-branding` container to use flexbox layout
- Changed logo layout from vertical (logo above text) to horizontal (logo left of text)
- Added `flex-direction: row`, `align-items: center`, `gap: 12px`
- Set logo image `max-height: 48px`, `width: auto`
- Maintained Red Hat Display Black 900 font for "HireAccord" text

**Files:**
- `wp-content/themes/blocksy-child/style.css` (lines 355-390)

**Deployment:** Include in code deployment (theme CSS)

---

### 2. Replace Logo and Favicon with HireAccord Files (MKTB-037)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Replace site logo with HireAccord_logo_original.png (139KB high-res PNG)
- Replace favicon with apple-touch-icon.png (19KB)
- Files located in: `restore/assets/images/hireaccord/`
- Local: Logo ID 73, Favicon ID 74
- Production: TBD (deploy during v3.7.1)

**Deployment Commands:**
```powershell
# Copy files to production
scp -P 65002 -i "tmp/hostinger_deploy_key" "restore/assets/images/hireaccord/HireAccord_logo_original.png" u909075950@45.84.205.129:/tmp/hireaccord-logo.png
scp -P 65002 -i "tmp/hostinger_deploy_key" "restore/assets/images/hireaccord/apple-touch-icon.png" u909075950@45.84.205.129:/tmp/hireaccord-favicon.png

# Import to WordPress media library and update settings
ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129 << 'EOF'
cd /home/u909075950/domains/hireaccord.com/public_html
LOGO_ID=$(wp media import /tmp/hireaccord-logo.png --title="HireAccord Logo" --porcelain --allow-root)
FAVICON_ID=$(wp media import /tmp/hireaccord-favicon.png --title="HireAccord Favicon" --porcelain --allow-root)
wp theme mod set custom_logo $LOGO_ID --allow-root
wp option update site_icon $FAVICON_ID --allow-root
rm /tmp/hireaccord-logo.png /tmp/hireaccord-favicon.png
wp cache flush --allow-root
echo "Logo ID: $LOGO_ID, Favicon ID: $FAVICON_ID"
EOF
```

---

### 3. Rename Welcome Page to About Us (MKTB-038)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Changes:**
- Renamed "Welcome" page to "About Us"
- Updated page title: "Welcome" → "About Us"
- Updated page slug: `welcome` → `about-us`
- Updated Primary Menu item: "Welcome" → "About Us"
- File renamed: `restore/pages/welcome-6.html` → `restore/pages/about-us-6.html`

**Page IDs:**
- Local: 6
- Production: 6
- URL: `/about-us/` (was `/welcome/`)

**Menu Item IDs:**
- Local: 40 (Primary Menu)
- Production: TBD

**Deployment Commands:**
```bash
# Production deployment
ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129 << 'EOF'
cd /home/u909075950/domains/hireaccord.com/public_html

# Update page title and slug
wp post update 6 --post_title="About Us" --post_name="about-us" --allow-root

# Find menu item ID for Welcome in Primary Menu
MENU_ITEM_ID=$(wp menu item list 2 --fields=db_id,title --format=csv --allow-root | grep "Welcome" | cut -d',' -f1)

# Update menu item title
wp menu item update $MENU_ITEM_ID --title="About Us" --allow-root

# Flush cache
wp cache flush --allow-root

echo "Page renamed and menu updated successfully"
EOF
```

---

### 4. Add Conditional Home Menu Item (PENG-095)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Changes:**
- Added "Home" menu item that appears only for logged-in users
- Menu item displays at first position (before "About Us")
- Role-based landing page mapping:
  - Candidates → `/candidates/`
  - Employers → `/employers/`
  - Scouts → `/scouts/`
  - Managers → `/managers/`
  - Operators → `/operators/`
- Administrators don't see Home menu item (no dedicated landing page)

**Implementation:**
- Modified `wp_nav_menu_objects` filter in functions.php
- Dynamically adds Home menu item based on user's role
- Menu item ID: 999999 (programmatically generated)

**Files:**
- `wp-content/themes/blocksy-child/functions.php` (lines 226-285)

**Deployment:** Include in code deployment (theme functions.php)

**User Experience:**
- **Logged out**: Menu shows → About Us | Register | Login | Help
- **Logged in**: Menu shows → **Home** | About Us | Profile | Help | Logout
  - Home points to role-specific landing page

---

### 5. Candidates Landing Page Design Token Migration (PENG-090)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (headings, body text, CTAs)
- Color tokens (navy headers, grey text, blue buttons)
- Spacing tokens (margins, padding, gaps)
- Border radius tokens (cards, buttons)
- HireAccord branding (logo, footer, copyright)
- SVG icon standardization (18px)

**Page IDs:**
- Local: 21
- Production: 17
- URL: `/candidates/`

**Files:**
- `restore/pages/candidates-21.html` (to be created)
- `tmp/restore-candidates-17.php` (deployment script)

---

### 6. Employers Landing Page Design Token Migration (PENG-091)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (headings, body text, CTAs)
- Color tokens (navy headers, grey text, blue buttons)
- Spacing tokens (margins, padding, gaps)
- Border radius tokens (cards, buttons)
- HireAccord branding (logo, footer, copyright)
- SVG icon standardization (18px)

**Page IDs:**
- Local: 22
- Production: 16
- URL: `/employers/`

**Files:**
- `restore/pages/employers-22.html` (to be created)
- `tmp/restore-employers-16.php` (deployment script)

---

### 7. Scouts Landing Page Design Token Migration (PENG-092)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (headings, body text, CTAs)
- Color tokens (navy headers, grey text, blue buttons)
- Spacing tokens (margins, padding, gaps)
- Border radius tokens (cards, buttons)
- HireAccord branding (logo, footer, copyright)
- SVG icon standardization (18px)

**Page IDs:**
- Local: 23
- Production: 18
- URL: `/scouts/`

**Files:**
- `restore/pages/scouts-23.html` (to be created)
- `tmp/restore-scouts-18.php` (deployment script)

---

### 8. Managers Landing Page Design Token Migration (PENG-093)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (headings, body text, CTAs)
- Color tokens (navy headers, grey text, blue buttons)
- Spacing tokens (margins, padding, gaps)
- Border radius tokens (cards, buttons)
- HireAccord branding (logo, footer, copyright)
- SVG icon standardization (18px)

**Page IDs:**
- Local: 24
- Production: 19
- URL: `/managers/`

**Files:**
- `restore/pages/managers-24.html` (to be created)
- `tmp/restore-managers-19.php` (deployment script)

---

### 9. Operators Landing Page Design Token Migration (PENG-094)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (headings, body text, CTAs)
- Color tokens (navy headers, grey text, blue buttons)
- Spacing tokens (margins, padding, gaps)
- Border radius tokens (cards, buttons)
- HireAccord branding (logo, footer, copyright)
- SVG icon standardization (18px)

**Page IDs:**
- Local: 25
- Production: 20
- URL: `/operators/`

**Files:**
- `restore/pages/operators-25.html` (to be created)
- `tmp/restore-operators-20.php` (deployment script)

---

### 10. Remove Search Icon and Modal from Header (MKTB-039)
**Status:** ✅ Completed | **Priority:** LOW

**Changes:**
- Hidden search button/icon in header navigation
- Hidden search modal/overlay that appears on click
- Used CSS `display: none !important` to hide all search-related elements
- Targets: `.ct-search-button`, `.ct-icon-search`, `.search-icon`, `.ct-header-search`, `.ct-search-modal`, `.ct-search-box`

**Rationale:**
- Search functionality not needed for current site structure
- Simplifies header navigation UI
- Reduces visual clutter for users

**Files:**
- `wp-content/themes/blocksy-child/style.css` (lines 431-448)

**Deployment:** Include in code deployment (theme CSS)

---

## 📄 Affected Pages

| Page | Slug | Local ID | Prod ID | Change Type | Notes |
|------|------|----------|---------|-------------|-------|
| Register | /register/ | 16 | TBD | Major Update | Design token migration |
| Password Reset | /password-reset/ | 15 | TBD | Major Update | Design token migration |
| Account | /account/ | 17 | TBD | Major Update | Design token migration |
| Profile | /profile/ | 18 | TBD | Major Update | Design token migration |

---

## 🚀 Deployment Steps

### Prerequisites
- Backup production: `pwsh infra/shared/scripts/wp-action.ps1 backup`

### Deployment Process (Per Page)
1. Export local page: `podman exec wp wp post get {ID} --field=post_content --allow-root --skip-plugins > restore/pages/{page}-{ID}.html`
2. Find production page ID: `ssh ... wp post list --fields=ID,post_title | grep "{Page Name}"`
3. Create restore script: `tmp/restore-{page}-{prod_id}.php`
4. Upload to production:
   ```powershell
   scp -P 65002 -i "tmp/hostinger_deploy_key" "restore/pages/{page}-{ID}.html" u909075950@45.84.205.129:/tmp/
   scp -P 65002 -i "tmp/hostinger_deploy_key" "tmp/restore-{page}-{prod_id}.php" u909075950@45.84.205.129:/home/u909075950/domains/hireaccord.com/public_html/
   ```
5. Execute: `ssh ... 'cd ... && php restore-{page}-{prod_id}.php && rm restore-{page}-{prod_id}.php'`
6. Cleanup: `ssh ... 'rm /tmp/{page}-{ID}.html ; wp cache flush --allow-root'`

---

## ✅ Verification Checklist

**Per Page:**
- [ ] Page displays with design tokens
- [ ] Font sizes use var(--font-size-*)
- [ ] Colors use var(--color-navy), var(--color-grey-medium-text)
- [ ] Spacing uses var(--space-*)
- [ ] Borders use var(--border-radius-*)
- [ ] HireAccord branding (not TalenDelight)
- [ ] No inline pixel values for fonts
- [ ] No inline hex colors
- [ ] No grey spacer strips
- [ ] Footer icons 18px (if applicable)
- [ ] No errors in browser console
- [ ] Cache flushed

---

## 🔙 Rollback Procedure

```powershell
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

---

## 📊 Migration Progress

**Phase 2B: Design Token Migration**
- **Previous (v3.7.0):** 4 pages (Welcome, Select Role, Register Profile, Help)
- **This Release (v3.7.1):** 5 landing pages (Candidates, Employers, Scouts, Managers, Operators) + logo layout improvement
- **Total After v3.7.1:** 9 of 22 pages (41%)
- **Remaining:** 13 pages (auth 4, admin 3, utility 6)
- **Next release:** v3.7.2 - Auth flow pages OR Admin pages (decide based on priority)

---

## 🐛 Known Issues

None

---

## ⚠️ Breaking Changes

None - all changes backward-compatible

---

## 📚 Documentation

- Pattern usage: [docs/lessons/pattern-usage-consistency.md](docs/lessons/pattern-usage-consistency.md)
- Design system: [docs/DESIGN-SYSTEM.md](docs/DESIGN-SYSTEM.md)
- Page deployment: [docs/procedures/PAGE-UPDATE-WORKFLOW.md](docs/procedures/PAGE-UPDATE-WORKFLOW.md)

---

## 🎯 Next Release

**v3.7.2** - Auth Flow Pages OR Admin Pages (TBD):

**Option A - Auth Flow:**
- Register page (ID 16)
- Password Reset page (ID 15)
- Account page (ID 17)
- Profile page (ID 18)

**Option B - Admin Pages:**
- Manager Admin page
- Manager Actions page
- Operator Actions page

**Target:** Complete all 22 pages before Sprint 1 (March 17, 2026)

---

**Release Manager:** GitHub Copilot + User  
**Session Date:** March 9-10, 2026  
**Deployment Date:** TBD
