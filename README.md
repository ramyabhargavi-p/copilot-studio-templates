# Copilot Studio Templates

Reusable YAML templates for building production-quality Copilot Studio agents.
Every topic has built-in error handling, telemetry, and CSAT — nothing to add manually.

---

## Your path through this repo

### Building your first agent (30–60 min)

| Step | File | What you do |
|------|------|-------------|
| **1** | [`QUICKSTART.md`](QUICKSTART.md) | Pick recipe, copy files, replace 5 values, push |
| **2** | [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md) | Look up any component call signature during build |
| **3** | [`SKILLS-REFERENCE.md`](SKILLS-REFERENCE.md) | Use Claude skills to generate topics, run evals, validate |

### Full enterprise delivery (all roles, all phases)

| Step | File | What you do |
|------|------|-------------|
| **4** | [`START-HERE.md`](START-HERE.md) | 28-step index from decision through operations |
| **5** | [`project-delivery/`](project-delivery/) | Work through `00-` → `12-` in order |
| **6** | [`governance/`](governance/) | Ethics checklist + security review before go-live |

### Reference (use at any point)

| File | What it covers |
|------|---------------|
| [`BEST-PRACTICES.md`](BEST-PRACTICES.md) | Design rules, error handling, telemetry, naming |
| [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) | Install `pac` CLI, VS Code extension, Git |
| [`TEAM-GUIDE.md`](TEAM-GUIDE.md) | Role-based entry points, onboarding for new developers |
| [`base/README.md`](base/README.md) | How to configure the 5 base files |
| [`ci-cd/README.md`](ci-cd/README.md) | GitHub Actions pipeline setup |
| [`troubleshooting/README.md`](troubleshooting/README.md) | Fix YAML errors, auth issues, routing gaps |

### After go-live

| Step | File | What you do |
|------|------|-------------|
| **7** | [`launch/launch-checklist.md`](launch/launch-checklist.md) | Tick every box before going live |
| **8** | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) | Weekly health check KQL queries |
| **9** | [`operations/runbook.md`](operations/runbook.md) | Respond to production incidents |

---

## Folder structure

| Folder | Contents | Go here when… |
|--------|----------|---------------|
| [`base/`](base/) | 5 files every agent needs (agent, settings, Greeting, Fallback, OnError) | Starting a new agent |
| [`components/`](components/) | Drop-in topics, actions, cards, knowledge sources — all with built-in telemetry | Adding a capability |
| [`components/topics/_scaffold/`](components/topics/_scaffold/) | **Master topic template** — copy for every new topic | Creating a new topic |
| [`recipes/`](recipes/) | Step-by-step guides for 6 common agent types | Picking an agent pattern |
| [`prompts/`](prompts/) | System prompt templates + AI generation prompts | Writing the agent persona or generating YAML |
| [`project-delivery/`](project-delivery/) | Discovery → Design → Build → UAT documents (numbered `00`–`12`) | Running a governed delivery |
| [`governance/`](governance/) | Responsible AI + security review checklists | Pre-go-live sign-off |
| [`launch/`](launch/) | Go-live checklist, user announcement, hypercare guide | Shipping to production |
| [`operations/`](operations/) | KQL monitoring queries, alerts, runbook | Post-launch operations |
| [`ci-cd/`](ci-cd/) | GitHub Actions for Dev → UAT → Prod promotion | Setting up CI/CD |
| [`troubleshooting/`](troubleshooting/) | Common errors and fixes | Something is broken |

---

## Base agent — 5 files, every project starts here

```
base/
├── agent.mcs.yml               Agent identity, system prompt, conversation starters
├── settings.mcs.yml            Auth mode, recognizer, language, access policy
└── topics/
    ├── Greeting.topic.mcs.yml  Welcome message + Conversation.Started telemetry
    ├── Fallback.topic.mcs.yml  Unknown intent — retries 3× then escalates
    └── OnError.topic.mcs.yml   System error handler — safe message + telemetry
```

→ Full setup instructions: [`base/README.md`](base/README.md)

---

## Components — drop-in by type

### Topics

| Component | Trigger | Purpose |
|-----------|---------|---------|
| [`_scaffold`](components/topics/_scaffold/) | `OnRecognizedIntent` | **Start every new topic here** — built-in error handling, telemetry, CSAT |
| [`auth`](components/topics/auth/) | `OnSignIn` | Sign-in flow with telemetry |
| [`conversation-init`](components/topics/conversation-init/) | `OnActivity` (first message) | Loads M365 profile into global variables |
| [`disambiguation`](components/topics/disambiguation/) | `OnSelectIntent` | Clarifies ambiguous intents |
| [`escalation`](components/topics/escalation/) | `BeginDialog` | Human handoff via TransferConversation |
| [`knowledge-search`](components/topics/knowledge-search/) | `OnUnknownIntent` | Generative answers from knowledge sources |
| [`out-of-scope`](components/topics/out-of-scope/) | `OnRecognizedIntent` | Redirects out-of-scope queries |
| [`question-branch`](components/topics/question-branch/) | `OnRecognizedIntent` | Collects input and branches |
| [`action-invoke`](components/topics/action-invoke/) | `OnRecognizedIntent` | Calls an action with validation and telemetry |
| [`feedback`](components/topics/feedback/) | `OnRecognizedIntent` / `BeginDialog` | Thumbs → rating → free text CSAT |
| [`remove-citations`](components/topics/remove-citations/) | `OnGeneratedResponse` | Strips `[1][2]` citation markers |

→ Call signatures for all topics: [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md)

### Actions

| Component | Kind | Purpose |
|-----------|------|---------|
| [`connector`](components/actions/connector/) | `InvokeConnectorTaskAction` | Calls a Power Platform connector |
| [`mcp`](components/actions/mcp/) | `InvokeExternalAgentTaskAction` | Calls an MCP server tool |

### Knowledge Sources

| Component | Source | Purpose |
|-----------|--------|---------|
| [`sharepoint`](components/knowledge/sharepoint/) | SharePoint library | Internal document search |
| [`public-website`](components/knowledge/public-website/) | Public URL | Public website search |

### Adaptive Cards

| Component | Use case |
|-----------|---------|
| [`confirmation-card`](components/adaptive-cards/confirmation-card.json) | Confirm before executing |
| [`status-card`](components/adaptive-cards/status-card.json) | Show action result |
| [`form-card`](components/adaptive-cards/form-card.json) | Collect structured input |
| [`feedback-thumbs`](components/adaptive-cards/feedback-thumbs.json) | Thumbs up/down |
| [`feedback-rating`](components/adaptive-cards/feedback-rating.json) | 1–5 star rating |
| [`feedback-text`](components/adaptive-cards/feedback-text.json) | Free text + category |

### Other

| Component | Kind | Purpose |
|-----------|------|---------|
| [`child-agent`](components/agents/child-agent/) | `AgentDialog` | Specialist sub-agent |
| [`global-variable`](components/variables/global-variable/) | Conversation scope | Shared state across topics |

---

## Recipes — pick your agent type

| Recipe | What it builds | Time |
|--------|---------------|------|
| [`01-basic-faq`](recipes/01-basic-faq.md) | Generative Q&A over SharePoint | 30 min |
| [`02-authenticated-agent`](recipes/02-authenticated-agent.md) | Sign-in + personalised M365 context | 45 min |
| [`03-connector-action-agent`](recipes/03-connector-action-agent.md) | Calls a Power Platform connector | 60 min |
| [`04-mcp-action-agent`](recipes/04-mcp-action-agent.md) | Calls an MCP server tool | 60 min |
| [`05-orchestrator-agent`](recipes/05-orchestrator-agent.md) | Multi-specialist with child agents | 2+ hr |
| [`06-full-featured-agent`](recipes/06-full-featured-agent.md) | Auth + knowledge + actions + CSAT | 2+ hr |

---

## Conventions

| Convention | Rule |
|------------|------|
| `<AngleBrackets>` | Required placeholder — replace before use |
| `_REPLACE` suffixes | Node IDs — replace with unique 6-char string (see QUICKSTART.md) |
| `schemaName` prefix | Every component ID starts with the agent's `schemaName` |
| One file per component | Never combine actions, knowledge, or child agents into one file |

---

## Telemetry events

| Event | Fired by |
|-------|----------|
| `Conversation.Started` | Greeting |
| `Topic.Started` | Every topic (scaffold) |
| `Topic.Completed` | Every action topic on success (scaffold) |
| `Topic.ErrorOccurred` | Every action topic on failure (scaffold) |
| `Agent.FallbackTriggered` | Fallback |
| `Agent.EscalationTriggered` | Fallback, Escalation |
| `Agent.DisambiguationTriggered` | Disambiguation |
| `Agent.OutOfScope` | Out of Scope |
| `Agent.ErrorOccurred` | OnError |
| `Auth.SignInStarted` / `Auth.SignInCompleted` | Sign In |
| `Knowledge.SearchInvoked` / `AnswerFound` / `AnswerNotFound` | Knowledge Search |
| `ConversationInit.Completed` | Conversation Init |
| `Action.Succeeded` / `Action.Failed` | Action Invoke |
| `Feedback.Thumbs` / `Feedback.Rating` / `Feedback.Text` | Feedback |

All events include `ConversationId` and `TimeUTC`.
