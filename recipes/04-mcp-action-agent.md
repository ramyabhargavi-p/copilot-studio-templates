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

## Values to Change

| File | Field | Notes |
|------|-------|-------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `jira_agent` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `Jira Agent` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | **Option A:** copy from a `prompts/system-prompts/` template → replace `[BRACKET]` values. **Option B:** use `prompts/ai-prompts/generate-agent-instructions.md` with Claude. Include in the instructions what MCP tools the agent can use and when. See [`prompts/README.md`](../prompts/README.md). |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` |
| `settings.mcs.yml` | `GenerativeActionsEnabled` | set to `true` for AI auto-invocation |
| `actions/<ToolName>.mcs.yml` | `connectionReference` | logical name of your MCP connection |
| `actions/<ToolName>.mcs.yml` | `operationId` | the MCP tool's operation ID |
| `actions/<ToolName>.mcs.yml` | `modelDisplayName` | short display name |
| `actions/<ToolName>.mcs.yml` | `modelDescription` | one sentence — be specific about what the tool does and when to use it |

## Write Instructions and OutOfScope Content

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | What MCP tools the agent can use, when to invoke them, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect for questions outside the tool's scope |

**Option A persona:** `prompts/system-prompts/it-helpdesk.md` (closest match for tool-calling agents)

**Critical — describe each MCP tool in the instructions.** Even though each tool has a `modelDescription`, the instructions provide broader context:

```yaml
instructions: |
  You help developers manage their work items.
  - SearchJiraIssues: finds open issues assigned to the user — use when asked about tasks or backlog
  - CreateGitHubIssue: opens a new GitHub issue — use when the user wants to report a bug or feature
  Always confirm before creating or modifying anything.
```

**Option B project brief:**

```
"Agent that uses MCP tools to [describe capability].
 Tools available: [list each tool and what it does in natural language].
 Must NOT handle [out-of-scope]. Redirect those to [contact]."
Agent name: [Your Agent Name] | Auth: ManualAzureAD or None | Tone: Professional
```

→ **Follow the full steps** (apply to both files): [`docs/SYSTEM-PROMPT-PATTERN.md`](../docs/SYSTEM-PROMPT-PATTERN.md)

---

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

## How to Copy the Components

> **Before copying:** Use 2-space indentation (never tabs). Cloud-First (cloned folder) users need rename-on-copy — see [troubleshooting → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder).

Replace `jira_agent` with your agent's schemaName and `SearchJiraIssues` with a descriptive action name.

```bash
# Mac / Linux
mkdir -p agents/jira_agent/topics agents/jira_agent/actions

cp base/agent.mcs.yml                       agents/jira_agent/
cp base/settings.mcs.yml                    agents/jira_agent/
cp base/topics/Greeting.topic.mcs.yml       agents/jira_agent/topics/
cp base/topics/Fallback.topic.mcs.yml       agents/jira_agent/topics/
cp base/topics/OnError.topic.mcs.yml        agents/jira_agent/topics/
cp base/topics/OutOfScope.topic.mcs.yml     agents/jira_agent/topics/

# Rename the action file to match the MCP tool — one copy per tool
cp components/actions/mcp/mcp-action.mcs.yml  agents/jira_agent/actions/SearchJiraIssues.mcs.yml
```

```powershell
# Windows PowerShell
$a = "agents\jira_agent"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\actions"

Copy-Item base\agent.mcs.yml                    $a\
Copy-Item base\settings.mcs.yml                 $a\
Copy-Item base\topics\Greeting.topic.mcs.yml    $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml    $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml     $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml  $a\topics\

# Rename the action file — one copy per MCP tool
Copy-Item components\actions\mcp\mcp-action.mcs.yml  $a\actions\SearchJiraIssues.mcs.yml
```

**Run the ID replacement script** — replaces all `_REPLACE` node IDs and `<PLACEHOLDER>` values in one pass.
→ See [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids). Set `$schema = "jira_agent"`.

After the script runs, fill in the MCP-specific values manually in each action file:

| Field | Example |
|-------|---------|
| `connectionReference` | `shared_mcp_jira` (logical name of your MCP connection) |
| `operationId` | `search_issues` (the MCP tool's operation ID) |
| `modelDisplayName` | `Search Jira Issues` |
| `modelDescription` | `Searches Jira for open issues assigned to the current user.` |

Also set `GenerativeActionsEnabled: true` in `settings.mcs.yml` so the AI auto-invokes the tool.

→ **Verify before pushing:** see [docs/QUICKSTART.md → Verify](../docs/QUICKSTART.md) — both commands must return zero output.

## Setup Checklist

- [ ] MCP server registered as a connection in Power Platform (make.powerapps.com → Connections)
- [ ] Files copied and ID script run (verify returns zero output)
- [ ] Each action file has `connectionReference`, `operationId`, `modelDisplayName`, `modelDescription` filled in
- [ ] `settings.mcs.yml` — `GenerativeActionsEnabled: true`
- [ ] VS Code → **Copilot Studio: Apply Changes**
- [ ] Test by asking the agent to use the tool in natural language

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
