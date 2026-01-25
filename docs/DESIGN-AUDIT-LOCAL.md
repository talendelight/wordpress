# Design System Audit - Local Environment

**Date:** January 22, 2026  
**Purpose:** Comprehensive UI consistency audit across all published pages in local WordPress environment  
**Environment:** http://wp.local (Podman/Docker development)

---

## Pages to Audit

### Public Pages (No Login Required)
1. **Homepage** (`/`)
   - Status: Published
   - URL: http://wp.local/

2. **Employers Landing Page** (`/employers/`)
   - Status: Published
   - URL: http://wp.local/employers/

3. **Candidates Landing Page** (`/candidates/`)
   - Status: Published
   - URL: http://wp.local/candidates/

4. **Scouts Landing Page** (`/scouts/`)
   - Status: Published
   - URL: http://wp.local/scouts/

5. **403 Access Restricted** (`/access-restricted/`)
   - Status: Published
   - URL: http://wp.local/access-restricted/

6. **Help Page** (`/help/`)
   - Status: Published
   - URL: http://wp.local/help/

### Authentication Pages
7. **Login Page** (`/log-in/`)
   - Status: Published
   - URL: http://wp.local/log-in/
   - Custom CSS: config/custom-css/login.css

8. **Password Reset** (`/password-reset/`)
   - Status: Published
   - URL: http://wp.local/password-reset/

9. **Select Role Page** (`/select-role/`)
   - Status: Published (custom template)
   - URL: http://wp.local/select-role/
   - Template: page-role-selection.php

10. **Register Profile** (`/register-profile/`)
    - Status: Published
    - URL: http://wp.local/register-profile/
    - Form: Forminator Person Registration Form

### Role-Specific Pages (Login Required)
11. **Operators Dashboard** (`/operators/`)
    - Status: Published
    - URL: http://wp.local/operators/
    - Access: Operators, Managers, Administrators

12. **Managers Dashboard** (`/managers/`)
    - Status: Published
    - URL: http://wp.local/managers/
    - Access: Managers, Administrators

13. **Manager Admin Operations** (`/manager-admin/`)
    - Status: Published
    - URL: http://wp.local/manager-admin/
    - Access: Managers, Administrators
    - Features: Tabbed interface, user registration request approvals

---

## Automated Analysis Results (WP-CLI)

### Page Inventory

**Total Published Pages:** 16 pages analyzed  
**Elementor Pages:** 13 pages (81%)  
**Non-Elementor Pages:** 3 pages (Login, Password Reset - WPUM managed)

| ID | Page Name | Slug | Editor | Date Published |
|----|-----------|------|--------|----------------|
| 20 | Welcome | home | Elementor | 2025-12-31 |
| 93 | Employers | employers | Elementor | 2026-01-06 |
| 229 | Candidates | candidates | Elementor | 2026-01-10 |
| 248 | Scouts | scouts | Elementor | 2026-01-10 |
| 299 | Operators | operators | Elementor | 2026-01-13 |
| 152 | Access Restricted | 403-forbidden | Elementor | 2026-01-06 |
| 365 | Register Profile | register-profile | Elementor | 2026-01-16 |
| 379 | Select Role | select-role | Elementor | 2026-01-17 |
| 386 | Manager Admin | manager-admin | Elementor | 2026-01-19 |
| 469 | Managers | managers | Elementor | 2026-01-20 |
| 75 | Log In | log-in | WPUM | 2026-01-01 |
| 76 | Password Reset | password-reset | WPUM | 2026-01-01 |
| 64 | Help | help | Elementor | 2026-01-01 |

### Design Token Analysis

**Color Palette (Extracted from all Elementor pages):**

| Color | Usage Count | Purpose (Inferred) |
|-------|-------------|-------------------|
| `#FFFFFF` | 111 uses | White - backgrounds, button text, hero text |
| `#063970` | 95 uses | **Navy (Primary)** - hero backgrounds, headings, button backgrounds |
| `#3498DB` | 78 uses | **Blue (Accent)** - icons, highlights, hover states |
| `#898989` | 65 uses | **Gray (Body Text)** - descriptions, secondary text |
| `#ECECEC` | 28 uses | Light gray - section backgrounds, borders |
| `#F8F9FA` | 2 uses | Off-white - alternate backgrounds |
| `#E8F4F8` | 1 use | Light blue tint |
| `#DC3545` | 1 use | Red - error/warning states |

**Typography Scale (Font Sizes):**

| Size | Usage Count | Purpose (Inferred) |
|------|-------------|-------------------|
| 16px | 14 uses | **Body text**, descriptions, button text |
| 18px | 4 uses | Large body text, emphasized paragraphs |
| 24px | ~15 uses | **H3 / Card Titles** (icon box titles) |
| 32px | 1 use | H2 headings |
| 48px | 7 uses | **H1 / Hero Headings** |

**Spacing System (Padding Values):**

| Value | Usage Count | Purpose (Inferred) |
|-------|-------------|-------------------|
| 80px | 17 uses | **Section padding** (top/bottom) - primary |
| 20px | 4 uses | Container padding (left/right), small spacing |
| 60px | 1 use | Alternate section padding |
| 0px | 1 use | Reset padding |

### Homepage Design Patterns (Detailed Analysis)

**Hero Section:**
- Background: Navy `#063970`
- Padding: 80px top/bottom, 20px left/right
- H1: 48px, weight 700, color `#FFFFFF`, center-aligned
- H3 Subheading: 16px, weight 400, color `#FFFFFF`, center-aligned
- CTA Button:
  - Text: "Get Started"
  - Background: White `#FFFFFF`
  - Text Color: Navy `#063970`
  - Border Radius: 50px (fully rounded pill shape)
  - Box Shadow: 0 0 10px 0 `#3498DB` (blue glow)

**Icon Box Pattern (Our Specialties section):**
- Title: 24px, weight 700, color Navy `#063970`
- Icon: 48px, color Blue `#3498DB`
- Description: 16px, weight 400, color Gray `#898989`
- Layout: 3-column grid (33.33% width each)
- Alignment: Center-aligned

**CTA Section:**
- Background: Navy `#063970`
- Padding: 80px top/bottom
- Heading: 48px, weight 700, white
- Body Text: 16px, weight 400, white
- Button: Same pattern as hero (white bg, navy text, 50px radius)

**Compliance Footer:**
- Background: Light Gray `#ECECEC`
- Icon List: 4 items
- Icon Size: 24px, color Blue `#3498DB`
- Text: 16px, color Gray `#898989`
- Layout: Inline horizontal, 30px spacing between items

---

## Audit Checklist (Per Page)

### Typography
- [ ] **Heading 1 (H1)** - Size, weight, color, line-height
- [ ] **Heading 2 (H2)** - Size, weight, color, line-height
- [ ] **Heading 3 (H3)** - Size, weight, color, line-height
- [ ] **Heading 4-6** - Consistency and usage
- [ ] **Body Text** - Size, line-height, color
- [ ] **Link Text** - Color, hover states, underline
- [ ] **Button Text** - Size, weight, letter-spacing
- [ ] **Font Families** - Consistent usage

### Colors
- [ ] **Primary Navy** (#063970) - Headers, CTAs
- [ ] **Blue** (#3498DB) - Primary buttons, links
- [ ] **Grey** (#6c757d) - Secondary elements
- [ ] **Red** (#dc3545) - Errors, required indicators
- [ ] **Green** (#28a745) - Success messages
- [ ] **Light Grey** (#ECECEC, #E0E0E0) - Backgrounds, borders
- [ ] **Text Colors** - Body (#333333), secondary (#898989)

### Spacing & Layout
- [ ] **Section Padding** - Top/bottom consistency
- [ ] **Container Padding** - Left/right consistency
- [ ] **Element Margins** - Between headings, paragraphs
- [ ] **Grid Spacing** - Column gaps
- [ ] **Button Padding** - Internal spacing
- [ ] **Max-width** - Content containers

### Buttons
- [ ] **Primary Button** - Navy/Blue, size, border-radius
- [ ] **Secondary Button** - Grey, size, border-radius
- [ ] **Button Hover** - Transition, color change
- [ ] **Button Sizes** - Small, medium, large consistency
- [ ] **Icon Buttons** - Alignment, sizing

### Forms
- [ ] **Input Fields** - Height, padding, border, font-size
- [ ] **Labels** - Font-size, weight, color, margin
- [ ] **Placeholders** - Color, font-style
- [ ] **Focus States** - Border color, box-shadow
- [ ] **Error States** - Border color, message styling
- [ ] **Checkboxes/Radios** - Size, alignment, spacing
- [ ] **Submit Buttons** - Match global button styles

### Icons
- [ ] **Icon Sizes** - 24px, 32px, 48px consistency
- [ ] **Icon Colors** - Matching section/brand colors
- [ ] **Icon Styles** - Solid, outline, filled
- [ ] **Icon Spacing** - Margin from text

### Sections
- [ ] **Hero Section** - Height, padding, text alignment
- [ ] **CTA Section** - Background, padding, centering
- [ ] **Content Sections** - Spacing between sections
- [ ] **Footer Section** - Styling, spacing

### Compliance/Trust Elements
- [ ] **Trust Badges** - Size, spacing, alignment
- [ ] **GDPR Notice** - Color, size, positioning
- [ ] **Footer Links** - Styling, hover states

### Responsive Design
- [ ] **Mobile (< 768px)** - Layout stacking, font sizes
- [ ] **Tablet (768px - 1024px)** - Responsive adjustments
- [ ] **Desktop (> 1024px)** - Full layout

---

## Design Standards Summary (Extracted from Audit)

### Established Color System ✅

**Primary Colors:**
- Navy: `#063970` - Primary brand color, hero backgrounds, headings, buttons
- Blue: `#3498DB` - Accent color, icons, hover states, focus effects
- White: `#FFFFFF` - Text on dark backgrounds, button backgrounds, section backgrounds

**Neutral Colors:**
- Dark Gray: `#333333` - Body text (needs verification - seen in Select Role form)
- Medium Gray: `#898989` - Secondary text, descriptions, disabled states
- Light Gray: `#ECECEC` - Section backgrounds, borders, footer backgrounds
- Off-White: `#F8F9FA` - Alternate backgrounds

**Semantic Colors:**
- Error/Danger: `#DC3545` - Error messages, required fields
- Success: `#28a745` - Success messages (needs verification)

**Status:** ✅ Well-defined primary and accent colors. Needs standardization for semantic colors across all pages.

### Established Typography Scale ✅

**Headings:**
- H1: 48px, weight 700, Navy `#063970` (or White `#FFFFFF` on dark backgrounds)
- H2: 32px, weight 700 (inferred, needs more data)
- H3/Card Titles: 24px, weight 700, Navy `#063970`

**Body Text:**
- Primary: 16px, weight 400, Dark Gray `#333333` (Select Role) or Medium Gray `#898989` (descriptions)
- Large: 18px, weight 400
- Small: 14px (inferred, needs verification)

**Font Weights:**
- Regular: 400
- Bold: 700

**Font Family:** Not extracted (likely Blocksy theme default - needs manual verification)

**Status:** ✅ Consistent heading scale. Body text color needs standardization (#333333 vs #898989 usage).

### Established Spacing System ✅

**Section Padding (Vertical):**
- Primary: 80px top/bottom
- Secondary: 60px top/bottom
- Minimal: 20px top/bottom

**Container Padding (Horizontal):**
- Standard: 20px left/right

**Element Spacing:**
- Between sections: ~0px (sections are self-contained)
- Between headings: 8px margin-bottom (from Forminator CSS)
- Between paragraphs: Default (needs verification)

**Grid Gap:**
- Icon boxes: 0px (full-width columns with internal padding)
- Icon list: 30px spacing between items

**Status:** ✅ Consistent 80px section padding. Needs standardization for element-level spacing.

### Established Button Patterns ✅

**Primary Button (CTA):**
- Background: White `#FFFFFF`
- Text Color: Navy `#063970`
- Border Radius: 50px (pill shape)
- Box Shadow: `0 0 10px 0 #3498DB` (blue glow)
- Hover: Not defined (needs manual testing)

**Secondary/Tertiary:** Not clearly defined (needs more examples)

**Button Sizes:** Not clearly defined (needs measurement)

**Status:** ⚠️ Primary CTA style is consistent. Secondary button styles need definition.

### Established Form Patterns ⚠️

**Forminator Forms (Custom CSS Applied):**
- Labels: 16px, weight 400, `#333333` (matches Select Role)
- Inputs: Height ~45px (inferred), border color needs verification
- Focus State: Not defined in custom CSS (needs checking)
- Error State: Not defined in custom CSS (needs checking)
- Submit Button: Centered, margin 0 auto

**Select Role Form:**
- Label: 16px, weight 400, `#333333`
- Select dropdown: Height ~45px, border needs verification

**Status:** ⚠️ Forminator labels standardized. Full form styling needs completion (focus, error states).

### Established Icon Patterns ✅

**Icon Sizes:**
- Large (Hero/Features): 48px
- Medium (Footer/UI): 24px
- Small: 16px (inferred, needs verification)

**Icon Colors:**
- Primary: Blue `#3498DB` (accent color)
- On Dark Backgrounds: White `#FFFFFF`
- In Text: Inherit from parent

**Icon Library:** Font Awesome (fas fa-* classes)

**Status:** ✅ Consistent icon sizes and colors.

### Gaps & Inconsistencies Identified

**Critical Issues:**
1. **Body Text Color Ambiguity:** Two gray values used (#333333 vs #898989) without clear guidelines on when to use each
2. **Secondary Button Styles:** No defined secondary/tertiary button patterns
3. **Form Focus/Error States:** Not defined in custom CSS
4. **Hover States:** Not extracted from static analysis (needs manual testing)
5. **Font Family:** Not confirmed (needs to extract from Blocksy theme settings)

**High Priority:**
6. **H2 Confirmation:** Only 1 use found (32px), needs verification across more pages
7. **Button Sizing System:** No small/medium/large button variants defined
8. **Link Styling:** Hover, visited, active states not defined
9. **Card/Container Shadows:** Not defined (some pages may use shadows, needs audit)

**Medium Priority:**
10. **Responsive Breakpoints:** Not extracted (needs manual testing on mobile/tablet)
11. **Semantic Colors Usage:** Success/warning/info colors not clearly defined
12. **Element Margins:** Consistent spacing between headings/paragraphs not measured

---

## Next Steps

### Phase 1: Manual Verification (Estimated: 2-3 hours)
1. **Test hover states** on all buttons, links, icon boxes
2. **Test responsive behavior** on mobile (< 768px), tablet (768-1024px), desktop (> 1024px)
3. **Verify font family** in browser dev tools (likely Blocksy default or Google Fonts)
4. **Check form focus states** (Forminator default styling vs custom CSS)
5. **Measure actual button sizes** (height, padding) in dev tools

### Phase 2: Document Design System (Estimated: 1-2 hours)
1. **Create DESIGN-SYSTEM.md** with all verified tokens
2. **Define CSS variables** for colors, typography, spacing
3. **Document component patterns** (buttons, cards, forms, icons)
4. **Add usage guidelines** (when to use primary vs secondary colors)

### Phase 3: Create Elementor Templates (Estimated: 2-3 hours)
1. **Hero Section Template** - Navy background, H1 + H3 + CTA button
2. **Icon Box Grid Template** - 3-column grid with standardized icon boxes
3. **CTA Section Template** - Navy background, centered heading + button
4. **Compliance Footer Template** - Light gray background, icon list

### Phase 4: Apply Consistency Fixes (Estimated: 3-4 hours)
1. **Update CSS files** with standardized values (replace ad-hoc styles with variables)
2. **Update Elementor pages** to use new templates
3. **Fix body text color inconsistencies** (decide on #333333 vs #898989 usage)
4. **Add missing hover/focus states** to buttons and forms

**Total Estimated Effort:** 8-12 hours

---

## Findings Template (Use for Each Page)

### [Page Name]

**URL:** http://wp.local/[page-slug]/

#### Typography Issues
- H1: [describe any issues]
- H2: [describe any issues]
- Body: [describe any issues]

#### Color Issues
- Primary colors: [describe]
- Text colors: [describe]

#### Spacing Issues
- Section padding: [describe]
- Element margins: [describe]

#### Button Issues
- Primary buttons: [describe]
- Secondary buttons: [describe]

#### Form Issues (if applicable)
- Input fields: [describe]
- Labels: [describe]

#### Icon Issues
- Sizes: [describe]
- Colors: [describe]

#### Priority
- [ ] Critical (breaks usability)
- [ ] High (major inconsistency)
- [ ] Medium (minor inconsistency)
- [ ] Low (nice-to-have)

---

## Design Standards to Extract

After audit, document these standards in DESIGN-SYSTEM.md:

### Typography Scale
```css
h1 { font-size: XXpx; font-weight: XXX; color: #XXXXXX; }
h2 { font-size: XXpx; font-weight: XXX; color: #XXXXXX; }
h3 { font-size: XXpx; font-weight: XXX; color: #XXXXXX; }
body { font-size: XXpx; line-height: X.X; color: #XXXXXX; }
```

### Color Palette
```css
--primary-navy: #063970;
--primary-blue: #3498DB;
--secondary-grey: #6c757d;
--error-red: #dc3545;
--success-green: #28a745;
--bg-light-grey: #ECECEC;
--border-grey: #E0E0E0;
--text-primary: #333333;
--text-secondary: #898989;
```

### Spacing System
```css
--section-padding: XXpx;
--container-padding: XXpx;
--element-margin: XXpx;
```

### Button Styles
```css
.btn-primary { ... }
.btn-secondary { ... }
```

---

## Action Plan After Audit

1. **Document Findings** - Complete findings for each page
2. **Prioritize Issues** - Critical → High → Medium → Low
3. **Create DESIGN-SYSTEM.md** - Comprehensive standards document
4. **Create Elementor Templates** - Reusable patterns (Hero, CTA, etc.)
5. **Fix Inconsistencies** - Apply standards to all pages
6. **Update CSS Files** - Centralize common styles
7. **Test Changes** - Verify all pages after updates

---

## Notes

- Use browser dev tools to inspect actual computed values
- Take screenshots for reference
- Export Elementor templates for analysis
- Check both logged-in and logged-out views
- Test with different user roles (Operator, Manager, etc.)
- Verify mobile responsiveness
