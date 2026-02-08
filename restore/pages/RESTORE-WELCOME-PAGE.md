# Welcome Page Restore Guide

**Last Updated:** February 8, 2026  
**Production Version:** v3.5.1 (64px spacing below "Our Specialties")

## Available Backup Files

### HTML Content Backups
- `welcome-6-gutenberg.html` - Gutenberg version (original 48px spacing)
- `welcome-6-gutenberg-64px.html` - Current production version (64px spacing)

### Complete WordPress Exports
- `welcome-6-production.json` - Full production export with all metadata (February 8, 2026)
- `welcome-6-gutenberg.json` - Local development version
- `welcome-6-elementor.json` - Original Elementor version (pre-migration)

### Database Query Results
- `welcome-post-6.sql` - Raw SQL query output from production

## Restore Methods

### Method 1: Restore via WP-CLI (Recommended)

**From Local Development:**
```powershell
# Copy content file to container
podman cp restore/pages/welcome-6-gutenberg-64px.html wp:/tmp/welcome.html

# Update page content
podman exec wp wp eval-file -c "
require_once('/var/www/html/wp-load.php');
\$content = file_get_contents('/tmp/welcome.html');
wp_update_post(['ID' => 6, 'post_content' => \$content]);
echo 'Restored Welcome page';
" --allow-root
```

**On Production:**
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129

cd domains/talendelight.com/public_html

# Upload content file first
# scp -i tmp/hostinger_deploy_key -P 65002 restore/pages/welcome-6-gutenberg-64px.html u909075950@45.84.205.129:~/welcome-restore.html

# Restore content
cat > ~/restore-welcome.php << 'EOF'
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');
$content = file_get_contents('/home/u909075950/welcome-restore.html');
if ($content === false) {
    echo "Error: Could not read file\n";
    exit(1);
}
$result = wp_update_post([
    'ID' => 6,
    'post_content' => $content
]);
if (is_wp_error($result)) {
    echo "Error: " . $result->get_error_message() . "\n";
    exit(1);
}
echo "✅ Success: Welcome page restored\n";
EOF

wp eval-file ~/restore-welcome.php --allow-root
wp cache flush --allow-root
```

### Method 2: Restore via WordPress Admin

1. Copy content from `welcome-6-gutenberg-64px.html`
2. Login to WordPress Admin
3. Go to Pages → Welcome → Edit
4. Switch to Code Editor (⌘⇧⌥M or Ctrl+Shift+Alt+M)
5. Paste the HTML content
6. Update page

### Method 3: Restore Complete Post (Nuclear Option)

If page is deleted or corrupted, restore from JSON:

```bash
# On production
cd domains/talendelight.com/public_html

# If page exists, delete it first
wp post delete 6 --force --allow-root

# Import from JSON
cat > ~/restore-full.php << 'EOF'
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');
$json = file_get_contents('/home/u909075950/welcome-6-production.json');
$data = json_decode($json, true);

$post_id = wp_insert_post([
    'ID' => 6,
    'post_title' => $data['post_title'],
    'post_name' => $data['post_name'],
    'post_content' => $data['post_content'],
    'post_status' => 'publish',
    'post_type' => 'page'
], true);

if (is_wp_error($post_id)) {
    echo "Error: " . $post_id->get_error_message() . "\n";
    exit(1);
}
echo "✅ Success: Welcome page restored (ID: $post_id)\n";
EOF

wp eval-file ~/restore-full.php --allow-root
```

## Post-Restore Checklist

- [ ] Verify icons display (Better Font Awesome must be active)
- [ ] Check spacing: 64px below "Our Specialties" heading
- [ ] Test all 4 specialty cards display correctly
- [ ] Verify "Get Started" button links to /register/
- [ ] Clear all caches: `wp cache flush --allow-root`
- [ ] Test on mobile devices
- [ ] Verify page is set as homepage if needed:
  ```bash
  wp option update show_on_front 'page' --allow-root
  wp option update page_on_front 6 --allow-root
  ```

## Dependencies

**Required Plugins:**
- Better Font Awesome v2.0.4 (for icons)

**Required Theme:**
- Blocksy Child (must be active)

**Required Settings:**
- Site URL: https://talendelight.com
- Home URL: https://talendelight.com

## Troubleshooting

### Icons Not Displaying
```bash
wp plugin list --name=better-font-awesome --allow-root
wp plugin activate better-font-awesome --allow-root
```

### CSS Not Loading
```bash
wp theme list --status=active --allow-root
wp theme activate blocksy-child --allow-root
```

### Wrong URLs (localhost:8080)
```bash
wp search-replace 'http://localhost:8080' 'https://talendelight.com' --all-tables --allow-root
wp option update home 'https://talendelight.com' --allow-root
wp option update siteurl 'https://talendelight.com' --allow-root
```

## Version History

| Date | Version | Changes | File |
|------|---------|---------|------|
| 2026-02-08 | v3.5.1 | 64px spacing, icons in single HTML blocks | welcome-6-gutenberg-64px.html |
| 2026-02-08 | v3.5.1 | Initial Gutenberg migration, 48px spacing | welcome-6-gutenberg.html |
| 2026-02-05 | v3.5.0 | Original Elementor version | welcome-6-elementor.json |

## Related Documentation

- [VERSION-HISTORY.md](../../docs/VERSION-HISTORY.md) - Full version history
- [DEPLOYMENT-INSTRUCTIONS-v3.5.1.md](../../docs/DEPLOYMENT-INSTRUCTIONS-v3.5.1.md) - Deployment guide
- [ELEMENTOR-TO-GUTENBERG-MIGRATION.md](../../docs/ELEMENTOR-TO-GUTENBERG-MIGRATION.md) - Migration strategy
