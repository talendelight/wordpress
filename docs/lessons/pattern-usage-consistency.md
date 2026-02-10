# Lesson: Pattern Usage Consistency

**Date:** February 10, 2026  
**Context:** Help page creation revealed pattern usage anti-pattern  
**Severity:** High - Causes design inconsistency across pages

---

## What Went Wrong

When creating the Help page (ID 141), I wrote card HTML from memory instead of reading the actual pattern files. This resulted in cards missing critical styling:

**Missing in Initial Implementation:**
- `border-radius: 12px` (rounded corners)
- `className: "is-style-card"`
- `padding: var:preset|spacing|48` (proper spacing)
- `minHeight: 100%` (consistent card heights)

**Result:** Help page cards looked different from Welcome/Employers pages, breaking design consistency.

---

## Root Cause Analysis

**The Problem:**
1. Pattern comment was added: `<!-- Pattern: blocksy-child/card-grid-3 -->`
2. BUT the actual pattern code was NOT used as template
3. HTML was written from general WordPress knowledge
4. Styling attributes from the actual pattern were missed

**Why This Happened:**
- Assumed I knew the markup structure
- Didn't verify against source files
- Pattern comments created false confidence ("I referenced the pattern")
- Relied on memory instead of reading actual code

---

## The Correct Workflow

### ✅ ALWAYS Do This When Using Patterns

```bash
# Step 1: Read the actual pattern file
cat wp-content/themes/blocksy-child/patterns/card-grid-3.php

# Step 2: Copy the EXACT HTML structure from the pattern
# Step 3: Modify ONLY the content (headings, paragraphs, button text)
# Step 4: Keep ALL styling attributes intact
```

### ❌ NEVER Do This

```bash
# ❌ Write HTML from memory
# ❌ Assume you know the structure
# ❌ Add pattern comment without using pattern code
# ❌ Skip reading the pattern file
```

---

## Pattern File Locations

All patterns are in: `wp-content/themes/blocksy-child/patterns/*.php`

**Card Patterns:**
- `card-grid-3.php` - 3 cards in single row
- `card-grid-2-2.php` - 2x2 grid (4 cards)
- `card-grid-3+1.php` - 3 cards + 1 centered card

**Other Patterns:**
- `hero-single-cta.php` - Hero sections
- `cta-primary.php` - Call-to-action sections
- `footer-trust-badges.php` - Footer badges
- `divider-navy.php` - Navy dividers

---

## Critical Styling Attributes

### Card Group Wrapper (MUST INCLUDE)

```html
<!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
<div class="wp-block-group is-style-card has-white-background-color has-background" 
     style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
```

**Key Attributes:**
- `"border":{"radius":"12px"}` → Rounded corners
- `"className":"is-style-card"` → Card styling class
- `"padding":{"top":"var:preset|spacing|48",...}` → Consistent spacing
- `"dimensions":{"minHeight":"100%"}` → Equal card heights

### Section Wrapper (MUST INCLUDE)

```html
style="margin-top:0;margin-bottom:0;padding-top:var(--wp--preset--spacing--70);padding-bottom:var(--wp--preset--spacing--70)"
```

**Key Attributes:**
- `margin-top:0;margin-bottom:0` → Zero-gap layout
- Consistent padding values across sections

---

## Real Example: Before vs After

### ❌ Before (Written from Memory)

```html
<!-- wp:column {"style":{"spacing":{"padding":{"top":"32px","right":"32px","bottom":"32px","left":"32px"}}},"backgroundColor":"white"} -->
<div class="wp-block-column has-white-background-color has-background" 
     style="padding-top:32px;padding-right:32px;padding-bottom:32px;padding-left:32px">
```

**Missing:**
- No `border-radius` → Square corners
- No `is-style-card` class → Wrong styling
- Fixed `32px` instead of `var:preset|spacing|48` → Inconsistent spacing
- No `minHeight:100%` → Uneven card heights

### ✅ After (Copied from Pattern)

```html
<!-- wp:column -->
<div class="wp-block-column">
    <!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
    <div class="wp-block-group is-style-card has-white-background-color has-background" 
         style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
```

---

## How to Verify Pattern Usage

### 1. Read the Pattern File

```bash
cat wp-content/themes/blocksy-child/patterns/card-grid-3.php
```

### 2. Check for Key Attributes in Your HTML

```bash
# Must contain:
grep "border-radius:12px" restore/pages/your-page.html
grep "is-style-card" restore/pages/your-page.html
grep "var:preset|spacing|48" restore/pages/your-page.html
grep "minHeight:100%" restore/pages/your-page.html
```

### 3. Visual Inspection

- Cards have rounded corners? ✅
- Cards have equal heights? ✅
- Cards match Welcome/Employers pages? ✅
- No white gaps between sections? ✅

---

## Git Commits Related to This Issue

**Initial (Incomplete):**
```
5681f73c - Add Help page with FAQ and support information
```

**Fix (Added Missing Styling):**
```
211c4036 - Fix Help page card styling to match Welcome/Employers pages
```

---

## Impact and Prevention

### Impact
- **Design inconsistency** across landing pages
- **Extra work** to fix styling after initial implementation
- **User confusion** if pages look different
- **Lost time** debugging visual differences

### Prevention
1. **Always read pattern files before using them**
2. **Copy structure, modify content only**
3. **Verify styling attributes before committing**
4. **Visual comparison with existing pages**
5. **Add this check to PR review process**

---

## Related Documentation

- Pattern library: [wp-content/themes/blocksy-child/patterns/](../../wp-content/themes/blocksy-child/patterns/)
- Zero-gap layout: See SESSION-SUMMARY-FEB-10.md
- Design system: [docs/DESIGN-SYSTEM.md](../DESIGN-SYSTEM.md)

---

## Lesson Summary

**Golden Rule:** Pattern comments are not enough - you MUST use the actual pattern code as a template.

**Workflow:**
1. Read pattern file → 2. Copy structure → 3. Modify content → 4. Verify styling

**Never:**
- Write markup from memory
- Assume you know the structure
- Skip reading pattern files

**Always:**
- Read the pattern source
- Copy exact structure
- Keep all styling attributes
- Verify against existing pages
