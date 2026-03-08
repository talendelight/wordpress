# Release Notes - v3.7.0

**Version:** 3.7.0 (MINOR)  
**Release Date:** March 10, 2026  
**Status:** ✅ Ready for Deployment  
**Session Date:** March 9, 2026

---

## 📦 Release Summary

**Theme:** Help Page Design Token Migration + CSS Improvements + Logo Font + Navigation Styling

This release continues the design token migration (Phase 2B - 18% complete: 4 of 22 pages). Help page fully migrated with consistent colors, fonts, spacing, and branding. Added Red Hat Display Black 900 font for site logo. Enhanced navigation styling (navy logo/menu, blue active state). Fixed footer copyright system with custom override. All changes maintain consistency with Welcome and Select Role pages.

**Type:** MINOR (new features, visual improvements, backward-compatible)

---

## ✨ Completed Features

### 1. Help Page Design Token Migration (PENG-070)
**Status:** ✅ Completed | **Priority:** HIGH

**Changes:**
- **Font sizes**: 7 patterns migrated (48px→5xl, 36px→4xl, 24px→2xl, 20px→xl, 18px→lg, 16px→base, 14px→sm)
- **Branding**: TalenDelight → HireAccord, talendelight.com → hireaccord.com
- **Footer icons**: Emoji (🛡️, 🔒, ⚖️) → SVG images (18px height standardized)
- **Buttons**: Navy background for card buttons (Learn More, Manage Account, Get Help)
- **Colors**: Navy headers (var(--color-navy) = #063970), grey descriptions (var(--color-grey-medium-text) = #898989)
- **Borders**: All cards use var(--border-radius-md)
- **Total CSS variables**: 40+

**Files:**
- `restore/pages/help-7.html` (270 lines)
- `tmp/restore-help-7.php` (deployment script)

---

### 2. Red Hat Display Black 900 Font for Logo (MKTB-033)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Implementation:**
- Google Fonts enqueued in `functions.php` (lines 54-59)
- Design tokens added: `--font-logo`, `--font-weight-black: 900`
- Applied to site logo: 24px, -0.5px letter-spacing, navy color
- Documented in 3 design docs

**Files:**
- `wp-content/themes/blocksy-child/functions.php`
- `wp-content/themes/blocksy-child/design-tokens.css`
- `wp-content/themes/blocksy-child/style.css`
- `Documents/WORDPRESS-UI-DESIGN.md`
- `Documents/COMMON-UI-DESIGN.md`
- `docs/DESIGN-SYSTEM.md`

---

### 3. Navigation Menu Styling (MKTB-034)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Changes:**
- **Logo text**: Navy color (var(--color-navy) = #063970)
- **Menu items default**: Navy color
- **Menu items active**: Blue (var(--color-navy-hover) = #0062e3), font-weight 600, underline with 4px offset
- **Search icon**: Navy color + fill for SVG

**Selectors:** 15+ CSS selectors covering all navigation scenarios

**Files:**
- `wp-content/themes/blocksy-child/style.css` (lines 379-410)

---

### 4. Button Styling Fix (PENG-071)
**Status:** ✅ Completed | **Priority:** HIGH

**Problem:** Buttons with `is-style-fill` + `has-navy-background-color` showed grey instead of navy

**Solution:** Added CSS override rule:
```css
.wp-block-button.is-style-fill .wp-block-button__link.has-navy-background-color {
    background-color: var(--color-navy) !important;
    color: var(--color-white) !important;
}
```

**Files:**
- `wp-content/themes/blocksy-child/style.css` (lines 207-211)

---

### 5. Footer Copyright Custom Override (MKTB-032)
**Status:** ✅ Completed | **Priority:** MEDIUM

**Implementation:**
- Created `wp-content/themes/blocksy-child/footer.php` (custom override, Blocksy Pro not required)
- Reads `copyright_text` theme mod
- Replaces `{current_year}` placeholder with `date('Y')`
- Decodes HTML entities (&copy; → ©)
- Renders: "Copyright © 2026 - HireAccord. A brand of Lochness Technologies LLP. All rights reserved."

**Files:**
- `wp-content/themes/blocksy-child/footer.php`
- `infra/shared/db/260308-1600-update-footer-copyright.sql` (production deployment reference)

---

## 📄 Affected Pages

| Page | Slug | Local ID | Prod ID | Change Type | Notes |
|------|------|----------|---------|-------------|-------|
| Help | /help/ | 7 | 7 | Major Update | Complete design token migration, 40+ CSS variables, HireAccord branding, SVG icons, navy buttons |

---

## 📂 Modified Files

**WordPress Theme:**
- `wp-content/themes/blocksy-child/footer.php` (new - custom copyright)
- `wp-content/themes/blocksy-child/functions.php` (Google Fonts enqueue)
- `wp-content/themes/blocksy-child/design-tokens.css` (font tokens)
- `wp-content/themes/blocksy-child/style.css` (logo, navigation, button fixes)

**Page Backups:**
- `restore/pages/help-7.html`
- `tmp/restore-help-7.php`

**Database:**
- `infra/shared/db/260308-1600-update-footer-copyright.sql`

**Documentation:**
- `Documents/WORDPRESS-UI-DESIGN.md`
- `Documents/COMMON-UI-DESIGN.md`
- `docs/DESIGN-SYSTEM.md`

---

## 🚀 Deployment Steps

### Prerequisites
- Backup production: `pwsh infra/shared/scripts/wp-action.ps1 backup`

### Code Deployment
1. Stage changes: `git add .`
2. Commit: `git commit -m "v3.7.0: Help page design tokens + CSS improvements + logo font"`
3. Push develop: `git push origin develop`
4. Merge to main: `git checkout main && git merge develop --no-edit && git push origin main`
5. Wait 30 seconds for Hostinger auto-deployment

### Content Deployment
6. Deploy Help page:
   ```powershell
   scp -P 65002 -i "tmp/hostinger_deploy_key" "restore/pages/help-7.html" u909075950@45.84.205.129:/tmp/
   scp -P 65002 -i "tmp/hostinger_deploy_key" "tmp/restore-help-7.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/
   ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && php restore-help-7.php && rm restore-help-7.php"
   ```

7. Update footer copyright (production):
   ```bash
   ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129
   cd /home/u909075950/domains/talendelight.com/public_html
   wp theme mod set copyright_text 'Copyright &copy; {current_year} - HireAccord. A brand of Lochness Technologies LLP. All rights reserved.' --allow-root --skip-plugins
   wp cache flush --allow-root
   ```

8. Clear cache: `wp cache flush --allow-root`
9. Health check: `pwsh infra/shared/scripts/wp-action.ps1 verify`

---

## ✅ Verification Checklist

- [ ] Help page displays at /help/ with design tokens
- [ ] Help page buttons (Learn More, Manage Account, Get Help) show navy color
- [ ] Help page section headers use navy color (#063970)
- [ ] Help page descriptions/answers use grey (#898989)
- [ ] Help page footer icons display as SVG (18px height)
- [ ] Help page cards use var(--border-radius-md)
- [ ] Site logo displays in Red Hat Display Black 900 font
- [ ] Logo text is navy color (#063970)
- [ ] Menu items display in navy color by default
- [ ] Active menu item shows blue (#0062e3) with underline
- [ ] Search icon shows navy color
- [ ] Footer copyright displays: "Copyright © 2026 - HireAccord. A brand of Lochness Technologies LLP. All rights reserved."
- [ ] Footer copyright shows © symbol (not &copy;)
- [ ] No grey buttons on Help page
- [ ] No errors in browser console
- [ ] No errors in production logs
- [ ] Health check passes (18+ checks)

---

## 🔙 Rollback Procedure

```powershell
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

---

## 📊 Migration Progress

**Phase 2B: Design Token Migration**
- **Completed:** 4 pages (Welcome ID 6, Select Role ID 9, Register Profile ID 28, Help ID 7)
- **Remaining:** 18 pages (auth flow 4, landing pages 5, admin 3, utility 6)
- **Progress:** 18% (4 of 22 pages)
- **Next release:** v3.8.0 - Continue migration

---

## 🐛 Known Issues

None

---

## ⚠️ Breaking Changes

None - all changes backward-compatible

---

## 📚 Documentation

- `restore/pages/help-7.html` - Help page backup (local page ID 7)
- `tmp/restore-help-7.php` - Deployment script
- `infra/shared/db/260308-1600-update-footer-copyright.sql` - Footer copyright commands
- `Documents/WORDPRESS-UI-DESIGN.md` - Typography with logo font
- `Documents/COMMON-UI-DESIGN.md` - Typography with logo font
- `docs/DESIGN-SYSTEM.md` - Font families with --font-logo token
- `docs/procedures/PAGE-UPDATE-WORKFLOW.md` - Page deployment workflow

---

## 🎯 Next Release

**v3.8.0** - Continue design token migration:
- Auth flow pages (Register ID 16, Password Reset ID 15, Account ID 17, Profile ID 18)
- Landing pages (Candidates, Employers, Scouts, Managers, Operators)
- Admin pages (Manager Admin, Manager Actions, Operator Actions)
- Utility pages (Terms, Privacy, 403, others)

**Target:** Complete all 22 pages before Sprint 1 (March 17, 2026)

---

**Release Manager:** GitHub Copilot + User  
**Session Date:** March 9, 2026  
**Deployment Date:** March 10, 2026 (scheduled)
