# This Week's Work Plan
**Week of:** February 23-27, 2026 (w/s 2026-02-23)  
**Focus:** Blockers, Critical MVP Tasks, Business Revenue Engine Setup  
**Capacity:** 6.3 calendar days realistic (18 hours/week × 70% efficiency ÷ 2h/day)

---

## 🚨 CRITICAL: Blockers First

### 1. LFTC-002: Engage Lawyer for GDPR Retention Policy
- **Priority:** CRITICAL (Blocker)
- **Estimate:** 0.5 days (1 hour)
- **Status:** Todo → In Progress (start immediately)
- **Why Critical:** Blocks PENG-014 (Privacy Policy), which blocks all registration forms
- **Action Items:**
  - [ ] Prepare brief: GDPR retention policy requirements for candidate CVs
  - [ ] Send to lawyer with context (CV lifecycle policy COPS-001 completed)
  - [ ] Request timeline (ideally 1-week turnaround)
- **Deliverable:** Brief sent, lawyer engaged, timeline confirmed

### 2. COPS-006: Post Secretary Job Listing
- **Priority:** CRITICAL
- **Estimate:** 1 day (2 hours)
- **Status:** Todo → In Progress (start this week)
- **Why Critical:** Target start date March 23 = 4-week hiring lead time = Must post NOW
- **Action Items:**
  - [ ] Write job description (10-20 hours/week, ops support, CRM maintenance, outreach)
  - [ ] Post on LinkedIn Jobs + Indeed + local job boards
  - [ ] Set up application tracking (simple spreadsheet or email folder)
- **Deliverable:** Job posted, applications start coming in
- **Note:** Continues over 3 weeks (screening, interviews, hiring)

---

## 💼 CRITICAL: In-Progress Work

### 3. BUG-001: Fix Role Showing N/A Instead of Candidate
- **Priority:** HIGH
- **Estimate:** 0.5 days (1 hour)
- **Status:** Todo → In Progress
- **Why Important:** Production bug affecting candidate registration (PENG-017)
- **Action Items:**
  - [ ] Debug td_user_role parameter flow in Forminator submission
  - [ ] Check database insert logic for role field
  - [ ] Test fix on local, deploy to production
- **Deliverable:** Role displays correctly on Manager Actions dashboard

### 4. PENG-072: Operator Actions Page
- **Priority:** CRITICAL
- **Estimate:** 2 days (4 hours)
- **Status:** Todo → In Progress
- **Why Critical:** MVP requires both Manager AND Operator dashboards for approval workflow
- **Action Items:**
  - [ ] Clone Manager Actions page structure
  - [ ] Add role-based filtering (Operators see Candidate + Employer only, not Scout/Manager/Operator)
  - [ ] Test approval/rejection buttons with Operator user
  - [ ] Update navigation to show Operator Actions in Operator menu
- **Deliverable:** Operator Actions dashboard functional with role filtering

---

## 🏗️ HIGH PRIORITY: Business Revenue Engine

### 5. COPS-008: CRM/Pipeline Tracker Setup
- **Priority:** HIGH
- **Estimate:** 1 day (2 hours)
- **Status:** Todo → In Progress (start this week)  
- **Why Important:** "Revenue engine cannot pause" - need tracking for leads/pipeline
- **Action Items:**
  - [ ] Choose tool: Airtable (recommended) or Notion or Google Sheets
  - [ ] Set up basic structure:
    - Table 1: Leads (Company, Contact, Status, Last Contact, Next Action)
    - Table 2: Candidates (Name, Skills, Status, Availability, Scout/Source)
    - Table 3: Active Roles (Company, Role, Requirements, Status, Assigned To)
  - [ ] Add sample data to validate structure
  - [ ] Document access (share with future secretary)
- **Deliverable:** CRM operational with basic structure

### 6. MKTB-013: Lead List Schema
- **Priority:** HIGH
- **Estimate:** 0.5 days (1 hour)
- **Status:** Todo
- **Why Important:** Define CRM structure for outreach campaign
- **Action Items:**
  - [ ] Define schema: Company Name, Region, Role Hiring For, Company Size, Contact Name, Contact Title, LinkedIn URL, Email, Channel, Status, Last Touch Date, Next Touch Date, Notes
  - [ ] Implement in Airtable/Notion/Sheet (after COPS-008)
  - [ ] Document fields and purpose
- **Deliverable:** Lead list schema defined in CRM
- **Dependencies:** COPS-008

### 7. MKTB-005: Outreach Templates
- **Priority:** CRITICAL
- **Estimate:** 0.5 days (1 hour)
- **Status:** Todo
- **Why Critical:** Need templates for outreach campaign (you do 2 days/week until secretary starts)
- **Action Items:**
  - [ ] Create Initial cold email template (~100 words, focus on pain point: screening time + value prop: AI-assisted screening)
  - [ ] Create Follow-up email template for non-responders
  - [ ] Store templates in CRM/shared folder
  - [ ] Test templates with 2-3 sample prospects
- **Deliverable:** 2 outreach templates (initial + follow-up) ready for use

---

## 📊 This Week Summary

### Workload Breakdown
| Task | Priority | Est (Days) | Type |
|------|----------|------------|------|
| LFTC-002 (Lawyer) | 🚨 CRITICAL | 0.5 | Blocker |
| COPS-006 (Secretary) | 🚨 CRITICAL | 1.0 | Business Ops |
| BUG-001 (Role fix) | ⚠️ HIGH | 0.5 | Development |
| PENG-072 (Operator Actions) | ⚠️ HIGH | 2.0 | Development |
| COPS-008 (CRM) | ⚠️ HIGH | 1.0 | Business Ops |
| MKTB-013 (Lead schema) | ⚠️ HIGH | 0.5 | Business Ops |
| MKTB-005 (Outreach templates) | 🚨 CRITICAL | 0.5 | Business Ops |
| **TOTAL** | | **6.0 days** | |

**Capacity Analysis:**
- **Planned:** 6.0 days
- **Realistic capacity:** 6.3 days/week
- **Buffer:** 0.3 days (5%)
- **Verdict:** ✅ **ACHIEVABLE** with minimal buffer (tight week, prioritize ruthlessly)

**Week Goals:**
1. ✅ Lawyer engaged → GDPR work starts (unblocks Privacy Policy)
2. ✅ Secretary job posted → Hiring pipeline starts
3. ✅ Operator Actions working → MVP approval workflow intact
4. ✅ CRM operational → Revenue tracking in place
5. ✅ Outreach templates ready → Begin outreach execution (2 sessions/week: 3 new + 5 follow-ups each)

## 🚫 Explicitly Deferred to Next Week

### PENG-014: Privacy Policy Page
- **Why deferred:** Blocked by LFTC-002 (lawyer engagement)
- **New planned week:** w/s 2026-03-02
- **Dependencies:** LFTC-002 must be engaged + initial inputs received

### PENG-015: CPT td_registration_request
- **Why deferred:** Can start after Privacy Policy framework clear
- **New planned week:** w/s 2026-03-02
- **Dependencies:** PENG-014 (conceptual), BMSL-001, PENG-001

### PENG-016: Record ID Generation System
- **Why deferred:** Dependent on CPT structure (PENG-015)
- **New planned week:** w/s 2026-03-02
- **Dependencies:** PENG-001, PENG-015

---

## 🎯 Success Criteria for This Week

**By Friday, February 28:**
1. ✅ Lawyer engaged, brief sent, timeline confirmed (LFTC-002)
2. ✅ Secretary job posted, applications coming in (COPS-006)
3. ✅ Role N/A bug fixed in production (BUG-001)
4. ✅ Operator Actions dashboard working (PENG-072)
5. ✅ Basic CRM/pipeline tracker operational (COPS-008)

**Outcomes:**
- **Legal blocker unblocked** → PENG-014 can start next week
- **Secretary hiring pipeline active** → March 23 start date achievable
- **Operator workflow complete** → MVP approval flow operational
- **Revenue engine tracked** → Business operations visible

---

## 📅 Next Week Preview (w/s 2026-03-02)

**Development (After LFTC-002 inputs received):**
- PENG-014: Privacy Policy page (2 days)
- PENG-015: CPT td_registration_request (2 days)
- PENG-016: Record ID generation (2 days)
- PENG-018: Employer registration form (2 days)

**Business Operations:**
- COPS-006 (continued): Screen secretary applications, shortlist 3-5
- COPS-009: Lead list building (3 days)

**Week of March 9 (w/s 2026-03-09):**
- PENG-073: Extract candidate details from CVs/meetings (2 days) - Create process/template for capturing Location, Primary role, Years of experience, Availability, Expected rate
- PENG-020: Operator registration form (2 days)

**Capacity:** 8 days planned vs 6.3 realistic = **OVERCOMMITTED**  
**Recommendation:** Prioritize PENG-014/015/016, defer PENG-018 OR COPS-009

---

## 🔄 WIP Limit

**Maximum 2 development tasks in progress at once:**
- Start: BUG-001 + PENG-072
- After BUG-001 complete: Continue PENG-072
- Allow parallel: Business ops tasks (LFTC-002, COPS-006, COPS-008) don't block development

**Rationale:** Context switching penalty + 2h/day constraint = Focus on completion, not starting

---

## 📝 Related Documents

- [Proposal Analysis](../tmp/PROPOSAL-ANALYSIS.md) - Full analysis of reprioritization proposal
- [WORDPRESS-ALL-TASKS.csv](../../Documents/WORDPRESS-ALL-TASKS.csv) - Master task list (all project tasks)
- [WORDPRESS-ALL-TASKS.md](../../Documents/WORDPRESS-ALL-TASKS.md) - Human-readable task list
- [WORDPRESS-OPEN-ACTIONS.md](../../Documents/WORDPRESS-OPEN-ACTIONS.md) - Blocking actions tracker

---

**Last Updated:** February 24, 2026  
**Next Review:** February 28, 2026 (end of week retrospective)
