# Restart Context - February 27, 2026

**Quick Reference for Post-Restart Session**

---

## ⚡ First 3 Actions (30 seconds)

```powershell
# 1. Delete redundant calendar file (already consolidated into THIS-WEEK-PLAN.md)
Remove-Item "C:\Users\codes\OneDrive\Lochness\TalenDelight\Documents\ROPS-WEEKLY-CALENDAR-PLAN.md"

# 2. Check all files present
Get-Item "ROPS-REVENUE-OPERATIONS-PLAYBOOK.md", "THIS-WEEK-PLAN.md", "WORDPRESS-ALL-TASKS.csv"

# 3. Done - ready to start ROPS-001
```

---

## 🎯 What Changed This Session

**Revenue Execution Mode Activated:**
- 70% Revenue / 20% Candidates / 10% Systems (n8n max 90 min/week)
- Weekly targets: 20 leads, 15 outbound, 25 follow-ups, ≥3 replies, ≥1 call, ≥1 opportunity
- Initial niche: Java backend + DevOps/Cloud, Baltics + Nordics
- Validation milestone: 4-6 weeks from Mar 2 (10 conversations, 2 discussions, 1 shortlist)

**Files Created/Updated:**
- ✅ ROPS-REVENUE-OPERATIONS-PLAYBOOK.md (8.16 KB) - Complete revenue guide
- ✅ THIS-WEEK-PLAN.md (561 lines) - Added "Weekly Rhythm" section (Mon-Sun breakdown)
- ✅ WORDPRESS-ALL-TASKS.csv (159 lines) - Added ROPS-010 & ROPS-011 as complete
- ✅ .github/copilot-instructions.md (816 lines) - Embedded Revenue Execution Mode rules

**File Consolidated:**
- ROPS-WEEKLY-CALENDAR-PLAN.md → THIS-WEEK-PLAN.md "Weekly Rhythm" section
- DELETE standalone calendar file after restart (manual cleanup)

---

## 📚 Key Documents

**Revenue Operations:**
1. [ROPS-REVENUE-OPERATIONS-PLAYBOOK.md](ROPS-REVENUE-OPERATIONS-PLAYBOOK.md) - Strategy, niche, offer, CRM, targets
2. [THIS-WEEK-PLAN.md](THIS-WEEK-PLAN.md) - "Weekly Rhythm" section with Mon-Sun schedule
3. [WORDPRESS-ALL-TASKS.csv](WORDPRESS-ALL-TASKS.csv) - 11 ROPS tasks (2 complete, 9 planned)

**Context:**
4. [WordPress/.github/copilot-instructions.md](../../code/wordpress/.github/copilot-instructions.md) - Revenue rules embedded
5. [WordPress/docs/SESSION-SUMMARY-FEB-27.md](../../code/wordpress/docs/SESSION-SUMMARY-FEB-27.md) - Full session details

---

## 🚀 Tomorrow's Work (Feb 28)

**ROPS-001: Define Niche Positioning Statement (1 hour)**
- Write 1-page positioning statement
- Reference: ROPS-REVENUE-OPERATIONS-PLAYBOOK.md sections 6-7
- Content already defined, just needs formal documentation

**Elements to include:**
- Target market: EU tech startups/consultancies, 10-200 employees
- Roles: Java backend + DevOps/Cloud
- Regions: Baltics + Nordics
- Pain point: Screening time/quality
- Value prop: AI-assisted screening, 3x faster
- Promise: "48h screening reports" or "shortlist in 5 days"

---

## 🎯 Copilot Behavior Changed

**From now on, Copilot will automatically:**
- Translate generic questions → revenue-focused ("What actions increase employer conversations?")
- Apply day-specific prompts (Mon employer, Tue candidate, Fri KPI, Sun review)
- Adjust volume based on time (45 min vs 2 hours)
- Challenge non-revenue work until 10 conversations + 2 discussions + 1 shortlist
- Protect follow-ups first when time tight
- Defer WordPress features, UI polish, documentation until revenue validated

**Your natural drift:** System refinement, automation, documentation  
**Copilot's job:** Redirect to outbound sent, follow-ups executed, calls booked

---

## 📋 ROPS Tasks Overview

**Completed (2):**
- ROPS-010: Weekly Calendar Plan (Feb 27) - Integrated into THIS-WEEK-PLAN.md
- ROPS-011: Niche Positioning & Pilot Offer (Feb 27) - Merged into Playbook

**This Week Setup (6):**
- ROPS-001: Positioning Statement (0.5 days) - START FEB 28 ⬅️
- ROPS-002: Pilot Offer (0.5 days)
- ROPS-003: Outreach Cadence (0.5 days)
- ROPS-004: CRM Structure (1.0 days)
- ROPS-005: Lead Schema (0.5 days)
- ROPS-006: Proof Asset (0.5 days)

**Next Week Recurring (3 - starting Mar 2):**
- ROPS-004: Employer leads (0.5 days/session, Mon/Wed/Fri)
- ROPS-005: Candidate sourcing (0.5 days/session, Tue/Thu)
- ROPS-006: Follow-ups (daily)
- ROPS-007: Signal analysis (weekly Fri/Sun)
- ROPS-008: KPI tracking (weekly Friday)
- ROPS-009: CRM maintenance (weekly)

---

## ⚙️ Weekly Rhythm (Starting Mar 2)

**Monday (Employer, 1-2h):** 5 leads + 3 outbound + 5 follow-ups  
**Tuesday (Candidate, 1-2h):** 5 candidates + 3 outreach + 1 profile  
**Wednesday (Employer, 1-2h):** 5 leads + 3 outbound + 5 follow-ups  
**Thursday (Candidate, 1-2h):** 5 candidates + 3 outreach + 1 profile  
**Friday (KPI, 1-2h):** 10 follow-ups + KPI update (10 min)  
**Weekend (3-4h):** 10 leads + remaining outbound + n8n 90 min

**Weekly Targets:**
- 20 leads, 15 outbound, 25 follow-ups, ≥3 replies, ≥1 call, ≥1 opportunity
- 15 candidates, 10 outreach, 3 consented, 2 profiles

---

## 🔍 Quick Check After Restart

```powershell
# Verify files exist
Test-Path "ROPS-REVENUE-OPERATIONS-PLAYBOOK.md"  # Should be True
Test-Path "THIS-WEEK-PLAN.md"                    # Should be True
Test-Path "WORDPRESS-ALL-TASKS.csv"              # Should be True
Test-Path "ROPS-WEEKLY-CALENDAR-PLAN.md"         # Should be False (after manual delete)

# Check file sizes
Get-Item "ROPS-REVENUE-OPERATIONS-PLAYBOOK.md" | Select-Object Name, Length
Get-Item "THIS-WEEK-PLAN.md" | Select-Object Name, Length

# Count ROPS tasks
$csv = Import-Csv "WORDPRESS-ALL-TASKS.csv" -Delimiter ";"
$rops = $csv | Where-Object { $_.'Task ID' -like 'ROPS-*' }
Write-Host "ROPS tasks: $($rops.Count)"  # Should be 11
```

---

**Machine Restart:** ✅ Safe - All context preserved  
**Next Action:** Delete ROPS-WEEKLY-CALENDAR-PLAN.md, then start ROPS-001  
**Session End:** February 27, 2026 (late night)

