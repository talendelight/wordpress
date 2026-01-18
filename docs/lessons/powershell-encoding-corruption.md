# PowerShell Encoding Corruption in WordPress CLI Operations

**Date:** January 13, 2026  
**Severity:** Critical  
**Impact:** Data corruption in Elementor page exports

---

## The Problem

When exporting WordPress/Elementor data via WP-CLI in PowerShell, Unicode and special characters get corrupted, causing import failures.

### Example

```powershell
# ❌ WRONG - Corrupts data
podman exec wp wp post meta get 248 _elementor_data --allow-root | Out-File page.json
podman exec wp wp post meta get 248 _elementor_data --allow-root > page.json
```

**Result:**
- `\u2705` (✅ checkmark) → `u2705` (plain text "u2705")
- `\u274c` (❌ cross) → `u274c` (plain text "u274c")
- `\/scouts\/refer` → `/scouts/refer` (unescaped slashes)
- BOM (Byte Order Mark) added to file
- WordPress rejects import: "Malformed UTF-8 characters, possibly incorrectly encoded"

---

## The Solution

**✅ CORRECT - Preserves binary data:**

```powershell
# Export inside container (no PowerShell)
podman exec wp bash -c "wp post meta get 248 _elementor_data --allow-root 2>/dev/null > /tmp/page.json"

# Copy file directly (binary copy)
podman cp wp:/tmp/page.json tmp/page.json
```

---

## Why This Happens

1. **PowerShell's default encoding:** Adds BOM, changes encoding
2. **Pipe operator (`|`)**: Converts objects to strings, loses binary data
3. **Redirection (`>`)**: Uses Out-File with default encoding
4. **Out-File cmdlet**: Applies encoding transformation

---

## Always Remember

### ❌ NEVER Do This
```powershell
podman exec wp command | Out-File file
podman exec wp command > file
podman exec wp command | Set-Content file
$data = podman exec wp command
```

### ✅ ALWAYS Do This
```powershell
# Step 1: Export inside container
podman exec wp bash -c "command > /tmp/file"

# Step 2: Copy from container
podman cp wp:/tmp/file tmp/file
```

---

## Quick Reference

| Operation | Wrong ❌ | Correct ✅ |
|-----------|---------|-----------|
| Export Elementor data | `podman exec wp wp post meta get 248 _elementor_data > file.json` | `podman exec wp bash -c "wp post meta get 248 _elementor_data > /tmp/file.json" && podman cp wp:/tmp/file.json tmp/file.json` |
| Export database | `podman exec wp mysqldump > dump.sql` | `podman exec wp bash -c "mysqldump > /tmp/dump.sql" && podman cp wp:/tmp/dump.sql tmp/dump.sql` |
| Read file from container | `podman exec wp cat /var/www/html/file > local` | `podman cp wp:/var/www/html/file tmp/file` |

---

## Related Issues

- JSON with null bytes fails in bash command substitution
- Large data (>10KB) causes command-line argument size issues
- Special characters in JSON break shell parsing
- Unicode escape sequences required for proper rendering

---

## Verification After Export

Always verify exported files don't have encoding corruption:

```powershell
# Check for UTF-8 BOM
$bytes = [System.IO.File]::ReadAllBytes("tmp/file.json")
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "ERROR: UTF-8 BOM detected - file corrupted"
}

# Check for UTF-16 LE
if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    Write-Host "ERROR: UTF-16 LE encoding - file corrupted"
}

# Verify JSON is valid
try {
    $json = Get-Content "tmp/file.json" -Raw | ConvertFrom-Json
    Write-Host "OK: Valid JSON with $($json.Count) items"
} catch {
    Write-Host "ERROR: Invalid JSON"
}
```

**On Linux (production):**
```bash
# Check encoding
file operators.json
# Should say: "JSON data" or "ASCII text"
# Should NOT say: "UTF-8 Unicode (with BOM)" or "UTF-16"
```

---

## See Also

- [elementor-cli-deployment.md](elementor-cli-deployment.md) - Full context and alternative approaches
- [export-elementor-pages.ps1](../../infra/shared/scripts/export-elementor-pages.ps1) - Automated export with verification
