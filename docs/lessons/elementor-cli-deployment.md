# Lesson: Elementor Page Deployment via CLI

**Date:** January 13, 2026  
**Context:** Attempting to deploy v3.1.0 pages from local to Hostinger production via command line  
**Outcome:** Partially successful - learned critical lessons about Elementor data handling

---

## Challenges Encountered

### 1. **Export Pages Step: Cluttered Output**

**Problem:**
```bash
podman exec wp wp post meta get 20 _elementor_data --allow-root
```
Output was cluttered with PHP notices and deprecation warnings from WP User Manager plugin.

**Root Cause:**
- WP-CLI runs WordPress initialization which loads all plugins
- WP User Manager has deprecated Carbon Fields code generating stderr output
- stderr mixed with stdout in terminal output

**Solution:**
```bash
podman exec wp bash -c "wp post meta get 20 _elementor_data --allow-root 2>/dev/null" > file.json
```

**Lesson Learned:**
- Always redirect stderr (`2>/dev/null`) when extracting data via WP-CLI
- Use bash -c wrapper to ensure proper shell handling of redirects
- Test output format before building automation

---

### 2. **Import Pages Step: JSON Special Characters Issues**

**Problem:**
```bash
$data = Get-Content file.json -Raw
ssh "wp post meta update 64 _elementor_data '$data'"
```
Failed with: `bash: line 1: Reliable,selected_icon:{value:fas: command not found`

**Root Cause:**
- Elementor JSON contains special bash characters: `{`, `}`, `$`, quotes, newlines
- PowerShell variable interpolation corrupted the data
- SSH command parsing treated JSON as shell commands

**Solution Attempt 1: File Upload**
```bash
scp file.json remote:~/file.json
ssh "wp post meta update 64 _elementor_data \"\$(cat ~/file.json)\""
```
**Result:** Still failed - command substitution couldn't handle large data

**Solution Attempt 2: Script File**
```bash
# Create deploy-pages.sh on remote
wp post meta update 64 _elementor_data "$(cat ~/file.json)"
```
**Result:** Failed with "ignored null byte in input" error

**Root Cause of Null Bytes:**
- WP-CLI meta get returns JSON as-is from database
- Elementor stores data JSON-encoded, then escaped for MySQL
- Contains literal `\u0000` null bytes that bash can't handle in command substitution

**Lesson Learned:**
- Elementor data cannot be reliably transferred via command-line variables
- File size (18KB+) exceeds practical command-line limits (typically 128KB ARG_MAX, but shell parsing breaks much earlier)
- Special characters in JSON make shell escaping nearly impossible
- Null bytes in data break bash command substitution completely

---

### 3. **PowerShell Interference**

**Problem:**
```powershell
ssh "cd path && wp command \"$(cat file)\""
```
PowerShell interpreted `$()` before SSH could execute it.

**Solution:**
```powershell
ssh 'cd path && wp command "$(cat file)"'  # Single quotes prevent PS interpolation
```

**Lesson Learned:**
- Use single quotes in PowerShell to prevent variable interpolation
- PowerShell's command parsing differs from bash - test carefully
- Consider using `bash -c 'command'` wrapper for complex commands

---

### 4. **Data Size Limitations**

**Problem:**
Elementor page data is 18KB-31KB per page, too large for command-line arguments.

**Why It Failed:**
1. Shell ARG_MAX limits (typically 128KB-2MB on Linux)
2. SSH command-line parsing overhead
3. JSON escaping doubles/triples effective size
4. Bash command substitution memory limits

**Lesson Learned:**
- Command-line is not suitable for large data transfers
- File-based approaches required for data >10KB
- Database import methods bypass size limits

---

## Why CLI Export/Import Failed

### Technical Reasons

1. **Elementor Data Format:**
   - Stored as JSON string in `wp_postmeta` table
   - Contains nested JSON with special characters
   - May contain binary data or null bytes
   - Not designed for command-line transfer

2. **WP-CLI Limitations:**
   - `wp post meta get` returns raw data (not sanitized for shell)
   - `wp post meta update` expects simple strings, not complex JSON
   - No built-in JSON escaping for shell safety

3. **Shell Limitations:**
   - Bash command substitution fails with null bytes
   - JSON special characters conflict with shell syntax
   - Variable size limits in shell environments
   - Complex escaping requirements make it error-prone

### Elementor's Design

**Official Export Format:**
Elementor uses a specific JSON template format (not raw database data):
```json
{
  "version": "0.4",
  "title": "Page Template",
  "type": "page",
  "content": [ ... ]
}
```

**What We Extracted:**
Raw `_elementor_data` postmeta (database JSON, not template format):
```json
[{"id":"abc123","elType":"container","settings":{...},...}]
```

**The Difference:**
- Template format: Exportable/importable via Elementor Tools
- Database format: Internal representation, not meant for direct manipulation

---

## Correct Approaches

### ✅ Method 1: GUI Export/Import (Recommended)

**Why It Works:**
- Elementor handles all data transformation
- Validates structure on import
- Handles media URLs, IDs, and relationships
- Preserves formatting and metadata

**Process:**
1. Local: Edit with Elementor → Tools → Export Template → Save JSON
2. Production: Edit with Elementor → Tools → Import Template → Upload JSON

**Pros:**
- ✅ Reliable and supported by Elementor
- ✅ Handles all edge cases
- ✅ Validates data integrity

**Cons:**
- ❌ Manual process (not scriptable)
- ❌ Requires browser access
- ❌ Time-consuming for many pages

---

### ✅ Method 2: Database Direct Update (Advanced)

**Prerequisites:**
- Direct MySQL/MariaDB access
- Proper escaping of data
- Understanding of WordPress post/meta relationships

**Process:**
```sql
-- Export from local database
SELECT meta_value 
FROM wp_postmeta 
WHERE post_id = 20 AND meta_key = '_elementor_data' 
INTO OUTFILE '/tmp/elementor_data.json';

-- Import to production database
UPDATE wp_postmeta 
SET meta_value = LOAD_FILE('/tmp/elementor_data.json')
WHERE post_id = 14 AND meta_key = '_elementor_data';
```

**Pros:**
- ✅ Can be scripted
- ✅ Handles large data
- ✅ No command-line escaping issues

**Cons:**
- ❌ Requires direct DB access (often blocked on shared hosting)
- ❌ File system permissions needed (LOAD_FILE)
- ❌ No validation - can break pages
- ❌ Risky for production

---

### ✅ Method 3: WordPress REST API (Modern Approach)

**Concept:**
```bash
# Export via REST API
curl -u user:pass http://local/wp-json/elementor/v1/templates/20 > template.json

# Import via REST API
curl -u user:pass -X POST http://prod/wp-json/elementor/v1/templates/import \
  -H "Content-Type: application/json" \
  -d @template.json
```

**Status:**
- ⚠️ Elementor REST API endpoints are limited
- ⚠️ May require Elementor Pro
- ⚠️ Authentication complexity on shared hosting

**Pros:**
- ✅ Designed for automation
- ✅ Handles authentication properly
- ✅ Validates data

**Cons:**
- ❌ Limited Elementor API support
- ❌ Requires additional setup
- ❌ May not work on all hosting

---

### ✅ Method 4: WP-CLI with PHP Script (Hybrid)

**Concept:**
```php
<?php
// save-elementor-data.php
$data = file_get_contents('/tmp/elementor-data.json');
update_post_meta(14, '_elementor_data', $data);
```

```bash
# Execute on production
wp eval-file save-elementor-data.php
```

**Pros:**
- ✅ Bypasses shell escaping issues
- ✅ PHP handles data properly
- ✅ Scriptable

**Cons:**
- ❌ Requires file upload
- ❌ Two-step process
- ❌ No validation

---

## Recommendations

### For One-Time Deployments
**Use GUI Method** - Most reliable, least risk

### For Frequent Deployments
**Develop Custom WP-CLI Command:**
```php
// wp-cli/commands/deploy-elementor.php
WP_CLI::add_command('deploy-elementor', function($args) {
    $local_id = $args[0];
    $prod_id = $args[1];
    
    $data = get_post_meta($local_id, '_elementor_data', true);
    update_post_meta($prod_id, '_elementor_data', $data);
    
    // Clear Elementor cache
    \Elementor\Plugin::instance()->files_manager->clear_cache();
    
    WP_CLI::success("Deployed page $local_id to $prod_id");
});
```

**Usage:**
```bash
# On local: Export to file
wp eval "echo get_post_meta(20, '_elementor_data', true);" > data.txt

# Upload to production
scp data.txt production:/tmp/

# On production: Import from file
wp eval "update_post_meta(14, '_elementor_data', file_get_contents('/tmp/data.txt'));"
wp elementor flush_css
```

### For CI/CD Pipelines
**Use combination:**
1. Export templates via GUI during development
2. Commit JSON templates to git
3. Deploy templates via rsync to production staging folder
4. Manual import via Elementor Tools (safety check)
5. Document deployment in release notes

---

## Key Takeaways

1. **Elementor is GUI-first** - CLI support is limited by design
2. **JSON data with special characters needs careful handling** - not suitable for shell variables
3. **Large data requires file-based transfer** - command-line has size limits
4. **WP-CLI is powerful but not universal** - some operations need PHP scripts
5. **PowerShell and Bash have different parsing** - test cross-platform carefully
6. **Production deployments should favor safety over automation** - GUI is OK for low-frequency changes
7. **Null bytes break shell command substitution** - cannot be worked around easily
8. **Always have a rollback plan** - database backups before any deployment

---

## Future Improvements

1. **Create custom WP-CLI command** for Elementor deployment
2. **Use proper API** if/when Elementor expands REST API support
3. **Build deployment tool** that handles edge cases properly
4. **Document page mappings** (local ID → production ID) in version control
5. **Automated testing** after deployment to verify pages render correctly
6. **Consider Elementor Pro** for advanced import/export features

---

## Final Working Solution

After extensive debugging, we discovered the root cause and implemented a reliable solution:

### The Problem: PowerShell Encoding Corruption

**Issue:**
```powershell
# This corrupts binary data in JSON
podman exec wp wp post meta get 248 _elementor_data | Out-File file.json
```

**What went wrong:**
1. PowerShell's `Out-File` adds BOM (Byte Order Mark)
2. Default encoding changes UTF-8 characters
3. Unicode escapes like `\u2705` (✅) become `u2705` (plain text)
4. Escaped slashes `\/` become unescaped `/`
5. WordPress database validation rejects corrupted data

### The Solution: Direct Binary Copy

**Working approach:**
```bash
# Export inside container (no PowerShell interference)
podman exec wp bash -c "wp post meta get 248 _elementor_data --allow-root 2>/dev/null > /tmp/page.json"

# Copy file directly from container (binary copy)
podman cp wp:/tmp/page.json tmp/page-clean.json

# Upload to production via SCP
scp tmp/page-clean.json production:~/page.json

# Import via PHP script (bypasses shell escaping)
wp eval-file import-script.php
```

**Import script (PHP):**
```php
global $wpdb;
$data = file_get_contents('/home/user/page.json');
$wpdb->delete($wpdb->postmeta, ['post_id' => 76, 'meta_key' => '_elementor_data']);
$wpdb->insert($wpdb->postmeta, [
    'post_id' => 76,
    'meta_key' => '_elementor_data',
    'meta_value' => $data
]);
```

### Why This Works

1. **No encoding changes**: `podman cp` does binary copy, preserving exact bytes
2. **No shell escaping**: PHP reads file directly, no command substitution
3. **No size limits**: File-based, not command-line arguments
4. **Direct DB access**: Bypasses WordPress meta API which may sanitize/validate

### Deployment Workflow

```bash
# 1. Export all pages from local (inside container)
for id in 20 93 229 248 152; do
    podman exec wp bash -c "wp post meta get $id _elementor_data --allow-root 2>/dev/null > /tmp/page-$id.json"
    podman cp wp:/tmp/page-$id.json tmp/page-$id.json
done

# 2. Upload to production
scp tmp/page-*.json production:~/

# 3. Create import script on local
cat > tmp/import-pages.php << 'EOF'
global $wpdb;
$mappings = [
    ['local' => 20, 'prod' => 14, 'file' => 'page-20.json', 'name' => 'Homepage'],
    ['local' => 93, 'prod' => 64, 'file' => 'page-93.json', 'name' => 'Employers'],
    // ... more mappings
];
foreach ($mappings as $map) {
    $data = file_get_contents("/home/user/{$map['file']}");
    $wpdb->delete($wpdb->postmeta, ['post_id' => $map['prod'], 'meta_key' => '_elementor_data']);
    $wpdb->insert($wpdb->postmeta, ['post_id' => $map['prod'], 'meta_key' => '_elementor_data', 'meta_value' => $data]);
    echo "Updated {$map['name']}\n";
}
EOF

# 4. Upload and execute import script
scp tmp/import-pages.php production:~/
ssh production "cd public_html && wp eval-file ~/import-pages.php && wp elementor flush_css"
```

### Integration with CI/CD

For GitHub Actions, this requires:
1. Spin up local WordPress container
2. Export pages to files (not through GitHub Actions shell)
3. Upload files to production staging folder
4. Trigger PHP import script on production
5. Manual verification step before going live

**Note:** Full automation in GitHub Actions is challenging because:
- Need local WordPress running to export data
- Cannot easily access local database from GitHub runners
- Better to export during development, commit export files to repo

## Conclusion

While CLI automation is possible for simple WordPress data, Elementor's complex JSON structure and WordPress's meta data handling make it challenging. The GUI method, though manual, is the most reliable approach for production deployments.

**Final Recommendation:**
- Development: Export pages using container-direct method, commit to repo
- Staging: Use PHP import script for automated deployment
- Production: Use PHP import script with manual verification
- CI/CD: Deploy code (themes/plugins) automatically, deploy pages semi-automatically via PHP scripts
- Always: Use `podman cp` for exports, never pipe through PowerShell
- Emergency: Use GUI import as fallback if automated import fails
