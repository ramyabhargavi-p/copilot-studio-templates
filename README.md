# Copilot Studio Templates

Reusable YAML templates for building Copilot Studio agents — for teams of all experience levels. Covers every phase: Discovery → Design → Build → Eval → UAT → Deploy → Operate → Govern.

---

## Not sure where to begin? → [START-HERE.md](START-HERE.md)

**`START-HERE.md` is the entry point for everyone** — business owners, project managers, testers, security reviewers, and developers. It tells each role exactly what to do and in what order, in plain language.

---

## New to Copilot Studio (developer)? → [GETTING-STARTED.md](GETTING-STARTED.md)

## Sharing this with your team? → [TEAM-GUIDE.md](TEAM-GUIDE.md)

---

## Quick Start (experienced developers)

```
1. Copy base/ into your new agent project folder
2. Replace all <PLACEHOLDER> values in the YAML files
3. Replace all _REPLACE ID suffixes with unique random strings
4. Cherry-pick components from components/ as needed
5. See recipes/ for recommended combinations
```

---

## Repository Structure

| Folder / File | Contents |
|--------|----------|
| [`START-HERE.md`](START-HERE.md) | **Entry point for everyone** — role-based paths for business owners, PMs, developers, testers, security reviewers, and agent owners |
| [`GETTING-STARTED.md`](GETTING-STARTED.md) | Developer step-by-step guide for all phases |
| [`TEAM-GUIDE.md`](TEAM-GUIDE.md) | **Sharing with your team** — who uses what, blockers, reusable prompts E2E reference |
| [`INDUSTRY-GUIDELINES.md`](INDUSTRY-GUIDELINES.md) | Industry best practices and Microsoft-specific guidelines for agent development |
| [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) | Required tools, VS Code extensions, and setup checklist |
| [`BEST-PRACTICES.md`](BEST-PRACTICES.md) | Design guidelines: error handling, logging, scope, naming, testing checklist |
| [`ROADMAP.md`](ROADMAP.md) | Planned additions — what's not built yet |
| [`base/`](base/) | Minimum viable agent YAML — start every project here |
| [`components/`](components/) | Optional add-ons — pick what you need |
| [`recipes/`](recipes/) | Documented combinations for common agent types |
| [`project-delivery/`](project-delivery/) | Discovery, design, content audit, eval, UAT, and deployment documents |
| [`prompts/`](prompts/) | Ready-made system prompt templates + AI generation prompts |
| [`operations/`](operations/) | Monitoring KQL queries, alert setup, and operational runbook |
| [`governance/`](governance/) | Responsible AI checklist and security review |
| [`launch/`](launch/) | Go-live checklist, user communication template, hypercare guide |
| [`ci-cd/`](ci-cd/) | GitHub Actions workflows for automated push and publish |
| [`troubleshooting/`](troubleshooting/) | Common issues and fixes — Teams/Copilot publishing, YAML errors, auth |

---

## Base Agent

**Copy `base/` to start every new agent.** It contains the 5 files every agent needs:

| File | Purpose |
|------|---------|
| [`base/agent.mcs.yml`](base/agent.mcs.yml) | Agent identity, system prompt (with scope + out-of-scope guidance), conversation starters |
| [`base/settings.mcs.yml`](base/settings.mcs.yml) | Auth mode, recognizer, language, access policy |
| [`base/topics/Greeting.topic.mcs.yml`](base/topics/Greeting.topic.mcs.yml) | Welcome message + `Conversation.Started` telemetry |
| [`base/topics/Fallback.topic.mcs.yml`](base/topics/Fallback.topic.mcs.yml) | Unknown intent — retries 3× with telemetry, then escalates |
| [`base/topics/OnError.topic.mcs.yml`](base/topics/OnError.topic.mcs.yml) | System error handler — test mode detail, prod safe message, `Agent.ErrorOccurred` telemetry |

→ See [`base/README.md`](base/README.md) for setup steps and key decisions.

---

## Components

### Topics

| Component | Trigger | What it does | README |
|-----------|---------|-------------|--------|
| [`auth`](components/topics/auth/) | `OnSignIn` | Sign-in flow with `Auth.SignInStarted` / `Auth.SignInCompleted` telemetry | [→](components/topics/auth/README.md) |
| [`conversation-init`](components/topics/conversation-init/) | `OnActivity` (first message) | Loads M365 profile with error handling + safe defaults; logs `ConversationInit.Completed` | [→](components/topics/conversation-init/README.md) |
| [`disambiguation`](components/topics/disambiguation/) | `OnSelectIntent` | Clarifies ambiguous intents; logs `Agent.DisambiguationTriggered` with match count | [→](components/topics/disambiguation/README.md) |
| [`escalation`](components/topics/escalation/) | `OnRecognizedIntent` / `BeginDialog` | Human handoff via `TransferConversation`; logs `Agent.EscalationTriggered` with reason | [→](components/topics/escalation/README.md) |
| [`knowledge-search`](components/topics/knowledge-search/) | `OnUnknownIntent` | Generative answers from knowledge sources; logs `Knowledge.SearchInvoked` / `AnswerFound` / `AnswerNotFound` | [→](components/topics/knowledge-search/README.md) |
| [`out-of-scope`](components/topics/out-of-scope/) | `OnRecognizedIntent` | Redirects clearly out-of-scope queries; logs `Agent.OutOfScope` | [→](components/topics/out-of-scope/README.md) |
| [`question-branch`](components/topics/question-branch/) | `OnRecognizedIntent` | Collects user input and branches the conversation | [→](components/topics/question-branch/README.md) |
| [`action-invoke`](components/topics/action-invoke/) | `OnRecognizedIntent` | Calls an action with output validation + `Action.Succeeded` / `Action.Failed` telemetry | [→](components/topics/action-invoke/README.md) |
| [`remove-citations`](components/topics/remove-citations/) | `OnGeneratedResponse` | Strips `[1][2]` citation markers from AI responses | [→](components/topics/remove-citations/README.md) |

### Actions

| Component | Kind | What it does | README |
|-----------|------|-------------|--------|
| [`connector`](components/actions/connector/) | `InvokeConnectorTaskAction` | Calls a Power Platform connector operation | [→](components/actions/connector/README.md) |
| [`mcp`](components/actions/mcp/) | `InvokeExternalAgentTaskAction` | Calls an MCP server tool | [→](components/actions/mcp/README.md) |

### Knowledge Sources

| Component | Source type | What it does | README |
|-----------|-------------|-------------|--------|
| [`sharepoint`](components/knowledge/sharepoint/) | SharePoint document library | Internal document search | [→](components/knowledge/sharepoint/README.md) |
| [`public-website`](components/knowledge/public-website/) | Public URL (Bing) | Public website search | [→](components/knowledge/public-website/README.md) |

### Agents

| Component | Kind | What it does | README |
|-----------|------|-------------|--------|
| [`child-agent`](components/agents/child-agent/) | `AgentDialog` | Specialist sub-agent for orchestrator pattern | [→](components/agents/child-agent/README.md) |

### Variables

| Component | Scope | What it does | README |
|-----------|-------|-------------|--------|
| [`global-variable`](components/variables/global-variable/) | Conversation | Shared state across topics (user profile, locale, flags) | [→](components/variables/global-variable/README.md) |

### Adaptive Cards

| Component | Use case | README |
|-----------|---------|--------|
| [`confirmation-card`](components/adaptive-cards/confirmation-card.json) | Ask user to confirm or cancel before executing an action | [→](components/adaptive-cards/README.md) |
| [`status-card`](components/adaptive-cards/status-card.json) | Display action result or data lookup with status colour | [→](components/adaptive-cards/README.md) |
| [`form-card`](components/adaptive-cards/form-card.json) | Collect structured input (date, dropdown, text) from user | [→](components/adaptive-cards/README.md) |

---

## Recipes

Start here if you know what type of agent you're building:

| Recipe | What it builds | Complexity |
|--------|---------------|------------|
| [01 — Basic FAQ](recipes/01-basic-faq.md) | Generative Q&A over SharePoint docs | Low |
| [02 — Authenticated Agent](recipes/02-authenticated-agent.md) | Sign-in + personalised M365 user context | Low–Medium |
| [03 — Connector Action Agent](recipes/03-connector-action-agent.md) | Calls a Power Platform connector | Medium |
| [04 — MCP Action Agent](recipes/04-mcp-action-agent.md) | Calls an MCP server tool | Medium |
| [05 — Orchestrator Agent](recipes/05-orchestrator-agent.md) | Multi-specialist with child agents | High |
| [06 — Full-Featured Agent](recipes/06-full-featured-agent.md) | Auth + knowledge + actions + disambiguation | High |

---

## Telemetry Events Reference

All templates use a consistent `{Category}.{Action}` naming convention:

| Event | Fired by | Key properties |
|-------|----------|----------------|
| `Conversation.Started` | Greeting | Channel, BotName |
| `Agent.FallbackTriggered` | Fallback | UserQuery, FallbackCount |
| `Agent.EscalationTriggered` | Fallback, Escalation | Reason, FallbackCount |
| `Agent.DisambiguationTriggered` | Disambiguation | UserQuery, MatchCount |
| `Agent.OutOfScope` | Out of Scope | UserQuery |
| `Agent.ErrorOccurred` | On Error | ErrorCode, ErrorMessage, IsTestMode |
| `Auth.SignInStarted` | Sign In | SignInReason |
| `Auth.SignInCompleted` | Sign In | — |
| `Knowledge.SearchInvoked` | Knowledge Search | UserQuery |
| `Knowledge.AnswerFound` | Knowledge Search | — |
| `Knowledge.AnswerNotFound` | Knowledge Search | UserQuery |
| `ConversationInit.Completed` | Conversation Init | UserCountry |
| `ConversationInit.ProfileLoadFailed` | Conversation Init | — |
| `Topic.Started` | Action Invoke | TopicName, UserQuery |
| `Action.Succeeded` | Action Invoke | TopicName, ActionName |
| `Action.Failed` | Action Invoke | TopicName, ActionName |

All events include `ConversationId` and `TimeUTC`.

---

## Conventions

| Convention | Rule |
|------------|------|
| `<AngleBrackets>` | Required placeholder — you must replace this value |
| `_REPLACE` suffixes | Node IDs — replace with a unique random string (e.g. `_a1b2c3`) |
| `schemaName` prefix | Every component ID starts with the agent's `schemaName` from `settings.mcs.yml` |
| One file per component | Never combine multiple actions, knowledge sources, or child agents into one file |
| Unique IDs per agent | IDs must be unique across the entire agent, not just within a single topic file |

### Generating Node IDs

Replace `_REPLACE`, `_REPLACE1`, etc. with 6-character random alphanumeric strings:
- VS Code Copilot Studio extension — auto-generates IDs on save
- Online: `https://it-tools.tech/token-generator` (length 6)
- PowerShell: `[System.Web.Security.Membership]::GeneratePassword(6, 0)`

---

## Contributing

1. Add new YAML template + `README.md` under the appropriate `components/` subfolder
2. Update the component table in this file
3. Add the telemetry events to the Telemetry Events Reference table
4. If it's a common combination, add a recipe under `recipes/`
5. Keep each template focused on a single purpose — one file per component
