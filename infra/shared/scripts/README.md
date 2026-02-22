# Script Registry & Action Dispatcher

**Created**: February 8, 2026  
**Purpose**: Central command registry for all WordPress operations  
**Incident**: Implemented after Welcome page disappeared from production

## Background

On February 8, 2026, the Welcome page (homepage) disappeared from production between deployment sessions. Investigation revealed:
- No backup system in place
- No automated verification after deployment
- No standard restore procedures
- tmp/ folder had 100+ one-time scripts with no organization

This system was created to prevent future incidents and provide:
1. Automated backup before every deployment
2. Automated verification after every deployment
3. One-command restore capability (5-10 minute recovery)
4. Clear organization and documentation

## Quick Reference

```powershell
# Use wp-action.ps1 as the main entry point
pwsh infra/shared/scripts/wp-action.ps1 <action> [arguments]
```

## Available Actions

### Production Operations

| Action | Script | Description |
|--------|--------|-------------|
| `backup` | `backup-production.ps1` | Create timestamped backup (pages, options, theme, patterns, database) |
| `verify` | `verify-production.ps1` | Check production state (18+ validation checks) |
| `restore` | `restore-production.ps1` | Restore from timestamped backup |

### Development Operations

| Action | Script | Description |
|--------|--------|-------------|
| `export-elementor` | `export-elementor-pages.ps1` | Export Elementor pages from local WordPress |

### Informational

| Action | Script | Description |
|--------|--------|-------------|
| `deploy` | *(built-in)* | Show deployment workflow (backup → push → verify) |
| `help` | *(built-in)* | Show help for actions |

## Examples

### Get Help
```powershell
# General help
pwsh infra/shared/scripts/wp-action.ps1 help

# Specific action help
pwsh infra/shared/scripts/wp-action.ps1 help backup
pwsh infra/shared/scripts/wp-action.ps1 help restore
```

### Backup Production
```powershell
# Standard backup (no database)
pwsh infra/shared/scripts/wp-action.ps1 backup

# With database (weekly recommended)
pwsh infra/shared/scripts/wp-action.ps1 backup -BackupDatabase $true

# Custom retention
pwsh infra/shared/scripts/wp-action.ps1 backup -MaxBackups 20
```

### Verify Production
```powershell
# Check all critical items
pwsh infra/shared/scripts/wp-action.ps1 verify

# With auto-fix (future)
pwsh infra/shared/scripts/wp-action.ps1 verify -Fix
```

### Restore Production
```powershell
# Restore pages from latest backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# Restore pages and options
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true -RestoreOptions $true

# Restore specific backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp 20260208-1430 -RestorePages $true

# Dry run (no changes)
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -DryRun

# Full restore including database (DESTRUCTIVE)
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true -RestoreOptions $true -RestoreTheme $true -RestoreDatabase $true
```

### Export Elementor Pages
```powershell
# Export to tmp/elementor-exports/
pwsh infra/shared/scripts/wp-action.ps1 export-elementor
```

### Show Deployment Workflow
```powershell
# Display complete deployment process
pwsh infra/shared/scripts/wp-action.ps1 deploy
```

## Script Registry Structure

```powershell
$SCRIPT_REGISTRY = @{
    'action-name' = @{
        script = 'script-filename.ps1'        # Implementation script
        description = 'What the action does'  # Help text
        usage = 'wp-action <action> [args]'   # Usage pattern
        examples = @(...)                      # Example commands
    }
}
```

## Adding New Actions

To add a new action to the registry:

1. **Create the implementation script** in `infra/shared/scripts/`
2. **Update `wp-action.ps1`** registry:
   ```powershell
   'my-action' = @{
       script = 'my-script.ps1'
       description = 'What my action does'
       usage = 'wp-action my-action [-Parameter $value]'
       examples = @(
           'wp-action my-action',
           'wp-action my-action -Parameter $true'
       )
   }
   ```
3. **Update ValidateSet** in param block:
   ```powershell
   [ValidateSet(
       'backup', 'verify', 'restore', 
       'export-elementor', 'deploy', 
       'my-action',  # Add here
       'help'
   )]
   ```
4. **Test the new action**:
   ```powershell
   pwsh infra/shared/scripts/wp-action.ps1 help my-action
   pwsh infra/shared/scripts/wp-action.ps1 my-action
   ```
5. **Document** in this file and relevant docs

## Current Scripts Inventory

### Production Operations

**backup-production.ps1** (343 lines)
- Creates timestamped backup in `restore/backups/yyyyMMdd-HHmm/`
- Backs up: pages (JSON), options (JSON), theme files, patterns, database (optional)
- Maintains rotation (default: 10 backups)
- Creates manifest.json for each backup
- Exit code: 0 = success, 1 = failure

**verify-production.ps1** (214 lines)
- Checks 18+ critical items via SSH + WP-CLI
- Categories: pages, patterns, assets, settings, plugins
- Creates issues report: `tmp/verification-issues-yyyyMMdd-HHmm.json`
- Exit code: 0 = all passed, 1 = issues found

**restore-production.ps1** (402 lines)
- Restores from timestamped backup or "latest"
- Granular control: pages, options, theme, database
- Dry-run mode for testing
- Automatic cache flushing
- Exit code: 0 = success, 1 = failure

### Development Operations

**export-elementor-pages.ps1**
- Exports Elementor pages from local WordPress container
- Uses `podman cp` for binary-safe transfer
- Reads mappings from `infra/shared/elementor-manifest.json`
- Outputs to `tmp/elementor-exports/`
- See [DEPLOYMENT-WORKFLOW.md](../../docs/procedures/DEPLOYMENT-WORKFLOW.md) for details

**import-elementor-pages.php** (Not exposed via wp-action.ps1)
- Companion script for Elementor imports on production
- Direct database operations (bypasses WordPress API)
- Supports dry-run mode: `ELEMENTOR_DRY_RUN=true`
- Manual execution on production server
- See [DEPLOYMENT-WORKFLOW.md](../../docs/procedures/DEPLOYMENT-WORKFLOW.md) for usage

## Architecture

```
wp-action.ps1 (Dispatcher)
    │
    ├── Validates action name
    ├── Looks up script in registry
    ├── Forwards all arguments to script
    └── Returns script exit code
        │
        └── backup-production.ps1
        └── verify-production.ps1
        └── restore-production.ps1
        └── export-elementor-pages.ps1
```

## Benefits

1. **Single Entry Point**: Always use `wp-action.ps1`, never call scripts directly
2. **Consistent Interface**: Same command structure for all operations
3. **Built-in Help**: `wp-action.ps1 help <action>` for any action
4. **Argument Forwarding**: Pass any arguments transparently to underlying scripts
5. **Discoverability**: `wp-action.ps1 help` lists all available actions
6. **Exit Codes**: Proper success/failure codes for automation

## Workspace Cleanup (February 8, 2026)

As part of this implementation, the tmp/ folder was cleaned:

**Deleted** (100+ files):
- 33 SQL backup files (5.58 MB)
- 50+ JSON verification/audit files
- 10+ one-time PowerShell audit scripts
- 25+ one-time PHP deployment scripts
- 15+ old HTML page exports
- 8+ one-time markdown documentation
- Archive files (.tar.gz, .sql.gz, .zip)
- CSV exports, SSH keys, shell scripts

**Moved to restore/**:
- welcome-page-clean.html → restore/pages/
- welcome-page-with-patterns.html → restore/pages/
- manager-admin-proper.json → restore/pages/manager-admin-backup.json
- register-profile-79-elementor-fixed.json → restore/pages/register-profile-backup.json

**Result**: Clean workspace with only active working files and proper backup structure

---

## Related Documentation

- [BACKUP-RESTORE-QUICKSTART.md](../../docs/procedures/BACKUP-RESTORE-QUICKSTART.md) - Backup/restore quick start
- [DISASTER-RECOVERY-PLAN.md](../../docs/procedures/DISASTER-RECOVERY-PLAN.md) - DR procedures
- [DEPLOYMENT-WORKFLOW.md](../../docs/procedures/DEPLOYMENT-WORKFLOW.md) - Complete deployment process
- [QUICK-REFERENCE-DEPLOYMENT.md](../../docs/procedures/QUICK-REFERENCE-DEPLOYMENT.md) - Command cheat sheet

---

**Created**: February 8, 2026  
**Last Updated**: February 8, 2026  
**Maintained By**: Technical Lead  
**Incident Resolved**: Welcome page disappearance → Comprehensive DR system implemented
