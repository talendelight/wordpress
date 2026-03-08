# HireAccord WordPress Application

**Brand:** HireAccord (external) / TalenDelight (internal codename)  
**Status:** Active Development → Production  
**Hosting:** Hostinger (talendelight.com, migrating to hireaccord.com)  
**Version:** v3.6.2 (February 2026)

---

## 🎯 Strategic Context

### Business Model: Option C (Hybrid Model)

**Phase 1 (Months 0-12): Screening & Assessment Focus**

HireAccord is positioned as a **signal amplification layer** reducing hiring uncertainty through structured technical and behavioral evaluation.

- **Service:** Technical and behavioral screening reports for Java Backend + DevOps/Cloud engineers
- **Market:** Baltics + Nordics tech companies (10-200 employees)
- **Value Proposition:** 48-hour structured evaluation reports (NOT volume-focused recruiting)
- **Revenue:** €200-€500 screening packages
- **Differentiation:** Talent signal expert, not generic recruiter

**Phase 2 (Month 12+): Direct Placement Expansion**
- Layer contingency placement fees on top of assessment capability
- Requires: Clean employer exit, validated pipeline, risk clarity

### Why WordPress?

WordPress serves as the **primary application for Phase 1** because it enables:

1. ✅ **Faster MVP** - Validates screening service faster than custom Angular/Java build
2. ✅ **Marketing foundation** - Communicates value proposition to employers
3. ✅ **Candidate intake** - CV submission workflow with consent capture (GDPR compliance)
4. ✅ **Role-based access** - Operator/Manager/Scout workflows for assisted submissions
5. ✅ **Proof of competence** - Professional presence builds trust before client conversations
6. ✅ **Low overhead** - Managed hosting reduces maintenance during stealth phase

**Strategic Documents:**
- [HIREACCORD-STRATEGIC-PLAN.md](../../Documents/HIREACCORD-STRATEGIC-PLAN.md) - Complete strategic plan with founder strengths, Option C model
- [ROPS-REVENUE-OPERATIONS-PLAYBOOK.md](../../Documents/ROPS-REVENUE-OPERATIONS-PLAYBOOK.md) - Revenue operations approach
- [STEALTH-MODE-OPERATIONS-GUIDE.md](../../Documents/STEALTH-MODE-OPERATIONS-GUIDE.md) - 90-day asset building program

---

## 📋 Project Overview

### Tech Stack

- **WordPress:** 6.9.1
- **PHP:** 8.3
- **Database:** MariaDB 12.2.2 (local), MySQL 8.0 (production)
- **Theme:** Blocksy (parent) + Blocksy Child (custom)
- **Page Builder:** Gutenberg (migrated from Elementor)
- **Hosting:** Hostinger shared hosting with Git auto-deployment

### Architecture

```
wordpress/
├── wp-content/           # Git-tracked content (deployed to production)
│   ├── themes/
│   │   └── blocksy-child/    # Custom theme with patterns
│   ├── plugins/
│   │   ├── talendelight-roles/           # RBAC (5 roles)
│   │   └── forminator-upload-handler/    # CV upload handling
│   └── mu-plugins/       # Must-use plugins (logout redirect, etc.)
├── config/               # Dev-specific configs (wp-config.php, .htaccess)
├── infra/                # Development infrastructure
│   ├── dev/              # Podman Compose for local development
│   └── shared/           # Reusable automation scripts
├── docs/                 # Comprehensive documentation
└── restore/              # Backup storage and restore templates
```

### Key Features

**Public Pages:**
- Home, Candidates, Employers, Scouts, Operators (marketing + positioning)

**Authentication & Registration:**
- 5 user roles: Candidate, Employer, Scout, Operator, Manager
- Role-based registration workflow
- Approval logic (Operator OR Manager for public users, Manager ONLY for internal users)

**CV Submission:**
- Candidate self-submission (public, no login required)
- Scout/Operator/Manager assisted submission (with consent)
- Email notifications (registration, assignment, approval, rejection)

**Security & Compliance:**
- GDPR-aware consent capture
- Role-based access control (custom RBAC plugin)
- CV staging with weekly offload to OneDrive/SharePoint
- Security hardening (Hostinger + custom measures)

---

## 🚀 Quick Start

### Prerequisites

- **Windows PowerShell** - See [docs/README.md](docs/README.md#windows-powershell-setup) for execution policy setup
- **Podman Desktop** - For local development environment
- **SSH Key** - For production deployment (configured in Hostinger)

### Local Development

```powershell
# Start development environment
cd infra/dev
podman-compose up -d

# Access local site
# URL: https://wp.local
# Admin: https://wp.local/wp-admin (username: admin, password: password)
```

### Production Deployment

```powershell
# Standard deployment workflow
pwsh infra/shared/scripts/wp-action.ps1 backup      # 1. Backup (MANDATORY)
git checkout main && git merge develop && git push   # 2. Deploy (30s auto-deploy)
pwsh infra/shared/scripts/wp-action.ps1 verify      # 3. Verify (MANDATORY)

# If verification fails
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest
```

**See:**
- [DEPLOYMENT-WORKFLOW.md](docs/DEPLOYMENT-WORKFLOW.md) - Complete deployment guide
- [QUICK-REFERENCE-DEPLOYMENT.md](docs/procedures/QUICK-REFERENCE-DEPLOYMENT.md) - Command cheat sheet

---

## 📚 Documentation

### Getting Started
- **[docs/README.md](docs/README.md)** - Documentation index with strategic context
- **[docs/PROJECT-TIMELINE.md](docs/PROJECT-TIMELINE.md)** - Development timeline (Dec 2025 - Feb 2026)
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)** - AI pair programming guidelines

### Core Documentation
- **[WORDPRESS-BUSINESS-FUNCTIONALITY.md](../../Documents/WORDPRESS-BUSINESS-FUNCTIONALITY.md)** - Business requirements, user workflows
- **[WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md)** - Architecture, plugin design
- **[WORDPRESS-UI-DESIGN.md](../../Documents/WORDPRESS-UI-DESIGN.md)** - Design system, component library
- **[WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md)** - Security policies, GDPR compliance
- **[WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md)** - Database management, migrations
- **[WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md)** - Hostinger deployment, Git integration

### Operational Guides
- **[DEPLOYMENT-WORKFLOW.md](docs/DEPLOYMENT-WORKFLOW.md)** - Deployment process and lessons learned
- **[DISASTER-RECOVERY-PLAN.md](docs/procedures/DISASTER-RECOVERY-PLAN.md)** - Incident response procedures
- **[BACKUP-RESTORE-QUICKSTART.md](docs/procedures/BACKUP-RESTORE-QUICKSTART.md)** - Fast recovery guide
- **[COMMAND-REGISTRY.md](.github/COMMAND-REGISTRY.md)** - Proven commands reference
- **[TASK-REGISTRY.md](.github/TASK-REGISTRY.md)** - Multi-step procedures reference

### Development
- **[docs/lessons/](docs/lessons/)** - Lessons learned from real issues
- **[FUNCTIONAL-TEST-CASES.md](docs/FUNCTIONAL-TEST-CASES.md)** - Test scenarios and validation
- **[e2e-tests/README.md](../e2e-tests/README.md)** - Automated test suite (Playwright)

---

## 🎯 MVP Target: April 5, 2026

**Current Status:** v3.6.2 (February 14, 2026)

**Remaining Work:**
- ✅ Registration workflows → Complete
- ✅ Approval logic → Complete (testing pending)
- 🚧 Elementor to Gutenberg migration → 81% complete (13 of 16 pages)
- ⏳ Email notifications → v3.7.0
- ⏳ Export functionality → v3.8.0
- ⏳ Privacy Policy & Consent → Legal review (LFTC-001)
- ⏳ Rebrand (TalenDelight → HireAccord) → Pre-launch

**See:** [WORDPRESS-ALL-TASKS.md](../../Documents/WORDPRESS-ALL-TASKS.md) for complete task list (177 tasks tracked)

---

## 🤝 Contributing

This is a solo founder project with AI pair programming (GitHub Copilot).

**Development Workflow:**
- `develop` branch - Active development
- `main` branch - Production (auto-deploys to Hostinger on push)
- All changes require local testing before production deployment
- Follow patterns in [copilot-instructions.md](.github/copilot-instructions.md)

**Key Principles:**
- Always backup before deployment
- Always verify after deployment
- Use established patterns (see COMMAND-REGISTRY.md, TASK-REGISTRY.md)
- Document lessons learned in docs/lessons/
- Update VERSION-HISTORY.md for all releases

---

## 📄 License & Legal

**Legal Entity:** Lochness Technologies LLP (India)  
**Copyright:** © 2026 - HireAccord. A brand of Lochness Technologies LLP. All rights reserved.

**Proprietary Software:** Not open source. All rights reserved.

---

## 🔗 Related Repositories

- **[e2e-tests/](../e2e-tests/)** - Playwright test automation
- **Person App** (Future) - Angular + Java 25 + MySQL system of record

---

**Last Updated:** March 3, 2026  
**Next Milestone:** v3.7.0 (March 9, 2026) - Email notifications + Elementor migration completion
