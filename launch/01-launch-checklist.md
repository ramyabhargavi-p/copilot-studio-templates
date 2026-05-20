# Pre-Go-Live Launch Checklist

> **When to use:** The week before go-live. Work through phases with the project team.
> All items must be checked before enabling the agent for real users.
> Owner: Project Lead. Reviewer: Agent Owner.

Complete every item before publishing to your production channel. No item is optional.

---

## How to use this

Work through each section in order. Check off each item. If any item fails, fix it before proceeding. Get sign-off from the Project Owner on the final section.

---

## Phase 1 — Build Complete

| # | Item | Status |
|---|------|--------|
| B1 | All `<PLACEHOLDER>` values replaced in every YAML file | ☐ |
| B2 | All `_REPLACE` node IDs replaced with unique 6-character strings | ☐ |
| B3 | All topics have been smoke-tested in Copilot Studio test canvas | ☐ |
| B4 | Greeting fires on conversation start | ☐ |
| B5 | Fallback retries 3× then escalates | ☐ |
| B6 | OnError shows safe message in production simulation | ☐ |
| B7 | Out-of-scope queries redirect correctly | ☐ |
| B8 | YAML committed to version control (git repository up to date) | ☐ |

---

## Phase 2 — Eval Passed

| # | Item | Status |
|---|------|--------|
| E1 | Full eval CSV created with minimum row count (see `project-delivery/12-eval-scenarios.md`) | ☐ |
| E2 | Topic routing accuracy ≥ 85% | Score: ____% ☐ |
| E3 | Out-of-scope routing accuracy = 100% | ☐ |
| E4 | Response groundedness ≥ 80% (if knowledge sources present) | Score: ____% ☐ |
| E5 | Eval CSV committed to `evals/` folder in version control | ☐ |

---

## Phase 3 — Security and Governance

| # | Item | Status |
|---|------|--------|
| G1 | Responsible AI checklist completed and signed (`governance/02-ai-ethics-checklist.md`) | ☐ |
| G2 | Security review checklist completed (`governance/03-security-review.md`) | ☐ |
| G3 | Prompt injection resistance tests all passed | ☐ |
| G4 | No PII in telemetry events | ☐ |
| G5 | DLP policy confirmed with Power Platform admin | ☐ |

---

## Phase 4 — UAT Passed

| # | Item | Status |
|---|------|--------|
| U1 | All Section 1 (core system) UAT tests passed | ☐ |
| U2 | All Section 2 (topic) UAT tests passed | ☐ |
| U3 | All Section 3 (out-of-scope) UAT tests passed | ☐ |
| U4 | Knowledge search tests passed (if applicable) | ☐ / N/A |
| U5 | Authentication tests passed (if applicable) | ☐ / N/A |
| U6 | Action / integration tests passed (if applicable) | ☐ / N/A |
| U7 | Channel-specific tests passed (Teams, website, Copilot as applicable) | ☐ |
| U8 | Stakeholder sign-off received on UAT test plan | ☐ |

---

## Phase 5 — Operations Ready

| # | Item | Status |
|---|------|--------|
| O1 | Application Insights connected and receiving events | ☐ |
| O2 | Alert rules created (see `operations/01-alert-setup.md`) | ☐ |
| O3 | On-call contact identified and documented in 03-runbook | ☐ |
| O4 | Runbook (`operations/03-runbook.md`) reviewed and adapted for this agent | ☐ |
| O5 | Monitoring queries bookmarked in Application Insights | ☐ |

---

## Phase 6 — Deployment Ready

| # | Item | Status |
|---|------|--------|
| D1 | Final agent changes applied via VS Code "Apply Changes" + published via Copilot Studio portal or `pac copilot publish --bot "<schema>"` | ☐ |
| D2 | Published successfully in Copilot Studio (not just pushed) | ☐ |
| D3 | Published version verified in test canvas post-publish | ☐ |
| D4 | Correct channel(s) enabled and verified (Teams / website / Copilot) | ☐ |
| D5 | Agent owner has access to the Copilot Studio environment and Application Insights | ☐ |
| D6 | Git repository handed over / access granted to agent owner | ☐ |
| D7 | User communication sent (see `launch/02-user-communication-template.md`) | ☐ |

---

## Phase 7 — Hypercare Active

| # | Item | Status |
|---|------|--------|
| H1 | Hypercare schedule confirmed (see `launch/03-hypercare-guide.md`) | ☐ |
| H2 | Feedback channel (email or Teams) communicated to users | ☐ |
| H3 | Day 1 check-in scheduled for the morning after launch | ☐ |

---

## Final Sign-Off

| Role | Name | Date |
|------|------|------|
| Developer | | |
| Project Owner | | |
| Stakeholder (optional) | | |

**Go / No-Go decision:** ______________________
