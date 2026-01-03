# Wireframe Specification — Home Page

**Elementor Template Name:** `WF - Home`  
**Feature:** WP-01.1  
**Status:** Ready for Implementation  
**Created:** December 30, 2025  
**Last Updated:** December 30, 2025

---

## Overview

**Primary Goal:** Convert employers (Request candidates) and candidates (Submit CV) with clear value proposition and minimal friction.

**Target Audiences:**
- Employers seeking IT/Tech talent
- IT professionals seeking opportunities
- Geographic focus: Baltics and EU

**Key Success Metrics:**
- Primary CTAs visible above fold (desktop)
- Clear differentiation between employer and candidate paths
- Mobile-responsive with no horizontal scrolling
- Page load < 3 seconds

---

## Page Structure (Top to Bottom)

### 1. Header (Global Template)
**Template:** `WF - Header`  
**Status:** Reusable across all pages

**Desktop Layout:**
- Left: TalenDelight logo (link to home)
- Center: Navigation menu (Employers | Candidates | Contact)
- Right: Primary CTA button "For Employers" (links to /employers/)

**Mobile Layout:**
- Logo left
- Hamburger menu right
- Sticky positioning (optional)

---

### 2. Hero Section
**Saved Section:** `WF - Hero`

#### Elementor Structure:
```
Container (Full Width)
├── Background: Navy Blue (#063970)
├── Padding: 120px (desktop) / 80px (tablet) / 60px (mobile)
├── Container (Boxed - max-width 1200px, centered)
    ├── Heading Widget (H1)
    │   └── Text: "Talent for today. Growth for tomorrow."
    │   └── Color: White (#FFFFFF)
    │   └── Size: 48px (desktop) / 36px (tablet) / 28px (mobile)
    │   └── Font Weight: Bold (700)
    │   └── Alignment: Center
    │
    ├── Text Editor Widget (Subheadline)
    │   └── Text: "Great tech talent meets great companies here. Whether you're hiring or leveling up your career, we'll get you matched."
    │   └── Color: White (#FFFFFF)
    │   └── Size: 20px (desktop) / 18px (tablet) / 16px (mobile)
    │   └── Alignment: Center
    │   └── Max-width: 800px, centered
    │   └── Margin-top: 24px
    │
    ├── Text Editor Widget (Geographic text)
    │   └── Text: "Serving the Baltics and European Union"
    │   └── Color: White (#FFFFFF) at 80% opacity
    │   └── Size: 14px
    │   └── Alignment: Center
    │   └── Margin-top: 16px
    │
    └── Container (Button Group - Flexbox Row, centered)
        ├── Gap: 24px
        ├── Margin-top: 40px
        ├── Direction: Row (desktop/tablet) / Column (mobile)
        │
        ├── Button Widget (Primary CTA)
        │   └── Text: "For Employers"
        │   └── Link: /employers/
        │   └── Background: White (#FFFFFF)
        │   └── Text Color: Navy Blue (#063970)
        │   └── Padding: 16px 32px
        │   └── Border Radius: 4px
        │   └── Font Weight: Semi-bold (600)
        │   └── Hover: Background #f0f0f0
        │
        └── Button Widget (Secondary CTA)
            └── Text: "For Candidates"
            └── Link: /candidates/
            └── Background: Transparent
            └── Border: 2px solid White
            └── Text Color: White (#FFFFFF)
            └── Padding: 14px 30px (account for border)
            └── Border Radius: 4px
            └── Font Weight: Semi-bold (600)
            └── Hover: Background White at 10% opacity
```

#### Responsive Rules:
- **Desktop (1440px):** Heading 48px, buttons side-by-side
- **Tablet (768px):** Heading 36px, buttons side-by-side
- **Mobile (375px):** Heading 28px, buttons stacked full-width, reduce vertical padding

#### Acceptance Criteria:
- [ ] Both CTAs visible without scrolling on desktop
- [ ] Text readable on navy background (white text)
- [ ] Buttons have adequate touch targets (44x44px minimum)
- [ ] Geographic text subtle but readable

---

### 3. Specialties Section
**Saved Section:** `WF - Specialties Grid`

#### Elementor Structure:
```
Container (Full Width)
├── Background: White (#FFFFFF)
├── Padding: 80px (desktop) / 60px (tablet) / 40px (mobile)
├── Container (Boxed - max-width 1200px, centered)
    ├── Heading Widget (H2)
    │   └── Text: "Our Specialties"
    │   └── Color: Navy Blue (#063970)
    │   └── Size: 36px (desktop) / 28px (tablet) / 24px (mobile)
    │   └── Alignment: Center
    │   └── Margin-bottom: 48px
    │
    └── Container (Grid Layout)
        ├── Columns: 2 (desktop) / 2 (tablet) / 1 (mobile)
        ├── Gap: 32px (desktop) / 24px (tablet/mobile)
        │
        ├── Container (Card 1 - Java Backend)
        │   ├── Background: White (#FFFFFF)
        │   ├── Border: 1px solid #e0e0e0
        │   ├── Border Radius: 8px
        │   ├── Padding: 32px
        │   ├── Hover: Border color Navy Blue (#063970)
        │   │
        │   ├── Icon Widget (Optional - tech icon)
        │   │   └── Size: 48px
        │   │   └── Color: Navy Blue (#063970)
        │   │   └── Margin-bottom: 16px
        │   │
        │   ├── Heading Widget (H3)
        │   │   └── Text: "Java Backend (Spring)"
        │   │   └── Color: Black (#000000)
        │   │   └── Size: 24px
        │   │   └── Margin-bottom: 16px
        │   │
        │   ├── Text Editor Widget
        │   │   └── Text: "Build robust, scalable backend systems with experienced Java engineers. From microservices architecture to enterprise applications, our Spring specialists deliver high-performance solutions that power your business."
        │   │   └── Color: Grey (#898989)
        │   │   └── Size: 16px
        │   │   └── Line-height: 1.6
        │   │   └── Margin-bottom: 24px
        │   │
        │   ├── Container (Skill Tags - Flexbox Row, wrap)
        │   │   ├── Gap: 8px
        │   │   ├── Margin-bottom: 24px
        │   │   │
        │   │   └── [6 Badge/Button Widgets for tags]
        │   │       └── Text: "Spring Boot", "Microservices", "REST APIs", "PostgreSQL", "Kafka", "Docker"
        │   │       └── Background: Navy Blue (#063970) at 10% opacity
        │   │       └── Text Color: Navy Blue (#063970)
        │   │       └── Padding: 6px 12px
        │   │       └── Border Radius: 4px
        │   │       └── Size: 14px
        │   │       └── No hover effect (informational only)
        │   │
        │   └── Button Widget (CTA)
        │       └── Text: "Request Talent"
        │       └── Link: /employers/
        │       └── Style: Text link or outline button
        │       └── Color: Navy Blue (#063970)
        │
        ├── Container (Card 2 - Fullstack)
        │   └── [Same structure as Card 1]
        │       └── Title: "Fullstack (Node/React)"
        │       └── Description: "Ship modern web applications faster with versatile fullstack developers. Our engineers excel at both frontend and backend, creating seamless user experiences backed by solid server-side logic."
        │       └── Tags: "React", "Node.js", "TypeScript", "MongoDB", "GraphQL", "AWS"
        │
        ├── Container (Card 3 - DevOps)
        │   └── [Same structure as Card 1]
        │       └── Title: "DevOps (Kubernetes/Terraform)"
        │       └── Description: "Accelerate delivery and maintain reliability with DevOps engineers who bridge development and operations. Automate deployments, optimize infrastructure, and scale with confidence."
        │       └── Tags: "Kubernetes", "Terraform", "CI/CD", "AWS/Azure", "Docker", "Jenkins"
        │
        └── Container (Card 4 - Cloud Engineering)
            └── [Same structure as Card 1]
                └── Title: "Cloud Engineering"
                └── Description: "Leverage the full power of cloud platforms with architects and engineers who design, migrate, and optimize cloud infrastructure. Reduce costs while improving performance and security."
                └── Tags: "AWS", "Azure", "GCP", "Infrastructure as Code", "Cloud Security", "Cost Optimization"
```

#### Responsive Rules:
- **Desktop (1440px):** 2 columns, cards equal height
- **Tablet (768px):** 2 columns, reduce padding
- **Mobile (375px):** 1 column, full width cards

#### Acceptance Criteria:
- [ ] All 4 specialty cards display correctly
- [ ] Cards have equal height in each row
- [ ] Skill tags wrap properly, don't overflow
- [ ] Hover effect on cards works (border color change)
- [ ] "Request Talent" CTAs link to /employers/

---

### 4. How It Works Section (Employers)
**Saved Section:** `WF - How It Works`

#### Elementor Structure:
```
Container (Full Width)
├── Background: Grey (#898989) at 5% opacity (or very light grey #f8f8f8)
├── Padding: 80px (desktop) / 60px (tablet) / 40px (mobile)
├── Container (Boxed - max-width 1200px, centered)
    ├── Heading Widget (H2)
    │   └── Text: "How It Works (For Employers)"
    │   └── Color: Navy Blue (#063970)
    │   └── Size: 36px (desktop) / 28px (tablet) / 24px (mobile)
    │   └── Alignment: Center
    │   └── Margin-bottom: 48px
    │
    └── Container (Steps - Flexbox Row, space-between)
        ├── Direction: Row (desktop) / Column (mobile)
        ├── Gap: 40px (desktop) / 32px (mobile)
        │
        ├── Container (Step 1)
        │   ├── Flex: 1
        │   ├── Alignment: Center (text-align)
        │   │
        │   ├── Icon or Number Widget
        │   │   └── Content: "01" or icon
        │   │   └── Color: Navy Blue (#063970)
        │   │   └── Size: 48px
        │   │   └── Font Weight: Bold
        │   │   └── Margin-bottom: 16px
        │   │
        │   ├── Heading Widget (H3)
        │   │   └── Text: "Tell us your needs"
        │   │   └── Color: Black (#000000)
        │   │   └── Size: 20px
        │   │   └── Margin-bottom: 12px
        │   │
        │   └── Text Editor Widget
        │       └── Text: "Share your requirements and team goals through our simple form or schedule a quick call."
        │       └── Color: Grey (#898989)
        │       └── Size: 16px
        │       └── Line-height: 1.6
        │
        ├── Container (Step 2)
        │   └── [Same structure as Step 1]
        │       └── Number: "02"
        │       └── Title: "Meet qualified candidates"
        │       └── Description: "Review pre-screened IT professionals matched to your specific requirements."
        │
        └── Container (Step 3)
            └── [Same structure as Step 1]
                └── Number: "03"
                └── Title: "Hire with confidence"
                └── Description: "We coordinate interviews and onboarding to get your new team member started quickly."
```

#### Responsive Rules:
- **Desktop (1440px):** 3 columns side-by-side
- **Tablet (768px):** 3 columns but tighter spacing
- **Mobile (375px):** Stacked vertically, full width

#### Acceptance Criteria:
- [ ] All 3 steps visible and clearly numbered
- [ ] Text readable against background
- [ ] Equal width/spacing on desktop
- [ ] Vertical stacking works on mobile

---

### 5. Candidate CTA Strip
**Saved Section:** `WF - CTA Strip`

#### Elementor Structure:
```
Container (Full Width)
├── Background: Navy Blue (#063970)
├── Padding: 60px (desktop) / 40px (tablet/mobile)
├── Container (Boxed - max-width 1200px, centered)
    ├── Flexbox Row (desktop) / Column (mobile)
    ├── Justify: Space-between
    ├── Align: Center
    ├── Gap: 24px (mobile)
    │
    ├── Container (Text Section)
    │   ├── Heading Widget (H2)
    │   │   └── Text: "Are you a tech professional?"
    │   │   └── Color: White (#FFFFFF)
    │   │   └── Size: 28px (desktop) / 24px (mobile)
    │   │   └── Margin-bottom: 8px
    │   │
    │   └── Text Editor Widget
    │       └── Text: "Submit your CV and get matched with great opportunities."
    │       └── Color: White (#FFFFFF) at 90% opacity
    │       └── Size: 16px
    │
    └── Button Widget
        └── Text: "Submit CV"
        └── Link: /candidates/
        └── Background: White (#FFFFFF)
        └── Text Color: Navy Blue (#063970)
        └── Padding: 16px 32px
        └── Border Radius: 4px
        └── Font Weight: Semi-bold (600)
        └── Hover: Background #f0f0f0
```

#### Responsive Rules:
- **Desktop:** Text left, button right
- **Mobile:** Text and button stacked, button full-width

#### Acceptance Criteria:
- [ ] CTA strip stands out from other sections
- [ ] Button visible and accessible
- [ ] Text readable on navy background

---

### 6. Footer (Global Template)
**Template:** `WF - Footer`  
**Status:** Reusable across all pages

#### Elementor Structure:
```
Container (Full Width)
├── Background: Grey (#898989) or Navy Blue (#063970)
├── Padding: 48px (desktop) / 32px (tablet/mobile)
├── Container (Boxed - max-width 1200px, centered)
    ├── Container (Footer Content - Flexbox)
    │   ├── Direction: Row (desktop) / Column (mobile)
    │   ├── Gap: 40px
    │   │
    │   ├── Container (Column 1 - About)
    │   │   ├── Heading Widget
    │   │   │   └── Text: "TalenDelight"
    │   │   │   └── Color: White (#FFFFFF)
    │   │   │   └── Size: 18px
    │   │   │
    │   │   └── Text Editor Widget
    │   │       └── Text: "A service by Lochness Technologies"
    │   │       └── Color: White at 80% opacity
    │   │       └── Size: 14px
    │   │
    │   ├── Container (Column 2 - Navigation)
    │   │   ├── Heading Widget
    │   │   │   └── Text: "Quick Links"
    │   │   │   └── Color: White (#FFFFFF)
    │   │   │   └── Size: 16px
    │   │   │
    │   │   └── Nav Menu Widget or Text Links
    │   │       └── Employers
    │   │       └── Candidates
    │   │       └── Contact
    │   │       └── Privacy Policy
    │   │       └── Color: White at 90% opacity
    │   │       └── Hover: White 100%
    │   │
    │   └── Container (Column 3 - Contact/Social)
    │       └── [Placeholder for social links or contact info]
    │
    └── Container (Copyright - Full Width)
        └── Text Editor Widget
            └── Text: "© 2025 TalenDelight by Lochness Technologies. All rights reserved."
            └── Color: White at 70% opacity
            └── Size: 14px
            └── Alignment: Center
            └── Margin-top: 32px
            └── Border-top: 1px solid White at 20% opacity
            └── Padding-top: 24px
```

#### Responsive Rules:
- **Desktop:** 3 columns side-by-side
- **Mobile:** Stack vertically

#### Acceptance Criteria:
- [ ] All footer links functional
- [ ] Privacy Policy link present
- [ ] Copyright text correct
- [ ] Readable on dark background

---

## Global Wireframe Settings

### Color Variables (Reference)
- Primary: Navy Blue (#063970)
- Secondary: Grey (#898989)
- Background: White (#FFFFFF)
- Text on Light: Black (#000000)
- Text on Dark: White (#FFFFFF)

### Typography Scale
- H1: 48px / 36px / 28px (D/T/M)
- H2: 36px / 28px / 24px (D/T/M)
- H3: 24px / 20px / 18px (D/T/M)
- Body: 16px
- Small: 14px

### Spacing Scale (Vertical Section Padding)
- Desktop: 80px
- Tablet: 60px
- Mobile: 40px

### Button Styles
- **Primary:** White bg + Navy text (on navy sections) OR Navy bg + White text (on light sections)
- **Secondary:** Border outline, transparent bg
- Padding: 16px 32px
- Border Radius: 4px
- Font Weight: 600

### Breakpoints
- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+
- Test at: 375px (mobile), 768px (tablet), 1440px (desktop)

---

## Implementation Checklist

### Pre-Implementation
- [ ] Read [WORDPRESS-WIREFRAMES-WORKFLOW.md](../../../Documents/WORDPRESS-WIREFRAMES-WORKFLOW.md)
- [ ] Confirm Blocksy theme active
- [ ] Confirm Elementor installed and active
- [ ] Set up global color variables in Elementor (if not already done)

### Elementor Setup
- [ ] Create global header template: `WF - Header`
- [ ] Create global footer template: `WF - Footer`
- [ ] Create saved sections:
  - [ ] `WF - Hero`
  - [ ] `WF - Specialties Grid`
  - [ ] `WF - How It Works`
  - [ ] `WF - CTA Strip`

### Build Home Page
- [ ] Create new page template: `WF - Home`
- [ ] Set template to Elementor Full Width
- [ ] Add Header template
- [ ] Add Hero section (or use saved section)
- [ ] Add Specialties section (or use saved section)
- [ ] Add How It Works section (or use saved section)
- [ ] Add Candidate CTA Strip (or use saved section)
- [ ] Add Footer template
- [ ] Configure all links (CTAs point to correct pages)

### Responsive Testing
- [ ] Test at 375px (mobile) - no horizontal scroll, elements stack correctly
- [ ] Test at 768px (tablet) - layout adapts appropriately
- [ ] Test at 1440px (desktop) - content centered, proper spacing
- [ ] Verify touch targets on mobile (44x44px minimum)
- [ ] Check text readability on all backgrounds

### Content Verification
- [ ] Hero headline correct
- [ ] Hero subheadline correct
- [ ] Geographic text present and subtle
- [ ] All 4 specialty cards with correct content
- [ ] All skill tags correct per specialty
- [ ] 3 employer process steps correct
- [ ] CTA strip copy correct
- [ ] Footer links functional

### Accessibility
- [ ] Heading hierarchy correct (H1 → H2 → H3)
- [ ] Color contrast meets WCAG AA (Navy + White, Black + White)
- [ ] All buttons have readable text
- [ ] Links distinguishable from plain text

---

## Export and Version Control

### After Wireframe Complete
- [ ] Export Elementor template as JSON
  - Path: `docs/wireframes/exports/elementor-json/WF-Home__2025-12-30.json`
- [ ] Capture screenshots at 3 breakpoints
  - `docs/wireframes/exports/screenshots/Home__desktop.png` (1440px)
  - `docs/wireframes/exports/screenshots/Home__tablet.png` (768px)
  - `docs/wireframes/exports/screenshots/Home__mobile.png` (375px)
- [ ] Update this document with completion date
- [ ] Commit to Git with message: "feat(wireframe): Home page wireframe complete"

### Screenshot Tools
- Browser DevTools (responsive mode)
- Full page screenshot extensions
- Elementor preview mode for clean captures (no editor UI)

---

## Notes

- This is a wireframe, not final design - focus on structure and content over pixel-perfect polish
- Colors and spacing can be refined in production implementation
- Specialty descriptions and tags are draft content, subject to refinement
- Save reusable sections early to speed up other page builds
- Test mobile experience thoroughly - majority of traffic may be mobile

---

## Related Documentation

- [WP-01.1-home-page.md](../../features/WP-01.1-home-page.md) - Feature requirements
- [WORDPRESS-WIREFRAMES-WORKFLOW.md](../../../Documents/WORDPRESS-WIREFRAMES-WORKFLOW.md) - Wireframe process
- [WORDPRESS-UI-DESIGN.md](../../../Documents/WORDPRESS-UI-DESIGN.md) - Design system
- [WORDPRESS-PAGE-SYNC-MANIFEST.md](../../../Documents/WORDPRESS-PAGE-SYNC-MANIFEST.md) - Sync strategy

---

## Change Log

| Date | Change | Author | Notes |
|------|--------|--------|-------|
| Dec 30, 2025 | Initial wireframe spec created | System | Ready for Elementor implementation |
