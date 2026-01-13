# Step-by-Step Guide: Building Operator Landing Page Locally

**Goal:** Create the Operator landing page (`/operators/`) with "Needs Action" section and four navigation tiles.

**Approach:** Use Elementor page builder (already installed) for visual design, with custom PHP for dynamic data.

---

## Current Status

✅ **COMPLETE - Phase 1 & 2:**
- ✅ Page created (ID: 299, slug: `operators`)
- ✅ Hero section with proper content
- ✅ "Needs Action" section with placeholder
- ✅ 5 navigation tiles (Needs Action, Candidates, Employers, Scouts, Reports)
- ✅ CTA section with "Need Help?" content
- ✅ Footer section
- ✅ Page published at https://wp.local/operators/
- ✅ Role-based access control implemented
- ✅ Login redirect configured (Operators → /operators/)
- ✅ Access restricted to: Operators, Managers, Administrators only

**Next Steps (Phase 3 & 4):**
- Implement dynamic "Needs Action" content (external app/API)
- Create Candidates management page (/operators/candidates/)
- Create Employers management page (/operators/employers/)
- Create Scouts management page (/operators/scouts/)
- Create Reports page (/operators/reports/)

---

## Access Control Summary

**Plugin:** `talendelight-roles` (version 1.0.0)  
**Status:** Active

**What's Implemented:**
1. **Page restriction:** Only Operators, Managers, and Administrators can access `/operators/`
2. **Login redirect:** Operator users automatically redirected to `/operators/` after login
3. **Unauthorized access:** Non-authorized users see 403 error with helpful message
4. **Authentication:** Unauthenticated visitors redirected to login page

**Test Scenarios:**
- ✅ Operator user login → redirects to `/operators/`
- ✅ Manager user login → redirects to `/operators/` (or `/managers/` when built)
- ✅ Administrator login → redirects to `/wp-admin/`
- ✅ Employer/Candidate/Scout users → cannot access `/operators/` (403 error)
- ✅ Non-logged-in users → redirected to login page

---

## Phase 1: Fill Empty Containers (✅ COMPLETE)

### Step 1: Verify Local Development Environment

```powershell
# Check if containers are already running
podman ps

# Look for containers: wordpress, wp-db, caddy
# If running, continue to Step 2
# If not running:
cd c:\data\lochness\talendelight\code\wordpress\infra\dev
podman-compose up -d

# Verify services running
podman ps

# Check WordPress is accessible
# Open: http://localhost:8080
```

**Expected:** WordPress login page appears at http://localhost:8080/wp-admin

**If containers already running:** Continue to Step 2

---

### Step 2: Locate Empty Containers in Elementor

You should see your page structure with:
1. **Hero section** (already filled)
2. **Empty container** - for "Needs Action" section  
3. **Empty container(s)** - for 4 navigation tiles (2×2 grid)
4. **CTA section** (already filled)
5. **Footer** (already filled)

Now proceed to fill the empty containers:

---

### Step 3: Fill "Needs Action" Container

**Locate the first empty container** (between Hero and Tiles)

**A. Add Section Heading with Dropdown:**

1. Click **[+]** inside the empty container
2. Drag **"Heading"** widget
3. Configure:
   - Title: "Needs Action"
   - Style: H2, size `32px`, color Navy `#063970`, weight `700`
   - Alignment: Left

4. Next to heading, add **"Text Editor"** widget (for dropdown - temporary static):
   - Content: `[Today ▼]`
   - Color: Grey `#898989`
   - Size: `16px`
   - Alignment: Right
   - *Note: We'll make this a real dropdown with custom code later*

**B. Add Placeholder for Future Content:**

1. Click **[+]** below the heading
2. Drag **"Text Editor"** widget
3. Configure:
   - Content: `[Needs Action content will be loaded here from external app]`
   - Color: Grey `#898989`
   - Size: `16px`
   - Alignment: Center
   - Style: Italic
   - *Note: This will be replaced with dynamic content from separate page/app*

---

### Step 4: Fill Tiles Container (2×2 Grid)
     - Box Shadow: `0px 2px 8px 0px rgba(0,0,0,0.1)`
   - Go to **Advanced** tab:
     - Padding: 40px all sides
     - Margin: 10px all sides (spacing between tiles)
   - Go to **Link** (in Advanced or at top):
     - Link URL: `/operators/candidates/` (or `#candidates` temporarily)
     - Open in new window: No
   - **Hover Effect** (if available):
     - Box Shadow on hover: `0px 4px 16px 0px rgba(0,0,0,0.15)`
     - Transform: `translateY(-4px)`

3. **Create Second Tile (Employers) - Top Right:**
   
   **In Right Column:**
   - Same structure as Candidates tile
   - Heading: "Employers"
   - Text: "(15 active)"
   - Link: `/operators/employers/` or `#employers`
   - Same styling

4. **Add Second Row - Scouts & Reports:**
   
   - Click [+] below current section
   - Choose: **2 columns** layout again
   
   **Left Column (Scouts):**
   - Heading: "Scouts"
   - Text: "(8 active)"
   - Link: `/operators/scouts/` or `#scouts`
   
   **Right Column (Reports):**
   - Heading: "Reports"
   - Text: "(Export/Pay)"
   - Link: `/operators/reports/` or `#reports`
   
   **Apply same container styling to both:**
   - White background, shadow, padding, link, hover effect

5. **Alternative: Use Custom CSS for Clickable Tiles**

If Elementor doesn't support container links easily, add this CSS via HTML widget at top of page:

```html
<style>
.tile-link {
  display: block;
  background: #FFFFFF;
  padding: 40px;
  margin: 10px;
  box-shadow: 0px 2px 8px 0px rgba(0,0,0,0.1);
  text-align: center;
  text-decoration: none;
  transition: all 0.3s ease;
  cursor: pointer;
}
.tile-link:hover {
  transform: translateY(-4px);
  box-shadow: 0px 4px 16px 0px rgba(0,0,0,0.15);
}
.tile-title {
  color: #063970;
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 10px;
}
.tile-count {
  color: #898989;
  font-size: 16px;
}
</style>
```

Then wrap each tile content in HTML widget:
```html
<a href="/operators/candidates/" class="tile-link">
  <div class="tile-title">Candidates</div>
  <div class="tile-count">(120 total)</div>
</a>
```

---

### Step 4: Fill Tiles Container (2×2 Grid)

**Locate the second empty container** (between "Needs Action" and CTA)

**Strategy:** Create 4 clickable tile cards using HTML widgets for full control

**A. Add HTML Widget for All 4 Tiles:**

1. Click **[+]** inside the empty tiles container
2. Drag **"HTML"** widget
3. Paste this complete tile grid code:

```html
<div class="operator-tiles">
  <a href="/operators/candidates/" class="tile-card">
    <h3 class="tile-title">Candidates</h3>
    <p class="tile-count">(120 total)</p>
  </a>
  
  <a href="/operators/employers/" class="tile-card">
    <h3 class="tile-title">Employers</h3>
    <p class="tile-count">(15 active)</p>
  </a>
  
  <a href="/operators/scouts/" class="tile-card">
    <h3 class="tile-title">Scouts</h3>
    <p class="tile-count">(8 active)</p>
  </a>
  
  <a href="/operators/reports/" class="tile-card">
    <h3 class="tile-title">Reports</h3>
    <p class="tile-count">(Export/Pay)</p>
  </a>
</div>

<style>
.operator-tiles {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.tile-card {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: #FFFFFF;
  padding: 50px 30px;
  box-shadow: 0px 2px 8px 0px rgba(0,0,0,0.1);
  text-decoration: none;
  transition: all 0.3s ease;
  min-height: 150px;
}

.tile-card:hover {
  transform: translateY(-4px);
  box-shadow: 0px 4px 16px 0px rgba(0,0,0,0.15);
}

.tile-title {
  color: #063970;
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 10px 0;
}

.tile-count {
  color: #898989;
  font-size: 16px;
  margin: 0;
}

/* Mobile responsive */
@media (max-width: 768px) {
  .operator-tiles {
    grid-template-columns: 1fr;
  }
}
</style>
```

4. **Save and preview**

---

### Step 5: Save and Publish

1. Click **"Update"** button (bottom left in Elementor)
2. Click **"Preview"** (eye icon) to see full page
3. Test:
   - ✅ "Needs Action" table displays with sample data
   - ✅ 4 tiles display in 2×2 grid
   - ✅ Tiles are clickable (will show 404 for now - pages don't exist yet)
   - ✅ Hover effects work on table rows and tiles
   - ✅ Mobile responsive (tiles stack vertically)

4. When satisfied, click **"Publish"** to make live

**Page is now accessible at:** https://wp.local/operators/

---

## Phase 2: Add Role-Based Access Control

### Step 6: Restrict Page to Operators Only

Create a custom plugin to handle role checks.

1. **Create plugin directory:**

```powershell
New-Item -Path "wp-content\plugins\talendelight-operators" -ItemType Directory
```

2. **Create main plugin file:**

```powershell
New-Item -Path "wp-content\plugins\talendelight-operators\talendelight-operators.php" -ItemType File
```

3. **Add plugin code:**

```php
<?php
/**
 * Plugin Name: TalenDelight Operators Portal
 * Description: Operator and Manager landing pages with role-based access
 * Version: 1.0.0
 * Author: TalenDelight
 */

// Prevent direct access
if ( ! defined( 'ABSPATH' ) ) exit;

/**
 * Redirect non-Operators away from Operator pages
 */
function td_restrict_operator_pages() {
    // Only run on operator pages
    if ( ! is_page( 'operators' ) ) {
        return;
    }
    
    // Allow if not logged in (will show login page)
    if ( ! is_user_logged_in() ) {
        auth_redirect();
        exit;
    }
    
    // Check if user has Operator or Manager role
    $user = wp_get_current_user();
    $allowed_roles = array( 'td_operator', 'td_manager', 'administrator' );
    
    $has_access = false;
    foreach ( $allowed_roles as $role ) {
        if ( in_array( $role, $user->roles ) ) {
            $has_access = true;
            break;
        }
    }
    
    if ( ! $has_access ) {
        // Redirect to 403 page or home
        wp_redirect( home_url( '/403-forbidden/' ) );
        exit;
    }
}
add_action( 'template_redirect', 'td_restrict_operator_pages' );
```

4. **Activate plugin:**
   - Go to: http://localhost:8080/wp-admin/plugins.php
   - Find "TalenDelight Operators Portal"
   - Click "Activate"

5. **Test access control:**
   - Logout (if logged in as admin)
   - Try to access: http://localhost:8080/operators/
   - Should redirect to login page
   - After login with non-operator user, should redirect to 403

---

## Phase 3: Make Data Dynamic (Next Steps)

### Step 7: Create Sample Data (Candidates, Employers)

**Option A: Use Custom Post Types**

Add to the plugin file:

```php
/**
 * Register Candidate Custom Post Type
 */
function td_register_candidate_cpt() {
    register_post_type( 'td_candidate', array(
        'labels' => array(
            'name' => 'Candidates',
            'singular_name' => 'Candidate',
        ),
        'public' => false,
        'show_ui' => true,
        'show_in_menu' => true,
        'supports' => array( 'title', 'custom-fields' ),
        'has_archive' => false,
        'rewrite' => false,
    ) );
}
add_action( 'init', 'td_register_candidate_cpt' );
```

**Option B: Use Database Table** (more scalable)

```php
/**
 * Create candidates table on plugin activation
 */
function td_create_candidates_table() {
    global $wpdb;
    $table_name = $wpdb->prefix . 'td_candidates';
    $charset_collate = $wpdb->get_charset_collate();
    
    $sql = "CREATE TABLE IF NOT EXISTS $table_name (
        id bigint(20) NOT NULL AUTO_INCREMENT,
        candidate_id varchar(50) NOT NULL UNIQUE,
        name varchar(200) NOT NULL,
        email varchar(200) NOT NULL,
        phone varchar(50),
        linkedin_url varchar(500),
        status varchar(50) DEFAULT 'new',
        assigned_to bigint(20),
        next_action_date date,
        submitted_date datetime DEFAULT CURRENT_TIMESTAMP,
        updated_date datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY status (status),
        KEY assigned_to (assigned_to),
        KEY submitted_date (submitted_date)
    ) $charset_collate;";
    
    require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );
    dbDelta( $sql );
}
register_activation_hook( __FILE__, 'td_create_candidates_table' );
```

---

### Step 8: Add Dynamic Data to "Needs Action" Table

Replace the static HTML table with dynamic PHP:

```php
/**
 * Shortcode to display Needs Action table
 */
function td_needs_action_table_shortcode( $atts ) {
    // Parse attributes
    $atts = shortcode_atts( array(
        'filter' => 'today', // today, 7days, all
    ), $atts );
    
    global $wpdb;
    $table_name = $wpdb->prefix . 'td_candidates';
    $current_user_id = get_current_user_id();
    
    // Build query based on filter
    $where_clauses = array();
    
    // New candidates (within 7 days)
    $where_clauses[] = "(status = 'new' AND submitted_date >= DATE_SUB(NOW(), INTERVAL 7 DAY))";
    
    // Follow-up due
    if ( $atts['filter'] === 'today' ) {
        $where_clauses[] = "(next_action_date = CURDATE())";
    } elseif ( $atts['filter'] === '7days' ) {
        $where_clauses[] = "(next_action_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY))";
    } else {
        $where_clauses[] = "(next_action_date IS NOT NULL)";
    }
    
    // Unassigned candidates
    $where_clauses[] = "(assigned_to IS NULL OR assigned_to = 0)";
    
    $where_sql = implode( ' OR ', $where_clauses );
    
    $query = "SELECT * FROM $table_name WHERE $where_sql ORDER BY submitted_date DESC LIMIT 20";
    $results = $wpdb->get_results( $query );
    
    // Build HTML
    ob_start();
    ?>
    <div class="needs-action-table">
        <table>
            <thead>
                <tr>
                    <th>Type</th>
                    <th>Name</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <?php if ( $results ) : ?>
                    <?php foreach ( $results as $item ) : ?>
                        <tr onclick="window.location.href='/operators/candidates/<?php echo esc_attr( $item->candidate_id ); ?>/'">
                            <td>👤 Candidate</td>
                            <td><?php echo esc_html( $item->name ); ?></td>
                            <td><span class="badge badge-<?php echo esc_attr( $item->status ); ?>"><?php echo ucfirst( $item->status ); ?></span></td>
                            <td><?php echo date( 'M j, Y', strtotime( $item->submitted_date ) ); ?></td>
                            <td>→</td>
                        </tr>
                    <?php endforeach; ?>
                <?php else : ?>
                    <tr>
                        <td colspan="5" style="text-align:center;">No items need action</td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    <?php
    return ob_get_clean();
}
add_shortcode( 'td_needs_action', 'td_needs_action_table_shortcode' );
```

**In Elementor:**
- Replace the HTML widget with **Shortcode widget**
- Enter: `[td_needs_action filter="today"]`

---

## Next Steps Summary

**You've now completed:**
✅ Phase 1: Basic page structure with Elementor
✅ Phase 2: Access control (role checking)
✅ Phase 3: Database setup for dynamic data

**What's next:**
1. Add sample candidate data for testing
2. Create the Candidates management page (drill-down)
3. Create Candidate detail page
4. Add Employers, Scouts, Reports pages
5. Implement search and filter functionality
6. Add AJAX for real-time updates

---

## Testing Checklist

- [ ] Page accessible at http://localhost:8080/operators/
- [ ] Requires login (redirects if not logged in)
- [ ] Requires Operator role (403 if wrong role)
- [ ] "Needs Action" section displays
- [ ] Four tiles display correctly
- [ ] Tiles are clickable (even with # links)
- [ ] Mobile responsive (tiles stack on small screens)
- [ ] No console errors

---

## Troubleshooting

**Issue: Page shows 404**
- Check slug is exactly "operators"
- Re-save permalinks: Settings → Permalinks → Save

**Issue: Access control not working**
- Verify plugin is activated
- Check user has td_operator or td_manager role
- Clear cache

**Issue: Elementor not loading**
- Check Elementor plugin is active
- Try re-saving the page

**Issue: Dynamic data not showing**
- Check database table exists
- Add sample data manually via phpMyAdmin
- Check shortcode syntax

---

**Ready to start?** Follow Step 1 to fire up your local environment!
