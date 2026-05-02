# Components

Optional add-ons for your agent. Pick only what you need — every component is independent.

Start with `base/` first. Then cherry-pick from here.

## Subfolders

| Folder | What's inside |
|--------|--------------|
| [`topics/`](topics/) | Topic YAML files — each handles a specific conversation pattern |
| [`actions/`](actions/) | Action YAML files — connector and MCP server integrations |
| [`knowledge/`](knowledge/) | Knowledge source YAML files — SharePoint and public website |
| [`agents/`](agents/) | Child agent definitions — for orchestrator patterns |
| [`variables/`](variables/) | Global variable declarations — shared state across topics |
| [`adaptive-cards/`](adaptive-cards/) | Adaptive Card JSON templates — confirmation, status, form |

## How to choose components

| If you need... | Add... |
|---------------|--------|
| Authenticated user context (name, country) | `topics/auth` + `topics/conversation-init` |
| Knowledge search over documents | `topics/knowledge-search` + `knowledge/sharepoint` or `knowledge/public-website` |
| Human escalation from a trigger phrase | `topics/escalation` |
| Block clearly out-of-scope queries | `topics/out-of-scope` |
| Call a Power Platform connector | `actions/connector` + `topics/action-invoke` |
| Call an MCP server tool | `actions/mcp` + `topics/action-invoke` |
| Collect structured input with a card | `adaptive-cards/form-card.json` |
| Confirm before executing an action | `adaptive-cards/confirmation-card.json` |
| Multiple specialists under one agent | `agents/child-agent` |
| Shared state across multiple topics | `variables/global-variable` |

See `recipes/` for pre-built combinations of these components.
