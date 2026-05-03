# Enterprise AI Agent Readiness Assessment

A structured evaluation of whether the organization is ready to introduce Copilot Studio AI agents at scale. Complete this before committing to an agent program — gaps identified here must be resolved before any agent enters production.

This document covers three dimensions: **Technical**, **Operational**, and **Governance** readiness. Each section produces a readiness score. The final section gives a Go / Conditional Go / No-Go recommendation.

---

## Document Control

| Field | Value |
|-------|-------|
| Organization / Business unit | |
| Assessment date | |
| Conducted by | |
| Reviewed by | |
| Status | Draft / Under Review / Approved |

---

## 1 — Strategic Alignment

Before assessing technical readiness, confirm that AI agents are the right solution to the right problem.

### 1.1 — Business case

| Question | Answer |
|----------|--------|
| What specific business problem are agents solving? | |
| What is the current cost / volume of the process being automated? | |
| What is the measurable success metric for the agent program? | |
| Who is the executive sponsor? | |
| What is the target go-live date and why? | |

### 1.2 — Strategic fit

| Check | Status |
|-------|--------|
| Agent program is aligned to organizational AI strategy | ☐ Aligned / ☐ Not defined / ☐ Conflicts |
| Use cases have been prioritized by business value, not by technical interest | ☐ Yes / ☐ No |
| Stakeholders understand AI agents are not RPA — they are probabilistic, not deterministic | ☐ Yes / ☐ No |
| Organization accepts that agents will occasionally give wrong answers and has a plan for this | ☐ Yes / ☐ No |
| Budget is confirmed for: build, licensing, ongoing operations, and quarterly reviews | ☐ Yes / ☐ Partial / ☐ No |

**If any answer in 1.2 is No: resolve before proceeding. Building without strategic alignment produces agents no one uses or trusts.**

---

## 2 — Technical Infrastructure Prerequisites

### 2.1 — Power Platform environment

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Dedicated Power Platform environment for AI agents (not shared with production apps) | Yes | | |
| Environment is in the correct region for data residency | Yes | | |
| Environment has Copilot Studio capacity (CU allocation confirmed) | Yes | | |
| Separate environments exist for: Dev, Test/UAT, Production | Recommended | | |
| Environment admin is identified and available | Yes | | |
| Environment is connected to the correct Microsoft 365 tenant | Yes | | |

### 2.2 — Licensing

| License | Purpose | Required for | Confirmed? |
|---------|---------|-------------|-----------|
| Copilot Studio (per-session or per-tenant) | Agent runtime | All agents | ☐ |
| Microsoft 365 Copilot (per user) | Agents surfaced in Copilot for M365 | Copilot channel | ☐ |
| Power Automate Premium | Cloud flow connectors called from agents | Connector-based agents | ☐ |
| Azure Application Insights | Telemetry and monitoring | All production agents | ☐ |
| Microsoft Entra ID (Azure AD) P1 | Conditional Access for agent authentication | Authenticated agents | ☐ |

**Licensing note:** Copilot Studio sessions are consumed per conversation. Estimate session volume before purchase. Under-licensed environments throttle agent responses silently.

### 2.3 — Identity and authentication

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Azure AD app registration process is defined (who creates them, approval required?) | Yes | | |
| Service accounts for connectors exist and have MFA configured | Yes | | |
| App registration secret rotation process is defined | Yes | | |
| Conditional Access policies do not block agent channels (Teams, web) | Yes | | |
| Redirect URI allowlisting process for new agents is defined | Yes | | |

### 2.4 — Connector and integration availability

| Connector / Integration | Used for | Available in env? | Connection owner | Notes |
|------------------------|---------|------------------|-----------------|-------|
| Microsoft 365 Users | User profile (ConversationInit) | ☐ | | |
| SharePoint Online | Knowledge sources | ☐ | | |
| [Line-of-business system] | [Action] | ☐ | | |
| [Other] | | ☐ | | |

**Blocker:** A connector that is not available in the Power Platform environment at design time cannot be built into the agent. Confirm all required connectors before the build starts.

### 2.5 — Knowledge source infrastructure

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| SharePoint sites for knowledge sources exist and are accessible | Yes | | |
| Document libraries are indexed by Microsoft Search | Yes | | |
| Content owner is identified for each knowledge source | Yes | | |
| Content review and update process is defined | Yes | | |
| Documents are in supported formats (Word, PDF, PowerPoint, plain text) | Yes | | |
| Confidential content is separated from agent-accessible content | Yes | | |

### 2.6 — Monitoring and observability

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Azure Application Insights instance is provisioned | Yes | | |
| Application Insights connection string is available | Yes | | |
| Monitoring dashboard is set up or planned | Recommended | | |
| Alert notification channel is defined (email, Teams webhook) | Yes | | |
| On-call / first-responder for agent incidents is identified | Yes | | |

---

## 3 — Operational Prerequisites

### 3.1 — Support model

AI agents require an ongoing support model. An agent without a defined support model degrades silently after launch.

| Question | Answer |
|----------|--------|
| Who is the agent owner post-launch? | |
| Who handles L1 user questions about the agent? | |
| Who handles L2 technical issues (routing errors, knowledge gaps)? | |
| Who handles L3 incidents (P1/P2 — agent down, errors)? | |
| What is the SLA for each incident severity? | P1: ___ / P2: ___ / P3: ___ |
| What is the process for a user to report an incorrect answer? | |
| How are user feedback items triaged and actioned? | |

### 3.2 — Change management and release

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Version control (git) is set up for agent YAML | Yes | | |
| A release / change approval process is defined for agent updates | Yes | | |
| The CI/CD pipeline is set up or the manual deploy process is documented | Yes | | |
| Rollback procedure is documented and tested | Yes | | |
| A freeze calendar exists for production change windows | Recommended | | |

### 3.3 — User adoption and training

| Question | Answer |
|----------|--------|
| How will users be informed the agent exists? | |
| Is a user guide or FAQ document planned? | |
| Are there any user groups who will resist adoption? What is the plan? | |
| How will user feedback in the first month be collected and acted on? | |
| Is a digital adoption platform (e.g. WalkMe) in use that should be updated? | |

### 3.4 — Operational cadence

| Cadence | Activity | Owner | Defined? |
|---------|---------|-------|---------|
| Daily (first 2 weeks — hypercare) | Monitor errors, fallback rate, user feedback | Agent owner | ☐ |
| Weekly | Review KQL dashboard metrics | Agent owner | ☐ |
| Monthly | Knowledge gap analysis from telemetry + eval re-run | Developer | ☐ |
| Quarterly | Full agent review: accuracy, coverage, user satisfaction | Agent owner + stakeholder | ☐ |

---

## 4 — Governance Prerequisites

### 4.1 — AI governance framework

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Organization has an AI use policy or acceptable use policy for AI tools | Yes | | |
| Responsible AI review process exists or `governance/ai-ethics-checklist.md` is adopted | Yes | | |
| Legal / compliance has reviewed the intended use of AI agents | Yes | | |
| Data Protection Officer (DPO) / Privacy has been consulted (if agents handle PII) | Required if PII | | |
| A process exists to handle user requests to opt out of AI interactions | Yes | | |

### 4.2 — Data and privacy

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Data classification policy defines what data agents can access | Yes | | |
| GDPR / local data protection obligations are met for conversation data | Yes | | |
| Conversation data retention policy is defined | Yes | | |
| PII is not logged in telemetry (confirmed by security review) | Yes | | |
| Data residency requirements are met by the Power Platform environment region | Yes | | |

### 4.3 — DLP and platform controls

| Prerequisite | Required | Current state | Gap |
|-------------|---------|---------------|-----|
| Power Platform DLP policy is applied to agent environments | Yes | | |
| DLP policy defines which connectors are allowed, blocked, and non-business | Yes | | |
| DLP policy has been reviewed with the agent's planned connectors | Yes | | |
| Generative AI feature policies in Power Platform admin are configured | Yes | | |
| Teams app submission and approval process is defined (for Teams-deployed agents) | Yes if Teams | | |

### 4.4 — Center of Excellence (CoE)

For organizations deploying more than 2–3 agents:

| Prerequisite | Recommended | Current state |
|-------------|-------------|---------------|
| A named AI Agent CoE lead or Power Platform CoE is identified | Yes | |
| Agent inventory / registry is maintained (name, owner, environment, use case) | Yes | |
| A reusable template library is maintained (this repository) | Yes | |
| A peer review process exists before agents are promoted to production | Yes | |
| A CoE communications channel exists (Teams channel, regular cadence) | Recommended | |

---

## 5 — Risk Register

Document risks identified during this assessment. Each risk must have a named owner and mitigation before go-live.

| Risk ID | Risk description | Likelihood | Impact | Mitigation | Owner |
|---------|-----------------|-----------|--------|-----------|-------|
| R-01 | Knowledge source content is stale at launch — users receive incorrect answers | Medium | High | Content audit (doc 06) + owner sign-off before go-live | |
| R-02 | Licensing is under-provisioned — agents throttle during peak usage | Medium | High | Model session volume before purchase; set up usage alerts | |
| R-03 | No support model — agent degrades after handover and no one notices | High | High | Define agent owner and support cadence before go-live | |
| R-04 | DLP policy blocks a required connector after build | Low | Critical | Confirm DLP policy with admin during technical discovery | |
| R-05 | Users lose trust after early incorrect answers | Medium | High | Set user expectations (AI disclaimer in greeting); define feedback channel | |
| R-06 | [Additional risk] | | | | |

---

## 6 — Readiness Scoring

Score each dimension. Items marked **Required** that are not in place count as blockers.

| Dimension | Total checks | Passed | Blockers (Required items not met) | Score |
|-----------|-------------|--------|----------------------------------|-------|
| Strategic alignment | | | | /10 |
| Technical infrastructure | | | | /10 |
| Operational readiness | | | | /10 |
| Governance readiness | | | | /10 |
| **Overall** | | | | **/40** |

### Recommendation

| Score range | Recommendation |
|-------------|---------------|
| 36–40, zero blockers | **Go** — proceed to build |
| 28–35, ≤ 2 blockers | **Conditional Go** — resolve blockers before go-live; build can start |
| < 28 or > 2 blockers | **No-Go** — resolve critical gaps before committing to build |

**Recommendation for this assessment:** _______________

**Justification:**

**Conditions (if Conditional Go):**

| Condition | Owner | Resolution date |
|-----------|-------|----------------|
| | | |

---

## 7 — Sign-Off

| Role | Name | Decision | Date |
|------|------|----------|------|
| Technology lead | | Go / Conditional Go / No-Go | |
| Executive sponsor | | Go / Conditional Go / No-Go | |
| Security / compliance | | Go / Conditional Go / No-Go | |
| Power Platform admin | | Go / Conditional Go / No-Go | |
