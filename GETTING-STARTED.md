# Getting Started — Complete Guide for New Developers

> **Where you are:** Step 2 of 13 in [`README.md`](README.md). Step 1 (tools setup) should already be done. Step 3 (UI guide) follows this document.

This guide walks you through building and deploying a Copilot Studio agent from scratch using this template library. It covers every phase: Discovery → Design → Build → Test → Deploy → Operate.

No prior Copilot Studio experience required.

---

## What You Need Before Starting

| Prerequisite | Where to get it |
|-------------|----------------|
| Microsoft 365 / Power Platform account | Your IT admin |
| Copilot Studio licence | Your IT admin |
| Power Platform environment (Dev + UAT + Prod) | Your IT admin or environment admin |
| `pac` CLI installed and authenticated | [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) |
| VS Code + Copilot Studio extension | VS Code Marketplace — search "Copilot Studio" |
| Git installed | [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) |

Don't have everything above? Complete [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) first.

---

## The 4 Phases at a Glance

```
Phase 1 — Discovery    What to build and for whom
Phase 2 — Design       Translate requirements into specific files
Phase 3 — Build        Copy, fill in, push
Phase 4 — Test + Ship  Verify it works, get sign-off, go live
```

Each phase has a gate. Don't skip a gate — open questions mid-build become blockers.

---

## Phase 1 — Discovery

> **Goal:** Know exactly what to build before writing a single line of YAML.

### Step 1.1 — Decide if an agent is even the right solution

Fill in [`project-delivery/00-ai-decision-framework.md`](project-delivery/00-ai-decision-framework.md) with your project sponsor.

The key questions:
- Does the problem require natural language understanding, or would a form or search page do?
- Is the business outcome measurable? (ticket deflection, time saved, etc.)
- Do you have the licensing, environment, and content ready?

If all three pass → proceed. If not → the document tells you what alternative to use instead.

**Why this matters:** Skipping this step is the single biggest cause of agents being rebuilt or abandoned. Thirty minutes here saves weeks later.

---

### Step 1.2 — Capture requirements

Fill in [`project-delivery/01-requirements-questionnaire.md`](project-delivery/01-requirements-questionnaire.md) with your business stakeholder.

The answers that drive the most downstream decisions:

| Question | What it determines |
|----------|-------------------|
| Q4 — Top 5 things users will ask | Your topic list |
| Q5 — Top 5 out-of-scope areas | System prompt + OutOfScope topic |
| Q6 — Escalation path | Fallback and Escalation component config |
| Q7 — Does it need auth? | `authenticationMode` in `settings.mcs.yml` |
| Q9 — What documents/content? | Knowledge source files and SharePoint paths |
| Q18 — Feedback method? | Whether to include the Feedback topic |

---

### Step 1.3 — Run technical discovery

Fill in [`project-delivery/02-technical-discovery.md`](project-delivery/02-technical-discovery.md) with your environment admin.

Must be confirmed before build:
- Environment name and ID (Dev, UAT, Prod)
- Authentication mode and Azure AD app registration (if auth required)
- Connector availability and DLP policy
- SharePoint library paths with confirmed read access
- Escalation queue name (exact string — typos break handoff)
- Application Insights workspace ID

**Phase 1 gate:** Every field in `01` and `02` is filled in and signed off. Do not start design with open questions.

---

## Phase 2 — Design

> **Goal:** Map every requirement to a specific file or component before writing any YAML.

### Step 2.1 — Complete the agent design worksheet

Fill in [`project-delivery/03-agent-design-worksheet.md`](project-delivery/03-agent-design-worksheet.md).

This translates your requirements into:
- Which recipe to start from (01–06)
- Which components to add from `components/`
- Which knowledge sources to configure
- What the system prompt needs to say

---

### Step 2.2 — Audit your content

Fill in [`project-delivery/06-content-audit.md`](project-delivery/06-content-audit.md) with the content owner.

Before pointing the agent at SharePoint:
- Is the content up to date?
- Is it in a format the knowledge source can index? (Word, PDF, HTML — not images)
- Does it contain PII that shouldn't appear in agent responses?

An agent is only as good as the content it searches. Bad content = bad answers.

---

### Step 2.3 — Write the functional design

Fill in [`project-delivery/07-functional-design-document.md`](project-delivery/07-functional-design-document.md).

This defines every use case, its expected input, expected output, and any business rules. It becomes the baseline for UAT — if it's not here, testers won't know what to verify.

---

### Step 2.4 — Design conversation flows

Fill in [`project-delivery/08-workflow-logic-design.md`](project-delivery/08-workflow-logic-design.md).

Map each topic's conversation flow before writing YAML:
- What triggers it?
- What does it collect from the user?
- What does it do with that input?
- What does it return?
- What happens on failure?

---

### Step 2.5 — Classify every action's safety tier

For every connector action the agent will call, assign a safety tier before build starts.
See [`project-delivery/00-ai-decision-framework.md`](project-delivery/00-ai-decision-framework.md) Step 5.

| Tier | Action type | Guardrail |
|------|------------|-----------|
| Low | Read/search/retrieve | None — telemetry only |
| Medium | Create/submit/update | Confirmation card before calling |
| High | Delete/revoke/bulk change | Approval flow — never inline |

**Phase 2 gate:** Steps 7 (FDD) and 10 (TDD) signed off by business owner and security before build begins.

---

## Phase 3 — Build

> **Goal:** Copy the base, add components, fill in placeholders, push.

### Step 3.1 — Pick your recipe

Choose the recipe that matches your agent type from [`QUICKSTART.md`](QUICKSTART.md) or [`recipes/`](recipes/).

| If you're building… | Use recipe |
|--------------------|-----------|
| FAQ / knowledge bot from SharePoint | `01-basic-faq` |
| Same but users must sign in | `02-authenticated-agent` |
| Agent that submits data to a system | `03-connector-action-agent` |
| Agent that calls an MCP tool | `04-mcp-action-agent` |
| Orchestrator with specialist sub-agents | `05-orchestrator-agent` |
| All of the above | `06-full-featured-agent` |

---

### Step 3.2 — Copy the base

```bash
cp -r base/ agents/<your-agent-name>/
```

The base gives you 5 files every agent needs:

| File | What it does |
|------|-------------|
| `agent.mcs.yml` | Agent identity, system prompt, conversation starters |
| `settings.mcs.yml` | Auth mode, recognizer, language, who can access |
| `Greeting.topic.mcs.yml` | First message + `Conversation.Started` telemetry |
| `Fallback.topic.mcs.yml` | Unknown intent — retries 3× then escalates |
| `OnError.topic.mcs.yml` | System error handler — safe message + telemetry |

---

### Step 3.3 — Fill in the required values

Open each file and replace:

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | Your schema name e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | Display name e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | 2–3 sentences: what the agent does + what it won't answer |
| `settings.mcs.yml` | `<agent_schema_name>` | Same as `<AgentName>` |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | Same as `<AgentName>` |

For the system prompt, use the structure in [`prompts/ai-prompts/generate-agent-instructions.md`](prompts/ai-prompts/generate-agent-instructions.md) or copy from [`prompts/system-prompts/`](prompts/system-prompts/).

---

### Step 3.4 — Add components

Copy the components your recipe needs. Each recipe's README has exact copy commands.

For every new topic you create — start from the scaffold, not a blank file:

```bash
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/<TopicName>.topic.mcs.yml
```

The scaffold has error handling, telemetry, and CSAT built in. See [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md) for call signatures of all components.

---

### Step 3.5 — Replace all `_REPLACE` node IDs

Every node ID in the YAML uses a `_REPLACE` suffix. Replace each with a unique 6-character string.

```bash
# macOS / Linux
for f in $(find . -name "*.yml"); do
  while grep -q '_REPLACE' "$f"; do
    id=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c6)
    sed -i "s/_REPLACE[0-9]*/$id/" "$f"
  done
done

# Windows PowerShell
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = $content -replace '_REPLACE\d*', "_$id", 1
  }
  Set-Content $_.FullName $content
}
```

---

### Step 3.6 — Push to Copilot Studio

```bash
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID> \
  --environment <ENV_URL>
```

Then apply changes: VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`

If Apply Changes fails, run `/copilot-studio:validate` or check for any remaining `<PLACEHOLDER>` values with:
```bash
grep -r '<' agents/<your-agent>/
```

> **Next:** Open [`COPILOT-STUDIO-UI-GUIDE.md`](COPILOT-STUDIO-UI-GUIDE.md) (README step 3) — it shows exactly where each template type appears in the Copilot Studio web UI after you push.

---

### Step 3.7 — Test in Copilot Studio

Open Copilot Studio → find your agent → click **Test** (right-hand pane).

- Ask each trigger phrase — confirm it routes to the correct topic
- Force a failure — confirm the error message is safe (not a raw error)
- Ask an out-of-scope question — confirm the redirect fires
- Check Variables tab — confirm `Global.FeedbackShown` is set after CSAT fires

Full UI testing steps: [`COPILOT-STUDIO-UI-GUIDE.md`](COPILOT-STUDIO-UI-GUIDE.md) → Testing section
Full build checklist: [`project-delivery/12-build-specification.md`](project-delivery/12-build-specification.md)

---

## Phase 4 — Test and Ship

> **Goal:** Verified agent, signed-off, published.

### Step 4.1 — Run automated routing tests

Target: **≥ 85% topic routing accuracy**.

```
/copilot-studio:create-eval     Generate test cases from your topics
/copilot-studio:run-eval        Run batch evaluation
/copilot-studio:analyze-evals   Identify and fix routing gaps
```

Or follow [`project-delivery/05-eval-scenarios.md`](project-delivery/05-eval-scenarios.md) manually.

---

### Step 4.2 — Complete the Responsible AI review

Fill in [`governance/ai-ethics-checklist.md`](governance/ai-ethics-checklist.md).

Key checks:
- Prompt injection resistance (tests I1–I5)
- Out-of-scope handling verified
- Escalation path confirmed and tested
- No PII logged in telemetry

---

### Step 4.3 — Complete the security review

Fill in [`governance/security-review.md`](governance/security-review.md).

Key checks:
- Connector permissions use least-privilege
- DLP policy confirmed
- Action Safety tier declared for every connector action

---

### Step 4.4 — Run UAT with real stakeholders

Follow [`project-delivery/04-uat-test-plan.md`](project-delivery/04-uat-test-plan.md).

UAT is done by real users — not the developer. The business owner signs off before go-live.

---

### Step 4.5 — Go live

Complete [`launch/launch-checklist.md`](launch/launch-checklist.md) — every item.

Then:
```bash
pac copilot publish --bot "<AgentName>" --environment <PROD_ENV_URL>
```

Send the user announcement: [`launch/user-communication-template.md`](launch/user-communication-template.md)

Set up monitoring: [`operations/alert-setup.md`](operations/alert-setup.md)

---

## After Go-Live

Once the agent is live, operational responsibility passes to the **Agent Owner** (a named individual, not IT in general).

| Task | File | Frequency |
|------|------|-----------|
| Health check queries | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) | Weekly |
| Review unanswered questions | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) — Unanswered section | Monthly |
| Respond to incidents | [`operations/runbook.md`](operations/runbook.md) | When needed |
| First two weeks hypercare | [`launch/hypercare-guide.md`](launch/hypercare-guide.md) | Daily — weeks 1–2 |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Apply Changes fails with schema error | Check for remaining `<PLACEHOLDER>` values |
| Agent doesn't answer from SharePoint | Confirm the URL is accessible and content is indexed |
| `_REPLACE` still in YAML after the script | Run `grep -r '_REPLACE' .` to find remaining ones |
| Agent shows error in Copilot Studio | Check `OnError.topic.mcs.yml` — `<AGENT_SCHEMA>` must match `schemaName` exactly |
| Teams channel not showing the agent | Agent must be **published** (not just pushed) |

Full troubleshooting: [`troubleshooting/README.md`](troubleshooting/README.md)

---

## Where to go next

| What you want to do | Where to go |
|--------------------|------------|
| Add CSAT feedback | `components/topics/feedback/` → call via `BeginDialog` at topic end |
| Add user sign-in | Recipe `02-authenticated-agent` |
| Add connector actions | Recipe `03-connector-action-agent` + `COMPONENT-REGISTRY.md` |
| Set up CI/CD pipeline | `ci-cd/README.md` |
| Full governance for enterprise rollout | `project-delivery/00-ai-decision-framework.md` → work all phases |
| All reusable components and call signatures | `COMPONENT-REGISTRY.md` |
| Week-by-week AI engineer guide | `project-delivery/13-ai-engineer-realtime-guide.md` |
