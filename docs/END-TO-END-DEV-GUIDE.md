# End-to-End Development Guide — Copilot Studio Templates

Full journey from zero to a live production agent. Every step shown two ways:
- **With UI** — using the Copilot Studio web interface at make.preview.microsoft.com
- **Without UI** — pure CLI + VS Code + YAML (recommended for teams, CI/CD, version control)

Both tracks use the same YAML templates. The CLI pushes YAML to the UI; the UI exports back to YAML.

---

## Overview — All Phases

```
Phase 0 — Setup          Install tools, authenticate, connect to environment
Phase 1 — Discovery      Decide what to build and for whom
Phase 2 — Design         Map requirements to files and components
Phase 3 — Build          Copy templates, fill placeholders, push to environment
Phase 4 — Test           Verify routing, safety, CSAT, and failure paths
Phase 5 — Deploy         Publish to users (Dev → UAT → Prod)
Phase 6 — Operate        Monitor health, respond to incidents, improve over time
```

Estimated total time for a simple agent (recipe 01 or 02): **3–4 hours first time, 1–2 hours after.**

---

---

# Phase 0 — Setup

## 0.1 — Install tools

### Without UI (CLI-first)

```powershell
# 1. pac CLI — push/pull/publish agent YAML
winget install Microsoft.PowerAppsCLI

# 2. VS Code — edit YAML files
winget install Microsoft.VisualStudioCode

# 3. Git — version control
winget install Git.Git

# 4. Node.js — only if running batch evals with the Kit
winget install OpenJS.NodeJS.LTS

# Verify all installs (close and reopen terminal first)
pac --version
code --version
git --version
node --version
```

→ Full options and troubleshooting: [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md)
→ Full pac command reference: [`commands/pac-commands.md`](../commands/pac-commands.md)

### With UI only

No CLI installation needed. Open your browser:
- Go to [make.preview.microsoft.com](https://make.preview.microsoft.com)
- Sign in with your Microsoft 365 / Power Platform account
- Select your environment from the top-right dropdown
- Navigate to **Copilot Studio**

---

## 0.2 — Authenticate and connect to environment

### Without UI

```bash
# Step 1 — log in via browser (one-time per machine)
pac auth create
# Browser opens → sign in with your Microsoft 365 account → close browser tab

# Step 2 — see all environments you have access to
pac env list
# Output:
# Environment Name       | Type       | URL                                   | ID
# Dev - HR Project       | Developer  | https://yourorg-dev.crm.dynamics.com  | xxxx-...
# UAT - HR Project       | Sandbox    | https://yourorg-uat.crm.dynamics.com  | xxxx-...
# Prod - HR Project      | Production | https://yourorg.crm.dynamics.com       | xxxx-...

# Step 3 — connect to your Dev environment
pac env select --environment "Dev - HR Project"

# Step 4 — confirm connection
pac env who
# Connected to: Dev - HR Project | https://yourorg-dev.crm.dynamics.com | you@org.com

# Step 5 — see agents already in this environment
pac copilot list
# Actual output format (pac 2.7.4):
# Name         Copilot ID                           Component State  Is Managed  Status Code  State Code
# HR Assistant xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx Published        False       Active       Provisioned
# IT Helpdesk  yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy Draft            False       Active       Provisioned
#
# IMPORTANT: Copy the Copilot ID (GUID) — --bot requires the GUID, NOT the display name

# Step 6 — open an existing agent (three options — pick one)

# Option A: open in Copilot Studio browser UI directly
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → click your agent → Test pane

# Option B: pull agent files to your machine to edit locally
# 6a. Create output directory first (required — command fails without it)
mkdir agents\hr-assistant
# 6b. Extract using the GUID from Step 5 output (display name does NOT work)
pac copilot extract-template \
  --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --templateFileName ./agents/hr-assistant/agent.yaml \
  --templateVersion 1.0.0
# OR VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"

# Option C: if you already pulled the files, just open in VS Code
code ./agents/hr-assistant/
```

### With UI

1. Go to [make.preview.microsoft.com](https://make.preview.microsoft.com)
2. Top-right corner → environment picker dropdown
3. Select **Dev - HR Project** (or your dev environment)
4. Left sidebar → **Copilot Studio**
5. Your agents appear in the list → click the agent name to open it

---

## 0.3 — Install VS Code Copilot Studio Extension

### Without UI

```bash
# Open VS Code
code .

# In VS Code:
# Ctrl+Shift+X → search "Copilot Studio" → Install (publisher: Microsoft)
```

→ Full VS Code shortcuts: [`commands/vscode-commands.md`](../commands/vscode-commands.md)

### With UI

Not applicable — the extension is only for local YAML editing.

---

---

# Phase 1 — Discovery

> **Goal:** Know exactly what to build before writing a single YAML line. Wrong decisions here mean rebuilds later.

## 1.1 — Decide if an AI agent is the right solution

Fill in: [`project-delivery/00-ai-decision-framework.md`](../project-delivery/00-ai-decision-framework.md)

Run the Nine Critical Questions (Q1–Q9) with your project sponsor:

| Question | What it decides |
|----------|----------------|
| Q1 — Where do users work? | Channel: Teams / SharePoint / custom / headless |
| Q2 — Build style? | SaaS (Copilot Studio) / Orchestration / Pro-Code |
| Q3 — Data grounding? | RAG (SharePoint) / Memory (Foundry) / Analytics (Fabric) |
| Q4 — Orchestration complexity? | Soloist / Orchestra (hub-and-spoke) / Mesh |
| Q5 — Compliance boundary? | M365 / Power Platform / Azure Landing Zone |
| Q6 — Scale? | Under 8,000 RPM → Copilot Studio; above → evaluate Foundry |
| Q7 — Action safety? | Read (Low) / Write (Medium) / Destructive (High) |
| Q8 — Team skills? | Maker / Pro-Dev / AI-ML |
| Q9 — Reactive or proactive? | User-triggered vs scheduled/event-driven |

**Output:** confirmed recipe (01–06) + technology stack decision

### Without UI

Edit the markdown file in VS Code:
```bash
code project-delivery/00-ai-decision-framework.md
```

### With UI

Open the file in VS Code alongside your browser. The framework doc is a decision worksheet — there is no UI equivalent.

---

## 1.2 — Capture requirements

Fill in: [`project-delivery/01-requirements-questionnaire.md`](../project-delivery/01-requirements-questionnaire.md)

Run with your business stakeholder. The answers that drive the most downstream decisions:

| Question | Drives |
|----------|--------|
| Top 5 things users will ask | Your topic list |
| Top 5 out-of-scope areas | System prompt + OutOfScope topic |
| Escalation path (queue name, email) | Fallback + Escalation component |
| Does it need sign-in? | `authenticationMode` in `settings.mcs.yml` |
| What documents / content? | Knowledge source paths |
| Feedback method? | Whether to include Feedback topic |

---

## 1.3 — Run technical discovery

Fill in: [`project-delivery/02-technical-discovery.md`](../project-delivery/02-technical-discovery.md)

Confirm before build starts:

```
□ Environment name and URL (Dev, UAT, Prod)
□ Azure AD app registration (if auth required)
□ Connector IDs and DLP policy
□ SharePoint library URLs — confirmed readable
□ Escalation queue name (exact string — typos break handoff)
□ Application Insights workspace ID
```

**Phase 1 gate:** `01` and `02` filled and signed off → proceed to Design.

---

---

# Phase 2 — Design

> **Goal:** Map every requirement to a specific file or component before writing YAML.

## 2.1 — Choose your recipe

Open [`recipes/README.md`](../recipes/README.md) and pick:

| Agent type | Recipe | Time |
|-----------|--------|------|
| FAQ / knowledge bot from SharePoint | `01-basic-faq` | 30 min |
| Same but with user sign-in | `02-authenticated-agent` | 45 min |
| Submits/retrieves data via connector | `03-connector-action-agent` | 60 min |
| Calls an MCP tool | `04-mcp-action-agent` | 60 min |
| Multiple specialist sub-agents | `05-orchestrator-agent` | 2+ hr |
| Auth + knowledge + actions + CSAT | `06-full-featured-agent` | 2+ hr |

Open the chosen recipe file — it lists exactly which template files to copy and which values to change.

---

## 2.2 — Design worksheet and content audit

```
project-delivery/03-agent-design-worksheet.md   → which components to add
project-delivery/06-content-audit.md            → is SharePoint content ready to index?
project-delivery/07-functional-design-document.md → every use case and expected output
project-delivery/08-workflow-logic-design.md    → conversation flow per topic
project-delivery/09-technical-design-document.md → tech decisions, security boundaries
```

---

## 2.3 — Classify every connector action by safety tier

Before build — for every connector action the agent will call:

| Tier | Action type | Guardrail required |
|------|------------|-------------------|
| **Low** | Read / search / retrieve | Telemetry only — no user confirmation |
| **Medium** | Create / submit / update | `confirmation-card.json` before calling |
| **High** | Delete / revoke / bulk change | Power Automate approval flow — never inline |

Record each action and its tier in `project-delivery/00-ai-decision-framework.md` Step 5.

→ Full guidance: [`BEST-PRACTICES.md`](BEST-PRACTICES.md) Section 12 — Action Safety

**Phase 2 gate:** FDD (07) and TDD (09) signed off by business owner and security.

---

---

# Phase 3 — Build

> **Goal:** Copy the base, add components, fill placeholders, push to environment.

## 3.1 — Copy the base agent

### Without UI

```bash
# From the repo root
cp -r base/ agents/<your-agent-name>/

# Open in VS Code
code agents/<your-agent-name>/
```

Base gives you 5 files:

```
agent.mcs.yml               → agent identity, system prompt, conversation starters
settings.mcs.yml            → auth mode, language, recognizer, access policy
topics/
  Greeting.topic.mcs.yml    → welcome message + Conversation.Started telemetry
  Fallback.topic.mcs.yml    → unknown intent — retries 3× then escalates
  OnError.topic.mcs.yml     → system error handler — safe message + telemetry
```

### With UI

1. Go to Copilot Studio → **Create** → **New agent**
2. Give it a name and description
3. After creation → **More options** → **Export** → download the YAML
4. Use that as your starting folder, then layer in the base templates

**Recommended:** use the CLI approach (copy `base/`) for consistency — it includes telemetry and error handling that the UI wizard does not add by default.

---

## 3.2 — Fill in required values

Open each base file and replace all `<AngleBracket>` placeholders:

| File | Placeholder | Replace with |
|------|------------|-------------|
| `agent.mcs.yml` | `<AgentName>` | Schema name e.g. `hr_assistant` (lowercase, underscores) |
| `agent.mcs.yml` | `<Agent Display Name>` | Display name e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | 2–3 sentences: what it does + what it won't answer |
| `settings.mcs.yml` | `<agent_schema_name>` | Same as `<AgentName>` |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | Same as `<AgentName>` |

For the system prompt — use a template from [`prompts/system-prompts/`](../prompts/system-prompts/) or generate one:
```bash
# Open the generation prompt in VS Code and paste into Claude
code prompts/ai-prompts/generate-agent-instructions.md
```

### With UI

After pushing the base YAML once, you can edit the agent name and system prompt in:
- **Settings** → **Details** → Name, Description
- **Settings** → **AI capabilities** → **Instructions** (system prompt)

---

## 3.3 — Add components from your recipe

Your recipe file lists exactly which components to copy. General pattern:

```bash
# Copy a topic component
cp components/topics/<component>/<ComponentName>.topic.mcs.yml \
   agents/<your-agent>/topics/

# Copy a knowledge source
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml \
   agents/<your-agent>/knowledge/MySharePoint.knowledge.mcs.yml

# Copy a connector action
cp components/actions/connector/connector-action.mcs.yml \
   agents/<your-agent>/actions/SubmitTicket.mcs.yml

# Copy an MCP action
cp components/actions/mcp/mcp-action.mcs.yml \
   agents/<your-agent>/actions/MyTool.mcs.yml
```

### For every NEW topic you create — start from the scaffold:

```bash
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/MyNewTopic.topic.mcs.yml
```

The scaffold includes error handling, telemetry, and CSAT guard — you get all of these for free without writing them yourself.

→ Call signatures for all components: [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md)

### With UI

After pushing your YAML, topics appear in the **Topics** tab. You can:
- Click a topic → edit nodes on the canvas
- Add trigger phrases in the **Trigger** panel (right side)
- Pull changes back: first run `pac copilot list` to get the GUID, then:
  `pac copilot extract-template --bot "<GUID>" --templateFileName ./agents/<name>/agent.yaml --templateVersion 1.0.0`

---

## 3.4 — Configure knowledge sources

### Without UI

Edit the knowledge source file you copied:

```yaml
# agents/<your-agent>/knowledge/MySharePoint.knowledge.mcs.yml
# Replace:
#   <SHAREPOINT_URL>  → full SharePoint library URL
#   <SCHEMA>          → your agent schema name
```

### With UI

1. **Knowledge** tab → **+ Add knowledge**
2. Choose: **SharePoint** / **Website** / **Dataverse** / **Upload file**
3. Enter the SharePoint URL → **Add**
4. Status shows **Indexing** → wait 5–30 min → status changes to **Ready**
5. Pull back to YAML: first run `pac copilot list` to get the GUID, then:
   `pac copilot extract-template --bot "<GUID>" --templateFileName ./agents/<name>/agent.yaml --templateVersion 1.0.0`

---

## 3.5 — Configure connector actions

### Without UI

Edit the connector action file:

```yaml
# Top of file — always declare the safety tier first
# SAFETY TIER: Medium
# GUARDRAIL:   confirmation-card
# REASON:      Creates a new ticket in ServiceNow — user must confirm

# Then replace:
#   <CONNECTOR_ID>   → Power Platform connector logical name
#   <OPERATION_ID>   → connector operation name
#   <SCHEMA>         → your agent schema name
```

For **Medium tier** — wire the confirmation card before the action:
```bash
# The confirmation-card JSON is at:
components/adaptive-cards/confirmation-card.json
# Embed it in the topic YAML before the InvokeConnectorTaskAction node
```

### With UI

1. Open the topic that calls the action → click the **action node**
2. Properties panel shows the connector → **Manage connections** if needed
3. For Medium tier: confirmation card node appears before the action — verify it shows correctly
4. For High tier: verify the Power Automate approval flow node is present (not an inline action)

---

## 3.6 — Replace all `_REPLACE` node IDs

Every template node uses `_REPLACE` suffixes. Each must be a unique 6-char string.

### Without UI

```powershell
# Windows PowerShell — run from your agent folder
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = $content -replace '_REPLACE\d*', $id, 1
  }
  Set-Content $_.FullName $content
}

# Verify no _REPLACE left
grep -r "_REPLACE" agents/<your-agent>/
```

### With UI (VS Code extension)

The Copilot Studio VS Code extension auto-generates node IDs on save. Open any `.mcs.yml` file → `Ctrl+S` → extension replaces `_REPLACE` suffixes automatically.

---

## 3.7 — First push to environment and open the agent

### Without UI

```bash
# Confirm you're on the right environment
pac env who

# Push (creates draft — not visible to users yet)
cd agents/<your-agent>/
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")

# Check for errors in push output
# Common issue: remaining <PLACEHOLDER> values
grep -r "<" agents/<your-agent>/

# See the agent now in the environment
pac copilot list

# Open the agent in Copilot Studio browser UI
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → click your agent → Test pane
# → Topics tab: verify all topics are listed
# → Test pane (right side): start testing immediately
```

### With UI

After applying changes:
1. Open [make.preview.microsoft.com](https://make.preview.microsoft.com)
2. Select your Dev environment (top-right picker)
3. Left sidebar → **Copilot Studio** → your agent appears in the list
4. Click the agent name → **Topics** tab → verify all topics are present
5. Click **Test** (top-right) → Test pane opens → start testing

---

---

# Phase 4 — Test

> **Goal:** Verify routing, knowledge answers, connector actions, safety guardrails, and CSAT — before any user sees the agent.

## 4.1 — Test in the UI Test pane

### With UI

1. Open your agent in Copilot Studio
2. Click **Test** (right side of screen)
3. Run through this checklist:

```
□ Type each topic's trigger phrase → confirm correct topic fires
□ Ask a question answered by knowledge source → confirm answer + citation
□ Ask an out-of-scope question → confirm redirect fires
□ Trigger a connector action:
    Low tier  → confirm it executes directly
    Medium    → confirm confirmation card appears, then executes on confirm
    Medium    → confirm nothing executes on cancel
    High      → confirm approval flow triggers, not inline execution
□ Force an error (bad input) → confirm safe error message, not raw error
□ Confirm CSAT card appears after first topic completes
□ Complete conversation, start again → confirm CSAT does NOT appear twice
         (Global.FeedbackShown blocks repeat)
□ Check Variables tab → confirm Global.FeedbackShown = true after first CSAT
```

### Without UI (activity log check)

```bash
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
# Then open in browser:
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → click your agent → Test pane

# In the Test pane, expand the activity log on each message
# Verify these telemetry events fire:
#   Conversation.Started    → on Greeting
#   Topic.Started           → on every topic
#   Topic.Completed         → on success
#   Topic.ErrorOccurred     → when you force an error
#   Knowledge.AnswerFound   → when knowledge source answers
#   Action.Succeeded        → when connector action completes
```

---

## 4.2 — Run automated routing evaluation

Target: **≥ 85% topic routing accuracy** before UAT.

### Without UI (Kit batch eval)

```bash
# Clone and build the Kit (one-time)
git clone https://github.com/microsoft/Copilot-Studio-Kit.git
cd Copilot-Studio-Kit
npm install && npm run build

# Run eval against your agent
npm run eval -- --agent-name "<Your Agent Name>" --environment <ENV_URL>

# Or use your scenarios file
npm run eval -- --scenarios ./project-delivery/05-eval-scenarios.yml
```

→ Prepare eval scenarios: [`project-delivery/05-eval-scenarios.md`](../project-delivery/05-eval-scenarios.md)

### With UI

Use the Claude skills:
```
/copilot-studio:create-eval      → generates test cases from your topics
/copilot-studio:run-eval         → runs the evaluation
/copilot-studio:analyze-evals    → identifies routing gaps
```

---

## 4.3 — Governance review (required before UAT)

### Without UI

```bash
# Open and fill in both checklists
code governance/ai-ethics-checklist.md
code governance/security-review.md
```

Key items:
```
□ Prompt injection resistance (tests I1–I5)
□ Out-of-scope handling verified
□ Escalation path confirmed and tested
□ No PII in telemetry
□ Connector permissions use least-privilege
□ DLP policy confirmed
□ Every connector action has a declared safety tier
```

### With UI

Fill in the markdown files in VS Code — there is no UI equivalent for governance docs.

---

## 4.4 — UAT with real stakeholders

Follow [`project-delivery/04-uat-test-plan.md`](../project-delivery/04-uat-test-plan.md).

UAT is done by real users, not the developer. The business owner signs the sign-off page before go-live.

**Phase 4 gate:** Eval ≥ 85%, both governance checklists signed, UAT signed off.

---

---

# Phase 5 — Deploy

> **Goal:** Publish to users. Promote Dev → UAT → Prod.

## 5.1 — Publish in Dev (verify before promoting)

### Without UI

```bash
pac copilot publish --bot "<AgentName>"
# Agent is now live on the Dev environment for any connected channels
```

### With UI

1. Open agent in Copilot Studio
2. Top-right → **Publish** button
3. Confirm → agent goes live within 1–2 minutes

---

## 5.2 — Promote Dev → UAT

### Without UI

```bash
# Switch to UAT environment
pac env select --environment "UAT - HR Project"
pac env who                     # confirm

# Apply changes to UAT (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")

# Run UAT test plan → get sign-off
# Then publish to UAT
pac copilot publish --bot "<AgentName>"
```

### With UI

1. Switch environment (top-right picker) to **UAT - HR Project**
2. Verify the agent is present
3. Run UAT → get sign-off
4. **Publish**

---

## 5.3 — Promote UAT → Prod (go-live)

### Without UI

```bash
# Complete launch checklist first
code launch/launch-checklist.md

# Switch to Prod
pac env select --environment "Prod - HR Project"
pac env who

# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
# Then publish
pac copilot publish --bot "<AgentName>"

# Tag the release in git
git tag v1.0.0 -m "HR Assistant v1.0 — initial launch"
git push origin v1.0.0

# Send user announcement
code launch/user-communication-template.md
```

### With UI

1. Complete [`launch/launch-checklist.md`](../launch/launch-checklist.md) — every item
2. Switch to Prod environment in top-right picker
3. Verify agent is present and correct
4. **Publish**
5. Send the user announcement: [`launch/user-communication-template.md`](../launch/user-communication-template.md)

---

## 5.4 — Set up CI/CD (automate future deployments)

One-time setup — automates push + publish on Git branch merge.

```bash
# Pipelines are in ci-cd/
ci-cd/push-on-pr.yml              → push to Dev on every PR
ci-cd/promote-dev-to-uat.yml      → promote to UAT on merge to uat branch
ci-cd/promote-uat-to-prod.yml     → promote to Prod on merge to main
ci-cd/publish-on-release.yml      → publish on GitHub release tag
```

→ Setup instructions: [`ci-cd/README.md`](../ci-cd/README.md)

---

---

# Phase 6 — Operate

> **Goal:** Keep the agent healthy. Catch problems before users do.

## 6.1 — Hypercare (first 2 weeks post-launch)

Follow [`launch/hypercare-guide.md`](../launch/hypercare-guide.md).

Daily checks during hypercare:
```
□ Any spike in fallback rate?
□ Any error messages reported by users?
□ Knowledge source still indexing correctly?
□ Escalation path working (tickets/calls reaching the right team)?
```

---

## 6.2 — Weekly health check

### Without UI (App Insights KQL)

Run the four queries from [`operations/monitoring-queries.md`](../operations/monitoring-queries.md):

```kql
-- 1. Conversation volume
customEvents
| where name == "Conversation.Started"
| summarize count() by bin(timestamp, 1d)

-- 2. Fallback rate
customEvents
| where name in ("Topic.Started", "Agent.FallbackTriggered")
| summarize
    total = countif(name == "Topic.Started"),
    fallbacks = countif(name == "Agent.FallbackTriggered")
  by bin(timestamp, 7d)
| extend fallbackRate = todouble(fallbacks) / total * 100

-- 3. CSAT score
customEvents
| where name == "Feedback.Rating"
| summarize avg(todouble(customDimensions.rating)) by bin(timestamp, 7d)

-- 4. Errors
customEvents
| where name == "Topic.ErrorOccurred"
| summarize count() by tostring(customDimensions.topicName), bin(timestamp, 7d)
```

### With UI

Copilot Studio → **Analytics** tab (left sidebar):
- **Summary** → conversation volume, resolution rate, escalation rate
- **Customer satisfaction** → CSAT score trend
- **Topic usage** → which topics fire most / least

---

## 6.3 — Alert thresholds

Set up alerts in [`operations/alert-setup.md`](../operations/alert-setup.md):

| Metric | Alert threshold | Action |
|--------|----------------|--------|
| Fallback rate | > 15% | Review unanswered topics |
| Escalation rate | > 10% | Review escalation path |
| CSAT | < 4.0 / 5.0 | Review last week's topic changes |
| Error rate | > 2% | Check `operations/runbook.md` |
| RPM | > 7,000 / min | Plan for scale — Foundry migration |

---

## 6.4 — Responding to incidents

Follow [`operations/runbook.md`](../operations/runbook.md) for every incident type:

```
Connector action failing       → runbook: Connector Issues
Knowledge source not answering → runbook: Knowledge Source Issues
Agent not routing correctly    → runbook: Routing Issues
Auth failures                  → runbook: Authentication Issues
High error rate                → runbook: Error Spike
```

---

## 6.5 — Ongoing improvement cycle

```bash
# Monthly — review unanswered questions
# In App Insights:
customEvents
| where name == "Knowledge.AnswerNotFound"
| summarize count() by tostring(customDimensions.utterance)
| order by count_ desc

# Add new topics for the top unanswered questions
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/NewTopic.topic.mcs.yml
# Edit → apply changes → test → publish
# Apply changes: VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
pac copilot publish --bot "<AgentName>"
```

---

---

# Quick Comparison — With UI vs Without UI

| Task | With UI | Without UI |
|------|---------|-----------|
| Create agent | Copilot Studio → Create → New agent | `cp -r base/ agents/<name>/` |
| Add a topic | Topics tab → + New topic → canvas editor | Copy `_scaffold` → edit YAML → VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"` |
| Add knowledge source | Knowledge tab → + Add knowledge | Copy template → edit YAML → VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"` |
| Add connector action | Topics canvas → Call an action node | Copy template → edit YAML → declare safety tier → VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"` |
| Replace placeholders | Properties panel per node | `Ctrl+H` in VS Code or PowerShell script |
| Test | Test pane (right side of screen) | `start https://make.preview.microsoft.com` → select env → agent → Test pane |
| Check variable values | Test pane → Variables tab | Same |
| See telemetry events | Activity log per message in Test pane | App Insights KQL queries |
| Publish | Publish button (top right) | `pac copilot publish --bot "<AgentName>"` |
| Promote to UAT/Prod | Switch environment → verify → Publish | `pac env select` → VS Code: Apply Changes → `pac copilot publish --bot "Name"` |
| Monitor health | Analytics tab in Copilot Studio | App Insights KQL (`operations/monitoring-queries.md`) |
| Version control | Not available in UI | Git — branch per feature, tag per release |
| CI/CD | Not available in UI | GitHub Actions (`ci-cd/` folder) |

---

---

# Complete File Reference — What to Open at Each Phase

| Phase | Files to open |
|-------|--------------|
| 0 — Setup | `TOOLS-AND-PLUGINS.md`, `../commands/pac-commands.md`, `../commands/vscode-commands.md` |
| 1 — Discovery | `../project-delivery/00-ai-decision-framework.md`, `01-requirements-questionnaire.md`, `02-technical-discovery.md` |
| 2 — Design | `../project-delivery/03-agent-design-worksheet.md`, `06-content-audit.md`, `07-functional-design-document.md`, `08-workflow-logic-design.md`, `../recipes/README.md` |
| 3 — Build | `../base/`, `../components/topics/_scaffold/`, recipe file, `COMPONENT-REGISTRY.md`, `../prompts/system-prompts/` |
| 4 — Test | `../project-delivery/04-uat-test-plan.md`, `05-eval-scenarios.md`, `../governance/ai-ethics-checklist.md`, `../governance/security-review.md` |
| 5 — Deploy | `../launch/launch-checklist.md`, `../launch/user-communication-template.md`, `../commands/pac-commands.md` Section 6, `../ci-cd/` |
| 6 — Operate | `../operations/monitoring-queries.md`, `../operations/alert-setup.md`, `../operations/runbook.md`, `../launch/hypercare-guide.md` |

---

# All Commands in Order — Cheat Sheet

```bash
# ── PHASE 0: SETUP ───────────────────────────────────────────────────────────
winget install Microsoft.PowerAppsCLI
winget install Microsoft.VisualStudioCode
winget install Git.Git
pac auth create
pac env list
pac env select --environment "Dev - My Project"
pac env who
pac copilot list                                    # see agents — copy the Copilot ID (GUID)
start https://make.preview.microsoft.com            # open existing agent in browser (select env → agent)
mkdir agents\my-agent                               # create output dir first (required)
pac copilot extract-template \
  --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --templateFileName ./agents/my-agent/agent.yaml \
  --templateVersion 1.0.0                           # use GUID from pac copilot list, NOT display name
# OR VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"

# ── PHASE 3: BUILD ───────────────────────────────────────────────────────────
cp -r base/ agents/my-agent/
code agents/my-agent/
# edit YAML files, fill placeholders, copy components
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot list                                    # confirm agent appears in environment
start https://make.preview.microsoft.com            # open in browser to verify topics

# ── PHASE 4: TEST ────────────────────────────────────────────────────────────
start https://make.preview.microsoft.com            # opens Copilot Studio → click agent → Test pane
# run through test checklist manually
npm run eval                   # batch routing accuracy test (Kit)

# ── PHASE 5: DEPLOY ──────────────────────────────────────────────────────────
pac copilot publish --bot "My Agent"   # Dev → live on Dev

pac env select --environment "UAT - My Project"
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "My Agent"   # UAT → live on UAT

pac env select --environment "Prod - My Project"
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "My Agent"   # Prod → live for all users

git tag v1.0.0 && git push origin v1.0.0

# ── PHASE 6: OPERATE ─────────────────────────────────────────────────────────
# Weekly — run KQL queries from operations/monitoring-queries.md
# On incident — follow operations/runbook.md
# Monthly — review Knowledge.AnswerNotFound, add new topics
```

→ Full pac commands: [`commands/pac-commands.md`](../commands/pac-commands.md)
→ Full git commands: [`commands/git-commands.md`](../commands/git-commands.md)
→ Full VS Code shortcuts: [`commands/vscode-commands.md`](../commands/vscode-commands.md)
→ UI-only steps in detail: [`COPILOT-STUDIO-UI-GUIDE.md`](COPILOT-STUDIO-UI-GUIDE.md)
