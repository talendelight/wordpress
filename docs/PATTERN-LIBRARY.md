# Block Pattern Library

**Version:** 1.0.0 (v3.5.1)  
**Created:** February 8, 2026  
**Theme:** Blocksy Child  
**Purpose:** Reusable Gutenberg block patterns for Elementor-to-Gutenberg migration

## Overview

This pattern library contains 10 production-tested, reusable Gutenberg block patterns that encode design system values and solutions discovered during the Welcome page migration. All patterns are registered via `functions.php` and available in the WordPress block editor under the **TalenDelight** category.

## Pattern Categories

### Layout Patterns

#### 1. Hero with Single CTA
- **Slug:** `blocksy-child/hero-single-cta`
- **File:** `patterns/hero-single-cta.php`
- **Categories:** hero, header
- **Use Cases:** Landing pages, welcome sections, campaign pages
- **Features:**
  - Full-width navy background (#063970)
  - White text, 48px h1, 20px description
  - Single pill CTA button (50px border-radius)
  - 80px top/bottom padding (design system)
  - Centered layout

**When to Use:**
- Homepage hero sections
- Landing page headers
- Feature announcement banners

---

#### 2. Card Grid 3+1
- **Slug:** `blocksy-child/card-grid-3+1`
- **File:** `patterns/card-grid-3+1.php`
- **Categories:** cards, grid, features
- **Use Cases:** Services overview, features grid, specialty showcase
- **Features:**
  - Gray off-white section background (#F8F9FA)
  - 4-column responsive grid with 32px gaps
  - Equal height cards (min-height:100%)
  - **64px margin below section heading** (production-tested spacing)
  - **Icon + title combined in single HTML block** (8px spacing solution)
  - 48px card padding, 12px border-radius
  - Font Awesome icons (48px, blue #3498DB)
  - Navy titles (#063970), gray descriptions (#666666)

**When to Use:**
- "Our Services" sections
- Feature showcases
- Specialty highlights (like Welcome page)
- Any 4-item grid layout

**Pre-filled Icons:**
- Card 1: `fa-cloud` (Cloud Services)
- Card 2: `fa-globe` (Global Reach)
- Card 3: `fa-server` (Infrastructure)
- Card 4: `fa-question-circle` (Support)

---

#### 3. Icon Feature Card
- **Slug:** `blocksy-child/icon-card`
- **File:** `patterns/icon-card.php`
- **Categories:** cards, features
- **Use Cases:** Single card in custom grids, feature highlights
- **Features:**
  - White background with 12px border-radius
  - 48px padding
  - min-height:100% for equal column heights
  - **Icon + title in single HTML block** (production-proven 8px spacing)
  - Font Awesome icon (48px, blue #3498DB)
  - 24px navy title (#063970)
  - 14px gray description (#666666)

**When to Use:**
- Building custom card grids (2, 3, 5, 6 columns)
- Feature comparisons
- Service cards
- Testimonial cards (with icon swap)

**Usage Tips:**
- Duplicate within a Columns block to create custom grids
- Replace icon class (e.g., `fa-star` → `fa-users`)
- Maintain icon+title combined structure for consistent spacing

---

### Call-to-Action Patterns

#### 4. Primary CTA Band
- **Slug:** `blocksy-child/cta-primary`
- **File:** `patterns/cta-primary.php`
- **Categories:** call-to-action, cta
- **Use Cases:** Conversion sections, mid-page CTAs, bottom page CTAs
- **Features:**
  - Full-width blue background (#3498DB)
  - White text, 36px h2 heading
  - Centered layout with 80px padding
  - White button with navy text (inverted style)
  - Pill button styling (50px border-radius)

**When to Use:**
- End of long-form content
- Between major sections
- Above footer
- After feature descriptions

**Customization:**
- Change heading text to match call-to-action
- Update button text and link
- Can change background to navy for variation

---

### Process/Workflow Patterns

#### 5. How It Works (3 Steps)
- **Slug:** `blocksy-child/how-it-works-3`
- **File:** `patterns/how-it-works-3.php`
- **Categories:** features, process
- **Use Cases:** Process explanation, workflow steps, onboarding guides
- **Features:**
  - 3-column responsive grid
  - Numbered step circles (64px, blue #3498DB)
  - Gray off-white cards (#F8F9FA)
  - 48px card padding, 12px border-radius
  - 64px heading bottom margin (design system)
  - 32px column gaps

**When to Use:**
- "How It Works" sections
- Registration process explanation
- Onboarding workflows
- Step-by-step guides

**Customization:**
- Change step numbers (1, 2, 3)
- Update step titles and descriptions
- Can add more columns for 4+ step process

---

### Alert/Notification Patterns

All alert patterns share consistent styling with icon, colored border, and appropriate semantic colors.

#### 6. Status Alert (Success)
- **Slug:** `blocksy-child/alert-success`
- **File:** `patterns/alert-success.php`
- **Categories:** alerts, notifications
- **Colors:** Green (#28a745 border, #d4edda background, #155724 text)
- **Icon:** `fa-check-circle`
- **Use Case:** Success messages, confirmation notices

#### 7. Status Alert (Warning)
- **Slug:** `blocksy-child/alert-warning`
- **File:** `patterns/alert-warning.php`
- **Categories:** alerts, notifications
- **Colors:** Yellow (#ffc107 border, #fff3cd background, #856404 text)
- **Icon:** `fa-exclamation-triangle`
- **Use Case:** Warning messages, important notices

#### 8. Status Alert (Error)
- **Slug:** `blocksy-child/alert-error`
- **File:** `patterns/alert-error.php`
- **Categories:** alerts, notifications
- **Colors:** Red (#dc3545 border, #f8d7da background, #721c24 text)
- **Icon:** `fa-times-circle`
- **Use Case:** Error messages, validation failures

#### 9. Status Alert (Info)
- **Slug:** `blocksy-child/alert-info`
- **File:** `patterns/alert-info.php`
- **Categories:** alerts, notifications
- **Colors:** Cyan (#17a2b8 border, #d1ecf1 background, #0c5460 text)
- **Icon:** `fa-info-circle`
- **Use Case:** Informational messages, help text

**When to Use Alerts:**
- Form submission feedback
- Page status messages
- Important notices in content
- User guidance messages

**Customization:**
- Replace message text
- Change icon (maintain same color)
- Can stack multiple alerts for different message types

---

### Legal/Documentation Patterns

#### 10. Legal Page Header
- **Slug:** `blocksy-child/legal-header`
- **File:** `patterns/legal-header.php`
- **Categories:** headers, legal
- **Use Cases:** Privacy Policy, Terms of Service, Legal Notices
- **Features:**
  - Full-width gray off-white background (#F8F9FA)
  - Centered 48px h1 in navy (#063970)
  - "Last Updated" date in 14px gray text (#666666)
  - 48px top/bottom padding

**When to Use:**
- Privacy Policy page
- Terms of Service page
- Cookie Policy page
- Any legal/compliance documentation

**Customization:**
- Update page title
- Change "Last Updated" date
- Optional: Add version number

---

## Design System Integration

All patterns use consistent design system values:

### Colors
- **Navy:** #063970 (primary text, headings)
- **Blue:** #3498DB (icons, CTAs, backgrounds)
- **Gray Off-White:** #F8F9FA (section backgrounds)
- **White:** #FFFFFF (card backgrounds, inverted text)
- **Gray Text:** #666666 (descriptions, body text)

### Typography
- **H1:** 48px, font-weight 700
- **H2:** 36px, font-weight 700
- **H3:** 24px, font-weight 700
- **Body:** 16px (default)
- **Small:** 14px (descriptions, dates)
- **Button Text:** 16px, font-weight 600

### Spacing
- **Section Padding:** 80px top/bottom
- **Card Padding:** 48px
- **Column Gaps:** 32px
- **Heading Bottom Margin:** 64px (production-tested)
- **Icon-Title Spacing:** 8px (in combined HTML blocks)
- **Border Radius:** 12px (cards), 50px (buttons)

### Icons
- **Size:** 48px
- **Color:** Blue (#3498DB)
- **Library:** Font Awesome 6.5.1 (via Better Font Awesome plugin)
- **Spacing:** 8px margin-bottom when combined with title

---

## Key Production Lessons Encoded

### 1. Icon + Title Combined HTML Blocks
**Problem:** Separate Gutenberg blocks for icons and titles created excessive, uncontrollable spacing.

**Solution:** Combined icon and title in single HTML block with explicit 8px spacing:
```html
<div style="text-align:center;">
    <i class="fas fa-cloud" style="font-size:48px;color:#3498DB;display:block;margin-bottom:8px;"></i>
    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0;">Title</h3>
</div>
```

**Where Used:** icon-card.php, specialty-grid-4.php

---

### 2. 64px Section Heading Spacing
**Problem:** 48px margin-bottom below section headings felt cramped on production.

**Solution:** Increased to 64px based on user feedback during Welcome page production deployment.

**Where Used:** card-grid-3+1.php, how-it-works-3.php

---

### 3. Equal Height Cards
**Problem:** Cards in multi-column layouts had different heights, breaking visual alignment.

**Solution:** `min-height:100%` on card containers inside Column blocks.

**Where Used:** icon-card.php, card-grid-3+1.php, how-it-works-3.php

---

## Usage Guidelines

### In WordPress Block Editor

1. **Insert Pattern:**
   - Click (+) to add new block
   - Select "Patterns" tab
   - Find pattern under "TalenDelight" category or search by name
   - Click to insert

2. **Customize Content:**
   - Edit text directly in blocks
   - Replace placeholder content
   - Modify links and button URLs
   - Change icons by editing HTML blocks

3. **Duplicate Pattern:**
   - Select entire pattern group (click parent block)
   - Copy (Ctrl+C) and Paste (Ctrl+V)
   - Useful for creating additional card columns

### For Developers

**Pattern File Structure:**
```php
<?php
/**
 * Title: Pattern Display Name
 * Slug: blocksy-child/pattern-slug
 * Categories: category1, category2
 * Description: Brief description of pattern purpose
 */
?>

<!-- WordPress block markup here -->
```

**Adding New Patterns:**
1. Create PHP file in `wp-content/themes/blocksy-child/patterns/`
2. Follow file structure above
3. Pattern auto-registered via `functions.php` on next page load
4. Test in block editor
5. Document in this file

**Modifying Patterns:**
1. Edit pattern PHP file
2. Clear WordPress cache: `wp cache flush`
3. Refresh editor page
4. Existing page content using pattern is NOT affected (patterns are templates, not live references)

---

## Pattern Registration

Patterns are registered via `functions.php` using custom code:

```php
add_action('init', function() {
    $patterns_dir = get_stylesheet_directory() . '/patterns/';
    $pattern_files = glob($patterns_dir . '*.php');
    
    foreach ($pattern_files as $pattern_file) {
        // Extract metadata from file headers
        $headers = get_file_data($pattern_file, array(
            'title' => 'Title',
            'slug' => 'Slug',
            'description' => 'Description',
            'categories' => 'Categories',
        ));
        
        // Register pattern with WordPress
        register_block_pattern($headers['slug'], array(
            'title' => $headers['title'],
            'description' => $headers['description'],
            'content' => /* pattern content */,
            'categories' => /* parsed categories */,
        ));
    }
}, 9);
```

**Why Manual Registration:**
WordPress 6.9 auto-registration wasn't detecting all patterns. Custom code ensures all patterns in `patterns/` directory are registered correctly.

---

## Migration Workflow

### Phase 1: Design System ✅ Complete
- CSS custom properties
- Global styles
- Color palette
- Typography scales

### Phase 2: Pattern Library ✅ Complete (This Document)
- 10 core patterns created
- Production-tested solutions
- Design system integration
- Pattern documentation

### Phase 3: Page Migrations (Next)
Using patterns will make page migrations 3x faster:
1. Create new page in Gutenberg editor
2. Insert relevant patterns
3. Customize content (text, images, links)
4. Test responsive layout
5. Publish

**Recommended Migration Order:**
1. ✅ Welcome (complete - used to create patterns)
2. Register Profile (simple - hero + form)
3. Select Role (simple - hero + cards)
4. Help (moderate - mix of patterns)
5. Profile pages (moderate - forms + alerts)
6. Dashboard pages (complex - custom layouts + alerts)

---

## Dependencies

### Required Plugins
- **Better Font Awesome 2.0.4** - Local font hosting for icons
  - All patterns use `fas` (Font Awesome Solid) classes
  - Icons load from local files (not CDN)

### Theme Requirements
- **Blocksy 2.1.23** - Parent theme
- **Blocksy Child** - Active theme with patterns/ directory
- **Design system CSS** - Custom properties in style.css

### WordPress Version
- **WordPress 6.9.0** - Block editor, pattern registration API

---

## Testing Checklist

When creating or modifying patterns:

- [ ] Pattern appears in block editor "Patterns" tab
- [ ] Pattern shows under "TalenDelight" category
- [ ] Pattern preview renders correctly
- [ ] Pattern inserts without errors
- [ ] All Font Awesome icons display
- [ ] Colors match design system
- [ ] Spacing matches design system (80px, 64px, 48px, 32px)
- [ ] Responsive layout works (mobile, tablet, desktop)
- [ ] Content is editable after insertion
- [ ] No console errors on page load
- [ ] Pattern works in Welcome page environment

---

## Future Enhancements

**Planned Additions (Post-MVP):**
- Login panel pattern (WPUM integration)
- CTA band with SLA note variant
- 2-column text+image layouts
- Testimonial card pattern
- FAQ accordion pattern
- Pricing table pattern
- Timeline/milestones pattern
- Team member card pattern

**Pattern Library v2.0 Goals:**
- Pattern variations (color schemes, sizes)
- Block binding for dynamic content
- Pattern transformations (convert between variants)
- Pattern preview thumbnails
- Category organization refinement

---

## Troubleshooting

### Pattern Not Showing in Editor
1. Check pattern file has correct header format
2. Verify file is in `patterns/` directory
3. Clear WordPress cache: `wp cache flush`
4. Restart WordPress container (Podman): `podman restart wp`
5. Check debug.log for PHP errors

### Icons Not Displaying
1. Verify Better Font Awesome plugin is active
2. Check icon class names (must be `fas fa-{icon-name}`)
3. Ensure Font Awesome 6.5.1 syntax (some icons renamed)
4. Test on production (font files must be deployed)

### Spacing Issues
1. Verify design system CSS loaded (custom properties)
2. Check for conflicting theme/plugin CSS
3. Use browser inspector to verify computed styles
4. Compare with production Welcome page

### Pattern Changes Not Reflecting
- Patterns are templates, not live references
- Existing page content won't update when pattern changes
- Must manually update pages OR re-insert pattern

---

## Version History

### v1.0.0 (February 8, 2026) - Initial Release
- 10 core patterns created
- Production-tested on Welcome page
- Design system integration complete
- Documentation complete
- All patterns registered and verified

**Context:** Created during Elementor-to-Gutenberg migration (v3.5.1), Phase 2 of migration plan. Patterns encode lessons learned from Welcome page production deployment.

---

## Support & Contact

**Project:** TalenDelight WordPress Migration  
**Theme:** Blocksy Child  
**Documentation:** See `docs/ELEMENTOR-TO-GUTENBERG-MIGRATION.md` for complete migration strategy  
**Design System:** See `docs/DESIGN-SYSTEM.md` for color/spacing specifications  
**Git Repository:** [github.com/talendelight/wordpress](https://github.com/talendelight/wordpress) (placeholder)

---

*Last Updated: February 8, 2026*  
*Pattern Library v1.0.0*  
*Part of v3.5.1 Elementor-to-Gutenberg Migration*
