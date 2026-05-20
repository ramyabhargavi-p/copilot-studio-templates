# Recipe 03 — Connector Action Agent

An agent that calls a Power Platform connector to read or write data in response to user requests.

## Use Case

- "Submit a leave request" → writes to Dataverse or SharePoint
- "What's on my calendar today?" → reads from Outlook
- "Create a support ticket" → writes to ServiceNow via a connector
- Any agent that needs to interact with a Power Platform-connected system

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
    └── connector/
        └── connector-action.mcs.yml        ← one file per connector operation
```

## How It Works

```
User: "I want to submit a leave request"
    │
    ▼
[GenerativeAIRecognizer] → matches a topic or GenerativeActionsEnabled routes to action
    │
    ▼
[Connector Action] — AI collects required inputs from user
    │
    ├─ Calls connector operation (e.g. CreateItem on SharePoint)
    └─ Returns response to user
```

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `it_helpdesk` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `IT Helpdesk` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | **Option A:** copy from `prompts/system-prompts/it-helpdesk.md` → replace `[BRACKET]` values. **Option B:** use `prompts/ai-prompts/generate-agent-instructions.md` with Claude. Include in the instructions what action(s) the agent can perform. See [`prompts/README.md`](../prompts/README.md). |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` |
| `settings.mcs.yml` | `authenticationMode: None` | `ManualAzureAD` if action runs as signed-in user |
| `connector-action.mcs.yml` | `<CONNECTOR_LOGICAL_NAME>` | e.g. `shared_sharepointonline` |
| `connector-action.mcs.yml` | `<OPERATION_ID>` | e.g. `CreateItem` |
| `connector-action.mcs.yml` | `<modelDescription>` | plain-English description of what the action does |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` |

## Write Instructions and OutOfScope Content

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | What actions the agent can take, when to invoke them, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect for questions outside the action's scope |

**Option A persona:** `prompts/system-prompts/it-helpdesk.md` (closest match for action-taking agents)

**Critical — describe each action in the instructions.** The AI uses this to decide when to invoke them:

```yaml
instructions: |
  You can help with:
  - Checking ticket status: ask for the ticket ID, then use GetTicketStatus
  - Creating a new ticket: collect the description and urgency, then use CreateTicket
  For anything else, tell the user this is outside your scope and offer to escalate.
```

**Option B project brief:**

```
"Agent that [what it does]. Available actions: [list each action and
 what it does in natural language]. Must NOT handle [out-of-scope].
 Redirect those to [contact]."
Agent name: IT Helpdesk | Auth: ManualAzureAD or None | Tone: Professional
```

→ **Follow the full steps** (apply to both files): [`docs/SYSTEM-PROMPT-PATTERN.md`](../docs/SYSTEM-PROMPT-PATTERN.md)

---

## How to Copy the Components

> **Before copying:** Use 2-space indentation (never tabs). Cloud-First (cloned folder) users need rename-on-copy — see [troubleshooting → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder).

Replace `it_helpdesk` with your agent's schemaName and `GetTicketStatus` with a descriptive action name.

```bash
# Mac / Linux
mkdir -p agents/it_helpdesk/topics agents/it_helpdesk/actions

cp base/agent.mcs.yml                       agents/it_helpdesk/
cp base/settings.mcs.yml                    agents/it_helpdesk/
cp base/topics/Greeting.topic.mcs.yml       agents/it_helpdesk/topics/
cp base/topics/Fallback.topic.mcs.yml       agents/it_helpdesk/topics/
cp base/topics/OnError.topic.mcs.yml        agents/it_helpdesk/topics/
cp base/topics/OutOfScope.topic.mcs.yml     agents/it_helpdesk/topics/

# Rename the action file to match what it does — one copy per connector operation
cp components/actions/connector/connector-action.mcs.yml  agents/it_helpdesk/actions/GetTicketStatus.mcs.yml
```

```powershell
# Windows PowerShell
$a = "agents\it_helpdesk"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\actions"

Copy-Item base\agent.mcs.yml                    $a\
Copy-Item base\settings.mcs.yml                 $a\
Copy-Item base\topics\Greeting.topic.mcs.yml    $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml    $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml     $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml  $a\topics\

# Rename the action file — one copy per operation
Copy-Item components\actions\connector\connector-action.mcs.yml  $a\actions\GetTicketStatus.mcs.yml
```

**Run the ID replacement script** — replaces all `_REPLACE` node IDs and `<PLACEHOLDER>` values in one pass.
→ See [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids). Set `$schema = "it_helpdesk"`.

After the script runs, fill in the connector-specific values manually in each action file:

| Field | Example |
|-------|---------|
| `connectionReference` | `shared_sharepointonline` |
| `operationId` | `GetItem` |
| `modelDisplayName` | `Get Ticket Status` |
| `modelDescription` | `Retrieves the status of an IT support ticket by ticket ID.` |

→ **Verify before pushing:** see [docs/QUICKSTART.md → Verify](../docs/QUICKSTART.md) — both commands must return zero output.

## Setup Checklist

- [ ] Files copied and ID script run (verify returns zero output)
- [ ] Each action file has `connectionReference`, `operationId`, `modelDisplayName`, `modelDescription` filled in
- [ ] `settings.mcs.yml` — set `authenticationMode: ManualAzureAD` if the action runs as the signed-in user
- [ ] Add the connector connection in your environment (Power Platform admin center → Connections)
- [ ] VS Code → **Copilot Studio: Apply Changes**
- [ ] Test by asking the agent to perform the action in natural language

## Multiple Actions

Add one `connector-action.mcs.yml` per connector operation. Rename each file descriptively:
```
actions/
├── GetLeaveBalance.mcs.yml
├── SubmitLeaveRequest.mcs.yml
└── CancelLeaveRequest.mcs.yml
```

## Optional Additions

- Add `auth` + `conversation-init` components if actions should run as the signed-in user
- Add `knowledge-search` + SharePoint knowledge for a hybrid agent that both answers questions and takes actions
