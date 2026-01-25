# TalenDelight Design System

**Version:** 1.0.0  
**Last Updated:** January 22, 2026  
**Status:** Draft - Extracted from Design Audit

---

## Color System

### Section Background Pattern

**Core Rule:** Sections use only two background colors:
- **White (#FFFFFF)** - All content sections
- **Navy (#063970)** - Hero and CTA sections only

**Container Pattern Within Sections:**
- Containers inside white sections can use **#ECECEC** background for visual alternation
- This creates visual rhythm without breaking section consistency
- Example: Compliance footer section has white background, but the container inside has #ECECEC

**Structure:**
```html
<section style="background: #FFFFFF">
  <container style="background: #ECECEC">  <!-- Alternating container -->
    Content here
  </container>
</section>
```

### Primary Colors

```css
/* Navy - Primary Brand Color */
--color-navy: #063970;
/* Use for: Hero backgrounds, primary headings, button backgrounds */

/* Blue - Accent Color */
--color-blue: #3498DB;
/* Use for: Icons, hover states, focus effects, shadows */

/* White */
--color-white: #FFFFFF;
/* Use for: Text on dark backgrounds, button backgrounds, section backgrounds */
```

### Neutral Colors

```css
/* Dark Gray - Primary Body Text */
--color-gray-dark: #333333;
/* Use for: Primary body text, form labels, readable content */

/* Medium Gray - Secondary Text */
--color-gray-medium: #898989;
/* Use for: Descriptions, icon box text, secondary information, disabled states */

/* Light Gray - Backgrounds & Borders */
--color-gray-light: #ECECEC;
/* Use for: Section backgrounds, footer backgrounds, borders, dividers */

/* Off-White - Alternate Backgrounds */
--color-gray-off-white: #F8F9FA;
/* Use for: Alternate section backgrounds, cards */
```

### Semantic Colors

```css
/* Error/Danger */
--color-danger: #DC3545;
/* Use for: Error messages, required field indicators, destructive actions */

/* Success */
--color-success: #28a745;
/* Use for: Success messages, confirmation states */

/* Warning */
--color-warning: #FFC107;
/* Use for: Warning messages, caution states */

/* Info */
--color-info: #17A2B8;
/* Use for: Informational messages, tips */
```

### Usage Guidelines

**Body Text:**
- Use `--color-gray-dark` (#333333) for primary body text, form labels, readable paragraphs
- Use `--color-gray-medium` (#898989) for secondary text like descriptions, captions, icon box descriptions

**Backgrounds:**
- Hero sections: `--color-navy` with white text
- CTA sections: `--color-navy` with white text
- Content sections: `--color-white` or `--color-gray-off-white`
- Footer sections: `--color-gray-light`

**Buttons:**
- Primary CTA: White background, navy text (inverted on navy backgrounds)
- Secondary: Navy background, white text
- Tertiary: Blue background, white text (for less prominent actions)

---

## Typography

### Font Families

```css
/* Primary Font Stack (Blocksy Theme Default) */
--font-family-primary: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;

/* Fallback for Headings */
--font-family-headings: inherit;
```

**Note:** Font family extracted from standard WordPress/Blocksy defaults. Verify actual font in production.

### Heading Scale

```css
/* H1 - Page Title / Hero Heading */
--font-size-h1: 48px;
--font-weight-h1: 700;
--line-height-h1: 1.2;
--color-h1: var(--color-navy); /* or white on dark backgrounds */

/* H2 - Section Heading */
--font-size-h2: 32px;
--font-weight-h2: 700;
--line-height-h2: 1.3;
--color-h2: var(--color-navy);

/* H3 - Subsection Heading / Card Title */
--font-size-h3: 24px;
--font-weight-h3: 700;
--line-height-h3: 1.4;
--color-h3: var(--color-navy);

/* H4 - Small Heading */
--font-size-h4: 20px;
--font-weight-h4: 600;
--line-height-h4: 1.4;
--color-h4: var(--color-navy);

/* H5 - Tiny Heading */
--font-size-h5: 18px;
--font-weight-h5: 600;
--line-height-h5: 1.5;
--color-h5: var(--color-navy);

/* H6 - Minimal Heading */
--font-size-h6: 16px;
--font-weight-h6: 600;
--line-height-h6: 1.5;
--color-h6: var(--color-navy);
```

### Body Text

```css
/* Body Text - Large */
--font-size-body-large: 18px;
--font-weight-body-large: 400;
--line-height-body-large: 1.6;
--color-body-large: var(--color-gray-dark);

/* Body Text - Regular (Default) */
--font-size-body: 16px;
--font-weight-body: 400;
--line-height-body: 1.6;
--color-body: var(--color-gray-dark);

/* Body Text - Small */
--font-size-body-small: 14px;
--font-weight-body-small: 400;
--line-height-body-small: 1.5;
--color-body-small: var(--color-gray-medium);
```

### Font Weights

```css
--font-weight-regular: 400;
--font-weight-medium: 500;
--font-weight-semibold: 600;
--font-weight-bold: 700;
```

---

## Spacing System

### Section Spacing (Vertical)

```css
/* Primary Section Padding */
--spacing-section-large: 80px;
/* Use for: Hero sections, CTA sections, major content sections */

/* Secondary Section Padding */
--spacing-section-medium: 60px;
/* Use for: Content sections with less visual weight */

/* Minimal Section Padding */
--spacing-section-small: 20px;
/* Use for: Compact sections, inner containers */
```

### Container Spacing (Horizontal)

```css
/* Standard Container Padding */
--spacing-container-x: 20px;
/* Use for: Left/right padding on containers */

/* Wide Container Max-Width */
--container-max-width: 1200px;
/* Use for: Centered content containers */
```

### Element Spacing

```css
/* Extra Large Spacing */
--spacing-xl: 40px;
/* Use for: Between major sections */

/* Large Spacing */
--spacing-lg: 30px;
/* Use for: Between icon list items, feature cards */

/* Medium Spacing */
--spacing-md: 20px;
/* Use for: Between form fields, content blocks */

/* Small Spacing */
--spacing-sm: 12px;
/* Use for: Between labels and inputs, icon and text */

/* Extra Small Spacing */
--spacing-xs: 8px;
/* Use for: Label margin-bottom, tight spacing */
```

### Grid Gaps

```css
/* Grid Gap - Cards/Features */
--grid-gap: 30px;
/* Use for: Feature grids, icon box grids */

/* Grid Gap - Compact */
--grid-gap-small: 20px;
/* Use for: Tighter layouts */
```

---

## Button System

### Primary Button (CTA)

**Usage:** Main call-to-action buttons (Register, Get Started, Login)

```css
.btn-primary {
  background-color: var(--color-white);
  color: var(--color-navy);
  font-size: 16px;
  font-weight: 400;
  padding: 12px 32px;
  border-radius: 50px; /* Pill shape */
  border: none;
  box-shadow: 0 0 10px 0 var(--color-blue); /* Blue glow */
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-block;
  text-align: center;
}

.btn-primary:hover {
  background-color: var(--color-gray-off-white);
  box-shadow: 0 0 15px 0 var(--color-blue); /* Stronger glow */
  transform: translateY(-2px);
}

.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 0 8px 0 var(--color-blue);
}
```

### Secondary Button

**Usage:** Less prominent actions (Cancel, Back, View More)

```css
.btn-secondary {
  background-color: var(--color-navy);
  color: var(--color-white);
  font-size: 16px;
  font-weight: 400;
  padding: 12px 32px;
  border-radius: 50px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-block;
  text-align: center;
}

.btn-secondary:hover {
  background-color: #084A8D; /* Lighter navy */
  transform: translateY(-2px);
}

.btn-secondary:active {
  transform: translateY(0);
}
```

### Tertiary Button

**Usage:** Subtle actions (Links styled as buttons)

```css
.btn-tertiary {
  background-color: transparent;
  color: var(--color-blue);
  font-size: 16px;
  font-weight: 400;
  padding: 12px 32px;
  border-radius: 50px;
  border: 2px solid var(--color-blue);
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-block;
  text-align: center;
}

.btn-tertiary:hover {
  background-color: var(--color-blue);
  color: var(--color-white);
  transform: translateY(-2px);
}

.btn-tertiary:active {
  transform: translateY(0);
}
```

### Button Sizes

```css
/* Small Button */
.btn-sm {
  font-size: 14px;
  padding: 8px 24px;
}

/* Medium Button (Default) */
.btn-md {
  font-size: 16px;
  padding: 12px 32px;
}

/* Large Button */
.btn-lg {
  font-size: 18px;
  padding: 16px 40px;
}
```

---

## Form System

### Input Fields

```css
.form-input {
  width: 100%;
  height: 45px;
  padding: 12px 16px;
  font-size: 16px;
  font-weight: 400;
  color: var(--color-gray-dark);
  background-color: var(--color-white);
  border: 1px solid var(--color-gray-light);
  border-radius: 4px;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

.form-input:focus {
  outline: none;
  border-color: var(--color-blue);
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-input:disabled {
  background-color: var(--color-gray-off-white);
  color: var(--color-gray-medium);
  cursor: not-allowed;
}

.form-input.error {
  border-color: var(--color-danger);
}

.form-input.error:focus {
  box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1);
}
```

### Labels

```css
.form-label {
  display: block;
  font-size: 16px;
  font-weight: 400;
  color: var(--color-gray-dark);
  margin-bottom: 8px;
  line-height: 1.5;
}

.form-label.required::after {
  content: " *";
  color: var(--color-danger);
}
```

### Checkboxes & Radio Buttons

```css
.form-checkbox,
.form-radio {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.form-checkbox input[type="checkbox"],
.form-radio input[type="radio"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.form-checkbox-label,
.form-radio-label {
  font-size: 16px;
  font-weight: 400;
  color: var(--color-gray-dark);
  cursor: pointer;
}
```

### Error Messages

```css
.form-error {
  display: block;
  font-size: 14px;
  font-weight: 400;
  color: var(--color-danger);
  margin-top: 4px;
  line-height: 1.4;
}
```

### Success Messages

```css
.form-success {
  display: block;
  font-size: 14px;
  font-weight: 400;
  color: var(--color-success);
  margin-top: 4px;
  line-height: 1.4;
}
```

---

## Icon System

### Icon Sizes

```css
/* Large Icons (Hero, Features) */
--icon-size-lg: 48px;

/* Medium Icons (UI, Footer) */
--icon-size-md: 24px;

/* Small Icons (Inline) */
--icon-size-sm: 16px;
```

### Icon Colors

```css
/* Primary Icon Color */
--icon-color-primary: var(--color-blue);
/* Use for: Feature icons, accent icons */

/* Secondary Icon Color */
--icon-color-secondary: var(--color-gray-medium);
/* Use for: UI icons, navigation icons */

/* On Dark Backgrounds */
--icon-color-light: var(--color-white);
/* Use for: Icons on navy/dark backgrounds */
```

### Icon Box Pattern

**Usage:** Feature cards, service listings, "How it Works" sections, "Our Specialties" grids

**Standard Specifications:**

| Element | Size | Weight | Color | Notes |
|---------|------|--------|-------|-------|
| Icon | 48px | - | #3498DB (Blue) | FontAwesome icons |
| Title | 24px | 700 | #063970 (Navy) | H3 equivalent |
| Description | 16px | 400 | #898989 (Gray) | Body text |

**Elementor Implementation:**

1. **Icon Settings:**
   - Style tab → Icon → Icon Size: **48px**
   - Style tab → Icon → Primary Color: **#3498DB**

2. **Title Settings:**
   - Style tab → Title → Typography: **Custom**
   - Font Size: **24px** (desktop and mobile)
   - Font Weight: **700**
   - Color: **#063970**

3. **Description Settings:**
   - Style tab → Description → Typography: **Custom**
   - Font Size: **16px**
   - Font Weight: **400**
   - Color: **#898989**

**HTML Structure:**

```html
<div class="icon-box">
  <div class="icon-box-icon">
    <i class="fas fa-cloud"></i>
  </div>
  <h3 class="icon-box-title">Cloud Backend</h3>
  <p class="icon-box-description">Build robust, scalable cloud-native backend systems...</p>
</div>
```

**CSS Implementation:**

```css
.icon-box {
  text-align: center;
  padding: var(--spacing-md);
}

.icon-box-icon {
  font-size: 48px; /* Standard icon size */
  color: var(--icon-color-primary); /* #3498DB */
  margin-bottom: var(--spacing-md);
}

.icon-box-title {
  font-size: 24px; /* H3-equivalent size */
  font-weight: 700; /* Bold */
  color: var(--color-navy); /* #063970 */
  margin-bottom: var(--spacing-xs);
}

.icon-box-description {
  font-size: 16px; /* Body text size */
  font-weight: 400; /* Regular */
  color: var(--color-gray-medium); /* #898989 */
  line-height: var(--line-height-body);
}
```

**Common Patterns:**
- "How it Works" sections: 3 icon boxes in a row (33.33% width each)
- "Our Specialties" sections: 3 or 4 icon boxes, plus optional standalone "Something else?" box
- "Why we are..." sections: 4 icon boxes in 2x2 grid (50% width each)

---

## Layout Components

### Hero Section

**Usage:** Landing page top section with H1, subheading, and CTA

```html
<section class="hero">
  <div class="hero-container">
    <h1 class="hero-title">Talent for today. Growth for tomorrow.</h1>
    <h3 class="hero-subtitle">Your trusted partner for permanent and contract IT & Tech placements...</h3>
    <a href="/log-in/" class="btn btn-primary">Get Started</a>
  </div>
</section>
```

```css
.hero {
  background-color: var(--color-navy);
  padding: var(--spacing-section-large) var(--spacing-container-x);
  text-align: center;
}

.hero-container {
  max-width: var(--container-max-width);
  margin: 0 auto;
}

.hero-title {
  font-size: var(--font-size-h1);
  font-weight: var(--font-weight-h1);
  color: var(--color-white);
  margin-bottom: var(--spacing-md);
  line-height: var(--line-height-h1);
}

.hero-subtitle {
  font-size: var(--font-size-body);
  font-weight: var(--font-weight-body);
  color: var(--color-white);
  margin-bottom: var(--spacing-lg);
  line-height: var(--line-height-body);
}
```

### CTA Section

**Usage:** Call-to-action sections mid-page or at bottom

```html
<section class="cta">
  <div class="cta-container">
    <h2 class="cta-title">Ready to get started?</h2>
    <p class="cta-text">Take the next step toward your goals.</p>
    <a href="/log-in/" class="btn btn-primary">Get Started</a>
  </div>
</section>
```

```css
.cta {
  background-color: var(--color-navy);
  padding: var(--spacing-section-large) var(--spacing-container-x);
  text-align: center;
}

.cta-container {
  max-width: var(--container-max-width);
  margin: 0 auto;
}

.cta-title {
  font-size: var(--font-size-h1);
  font-weight: var(--font-weight-h1);
  color: var(--color-white);
  margin-bottom: var(--spacing-sm);
  line-height: var(--line-height-h1);
}

.cta-text {
  font-size: var(--font-size-body);
  font-weight: var(--font-weight-body);
  color: var(--color-white);
  margin-bottom: var(--spacing-lg);
  line-height: var(--line-height-body);
}
```

### Compliance Footer

**Usage:** Trust badges, GDPR notice, footer links

**Structure:** Section has white background, container inside has #ECECEC

```html
<section class="compliance-footer-section">  <!-- White background -->
  <div class="compliance-footer-container">  <!-- #ECECEC background -->
    <ul class="compliance-list">
    <li class="compliance-item">
      <i class="fas fa-check-circle"></i>
      <span>GDPR Compliant</span>
    </li>
    <li class="compliance-item">
      <i class="fas fa-lock"></i>
      <span>Secure & Reliable</span>
    </li>
    <!-- More items -->
  </ul>
</footer>
```

```css
.compliance-footer-section {
  background-color: var(--color-white);  /* Section is white */
  padding: 0;
}

.compliance-footer-container {
  background-color: var(--color-gray-light);  /* Container is #ECECEC */
  padding: var(--spacing-md) var(--spacing-container-x);
  text-align: center;
}

.compliance-list {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 60px;  /* Increased for better mobile wrapping spacing */
  list-style: none;
  padding: 0;
  margin: 0;
  flex-wrap: wrap;
}

.compliance-item {
  display: flex;
  align-items: center;
  gap: 5px;  /* Space between icon and text */
  font-size: var(--font-size-body);
  color: var(--color-gray-medium);
}

.compliance-item i {
  font-size: var(--icon-size-md);  /* 24px */
  color: var(--icon-color-primary);
  vertical-align: middle;  /* Center alignment with text */
}
```

---

## Responsive Design

### Breakpoints

```css
/* Mobile First Approach */

/* Small Devices (Mobile) */
--breakpoint-sm: 576px;

/* Medium Devices (Tablet) */
--breakpoint-md: 768px;

/* Large Devices (Desktop) */
--breakpoint-lg: 1024px;

/* Extra Large Devices (Wide Desktop) */
--breakpoint-xl: 1200px;
```

### Responsive Typography

**Elementor Implementation (Manual Configuration Required):**

Elementor uses device-specific breakpoints:
- **Desktop**: 1025px and above
- **Tablet**: 768px - 1024px  
- **Mobile**: 767px and below

**Font Size Standards:**

| Element | Desktop | Mobile | Elementor Setting |
|---------|---------|--------|-------------------|
| Hero H1 | 48px | 42px | Typography → Click mobile icon → 42px |
| CTA Title | 48px | 42px | Typography → Click mobile icon → 42px |
| Section Titles (H2) | 32px | 32px | Keep same (no mobile override) |
| Icon Box Titles | 24px | 24px | Keep same for consistency |
| Body Text | 16px | 16px | Keep same (standard web size) |

**CSS Variables (for custom development):**

```css
/* Mobile (< 768px) */
@media (max-width: 767px) {
  :root {
    --font-size-h1: 42px; /* Hero and CTA titles */
    --font-size-h2: 32px; /* Section titles - unchanged */
    --font-size-h3: 24px; /* Icon box titles - unchanged */
    --font-size-body: 16px; /* Body text - unchanged */
  }
  
  .icon-box {
    width: 100%; /* Stack icon boxes on mobile */
  }
}

/* Tablet (768px - 1023px) */
@media (min-width: 768px) and (max-width: 1023px) {
  :root {
    --font-size-h1: 45px; /* Slightly reduced from 48px */
    --font-size-h2: 30px; /* Slightly reduced from 32px */
  }
}
```

### Responsive Spacing & Padding

**Section Padding Standards:**

| Section Type | Desktop Top/Bottom | Desktop Left/Right | Mobile All Sides |
|--------------|-------------------|-------------------|------------------|
| Hero Outer | 0px | 0px | 0px |
| Hero Inner (Navy) | 80px | 20px | 80px top/bottom, 20px sides |
| Content Sections | 80px | 80px | 20px all sides |
| CTA Outer | 20px | 20px | 20px all sides |
| CTA Inner (Navy) | 80px | 80px | 80px all sides (no mobile override) |

**Section Structure Patterns:**

```
Hero Section Structure:
  Outer container: 0px all sides → Inner navy extends to viewport edges
  Inner navy container: 80px vertical, 20px horizontal
  
CTA Section Structure:
  Outer container: 20px all sides → Provides breathing room from edges
  Inner navy container: 80px all sides → Content has generous internal padding
  
Content Sections:
  Desktop: 80px all sides → Generous spacing
  Mobile: 20px all sides → Maximizes viewport usage
```

**Elementor Implementation:**

1. **Desktop Padding Setup:**
   - Hero outer: 0px all sides (navy extends to edges)
   - CTA outer: 20px all sides (breathing room from edges)
   - Content sections: 80px all sides
   
2. **Mobile Padding Override:**
   - Click mobile icon (📱) next to Padding
   - Content sections: Change to 20px all sides
   - CTA outer: Already 20px (no override needed)
   - Hero/CTA inner: No mobile override needed

**Why This Matters:**
- Desktop: 80px vertical spacing provides breathing room, 0px horizontal allows full-width navy sections
- Mobile (320-414px viewports): 80px padding is too large, reduces content area by 160px
- Solution: 20px mobile padding leaves comfortable space while maximizing content area
```

---

## Shadows & Effects

### Box Shadows

```css
/* Button Glow (Primary CTA) */
--shadow-button-glow: 0 0 10px 0 var(--color-blue);
--shadow-button-glow-hover: 0 0 15px 0 var(--color-blue);

/* Card Shadow (Subtle Elevation) */
--shadow-card: 0 2px 8px rgba(0, 0, 0, 0.1);
--shadow-card-hover: 0 4px 16px rgba(0, 0, 0, 0.15);

/* Focus Ring (Inputs) */
--shadow-focus-blue: 0 0 0 3px rgba(52, 152, 219, 0.1);
--shadow-focus-danger: 0 0 0 3px rgba(220, 53, 69, 0.1);
```

### Transitions

```css
/* Standard Transition */
--transition-standard: all 0.3s ease;

/* Fast Transition */
--transition-fast: all 0.2s ease;

/* Slow Transition */
--transition-slow: all 0.4s ease;
```

---

## Usage Guidelines

### When to Use Primary Navy (#063970)
- Hero section backgrounds
- CTA section backgrounds
- Primary headings (H1, H2, H3) on light backgrounds
- Button backgrounds (secondary buttons)
- Important UI elements that need emphasis

### When to Use Accent Blue (#3498DB)
- Icons (especially in icon boxes, compliance footer)
- Hover states for buttons and links
- Focus states for form inputs
- Box shadows (button glows)
- Accent elements (badges, highlights)

### When to Use White (#FFFFFF)
- Text on dark backgrounds (navy sections)
- Primary button backgrounds (inverted on navy)
- **Section backgrounds (main content areas)** - ALL content sections use white
- Card backgrounds

**Important:** Content sections should have white backgrounds. Use #ECECEC only for containers within white sections to create visual rhythm.

### When to Use Dark Gray (#333333)
- Primary body text (paragraphs, form labels)
- Content that needs high readability
- Default text color for most UI elements

### When to Use Medium Gray (#898989)
- Secondary text (descriptions, captions, icon box descriptions)
- Placeholder text
- Disabled state text
- Less important information

### When to Use Light Gray (#ECECEC)
- **Container backgrounds within white sections** (creates alternating visual rhythm)
- Compliance footer container (inside white section)
- Borders and dividers
- Disabled state backgrounds

**Rule:** #ECECEC is for containers, NOT for section backgrounds. Sections remain white (#FFFFFF) or navy (#063970).

---

## Implementation Notes

### CSS Custom Properties Setup

Add this to your main CSS file (e.g., `config/custom-css/design-system.css`):

```css
:root {
  /* Colors */
  --color-navy: #063970;
  --color-blue: #3498DB;
  --color-white: #FFFFFF;
  --color-gray-dark: #333333;
  --color-gray-medium: #898989;
  --color-gray-light: #ECECEC;
  --color-gray-off-white: #F8F9FA;
  --color-danger: #DC3545;
  --color-success: #28a745;
  
  /* Typography */
  --font-size-h1: 48px;
  --font-size-h2: 32px;
  --font-size-h3: 24px;
  --font-size-body: 16px;
  --font-weight-regular: 400;
  --font-weight-bold: 700;
  
  /* Spacing */
  --spacing-section-large: 80px;
  --spacing-container-x: 20px;
  --spacing-lg: 30px;
  --spacing-md: 20px;
  --spacing-sm: 12px;
  --spacing-xs: 8px;
  
  /* Icons */
  --icon-size-lg: 48px;
  --icon-size-md: 24px;
  --icon-size-sm: 16px;
  
  /* Shadows */
  --shadow-button-glow: 0 0 10px 0 var(--color-blue);
  
  /* Transitions */
  --transition-standard: all 0.3s ease;
}
```

### Elementor Global Colors Setup

1. Go to **Elementor → Custom Colors** (or Theme Builder → Global Colors)
2. Add these colors:
   - **Primary Navy:** `#063970`
   - **Accent Blue:** `#3498DB`
   - **Gray Dark:** `#333333`
   - **Gray Medium:** `#898989`
   - **Gray Light:** `#ECECEC`

3. Use global colors in all Elementor pages for consistency

### Forminator Forms Integration

Apply design system to Forminator forms via `config/custom-css/forminator-forms.css`:

```css
/* Use design system variables */
.forminator-custom-form .forminator-label {
  color: var(--color-gray-dark) !important;
  font-size: var(--font-size-body) !important;
  font-weight: var(--font-weight-regular) !important;
  margin-bottom: var(--spacing-xs) !important;
}

.forminator-custom-form input[type="text"],
.forminator-custom-form input[type="email"],
.forminator-custom-form select {
  border-color: var(--color-gray-light) !important;
}

.forminator-custom-form input:focus,
.forminator-custom-form select:focus {
  border-color: var(--color-blue) !important;
  box-shadow: var(--shadow-focus-blue) !important;
}
```

---

## Changelog

### Version 1.0.0 (January 22, 2026)
- Initial design system extracted from automated audit
- Defined color palette (primary, neutral, semantic)
- **Clarified background color usage:** Sections use white/navy only, containers can use #ECECEC
- Established typography scale (H1-H6, body text)
- Documented spacing system (section, container, element)
- Created button system (primary, secondary, tertiary)
- Defined form system (inputs, labels, error states)
- Documented icon patterns (sizes, colors, icon boxes)
- Created layout components (hero, CTA, compliance footer)
- **Added mobile responsive guidelines:** Font sizes (42px mobile for Hero/CTA H1), spacing (20px mobile padding)
- **Fixed Hero/CTA width consistency:** CTA outer section 0px horizontal padding to match Hero width
- Defined shadows, effects, and transitions
- Added usage guidelines and implementation notes
- **Verified compliance:** Homepage, Employers, and Candidates pages audited and compliant

---

## Implementation Status

### Completed Pages (January 22, 2026)
- ✅ **Homepage (Welcome)** - ID 20 - All design standards applied
  - Hero H1 mobile: 42px ✓
  - CTA title mobile: 42px ✓
  - CTA outer padding: 20px all sides ✓
  - All 4 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓
  
- ✅ **Employers** - ID 93 - All design standards applied
  - Hero H1 mobile: 42px ✓
  - CTA title mobile: 42px ✓
  - CTA outer padding: 20px all sides ✓
  - All 7 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **Candidates** - ID 229 - All design standards applied
  - Hero H1 mobile: 42px ✓
  - CTA title mobile: 42px ✓
  - CTA outer padding: 20px all sides ✓
  - All 8 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓
  - Section backgrounds: White/Navy pattern ✓

- ✅ **Scouts** - ID 248 - All design standards applied (January 22, 2026)
  - Hero H1 mobile: 42px ✓
  - CTA title mobile: 42px ✓
  - CTA outer padding: 20px all sides ✓
  - All 10 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **Operators Dashboard** - ID 299 - All design standards applied (January 22, 2026)
  - Hero H1 mobile: 42px ✓
  - All 5 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **Managers Dashboard** - ID 469 - All design standards applied (January 22, 2026)
  - Hero H1 mobile: 42px ✓
  - All 9 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **Manager Admin** - ID 386 - All design standards applied (January 22, 2026)
  - Hero H1 mobile: 42px ✓
  - All 6 icon boxes: 48px/24px/700/16px ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **403 Forbidden** - ID 152 - All design standards applied (January 22, 2026)
  - Hero H1 mobile: 42px ✓
  - Icon boxes: None on page ✓
  - Footer compliance: Mobile spacing 60px ✓

- ✅ **Register Profile** - ID 365 - All design standards applied (January 23, 2026)
  - Hero H1 mobile: 42px ✓
  - Icon boxes: None on page ✓
  - Footer compliance: Mobile spacing 60px ✓

### Non-Elementor Pages
- **Select Role** - ID 379 - Uses custom PHP template (`page-role-selection.php`)
  - Not built with Elementor - uses hardcoded HTML/CSS in template file
  - Active in registration flow: /register/ → /select-role/ → /register-profile/

---

## Audit Complete

**All 10 Elementor-built pages audited and compliant** (January 23, 2026)

---

## Next Actions

1. **Page Audits:** Complete design audit for remaining 9 pages
2. **Mobile Fixes:** Apply responsive typography and padding to all pages
3. **Elementor Setup:** Configure Elementor global colors and styles
4. **Template Creation:** Build reusable Elementor templates using these standards
5. **CSS Implementation:** Create `config/custom-css/design-system.css` with all CSS variables
