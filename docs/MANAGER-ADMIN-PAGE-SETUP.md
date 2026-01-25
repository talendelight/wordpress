# Step-by-Step Guide: Building Manager Admin Page

**Date:** January 19, 2026  
**Purpose:** Create Manager Admin operations hub page using Managers Dashboard as a template

---

## Overview

**Page Details:**
- **Page ID:** 386
- **Slug:** `manager-admin`
- **Title:** Manager Admin
- **Hero Heading:** Admin Operations
- **URL:** http://localhost:8080/manager-admin/
- **Status:** Draft (ready to build)

**Purpose:** Central hub for system administration tasks including:
- User Request Approvals
- User Management
- System Settings
- Audit Logs
- Role Management
- Platform Monitoring

---

## Step-by-Step Build Process

### Step 1: Access the Page in WordPress Admin

1. **Navigate to Pages:**
   - Go to: http://localhost:8080/wp-admin/edit.php?post_type=page
   - Find "Manager Admin" (ID 386) - should show as Draft

2. **Set Page Template:**
   - Click "Edit" on the Manager Admin page
   - In right sidebar → **Template:** Select "Elementor Canvas"
   - In right sidebar → **Blocksy** section → **Page Layout:** Set to "Default"
   - Click "Update" to save settings

3. **Open Elementor Editor:**
   - Click "Edit with Elementor" button at the top
   - OR navigate directly to: http://localhost:8080/wp-admin/post.php?post=386&action=elementor
   - Elementor editor will load with a blank canvas

---

### Step 2: Build Hero Section

**What to Build:**
- Dark navy background
- Centered heading: "Admin Operations"
- Centered subtitle: "Manage system settings, user requests, and admin tasks"
- Optional: Button linking to documentation

**Steps:**

1. **Add Container Section:**
   - Click (+) icon to add new section
   - Choose "Container" (not Section - Elementor uses Flexbox containers now)
   - Set full-width layout

2. **Configure Container Settings:**
   - Click the container border → Settings (left panel)
   - **Layout:**
     - Content Width: Full Width (100%)
     - Min Height: 300px (or adjust to preference)
     - Align Items: Center
     - Justify Content: Center
   - **Style → Background:**
     - Background Type: Classic (Color)
     - Color: `#0a2540` (dark navy) or use Blocksy theme's primary color
   - **Advanced → Padding:**
     - Top: 60px, Bottom: 60px (adjust for spacing)

3. **Add Heading Widget:**
   - Inside the container, click (+) → Search "Heading"
   - Drag "Heading" widget into container
   - **Content:**
     - Title: "Admin Operations"
     - HTML Tag: H1
   - **Style:**
     - Text Color: White (#ffffff)
     - Typography: 
       - Font Size: 48px (desktop), 32px (tablet), 28px (mobile)
       - Font Weight: Bold (600-700)
     - Text Align: Center

4. **Add Subheading (Text Editor Widget):**
   - Click (+) below heading → Search "Text Editor"
   - Drag into container (below heading)
   - **Content:**
     - Text: "Manage system settings, user requests, and admin tasks"
   - **Style:**
     - Text Color: Light gray (#e0e0e0 or rgba(255,255,255,0.8))
     - Typography:
       - Font Size: 18px (desktop), 16px (mobile)
       - Font Weight: 400
     - Text Align: Center
     - Padding Top: 10px (spacing from heading)

5. **Optional: Add Button:**
   - Click (+) below text → Search "Button"
   - Drag into container
   - **Content:**
     - Text: "View Documentation"
     - Link: #help (or actual documentation URL)
   - **Style:**
     - Alignment: Center
     - Text Color: White
     - Background Color: Transparent or accent color
     - Border: 2px solid white
     - Padding: 12px 30px
     - Margin Top: 20px

**Preview:** Hero section complete with dark navy background, centered white text, and optional button.

---

### Step 3: Build Admin Operations Tiles Section

**What to Build:**
- Grid of 6 tiles (2 rows × 3 columns)
- Each tile: Icon, heading, description, click handler
- Similar styling to Managers Dashboard tiles

**Option A: Copy from Managers Dashboard (Fastest)**

1. **Open Managers page in new tab:**
   - Navigate to: http://localhost:8080/wp-admin/post.php?post=333&action=elementor
   - This is your source page

2. **Select the tiles section:**
   - In Navigator (hamburger menu), find the section with tiles
   - Right-click the section → "Copy"

3. **Switch back to Manager Admin page:**
   - Right-click in canvas (below hero) → "Paste"
   - Entire tiles section will be duplicated

4. **Modify tile content** (see next section for details)

**Option B: Build from Scratch**

1. **Add Container Section:**
   - Click (+) below hero → Add "Container"
   - Set Content Width: Boxed (1140px max width for desktop)
   - Set Direction: Row (horizontal)
   - Set Wrap: Wrap (tiles will wrap to next row)
   - Justify Content: Space Between
   - Align Items: Stretch

2. **Add Inner Container for Each Tile (Repeat 6 times):**
   
   **For EACH tile, follow these steps:**
   
   a. **Add Inner Container:**
      - Inside the main container, click (+) → Add "Container"
      - This is one tile
   
   b. **Configure Tile Container:**
      - **Layout:**
        - Width: 30% (desktop), 45% (tablet), 100% (mobile)
        - Min Height: 200px
        - Direction: Column (vertical)
        - Align Items: Center
        - Justify Content: Center
      - **Style → Background:**
        - Color: White (#ffffff) or light gray (#f5f5f5)
        - Hover: Slightly darker or add shadow
      - **Style → Border:**
        - Border Type: Solid
        - Width: 1px
        - Color: #e0e0e0
        - Border Radius: 8px (rounded corners)
      - **Advanced → Padding:**
        - All sides: 30px
      - **Advanced → Margin:**
        - Bottom: 30px (spacing between rows)
   
   c. **Add Icon Widget:**
      - Inside tile container, click (+) → "Icon"
      - **Content:**
        - Icon Library: Font Awesome
        - Choose icon (see tile details below)
      - **Style:**
        - Primary Color: Theme primary color or #0a2540 (navy)
        - Size: 48px
        - Alignment: Center
   
   d. **Add Heading Widget:**
      - Below icon, add "Heading"
      - **Content:**
        - Title: (see tile details below)
        - HTML Tag: H3
      - **Style:**
        - Text Color: Dark (#333333)
        - Typography: Font Size 20px, Weight 600
        - Alignment: Center
        - Margin Top: 15px
   
   e. **Add Text Widget:**
      - Below heading, add "Text Editor"
      - **Content:**
        - Description: (see tile details below)
      - **Style:**
        - Text Color: Medium gray (#666666)
        - Typography: Font Size 14px
        - Alignment: Center
        - Margin Top: 10px
   
   f. **Add Link/Click Behavior:**
      - Click the tile container border → Settings
      - **Advanced → Motion Effects → Click:**
        - OR use "Link" option in Advanced settings
        - Link: #user-requests (or actual URL when available)
        - Open in: Same window

---

### Step 4: Tile Content Details

**Tile 1: User Request Approvals**
- **Icon:** fas fa-user-check
- **Heading:** User Request Approvals
- **Description:** Review and approve user profile change requests
- **Badge/Note:** "12 pending" (optional, can add as small text)
- **Link:** #user-requests (future: /manager-admin/user-requests/)

**Tile 2: User Management**
- **Icon:** fas fa-users-cog
- **Heading:** User Management
- **Description:** Manage user accounts, roles, and permissions
- **Link:** #users (placeholder)

**Tile 3: System Settings**
- **Icon:** fas fa-cogs
- **Heading:** System Settings
- **Description:** Configure platform settings and preferences
- **Link:** #settings (placeholder)

**Tile 4: Audit Logs**
- **Icon:** fas fa-history or fas fa-clipboard-list
- **Heading:** Audit Logs
- **Description:** View system activity and compliance logs
- **Link:** #audit (placeholder)

**Tile 5: Role Management**
- **Icon:** fas fa-user-shield
- **Heading:** Role Management
- **Description:** Define and manage user role permissions
- **Link:** #roles (placeholder)

**Tile 6: Platform Monitoring**
- **Icon:** fas fa-chart-line or fas fa-tachometer-alt
- **Heading:** Platform Monitoring
- **Description:** Monitor system health and performance metrics
- **Link:** #monitoring (placeholder)

---

### Step 5: Add CTA Section (Need Help?)

**What to Build:**
- Light gray background
- Centered heading and button
- Link to documentation

**Steps:**

1. **Add Container Section:**
   - Below tiles section, click (+) → Add "Container"
   - Set Content Width: Full Width
   - Set Min Height: 200px
   - Align Items: Center
   - Justify Content: Center

2. **Configure Background:**
   - **Style → Background:**
     - Color: Light gray (#f9f9f9)
   - **Advanced → Padding:**
     - Top/Bottom: 50px

3. **Add Heading:**
   - Inside container, add "Heading" widget
   - **Content:**
     - Title: "Need Help?"
     - HTML Tag: H2
   - **Style:**
     - Text Color: Dark (#333)
     - Font Size: 32px
     - Alignment: Center

4. **Add Description Text:**
   - Add "Text Editor" below heading
   - **Content:**
     - Text: "Check the internal documentation for guidance on admin operations."
   - **Style:**
     - Text Color: Gray (#666)
     - Font Size: 16px
     - Alignment: Center
     - Margin Top: 10px

5. **Add Button:**
   - Add "Button" widget
   - **Content:**
     - Text: "View Documentation"
     - Link: #help (or actual URL)
   - **Style:**
     - Alignment: Center
     - Background: Theme primary color
     - Text Color: White
     - Padding: 15px 40px
     - Border Radius: 4px
     - Margin Top: 20px

---

### Step 6: Add Footer Section (Compliance Badges)

**What to Build:**
- Dark background matching hero
- Row of compliance badges with icons
- Icons: GDPR, Security, Equal Opportunity, EU Markets

**Steps:**

1. **Copy from Managers Dashboard (Recommended):**
   - Open Managers page (ID 333) in Elementor
   - Find the footer section with compliance badges
   - Right-click section → Copy
   - Return to Manager Admin page
   - Right-click at bottom → Paste
   - Done! Footer copied with all badges

2. **OR Build from Scratch:**
   - Add Container with dark background (#0a2540 or #1a1a1a)
   - Add 4 Icon List widgets in a row
   - Icons: Shield (GDPR), Lock (Security), Balance Scale (Equal Opportunity), Flag (EU)
   - Style with white icons and text
   - Center align

---

### Step 7: Configure Responsive Settings

**Mobile Optimization:**

1. **Switch to Mobile View:**
   - Click device icon (bottom left) → Mobile view

2. **Adjust Hero Section:**
   - Click hero container → Style
   - Mobile Padding: Reduce to 40px top/bottom
   - Heading Font Size: 28px
   - Text Font Size: 14px

3. **Adjust Tiles Section:**
   - Click tiles container → Layout
   - Mobile: Width 100% (full width, stacked)
   - Ensure vertical spacing looks good

4. **Adjust CTA Section:**
   - Mobile Padding: 30px top/bottom
   - Heading: 24px
   - Button: Full width or centered

**Tablet View:**
- Tiles: 45% width (2 per row)
- Font sizes: Between desktop and mobile

---

### Step 8: Final Settings & Publish

1. **Page Settings:**
   - Click hamburger menu (☰) → Settings (gear icon)
   - **Page Layout:**
     - Hide Title: No (we want "Manager Admin" to show)
     - OR if using Elementor Canvas, title won't show anyway
   
2. **SEO Settings (Optional):**
   - Scroll down to SEO section
   - Meta Description: "Manager Admin operations hub - user requests, system settings, and administrative tasks"

3. **Save as Draft:**
   - Click "Update" button (bottom left)
   - Status: Keep as Draft for now
   - Once ready, change to "Publish"

4. **Exit Elementor:**
   - Click hamburger menu → Exit to Dashboard
   - You'll return to WordPress page editor

5. **Set Blocksy Page Layout:**
   - In WordPress page editor (classic editor)
   - Right sidebar → **Blocksy** section
   - **Page Layout:** Ensure set to "Default"
     - This shows the header/menu (learned from v3.2.0 issue)
   - Click "Update"

6. **Preview Page:**
   - Click "Preview" button
   - Opens in new tab: http://localhost:8080/manager-admin/
   - Verify all sections look correct
   - Test on mobile (browser dev tools)

---

### Step 9: Test Access Control

**Important:** This page should only be accessible to Managers and Administrators.

1. **Check Plugin Code:**
   - Verify `talendelight-roles` plugin has access control for `/manager-admin/`
   - Similar logic to `/managers/` page

2. **Test Access:**
   - **As Admin:** Page should load normally
   - **As Manager:** Login as `manager_test` → Page should load
   - **As Operator:** Should see 403 Forbidden page
   - **As Other Roles:** Should see 403 Forbidden
   - **Logged Out:** Should redirect to login or 403

3. **If Access Control Missing:**
   - Edit `wp-content/plugins/talendelight-roles/talendelight-roles.php`
   - Add condition for `manager-admin` slug
   - Similar to existing `managers` and `operators` checks

---

### Step 10: Export for Deployment

Once page is complete and tested:

```powershell
# From project root
cd c:\data\lochness\talendelight\code\wordpress

# Export Elementor pages
pwsh infra/shared/scripts/export-elementor-pages.ps1

# This will create:
# - tmp/elementor-exports/managers.json (original)
# - tmp/elementor-exports/manager-admin.json (new page)
```

**Verify Export:**
```powershell
# Check file exists
Test-Path tmp/elementor-exports/manager-admin.json
# Should return: True

# Check file size (should be > 1KB)
(Get-Item tmp/elementor-exports/manager-admin.json).Length
```

**Files Ready for Deployment:**
- `tmp/elementor-exports/managers.json` (Manager Dashboard - missing from production)
- `tmp/elementor-exports/manager-admin.json` (Manager Admin - new page)

---

## Quick Reference

**Page URLs:**
- **Local:** http://localhost:8080/manager-admin/
- **Production:** https://talendelight.com/manager-admin/

**Elementor Editor:**
- **Direct Link:** http://localhost:8080/wp-admin/post.php?post=386&action=elementor

**Color Palette:**
- **Hero Background:** #0a2540 (dark navy)
- **Tile Background:** #ffffff (white) or #f5f5f5 (light gray)
- **CTA Background:** #f9f9f9 (light gray)
- **Footer Background:** #0a2540 or #1a1a1a (dark)
- **Text:** #333333 (dark), #666666 (medium gray), #ffffff (white)

**Font Sizes:**
- **Hero H1:** 48px (desktop), 32px (tablet), 28px (mobile)
- **Hero Subtitle:** 18px (desktop), 16px (mobile)
- **Tile Heading (H3):** 20px
- **Tile Description:** 14px
- **CTA Heading (H2):** 32px
- **CTA Text:** 16px

**Spacing:**
- **Section Padding:** 60px (desktop), 40px (mobile)
- **Tile Padding:** 30px
- **Tile Margin Bottom:** 30px
- **Element Spacing:** 10-20px between widgets

---

## Troubleshooting

**Issue: Elementor not loading**
- Solution: Clear browser cache, try incognito mode
- Check if Elementor plugin is active

**Issue: Tiles not responsive**
- Solution: Check container width settings in mobile view
- Ensure "Wrap" is enabled on main tiles container

**Issue: Icons not showing**
- Solution: Verify Font Awesome library loaded
- Try different icon set (Elementor Icons instead of Font Awesome)

**Issue: Page layout missing header/menu**
- Solution: Set Blocksy Page Layout to "Default" (not "No Sidebar")
- This was a known issue from v3.2.0 Operators page

**Issue: Access control not working**
- Solution: Check `talendelight-roles` plugin code
- Add `manager-admin` slug to allowed pages array
- Test with different user roles

---

## Next Steps After Building

1. **Add Interactivity (Future):**
   - User Registration Request Approvals section: Add actual table with data
   - Connect tiles to real admin sub-pages
   - Implement API calls for summary metrics

2. **Deploy to Production:**
   - Follow [RELEASE-NOTES-NEXT.md](RELEASE-NOTES-NEXT.md) deployment steps
   - Export → Upload → Import → Test

3. **Documentation:**
   - Update feature spec with actual implementation details
   - Take screenshots for documentation
   - Create user guide for managers

---

**Estimated Time:** 1-2 hours (including styling and testing)

**Difficulty:** Medium (Copying from Managers page makes it easier)

**Prerequisites:**
- Familiarity with Elementor editor
- Basic understanding of responsive design
- Access to local WordPress admin

---

**Ready to start?** Open the Elementor editor and begin with Step 1! 🚀
