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

### 2. Candidates Landing Page Design Token Migration (PENG-090)
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

### 3. Employers Landing Page Design Token Migration (PENG-091)
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

### 4. Scouts Landing Page Design Token Migration (PENG-092)
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

### 5. Managers Landing Page Design Token Migration (PENG-093)
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

### 6. Operators Landing Page Design Token Migration (PENG-094)
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
