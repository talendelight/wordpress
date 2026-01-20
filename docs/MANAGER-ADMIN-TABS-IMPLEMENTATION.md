# Manager Admin Page - Tabbed Interface Implementation Guide

**Feature:** User Request Approvals Tabbed Interface  
**Page:** Manager Admin (/manager-admin/)  
**Updated:** January 19, 2026

---

## Overview

This guide walks through implementing the tabbed interface for User Request Approvals section on the Manager Admin page using Elementor.

### Tab Structure
- **Pending (Default)** - Active requests awaiting review
- **Approved** - Approved requests (last 30 days)
- **Rejected** - Rejected requests (last 30 days)
- **All** - All requests (last 30 days)

---

## Step-by-Step Implementation

### Step 1: Create Main Content Container

**Location:** After tiles section, before "Need Help?" CTA

1. Add new **Container** widget
2. **Layout Settings:**
   - Width: Full Width (100%)
   - Content Width: Boxed
   - Max Width: 1200px
   - Flex Direction: Column
   - Gap: 60px

3. **Style:**
   - Background Color: #F8F9FA
   - Padding: 80px top, 80px bottom, 20px left/right

4. **Advanced:**
   - CSS ID: `admin-content-area`

---

### Step 2: Add User Request Approvals Section Container

**Inside the main content container:**

1. Add nested **Container**
2. **Layout:**
   - Flex Direction: Column
   - Gap: 30px

3. **Style:**
   - Background: White (#FFFFFF)
   - Padding: 40px all sides
   - Border Radius: 8px
   - Box Shadow: 0 2px 10px rgba(0,0,0,0.08)

4. **Advanced:**
   - CSS ID: `user-requests`
   - HTML Tag: section

---

### Step 3: Add Section Heading

1. Add **Heading** widget (H2)
2. **Content:**
   - Text: "User Request Approvals"
   - Size: H2
   - Color: #063970 (navy)
   - Alignment: Left
   
3. **Style:**
   - Font Size: 32px
   - Font Weight: 700
   - Margin Bottom: 30px

---

### Step 4: Create Tab Navigation

1. Add **Container** for tabs (horizontal)
2. **Layout:**
   - Flex Direction: Row
   - Justify Content: Flex Start
   - Gap: 0px
   - Border Bottom: 2px solid #E0E0E0

3. **Add 4 Button Widgets** (one for each tab):

#### Tab 1: Pending
- **Text:** "Pending (12)"
- **Link:** `#tab-pending`
- **Style:**
  - Text Color: #063970
  - Background: Transparent
  - Padding: 15px 30px
  - Border: None
  - Border Bottom: 3px solid transparent
  - Typography: 16px, weight 600
  
- **Hover:**
  - Border Bottom Color: #3498DB
  
- **CSS Classes:** `tab-button active` (add "active" for default)

#### Tab 2: Approved
- Same as Pending but:
  - Text: "Approved (45)"
  - Link: `#tab-approved`
  - CSS Classes: `tab-button` (no "active")

#### Tab 3: Rejected
- Same as Pending but:
  - Text: "Rejected (8)"
  - Link: `#tab-rejected`
  - CSS Classes: `tab-button`

#### Tab 4: All
- Same as Pending but:
  - Text: "All (65)"
  - Link: `#tab-all`
  - CSS Classes: `tab-button`

---

### Step 5: Create Tab Content Areas

Add 4 **Container** widgets (one for each tab content):

#### Container 1: Pending Content (Default Visible)
1. **Advanced:**
   - CSS Classes: `tab-content active`
   - Data Attribute: `data-tab="pending"`

2. **Style:**
   - Padding: 30px 0
   - Display: Block (default)

3. **Content Structure:**
   ```
   → Summary Metrics Row (3 icon boxes)
   → Coming Soon Notice
   ```

#### Containers 2-4: Approved, Rejected, All
- Same structure as Pending
- CSS Classes: `tab-content hidden` (add "hidden")
- Data Attributes: `data-tab="approved"`, `data-tab="rejected"`, `data-tab="all"`

---

### Step 6: Add Summary Metrics (Inside Pending Tab Content)

1. Add **Container** (row layout)
2. **Layout:**
   - Flex Direction: Row
   - Flex Wrap: Wrap
   - Gap: 20px
   - Justify Content: Space Between

3. **Add 3 Icon Box Widgets:**

#### Metric 1: Total Items
- **Icon:** fas fa-list-ul (blue #3498DB)
- **Title:** "12"
- **Description:** "Total Items"
- **Style:**
  - Background: #F5F9FC
  - Padding: 20px
  - Border Radius: 8px
  - Text Align: Center
  - Title Size: 36px, Weight: 700, Color: #063970
  - Description Size: 14px, Color: #898989

#### Metric 2: Priority Breakdown
- **Icon:** fas fa-exclamation-triangle (orange #FF9800)
- **Title:** "Critical: 1 | High: 3 | Normal: 8"
- **Description:** "Priority Distribution"
- (Same styling as Metric 1)

#### Metric 3: Reviewed Today
- **Icon:** fas fa-calendar-check (green #4CAF50)
- **Title:** "5"
- **Description:** "Reviewed Today"
- (Same styling as Metric 1)

---

### Step 7: Add Coming Soon Notice

1. Add **Text Editor** widget
2. **Content:**
```html
<div style="padding: 40px; text-align: center; background: #fff; border: 2px dashed #ddd; border-radius: 8px; margin-top: 30px;">
  <h3 style="color: #063970; margin-bottom: 15px; font-size: 24px;">🚧 Under Development</h3>
  <p style="color: #666; margin-bottom: 15px; font-size: 16px;">
    The User Request Approvals interface is currently being developed.
  </p>
  <p style="color: #898989; font-size: 14px; line-height: 1.6;">
    <strong>Planned Features:</strong><br>
    • Request filtering by type, priority, and user role<br>
    • Bulk approve/reject actions<br>
    • Detailed review interface with validation checks<br>
    • Automated email notifications<br>
    • Audit trail for compliance tracking
  </p>
</div>
```

---

### Step 8: Add Content for Other Tabs

**For Approved/Rejected/All tabs**, add similar structure but simpler:

1. **Text Editor Widget:**
```html
<div style="padding: 40px; text-align: center;">
  <h4 style="color: #063970; margin-bottom: 15px;">🚧 Under Development</h4>
  <p style="color: #666;">
    This tab will display [Approved/Rejected/All] requests.
  </p>
</div>
```

---

### Step 9: Add Tab Switching JavaScript

At the bottom of the page (before footer), add **HTML** widget:

```html
<style>
/* Tab Navigation Styles */
.tab-button {
  transition: all 0.3s ease !important;
  border-bottom: 3px solid transparent !important;
}

.tab-button.active {
  border-bottom-color: #3498DB !important;
  color: #063970 !important;
  font-weight: 700 !important;
}

.tab-button:hover {
  background-color: #F5F9FC !important;
}

/* Tab Content Styles */
.tab-content {
  display: block;
  animation: fadeIn 0.3s ease-in;
}

.tab-content.hidden {
  display: none !important;
}

@keyframes fadeIn {
  from { 
    opacity: 0; 
    transform: translateY(10px); 
  }
  to { 
    opacity: 1; 
    transform: translateY(0); 
  }
}
</style>

<script>
jQuery(document).ready(function($) {
  // Tab switching functionality
  $('.tab-button a').on('click', function(e) {
    e.preventDefault();
    
    var targetTab = $(this).attr('href').replace('#tab-', '');
    
    // Update active tab button
    $('.tab-button').removeClass('active');
    $(this).closest('.tab-button').addClass('active');
    
    // Show corresponding tab content
    $('.tab-content').addClass('hidden');
    $('.tab-content[data-tab="' + targetTab + '"]').removeClass('hidden');
    
    // Smooth scroll to content
    $('html, body').animate({
      scrollTop: $('.tab-content[data-tab="' + targetTab + '"]').offset().top - 150
    }, 300);
  });
  
  // Initialize: Show Pending tab by default
  $('.tab-content[data-tab="pending"]').removeClass('hidden');
  $('.tab-button:first-child').addClass('active');
});
</script>
```

---

### Step 10: Add Other Admin Sections (Placeholders)

After the User Request Approvals section, add 5 more section containers for:

1. **User Management** (ID: `user-management`)
2. **System Settings** (ID: `system-settings`)
3. **Audit Logs** (ID: `audit-logs`)
4. **Role Management** (ID: `role-management`)
5. **Platform Monitoring** (ID: `platform-monitoring`)

**Each section:**
- White background, 40px padding, 8px border radius, shadow
- Heading (H3) with section name
- Simple "Under Development" notice

---

## Testing Checklist

After implementation, verify:

- [ ] Tabs switch content correctly
- [ ] Pending tab shows by default
- [ ] Active tab is visually highlighted
- [ ] Tab counts are visible (even if placeholder)
- [ ] Summary metrics display properly
- [ ] Coming soon message is clear
- [ ] Smooth scrolling works
- [ ] All 6 admin sections are visible
- [ ] Responsive on mobile/tablet
- [ ] No console errors

---

## Next Development Steps

1. **Phase 1 (v3.4.0):** Static tabbed interface ✅ (Current)
2. **Phase 2 (v3.5.0):** Backend PHP integration
   - Fetch real data from `wp_td_user_data_change_requests` table
   - AJAX tab content loading
   - Update tab counts dynamically
   
3. **Phase 3 (v3.6.0):** Full functionality
   - Request table with sorting/filtering
   - Approve/reject actions
   - Detail modal view
   - Email notifications

---

## Related Documentation

- [WP-01.6 Feature Spec](features/WP-01.6-user-request-approvals.md) - Complete functional requirements
- [VERSION-HISTORY.md](VERSION-HISTORY.md) - Release planning and versioning
- [MANAGER-ADMIN-PAGE-SETUP.md](MANAGER-ADMIN-PAGE-SETUP.md) - Initial page setup guide

---

## Notes

- Tab counts (12, 45, 8, 65) are placeholders
- Real counts will be populated via PHP/AJAX in v3.5.0
- Use CSS classes for styling, not inline styles (except for HTML widget content)
- Keep IDs unique and semantic for JavaScript targeting
