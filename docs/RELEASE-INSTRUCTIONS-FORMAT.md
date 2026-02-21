# Release Instructions Format

## Overview

Release instructions are defined in two formats:

1. **Human-readable** (Markdown in `.github/releases/archive/`) - For developer reference (archived releases)
2. **Machine-readable** (JSON in `.github/releases/`) - For GitHub Actions automation

**Templates:**
- [templates/vX.Y.Z.json](../templates/vX.Y.Z.json) - Copy this to create new release metadata
- [templates/RELEASE-NOTES-vX.Y.Z.md](../templates/RELEASE-NOTES-vX.Y.Z.md) - Copy this to create new release notes

## File Naming Convention

- Human: `.github/releases/archive/RELEASE-vX.Y.Z.md`
- Machine: `.github/releases/vX.Y.Z.json`

## Machine-Readable Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["version", "steps"],
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Semantic version (e.g., 3.1.0)"
    },
    "release_date": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp"
    },
    "description": {
      "type": "string",
      "description": "Brief release summary"
    },
    "requires_db_backup": {
      "type": "boolean",
      "default": false,
      "description": "If true, backup database before deployment"
    },
    "requires_manual_verification": {
      "type": "boolean",
      "default": true,
      "description": "If true, pause for manual verification"
    },
    "steps": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["type", "description"],
        "properties": {
          "type": {
            "type": "string",
            "enum": [
              "deploy_code",
              "deploy_elementor",
              "deploy_css",
              "run_sql",
              "clear_cache",
              "verify_url",
              "manual"
            ]
          },
          "description": {
            "type": "string"
          },
          "config": {
            "type": "object",
            "description": "Type-specific configuration"
          }
        }
      }
    }
  }
}
```

## Step Types

### 1. deploy_code
Deploys themes/plugins via rsync

```json
{
  "type": "deploy_code",
  "description": "Deploy wp-content to production",
  "config": {
    "source": "wp-content/",
    "destination": "/domains/site.com/public_html/wp-content/",
    "exclude": ["uploads/", "*.log"],
    "rsync_flags": "-avz --delete"
  }
}
```

### 2. deploy_pages
Deploys WordPress pages using restoration scripts

```json
{
  "type": "deploy_pages",
  "description": "Deploy updated landing pages",
  "config": {
    "pages_dir": "restore/pages/",
    "restore_script": "infra/shared/scripts/restore-page.php"
  }
}
```

### 3. deploy_css
Deploys custom CSS to WordPress Customizer

```json
{
  "type": "deploy_css",
  "description": "Update login page CSS",
  "config": {
    "css_file": "config/custom-css/login.css",
    "target": "customizer",
    "selector": ".login-form"
  }
}
```

### 4. run_sql
Executes SQL file on production database

```json
{
  "type": "run_sql",
  "description": "Add new database tables",
  "config": {
    "sql_file": "infra/shared/db/260113-1030-add-scout-tables.sql",
    "dry_run": false
  }
}
```

### 5. clear_cache
Clears various caches

```json
{
  "type": "clear_cache",
  "description": "Clear LiteSpeed and WordPress caches",
  "config": {
    "cache_types": ["litespeed", "wordpress", "opcache"]
  }
}
```

### 6. verify_url
Verifies URL returns expected status

```json
{
  "type": "verify_url",
  "description": "Verify homepage loads",
  "config": {
    "url": "https://talendelight.com/",
    "expected_status": 200,
    "expected_content": "Welcome to TalenDelight"
  }
}
```

### 7. manual
Requires manual intervention

```json
{
  "type": "manual",
  "description": "Verify compliance footer appears on all pages",
  "config": {
    "instructions": [
      "Open https://talendelight.com/employers/",
      "Scroll to bottom",
      "Verify 4 trust badges are visible",
      "Confirm checkmarks (✅) render correctly"
    ],
    "approve_before_continue": true
  }
}
```

## Example Release File

`.github/releases/v3.1.0.json`:

```json
{
  "version": "3.1.0",
  "release_date": "2026-01-13T00:00:00Z",
  "description": "Added GDPR compliance footer to all pages",
  "requires_db_backup": false,
  "requires_manual_verification": true,
  "steps": [
    {
      "type": "deploy_code",
      "description": "Deploy themes and plugins",
      "config": {
        "source": "wp-content/themes/",
        "destination": "/domains/talendelight.com/public_html/wp-content/themes/",
        "exclude": []
      }
    },
    {
      "type": "deploy_pages",
      "description": "Import updated pages with compliance footer",
      "config": {
        "pages_dir": "restore/pages/",
        "restore_script": "infra/shared/scripts/restore-page.php"
      }
    },
    {
      "type": "deploy_css",
      "description": "Update login form styling",
      "config": {
        "css_file": "config/custom-css/login.css",
        "target": "customizer"
      }
    },
    {
      "type": "clear_cache",
      "description": "Clear all caches",
      "config": {
        "cache_types": ["litespeed", "wordpress"]
      }
    },
    {
      "type": "manual",
      "description": "Verify pages display correctly",
      "config": {
        "instructions": [
          "Check https://talendelight.com/ - compliance footer visible",
          "Check https://talendelight.com/employers/ - compliance footer visible",
          "Check https://talendelight.com/candidates/ - compliance footer visible",
          "Check https://talendelight.com/scouts/ - compliance footer visible",
          "Verify login button has blue glow effect"
        ],
        "approve_before_continue": true
      }
    }
  ]
}
```

## GitHub Actions Integration

The workflow reads the latest release file and executes steps:

```yaml
jobs:
  deploy:
    steps:
      - name: Find latest release
        run: |
          LATEST_RELEASE=$(ls -1 .github/releases/*.json | sort -V | tail -n1)
          echo "RELEASE_FILE=$LATEST_RELEASE" >> $GITHUB_ENV
          
      - name: Parse release instructions
        run: |
          cat $RELEASE_FILE | jq -r '.steps[] | @json'
          
      - name: Execute deployment steps
        run: |
          node .github/scripts/execute-release.js $RELEASE_FILE
```

## Creating New Release

1. Create human-readable release notes: `.github/releases/archive/RELEASE-v3.2.0.md`
2. Create machine-readable instructions: `.github/releases/v3.2.0.json`
3. Backup pages: `wp-action backup`
4. Commit all files to git
5. Push to `main` branch - GitHub Actions will detect and execute latest release

## Validation

Validate release file before committing:

```bash
# Using ajv-cli
ajv validate -s .github/releases/schema.json -d .github/releases/v3.1.0.json

# Using jq
jq empty .github/releases/v3.1.0.json && echo "Valid JSON" || echo "Invalid JSON"
```
