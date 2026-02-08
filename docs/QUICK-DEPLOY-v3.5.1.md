# v3.5.1 Quick Deployment Guide

**Copy-paste commands for fast deployment**

---

## 1. Commit & Push (5 minutes)

```powershell
cd c:\data\lochness\talendelight\code\wordpress

git add -A
git commit -m "v3.5.1: Migrate Welcome page to Gutenberg, install Better Font Awesome"
git push origin main
```

Wait 30 seconds for Hostinger auto-deployment.

---

## 2. Install Plugin via SSH (2 minutes)

```powershell
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp plugin install better-font-awesome --activate --allow-root"
```

---

## 3. Update Welcome Page Content (5 minutes)

```powershell
# Upload content file
scp -i tmp/hostinger_deploy_key -P 65002 restore/pages/welcome-6-gutenberg.html u909075950@45.84.205.129:~/welcome-content.html

# SSH and run update
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
```

Once in SSH:

```bash
cd domains/talendelight.com/public_html

# Create update script
cat > ~/update-welcome.php << 'EOF'
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');
$content = file_get_contents('/home/u909075950/welcome-content.html');
wp_update_post(['ID' => 6, 'post_content' => $content]);
echo "✅ Done\n";
EOF

# Run it
wp eval-file ~/update-welcome.php --allow-root

# Delete Elementor meta
wp post meta delete 6 _elementor_edit_mode --allow-root
wp post meta delete 6 _elementor_data --allow-root  
wp post meta delete 6 _elementor_version --allow-root

# Clear cache
wp cache flush --allow-root

exit
```

---

## 4. Test (3 minutes)

**Desktop:**
https://talendelight.com/welcome/ (Ctrl+Shift+R)

**Mobile:**
Open on phone, check icons and spacing

---

## Rollback (if needed)

```powershell
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp plugin deactivate better-font-awesome --allow-root"
```

Then restore Elementor backup via welcome-6-elementor.json

---

**Total Time: ~15 minutes**
