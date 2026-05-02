# Recipe 04 — MCP Action Agent

An agent that calls an external MCP (Model Context Protocol) server tool in response to user requests.

## Use Case

- Agent that calls a custom Python/Node.js API exposed as an MCP server
- Agent that integrates with MCP-compatible services (GitHub, Jira, Confluence, etc.)
- When the capability you need isn't available as a Power Platform connector

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
└── actions/
    └── mcp/
        └── mcp-action.mcs.yml              ← one file per MCP tool
```

## How It Works

```
User: "Search for open Jira issues assigned to me"
    │
    ▼
[GenerativeAIRecognizer] → routes to MCP action
    │
    ▼
[MCP Action] — calls the MCP server operation
    │
    └─ Returns the tool's response to the user
```

## Setup Checklist

- [ ] Register your MCP server as a connection in Power Platform (make.powerapps.com → Connections)
- [ ] Copy `base/` into your agent project
- [ ] Copy `mcp-action.mcs.yml` into your agent's `actions/` folder
- [ ] `mcp-action.mcs.yml` — replace all placeholders:
  - [ ] MCP server name in the comment header
  - [ ] `connectionReference` — the logical name of the MCP connection
  - [ ] `operationId` — the MCP tool operation ID
  - [ ] `modelDisplayName` and `modelDescription` — be specific
- [ ] `settings.mcs.yml` — set `GenerativeActionsEnabled: true` for AI auto-invocation
- [ ] All topic files — replace every `_REPLACE` suffix with unique random strings
- [ ] Push and test in the Copilot Studio test canvas

## Multiple MCP Tools

Add one `mcp-action.mcs.yml` per MCP tool. Rename files descriptively:
```
actions/
├── SearchJiraIssues.mcs.yml
├── CreateGitHubIssue.mcs.yml
└── GetConfluencePage.mcs.yml
```

## Connector vs MCP — Which to Use?

| Use | When |
|-----|------|
| `connector-action` | The API is available as a Power Platform connector (SharePoint, Outlook, Dataverse, ServiceNow, etc.) |
| `mcp-action` | The API is a custom service or exposed via MCP protocol; not available as a standard connector |

## Optional Additions

- Add `auth` component if the MCP server requires user identity (`mode: Invoker`)
- Combine with `knowledge-search` for an agent that both searches knowledge and calls tools
