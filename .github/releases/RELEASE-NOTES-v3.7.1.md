# Release Notes - v3.7.1

**Version:** 3.7.1 (PATCH)  
**Release Date:** March 10, 2026  
**Status:** 🟡 In Progress  
**Session Date:** March 9-10, 2026

---

## 📦 Release Summary

**Theme:** Design Token Migration - Auth Flow Pages

This release continues Phase 2B design token migration (Round 2: Auth Flow). Migrating 4 authentication/user flow pages: Register, Password Reset, Account, and Profile. All pages will use consistent design tokens for fonts, colors, spacing, and branding with HireAccord identity.

**Type:** PATCH (incremental migration work, no new features)

---

## 🎯 Planned Features

### 1. Register Page Design Token Migration (PENG-072)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (all patterns)
- Color tokens (navy headers, grey text)
- Spacing tokens (margins, padding)
- HireAccord branding
- Border radius tokens

**Files:**
- `restore/pages/register-16.html` (to be created)
- `tmp/restore-register-{prod_id}.php` (deployment script)

---

### 2. Password Reset Page Design Token Migration (PENG-073)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (all patterns)
- Color tokens (navy headers, grey text)
- Spacing tokens (margins, padding)
- HireAccord branding
- Border radius tokens

**Files:**
- `restore/pages/password-reset-15.html` (to be created)
- `tmp/restore-password-reset-{prod_id}.php` (deployment script)

---

### 3. Account Page Design Token Migration (PENG-074)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (all patterns)
- Color tokens (navy headers, grey text)
- Spacing tokens (margins, padding)
- HireAccord branding
- Border radius tokens

**Files:**
- `restore/pages/account-17.html` (to be created)
- `tmp/restore-account-{prod_id}.php` (deployment script)

---

### 4. Profile Page Design Token Migration (PENG-075)
**Status:** ⏳ Not Started | **Priority:** HIGH

**Changes:**
- Font size tokens (all patterns)
- Color tokens (navy headers, grey text)
- Spacing tokens (margins, padding)
- HireAccord branding
- Border radius tokens

**Files:**
- `restore/pages/profile-18.html` (to be created)
- `tmp/restore-profile-{prod_id}.php` (deployment script)

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
- **This Release (v3.7.1):** 4 pages (Register, Password Reset, Account, Profile)
- **Total After v3.7.1:** 8 of 22 pages (36%)
- **Remaining:** 14 pages (landing pages 5, admin 3, utility 6)
- **Next release:** v3.7.2 - Landing pages (Candidates, Employers, Scouts, Managers, Operators)

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

**v3.7.2** - Landing Pages Migration:
- Candidates landing page
- Employers landing page
- Scouts landing page
- Managers landing page
- Operators landing page

**Target:** Complete all 22 pages before Sprint 1 (March 17, 2026)

---

**Release Manager:** GitHub Copilot + User  
**Session Date:** March 9-10, 2026  
**Deployment Date:** TBD
