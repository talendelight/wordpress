# Temporary Database Files

## Purpose

This directory is for **sensitive product/customer data SQL files** that should NOT be committed to version control.

## File Pattern

- `{yymmdd}-data.sql` - Product catalogs, pricing, customer records, test data

## Examples

- `251222-data.sql` - Initial product catalog for December 2025
- `260115-data.sql` - Updated pricing and inventory
- `260201-data.sql` - New product categories

## Usage

### Importing Product Data to Dev Environment

```powershell
cd tmp

# Import via MySQL
Get-Content 251222-data.sql | podman exec -i wp-db mysql -u root -ppassword wordpress

# Or via WP-CLI
podman exec wordpress wp db query "$(Get-Content 251222-data.sql -Raw)"
```

### Creating Product Data Export

```powershell
# Export WooCommerce products only
podman exec wp-db mysqldump -u root -ppassword wordpress `
  wp_posts wp_postmeta wp_term_relationships `
  --where="post_type IN ('product', 'product_variation')" `
  | Out-File -Encoding utf8 tmp/251222-data.sql

# Or export specific tables
podman exec wp-db mysqldump -u root -ppassword wordpress `
  wp_wc_products wp_wc_product_meta_lookup `
  | Out-File -Encoding utf8 tmp/251222-data.sql
```

## Important Notes

⚠️ **All files in this directory are ignored by git** (.gitignore configured)

- Do NOT commit product data, pricing, or customer information to git
- Structural changes (schema, metadata) belong in `/infra/shared/init/` instead
- This directory is for local development/testing data only
- Production product data should be managed through WordPress admin or proper migration tools

## Security

- Files here may contain sensitive business data
- Keep this directory out of public repositories
- Use secure methods to share data exports with team members (encrypted channels, private S3 buckets, etc.)
- Regularly clean up old data files

## See Also

- [infra/shared/init/README.md](../infra/shared/init/README.md) - Structural change files
- [infra/dev/DATABASE.md](../infra/dev/DATABASE.md) - Database workflows
