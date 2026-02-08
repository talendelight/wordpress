# Deployment Workflow Summary

**Related Documentation:**
- [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) - Slug-based ID lookups and cross-environment ID mapping
- [Quick Reference](QUICK-REFERENCE-DEPLOYMENT.md) - Command cheat sheet
- [Release Process](RELEASE-NOTES-PROCESS.md) - Release lifecycle workflow

---

## What Changed (v3.1.0 Implementation)

### Problems Discovered
1. **PowerShell encoding corruption** - Unicode characters in Elementor JSON exports were corrupted when piped through PowerShell
2. **Bash escaping issues** - Special characters in JSON broke shell command substitution
3. **WordPress meta API limitations** - `update_post_meta()` failed on large/complex data
4. **Size limitations** - Command-line arguments couldn't handle 30KB+ JSON data

### Solutions Implemented

#### 1. Export Script (PowerShell)
**Location:** `infra/shared/scripts/export-elementor-pages.ps1`

**What it does:**
- Exports Elementor pages from local WordPress container
- Uses `podman cp` for binary-safe file transfer (no encoding corruption)
- Reads page mappings from `infra/shared/elementor-manifest.json`
- Outputs to `tmp/elementor-exports/`

**Usage:**
```powershell
pwsh infra/shared/scripts/export-elementor-pages.ps1
```

#### 2. Import Script (PHP)
**Location:** `infra/shared/scripts/import-elementor-pages.php`

**What it does:**
- Imports Elementor pages on production using manifest
- Direct database operations (bypasses WordPress API)
- Supports dry-run mode for testing
- Comprehensive error handling and logging

**Usage:**
```bash
# On production
cd /domains/talendelight.com/public_html
wp eval-file ~/elementor-exports/import-elementor-pages.php

# Dry run (no changes)
ELEMENTOR_DRY_RUN=true wp eval-file ~/elementor-exports/import-elementor-pages.php
```

#### 3. Manifest File
**Location:** `infra/shared/elementor-manifest.json`

**What it defines:**
- Page ID mappings (local → production)
- Form ID mappings for cross-references
- Slugs for dynamic lookups (see [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md))
- File names for exports
- URLs for verification
- Version and description

**Important:** Always use slug-based lookups instead of hardcoded IDs. See [ID-MANAGEMENT-STRATEGY.md](ID-MANAGEMENT-STRATEGY.md) for details.

#### 4. Release Instructions (Dual Format)

**Human-readable:** `.github/releases/archive/RELEASE-v3.1.0.md` (after release)
- Detailed step-by-step instructions
- Context and reasoning
- Manual verification steps

**Machine-readable:** `.github/releases/v3.1.0.json`
- JSON schema for automation
- Step types: `deploy_code`, `deploy_elementor`, `clear_cache`, `manual`
- Parsed by GitHub Actions workflow

#### 5. Updated GitHub Actions
**Location:** `.github/workflows/deploy.yml`

**Changes:**
- Reads latest release instructions from `.github/releases/`
- Supports manual workflow dispatch with version override
- Deploys code automatically
- Provides instructions for Elementor deployment (semi-automatic)
- Clears caches after deployment
- Shows manual verification checklist

### 6. Custom CSS Deployment
**Location:** `infra/shared/scripts/deploy-custom-css.php`

**What it does:**
- Deploys CSS from `config/custom-css/` to WordPress Additional CSS
- Uses PHP script via `wp eval-file` to avoid command-line limitations
- Updates theme mods directly via WordPress API
- Handles large files (8KB+) and special characters

**Usage:**
```bash
# 1. Combine CSS files
$combined = (Get-Content config/custom-css/*.css -Raw) -join "`n`n"
Set-Content tmp/combined-custom.css -Value $combined

# 2. Upload to production
scp -i tmp/hostinger_deploy_key -P 65002 tmp/combined-custom.css u909075950@45.84.205.129:~/custom.css
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/scripts/deploy-custom-css.php u909075950@45.84.205.129:~/

# 3. Deploy
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd public_html && wp eval-file ~/deploy-custom-css.php"
```

**Why not wp-cli theme mod set:** Command substitution fails with large/complex CSS files. See [wordpress-custom-css-deployment.md](lessons/wordpress-custom-css-deployment.md) for details.

---

### Key Lessons Documented

1. **[elementor-cli-deployment.md](lessons/elementor-cli-deployment.md)**
   - Full journey from CLI attempts to working solution
   - Why Elementor CLI export doesn't exist for individual pages
   - Comparison of different approaches (GUI, CLI, REST API)

2. **[powershell-encoding-corruption.md](lessons/powershell-encoding-corruption.md)**
   - Specific warning about PowerShell encoding issues
   - Quick reference for correct vs incorrect approaches
   - Always-use/never-use patterns

3. **[TEMPLATE-ELEMENTOR-DEPLOYMENT.md](templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md)**
   - Step-by-step template for future deployments
   - Includes rollback procedures
   - Verification checklist

4. **[RELEASE-INSTRUCTIONS-FORMAT.md](docs/RELEASE-INSTRUCTIONS-FORMAT.md)**
   - Schema for machine-readable release files
   - Step type definitions
   - Integration with CI/CD

### Current File Structure

```
wordpress/
├── .github/
│   ├── releases/
│   │   ├── archive/
│   │   │   └── v3.1.0.json          # Archived completed releases
│   │   └── v3.2.0.json              # Active release instructions
│   └── workflows/
│       └── deploy.yml               # Updated with release automation
├── docs/
│   ├── lessons/
│   │   ├── elementor-cli-deployment.md
│   │   └── powershell-encoding-corruption.md
│   ├── templates/
│   │   └── TEMPLATE-ELEMENTOR-DEPLOYMENT.md
│   ├── DEPLOYMENT-WORKFLOW.md           # Master guide
│   ├── QUICK-REFERENCE-DEPLOYMENT.md    # Cheat sheet
│   └── RELEASE-INSTRUCTIONS-FORMAT.md   # Schema docs
├── infra/
│   └── shared/
│       ├── scripts/
│       │   ├── export-elementor-pages.ps1   # Export script
│       │   └── import-elementor-pages.php   # Import script
│       └── elementor-manifest.json          # Page mappings
└── tmp/
    ├── elementor-exports/           # Export output (gitignored)
    │   ├── homepage.json
    │   ├── employers.json
    │   ├── candidates.json
    │   ├── scouts.json
    │   ├── access-restricted.json
    │   └── manifest.json
    ├── update-all-pages.php         # Deprecated (marked)
    └── *-from-container.json        # Clean exports (kept for reference)
```

### Deployment Workflow (New)

#### For Developers

1. **Make changes in local WordPress**
   - Edit pages in Elementor
   - Test locally at http://localhost:8080

2. **Export pages**
   ```powershell
   pwsh infra/shared/scripts/export-elementor-pages.ps1
   ```

3. **Commit changes**
   ```bash
   git add tmp/elementor-exports/
   git commit -m "Export Elementor pages for v3.1.0"
   ```

4. **Push to main**
   ```bash
   git push origin main
   ```

5. **GitHub Actions deploys code automatically**
   - Deploys `wp-content/` (themes, plugins, uploads)
   - **Assets automatically included** (theme images, logos, SVGs)
   - Shows manual steps for Elementor/database changes

6. **Deploy assets if added new ones**
   ```bash
   # Assets are tracked in Git and auto-deploy with code
   # Manual upload only if needed:
   scp -i tmp/hostinger_deploy_key -P 65002 \
     wp-content/themes/blocksy-child/assets/images/* \
     u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/assets/images/
   ```
   - Themes and plugins deployed via SCP
   - Cache cleared
   - Manual Elementor deployment instructions shown

6. **Complete Elementor deployment (manual)**
   ```bash
   # Upload exports and script
   scp -r tmp/elementor-exports/ u909075950@45.84.205.129:~/
   
   # Execute import
   ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp eval-file ~/elementor-exports/import-elementor-pages.php"
   ```

7. **Verify deployment**
   - Check URLs listed in release instructions
   - Confirm Unicode characters render (✅ ❌)
   - Test responsive layout

#### For Future Automation

To make Elementor deployment fully automatic in CI/CD:
- ✅ Export script that avoids PowerShell corruption
- ✅ Import script that handles binary data correctly
- ✅ Manifest-based configuration
- ⚠️ Challenge: Exports require local WordPress running
- ⚠️ Challenge: GitHub Actions doesn't have access to local dev environment
- 💡 Solution: Commit exports to git as part of development (trade-off: larger repo)

### What's Still Manual

1. **Elementor page deployment** - Requires SSH and WP-CLI execution
2. **CSS deployment** - Currently manual via WordPress admin
3. **Database changes** - Must be manually applied via phpMyAdmin or WP-CLI
4. **Final verification** - Human review of deployed pages

### What's Automated

1. **Code deployment** - Themes and plugins via rsync/SCP
2. **Cache clearing** - Elementor and LiteSpeed caches
3. **Release versioning** - Via JSON manifests
4. **Deployment instructions** - Shown in GitHub Actions output

### Obsolete Files (Cleaned Up)

Deleted:
- `tmp/deploy-new-pages.php` - Replaced by `import-elementor-pages.php`
- `tmp/deploy-pages.sh` - Shell script approach didn't work
- `tmp/insert-candidates-db.php` - Single-page version, replaced by batch script
- `tmp/insert-scouts-db.php` - Single-page version, replaced by batch script
- `tmp/update-scouts.php` - Old version with issues
- `tmp/*-elementor.json` - Corrupted exports (PowerShell encoding)
- `tmp/*-elementor-utf8.json` - Still corrupted, wrong approach
- `tmp/scouts-*.json` - Multiple failed attempts
- `tmp/export-*.json` - Old naming convention

Marked as deprecated (kept for reference):
- `tmp/update-all-pages.php` - Working but version-specific, use generic script

Kept for reference:
- `tmp/*-from-container.json` - Clean exports from successful deployment
- `tmp/README.md` - Documentation of tmp/ directory purpose

### Next Steps for Future Releases

1. **Create release notes** - Follow `RELEASE-NOTES-PROCESS.md`
2. **Update manifest** - Edit `infra/shared/elementor-manifest.json` with new version
3. **Backup new assets** - Copy any new images/logos to `restore/assets/`
4. **Export pages** - Run export script
5. **Create release JSON** - Copy and modify `.github/releases/v3.1.0.json`
6. **Commit and push** - GitHub Actions handles the rest (includes assets)
7. **Complete manual steps** - Follow instructions in Actions output
8. **Verify** - Use checklist from release instructions (including asset URLs)

---

## Asset Restoration After Issues

If assets are missing or corrupted on production:

### Quick Restore from Backup
```bash
# Restore single asset
scp -i tmp/hostinger_deploy_key -P 65002 \
  restore/assets/images/eu-logo.svg \
  u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/assets/images/

# Restore all assets
scp -i tmp/hostinger_deploy_key -P 65002 -r \
  restore/assets/images/* \
  u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/assets/images/
```

### Restore from Git
```bash
# On production, pull latest assets from Git
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd public_html
git checkout main -- wp-content/themes/blocksy-child/assets/
```

**See [restore/ASSETS-RESTORE.md](../restore/ASSETS-RESTORE.md) for complete asset restoration guide.**

---

### Success Metrics

✅ All 5 pages deployed successfully
✅ Unicode characters render correctly (✅ ❌ not u2705/u274c)
✅ Compliance footer visible on all pages
✅ Login CSS applied (blue glow effect)
✅ No encoding corruption
✅ Reusable scripts for future deployments
✅ Documentation for future team members
✅ Semi-automated workflow (balance of automation and safety)
