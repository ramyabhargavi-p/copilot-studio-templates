# Components

Drop-in building blocks for Copilot Studio agents. Each component is a self-contained YAML file (or small folder) with built-in error handling, telemetry, and CSAT — copy it into your agent and configure the placeholders.

---

## How components assemble into an agent

```mermaid
flowchart TD
    BASE[base/] --> AGENT([Your Agent])

    subgraph COMP["components/  — drop in as needed"]
        T[topics x12]
        AC[actions x2]
        K[knowledge x3]
        CA[adaptive-cards x6]
        V[variables x5]
        CH[agents x1]
    end

    T --> AGENT
    AC --> AGENT
    K --> AGENT
    CA --> T
    V --> T
    CH --> AGENT
```

Start with `base/` (6 files). Add components from `components/` as your agent needs them. Never write YAML from scratch.

---

## What's here

| Folder | Count | Contents | Use when… |
|--------|-------|----------|-----------|
| [`topics/`](topics/) | 12 | Conversation topic templates | Adding a capability to an agent |
| [`actions/`](actions/) | 2 | Connector and MCP action types | Calling external systems |
| [`knowledge/`](knowledge/) | 3 | Knowledge source types (SharePoint, web, glossary) | Answering questions from documents |
| [`adaptive-cards/`](adaptive-cards/) | 6 | Card templates (confirmation, form, feedback) | Collecting input or showing results |
| [`agents/`](agents/) | 1 | Child agent template | Orchestrator pattern with specialist sub-agents |
| [`variables/`](variables/) | 5 | Global variable templates | Sharing state across topics in a conversation |

---

## How to use a component

```bash
# Step 1 — Copy the component into your agent folder
cp components/topics/escalation/Escalation.topic.mcs.yml \
   agents/<your-agent>/topics/Escalation.topic.mcs.yml

# Step 2 — Replace <SCHEMA> with your agent's schemaName in the file
sed -i 's/<SCHEMA>/<your-schema-name>/g' agents/<your-agent>/topics/Escalation.topic.mcs.yml

# Step 3 — Run the _REPLACE ID script (see docs/QUICKSTART.md → Replace node IDs)

# Step 4 — Replace any remaining <PLACEHOLDER> values (queue names, URLs, etc.)
grep -n "<" agents/<your-agent>/topics/Escalation.topic.mcs.yml

# Step 5 — Push to your connected environment
# VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

### Placeholder convention

| Placeholder type | Example | Action |
|-----------------|---------|--------|
| `<ANGLE_BRACKETS>` | `<SCHEMA>`, `<SHAREPOINT_URL>` | Replace manually before push |
| `_REPLACE` | `sendActivity_REPLACE` | Replace by running the ID script (see QUICKSTART.md) |
| `schemaName` prefix | `contoso_agent.topic.Escalate` | Follows from your `schemaName` in `agent.mcs.yml` |

### Verify nothing was missed before pushing

```powershell
# Windows PowerShell — both must return zero output before Apply Changes
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\<your-agent>" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\<your-agent>" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/<your-agent> --include="*.mcs.yml"
grep -rn "_REPLACE" agents/<your-agent> --include="*.mcs.yml"
```

---

## Claude skills for components

| Task | Skill |
|------|-------|
| Generate a new topic from a description | `/copilot-studio:new-topic` |
| Add a connector or MCP action | `/copilot-studio:add-action` |
| Add a knowledge source | `/copilot-studio:add-knowledge` |
| Add an adaptive card to a topic | `/copilot-studio:add-adaptive-card` |
| Validate all component YAML | `/copilot-studio:validate` |

→ Full call signatures and input/output specs: [`../docs/COMPONENT-REGISTRY.md`](../docs/COMPONENT-REGISTRY.md)

---

## Component index

Open any component's README for copy commands, placeholder tables, and YAML examples.

### Topics

| Component | When to add it |
|-----------|---------------|
| [`_scaffold`](topics/_scaffold/) | Starting point for every new custom topic — never write YAML from scratch |
| [`action-invoke`](topics/action-invoke/) | Call a connector from a topic (question → action → response + CSAT) |
| [`auth`](topics/auth/) | Force sign-in before sensitive topics (ManualAzureAD auth only) |
| [`conversation-init`](topics/conversation-init/) | Load user name + country from M365 profile on first turn |
| [`disambiguation`](topics/disambiguation/) | Ask the user to choose when their message matches multiple topics |
| [`escalation`](topics/escalation/) | Hand off to a live agent queue |
| [`feedback`](topics/feedback/) | CSAT at end of conversation (thumbs → star rating → issue category) |
| [`feedback-persisted`](topics/feedback-persisted/) | Write CSAT responses to Dataverse for Power BI dashboards |
| [`knowledge-search`](topics/knowledge-search/) | Generative answers from SharePoint or web knowledge sources |
| [`out-of-scope`](topics/out-of-scope/) | Redirect questions outside the agent's domain |
| [`question-branch`](topics/question-branch/) | Ask one question and branch the conversation on the answer |
| [`remove-citations`](topics/remove-citations/) | Strip [1]–[10] citation markers from AI-generated responses |

### Actions

| Component | When to add it |
|-----------|---------------|
| [`connector`](actions/connector/) | Call any Power Platform connector (SharePoint, Outlook, Dataverse, custom) |
| [`mcp`](actions/mcp/) | Call an MCP (Model Context Protocol) server tool |

### Knowledge sources

| Component | When to add it |
|-----------|---------------|
| [`sharepoint`](knowledge/sharepoint/) | Answer questions from internal SharePoint documents |
| [`public-website`](knowledge/public-website/) | Answer questions from publicly accessible websites |
| [`glossary`](knowledge/glossary/) | Inject domain acronyms (PTO, WFH) silently into AI context |

### Adaptive cards

| Component | When to add it |
|-----------|---------------|
| `confirmation-card.json` | Confirm a write or destructive action (Safety tier 2–3) |
| `form-card.json` | Collect multi-field input in a structured form |
| `status-card.json` | Show a status or result after an action |
| `feedback-thumbs.json` | Used by the `feedback` topic — copy all 3 feedback cards together |
| `feedback-rating.json` | Used by the `feedback` topic |
| `feedback-text.json` | Used by the `feedback` topic |

→ Card runtime placeholders and DataContext examples: [`adaptive-cards/README.md`](adaptive-cards/README.md)

### Variables

| Component | Variable | When to add it |
|-----------|----------|---------------|
| [`global-variable`](variables/global-variable/) | Configurable | Any value that multiple topics need to share across a conversation |
| [`user-display-name`](variables/user-display-name/) | `Global.UserDisplayName` | Personalise responses with the signed-in user's display name |
| [`user-country`](variables/user-country/) | `Global.UserCountry` | Adapt responses based on the user's country |
| [`glossary-var`](variables/glossary-var/) | `Global.Glossary` | Expand domain acronyms in AI context |
| [`feedback-context`](variables/feedback-context/) | `Global.FeedbackContext`, `Global.FeedbackQuestion`, `Global.FeedbackSources` | Required when using `feedback-persisted` — stores the topic name, user question, and cited sources |

### Child agents

| Component | When to add it |
|-----------|---------------|
| [`child-agent`](agents/child-agent/) | Add a specialist sub-agent under an orchestrator parent |
