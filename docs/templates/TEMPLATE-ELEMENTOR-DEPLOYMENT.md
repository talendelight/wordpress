# WordPress Elementor Page Deployment Template

## Purpose
Template for deploying Elementor pages from local development to production without GUI.

## Prerequisites
- Local WordPress running in Podman/Docker container
- Production SSH access with WP-CLI available
- Page ID mapping documented (local → production)

---

## Step 1: Export Pages from Local

```bash
# Create export directory
mkdir -p tmp/elementor-exports

# Export each page (run in PowerShell on Windows)
$pages = @(
    @{LocalId=20; Name="homepage"},
    @{LocalId=93; Name="employers"},
    @{LocalId=229; Name="candidates"},
    @{LocalId=248; Name="scouts"},
    @{LocalId=152; Name="access-restricted"}
)

foreach ($page in $pages) {
    $id = $page.LocalId
    $name = $page.Name
    
    Write-Host "Exporting $name (ID: $id)..."
    
    # Export inside container
    podman exec wp bash -c "wp post meta get $id _elementor_data --allow-root 2>/dev/null > /tmp/$name.json"
    
    # Copy from container (binary copy)
    podman cp wp:/tmp/$name.json tmp/elementor-exports/$name.json
    
    Write-Host "  Exported: tmp/elementor-exports/$name.json"
}

Write-Host "`nAll pages exported successfully!"
```

---

## Step 2: Create Deployment Manifest

Create `tmp/elementor-exports/manifest.json`:

```json
{
  "version": "3.1.0",
  "exported_at": "2026-01-13T10:30:00Z",
  "pages": [
    {
      "name": "homepage",
      "local_id": 20,
      "prod_id": 14,
      "file": "homepage.json",
      "title": "Homepage (Welcome)"
    },
    {
      "name": "employers",
      "local_id": 93,
      "prod_id": 64,
      "file": "employers.json",
      "title": "Employers"
    },
    {
      "name": "candidates",
      "local_id": 229,
      "prod_id": 75,
      "file": "candidates.json",
      "title": "Candidates"
    },
    {
      "name": "scouts",
      "local_id": 248,
      "prod_id": 76,
      "file": "scouts.json",
      "title": "Scouts"
    },
    {
      "name": "access-restricted",
      "local_id": 152,
      "prod_id": 44,
      "file": "access-restricted.json",
      "title": "Access Restricted"
    }
  ]
}
```

---

## Step 3: Create Import Script

Create `tmp/elementor-exports/import-pages.php`:

```php
<?php
/**
 * Import Elementor pages to production
 * Usage: wp eval-file import-pages.php
 */

global $wpdb;

// Read manifest
$manifest_file = getenv('HOME') . '/elementor-exports/manifest.json';
if (!file_exists($manifest_file)) {
    echo "ERROR: Manifest file not found: $manifest_file\n";
    exit(1);
}

$manifest = json_decode(file_get_contents($manifest_file), true);
if (!$manifest) {
    echo "ERROR: Could not parse manifest\n";
    exit(1);
}

echo "Deploying Elementor pages (version: {$manifest['version']})\n\n";

$success_count = 0;
$error_count = 0;

foreach ($manifest['pages'] as $page) {
    echo "Processing: {$page['title']} (ID: {$page['prod_id']})\n";
    
    $file_path = getenv('HOME') . "/elementor-exports/{$page['file']}";
    
    if (!file_exists($file_path)) {
        echo "  ERROR: File not found: $file_path\n\n";
        $error_count++;
        continue;
    }
    
    $data = file_get_contents($file_path);
    
    if (!$data) {
        echo "  ERROR: Could not read file\n\n";
        $error_count++;
        continue;
    }
    
    echo "  Read " . strlen($data) . " bytes\n";
    
    // Delete existing data
    $deleted = $wpdb->delete(
        $wpdb->postmeta,
        ['post_id' => $page['prod_id'], 'meta_key' => '_elementor_data'],
        ['%d', '%s']
    );
    
    echo "  Deleted existing data: " . ($deleted ? "yes ($deleted rows)" : "none") . "\n";
    
    // Insert new data
    $result = $wpdb->insert(
        $wpdb->postmeta,
        [
            'post_id' => $page['prod_id'],
            'meta_key' => '_elementor_data',
            'meta_value' => $data
        ],
        ['%d', '%s', '%s']
    );
    
    if ($result === false) {
        echo "  ERROR: Database insert failed - " . $wpdb->last_error . "\n\n";
        $error_count++;
        continue;
    }
    
    echo "  SUCCESS: Imported (meta_id: {$wpdb->insert_id})\n\n";
    $success_count++;
}

// Clear Elementor cache
if (class_exists('\Elementor\Plugin')) {
    \Elementor\Plugin::instance()->files_manager->clear_cache();
    echo "Cleared Elementor cache\n\n";
}

echo "Deployment complete: $success_count succeeded, $error_count failed\n";

exit($error_count > 0 ? 1 : 0);
```

---

## Step 4: Upload and Deploy

```bash
# Upload exports and scripts to production
scp -r tmp/elementor-exports/ production:~/

# Execute import script
ssh production "cd domains/site.com/public_html && wp eval-file ~/elementor-exports/import-pages.php"

# Verify deployment
ssh production "cd domains/site.com/public_html && wp post list --post_type=page --post__in=14,64,75,76,44 --fields=ID,post_title,url"
```

---

## Step 5: Verification Checklist

- [ ] All pages load without errors
- [ ] Compliance footer visible on all pages
- [ ] Unicode characters render correctly (✅ ❌)
- [ ] Buttons link to correct URLs
- [ ] Login form styling applied
- [ ] Mobile responsive layout works
- [ ] No console errors in browser DevTools

---

## Rollback Procedure

If deployment fails:

```bash
# On production: Restore from backup (if exists)
ssh production "cd domains/site.com/public_html && wp db import ~/backups/pre-deployment.sql"

# Or: Restore individual page from previous export
ssh production "cd domains/site.com/public_html && wp eval-file ~/elementor-exports/rollback-page.php"
```

---

## Automation Notes

This process can be automated in CI/CD:
1. Export during build step (requires local WordPress)
2. Commit exports to git (if small enough)
3. Deploy via GitHub Actions SSH
4. Execute import script remotely
5. Run verification tests

**Trade-off:** Exports are snapshots, not live data. Best for:
- Structural changes (layout, sections)
- Design updates (colors, spacing)
- Content updates committed in development

**Not ideal for:**
- Frequently changing content
- User-generated content
- Dynamic content from plugins
