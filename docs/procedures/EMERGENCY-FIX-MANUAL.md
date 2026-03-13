# Emergency Production Fix - Manual Steps

**Created**: February 9, 2026  
**Issue**: Production redirecting to :8080 and Welcome page missing  
**Status**: SSH connection timing out - requires manual fix via Hostinger control panel

## Problem Summary

1. **Critical (P0)**: Production site redirecting to `https://talendelight.com:8080/` (unreachable)
2. **High (P1)**: Welcome page missing (no homepage set)

## Root Cause

WordPress database options misconfigured:
- `siteurl` option: pointing to `:8080` instead of `https://talendelight.com`
- `home` option: pointing to `:8080` instead of `https://talendelight.com`
- `page_on_front` option: not set (0) - no homepage
- Welcome page: missing from database

## Manual Fix Steps

### Option A: Via Hostinger File Manager + Terminal

1. **Log into Hostinger**
   - Go to: https://hpanel.hostinger.com
   - Navigate to your hosting account

2. **Upload Fix Scripts**
   - Open File Manager
   - Navigate to home directory (`/home/u909075950/`)
   - Upload these 3 files:
     - `fix-urls.php` (see Step 3 below)
     - `restore-welcome.php` (see Step 4 below)
     - `welcome-content.html` (from `restore/pages/welcome-page-clean.html`)

3. **Create fix-urls.php**
   
   ```php
   <?php
   require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');
   
   // Fix site URL and home URL
   update_option('siteurl', 'https://talendelight.com');
   update_option('home', 'https://talendelight.com');
   
   echo "URLs fixed:\n";
   echo "  siteurl: " . get_option('siteurl') . "\n";
   echo "  home: " . get_option('home') . "\n";
   
   // Flush caches
   wp_cache_flush();
   echo "Cache flushed\n";
   ?>
   ```

4. **Create restore-welcome.php**
   
   ```php
   <?php
   require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');
   
   $content = file_get_contents('/home/u909075950/welcome-content.html');
   if (!$content) {
       echo "Error: Could not read welcome-content.html\n";
       exit(1);
   }
   
   // Check if Welcome page exists
   $existing = get_page_by_path('welcome', OBJECT, 'page');
   
   if ($existing) {
       // Update existing page
       $result = wp_update_post(array(
           'ID' => $existing->ID,
           'post_content' => $content,
       ));
       
       if (is_wp_error($result)) {
           echo "Error updating page: " . $result->get_error_message() . "\n";
           exit(1);
       }
       
       $page_id = $existing->ID;
       echo "Success: Welcome page updated (ID: $page_id)\n";
   } else {
       // Create new page
       $page_id = wp_insert_post(array(
           'post_title' => 'Welcome',
           'post_name' => 'welcome',
           'post_content' => $content,
           'post_status' => 'publish',
           'post_type' => 'page',
           'comment_status' => 'closed',
           'ping_status' => 'closed',
       ));
       
       if (is_wp_error($page_id)) {
           echo "Error creating page: " . $page_id->get_error_message() . "\n";
           exit(1);
       }
       
       echo "Success: Welcome page created (ID: $page_id)\n";
   }
   
   // Set as homepage
   update_option('show_on_front', 'page');
   update_option('page_on_front', $page_id);
   
   echo "Set as homepage (page_on_front = $page_id)\n";
   
   // Flush caches
   wp_cache_flush();
   echo "Cache flushed\n";
   
   // Cleanup
   unlink('/home/u909075950/welcome-content.html');
   ?>
   ```

5. **Execute Fixes**
   - In File Manager, open Terminal (or use Hostinger's SSH terminal)
   - Run:
     ```bash
     cd ~
     php fix-urls.php
     php restore-welcome.php
     ```

6. **Verify Fixes**
   ```bash
   cd domains/talendelight.com/public_html
   wp option get siteurl --allow-root
   wp option get home --allow-root
   wp option get page_on_front --allow-root
   wp post list --post_type=page --format=csv --fields=ID,post_title,post_name --allow-root
   ```

7. **Test Site**
   - Visit: https://talendelight.com
   - Verify: No :8080 redirect
   - Verify: Welcome page displays as homepage

8. **Cleanup**
   ```bash
   rm ~/fix-urls.php
   rm ~/restore-welcome.php
   ```

### Option B: Via Hostinger phpMyAdmin

**Warning**: Direct database editing is riskier. Use Option A if possible.

1. **Fix URLs**
   - Open phpMyAdmin from Hostinger control panel
   - Select WordPress database
   - Run SQL:
     ```sql
     UPDATE wp_options SET option_value = 'https://talendelight.com' WHERE option_name = 'siteurl';
     UPDATE wp_options SET option_value = 'https://talendelight.com' WHERE option_name = 'home';
     ```

2. **Restore Welcome Page**
   - This requires creating the page via WordPress admin panel after URLs are fixed
   - Or use File Manager method above to run restore-welcome.php

### Option C: Via WordPress Admin Panel (After URLs Fixed)

1. **Fix URLs First** (use Option A or B above)

2. **Restore Welcome Page**
   - Log into WordPress admin: https://talendelight.com/wp-admin
   - Go to Pages → Add New
   - Title: "Welcome"
   - Paste content from `restore/pages/welcome-page-clean.html`
   - Publish page
   - Go to Settings → Reading
   - Set "Your homepage displays" to "A static page"
   - Select "Welcome" as Homepage
   - Save changes

## After Fix Complete

1. **Create Backup**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 backup
   ```

2. **Verify Production**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 verify
   ```

3. **Document Incident**
   - Update incident log
   - Document root cause
   - Update disaster recovery procedures if needed

## Why SSH Connection Timing Out

Possible causes:
1. Rate limiting from previous multiple connection attempts
2. Hostinger firewall blocking IP temporarily
3. Hostinger maintenance/issues
4. Network connectivity problem

**Solution**: Wait 30-60 minutes for rate limit to clear, or use File Manager alternative above.

## Files Referenced

- **Welcome page backup**: `restore/pages/welcome-page-clean.html`
- **Emergency script (automated)**: `infra/shared/scripts/emergency-fix-production.ps1`
- **This manual guide**: `docs/EMERGENCY-FIX-MANUAL.md`

## Production Credentials

- **Hostinger Control Panel**: https://hpanel.hostinger.com
- **WordPress Admin**: https://talendelight.com/wp-admin
- **SSH Host**: 45.84.205.129:22
- **SSH User**: u909075950
- **Database**: Accessible via phpMyAdmin in Hostinger control panel
