# AI Engineer Realtime Guide

How to use the Microsoft AI Decision Framework concepts during an actual project — week by week, decision by decision. Use this alongside the numbered `project-delivery/` documents.

---

## How to read this guide

Each section maps to a project phase and tells you **exactly which framework concept to apply, when, and what output it produces**. The output is always a file, a YAML setting, or a component selection — not just a mental model.

---

## Week 0 — Pre-build (Sprint 0)

**Goal:** Leave this week with a completed `00-ai-decision-framework.md` and a confirmed recipe. No YAML yet.

### What to do

**1. Run the Nine Critical Questions (Step 3 of `00-ai-decision-framework.md`)**

Run through Q1–Q9 with the project sponsor and tech lead. Each answer is a constraint that narrows your choices.

| Question | Output it produces |
|----------|--------------------|
| Q1 — UX location | Which channel to configure in `settings.mcs.yml` |
| Q2 — Build style | Confirms Copilot Studio is right (vs Foundry or declarative agent) |
| Q3 — Grounding pattern | Which knowledge components to include |
| Q4 — Orchestration | Which recipe (01-06) to start from |
| Q5 — Trust boundary | Whether to use `authenticationMode: ManualAzureAD` or `None` |
| Q6 — Scale + cost | Whether to flag scale risk early (>8,000 RPM → needs escalation path) |
| Q7 — Action safety | Feeds directly into the Action Safety table below |
| Q8 — Team skills | Whether a maker can own parts or everything needs a pro developer |
| Q9 — Reactive vs proactive | Whether you need Power Automate triggers alongside the agent |

**2. Build the Action Safety table (Step 5 of `00-ai-decision-framework.md`)**

List every connector action the agent will call. Assign a tier to each. This table must be signed off before build starts.

```
| Action name          | Tier    | Guardrail                        |
|----------------------|---------|----------------------------------|
| GetLeaveBalance      | Low     | None (audit log only)            |
| SubmitLeaveRequest   | Medium  | confirmation-card before submit  |
| DeleteLeaveRequest   | High    | Approval flow + separate channel |
```

**3. Choose your interaction model (Step 6)**

- Immersive → configure Teams channel + conversation starters
- Assistive → build as declarative agent, surface in M365 Copilot
- Embedded → expose via Direct Line API, integrate into existing app

**4. Select recipe and components**

Use your Q1 + Q4 answers:

| Q4 answer | Q1 answer | Start with recipe |
|-----------|-----------|-------------------|
| Soloist | M365 apps | `01` or `02` |
| Soloist | Connector actions needed | `03` or `04` |
| Orchestra | Any | `05` |
| Full featured | Any | `06` |

**Week 0 exit criteria:**
- [ ] `00-ai-decision-framework.md` Decision Record filled in and signed
- [ ] Action Safety table complete with at least one row per planned action
- [ ] Recipe selected
- [ ] Highest Safety Tier documented (determines if approval flow is needed)

---

## Week 1–2 — Build

**Goal:** Working agent in Dev environment, all topics using the scaffold, every action wired with its guardrail.

### What to do

**1. Copy the base and scaffold — never start from scratch**

```bash
cp -r base/ agents/<your-agent>/
# Every new topic starts here — not a blank file:
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/<TopicName>.topic.mcs.yml
```

The scaffold already has error handling, telemetry, and CSAT built in. You fill in the logic — you don't write the plumbing.

**2. Map your IQ Layers to components**

| IQ Layer | What you need | Component to use |
|----------|--------------|-----------------|
| Foundry IQ (Memory/Grounding) | Answers from internal documents | `components/knowledge/sharepoint/` |
| Foundry IQ (public content) | Answers from public web pages | `components/knowledge/public-website/` |
| Work IQ (Live org context) | What was discussed in recent meetings, emails | SKILLS-REFERENCE.md → WorkIQ queries |
| Fabric IQ (Structured data) | Agent reasoning over Dataverse/SQL | Outside scope — use Fabric Data Agents |

**3. Implement Action Safety guardrails — tier by tier**

**Low tier (Read-only):** No guardrail needed. Use direct `InvokeConnectorTaskAction`. The scaffold's `LogCustomTelemetryEvent` already creates the audit trail.

**Medium tier (Write):** Add `confirmation-card.json` before every write action.
```bash
# Wire it into your topic's main logic (Option B in the scaffold):
# 1. SendActivity with confirmation-card
# 2. Question node to capture response
# 3. ConditionGroup: if confirmed → call action, else → cancel message
```

**High tier (Destructive):** Never execute inline. Always route through an approval flow.
```
Topic → confirmation-card → Power Automate approval flow
         (if approved) → action executes
         (if rejected) → topic sends cancellation message
```

**4. Declare Safety Tier in every connector action file**

Add this comment at the top of every `*-action.mcs.yml` file:
```yaml
# SAFETY TIER: Low / Medium / High
# GUARDRAIL: None / confirmation-card / approval-flow
# REASON: <one line explaining the classification>
```

**5. Scale check — early, not late**

Estimate your peak RPM:
```
Peak concurrent users × average messages per minute = peak RPM
```
If peak RPM > 6,000 (leaving 25% headroom before the 8,000 limit):
- Flag to the project sponsor now
- Consider batching, caching, or planning a Foundry migration path
- Document in `02-technical-discovery.md` under "Scale planning"

**Week 1–2 exit criteria:**
- [ ] All topics created from `_scaffold` (not blank YAML)
- [ ] Every connector action has a Safety Tier comment
- [ ] Confirmation card wired for all Medium tier actions
- [ ] Approval flow stub created for all High tier actions
- [ ] RPM estimate in `02-technical-discovery.md`
- [ ] Apply Changes succeeds with no errors (VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`)

---

## Week 3 — Test

**Goal:** 85%+ routing accuracy, all safety guardrails verified, CSAT flowing to App Insights.

### What to do

**1. Run eval scenarios (`05-eval-scenarios.md`)**

Target: ≥ 85% correct topic routing. Use `/copilot-studio:run-eval` or the Kit.

```
/copilot-studio:create-eval    → generate test cases from your topics
/copilot-studio:run-eval       → run batch evaluation
/copilot-studio:analyze-evals  → identify routing gaps
```

**2. Test Action Safety guardrails explicitly — not just happy path**

For every Medium tier action:
- [ ] Send the trigger phrase → confirm the confirmation card appears
- [ ] Click "Cancel" → confirm the action does NOT execute and a cancellation message appears
- [ ] Click "Confirm" → confirm the action executes and success message appears
- [ ] Simulate action failure → confirm error message appears (not raw error) and telemetry fires

For every High tier action:
- [ ] Trigger the topic → confirm it routes to the approval flow (does not execute inline)
- [ ] Approve in the approval flow → confirm action executes
- [ ] Reject in the approval flow → confirm topic sends rejection message

**3. Verify CSAT is collecting**

- Trigger a topic and complete it → confirm thumbs card appears at end
- Submit negative feedback → confirm rating card appears
- Give rating ≤ 3 → confirm text card appears
- Check App Insights in Azure Portal → verify `Feedback.Thumbs`, `Feedback.Rating`, `Feedback.Text` events appear

**4. Test failure paths — not just the golden path**

| Failure scenario | Expected behaviour |
|-----------------|-------------------|
| Connector action returns null | Error message (not blank), `Topic.ErrorOccurred` telemetry fires |
| Knowledge source returns no answer | Fallback topic triggers, user offered escalation |
| Auth fails during sign-in | OnError topic fires, safe message shown |
| User gives unexpected input in Question node | Agent prompts again or routes to fallback |

**Week 3 exit criteria:**
- [ ] Routing accuracy ≥ 85% confirmed in eval output
- [ ] All Safety Tier guardrails manually tested (confirm + cancel + failure)
- [ ] CSAT events visible in App Insights
- [ ] All failure paths tested and producing correct output

---

## Week 4 — Deploy

**Goal:** Signed-off agent in Prod, all governance complete.

### What to do

**1. Complete the Evaluation Criteria Checklist (Step 10B of `00-ai-decision-framework.md`)**

Five categories — all must pass:
- **Lifecycle:** Tech status GA (not Preview) for all components used
- **Architecture:** Tier assigned, orchestration pattern confirmed, data boundaries documented
- **Resources:** ALM pipeline in `ci-cd/` configured, team capacity confirmed post-launch
- **Governance:** Trust boundary confirmed, all High tier actions approved by security
- **Budget:** Cost model and monthly spend estimate signed off

**2. Complete the governance documents**

```
governance/ai-ethics-checklist.md    → complete all items
governance/security-review.md        → complete all items (especially prompt injection tests)
```

**3. Action Safety final audit**

One last check: run this search and confirm every result has a tier declaration:
```bash
grep -r "InvokeConnectorTaskAction" agents/ 
# For each match — confirm the file has a # SAFETY TIER: comment
```

**4. Go-live sequence**

```
launch/launch-checklist.md           → tick every box
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "<AgentName>" --environment <PROD_URL>
launch/user-communication-template.md → send to users
```

**5. Set up monitoring alerts**

```
operations/alert-setup.md            → configure Azure Monitor alerts
operations/monitoring-queries.md     → deploy KQL dashboard
```

**Week 4 exit criteria:**
- [ ] Evaluation Criteria Checklist all green
- [ ] Ethics and security checklists signed off
- [ ] Action Safety audit complete — every action has a declared tier
- [ ] Agent published (not just pushed)
- [ ] Monitoring alerts active
- [ ] User communication sent

---

## Post-launch — Operate and Scale

**Weekly (Agent Owner):**
- Run health check queries from `operations/monitoring-queries.md`
- Monitor `Agent.FallbackTriggered` rate — should stay < 20%
- Monitor `Action.Failed` rate — alert if > 5%
- Check CSAT thumbs-up rate — target ≥ 75% at 3 months

**Monthly (Agent Owner + Developer):**
- Review unanswered questions section in `operations/monitoring-queries.md`
- Add trigger phrases for topics that are consistently misrouted
- Audit `Agent.OutOfScope` events — high rates suggest scope mismatch

**When to trigger Progressive Enhancement (Studio → Foundry):**

| Signal | Action |
|--------|--------|
| RPM consistently > 6,000 | Plan multi-region or Foundry Agent Service migration |
| Topics require multi-step AI reasoning (Tier 3) | Build specialist agent in Foundry, expose as child agent via recipe 05 |
| Knowledge base > 10,000 documents with complex relationships | Move from SharePoint knowledge to Azure AI Search index |
| Mixed maker/developer team hitting Copilot Studio limits | Pattern 6: Progressive Enhancement — makers keep canvas, devs own Foundry services |

**CAF AI Adoption lifecycle (for org-level governance):**

| Phase | What happens |
|-------|-------------|
| Strategy | Business case approved, sponsor named |
| Plan | Architecture decision, team formed |
| Ready | Environments provisioned, DLP applied |
| Govern + Secure | Responsible AI checklist, security review |
| Build | This guide |
| Operate | Weekly/monthly health checks, incident response |

**Important deadline: Azure OpenAI Assistants API**
If anything in the project uses the Azure OpenAI Assistants API — it must migrate to the Responses API before **August 26, 2026**. The migration tool automates most of the conversion (Threads → Conversations, Runs → Responses, Assistants → Agents).

---

## Quick Decision Cards

Use these when you need a fast answer during build, not a full framework walkthrough.

---

### Card 1 — Which recipe?

```
Q: What does the agent do?

Answers questions from documents only
  → recipe 01 (no auth) or 02 (with auth)

Calls a Power Platform connector (submit, retrieve)
  → recipe 03

Calls an MCP tool
  → recipe 04

Routes to specialist sub-agents
  → recipe 05

All of the above
  → recipe 06
```

---

### Card 2 — Does this action need a confirmation card?

```
Q: What does this action DO?

Read only (GET, search, retrieve, summarise)
  → Safety Tier: Low → no card, just call the action

Create, submit, update, send
  → Safety Tier: Medium → add confirmation-card BEFORE calling

Delete, revoke, transfer, bulk modify
  → Safety Tier: High → approval flow required, never inline
```

---

### Card 3 — Which knowledge pattern?

```
Q: Where does the content live?

SharePoint document library (internal docs)
  → components/knowledge/sharepoint/ (Foundry IQ)

Public website or documentation URL
  → components/knowledge/public-website/ (Foundry IQ)

User's recent emails, meetings, Teams chats
  → WorkIQ skill (Work IQ) — for dev context or personalised responses

Dataverse tables or SQL data
  → Outside scope. Consider Fabric Data Agents or a connector action.
```

---

### Card 4 — Am I close to scale limits?

```
Q: What is my peak RPM?

< 3,000 RPM   → Fine. No action.
3,000–6,000   → Monitor. No action yet.
6,000–8,000   → Warning zone. Start planning multi-region.
> 8,000       → At risk of throttling. Escalate to architect.
              → Options: multi-region Copilot Studio, Foundry Agent Service

How to estimate:
  Peak concurrent users × messages per minute = peak RPM
  Example: 500 users × 5 msg/min = 2,500 RPM (safe)
  Example: 2,000 users × 5 msg/min = 10,000 RPM (over limit — needs plan)
```

---

### Card 5 — Who owns this part?

```
Q: Which team profile should handle this?

Conversation design (trigger phrases, responses, topic flow)
  → Maker / business SME with Copilot Studio UI

YAML components, connector actions, error handling, CI/CD
  → Professional developer

Custom model, eval harness, advanced grounding, Foundry
  → AI / ML engineer

Connector architecture, approval flows, Logic Apps
  → Integration architect

Agent Owner (post-launch health, CSAT review, incident response)
  → Named individual from the business — not IT
```

---

## Checklist: Did you use the framework?

Run this before submitting the project for go-live sign-off:

- [ ] `00-ai-decision-framework.md` Decision Record signed
- [ ] Nine Questions answered and documented
- [ ] Complexity tier confirmed
- [ ] Orchestration pattern selected
- [ ] Experience model confirmed
- [ ] IQ layers mapped to components
- [ ] Every connector action in the Action Safety table
- [ ] Guardrails implemented for all Medium and High tier actions
- [ ] Scale estimate documented
- [ ] Trust boundary confirmed
- [ ] Evaluation Criteria Checklist complete (5 categories)
- [ ] Progressive Enhancement path documented (when/how to scale up)
