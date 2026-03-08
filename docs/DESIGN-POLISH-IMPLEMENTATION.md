# Design Polish Implementation Status

**Created:** March 8, 2026  
**Last Updated:** March 8, 2026  
**Reference:** WORDPRESS-DESIGN-POLISH-SUMMARY.md (external design consultation)  
**Related Docs:** [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md), [COMMON-UI-DESIGN.md](../../Documents/COMMON-UI-DESIGN.md)

---

## Overview

This document tracks the implementation of design polish recommendations to improve credibility, visual consistency, and maintainability across mobile + desktop + different screen sizes.

**Goal:** Presentation layer polish (no new features) + lightweight design system for easier UX designer collaboration.

---

## Implementation Progress

### ✅ Phase 1: Design Tokens (COMPLETE - March 7-8, 2026)

**Objective:** Create global CSS variables for colors/typography/spacing - one source of truth.

**Status:** ✅ **COMPLETE**

**What Was Done:**

1. ✅ **Created design-tokens.css** ([wp-content/themes/blocksy-child/design-tokens.css](../wp-content/themes/blocksy-child/design-tokens.css))
   - 200+ CSS custom properties
   - Comprehensive token coverage:
     * Primary brand colors (Navy #063970, hover #0062e3, Accent Blue #3498DB)
     * 7 neutral greys (white to dark grey)
     * Action colors (Assign/Approve/Reject/Undo)
     * Status badge colors (New/Assigned/Approved/Rejected - Material Design palette)
     * Semantic colors (success/warning/error/info)
     * Link colors (default/hover/visited)
     * Table colors, modal colors
     * Interactive states (focus ring, input borders, heights, padding)
     * Typography scale (xs 12px → 5xl 48px, weights, line heights)
     * Spacing scale (xs 4px → 3xl 64px)
     * Border radius scale, shadows, z-index, transitions
     * Reduced motion support (@media prefers-reduced-motion)

2. ✅ **Loaded globally via functions.php**
   - Handle: `td-design-tokens`
   - Load order: FIRST (no dependencies)
   - All other CSS depends on tokens: `blocksy-child-style`, `blocksy-child-colors`, `wpum-design-system`, `td-registration-form`
   - Version: 3.2.0

3. ✅ **Color standardization - Button hover unified**
   - Replaced all `#2980B9` → `#0062e3` globally (13 occurrences)
   - Eliminated "Light Blue Button" pattern (darkening hover)
   - Standardized to 2 button types: Navy + White, both hover to #0062e3
   - Updated box-shadow rgba values to match new hover color
   - Files updated:
     * config/custom-css/td-button.css (6 instances)
     * wp-content/themes/blocksy-child/page-role-selection.php (1 instance)
     * config/custom-css/forminator-forms.css (2 instances)
     * config/custom-css/login.css (1 instance)
     * restore/pages/ archive files (3 instances)

4. ✅ **Token naming convention**
   - Uses `td-` prefix (td-design-tokens) for consistency with existing codebase
   - Semantic naming: `--color-navy`, `--color-action-approve`, `--space-md`, `--shadow-lg`

**Files Created:**
- [wp-content/themes/blocksy-child/design-tokens.css](../wp-content/themes/blocksy-child/design-tokens.css) (232 lines, production)
- [config/custom-css/design-tokens.css](../config/custom-css/design-tokens.css) (232 lines, reference copy)

**Outcome:** ✅ One source of truth for design values. Future rebrands/adjustments can be done by changing tokens, not editing every page.

---

### ⏳ Phase 2: Base Styles (NOT STARTED)

**Objective:** Create global base.css with consistent defaults for body, containers, sections, buttons, forms.

**Status:** ⏳ **TODO**

**Recommended Approach:**

1. **Create base.css file**
   - Location: `wp-content/themes/blocksy-child/base.css`
   - Enqueue after design-tokens.css in functions.php

2. **Include:**
   - Body defaults (background: `var(--color-white)`, font-family, line-height)
   - Container widths/padding (`.td-container` class)
   - Section spacing (`.td-section` class for consistent vertical rhythm)
   - Button base styles (leverage td-button.css existing work)
   - Form field base styles (inputs, selects, textareas)
   - Focus states (consistent across all interactive elements)

3. **Consolidate existing CSS:**
   - Review td-button.css, forminator-forms.css, login.css, wpum-overrides.css
   - Extract common patterns into base.css
   - Use CSS variables from design-tokens.css

**Dependencies:**
- Requires Phase 1 (design-tokens.css) ✅ COMPLETE
- Requires audit of existing custom CSS files

**Priority:** MEDIUM (improves consistency, but tokens are already working)

---

### ⏳ Phase 3: Background Standardization (PARTIALLY DONE)

**Objective:** Enforce only 2 background types to prevent drift: default page background (`--td-bg`) + alternate section/card background (`--td-surface`).

**Status:** ⏳ **PARTIALLY DONE**

**What We Have:**
- ✅ Design tokens include background colors:
  * `--color-white` (#FFFFFF) - default page background
  * `--color-grey-off-white` (#f8f9fa) - alternate backgrounds
  * `--color-grey-light` (#ECECEC) - cards/sections
  * `--color-navy` (#063970) - hero/CTA sections
  * `--color-table-header-bg`, `--color-modal-bg` etc.

**What's Missing:**
- ❌ Wrapper classes not yet defined:
  * `.td-section` for vertical spacing
  * `.td-surface` for alternate background sections/cards
  * `.td-container` for layout width/padding

**Recommended Next Steps:**

1. **Add to base.css:**
   ```css
   /* Layout Containers */
   .td-container {
     max-width: 1200px;
     margin: 0 auto;
     padding: 0 var(--space-lg);
   }
   
   /* Section Spacing */
   .td-section {
     padding: var(--space-3xl) 0;
   }
   
   @media (max-width: 768px) {
     .td-section {
       padding: var(--space-2xl) 0;
     }
   }
   
   /* Alternate Background */
   .td-surface {
     background: var(--color-grey-off-white);
     padding: var(--space-xl);
     border-radius: var(--border-radius-lg);
   }
   
   .td-surface--card {
     background: var(--color-white);
     border: 1px solid var(--color-grey-medium-border);
     box-shadow: var(--shadow-sm);
   }
   ```

2. **Update DESIGN-SYSTEM.md** to document these classes

3. **Apply classes in pages** (gradual migration)

**Priority:** HIGH (prevents background color drift)

---

### ⏳ Phase 4: Component Classes (NOT STARTED)

**Objective:** Define minimal "approved classes" list for consistent components.

**Status:** ⏳ **TODO**

**Recommended Classes:**

```css
/* Already Exists (in td-button.css) */
.btn-blue         /* Light blue button (primary CTA) */
.btn-grey         /* Grey button (secondary actions) */
#td-role-next     /* Navy button (role selection) */
#td-role-back     /* Back button */

/* To Be Added (in base.css) */
.td-btn           /* Base button class using design tokens */
.td-btn--primary  /* Primary navy button */
.td-btn--secondary /* Secondary grey button */
.td-btn--full     /* Full width button (mobile) */

.td-container     /* Layout container */
.td-section       /* Section vertical spacing */
.td-surface       /* Alternate background wrapper */
.td-card          /* Card component */
.td-text-muted    /* Muted text (secondary info) */
```

**Implementation Plan:**

1. Create `.td-btn` base class:
   ```css
   .td-btn {
     display: inline-block;
     padding: var(--space-md) var(--space-lg);
     border-radius: 50px;
     font-size: var(--font-size-base);
     font-weight: var(--font-weight-semibold);
     text-align: center;
     transition: var(--transition-base);
     cursor: pointer;
     border: none;
     min-width: 180px;
   }
   
   .td-btn--primary {
     background: var(--color-navy);
     color: var(--color-white);
   }
   
   .td-btn--primary:hover {
     background: var(--color-navy-hover);
   }
   
   .td-btn--secondary {
     background: var(--color-grey-light);
     color: var(--color-grey-dark);
   }
   
   .td-btn--secondary:hover {
     background: var(--color-grey-medium-hover);
   }
   
   @media (max-width: 768px) {
     .td-btn--full {
       width: 100%;
       min-width: unset;
     }
   }
   ```

2. Gradually refactor existing button CSS to use `.td-btn` classes

3. Document in DESIGN-SYSTEM.md

**Priority:** MEDIUM (improves consistency, but existing button classes work)

---

### ⏳ Phase 5: Mobile Polish (NOT STARTED)

**Objective:** Add responsive breakpoint rules for better mobile experience.

**Status:** ⏳ **TODO**

**Recommended Approach:**

Add to base.css:

```css
/* Mobile Breakpoint: 768px and below */
@media (max-width: 768px) {
  /* Reduce padding and spacing */
  .td-container {
    padding: 0 var(--space-md);
  }
  
  .td-section {
    padding: var(--space-2xl) 0;
  }
  
  .td-surface {
    padding: var(--space-lg);
  }
  
  /* Full width CTA buttons */
  .td-btn,
  .btn-blue,
  .btn-grey,
  #td-role-next {
    width: 100%;
    min-width: unset;
  }
  
  /* Comfortable tap targets (WCAG 2.1 AAA: 44x44px minimum) */
  button,
  input[type="submit"],
  input[type="button"],
  .button,
  a.button {
    min-height: 44px;
    padding: var(--space-md) var(--space-lg);
  }
  
  /* Typography adjustments */
  h1 {
    font-size: var(--font-size-4xl); /* 36px instead of 48px */
  }
  
  h2 {
    font-size: var(--font-size-3xl); /* 30px */
  }
  
  /* Reduce shadow intensity on mobile */
  .td-surface,
  .td-card {
    box-shadow: var(--shadow-sm);
  }
}
```

**Testing Checklist:**
- [ ] All pages tested at 320px (iPhone SE), 375px (iPhone 12), 768px (iPad)
- [ ] Tap targets minimum 44x44px (WCAG AAA)
- [ ] Buttons don't overflow horizontally
- [ ] Form fields comfortable to tap and type
- [ ] Text remains readable (no tiny fonts)
- [ ] Spacing proportional (not too tight)

**Priority:** HIGH (mobile traffic is significant)

---

## Current State Summary

### ✅ What's Working Well

1. **Design tokens implemented** - 200+ CSS variables ready to use
2. **Global loading** - tokens available on all pages via functions.php
3. **Color consistency** - Button hover unified to #0062e3
4. **Action/Status colors optimal** - Material Design palette, WCAG compliant
5. **Grey shades well-distributed** - 7 shades with clear semantic purposes
6. **Semantic naming** - Easy for designers to understand (`--color-navy-hover`, `--space-md`)

### ⚠️ What Needs Work

1. **No base.css yet** - Missing global defaults for body, containers, buttons, forms
2. **No wrapper classes** - `.td-container`, `.td-section`, `.td-surface` not defined
3. **No component classes** - `.td-btn`, `.td-card` not implemented
4. **Mobile not optimized** - No breakpoint rules for smaller screens
5. **Some inline styles remain** - page-role-selection.php has embedded `<style>` block that could use tokens

### 🎯 Quick Wins (High Impact, Low Effort)

1. **Create base.css** with:
   - `.td-container` for layout width
   - `.td-section` for vertical spacing
   - `.td-btn` base button class
   - Mobile breakpoint (@media max-width: 768px)

2. **Update page-role-selection.php** - Replace hex codes with CSS variables:
   ```css
   /* Before */
   background: #063970;
   color: #0062e3;
   
   /* After */
   background: var(--color-navy);
   color: var(--color-navy-hover);
   ```

3. **Add `.td-btn--full` class** - Make CTA buttons full width on mobile

**Estimated effort:** 2-3 hours (one session during gap days)

---

## Next Actions (Prioritized)

### High Priority (This Week - March 8-14, 2026)

1. **Create base.css** (2 hours)
   - Location: wp-content/themes/blocksy-child/base.css
   - Include: body defaults, container/section/surface classes, mobile breakpoint
   - Enqueue in functions.php after td-design-tokens

2. **Refactor page-role-selection.php** (30 minutes)
   - Replace inline hex codes with CSS variables
   - Extract embedded `<style>` block to external CSS if possible

3. **Test mobile experience** (1 hour)
   - Check Welcome, Employers, Candidates, Login, Register pages
   - Test at 320px, 375px, 768px breakpoints
   - Document issues in DESIGN-AUDIT-LOCAL.md

### Medium Priority (Gap Days - March 8-16, 2026)

4. **Create component classes** (1-2 hours)
   - `.td-btn` and variants
   - `.td-card` component
   - `.td-text-muted` utility

5. **Update DESIGN-SYSTEM.md** (30 minutes)
   - Document base.css classes
   - Add usage examples for `.td-container`, `.td-section`, `.td-surface`
   - Link to design-tokens.css

6. **Update COMMON-UI-DESIGN.md** (30 minutes)
   - Fill remaining TBD items with production values
   - Reference WordPress design-tokens.css
   - Add mobile breakpoint rules

### Low Priority (Post-MVP)

7. **Gradual migration** - Apply `.td-*` classes to existing pages
8. **Pattern library** - Document reusable block patterns using design tokens
9. **Dark mode tokens** - Add CSS variables for dark theme (future)

---

## How This Helps UX Designer

**Before (without design system):**
- Designer edits colors/spacing in 10+ different CSS files
- Inconsistencies creep in (slightly different blues, spacing values)
- Hard to apply global changes (e.g., rebrand to different blue)

**After (with design system):**
- Designer changes `--color-navy` in design-tokens.css → entire site updates
- Consistent components (`.td-btn`, `.td-card`) = faster page creation
- Mobile breakpoint rules = predictable responsive behavior
- Clear documentation = designer can work independently

**Support for future rebrand:**
- Change 5-10 token values in design-tokens.css
- Entire site rebrands instantly
- No need to hunt through hundreds of hex codes

---

## Design System Philosophy (March 2026)

### Principles

1. **Minimal, not maximal** - Small set of tokens + components, not a design system program
2. **Code-first** - No Figma dependency, CSS variables are source of truth
3. **Practical** - Solve real problems (consistency, mobile, rebrand ease), not theoretical ones
4. **Incremental** - Gradual migration, no big rewrite needed
5. **Designer-friendly** - Clear naming, good documentation, easy to modify

### What Success Looks Like

- ✅ Designer can adjust site look-and-feel by editing ONE file (design-tokens.css)
- ✅ New pages use consistent components (`.td-btn`, `.td-section`)
- ✅ Mobile experience is comfortable (44px tap targets, full-width CTAs)
- ✅ No background color drift (only 2-3 background types)
- ✅ Rebrand takes hours, not days

---

## Related Documents

- [design-tokens.css](../wp-content/themes/blocksy-child/design-tokens.css) - 200+ CSS variables (production)
- [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) - WordPress design system documentation
- [COMMON-UI-DESIGN.md](../../Documents/COMMON-UI-DESIGN.md) - Cross-application design primitives
- [DESIGN-AUDIT-LOCAL.md](DESIGN-AUDIT-LOCAL.md) - Local environment design audit findings
- [WORDPRESS-UI-DESIGN.md](../../Documents/WORDPRESS-UI-DESIGN.md) - Business functionality UI requirements
- [PRODUCTION-COLOR-EXTRACTION.md](../../Documents/tmp/PRODUCTION-COLOR-EXTRACTION.md) - Production color analysis (March 7, 2026)
- [WORDPRESS-DESIGN-POLISH-SUMMARY.md](../../Downloads/WORDPRESS-DESIGN-POLISH-SUMMARY.md) - External design consultation notes

---

**Status:** Phase 1 complete ✅ | Phases 2-5 in planning ⏳  
**Next Review:** March 14, 2026 (end of gap days)
