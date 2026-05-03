# Start Here — What Is This and How Do I Use It?

This repository is a toolkit for building AI agents using Microsoft Copilot Studio. It contains everything a project team needs — from the first business conversation through to go-live and beyond — organised so that each role knows exactly what to do and when.

**You do not need to be a developer to use most of this toolkit.**

---

## What is a Copilot Studio Agent?

A Copilot Studio agent is an AI-powered assistant that lives inside Microsoft Teams, Microsoft Copilot, or your organisation's website. Users chat with it to get information, complete requests, or be connected to the right person — without waiting for email responses or searching through SharePoint.

Examples:
- An **HR agent** that answers leave policy questions and accepts leave requests
- An **IT helpdesk agent** that troubleshoots common problems and raises tickets automatically
- A **knowledge agent** that searches your internal documents and answers questions in plain language

---

## Who does what?

Find your role and go straight to what you need.

---

### I am a business owner / project sponsor

You define what the agent should do and for whom. You don't need to know anything technical.

**Your steps:**

| Step | What you do | Document |
|------|------------|---------|
| 1 | Decide whether an AI agent is the right solution | [`project-delivery/00-ai-decision-framework.md`](project-delivery/00-ai-decision-framework.md) |
| 2 | Answer questions about the agent's purpose, scope, and who it serves | [`project-delivery/01-requirements-questionnaire.md`](project-delivery/01-requirements-questionnaire.md) |
| 3 | Review and approve what the agent will and won't do | [`project-delivery/07-functional-design-document.md`](project-delivery/07-functional-design-document.md) |
| 4 | Review and sign off on test results before go-live | [`project-delivery/04-uat-test-plan.md`](project-delivery/04-uat-test-plan.md) |
| 5 | Approve the pre-go-live checklist | [`launch/launch-checklist.md`](launch/launch-checklist.md) |
| 6 | Nominate someone as the ongoing agent owner | [`governance/enterprise-ai-governance-framework.md`](governance/enterprise-ai-governance-framework.md) Section 2 |

**What you don't need to do:** anything involving YAML, code, or the Power Platform admin portal.

---

### I am a project manager / delivery lead

You coordinate the delivery from first meeting to go-live. You don't write code, but you run the process.

**Your delivery checklist:**

| Phase | Document | Your role |
|-------|---------|----------|
| Pre-project | [`project-delivery/10-enterprise-readiness-assessment.md`](project-delivery/10-enterprise-readiness-assessment.md) | Ensure all readiness checks are completed before committing |
| Discovery | [`project-delivery/01-requirements-questionnaire.md`](project-delivery/01-requirements-questionnaire.md) | Facilitate the stakeholder session |
| Discovery | [`project-delivery/11-user-workflow-analysis.md`](project-delivery/11-user-workflow-analysis.md) | Ensure user representatives are involved |
| Design | [`project-delivery/07-functional-design-document.md`](project-delivery/07-functional-design-document.md) | Get stakeholder sign-off before build starts |
| Governance | [`governance/ai-ethics-checklist.md`](governance/ai-ethics-checklist.md) | Ensure this is completed before UAT |
| UAT | [`project-delivery/04-uat-test-plan.md`](project-delivery/04-uat-test-plan.md) | Coordinate the testing session; collect sign-off |
| Launch | [`launch/launch-checklist.md`](launch/launch-checklist.md) | Gate the go-live decision |
| Launch | [`launch/user-communication-template.md`](launch/user-communication-template.md) | Send the announcement |
| Post-launch | [`launch/hypercare-guide.md`](launch/hypercare-guide.md) | Monitor the first two weeks |

**Full delivery sequence:** See [`project-delivery/README.md`](project-delivery/README.md)

---

### I am a developer (new to Copilot Studio)

You'll build the agent. This toolkit gives you the YAML templates, component library, and step-by-step guides so you don't start from scratch.

**Where to start:**

1. Read `GETTING-STARTED.md` — it walks you through every phase with exact commands
2. Install the tools in `TOOLS-AND-PLUGINS.md` (especially the VS Code extension)
3. Copy `base/` into your agent project folder
4. Pick the recipe from `recipes/` that most closely matches your agent type
5. Use the prompts in `prompts/ai-prompts/` to generate YAML you're not sure how to write

**When the design documents are approved:** follow `project-delivery/12-build-specification.md` — it's a step-by-step build checklist aligned to every approved design document.

---

### I am a developer (experienced with Copilot Studio)

Go straight to [`README.md`](README.md) for the full component and recipe reference.

Key shortcuts:
- Build checklist: [`project-delivery/12-build-specification.md`](project-delivery/12-build-specification.md)
- Prompt patterns: [`prompts/ai-prompts/prompt-engineering-patterns.md`](prompts/ai-prompts/prompt-engineering-patterns.md)
- CI/CD pipelines: [`ci-cd/`](ci-cd/)
- Solution CLI reference: [`ci-cd/solution-cli-guide.md`](ci-cd/solution-cli-guide.md)

---

### I am a tester / QA analyst

You validate the agent works correctly before it goes live. You don't need to understand the YAML.

**Your documents:**

| Document | What you do with it |
|---------|---------------------|
| [`project-delivery/05-eval-scenarios.md`](project-delivery/05-eval-scenarios.md) | Understand what evaluation tests are and review the test CSV |
| [`project-delivery/04-uat-test-plan.md`](project-delivery/04-uat-test-plan.md) | Run through each test section; record Pass/Fail; note issues |

**How UAT works in practice:**
1. The developer shares the link to the agent in the Copilot Studio test canvas (or Teams)
2. You work through `04-uat-test-plan.md` section by section — it tells you exactly what to type and what to expect
3. You record Pass or Fail for each test
4. Outstanding issues go in the table at the bottom of the document
5. When all critical tests pass, you sign off

---

### I am a security or compliance reviewer

You ensure the agent handles data correctly, meets organisational policies, and doesn't expose the organisation to risk.

**Your documents:**

| Document | What to check |
|---------|--------------|
| [`governance/ai-ethics-checklist.md`](governance/ai-ethics-checklist.md) | Responsible AI — fairness, safety, privacy, transparency, accountability, prompt injection |
| [`governance/security-review.md`](governance/security-review.md) | Authentication, data handling, DLP, connectors, channel security |
| [`project-delivery/09-technical-design-document.md`](project-delivery/09-technical-design-document.md) | Security design section — review Section 3 |
| [`governance/enterprise-ai-governance-framework.md`](governance/enterprise-ai-governance-framework.md) | Data classification policy, DLP requirements, incident governance |

You do not need to read any YAML files. The checklist documents are written in plain language.

---

### I am the agent owner (post-launch)

You are responsible for the agent after it goes live. You manage its health, approve changes, and ensure it stays accurate over time.

**Your ongoing responsibilities:**

| When | What you do | Where |
|------|------------|-------|
| Daily (first 2 weeks) | Check for errors and user feedback | [`launch/hypercare-guide.md`](launch/hypercare-guide.md) |
| Weekly | Review the monitoring dashboard | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) |
| Monthly | Review knowledge gaps and trigger phrase accuracy | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) — "Unanswered questions" query |
| Quarterly | Full agent review with the developer | [`BEST-PRACTICES.md`](BEST-PRACTICES.md) Section 11 |
| When something breaks | Follow the incident procedures | [`operations/runbook.md`](operations/runbook.md) |

You don't need to write any code. Your role is oversight, sign-off on changes, and being the first call when something goes wrong.

---

## The Big Picture — What Happens and In What Order

```
SHOULD WE BUILD AN AGENT?
  Is this the right tool for this problem?
  → project-delivery/00-ai-decision-framework.md
        │
        ▼
ARE WE READY TO BUILD?
  Licensing, environments, governance, support model in place?
  → project-delivery/10-enterprise-readiness-assessment.md
        │
        ▼
WHAT DOES THE AGENT NEED TO DO?
  Discovery: requirements, technical setup, user workflows
  → project-delivery/01, 02, 11
        │
        ▼
HOW WILL IT WORK?
  Design: use cases, conversation flows, security, prompt patterns
  → project-delivery/03, 06, 07, 08, 09
  → prompts/ai-prompts/prompt-engineering-patterns.md
        │
        ▼
BUILD IT
  Implement in YAML following the approved design
  → project-delivery/12-build-specification.md
  → base/ + components/ + recipes/
        │
        ▼
DOES IT WORK?
  Eval (automated routing accuracy) + UAT (stakeholder testing)
  → project-delivery/05-eval-scenarios.md
  → project-delivery/04-uat-test-plan.md
        │
        ▼
IS IT SAFE?
  Responsible AI + Security review
  → governance/ai-ethics-checklist.md
  → governance/security-review.md
        │
        ▼
GO LIVE
  Pre-go-live checklist → deploy → announce to users
  → launch/launch-checklist.md
  → launch/user-communication-template.md
        │
        ▼
KEEP IT WORKING
  Monitor, improve, review quarterly
  → operations/
  → launch/hypercare-guide.md
```

---

## Plain Language Glossary

| Term | What it means |
|------|--------------|
| **Copilot Studio** | Microsoft's tool for building AI agents — no coding experience required for simple agents; YAML editing required for advanced ones |
| **Agent** | The AI assistant your users will chat with |
| **Topic** | A specific task or conversation the agent can handle (e.g. "Check leave balance") |
| **Knowledge source** | A SharePoint document library or website the agent can search to answer questions |
| **Action** | A connection to another system (e.g. submitting a leave request to an HR system) |
| **Trigger phrase** | The type of message a user sends that starts a particular topic |
| **Fallback** | What the agent does when it doesn't understand the user's message |
| **Escalation** | Transferring the user to a human agent |
| **Eval** | Automated testing of whether the agent routes user messages to the correct topic |
| **UAT** | User Acceptance Testing — a structured session where real users test the agent before go-live |
| **YAML** | The file format used to define the agent's structure — only developers need to read or write this |
| **pac CLI** | A command-line tool for pushing agent files to the Microsoft Power Platform — developers only |
| **Environment** | A Microsoft Power Platform workspace — like a folder in the cloud where the agent lives |
| **Telemetry** | Usage data sent to Application Insights — shows how users interact with the agent |
| **DLP** | Data Loss Prevention — a policy that controls which external systems the agent can connect to |

---

## Common Questions from Non-Developers

**Q: Do I need to write code to use this?**
No — the requirements questionnaire, design worksheets, UAT test plan, governance checklists, and launch documents are all plain-language Word-style documents. Only the YAML building step requires a developer.

**Q: How long does it take to build an agent?**
A simple FAQ agent (knowledge search + out-of-scope + escalation) takes 1–2 days to build after the design is approved. A full-featured agent with multiple topics, connector actions, and authentication takes 1–2 weeks. This toolkit significantly reduces both timelines.

**Q: What if the agent gives wrong answers?**
All knowledge agents can give imprecise answers — this is inherent to AI. The eval testing and grounding patterns in this toolkit reduce this significantly. The `governance/ai-ethics-checklist.md` includes specific prompt injection and hallucination tests that must pass before go-live. The monitoring setup ensures you catch problems quickly after launch.

**Q: Who is responsible for the agent once it's live?**
The **agent owner** — a named individual, not a team. They receive incident alerts, approve changes, and ensure the content stays up to date. See `governance/enterprise-ai-governance-framework.md` for the full owner responsibilities.

**Q: Can we add features after go-live?**
Yes — this is called a change. The governance framework defines what level of approval is needed: minor changes (text updates) need agent owner only; new topics or connectors need agent owner + project owner. All changes go through the same eval and test process as the original build.
