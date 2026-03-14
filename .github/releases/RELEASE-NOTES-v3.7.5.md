# Release Notes: v3.7.5

**Release Date:** TBD  
**Status:** Planning  
**Type:** Infrastructure + Content Improvements

---

## Overview

This release focuses on fixing GitHub Actions deployment automation and conducting a comprehensive business analyst review of all page content before public launch.

---

## Changes

### 1. GitHub Actions Deployment Fix

**Problem:**
- GitHub Actions workflow failing with "You have an error in your yaml syntax"
- Attempted fixes for emoji characters and quote escaping unsuccessful
- Production deployments currently require manual SCP uploads

**Planned Actions:**
- [ ] Validate YAML syntax using yamllint or GitHub's validator
- [ ] Identify root cause of validation errors (encoding, special characters, indentation)
- [ ] Test workflow in isolated environment
- [ ] Document working deployment process
- [ ] Update TASK-REGISTRY.md with GitHub Actions troubleshooting

**Success Criteria:**
- Workflow validates without errors on GitHub
- Push to `main` branch triggers automated deployment
- Code and database changes deploy successfully
- Post-deployment verification completes

---

### 2. Business Analyst Content Review

**Objective:**
Review all public-facing pages with business analyst to ensure:
- Clear value proposition
- Professional tone and messaging
- HireAccord brand consistency
- Accurate descriptions of services
- Compliance with regulatory language requirements

**Pages to Review:**

1. **Homepage** (https://hireaccord.com)
   - Hero section
   - Value proposition
   - Service overview
   - Call-to-action clarity

2. **Candidates Page** (https://hireaccord.com/candidates/)
   - Benefits for candidates
   - Process explanation
   - Trust indicators

3. **Employers Page** (https://hireaccord.com/employers/)
   - Business value proposition
   - Service packages
   - Pricing clarity

4. **Managers Page** (https://hireaccord.com/managers/)
   - Role description
   - Responsibilities
   - Benefits

5. **Register Profile** (https://hireaccord.com/register-profile/)
   - Role selection clarity
   - Onboarding flow
   - Instructions

6. **Privacy Policy** (https://hireaccord.com/privacy-policy/)
   - GDPR compliance
   - Data handling transparency
   - Legal accuracy

7. **Terms of Service** (if applicable)
   - Legal requirements
   - Service limitations
   - User responsibilities

**Content Review Checklist:**
- [ ] Schedule BA review sessions (1-2 hours per page)
- [ ] Document all content change requests
- [ ] Prioritize changes (critical vs. nice-to-have)
- [ ] Update page HTML in restore/pages/
- [ ] Deploy to local for BA approval
- [ ] Deploy approved content to production
- [ ] Verify branding consistency across all pages

---

## Deployment Plan

### Phase 1: GitHub Actions Fix (Week 1)
1. Debug YAML validation issues
2. Test workflow locally with act or similar tool
3. Push fix to `develop` branch
4. Test automated deployment on staging/test push
5. Merge to `main` when validated

### Phase 2: Content Review (Week 1-2)
1. Export all pages to review documents
2. Schedule BA review sessions
3. Document feedback and requested changes
4. Make approved content updates
5. Review updated pages with BA
6. Deploy approved content

### Phase 3: Verification (Week 2)
1. Verify GitHub Actions workflow works end-to-end
2. Confirm all pages reflect approved content
3. Test user flows (registration, login, navigation)
4. Performance check (load times)

---

## Files Modified

### Infrastructure
- `.github/workflows/deploy.yml` - Fix YAML syntax errors
- Potentially `.github/workflows/post-deploy.yml` if issues found

### Content (TBD based on BA feedback)
- Potentially all pages in `restore/pages/`
- May require pattern updates in `wp-content/themes/blocksy-child/patterns/`

---

## Testing Checklist

**GitHub Actions:**
- [ ] Workflow file validates on GitHub
- [ ] Workflow runs on push to `main`
- [ ] Code deployment succeeds
- [ ] Database migration succeeds (if applicable)
- [ ] Cache clearing works
- [ ] Health check passes

**Content Review:**
- [ ] All pages reviewed with BA
- [ ] Content approved for public launch
- [ ] Brand consistency verified
- [ ] Legal/compliance language approved
- [ ] Tone and messaging aligned with strategy

---

## Rollback Plan

**GitHub Actions Issues:**
- Revert `.github/workflows/deploy.yml` to previous working version
- Continue manual deployments via SCP until fixed

**Content Issues:**
- Restore pages from `restore/pages/` backups
- Use deploy-pages.ps1 to revert to previous content

---

## Notes

- **Current State:** GitHub Actions blocked, manual deployment working
- **Priority:** Fix automation before next major release
- **BA Review:** Critical for public launch readiness
- **Timeline:** Flexible based on BA availability
- **Sprint Context:** Gap Days work (Mar 7-16) or Sprint 1 (starts Mar 17)

---

## Next Steps After v3.7.5

Potential v3.8.0 features (pending prioritization):
- Profile Pages (WP-04.14)
- Email Notification Templates completion
- Registration UX improvements
- Multi-contact design implementation

---

**Last Updated:** March 14, 2026  
**Prepared by:** Development Team  
**Requires Approval:** Business Analyst (content changes), DevOps (workflow fixes)
