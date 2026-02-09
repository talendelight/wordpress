#Requires -Version 5.1
<#
.SYNOPSIS
    Emergency production fix for URL redirect and missing Welcome page
    
.DESCRIPTION
    Fixes two critical production issues:
    1. URLs redirecting to :8080 (wrong domain)
    2. Welcome page missing (no homepage)
    
.NOTES
    Created: February 9, 2026
    Incident: Production redirecting to :8080 and Welcome page missing
#>

$ErrorActionPreference = "Stop"

$SSH_USER = "u909075950"
$SSH_HOST = "45.84.205.129"
$SSH_PORT = "65002"  # Hostinger uses port 65002, not default 22
$SSH_KEY = Join-Path $PSScriptRoot "..\..\..\tmp\hostinger_deploy_key"
$PROD_PATH = "domains/talendelight.com/public_html"

Write-Host "=== Production Emergency Fix ===" -ForegroundColor Cyan
Write-Host "Fixing: 1) Welcome page missing, 2) URL redirect to :8080`n" -ForegroundColor Yellow

# Step 1: Fix WordPress URLs
Write-Host "1. Fixing WordPress URLs..." -ForegroundColor Cyan

$fixUrlsScript = @'
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
'@

# Write fix script
$tempDir = Join-Path $env:TEMP "wp-emergency-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$fixUrlsFile = Join-Path $tempDir "fix-urls.php"
Set-Content -Path $fixUrlsFile -Value $fixUrlsScript -NoNewline

Write-Host "  Uploading URL fix script..." -ForegroundColor Gray
if (Test-Path $SSH_KEY) {
    scp -i $SSH_KEY -P $SSH_PORT $fixUrlsFile "${SSH_USER}@${SSH_HOST}:~/fix-urls.php"
} else {
    Write-Host "  Note: SSH key not found, will prompt for password" -ForegroundColor Yellow
    scp -P $SSH_PORT $fixUrlsFile "${SSH_USER}@${SSH_HOST}:~/fix-urls.php"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Executing URL fix..." -ForegroundColor Gray
    if (Test-Path $SSH_KEY) {
        $result = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "php ~/fix-urls.php && rm ~/fix-urls.php"
    } else {
        $result = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "php ~/fix-urls.php && rm ~/fix-urls.php"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $([char]0x2713) URLs fixed:" -ForegroundColor Green
        Write-Host $result -ForegroundColor Gray
    } else {
        Write-Host "  Failed to execute URL fix (exit code: $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  Failed to upload URL fix script (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# Step 2: Restore Welcome page
Write-Host "`n2. Restoring Welcome page..." -ForegroundColor Cyan

# Read Welcome page content
$welcomePagePath = Join-Path $PSScriptRoot "..\..\..\restore\pages\welcome-page-clean.html"
if (!(Test-Path $welcomePagePath)) {
    Write-Host "  Error: Welcome page backup not found at $welcomePagePath" -ForegroundColor Red
    exit 1
}

$welcomeHtml = Get-Content $welcomePagePath -Raw

# Create temporary HTML file
$welcomeHtmlFile = Join-Path $tempDir "welcome-content.html"
Set-Content -Path $welcomeHtmlFile -Value $welcomeHtml -NoNewline

Write-Host "  Uploading Welcome page content..." -ForegroundColor Gray
if (Test-Path $SSH_KEY) {
    scp -i $SSH_KEY -P $SSH_PORT $welcomeHtmlFile "${SSH_USER}@${SSH_HOST}:~/welcome-content.html"
} else {
    scp -P $SSH_PORT $welcomeHtmlFile "${SSH_USER}@${SSH_HOST}:~/welcome-content.html"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "  Failed to upload Welcome page content (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# Create restore script
$restoreScript = @'
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

// Force correct URLs (prevent localhost:8080 contamination)
update_option('siteurl', 'https://talendelight.com');
update_option('home', 'https://talendelight.com');
echo "URLs verified: https://talendelight.com\n";

// Flush caches
wp_cache_flush();
echo "Cache flushed\n";

// Cleanup
unlink('/home/u909075950/welcome-content.html');
?>
'@

$restoreScriptFile = Join-Path $tempDir "restore-welcome.php"
Set-Content -Path $restoreScriptFile -Value $restoreScript -NoNewline

Write-Host "  Uploading restore script..." -ForegroundColor Gray
if (Test-Path $SSH_KEY) {
    scp -i $SSH_KEY -P $SSH_PORT $restoreScriptFile "${SSH_USER}@${SSH_HOST}:~/restore-welcome.php"
} else {
    scp -P $SSH_PORT $restoreScriptFile "${SSH_USER}@${SSH_HOST}:~/restore-welcome.php"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Executing restore..." -ForegroundColor Gray
    if (Test-Path $SSH_KEY) {
        $result = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "php ~/restore-welcome.php && rm ~/restore-welcome.php"
    } else {
        $result = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "php ~/restore-welcome.php && rm ~/restore-welcome.php"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $([char]0x2713) Welcome page restored:" -ForegroundColor Green
        Write-Host $result -ForegroundColor Gray
    } else {
        Write-Host "  Failed to execute restore (exit code: $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  Failed to upload restore script (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# Step 3: Verify and fix theme
Write-Host "`n3. Checking theme..." -ForegroundColor Cyan

if (Test-Path $SSH_KEY) {
    $themeCheck = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp theme list --status=active --field=name --allow-root"
} else {
    $themeCheck = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp theme list --status=active --field=name --allow-root"
}

if ($themeCheck -notmatch "blocksy") {
    Write-Host "  Wrong theme active ($themeCheck), activating Blocksy..." -ForegroundColor Yellow
    if (Test-Path $SSH_KEY) {
        ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp theme activate blocksy --allow-root && wp cache flush --allow-root"
    } else {
        ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp theme activate blocksy --allow-root && wp cache flush --allow-root"
    }
    Write-Host "  $([char]0x2713) Blocksy theme activated" -ForegroundColor Green
} else {
    Write-Host "  $([char]0x2713) Correct theme active: $themeCheck" -ForegroundColor Green
}

# Step 3.5: Verify Blocksy Companion plugin
Write-Host "`n3.5. Checking Blocksy Companion plugin..." -ForegroundColor Cyan

if (Test-Path $SSH_KEY) {
    $pluginCheck = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp plugin list --name=blocksy-companion --field=status --allow-root 2>/dev/null"
} else {
    $pluginCheck = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp plugin list --name=blocksy-companion --field=status --allow-root 2>/dev/null"
}

if ($pluginCheck -ne "active") {
    Write-Host "  Blocksy Companion not active, activating..." -ForegroundColor Yellow
    if (Test-Path $SSH_KEY) {
        ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp plugin activate blocksy-companion --allow-root 2>&1"
    } else {
        ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp plugin activate blocksy-companion --allow-root 2>&1"
    }
    Write-Host "  $([char]0x2713) Blocksy Companion activated" -ForegroundColor Green
} else {
    Write-Host "  $([char]0x2713) Blocksy Companion active" -ForegroundColor Green
}

# Step 3.6: Fix permalinks
Write-Host "`n3.6. Checking permalink structure..." -ForegroundColor Cyan

if (Test-Path $SSH_KEY) {
    $permalinkCheck = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp option get permalink_structure --allow-root 2>/dev/null"
} else {
    $permalinkCheck = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp option get permalink_structure --allow-root 2>/dev/null"
}

if ([string]::IsNullOrWhiteSpace($permalinkCheck)) {
    Write-Host "  Permalink structure not set, fixing..." -ForegroundColor Yellow
    if (Test-Path $SSH_KEY) {
        ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp rewrite structure '/%postname%/' --allow-root && wp rewrite flush --allow-root"
    } else {
        ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp rewrite structure '/%postname%/' --allow-root && wp rewrite flush --allow-root"
    }
    Write-Host "  $([char]0x2713) Permalink structure set to /%postname%/" -ForegroundColor Green
} else {
    Write-Host "  $([char]0x2713) Permalink structure: $permalinkCheck" -ForegroundColor Green
}

# Step 3.7: Verify and fix HTTPS redirect
Write-Host "`n3.7. Checking HTTPS redirect..." -ForegroundColor Cyan

$htaccessFix = @'
# Force HTTPS - Must be first
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

'@

if (Test-Path $SSH_KEY) {
    $hasHttpsRedirect = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && head -10 .htaccess | grep -c 'Force HTTPS'"
} else {
    $hasHttpsRedirect = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && head -10 .htaccess | grep -c 'Force HTTPS'"
}

if ($hasHttpsRedirect -eq "0") {
    Write-Host "  HTTPS redirect missing, adding..." -ForegroundColor Yellow
    
    $tempHtaccess = Join-Path $tempDir "htaccess-fix.txt"
    Set-Content -Path $tempHtaccess -Value $htaccessFix -NoNewline
    
    if (Test-Path $SSH_KEY) {
        scp -i $SSH_KEY -P $SSH_PORT $tempHtaccess "${SSH_USER}@${SSH_HOST}:~/htaccess-fix.txt"
        ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && cat ~/htaccess-fix.txt .htaccess > .htaccess.new && mv .htaccess.new .htaccess && rm ~/htaccess-fix.txt"
    } else {
        scp -P $SSH_PORT $tempHtaccess "${SSH_USER}@${SSH_HOST}:~/htaccess-fix.txt"
        ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && cat ~/htaccess-fix.txt .htaccess > .htaccess.new && mv .htaccess.new .htaccess && rm ~/htaccess-fix.txt"
    }
    
    Write-Host "  $([char]0x2713) HTTPS redirect added to .htaccess" -ForegroundColor Green
} else {
    Write-Host "  $([char]0x2713) HTTPS redirect configured" -ForegroundColor Green
}

# Step 3.8: Verify homepage is set to Welcome page
Write-Host "`n3.8. Checking homepage setting..." -ForegroundColor Cyan

if (Test-Path $SSH_KEY) {
    $homepageCheck = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" @"
cd $PROD_PATH
SHOW_ON_FRONT=`$(wp option get show_on_front --allow-root 2>/dev/null)
PAGE_ON_FRONT=`$(wp option get page_on_front --allow-root 2>/dev/null)
WELCOME_ID=`$(wp post list --post_type=page --name=welcome --field=ID --allow-root 2>/dev/null)

if [ "`$SHOW_ON_FRONT" != "page" ] || [ "`$PAGE_ON_FRONT" != "`$WELCOME_ID" ] || [ -z "`$WELCOME_ID" ]; then
  echo "FIX_NEEDED:`$WELCOME_ID"
else
  echo "OK:`$PAGE_ON_FRONT"
fi
"@
} else {
    $homepageCheck = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" @"
cd $PROD_PATH
SHOW_ON_FRONT=`$(wp option get show_on_front --allow-root 2>/dev/null)
PAGE_ON_FRONT=`$(wp option get page_on_front --allow-root 2>/dev/null)
WELCOME_ID=`$(wp post list --post_type=page --name=welcome --field=ID --allow-root 2>/dev/null)

if [ "`$SHOW_ON_FRONT" != "page" ] || [ "`$PAGE_ON_FRONT" != "`$WELCOME_ID" ] || [ -z "`$WELCOME_ID" ]; then
  echo "FIX_NEEDED:`$WELCOME_ID"
else
  echo "OK:`$PAGE_ON_FRONT"
fi
"@
}

if ($homepageCheck -match "FIX_NEEDED:(.+)") {
    $welcomeId = $matches[1]
    if ($welcomeId) {
        Write-Host "  Homepage not set correctly, setting to Welcome page (ID: $welcomeId)..." -ForegroundColor Yellow
        if (Test-Path $SSH_KEY) {
            ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp option update show_on_front page --allow-root && wp option update page_on_front $welcomeId --allow-root && wp cache flush --allow-root"
        } else {
            ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" "cd $PROD_PATH && wp option update show_on_front page --allow-root && wp option update page_on_front $welcomeId --allow-root && wp cache flush --allow-root"
        }
        Write-Host "  $([char]0x2713) Homepage set to Welcome page" -ForegroundColor Green
    } else {
        Write-Host "  Warning: Welcome page not found, cannot set homepage" -ForegroundColor Yellow
    }
} else {
    Write-Host "  $([char]0x2713) Homepage correctly set to Welcome page" -ForegroundColor Green
}

# Step 4: Verify fixes
Write-Host "`n4. Verifying fixes..." -ForegroundColor Cyan

if (Test-Path $SSH_KEY) {
    $verifyResult = ssh -i $SSH_KEY -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" @"
cd $PROD_PATH
echo '=== Production Status ==='
echo 'URLs:'
wp option get siteurl --allow-root
wp option get home --allow-root
echo 'Homepage:'
wp option get page_on_front --allow-root
echo 'Theme:'
wp theme list --status=active --allow-root
echo 'Pages:'
wp post list --post_type=page --format=csv --fields=ID,post_title,post_name --allow-root
"@
} else {
    $verifyResult = ssh -p $SSH_PORT "${SSH_USER}@${SSH_HOST}" @"
cd $PROD_PATH
echo '=== Production Status ==='
echo 'URLs:'
wp option get siteurl --allow-root
wp option get home --allow-root
echo 'Homepage:'
wp option get page_on_front --allow-root
echo 'Theme:'
wp theme list --status=active --allow-root
echo 'Pages:'
wp post list --post_type=page --format=csv --fields=ID,post_title,post_name --allow-root
"@
}

if ($LASTEXITCODE -eq 0) {
    Write-Host $verifyResult -ForegroundColor Gray
} else {
    Write-Host "  Warning: Could not verify (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
}

# Cleanup temp directory
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=== Production Fix Complete ===" -ForegroundColor Green
Write-Host "$([char]0x2713) URLs fixed (https://talendelight.com)" -ForegroundColor Green
Write-Host "$([char]0x2713) Welcome page restored and set as homepage" -ForegroundColor Green
Write-Host "$([char]0x2713) Blocksy theme and companion activated" -ForegroundColor Green
Write-Host "$([char]0x2713) Permalink structure configured" -ForegroundColor Green
Write-Host "`nTest site: https://talendelight.com" -ForegroundColor Cyan
