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

These two files define your agent's domain — write them together.

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | What MCP tools the agent can use, when to invoke them, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect for questions outside the tool's scope |

**The `generate-agent-instructions.md` prompt writes both in one pass.**

### Step 1 — Option A: Use a ready-made persona (5 min)

```
1. Open prompts/system-prompts/it-helpdesk.md  (closest match for tool-calling agents)
2. Copy everything inside the triple backticks
3. Paste into agent.mcs.yml replacing the entire instructions: | block
4. Replace every [BRACKET] value and update the tools section to match your MCP tools
5. Then go to Step 3 to fill OutOfScope.topic.mcs.yml manually
```

### Step 1 — Option B: Generate both with Claude (10 min, recommended)

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into Claude
3. Fill in:
     Project brief:  "Agent that uses MCP tools to [describe capability].
                      Tools available: [list each tool and what it does in natural language].
                      Must NOT handle [out-of-scope]. Redirect those to [contact]."
     Agent name:     Jira Agent
     Primary users:  Internal developers / [your audience]
     Authentication: ManualAzureAD (if MCP server requires user identity) or None
     Tone:           Professional
4. Paste Claude's output into agent.mcs.yml
```

**Critical — describe each MCP tool in the instructions.** The AI uses this to decide when to invoke them. Even though each tool has a `modelDescription`, the instructions provide broader context:

```yaml
instructions: |
  You help developers manage their work items.
  - SearchJiraIssues: finds open issues assigned to the user — use when asked about tasks or backlog
  - CreateGitHubIssue: opens a new GitHub issue — use when the user wants to report a bug or feature
  Always confirm before creating or modifying anything.
```

### Step 2 — Apply to agent.mcs.yml

Paste the output replacing the entire `instructions: |` block. Every line must be indented 2 spaces — YAML is whitespace-sensitive.

### Step 3 — Apply to OutOfScope.topic.mcs.yml

Claude's "What I cannot help with" items become trigger phrases and redirect text.

**Mapping:**

```
Claude output                                →  OutOfScope.topic.mcs.yml
─────────────────────────────────────────────────────────────────────────────
"HR questions — hr@company.com"                 triggerQueries:
"Finance queries — finance@company.com"           - annual leave
"Facilities — facilities@company.com"             - expense claim
                                                  - payroll

                                                SendActivity:
                                                  "I'm only set up for [tool domain].
                                                   For [topic], [contact] is best."
```

**Add the file and fill in the placeholders:**

If `OutOfScope.mcs.yml` is not yet in your `topics/` folder, copy it in:

```powershell
# PowerShell
Copy-Item "base\topics\OutOfScope.topic.mcs.yml" "agents\<display name>\topics\OutOfScope.mcs.yml" -Force
```
```bash
# Mac / Linux
cp base/topics/OutOfScope.topic.mcs.yml "agents/<display name>/topics/OutOfScope.mcs.yml"
```

Open `OutOfScope.mcs.yml` and replace these 5 things:

| Placeholder | Replace with | Example |
|-------------|-------------|---------|
| `<out-of-scope phrase 1–5>` | Trigger phrases from Claude's "What I cannot help with" section | `payroll`, `IT support`, `expense claim` |
| `<DOMAIN>` | What this agent handles | `HR policies and leave management` |
| `<OUT-OF-SCOPE-TOPIC>` | The out-of-scope area in the redirect message | `IT support` |
| `<CONTACT>` | Where to send the user | `it@contoso.com` |
| `_REPLACE1`, `_REPLACE2` | Run the ID script (QUICKSTART Step 4) or any 6-char random string | `_ab3f9x` |

**Need more trigger phrases?** Ask Claude:

```
Generate 10 trigger phrases for a Copilot Studio OutOfScope topic.
The agent handles: [your domain].
Out-of-scope areas: [list from your instructions].
Include: formal, casual, abbreviated, and question variations.
Output as a YAML list (- phrase format).
```

→ Template: [`prompts/ai-prompts/generate-topic.md`](../prompts/ai-prompts/generate-topic.md) → "Generate trigger phrases only"
→ All prompt templates: [`prompts/README.md`](../prompts/README.md)

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

> **YAML indentation:** Always use **2 spaces** — never tabs. When pasting content between files, match the indentation level of the surrounding block exactly. A single wrong indent silently breaks the file. VS Code shows indentation errors as red underlines in the Problems panel (`Ctrl+Shift+M`).

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch. If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/Jira Agent/`) and already contains topic files. Topic files need rename-on-copy — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

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

**Verify nothing was missed before pushing:**

```powershell
# Windows — must return zero output
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\jira_agent" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\jira_agent" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/jira_agent --include="*.mcs.yml"
grep -rn "_REPLACE" agents/jira_agent --include="*.mcs.yml"
```

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
