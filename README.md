# Copilot Studio Templates

Reusable YAML templates for building production-quality Copilot Studio agents.
Every topic has built-in error handling, telemetry, and CSAT — nothing to add manually.

---

## New to this repo? Start here — in this order

| # | File | Why you read it | Time |
|---|------|----------------|------|
| **1** | [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) | Install pac CLI + VS Code extension — nothing works without these | 15 min |
| **1b** | [`commands/README.md`](commands/README.md) | pac / Git / VS Code / Node.js command references — open during development | Reference |
| **2** | [`END-TO-END-DEV-GUIDE.md`](END-TO-END-DEV-GUIDE.md) | **Full journey Phase 0–6 with UI and without UI** — setup → build → test → deploy → operate | Master guide |
| **2b** | [`examples/it-helpdesk/WALKTHROUGH.md`](examples/it-helpdesk/WALKTHROUGH.md) | **Real project example** — Contoso IT Helpdesk, all phases with real values and YAML | Sample project |
| **3** | [`GETTING-STARTED.md`](GETTING-STARTED.md) | Full walkthrough from zero to a working agent — Discovery → Design → Build → Ship | 30 min read |
| **4** | [`COPILOT-STUDIO-UI-GUIDE.md`](COPILOT-STUDIO-UI-GUIDE.md) | How to push YAML to the UI, test, and publish — detailed UI steps | 20 min |
| **5** | [`TEMPLATES.md`](TEMPLATES.md) | See all 49 templates in one list — understand what's available before you build | 10 min |
| **6** | [`recipes/README.md`](recipes/README.md) | Pick the right recipe for your agent type (6 options) | 5 min |
| **7** | [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md) | Look up call signatures while building — keep this open during build | Reference |
| **8** | [`ACTION-SAFETY-PATTERNS.md`](ACTION-SAFETY-PATTERNS.md) | **Full YAML patterns for Medium + High tier actions** — confirmation card, approval flow, test checklist | Dev reference |
| [`BEST-PRACTICES.md`](BEST-PRACTICES.md) | Design rules, error handling, Action Safety, naming conventions | 20 min |

> **In a hurry?** Skip to [`QUICKSTART.md`](QUICKSTART.md) — experienced devs can have a working agent in 30–60 min.

---

## Full project delivery — all roles, all phases

| # | File | What you do |
|---|------|-------------|
| **8** | [`START-HERE.md`](START-HERE.md) | 28-step master index — decision through operations, all roles |
| **9** | [`project-delivery/README.md`](project-delivery/README.md) | Phase map for all 14 delivery documents (numbered `00`–`13`) |
| **10** | [`governance/README.md`](governance/README.md) | Ethics + security checklists — required before go-live |

---

## After go-live

| # | File | What you do |
|---|------|-------------|
| **11** | [`launch/launch-checklist.md`](launch/launch-checklist.md) | Tick every box before users see the agent |
| **12** | [`operations/monitoring-queries.md`](operations/monitoring-queries.md) | Weekly health check KQL queries |
| **13** | [`operations/runbook.md`](operations/runbook.md) | Step-by-step response to production incidents |

---

## Other reference files

| File | Go here when… |
|------|--------------|
| [`TEAM-GUIDE.md`](TEAM-GUIDE.md) | You want role-based entry points (PM, QA, DevOps, security) |
| [`SKILLS-REFERENCE.md`](SKILLS-REFERENCE.md) | You want Claude to generate YAML, run evals, or validate |
| [`base/README.md`](base/README.md) | You need detail on the 5 base files |
| [`ci-cd/README.md`](ci-cd/README.md) | Setting up GitHub Actions for Dev → UAT → Prod |
| [`prompts/README.md`](prompts/README.md) | Writing agent personas or generating YAML with Claude |
| [`troubleshooting/README.md`](troubleshooting/README.md) | Something is broken — YAML errors, auth issues, routing gaps |

---

## Folder structure

| Folder | Contents | Go here when… |
|--------|----------|---------------|
| [`base/`](base/) | 5 files every agent needs (agent, settings, Greeting, Fallback, OnError) | Starting a new agent |
| [`components/`](components/) | Drop-in topics, actions, cards, knowledge sources — all with built-in telemetry | Adding a capability |
| [`components/topics/_scaffold/`](components/topics/_scaffold/) | **Master topic template** — copy for every new topic | Creating a new topic |
| [`recipes/`](recipes/) | Step-by-step guides for 6 common agent types | Picking an agent pattern |
| [`prompts/`](prompts/) | System prompt templates + AI generation prompts | Writing the agent persona or generating YAML |
| [`project-delivery/`](project-delivery/) | Discovery → Design → Build → UAT documents (numbered `00`–`13`) | Running a governed delivery |
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

### Copilot Studio (YAML, low-code)

| Recipe | What it builds | Time |
|--------|---------------|------|
| [`01-basic-faq`](recipes/01-basic-faq.md) | Generative Q&A over SharePoint | 30 min |
| [`02-authenticated-agent`](recipes/02-authenticated-agent.md) | Sign-in + personalised M365 context | 45 min |
| [`03-connector-action-agent`](recipes/03-connector-action-agent.md) | Calls a Power Platform connector | 60 min |
| [`04-mcp-action-agent`](recipes/04-mcp-action-agent.md) | Calls an MCP server tool | 60 min |
| [`05-orchestrator-agent`](recipes/05-orchestrator-agent.md) | Multi-specialist with child agents | 2+ hr |
| [`06-full-featured-agent`](recipes/06-full-featured-agent.md) | Auth + knowledge + actions + CSAT | 2+ hr |

### Pro-code (when Copilot Studio alone is not enough)

| Recipe | What it builds | Time |
|--------|---------------|------|
| [`07-m365-agents-sdk`](recipes/07-m365-agents-sdk.md) | Custom agent in C# / TypeScript / Python — wraps or extends Copilot Studio via SDK | 2+ hr |
| [`08-azure-ai-foundry`](recipes/08-azure-ai-foundry.md) | Foundry agent — code interpreter, custom models, > 8K RPM, Progressive Enhancement | 3+ hr |

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
