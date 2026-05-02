# Copilot Studio Templates

Reusable YAML templates for building Copilot Studio agents. Clone once, use everywhere.

Every template includes inline comments explaining each field and a README explaining when and how to use it.

---

## Quick Start

```
1. Copy base/ into your new agent project folder
2. Replace all <PLACEHOLDER> values in the YAML files
3. Replace all _REPLACE ID suffixes with unique random strings
4. Cherry-pick components from components/ as needed
5. See recipes/ for recommended combinations
```

---

## Repository Structure

| Folder | Contents |
|--------|----------|
| [`base/`](base/) | Minimum viable agent — start here |
| [`components/`](components/) | Optional add-ons — pick what you need |
| [`recipes/`](recipes/) | Documented combinations for common agent types |

---

## Base Agent

**Copy `base/` to start every new agent.** It contains the 5 files every agent needs:

| File | Purpose |
|------|---------|
| [`base/agent.mcs.yml`](base/agent.mcs.yml) | Agent identity, system prompt, conversation starters, AI model |
| [`base/settings.mcs.yml`](base/settings.mcs.yml) | Auth mode, recognizer, language, access policy |
| [`base/topics/Greeting.topic.mcs.yml`](base/topics/Greeting.topic.mcs.yml) | Welcome message on conversation start |
| [`base/topics/Fallback.topic.mcs.yml`](base/topics/Fallback.topic.mcs.yml) | Unknown intent handler — retries 3× then escalates |
| [`base/topics/OnError.topic.mcs.yml`](base/topics/OnError.topic.mcs.yml) | System error handler with telemetry logging |

→ See [`base/README.md`](base/README.md) for setup steps and key decisions.

---

## Components

### Topics

| Component | Trigger | What it does | README |
|-----------|---------|-------------|--------|
| [`auth`](components/topics/auth/) | `OnSignIn` | Sign-in flow with OAuthInput | [→](components/topics/auth/README.md) |
| [`conversation-init`](components/topics/conversation-init/) | `OnActivity` (first message) | Loads M365 user profile + glossary into global variables | [→](components/topics/conversation-init/README.md) |
| [`disambiguation`](components/topics/disambiguation/) | `OnSelectIntent` | Clarifies which topic the user meant when multiple match | [→](components/topics/disambiguation/README.md) |
| [`knowledge-search`](components/topics/knowledge-search/) | `OnUnknownIntent` | Generative answers from knowledge sources | [→](components/topics/knowledge-search/README.md) |
| [`question-branch`](components/topics/question-branch/) | `OnRecognizedIntent` | Collects user input and branches the conversation | [→](components/topics/question-branch/README.md) |
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

## Conventions

| Convention | Rule |
|------------|------|
| `<AngleBrackets>` | Required placeholder — you must replace this value |
| `_REPLACE` suffixes | Node IDs — replace with a unique random string (e.g. `_a1b2c3`) |
| `schemaName` prefix | Every component ID starts with the agent's `schemaName` from `settings.mcs.yml` |
| One file per component | Never combine multiple actions, knowledge sources, or child agents into one file |
| Unique IDs per agent | IDs must be unique across the entire agent, not just within a single topic file |

### Generating Node IDs

Replace `_REPLACE`, `_REPLACE1`, `_REPLACE2`, etc. with 6-character random alphanumeric strings. Quick options:
- VS Code Copilot Studio extension — auto-generates IDs on save
- Online generator: `https://it-tools.tech/token-generator` (set length to 6)
- PowerShell: `[System.Web.Security.Membership]::GeneratePassword(6, 0)`

---

## Contributing

1. Add new YAML template + `README.md` under the appropriate `components/` subfolder
2. Update the component table in this file
3. If it's a common combination, add a recipe under `recipes/`
4. Keep each template focused on a single purpose — one file per component
