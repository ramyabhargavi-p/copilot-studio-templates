# Copilot Studio Agent — Master Index

This is the single guide to follow from start to finish. Work through the steps in order.
Each step links to the document you need. Check steps off as you complete them.

**Not a developer?** Every step is labelled with who does it. You do not need to touch YAML or code.

---

## Before You Begin — Tools Setup

| # | Do this | File | Who |
|---|---------|------|-----|
| 0 | Install required tools (pac CLI, VS Code extension, Git) | [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) | Developer |

---

## Phase 1 — Decision
*Should we build this? Before any technical or design work starts.*

| # | Do this | File | Who |
|---|---------|------|-----|
| 1 | Decide whether an AI agent is the right solution | [`project-delivery/00-ai-decision-framework.md`](project-delivery/00-ai-decision-framework.md) | Business Owner + Developer |
| 2 | Confirm the organisation is ready (licences, environments, governance) | [`project-delivery/10-enterprise-readiness-assessment.md`](project-delivery/10-enterprise-readiness-assessment.md) | Tech Lead + Security |

**Gate:** Both documents must be completed and signed off before Discovery begins.

---

## Phase 2 — Discovery
*What does the agent need to do, and what do we have to work with?*

| # | Do this | File | Who |
|---|---------|------|-----|
| 3 | Capture requirements — what the agent must do and for whom | [`project-delivery/01-requirements-questionnaire.md`](project-delivery/01-requirements-questionnaire.md) | Developer + Business Owner |
| 4 | Confirm the technical environment — environments, connectors, auth, App Insights | [`project-delivery/02-technical-discovery.md`](project-delivery/02-technical-discovery.md) | Developer + IT Admin |
| 5 | Map how users work today and how the agent will change that | [`project-delivery/11-user-workflow-analysis.md`](project-delivery/11-user-workflow-analysis.md) | Developer + Business SME |

**Gate:** All three documents complete before Design begins.

---

## Phase 3 — Design
*Decide what to build and how it will behave. Get sign-off before writing any YAML.*

| # | Do this | File | Who |
|---|---------|------|-----|
| 6 | Choose which components the agent needs (topics, knowledge, actions, auth) | [`project-delivery/03-agent-design-worksheet.md`](project-delivery/03-agent-design-worksheet.md) | Developer |
| 7 | Review and grade the documents/content the agent will search | [`project-delivery/06-content-audit.md`](project-delivery/06-content-audit.md) | Developer + Content Owner |
| 8 | Define every use case, business rule, and data requirement | [`project-delivery/07-functional-design-document.md`](project-delivery/07-functional-design-document.md) | Developer + Business Owner |
| 9 | Design conversation flows, branching logic, and slot collection | [`project-delivery/08-workflow-logic-design.md`](project-delivery/08-workflow-logic-design.md) | Developer |
| 10 | Design security, prompt patterns, and error handling architecture | [`project-delivery/09-technical-design-document.md`](project-delivery/09-technical-design-document.md) | Developer + Security |
| 11 | Select prompt engineering patterns and write the agent system prompt | [`prompts/ai-prompts/prompt-engineering-patterns.md`](prompts/ai-prompts/prompt-engineering-patterns.md) → then [`prompts/system-prompts/`](prompts/system-prompts/) | Developer |

**Gate:** Steps 8 (FDD) and 10 (TDD) must be signed off by Business Owner and Security before Build begins.

---

## Phase 4 — Build
*Implement the agent in YAML following the approved design.*

| # | Do this | File | Who |
|---|---------|------|-----|
| 12 | Pick the recipe closest to your agent type | [`recipes/`](recipes/) | Developer |
| 13 | Copy `base/` into your agent folder and replace all placeholders | [`base/`](base/) → [`base/README.md`](base/README.md) | Developer |
| 14 | Add components from the component library as needed | [`components/`](components/) | Developer |
| 15 | Follow the build checklist aligned to the approved design documents | [`project-delivery/12-build-specification.md`](project-delivery/12-build-specification.md) | Developer |
| 16 | Set up CI/CD pipelines for Dev → UAT → Prod promotion | [`ci-cd/`](ci-cd/) → [`ci-cd/README.md`](ci-cd/README.md) | Developer |

---

## Phase 5 — Test and Review
*Verify the agent works correctly and safely before any user sees it.*

| # | Do this | File | Who |
|---|---------|------|-----|
| 17 | Run automated topic routing tests (Eval) — target ≥ 85% accuracy | [`project-delivery/05-eval-scenarios.md`](project-delivery/05-eval-scenarios.md) | Developer |
| 18 | Complete the Responsible AI checklist | [`governance/ai-ethics-checklist.md`](governance/ai-ethics-checklist.md) | Developer + Project Owner |
| 19 | Complete the Security review | [`governance/security-review.md`](governance/security-review.md) | Developer + Security |
| 20 | Run User Acceptance Testing with real stakeholders — get sign-off | [`project-delivery/04-uat-test-plan.md`](project-delivery/04-uat-test-plan.md) | Tester + Business Owner |

**Gate:** All four steps must pass and be signed off. No exceptions before go-live.

---

## Phase 6 — Launch
*Go live and tell users.*

| # | Do this | File | Who |
|---|---------|------|-----|
| 21 | Complete every item on the pre-go-live checklist | [`launch/launch-checklist.md`](launch/launch-checklist.md) | Developer + Project Manager |
| 22 | Send the user announcement | [`launch/user-communication-template.md`](launch/user-communication-template.md) | Project Manager |
| 23 | Configure Azure Monitor alerts for errors and availability | [`operations/alert-setup.md`](operations/alert-setup.md) | Developer |

---

## Phase 7 — Operate
*Keep the agent healthy after go-live. Ongoing responsibility of the Agent Owner.*

| # | Do this | File | Who | Frequency |
|---|---------|------|-----|-----------|
| 24 | Monitor and respond to issues in the first two weeks | [`launch/hypercare-guide.md`](launch/hypercare-guide.md) | Agent Owner | Daily — weeks 1–2 |
| 25 | Run the health check dashboard queries | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) | Agent Owner | Weekly |
| 26 | Review unanswered questions and routing gaps | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) — "Unanswered questions" section | Agent Owner | Monthly |
| 27 | Respond to incidents using the runbook | [`operations/runbook.md`](operations/runbook.md) | Agent Owner | When needed |
| 28 | Full quarterly review with developer | [`BEST-PRACTICES.md`](BEST-PRACTICES.md) Section 11 | Agent Owner + Developer | Quarterly |

---

## Reference Materials
*Use these at any point in the project — they support multiple phases.*

| Document | What it covers | Most relevant at |
|----------|---------------|-----------------|
| [`BEST-PRACTICES.md`](BEST-PRACTICES.md) | Design guidelines, naming conventions, testing checklist | Build + Operate |
| [`INDUSTRY-GUIDELINES.md`](INDUSTRY-GUIDELINES.md) | Microsoft-specific and industry best practices | Design + Build |
| [`governance/enterprise-ai-governance-framework.md`](governance/enterprise-ai-governance-framework.md) | Full enterprise governance — roles, lifecycle, DLP, change control, incidents | All phases |
| [`TEAM-GUIDE.md`](TEAM-GUIDE.md) | What can be reused, onboarding checklist, known blockers | Before build starts |
| [`troubleshooting/README.md`](troubleshooting/README.md) | Common issues — Teams publishing, YAML errors, auth, routing | Build + Operate |
| [`prompts/ai-prompts/`](prompts/ai-prompts/) | AI generation prompts for topics, evals, adaptive cards | Build |
| [`ci-cd/solution-cli-guide.md`](ci-cd/solution-cli-guide.md) | Full `pac solution` CLI reference for solution-based ALM | Build + Deploy |

---

## Quick-Start Paths

If you already know your situation, skip ahead:

| Situation | Start at |
|-----------|---------|
| Just want to build a quick FAQ bot | Step 12 → pick `recipes/01-basic-faq.md` |
| First agent for the organisation — need full governance | Step 1 — do not skip Phase 1 |
| Re-using this kit for a second agent | Step 3 (skip Steps 1–2 if org readiness is already confirmed) |
| Something broke in production | [`troubleshooting/README.md`](troubleshooting/README.md) or [`operations/runbook.md`](operations/runbook.md) |
| New developer joining mid-project | [`TEAM-GUIDE.md`](TEAM-GUIDE.md) onboarding checklist |
| Need to explain the project to a stakeholder | [`project-delivery/07-functional-design-document.md`](project-delivery/07-functional-design-document.md) |

---

## Who Does What — Role Summary

| Role | Steps they own |
|------|---------------|
| **Business Owner / Project Sponsor** | 1, 3 (input), 8 (sign-off), 20 (sign-off), 21 (approve) |
| **Project Manager / Delivery Lead** | Gates between phases, coordinates 3–5, sends 22 |
| **Developer** | 0, 4–6, 8–16, 17, 18–19, 23 |
| **IT Admin / Environment Admin** | 4 (input), 16 (environment setup) |
| **Tester / QA** | 17–20 |
| **Security / Compliance Reviewer** | 2 (input), 10 (sign-off), 19 |
| **Agent Owner (post-launch)** | 24–28 |