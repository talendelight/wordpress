# Forminator Forms Restore

## Production Backup (Jan 30, 2026) - USE THESE FILES

**Source:** Production backup from Jan 30, 2026

### Files to Import (in order):

1. **forminator-form-80-from-production.sql** - Main form post data (ID 80: person-registration-form)
2. **forminator-form-80-meta-from-production.sql** - Form metadata (settings, fields)
3. **forminator-tables-from-production.sql** - Forminator plugin tables (entries, views, reports)

### Import Commands:

```powershell
# From wordpress directory
Get-Content restore/forms/forminator-form-80-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-form-80-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-tables-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
```

### Reference Files:

- **forminator-form-80-from-production.json** - JSON export for inspection (not for import)

---

## Old Files (Ignore During Restore)

These files are from earlier exports and may not match production:

- `forminator-forms-dump.sql` - Old export
- `forminator-forms-list.json` - Old export
- `forminator-forms-list.txt` - Old export
- `forminator-forms.json` - Old export
- `forminator-schema.txt` - Old export
- `forminator-tables.txt` - Old export

**⚠️ Do not use these files for restoration. Use only the files with "from-production" in the name.**
