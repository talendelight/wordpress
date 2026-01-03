# Epic WP-01: Public Marketing Website (MVP)

**Epic ID:** WP-01  
**Status:** In Progress  
**Priority:** MVP  
**Created:** December 29, 2025  
**Last Updated:** December 29, 2025

---

## Epic Overview

Build a professional public-facing marketing website that communicates TalenDelight's value proposition, specialties, and processes to both employers and candidates. The website serves as the primary entry point for new business relationships and candidate submissions.

**Epic Goal:** Establish online presence with clear messaging and functional intake forms for employers and candidates.

---

## Features in this Epic

| Feature ID | Feature Name | Status | Priority | Assignee | Notes |
|------------|--------------|--------|----------|----------|-------|
| WP-01.1 | Home page | Planning | MVP | | Value proposition, specialties, CTAs |
| WP-01.2 | Employers page | Not Started | MVP | | Process + request form |
| WP-01.3 | Candidates page | Not Started | MVP | | Process + submit CV form |
| WP-01.4 | Contact page | Not Started | MVP | | Employer/candidate selector |
| WP-01.5 | Privacy Policy page | Not Started | MVP | | Consent, retention, contact |
| WP-01.6 | Basic SEO setup | Not Started | MVP | | Titles, meta, sitemap |
| WP-01.7 | Analytics integration | Not Started | MVP | | Privacy-aware tracking |

---

## Epic-Level Requirements

### Business Requirements
- Professional, trustworthy brand presentation
- Clear differentiation of employer vs. candidate journeys
- Seamless progression from information to action (form submission)
- Privacy-first approach (GDPR-aware)
- Multi-language ready (EN first, LV/LT/ET future)

### Technical Requirements
- WordPress 6.9.0 + PHP 8.3
- Blocksy theme as foundation
- Elementor for page building
- Responsive design (mobile-first)
- Fast load times (<3s)
- Accessible (WCAG 2.1 AA minimum)

### Design Requirements
- Consistent visual identity across all pages
- Clear information hierarchy
- Strong CTAs on each page
- Professional imagery/graphics
- Color scheme and typography defined
- Reusable component library (Elementor templates)

---

## Epic Dependencies

### Upstream Dependencies
- Blocksy theme installed and activated ✅
- Elementor installed and activated ✅
- Basic WordPress configuration complete ✅

### Downstream Dependencies
- **WP-02** (Candidate Intake): Form integration on WP-01.3
- **WP-03** (Partner Submissions): Linked from marketing pages
- **WP-07** (Security): Form protection, spam prevention

---

## Epic Architecture

### Page Structure
```
/ (Home)
├── /employers (Employer process + form)
├── /candidates (Candidate process + form)
├── /contact (General contact)
└── /privacy-policy (Legal)
```

### Navigation Design
- **Header:** Logo, Main Nav (Home, Employers, Candidates, Contact)
- **Footer:** Privacy Policy, Social Links, Copyright
- **Mobile:** Hamburger menu

### Key Components (Elementor Templates)
- Hero section (reusable with variants)
- CTA blocks (primary/secondary styles)
- Process timeline (3-step visual)
- Feature grid (specialties/services)
- Form container (consistent styling)
- Testimonial slider (future)

---

## Technical Stack

### Themes & Plugins
- **Theme:** Blocksy (primary)
- **Page Builder:** Elementor
- **Forms:** WPForms Lite (upgrade to Pro if needed)
- **SEO:** Yoast SEO or Rank Math
- **Analytics:** (TBD - privacy-aware solution)

### Assets Management
- Images: `wp-content/uploads/YYYY/MM/`
- Custom CSS: Elementor custom CSS or Blocksy child theme
- Scripts: Minimal custom JS (prefer native WP/Elementor features)

---

## Epic Acceptance Criteria

- [ ] All 7 features (WP-01.1 through WP-01.7) complete and deployed
- [ ] Pages render correctly on desktop, tablet, mobile
- [ ] Navigation works consistently across all pages
- [ ] Forms submit successfully and trigger appropriate workflows
- [ ] SEO metadata present and correct on all pages
- [ ] Analytics tracking operational
- [ ] Page load times <3 seconds
- [ ] No accessibility violations (WCAG 2.1 AA)
- [ ] Privacy Policy published and linked from forms
- [ ] Tested in Chrome, Firefox, Safari, Edge

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Scope creep on design iterations | High | Medium | Define design approval checkpoint; timebox iterations |
| Form spam/abuse | Medium | High | Implement CAPTCHA, rate limiting (WP-07.2) |
| Content not ready | High | Medium | Use lorem ipsum placeholders; define content delivery schedule |
| Elementor performance issues | Medium | Low | Monitor page size; optimize images; use caching |
| Mobile UX not tested adequately | High | Medium | Test on real devices; use BrowserStack for coverage |

---

## Epic Timeline

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Epic kickoff | Dec 29, 2025 | ✅ Complete |
| Requirements complete (all features) | TBD | Not Started |
| Design mockups approved | TBD | Not Started |
| Development complete | TBD | Not Started |
| QA/Testing | TBD | Not Started |
| Deployment to production | TBD | Not Started |

---

## Related Documentation

- [WORDPRESS-BACKLOG.md](../../Documents/WORDPRESS-BACKLOG.md) - Full backlog
- [WORDPRESS-BUSINESS-FUNCTIONALITY.md](../../Documents/WORDPRESS-BUSINESS-FUNCTIONALITY.md) - Business requirements
- [WORDPRESS-UI-DESIGN.md](../../Documents/WORDPRESS-UI-DESIGN.md) - Design guidelines
- [WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md) - Architecture
- [WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md) - Deployment process
- [WORDPRESS-PAGE-SYNC-MANIFEST.md](../../Documents/WORDPRESS-PAGE-SYNC-MANIFEST.md) - Page sync strategy

---

## Notes

- This is the foundational epic - quality and polish matter
- Focus on clarity of messaging over visual complexity
- Every page should have a clear purpose and CTA
- Build reusable components for consistency and efficiency
- Test with real users (employers + candidates) before launch
