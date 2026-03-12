# Release Notes - v3.7.3 (IN PROGRESS)

**Planned Start:** March 12, 2026  
**Release Date:** TBD  
**Type:** Patch Release  
**Status:** 🔄 In Progress  

## Overview

Refactor inline JavaScript to external `.js` files for better caching, cleaner code, and WordPress best practices compliance.

---

## 🎯 Goals

### Problem
- v3.7.2 used inline `<script>` tags for tab switching on Manager Actions and Operator Actions pages
- WordPress security filtering (`wp_filter_post_kses`) strips script tags by default
- Required specialized deployment script to bypass filtering
- Inline scripts don't benefit from browser caching
- Violates WordPress best practices

### Solution
- Extract JavaScript to external file: `tab-switching.js`
- Enqueue properly via `functions.php` using `wp_enqueue_script()`
- Remove inline `<script>` tags from page content
- Use WordPress conditional loading (only on action pages)

### Benefits
- ✅ No WordPress security filtering issues
- ✅ Better browser caching (JS loaded once, reused)
- ✅ Cleaner page content (separation of concerns)
- ✅ Reusable across multiple pages
- ✅ Proper WordPress enqueue pattern
- ✅ Version control for cache busting
- ✅ Can be minified for production
- ✅ Standard deployment (no specialized scripts needed)

---

## 📋 Tasks

### 1. Create External JavaScript File
**Task:** PENG-109  
**Priority:** High  
**Status:** Not Started  

**File:** `wp-content/themes/blocksy-child/assets/js/tab-switching.js`

**Content:** Extract tab switching JavaScript from Manager Actions and Operator Actions pages.

**Current Inline Code:**
```javascript
(function() {
    const tabButtons = document.querySelectorAll('.td-tab-button');
    const tabContents = document.querySelectorAll('.td-tab-content');
    
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            // ... tab switching logic
        });
    });
    
    // Hover effects
    tabButtons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            // ... hover logic
        });
        button.addEventListener('mouseleave', function() {
            // ... hover logic  
        });
    });
})();
```

**Action:**
- [x] Create `assets/js/` directory in blocksy-child theme
- [ ] Extract JavaScript to `tab-switching.js`
- [ ] Test file loads correctly in local environment

---

### 2. Enqueue JavaScript in functions.php
**Task:** PENG-110  
**Priority:** High  
**Status:** Not Started  
**Dependencies:** PENG-109  

**File:** `wp-content/themes/blocksy-child/functions.php`

**Code to Add:**
```php
/**
 * Enqueue tab switching JavaScript for action pages
 */
function td_enqueue_tab_switching_script() {
    // Only load on Manager Actions and Operator Actions pages
    if (is_page(['actions', 'manager-actions'])) {
        wp_enqueue_script(
            'td-tab-switching',
            get_stylesheet_directory_uri() . '/assets/js/tab-switching.js',
            array(), // No dependencies (vanilla JavaScript)
            '1.0.0', // Version for cache busting
            true // Load in footer (after DOM ready)
        );
    }
}
add_action('wp_enqueue_scripts', 'td_enqueue_tab_switching_script');
```

**Action:**
- [ ] Add function to `functions.php`
- [ ] Test conditional loading (only on action pages)
- [ ] Verify script loads in footer

---

### 3. Update Manager Actions Page
**Task:** PENG-111  
**Priority:** High  
**Status:** Not Started  
**Dependencies:** PENG-109, PENG-110  

**Page:** Manager Actions (ID 27 local, ID 105 production)  
**URL:** `/managers/actions/`

**Changes:**
1. Remove inline `<script>` tags and JavaScript code
2. Keep HTML structure (tabs, buttons, content)
3. JavaScript will load automatically via `functions.php` enqueue

**Before:**
```html
<!-- Tab Switching JavaScript -->
<script>
(function() {
    const tabButtons = document.querySelectorAll('.td-tab-button');
    // ... JavaScript code ...
})();
</script>
```

**After:**
```html
<!-- Tab switching handled by enqueued tab-switching.js -->
```

**Action:**
- [ ] Update restore/pages/manager-actions-27.html
- [ ] Deploy to local using deploy-pages.ps1
- [ ] Test tab switching still works
- [ ] Verify JavaScript loads from external file (DevTools Network tab)

---

### 4. Update Operator Actions Page
**Task:** PENG-112  
**Priority:** High  
**Status:** Not Started  
**Dependencies:** PENG-109, PENG-110  

**Page:** Operator Actions (ID 49 local, ID 84 production)  
**URL:** `/operators/actions/`

**Changes:** Same as Manager Actions page - remove inline script, rely on enqueued external file.

**Action:**
- [ ] Update restore/pages/operator-actions-49.html
- [ ] Deploy to local using deploy-pages.ps1
- [ ] Test tab switching still works
- [ ] Verify JavaScript loads from external file

---

### 5. Local Testing
**Task:** PENG-113  
**Priority:** Critical  
**Status:** Not Started  
**Dependencies:** PENG-111, PENG-112  

**Test Checklist:**

#### Manager Actions Page (https://wp.local/managers/actions/)
- [ ] Page loads without errors
- [ ] Tab buttons render correctly
- [ ] Clicking "New" tab switches content
- [ ] Clicking "Assigned" tab switches content
- [ ] Clicking "Approved" tab switches content
- [ ] Clicking "Rejected" tab switches content
- [ ] Clicking "All" tab switches content
- [ ] Hover effects work (inactive tabs highlight)
- [ ] Active tab has blue border bottom
- [ ] No JavaScript errors in console
- [ ] JavaScript file loads in Network tab (tab-switching.js)

#### Operator Actions Page (https://wp.local/operators/actions/)
- [ ] Same tests as Manager Actions above

#### Browser DevTools Checks
- [ ] Open Network tab → Filter JS files
- [ ] Verify `tab-switching.js` loads (200 status)
- [ ] Check file size (should be ~3-5KB)
- [ ] Open Console → No JavaScript errors
- [ ] View Page Source → No inline `<script>` tags visible

---

### 6. Production Deployment
**Task:** PENG-114  
**Priority:** High  
**Status:** Not Started  
**Dependencies:** PENG-113  

**Deployment Steps:**

1. **Deploy Theme Files (Git Push)**
   ```bash
   git add wp-content/themes/blocksy-child/assets/js/tab-switching.js
   git add wp-content/themes/blocksy-child/functions.php
   git commit -m "Add external JS file for tab switching - v3.7.3"
   git push origin main
   ```

2. **Deploy Page Content (deploy-pages.ps1)**
   ```powershell
   .\infra\shared\scripts\deploy-pages.ps1 -Environment Production -PageNames 'manager-actions','operator-actions'
   ```

3. **Flush Caches**
   ```powershell
   ssh -i "tmp\hostinger_deploy_key" -p 65002 u909075950@45.84.205.129 "cd /home/u909075950/domains/hireaccord.com/public_html && wp cache flush --allow-root"
   ```

4. **Verify Production**
   - Test https://hireaccord.com/managers/actions/
   - Test https://hireaccord.com/operators/actions/
   - Check browser DevTools (JS file loads, no errors)

---

## 📊 Release Statistics

| Metric | Value |
|--------|-------|
| Total Tasks | 6 |
| Completed | 0 |
| Pages Updated | 2 |
| Refactoring Tasks | 4 |
| Testing Tasks | 1 |
| Deployment Tasks | 1 |
| Estimated Days | 0.7 |
| Actual Days | TBD |

---

## 🔧 Technical Details

**Approach:** Option 1 - Theme-based enqueue (WordPress best practice)

**File Structure:**
```
wp-content/themes/blocksy-child/
├── assets/
│   └── js/
│       └── tab-switching.js (NEW)
├── functions.php (MODIFIED - add enqueue function)
└── style.css
```

**Enqueue Details:**
- **Handle:** `td-tab-switching`
- **Location:** `get_stylesheet_directory_uri() . '/assets/js/tab-switching.js'`
- **Dependencies:** None (vanilla JavaScript)
- **Version:** `1.0.0` (for cache busting)
- **Load in Footer:** `true` (better page load performance)
- **Conditional Load:** Only on pages with slug `actions` or `manager-actions`

**WordPress Function Used:**
```php
wp_enqueue_script($handle, $src, $deps, $ver, $in_footer)
```

**Conditional Check:**
```php
is_page(['actions', 'manager-actions'])
```

---

## ✅ Testing Checklist

### Local Environment (https://wp.local/)
- [ ] JavaScript file created: `blocksy-child/assets/js/tab-switching.js`
- [ ] Enqueue function added to `functions.php`
- [ ] Manager Actions page updated (inline script removed)
- [ ] Operator Actions page updated (inline script removed)
- [ ] Tab switching works on Manager Actions
- [ ] Tab switching works on Operator Actions
- [ ] JavaScript file loads (verify in DevTools Network tab)
- [ ] No console errors
- [ ] No inline `<script>` tags in page source

### Production Environment (https://hireaccord.com/)
- [ ] Theme files deployed (git push)
- [ ] Page content deployed (deploy-pages.ps1)
- [ ] Caches flushed
- [ ] Tab switching works on Manager Actions
- [ ] Tab switching works on Operator Actions
- [ ] JavaScript file loads correctly
- [ ] No console errors
- [ ] No inline `<script>` tags in page source

---

## 🚀 Deployment Plan

**Phase 1: Local Development**
1. Create `tab-switching.js` file
2. Update `functions.php` with enqueue function
3. Remove inline scripts from both pages
4. Test thoroughly in local environment

**Phase 2: Production Deployment**
1. Git commit theme files
2. Push to main branch
3. Deploy page content using deploy-pages.ps1
4. Flush caches
5. Verify functionality

**Phase 3: Verification**
1. Manual testing on production
2. Browser DevTools inspection
3. Performance check (file caching)

---

## 🎯 Success Criteria

- ✅ No inline `<script>` tags in page content
- ✅ External `tab-switching.js` file loads successfully
- ✅ Tab switching functionality works on both pages
- ✅ No JavaScript errors in browser console
- ✅ File cached on second page load (faster performance)
- ✅ Standard deployment process (no specialized scripts)
- ✅ WordPress best practices followed

---

## 📝 Notes

**Why This Approach:**
- Follows WordPress coding standards
- Better performance (browser caching)
- Cleaner separation of concerns
- No WordPress security filtering issues
- Easier to maintain and update
- Reusable across multiple pages

**Alternative Considered:**
- Option 2: Simple HTML block with `<script src="">` - works but doesn't leverage WordPress enqueue system for dependencies, versioning, and conditional loading

---

## 🔗 Related Documentation

- [WordPress Developer Handbook - Enqueuing Scripts](https://developer.wordpress.org/themes/basics/including-css-javascript/#enqueuing-scripts-and-styles)
- [Conditional Tags - is_page()](https://developer.wordpress.org/reference/functions/is_page/)
- [wp_enqueue_script() Reference](https://developer.wordpress.org/reference/functions/wp_enqueue_script/)

---

**Release Manager:** GitHub Copilot  
**Developer:** GitHub Copilot (following user direction)  
**Tester:** User (Manual Visual Verification)  

**Started:** March 12, 2026  
**Completed:** TBD
