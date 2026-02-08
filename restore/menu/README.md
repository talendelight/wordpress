# Menu Restore

## Production Backup (Jan 30, 2026) - USE THESE FILES

**Source:** Production backup from Jan 30, 2026

### Files to Import (in order):

1. **menus-from-production.sql** - Menu terms and taxonomy definitions
2. **menu-items-from-production.sql** - Menu item posts (nav_menu_item)
3. **menu-items-meta-from-production.sql** - Menu item metadata (parent, position, object_id, etc.)
4. **menu-relationships-from-production.sql** - Relationships between menu items and menus

### Import Commands:

```powershell
# From wordpress directory
Get-Content restore/menu/menus-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-relationships-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
```

### Reference Files:

- **menus-from-production.json** - JSON export for inspection (not for import)

---

## Old Files (Ignore During Restore)

These files are from earlier exports and may not match production:

- `main-navigation-items.json` - Old export
- `menus-list.json` - Old export

**⚠️ Do not use these files for restoration. Use only the files with "from-production" in the name.**
