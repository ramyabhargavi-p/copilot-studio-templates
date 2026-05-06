# Copilot Studio UI Guide

How to take templates from this repo and use them in the Copilot Studio web UI and VS Code extension.

Every template type is covered: YAML topics, knowledge sources, connector actions, adaptive cards, and publishing.

---

## Overview — Two ways to work

| Method | Best for | Tooling |
|--------|---------|---------|
| **pac CLI + VS Code** | Team builds, CI/CD, version control | `pac` CLI + VS Code + Copilot Studio Extension |
| **Copilot Studio UI only** | Quick edits, first-time exploration | Browser at make.preview.microsoft.com |

Both methods use the same YAML. The CLI pushes files to the UI; the UI exports back to files.

---

## Method 1 — pac CLI (recommended for teams)

### First-time setup

**Install pac CLI — pick one method:**

```bash
# Option A: winget (Windows — recommended, no admin required)
winget install Microsoft.PowerAppsCLI

# Option B: dotnet tool (requires .NET SDK 6+)
dotnet tool install --global Microsoft.PowerApps.CLI

# Option C: MSI installer (IT-managed machines)
# Download from https://aka.ms/PowerAppsCLI and run the .msi

# Option D: npm (requires PowerShell execution policy fix first)
# Run as Administrator: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then: npm install -g @microsoft/powerplatform-cli
```

After installing, close and reopen your terminal, then verify:

```bash
pac --version
```

**Authenticate (browser login — do this once):**

```bash
# Opens browser for Microsoft login — no client secret needed for dev machines
pac auth create

# Verify it worked
pac auth list
# Output shows: Index | Active | Kind | Name | User | Environment
```

---

### Step-by-step: connect to an environment and start developing

```bash
# 1. See all environments you have access to
pac env list
# Output: Environment Name | Type | URL | Environment ID

# 2. Set the environment you want to work in
pac env select --environment "Dev - My Project"
# Or use the URL instead of the name:
pac env select --environment https://yourorg-dev.crm.dynamics.com

# 3. Confirm which environment is now active
pac env who
# Output: Connected to: Dev - My Project | https://yourorg-dev.crm.dynamics.com

# 4. See what agents already exist in this environment
pac copilot list
# Output: Agent Name | Schema Name | Agent ID | Status

# 5a. Pull an EXISTING agent to edit it locally
pac copilot extract-template --bot "HR Assistant" --templateFileName ./agents/hr-assistant/agent.yaml
# OR VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"

# 5b. OR start a NEW agent from template (no pull needed)
cp -r base/ agents/hr-assistant/

# 6. Open in VS Code and edit
code agents/hr-assistant/

# 7. Push your changes back to the environment (draft — not live yet)
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")

# 8. Open the agent in the browser to test
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → your agent → Test pane

# 9. When ready to go live — publish
pac copilot publish --bot "HR Assistant"
```

---

### Switching between Dev / UAT / Prod environments

```bash
# See all auth profiles (one per environment if you created them separately)
pac auth list
# Index | Active | Environment
#   1   |        | Dev - My Project
#   2   |   *    | UAT - My Project
#   3   |        | Prod - My Project

# Switch to a different environment
pac env select --environment "Prod - My Project"

# Or switch by auth profile index
pac auth select --index 3

# Confirm which is active
pac env who

# Push to the now-active environment
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
```

---

### Everyday development loop (after first-time setup)

```bash
# 1. Make sure you're on the right environment
pac env who

# 2. Edit your YAML files in VS Code
code agents/hr-assistant/

# 3. Push draft to environment
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")

# 4. Test in browser (Test pane — tests draft, not published version)
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → your agent → Test pane

# 5. Repeat steps 2–4 until done

# 6. Publish to make it live for users
pac copilot publish --bot "<AgentName>"
```

### Push your agent to Copilot Studio

Apply changes via VS Code:
```
Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

To apply changes and then publish (make it live for users):
```bash
# Step 1: Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
# Step 2: Publish
pac copilot publish --bot "<AgentName>"
```

After applying changes:
1. Open [make.preview.microsoft.com](https://make.preview.microsoft.com)
2. Select your environment (top-right dropdown)
3. Go to **Copilot Studio** → your agent appears in the list

### Pull changes made in the UI back to files

```bash
pac copilot extract-template --bot "<AgentName>" --templateFileName ./agents/<your-agent-name>/agent.yaml
# OR VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"
```

---

## Method 2 — VS Code Extension

### Install

1. Open VS Code
2. Extensions panel → search **Microsoft Copilot Studio**
3. Install → restart VS Code

### Open your agent

1. `Ctrl+Shift+P` → **Copilot Studio: Open Agent**
2. Sign in with your Microsoft 365 account
3. Select environment → select agent
4. VS Code shows the agent's YAML files in the Explorer sidebar

### Push from VS Code

1. Edit any `.mcs.yml` file
2. `Ctrl+Shift+P` → **Copilot Studio: Push Agent**
3. Changes appear live in the browser UI within ~30 seconds

---

## Adding Each Template Type in the UI

### 1 — Topics (`.topic.mcs.yml` files)

**What the UI shows:** Topics tab in the left sidebar.

**Steps to add a new topic from a template:**

1. Copy the scaffold:
   ```bash
   cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
      agents/<your-agent>/topics/MyNewTopic.topic.mcs.yml
   ```

2. Edit the file — replace `<TOPIC_NAME>`, `<SCHEMA>`, `<DESCRIPTION>`, and all `_REPLACE` IDs

3. Push:
   ```
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   ```

4. In the UI: **Topics** tab → your topic appears → click to verify trigger phrases

**What you see in the UI after push:**
- Topics list shows your topic name
- Click the topic → visual canvas shows nodes matching your YAML steps
- Trigger phrases appear in the **Trigger** panel on the right

**To edit a topic in the UI (instead of YAML):**
- Click any node on the canvas
- Edit text, conditions, or actions in the right-hand properties panel
- Pull back to YAML: `pac copilot extract-template --bot "<AgentName>" --templateFileName ./agents/<name>/agent.yaml`

---

### 2 — Knowledge Sources (`.knowledge.mcs.yml` files)

**What the UI shows:** Knowledge tab in the left sidebar.

**Steps to add a SharePoint knowledge source:**

1. Copy the template:
   ```bash
   cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml \
      agents/<your-agent>/knowledge/MySharePoint.knowledge.mcs.yml
   ```

2. Edit the file — replace `<SHAREPOINT_URL>` and `<SCHEMA>`

3. Push:
   ```
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   ```

4. In the UI: **Knowledge** tab → your SharePoint source appears with status **Indexing** → waits 5–30 min to complete → status changes to **Ready**

**To add a knowledge source directly in the UI (then pull to YAML):**
1. **Knowledge** tab → **+ Add knowledge**
2. Choose source type: SharePoint, Website, Dataverse, or Upload file
3. Fill in the URL or upload
4. Click **Add** → source indexes
5. Pull back to YAML: `pac copilot extract-template --bot "<AgentName>" --templateFileName ./agents/<name>/agent.yaml`

**Verifying it works:**
- In the **Test** pane (right side of UI) → ask a question about the source content
- Answer should appear with citations below the response

---

### 3 — Connector Actions (`.mcs.yml` action files)

**What the UI shows:** Settings → AI capabilities → Actions (for actions attached to topics)
Also visible as a node inside a topic canvas when wired in.

**Steps to add a connector action from template:**

1. Copy the template:
   ```bash
   cp components/actions/connector/connector-action.mcs.yml \
      agents/<your-agent>/actions/SubmitTicket.mcs.yml
   ```

2. Edit — replace `<CONNECTOR_ID>`, `<OPERATION_ID>`, `<SCHEMA>`, input/output parameter names, and the Safety Tier comment header

3. Push:
   ```
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   ```

4. In the UI, the action is visible inside any topic that calls it (as an "action" node on the canvas)

**To configure a connector action in the UI (first-time only — for connector ID):**
1. Open the topic that uses the action
2. Click the **Call an action** node
3. The properties panel shows the connector and operation — verify they match your YAML
4. If the connector shows **Connection required**: click **Manage connections** → sign in to the connector

**Medium safety tier (confirmation card):**
- In the topic canvas, the confirmation card node appears before the action node
- Click the card node → properties show the card JSON — verify it matches `confirmation-card.json`

**High safety tier (approval flow):**
- The action does NOT appear inline in the topic
- Instead, a **Send an HTTP request** or **Run a flow** node triggers the Power Automate approval flow
- Verify the flow ID in the node properties matches your approval flow

---

### 4 — MCP Actions (`.mcs.yml` MCP files)

**What the UI shows:** Settings → AI capabilities → Plugins (external agents/MCP tools appear here)

**Steps:**

1. Copy the MCP action template:
   ```bash
   cp components/actions/mcp/mcp-action.mcs.yml \
      agents/<your-agent>/actions/MyMCPTool.mcs.yml
   ```

2. Edit — replace `<MCP_SERVER_URL>`, `<TOOL_NAME>`, `<SCHEMA>`

3. Push:
   ```
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   ```

4. In the UI: **Settings** → **AI capabilities** → **Plugins** → your MCP tool appears → toggle **Enabled**

**Testing MCP in the UI:**
- Open **Test** pane → ask something that should invoke the tool
- Tool call appears in the activity log below the response (shows tool name + inputs/outputs)

---

### 5 — Adaptive Cards

Adaptive cards are embedded as JSON inside topic YAML. They do not appear as separate files in the UI.

**How to use a card template:**

1. Open the card JSON file you need:
   ```bash
   cat components/adaptive-cards/confirmation-card.json
   ```

2. Copy the JSON and paste it into your topic YAML inside the appropriate `SendActivity` node:
   ```yaml
   - kind: SendActivity
     id: showCard_REPLACE
     activity:
       attachments:
         - contentType: application/vnd.microsoft.card.adaptive
           content: |
             {
               "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
               "type": "AdaptiveCard",
               "version": "1.5",
               ...paste card JSON here...
             }
   ```

3. Push and verify in the UI: the topic canvas shows an **Adaptive card** node → click it → the card preview appears in the properties panel

**To see the rendered card:**
- Open **Test** pane → trigger the topic → the card renders as it would for users

**To edit the card visually:**
- Go to [adaptivecards.io/designer](https://adaptivecards.io/designer)
- Paste your JSON → edit visually → copy updated JSON back into your YAML

---

### 6 — Child Agents (Orchestrator pattern)

**What the UI shows:** Settings → AI capabilities → Child agents

**Steps:**

1. Copy the child agent template:
   ```bash
   cp components/agents/child-agent/child-agent.mcs.yml \
      agents/<your-agent>/agents/ITSpecialist.mcs.yml
   ```

2. Edit — replace `<CHILD_AGENT_ID>`, `<CHILD_AGENT_SCHEMA>`, and description

3. Push the orchestrator agent (parent):
   ```
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   ```

4. In the UI: **Settings** → **AI capabilities** → **Child agents** → your child agent appears → toggle **Enabled**

**Verify routing in the Test pane:**
- Ask a question that should go to the child agent
- The response shows the child agent name at the top of the reply
- Activity log shows: `BeginDialog → <ChildAgentName>`

---

### 7 — Global Variables

Global variables defined in `.variable.mcs.yml` files are visible in the UI under **Variables**.

**After pushing:**
1. Open any topic → click a **Set variable** or **Condition** node
2. Click the variable picker → your global variable appears in the **Global** section
3. Verify the type (string/boolean/number) matches your YAML declaration

---

## Publishing — Making the Agent Live

Applying changes (VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`) uploads your YAML as a draft. Users cannot see drafts — you must publish.

### Publish via CLI

```bash
pac copilot publish --bot "<AgentName>"
```

### Publish via UI

1. Open your agent in [make.preview.microsoft.com](https://make.preview.microsoft.com)
2. Top-right corner → **Publish** button
3. Confirm → agent goes live within 1–2 minutes

### Publish via CI/CD

See [`ci-cd/publish-on-release.yml`](ci-cd/publish-on-release.yml) — triggers on a GitHub release tag.

---

## Testing in the UI

The **Test** pane (right side of every agent) is always testing the **draft** (unpublished) version.

| Test action | How |
|-------------|-----|
| Send a message | Type in the Test pane input box → Enter |
| Reset conversation | Click **Reset** (circular arrow icon) top of Test pane |
| See variable values | Click **Variables** tab above the Test pane input |
| See activity log | Click the `>` expand arrow on any message in the Test pane |
| Jump to a topic | Click **Go to topic** in the activity log entry |

**Verify every topic after push:**
1. Trigger the topic via its trigger phrase
2. Check the activity log — confirm `Topic.Started` telemetry event fires
3. Complete the happy path — confirm `Topic.Completed` fires
4. Confirm CSAT card appears (first trigger only, then `Global.FeedbackShown` blocks repeat)

---

## Copilot Studio UI Layout Reference

```
Left sidebar:
├── Topics           ← your .topic.mcs.yml files appear here
├── Knowledge        ← your .knowledge.mcs.yml sources appear here
├── Actions          ← connector + MCP actions referenced in topics
├── Variables        ← global variables from .variable.mcs.yml
└── Settings
    ├── AI capabilities
    │   ├── Plugins        ← MCP tools + child agents
    │   └── Actions        ← connector actions
    ├── Authentication ← maps to settings.mcs.yml → authorizationSettings
    ├── Generative AI  ← knowledge search + content moderation
    └── Channels       ← Teams, SharePoint, custom

Top bar:
├── Test             ← Test pane (draft version)
├── Publish          ← makes draft live
└── More options     ← export solution, manage environments
```

---

## Common UI Tasks — Quick Reference

| Task | Where in UI |
|------|------------|
| Add a trigger phrase to a topic | Topics → click topic → Trigger panel (right) → Add phrase |
| Change agent name / description | Settings → Details |
| Change authentication mode | Settings → Authentication |
| Enable/disable a topic | Topics → toggle switch next to topic name |
| See what topics a phrase triggers | Topics → Test → type the phrase → see which topic activates |
| View telemetry in App Insights | Azure Portal → App Insights resource → Logs → run KQL from `operations/monitoring-queries.md` |
| Export agent as solution | More options → Export → creates `.zip` for ALM |
| Import agent solution | make.powerapps.com → Solutions → Import |

---

## Troubleshooting UI Pushes

| Problem | Fix |
|---------|-----|
| Apply Changes fails with 401 | Run `pac auth create` again — token expired |
| Topic not appearing after applying changes | Wait 30 seconds and refresh; check the VS Code output panel for errors |
| Knowledge source stuck on "Indexing" | Normal — SharePoint can take up to 30 min; website up to 60 min |
| Adaptive card not rendering | Check JSON validity at [adaptivecards.io/designer](https://adaptivecards.io/designer) |
| Connector shows "Connection required" | Settings → Connections → sign in to the connector |
| Topic triggering wrong intent | Check trigger phrases for overlap → use Disambiguation topic |

→ Full error reference: [`troubleshooting/README.md`](troubleshooting/README.md)
→ pac CLI install: [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md)
