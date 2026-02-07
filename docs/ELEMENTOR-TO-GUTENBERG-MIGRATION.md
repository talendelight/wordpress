# Elementor to Gutenberg Migration Plan

**Decision Date:** February 7, 2026  
**Target Completion:** March 7, 2026 (4 weeks)  
**Status:** In Progress - Phase 1

---

## Decision Rationale

### Why Migrate?

**Performance:**
- Elementor adds 500KB+ JavaScript/CSS overhead per page
- Gutenberg is native WordPress (no plugin dependency)
- 80-90% lighter page loads

**Design Consistency:**
- Current issue: Elementor pages look different from WPUM login pages and Forminator forms
- Solution: Unified CSS design system controls all pages
- Single source of truth for colors, typography, spacing

**Simplicity:**
- No complex Elementor data exports/imports (JSON corruption issues experienced)
- Version control friendly (blocks = HTML comments)
- Easier backup/restore workflows

**Cost:**
- Avoid Elementor Pro licensing pressure
- No vendor lock-in

### Timeline Impact

- Original MVP: April 5, 2026
- With migration: April 26, 2026 (+3 weeks)
- **Revised MVP: May 3, 2026** (with buffer)

---

## Migration Phases

### Phase 1: Design System Foundation ✅ IN PROGRESS

**Duration:** 2 calendar days (4 hours work)  
**Started:** February 7, 2026  
**Status:** ✅ CSS variables created

**Tasks:**
- [x] Extract colors from existing pages
- [x] Create CSS custom properties in child theme
- [x] Define typography scale
- [x] Define spacing system
- [x] Define component styles (buttons, forms, cards)
- [ ] Test CSS variables on existing pages
- [ ] Document design system usage

**Deliverables:**
- ✅ `wp-content/themes/blocksy-child/style.css` - CSS variables
- ⏳ Updated `docs/DESIGN-SYSTEM.md` with implementation details
- ⏳ Test page using new design system

---

### Phase 2: Reusable Block Patterns

**Duration:** 2 calendar days (4 hours work)  
**Starts:** February 9, 2026  
**Status:** Not Started

**Tasks:**
- [ ] Create hero section pattern (matching Elementor hero)
- [ ] Create card grid pattern (3-column, 2-column)
- [ ] Create icon box pattern
- [ ] Create tab interface pattern (for Manager Actions)
- [ ] Create data table pattern (for user requests)
- [ ] Create CTA section pattern
- [ ] Test patterns in Gutenberg editor

**Deliverables:**
- Block patterns in child theme `functions.php`
- Pattern library documentation
- Screenshots of each pattern

---

### Phase 3: Page Migration - Simple Pages

**Duration:** 1 calendar day (2 hours work)  
**Starts:** February 11, 2026  
**Status:** Not Started

**Pages (5):**
1. Welcome (ID 6)
2. Help (ID 15)
3. 403 Forbidden (ID 44)
4. Sample Page (ID 2)
5. Privacy Policy (ID 3)

**Process per page:**
1. Take screenshot of current Elementor page
2. Create new Gutenberg version in draft
3. Use block patterns to replicate design
4. Compare with screenshot
5. Test responsive (mobile, tablet, desktop)
6. Replace Elementor content with Gutenberg
7. Export page to restore/pages/

**Deliverables:**
- 5 pages migrated to Gutenberg
- Before/after screenshots
- Performance comparison report

---

### Phase 4: Page Migration - Role Landing Pages

**Duration:** 2 calendar days (4 hours work)  
**Starts:** February 12, 2026  
**Status:** Not Started

**Pages (5):**
1. Candidates (ID 7) - CV submission form
2. Employers (ID 64) - Request candidates form
3. Scouts (ID 76) - Partner submission
4. Managers (ID 8) - Manager landing
5. Operators (ID 9) - Operator landing

**Special Considerations:**
- Forminator forms embedded - ensure proper integration
- CTAs must match design system
- Consistent messaging across all roles

**Deliverables:**
- 5 role landing pages migrated
- Form integration tested
- CTA buttons consistent

---

### Phase 5: Page Migration - Authentication Pages

**Duration:** 1 calendar day (2 hours work)  
**Starts:** February 14, 2026  
**Status:** Not Started

**Pages (5):**
1. Login (ID 26) - WPUM shortcode
2. Password Reset (ID 27) - WPUM shortcode
3. Register (ID 28) - WPUM shortcode
4. Account (ID 29) - WPUM shortcode
5. Profile (ID 30) - WPUM shortcode

**Special Considerations:**
- Pages use WPUM shortcodes - no Elementor content to migrate
- Only need to style WPUM forms with design system CSS
- Test all WPUM functionality after styling

**Deliverables:**
- WPUM forms styled with design system
- Authentication flows tested
- CSS adjustments documented

---

### Phase 6: Page Migration - Registration Flow

**Duration:** 2 calendar days (4 hours work)  
**Starts:** February 15, 2026  
**Status:** Not Started

**Pages (2):**
1. Select Role (ID 78) - Role selection interface
2. Register Profile (ID 79) - Forminator registration form

**Special Considerations:**
- Critical user journey - must be perfect
- Forminator form styling
- Role selection UI/UX

**Deliverables:**
- Registration flow migrated
- End-to-end testing completed
- User testing feedback incorporated

---

### Phase 7: Page Migration - Complex Pages

**Duration:** 4 calendar days (8 hours work)  
**Starts:** February 17, 2026  
**Status:** Not Started

**Pages (2):**
1. Manager Admin (ID 10) - 6 tile dashboard
2. Manager Actions (ID 84) - 5-tab interface with shortcodes

**Special Considerations:**
- Most complex pages with tabs, shortcodes, dynamic content
- Requires custom tab blocks or pattern
- Must maintain functionality while improving performance

**Tasks per page:**
- [ ] Analyze current Elementor structure
- [ ] Design Gutenberg equivalent
- [ ] Build custom blocks if needed (tab interface)
- [ ] Migrate content section by section
- [ ] Test all interactive elements
- [ ] Performance benchmark

**Deliverables:**
- Complex pages fully migrated
- Custom blocks created (if needed)
- Performance improvement metrics

---

### Phase 8: New Pages (5 Placeholder Pages)

**Duration:** 1 calendar day (2 hours work)  
**Starts:** February 21, 2026  
**Status:** Not Started

**Pages (5):**
- IDs: 105, 106, 107, 108, 109 (currently unknown purpose)

**Process:**
- Review current content
- Migrate or remove as appropriate
- Use block patterns for consistent design

---

### Phase 9: Testing & Optimization

**Duration:** 3 calendar days (6 hours work)  
**Starts:** February 22, 2026  
**Status:** Not Started

**Tasks:**
- [ ] Responsive testing (all pages, all breakpoints)
- [ ] Cross-browser testing (Chrome, Firefox, Safari, Edge)
- [ ] Performance benchmarking (Lighthouse scores)
- [ ] Accessibility audit (WCAG 2.1 AA)
- [ ] User testing (registration flow, role-based access)
- [ ] Load testing (10 concurrent users)

**Success Metrics:**
- Lighthouse Performance: 90+ (currently ~60-70 with Elementor)
- All pages work on mobile/tablet/desktop
- No broken layouts or functionality
- Consistent design across all pages

**Deliverables:**
- Test report with screenshots
- Performance comparison (before/after)
- Bug list and fixes

---

### Phase 10: Cleanup & Documentation

**Duration:** 2 calendar days (4 hours work)  
**Starts:** February 25, 2026  
**Status:** Not Started

**Tasks:**
- [ ] Deactivate Elementor plugin
- [ ] Remove Elementor data from database
- [ ] Clean up unused Elementor assets
- [ ] Update documentation (deployment guides, session summaries)
- [ ] Update restore/backup scripts (remove Elementor exports)
- [ ] Git commit all changes with migration notes

**Deliverables:**
- Elementor fully removed
- Clean database
- Updated documentation
- Migration retrospective document

---

## Risk Management

### Identified Risks

**Risk 1: Forms Break After Migration**
- **Impact:** High - Registration flow critical
- **Mitigation:** Test Forminator/WPUM integration at each phase
- **Contingency:** Keep Elementor installed (deactivated) until all testing complete

**Risk 2: Custom Functionality Lost**
- **Impact:** Medium - Some Elementor features may not have Gutenberg equivalent
- **Mitigation:** Document all Elementor features before migration
- **Contingency:** Build custom blocks for critical features

**Risk 3: Design Inconsistencies**
- **Impact:** Medium - Pages may look different than intended
- **Mitigation:** Use block patterns, strict design system adherence
- **Contingency:** Iterate until exact match achieved

**Risk 4: Timeline Overrun**
- **Impact:** Low - MVP delayed further
- **Mitigation:** 1-week buffer built into timeline
- **Contingency:** Phase migration - launch MVP with partial Gutenberg adoption

---

## Success Criteria

### Technical Metrics
- ✅ All 23 pages migrated to Gutenberg
- ✅ Lighthouse Performance: 90+ (up from 60-70)
- ✅ Page load time: <2 seconds (down from 4-5 seconds)
- ✅ Zero console errors
- ✅ 100% responsive (mobile, tablet, desktop)

### Design Metrics
- ✅ Consistent colors/typography across all pages
- ✅ Login pages match content pages visually
- ✅ Forms (Forminator/WPUM) match design system

### Functional Metrics
- ✅ All user flows work (registration, login, role-based access)
- ✅ All forms submit successfully
- ✅ No broken links or missing content

---

## Rollback Plan

If migration fails or causes critical issues:

1. **Immediate:** Reactivate Elementor plugin
2. **Restore:** Import Elementor page data from `restore/pages/*-elementor.json`
3. **Revert:** Git revert to commit before migration started
4. **Reassess:** Delay migration to post-MVP phase

**Rollback Trigger:**
- Critical user flow broken (registration, login)
- Performance worse than Elementor
- Design regression beyond acceptable threshold

---

## Progress Tracking

**Overall Progress:** 10% (Phase 1 in progress)

**Completed:**
- ✅ Decision documented
- ✅ Migration plan created
- ✅ CSS design system implemented
- ✅ Design variables extracted

**Current:**
- 🔄 Testing CSS variables on existing pages
- 🔄 Documenting design system usage

**Next:**
- Create reusable block patterns (Phase 2 - starts Feb 9)

---

## Related Documentation

- [docs/DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) - Design system specification
- [Documents/COMMON-UI-DESIGN.md](../../Documents/COMMON-UI-DESIGN.md) - Cross-app design foundation
- [Documents/WORDPRESS-UI-DESIGN.md](../../Documents/WORDPRESS-UI-DESIGN.md) - WordPress-specific UI
- [Documents/WORDPRESS-MVP-TASKS.md](../../Documents/WORDPRESS-MVP-TASKS.md) - MVP task tracking
- [.github/copilot-instructions.md](../.github/copilot-instructions.md) - Project guidelines

---

**Next Review:** February 9, 2026 (end of Phase 1)
