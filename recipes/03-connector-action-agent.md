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

These two files define your agent's domain — write them together.

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | What actions the agent can take, when to invoke them, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect for questions outside the action's scope |

**The `generate-agent-instructions.md` prompt writes both in one pass.**

### Step 1 — Option A: Use a ready-made persona (5 min)

```
1. Open prompts/system-prompts/it-helpdesk.md  (closest match for action-taking agents)
2. Copy everything inside the triple backticks
3. Paste into agent.mcs.yml replacing the instructions: | block
4. Replace every [BRACKET] value
5. Add a section describing your specific actions (see example below)
6. Then go to Step 3 to fill OutOfScope.topic.mcs.yml manually
```

### Step 1 — Option B: Generate both with Claude (10 min, recommended)

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into Claude
3. Fill in:
     Project brief:  "Agent that [what it does]. Available actions: [list each action and
                      what it does in natural language]. Must NOT handle [out-of-scope].
                      Redirect those to [contact]."
     Agent name:     IT Helpdesk
     Primary users:  Internal employees
     Authentication: ManualAzureAD (if action runs as signed-in user) or None
     Tone:           Professional
4. Paste Claude's output into agent.mcs.yml
```

**Critical — describe each action in the instructions.** The AI uses this to decide when to invoke them:

```yaml
instructions: |
  You can help with:
  - Checking ticket status: ask for the ticket ID, then use GetTicketStatus
  - Creating a new ticket: collect the description and urgency, then use CreateTicket
  For anything else, tell the user this is outside your scope and offer to escalate.
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
"Facilities — facilities@company.com"             - payroll
                                                  - expense claim
                                                  - office supplies

                                                SendActivity:
                                                  "I'm only set up for [domain].
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

## How to Copy the Components

> **YAML indentation:** Always use **2 spaces** — never tabs. When pasting content between files, match the indentation level of the surrounding block exactly. A single wrong indent silently breaks the file. VS Code shows indentation errors as red underlines in the Problems panel (`Ctrl+Shift+M`).

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch. If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/IT Helpdesk/`) and already contains topic files. Topic files need rename-on-copy — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

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

**Verify nothing was missed before pushing:**

```powershell
# Windows — must return zero output
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\it_helpdesk" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\it_helpdesk" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/it_helpdesk --include="*.mcs.yml"
grep -rn "_REPLACE" agents/it_helpdesk --include="*.mcs.yml"
```

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
