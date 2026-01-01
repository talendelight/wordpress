# Page Wireframe Questionnaire Template

**Purpose:** Structured questionnaire to gather all necessary details before creating wireframe mockups and building pages in Elementor.

**When to Use:** Before starting any new page design - after feature requirements are documented, before Elementor implementation.

**Last Updated:** January 1, 2026  
**Version:** 1.0

---

## Instructions

1. **Review feature documentation** first (e.g., WP-01.2-employers-page.md)
2. **Go through each section** of this questionnaire with stakeholders
3. **Document answers** inline or in feature doc
4. **Create wireframe document** based on answers
5. **Get approval** before proceeding to Elementor implementation
6. **Update questionnaire** if new question types are discovered

---

## Section 1: Page Fundamentals

### 1.1 Page Identity
- [ ] **Page title** (appears in browser tab and admin): ___________
- [ ] **Permalink/URL slug**: ___________
- [ ] **Target audience**: ___________
- [ ] **Primary goal/conversion**: ___________
- [ ] **Public or authenticated** page?: ___________

### 1.2 Access & Navigation
- [ ] **Login required?** Yes / No
- [ ] **Linked from header navigation?** Yes / No
- [ ] **Linked from homepage?** Which CTA/section: ___________
- [ ] **Linked from other pages?** List: ___________
- [ ] **Should appear in footer?** Yes / No

---

## Section 2: Page Structure & Sections

### 2.1 Overall Layout
- [ ] **How many major sections?** ___________
- [ ] **Full-width or contained?** ___________
- [ ] **Sidebar needed?** Yes / No

### 2.2 Section Inventory
For each section, document:

**Section [Number]: [Name]**
- **Purpose**: (What does this section communicate/achieve?)
- **Background**: (Color, image, pattern, or transparent?)
- **Width**: (Full-width, contained, narrow)
- **Content type**: (Text only, text+image, grid of cards, form, etc.)
- **Priority**: (Must-have, Should-have, Nice-to-have)

Example:
- **Section 1: Hero**
  - Purpose: Grab attention, communicate value proposition, drive primary CTA
  - Background: Navy #063970 solid color
  - Width: Full-width with contained content (max 1200px)
  - Content type: Heading + subheading + buttons
  - Priority: Must-have

---

## Section 3: Content Details (Per Section)

### 3.1 Hero Section (if applicable)
- [ ] **Headline (H1)**: "___________"
- [ ] **Subheading**: "___________"
- [ ] **Background color/image**: ___________
- [ ] **CTA button(s)**:
  - Button 1 text: "___________"
  - Button 1 destination: ___________
  - Button 1 style: Type 1 / Type 2 / Custom
  - Button 2 text (if any): "___________"
  - Button 2 destination: ___________
  - Button 2 style: Type 1 / Type 2 / Custom
- [ ] **Image/visual needed?**: Yes / No
  - If yes, describe: ___________

### 3.2 Process/Steps Section (if applicable)
- [ ] **Section heading (H2)**: "___________"
- [ ] **Subheading/intro text**: "___________"
- [ ] **Number of steps**: ___________
- [ ] **Layout**: Horizontal row / Vertical stack / Grid
- [ ] **Step format**: Icon + title + text / Numbered boxes / Cards

For each step:
- **Step [N] Title**: "___________"
- **Step [N] Description**: "___________"
- **Icon needed?**: Yes / No (if yes, describe: ___________)

### 3.3 Grid/Cards Section (if applicable)
Examples: Specialties, Features, Benefits, Services

- [ ] **Section heading (H2)**: "___________"
- [ ] **Subheading/intro text**: "___________"
- [ ] **Number of cards/items**: ___________
- [ ] **Layout**: 2 columns / 3 columns / 4 columns / 2x2 grid / Custom
- [ ] **Card style**: Icon box / Text only / Image + text / Custom
- [ ] **All cards same size?**: Yes / No
- [ ] **Any special card** (e.g., CTA card, catch-all): Describe: ___________

For each card:
- **Card [N] Title**: "___________"
- **Card [N] Content**: (Bullet points, paragraph, link?)
- **Icon needed?**: Yes / No (if yes, describe: ___________)
- **Link/CTA?**: Yes / No (destination: ___________)

### 3.4 Form Section (if applicable)
- [ ] **Form purpose**: (Contact, submission, signup, etc.)
- [ ] **Form heading**: "___________"
- [ ] **Form location**: Embedded on page / Modal popup / Separate page link
- [ ] **Fields needed**: List all
- [ ] **Submit button text**: "___________"
- [ ] **Required plugin**: (WPForms, Gravity Forms, custom, etc.)
- [ ] **Submission destination**: (Email, database, both)

### 3.5 Final CTA Section (if applicable)
- [ ] **Section heading (H2)**: "___________"
- [ ] **Subheading/supporting text**: "___________"
- [ ] **Background**: (Color, image, or transparent)
- [ ] **CTA button(s)**:
  - Button 1 text: "___________"
  - Button 1 destination: ___________
  - Button 1 style: Type 1 / Type 2
  - Button 2 text (if any): "___________"
  - Button 2 destination: ___________

---

## Section 4: Visual Design & Styling

### 4.1 Color Scheme
- [ ] **Primary section backgrounds**: Navy #063970 / White #FFFFFF / Grey / Other: ___________
- [ ] **Accent colors**: Blue #3498DB / Other: ___________
- [ ] **Text colors**: Navy (headings) / Grey #898989 (body) / Custom: ___________
- [ ] **Special color needs**: ___________

### 4.2 Typography
- [ ] **Heading sizes**: Default / Custom (specify: ___________)
- [ ] **Font weights**: Default / Custom (specify: ___________)
- [ ] **Text alignment**: Left / Center / Mixed
- [ ] **Special typography needs**: ___________

### 4.3 Spacing & Layout
- [ ] **Section padding** (vertical space between sections): Default (80px desktop) / Custom: ___________
- [ ] **Content width**: Default (1200px max) / Custom: ___________
- [ ] **Element spacing**: Default / Tight / Loose / Custom: ___________
- [ ] **Special spacing needs**: ___________

### 4.4 Visual Elements
- [ ] **Icons needed?**: Yes / No
  - If yes, style: Line icons / Filled / Custom / Library: ___________
- [ ] **Images needed?**: Yes / No
  - If yes, list: ___________
- [ ] **Background patterns/textures?**: Yes / No
- [ ] **Decorative elements**: (Lines, shapes, gradients?) ___________

---

## Section 5: Responsive Design

### 5.1 Desktop Layout (>1024px)
- [ ] **Grid columns for cards/items**: ___________
- [ ] **Special desktop-only features**: ___________

### 5.2 Tablet Layout (768px-1024px)
- [ ] **Grid columns adjust to**: ___________
- [ ] **Layout changes**: (Describe if different from desktop)
- [ ] **Hide/show elements**: ___________

### 5.3 Mobile Layout (<768px)
- [ ] **Stack all sections vertically?**: Yes / No
- [ ] **Single column for all cards?**: Yes / No / Keep 2 columns
- [ ] **Button sizes adjusted?**: Yes / No
- [ ] **Font sizes reduced?**: Yes / No
- [ ] **Hide/show elements**: ___________
- [ ] **Mobile-specific considerations**: ___________

---

## Section 6: Interactive Elements

### 6.1 Buttons
For each button on the page:
- **Button [N] Label**: "___________"
- **Button [N] Style**: Type 1 (50px radius, shadow) / Type 2 (5px radius, blue bg)
- **Button [N] Destination**: URL or anchor: ___________
- **Button [N] Behavior**: Same tab / New tab / Anchor scroll
- **Hover effects**: Default / Custom (describe: ___________)

### 6.2 Links
- [ ] **Internal page links**: List: ___________
- [ ] **External links**: List (with "open in new tab" preference): ___________
- [ ] **Anchor links** (scroll to section): List: ___________
- [ ] **Link styling**: Underline / Color change / Both / Custom: ___________

### 6.3 Animations (Optional)
- [ ] **Fade-in on scroll?**: Yes / No
- [ ] **Other animations**: Describe: ___________
- [ ] **Animation timing**: Fast / Medium / Slow

---

## Section 7: SEO & Metadata

### 7.1 SEO Basics
- [ ] **Page title** (for search results): "___________"
- [ ] **Meta description**: "___________"
- [ ] **Focus keyword**: "___________"
- [ ] **Alt text strategy**: (For images/icons)

### 7.2 Schema Markup (Future)
- [ ] **Schema type needed**: (Organization, Service, Article, etc.)
- [ ] **Priority**: Low / Medium / High

---

## Section 8: Technical Requirements

### 8.1 Plugins/Dependencies
- [ ] **Required plugins**: (List any needed plugins)
- [ ] **Third-party integrations**: (Forms, analytics, etc.)
- [ ] **Custom code needed?**: Yes / No (describe: ___________)

### 8.2 Performance
- [ ] **Image optimization**: Required / Optional
- [ ] **Lazy loading**: Yes / No
- [ ] **Performance target**: Lighthouse score > ___________
- [ ] **Load time target**: < ___________ seconds

### 8.3 Accessibility
- [ ] **Heading hierarchy correct**: (H1 → H2 → H3)
- [ ] **Alt text for all images**: Yes
- [ ] **Keyboard navigation**: Required / Optional
- [ ] **Screen reader considerations**: ___________

---

## Section 9: Content Source & Assets

### 9.1 Content Status
- [ ] **All copy finalized?**: Yes / No
- [ ] **Copy source**: Feature doc / Separate doc / TBD
- [ ] **Copy approval**: Approved / Pending / In progress

### 9.2 Assets Checklist
- [ ] **Icons**: Source: ___________ / Ready: Yes / No
- [ ] **Images**: List needed: ___________ / Ready: Yes / No
- [ ] **Logo/brand assets**: Ready: Yes / No
- [ ] **Custom graphics**: Describe: ___________ / Ready: Yes / No

---

## Section 10: Testing & Validation

### 10.1 Test Cases
- [ ] **Desktop browsers to test**: Chrome, Firefox, Safari, Edge
- [ ] **Mobile devices to test**: iPhone (375px), Android (360px), Tablet (768px)
- [ ] **Specific interactions to test**: List: ___________
- [ ] **Cross-browser issues expected?**: Yes / No (describe: ___________)

### 10.2 Validation Criteria
- [ ] **Does page match wireframe?**: Yes / No
- [ ] **All content present?**: Yes / No
- [ ] **All buttons work?**: Yes / No
- [ ] **Mobile responsive?**: Yes / No
- [ ] **No console errors?**: Yes / No
- [ ] **Performance acceptable?**: Yes / No

---

## Section 11: Post-Build Checklist

- [ ] **Wireframe document created and approved**
- [ ] **All questions answered**
- [ ] **Assets prepared and available**
- [ ] **Page built in Elementor**
- [ ] **Content populated**
- [ ] **Responsive design tested**
- [ ] **Cross-browser tested**
- [ ] **SEO metadata added**
- [ ] **Stakeholder review completed**
- [ ] **Feedback incorporated**
- [ ] **Ready for deployment**

---

## Notes & Special Considerations

**Page-Specific Notes:**
(Add any unique requirements, constraints, or considerations for this specific page)

**Lessons Learned:**
(After page completion, add any insights for future pages)

**Updated Questions:**
(If new question types discovered during this page, add them here and update template)

---

## Questionnaire History

| Date | Page | Questions Added | Notes |
|------|------|-----------------|-------|
| Jan 1, 2026 | Template Created | Initial 11 sections | Based on homepage learnings |
| | | | |

---

**Template Version:** 1.0  
**Next Review:** After completing 3-5 pages using this template
