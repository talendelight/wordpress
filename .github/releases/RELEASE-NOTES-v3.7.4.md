# Release Notes v3.7.4

**Status:** In Progress  
**Type:** Patch  
**Release Date:** TBD  
**Started:** March 13, 2026

## Overview

UI improvements for Manager Actions and Operator Actions pages:
- Fixed button styling (oval → rectangle) for consistency
- Added Onboard functionality for approved users
- Added Archive functionality for rejected users

## Tasks

### UI-001: Fix Action Button Styling
- **Type:** bug-fix
- **Status:** completed
- **Priority:** medium
- **Estimated:** 0.2 days
- **Description:** Change action button border-radius from 50% (oval/circular) to 5px (rounded rectangle) for visual consistency with other UI elements
- **Implementation Notes:** Updated CSS in manager-actions-display.php and operator-actions-display.php

### FEAT-001: Add Onboard Button
- **Type:** feature
- **Status:** completed (UI only, backend handler needed)
- **Priority:** high
- **Estimated:** 0.3 days
- **Description:** Add "Onboard" button (+) after "Undo Approve" button in Approved tab and for approved records in All tab
- **Implementation Notes:** 
  - Added button in Manager Actions and Operator Actions
  - Blue background (#2196F3)
  - Located after Undo Approve button with 4px margin
  - **Backend Handler Required:** JavaScript/AJAX handler needs to be implemented for actual onboarding functionality

### FEAT-002: Add Archive Button
- **Type:** feature
- **Status:** completed (UI only, backend handler needed)
- **Priority:** high
- **Estimated:** 0.3 days
- **Description:** Add "Archive" button (↓) after "Undo Rejection" button in Rejected tab and for rejected records in All tab
- **Implementation Notes:** 
  - Added button in Manager Actions and Operator Actions
  - Gray background (#9E9E9E)
  - Down arrow icon (↓) matching the style of Assign button (➜)
  - Located after Undo Rejection button with 4px margin
  - **Backend Handler Required:** JavaScript/AJAX handler needs to be implemented for actual archive functionality

## Files Modified

### To Be Committed
- `wp-content/mu-plugins/manager-actions-display.php` - Button styling fix + Onboard button
- `wp-content/mu-plugins/operator-actions-display.php` - Button styling fix + Onboard button

### To Be Created
*None yet*

### To Be Deleted
*None*

## Deployment Plan

### Pre-Deployment
1. [ ] Review all changes locally
2. [ ] Test all functionality
3. [ ] Check git status (Rule #16)
4. [ ] Backup production

### Deployment Steps
1. [ ] Commit all changes
2. [ ] Push to develop
3. [ ] Merge to main
4. [ ] Wait for Hostinger auto-deploy
5. [ ] Verify deployment

### Post-Deployment
1. [ ] User visual verification (Rule #15)
2. [ ] Clear production cache
3. [ ] Test key functionality
4. [ ] Update release status

## Verification Checklist

- [ ] Local testing complete
- [ ] Production deployment successful
- [ ] Technical verification passed
- [ ] **User visual verification confirmed** (Rule #15 - WAIT for user approval)

## Issues & Resolution

*Document any issues encountered and how they were resolved*

## Next Steps

*List next actions after this release is complete*

---

**Note:** Per Rule #15, do not mark this release complete without explicit user verification and approval.
