# Homepage Creation Workflow - Learning Documentation

**Date:** December 31, 2025  
**Purpose:** Document the complete workflow for creating a marketing homepage with Elementor  
**Feature Reference:** [WP-01.1-home-page.md](../features/WP-01.1-home-page.md)  
**Learning Goal:** Enable future autonomous page creation and deployment

---

## Overview

This document captures the hands-on process of creating the TalenDelight homepage from scratch, including:
- WordPress page creation and configuration
- Elementor visual builder usage patterns
- Section structure and widget selection
- Content population and styling
- Responsive design considerations
- Publishing and homepage assignment

**Context:**
- Starting with fresh WordPress 6.9.0 + Elementor installation
- Existing pages: "About us" (ID 15), "Sample Page" (ID 2)
- Goal: Create homepage with Hero, Specialties, How It Works, and CTA sections
- Content and requirements approved in feature documentation

---

## Pre-Creation State

### Current Environment
```bash
# WordPress pages before creation
podman exec wp wp post list --post_type=page --format=table --allow-root
# Output: 2 pages (About us, Sample Page)
```

### Content Ready
✅ Hero headline: "Talent for today. Growth for tomorrow."  
✅ Specialties: 4 defined (Java Backend, Fullstack, DevOps, Cloud)  
✅ Process steps: 3-step workflow for Employers and Candidates  
✅ Color scheme: Navy (#063970), Grey (#898989), White  
❌ Images/icons: TBD (placeholders acceptable for wireframe)

---

## Phase 1: Page Creation

### Step 1.1: Create New Page in WordPress

**Action:** ✅ Completed Dec 31, 2025

**Actual Process:**
1. Navigate to WordPress Admin → Pages → Add New
2. Enter page title: "Home"
3. Click "Edit with Elementor" button (before adding any content)
4. Elementor full-screen editor loads

**Database Impact:**
- New post entry in `wp_posts` table (ID: 20)
- Post status: draft
- Postmeta entries for Elementor created automatically
- Baseline: 12 posts, 33 postmeta before creation

**Key Learnings:**
- No need to configure template manually - Elementor handles it
- Click "Edit with Elementor" immediately, don't use block editor
- Page auto-saves as draft when Elementor opens
- WP-CLI option available: `wp post create --post_type=page --post_title="Home" --allow-root`

**Observations:**
```
Page creation is straightforward via WP Admin UI.
For automation: WP-CLI can create page structure, but Elementor visual design requires UI.
```

---

### Step 1.2: Open Elementor Editor

**Action:** ✅ Completed

**Actual Process:**
- "Edit with Elementor" button appears in WordPress page editor
- Click button → Elementor loads in full-screen mode
- Empty canvas appears, ready for content

**Interface Elements:**
- **Left panel:** Widget library, settings for selected element
- **Center canvas:** Live WYSIWYG preview of page
- **Bottom bar:** Update/Save Draft button, responsive preview toggles, Navigator panel
- **Top bar:** Elementor menu (hamburger icon), page settings, history/undo

**Key Learnings:**
- Elementor is 100% visual - no code editing
- All changes appear in real-time on canvas
- Navigator panel (bottom left) shows page structure hierarchy
- Can select elements by clicking canvas OR using Navigator

**Observations:**
```
Elementor interface is intuitive for visual design.
Cannot be automated via CLI - requires human design decisions.
Could potentially import/export templates via WP-CLI for reuse.
```

---

## Phase 2: Building Sections

### Section 2.1: Hero Section

**Content Requirements:** ✅ Implemented

**Elementor Widgets Used:**
- ✅ Container widget (main hero section container)
- ✅ Heading widget (H1): "Talent for today. Growth for tomorrow."
- ✅ Text Editor widget: Subheading text
- ✅ Button widgets (2): "For Employers" and "For Candidates"

**Styling Applied:**
- **Background color:** Navy #063970
- **Text color:** White #FFFFFF (heading + subheading)
- **Padding:** 80px top/bottom (Advanced → Padding settings)
- **Alignment:** All elements centered
- **Button style:** Type 1 (Colored Background CTA)
  - Border radius: 50px (pill shape)
  - Box shadow: #3498DB (blue glow)
  - Background: Navy #063970
  - Text: White #FFFFFF

**Step-by-Step Process:**
```
1. Add Container widget to canvas
2. Add Heading widget inside container
   - Change text to hero headline
   - Set HTML tag to H1
   - Center alignment
3. Add Text Editor widget below heading
   - Add subheading text
   - Center alignment
4. Add Button widget
   - Change text to "For Employers"
   - Set link to "#" (placeholder)
   - Apply button styling (border-radius, shadow)
5. Add second Button widget
   - Change text to "For Candidates"
   - Set link to "#" (placeholder)
   - Copy styling from first button
6. Select container, go t ✅ Implemented (with revisions)

**Final Specialties (Updated Dec 31, 2025):**
1. Cloud Backend (Java, Node, Go, Python priority)
2. Fullstack (Cloud Backend + Frontend/Data)
3. DevOps & Infra (CI/CD, Kubernetes, Terraform)
4. Something else in mind? (Friendly catch-all CTA)

**Elementor Widgets Used:**
- ✅ Container widget (main section wrapper - white background)
- ✅ Heading widget (H2): "Our Specialties"
- ✅ Container widget (for first 3 icon boxes in a row)
- ✅ Icon Box widgets (3 in row: Cloud Backend, Fullstack, DevOps & Infra)
- ✅ Container widget (for 4th icon box, centered below)
- ✅ Icon Box widget (1 centered: "Something else in mind?")

**Layout Decision: 3 + 1 (Not 2x2 Grid)**
- **Top row:** 3 icon boxes side-by-side
- **Bottom row:** 1 icon box centered
- **Reasoning:** "Something else in mind?" is semantically different (helper CTA vs technical specialty), so giving it visual distinction makes sense

**Styling Applied:**
- **Main container:** White background (default), 80px padding top/bottom
- **Heading:** H2, centered, navy color #063970
- **Icon boxes:** Default Elementor styling with custom icons
- **4th box container:** 20px padding for breathing room

**Step-by-Step Process:**
```
1. Add Container widget below hero section (new white section)
2. Set padding 80px top/bottom in Advanced tab
3. Add Heading widget inside container
   - Text: "Our Specialties"
   - HTML tag: H2
   - Center alignment
   - Color: #063970 (navy)
4. Add Container widget for icon box row
   - Layout Direction: Row (horizontal)
   - Gap: 20-30px between boxes
5. Add Icon Box widget inside row container
   - Configure for Cloud Backend (icon, title, description)
6. Right-click Icon Box → Duplicate (creates 2nd box)
   - Modify for Fullstack specialty
7. Right-click Icon Box → Duplicate again (creates 3rd box)
   - Modify for DevOps & Infra specialty
8. Add Container widget below the row (for 4th box)
   - Center alignment
   - Padding: 20px
9. Add Icon Box widget in this container
   - Title: "Something else in mind?"
   - Description: "That's fine. Share your goal, and we'll match you with the right specialist."
   - Center alignment
```

**Observations & Tips:**
```
- Icon Box widget is perfect for features/services sections
- Duplicate widget function (right-click) saves time - faster than recreating
- Nested containers allow complex layouts (row inside section, then single box below)
- Layout Direction: Row makes boxes horizontal, Column makes them vertical
- 3+1 layout provides visual hierarchy: core specialties + friendly escape hatch
- User refined content multiple times during build (Cloud Backend vs Java Backend, etc.)
- Open action created for mobile responsive testing (4 boxes may need adjustment)
  1. Java Backend (Spring) - with description and skill tags
  2. Fullstack (Node/React) - with description and skill tags
  3. DevOps (Kubernetes/Terraform) - with description and skill tags
  4. Cloud Engineering - with description and skill tags

**Elementor Widgets Used:**
- [ ] Container/Section widget
- [ ] Heading widget (H2)
- [ ] Icon Box widgets (4)

**Layout:**
- Desktop: 2x2 grid or 4 columns
- Mobile: Single column stack

**Step-by-Step Process:**
```
[To be documented during creation]
```

**Observations & Tips:**
```
[To be filled during demonstration]
```

---

### Section 2.3: How It Works Section

**Content Requirements:**
- H2 Heading: "How It Works"
- Two tracks: Employers and Candidates
- 3 steps each with approved copy

**Elementor Widgets Used:**
- [ ] Container/Section widget
- [ ] Heading widget (H2)
- [ ] Tabs widget OR Column layout
- [ ] Icon List OR custom icons with text

**Layout Decision:**
- Option A: Tabbed interface (Employers tab / Candidates tab)
- Option B: Side-by-side columns
- Decision: TBD

**Step-by-Step Process:**
```
[To be documented during creation]
```

**Observations & Tips:**
```
[To be filled during demonstration]
```

---

### Section 2.4: Secondary CTAs

**Content Requirements:**
- Repeat primary CTAs at bottom of page
- Alternative: Link to Contact page

**Elementor Widgets Used:**
- [ ] Container/Section widget
- [ ] Button widgets

**Step-by-Step Process:**
```
[To be documented during creation]
```

---

## Phase 3: Styling & Responsive Design

### Global Styling

**Colors Applied:**
- Navy: #063970
- Grey: #898989
- White: #FFFFFF
- Blue (Accent): #3498DB

**Typography:**
- Font family: TBD
- Heading sizes: H1 (TBD), H2 (TBD)
- Body text: 16px, line-height 1.6

**Button Style Standards:**

**Button Type 1: Colored Background CTA (Hero/Dark Sections)**
- **Use case:** CTAs on dark/colored backgrounds (hero sections)
- **Border radius:** 50px (pill shape)
- **Box shadow:** #3498DB (blue glow effect)
- **Background:** Navy #063970 or theme default
- **Text color:** White #FFFFFF
- **Example location:** Home page hero section
- **When to use:** Primary CTAs on navy, grey, or image backgrounds

**Button Type 2: Light Background CTA (Content Sections)**
- **Use case:** CTAs on white/light backgrounds
- **Background color:** #3498DB (bright blue)
- **Text color:** #FFFFFF (white)
- **Border radius:** 5px (subtle rounded corners)
- **Box shadow:** None
- **Example location:** About us page
- **When to use:** Secondary CTAs, content sections, light backgrounds

**Process:**
```
Documented Dec 31, 2025 during homepage creation
```

---

### Responsive Preview & Adjustments

**Breakpoints to Test:**
- Mobile: 375px (iPhone standard)
- Tablet: 768px
- Desktop: 1440px

**Common Adjustments:**
- [ ] Stack elements vertically on mobile
- [ ] Adjust padding/margins for smaller screens
- [ ] Ensure CTAs visible without scrolling (mobile hero)
- [ ] Font size reductions if needed

**Process:**
```
[To be documented during testing]
```

---

## Phase 4: Publishing & Configuration

### Step 4.1: Save and Publish Page

**Action:** [User will demonstrate]

**Expected Process:**
- Click "Publish" button in Elementor
- OR "Update" if already published
- Elementor saves design data to postmeta
- Page status changes to "publish"

**Database Impact:**
- `wp_posts.post_status` → "publish"
- Elementor JSON data saved to `_elementor_data` postmeta
- Revision created

**Observations:**
```
[To be filled during demonstration]
```

---

### Step 4.2: Set as Homepage

**Action:** [User will demonstrate]

**Expected Process:**
- Navigate to Settings → Reading
- Set "Your homepage displays" → "A static page"
- Select "Home" page from dropdown
- Save changes

**WordPress Configuration:**
- Option `show_on_front` → "page"
- Option `page_on_front` → [page ID]

**Verification:**
- Visit http://localhost:8080/
- Homepage should display (not blog listing)

**Observations:**
```
[To be filled during demonstration]
```

---

## Phase 5: Testing & Verification

### Functional Testing

**Tests to Perform:**
- [ ] Homepage loads at root URL (/)
- [ ] All sections display correctly
- [ ] CTAs are clickable (even if links are placeholders)
- [ ] Text is readable (contrast check)
- [ ] No layout breaking issues

**Observations:**
```
[To be filled during testing]
```

---

### Responsive Testing

**Tests to Perform:**
- [ ] Mobile view: Elements stack properly
- [ ] Tablet view: Layout adapts
- [ ] Desktop view: Content centered, proper spacing

**Elementor Preview Tools:**
- Responsive preview toggle in editor
- Device-specific styling controls

**Observations:**
```
[To be filled during testing]
```

---

## Key Learnings

### What Can Be Automated (WP-CLI)
✅ **Page creation:** `wp post create --post_type=page --post_title="Title" --allow-root`  
✅ **Homepage setting:** `wp option update show_on_front page` + `wp option update page_on_front [ID]`  
✅ **Post/page listing:** `wp post list --post_type=page --format=table --allow-root`  
✅ **Database queries:** Direct MariaDB access via `podman exec wp-db mariadb`  
✅ **Elementor template import/export:** Possible via WP-CLI with template files  
✅ **Plugin activation:** `wp plugin activate elementor --allow-root`

### What Requires Manual UI Work
❌ **Visual layout design:** Elementor is WYSIWYG - requires human design decisions  
❌ **Widget configuration:** Drag-and-drop, styling, content editing must be done in UI  
❌ **Styling decisions:** Colors, spacing, typography require visual judgment  
❌ **Responsive adjustments:** Previewing and tweaking for mobile/tablet  
❌ **Icon selection:** Choosing appropriate icons from library  
❌ **Content refinement:** Real-time editing and approval during build

### Elementor Data Storage
✅ **Storage location:** `wp_postmeta` table, meta_key `_elementor_data`  
✅ **Format:** JSON structure containing all widgets, settings, and layout  
✅ **Accessibility:** Can be extracted via SQL query for analysis  
✅ **Template system:** Elementor supports saving sections/pages as reusable templates  
✅ **Version control:** Challenging - JSON is minified, changes hard to track in git  

**Example extraction:**
```bash
podman exec wp-db mariadb -u root -ppassword -D wordpress \
  -e "SELECT meta_value FROM wp_postmeta WHERE post_id = 20 AND meta_key = '_elementor_data';"
```

### Button Style Standards Documented

**Type 1: Colored Background CTA (Hero/Dark Sections)**
- Border radius: 50px (pill shape)
- Box shadow: #3498DB (blue glow effect)
- Background: Navy #063970
- Text: White #FFFFFF
- Use case: Primary CTAs on dark/colored backgrounds

**Type 2: Light Background CTA (Content Sections)**
- Border radius: 5px (subtle rounded)
- Background: #3498DB (bright blue)
- Text: White #FFFFFF
- No box shadow
- Use case: Secondary CTAs on white/light backgrounds

**Data source:** Type 2 extracted from About us page (ID 15) via Elementor JSON analysis

### Design Decisions Documented
✅ Specialties changed from 4 equal boxes to 3+1 layout (visual hierarchy)  
✅ "How It Works" removed from homepage - will be on dedicated Employer/Candidate pages  
✅ Content refined multiple times during build (naming, descriptions)  
✅ Responsive optimization deferred to dedicated task (open action created)

---

## Troubleshooting Notes

### Common Issues Encountered
```
[To be filled during work]
```

### Solutions Applied
```
[To be filled during work]
```

---

## Future Automation Opportunities

### Potential WP-CLI Scripts
```
[To be determined after learning workflow]
- Create page structure
- Import Elementor template
- Set as homepage
- Configure basic settings
```

### Template Reuse Strategy
```
[To be determined]
- Can sections be saved as Elementor templates?
- Can templates be exported/imported via CLI?
- Version control for Elementor designs?
```

---

## Related Resources

- [elementor-page-building.md](elementor-page-building.md) - Previous Elementor observations
- [wp-cli-database-access.md](wp-cli-database-access.md) - WP-CLI capabilities
- [WP-01.1-home-page.md](../features/WP-01.1-home-page.md) - Feature requirements
- [WORDPRESS-PAGE-SYNC-MANIFEST.md](../../../Documents/WORDPRESS-PAGE-SYNC-MANIFEST.md) - Sync strategy

---

## Workflow Summary

**Completed Steps (Dec 31, 2025):**

1. ✅ Created "Home" page via WordPress Admin (ID: 20)
2. ✅ Opened Elementor editor (full-screen visual builder)
3. ✅ Built Hero Section:
   - Navy background (#063970)
   - H1 heading, subheading text, 2 CTA buttons
   - Button Type 1 styling documented
4. ✅ Built Specialties Section:
   - White background container with H2 heading
   - 3 icon boxes in row (Cloud Backend, Fullstack, DevOps & Infra)
   - 1 centered icon box below ("Something else in mind?")
   - 3+1 layout for visual hierarchy
5. ✅ Extracted button styling from About us page for reuse
6. ✅ Documented design decisions and content refinements
7. ✅ Created open action for responsive layout testing

**Completed Tasks:**
- [x] Add final CTA section with navy background, H2 heading, subheading, 2 buttons
- [x] Publish page (Dec 31, 2025)
- [x] Set as homepage in WordPress Settings → Reading
- [x] Verified at http://localhost:8080/ ✅

**Remaining Tasks:**
- [ ] Test responsive design (mobile/tablet breakpoints) - Open action created
- [ ] Export Elementor template for production deployment
- [ ] Update feature documentation status

**Total Time Estimate:** ~60-90 minutes (with content refinement discussions)  
**Complexity Level:** Moderate (multiple sections, design decisions, content iterations)  
**Repeatability:** Partially scriptable (page creation), but design requires UI work

---

## Post-Creation Checklist

- [ ] Page created and published
- [ ] Set as homepage in WordPress settings
- [ ] Sections built according to requirements
- [ ] Content populated from feature doc
- [ ] Responsive design verified
- [ ] Links configured (even if placeholder pages)
- [ ] Feature documentation updated (WP-01.1-home-page.md status)
- [ ] Learning documentation completed (this file)
- [ ] Screenshot captured for reference

---

## Notes & Observations

```
[Free-form notes during the creation process]
```
