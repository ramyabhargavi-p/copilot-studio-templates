# Recipe 02 — Authenticated Agent

An agent that requires users to sign in and loads their M365 profile to personalise responses.

## Use Case

- Internal agent where the user's identity matters (personalised responses, role-based access)
- Agent that calls connectors on behalf of the signed-in user (e.g. reading their own calendar or leave balance)
- Agent where you want to greet users by name and tailor responses to their region or department

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml                        ← set authenticationMode: ManualAzureAD
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   ├── auth/
│   │   └── SignIn.topic.mcs.yml            ← prompts user to sign in
│   └── conversation-init/
│       └── ConversationInit.topic.mcs.yml  ← loads M365 profile into global variables
└── variables/
    ├── user-display-name/
    │   └── UserDisplayName.variable.mcs.yml  ← declares Global.UserDisplayName
    └── user-country/
        └── UserCountry.variable.mcs.yml      ← declares Global.UserCountry
```

## How It Works

```
User opens conversation
    │
    ▼
[Greeting] — sends welcome message

User sends first message
    │
    ▼
[ConversationInit] fires (condition: IsBlank(Global.UserCountry))
    │
    ├─ Calls Office 365 Users API → Topic.M365Profile
    ├─ Sets Global.UserCountry
    └─ Sets Global.UserDisplayName

[SignIn] fires if auth is needed
    │
    └─ Presents OAuthInput card → user authenticates

Subsequent messages
    │
    └─ ConversationInit skipped (Global.UserCountry already set)
       Topics run with Global.UserDisplayName available
```

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | **Option A:** copy from `prompts/system-prompts/hr-assistant.md` → replace `[BRACKET]` values. **Option B:** use `prompts/ai-prompts/generate-agent-instructions.md` with Claude. Either way, include these lines in the instructions: `User: {Global.UserDisplayName}` and `Country: {Global.UserCountry}`. See [`prompts/README.md`](../prompts/README.md). |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` |
| `settings.mcs.yml` | `authenticationMode: None` | `authenticationMode: ManualAzureAD` |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` |
| `ConversationInit.topic.mcs.yml` | `<AGENT-SCHEMA-NAME>` | same as `<AgentName>` |

## Write Instructions and OutOfScope Content

These two files define your agent's domain — write them together.

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | Who the agent is, what it answers, user context, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect message for out-of-domain questions |

**The `generate-agent-instructions.md` prompt writes both in one pass.** Its output includes a `## What I cannot help with` section that maps directly into `OutOfScope.topic.mcs.yml`.

### Step 1 — Option A: Use a ready-made persona (5 min)

```
1. Open prompts/system-prompts/hr-assistant.md  (or it-helpdesk.md for IT agents)
2. Copy everything inside the triple backticks
3. Paste into agent.mcs.yml replacing the entire instructions: | block
4. Replace every [BRACKET] value:
     [Company Name]  →  e.g. Contoso
     [company].com   →  your contact email domain
5. Add these lines at the top of the instructions block:
     User: {Global.UserDisplayName}
     Country: {Global.UserCountry}
6. Then go to Step 3 to fill in OutOfScope.topic.mcs.yml manually
```

### Step 1 — Option B: Generate both with Claude (10 min, recommended)

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into Claude
3. Fill in:
     Project brief:  "Authenticated agent for internal employees. Users are greeted by name.
                      Answers questions about [domain]. Country-aware (uses {Global.UserCountry}).
                      Must NOT handle [out-of-scope]. Redirect those to [contact]."
     Agent name:     HR Assistant
     Primary users:  Internal employees (authenticated via Azure AD)
     Authentication: ManualAzureAD
     Tone:           Empathetic
4. Paste Claude's output into agent.mcs.yml
```

**After pasting either option** — add these lines at the top of the `instructions:` block:

```yaml
instructions: |
  User: {Global.UserDisplayName}
  Country: {Global.UserCountry}
  ## ... rest of your instructions below
```

### Step 2 — Apply to agent.mcs.yml

Paste the instructions replacing the entire `instructions: |` block. Every line must be indented exactly 2 spaces — YAML is whitespace-sensitive.

### Step 3 — Apply to OutOfScope.topic.mcs.yml

Claude's "What I cannot help with" items become trigger phrases and redirect text.

**Mapping:**

```
Claude output                                →  OutOfScope.topic.mcs.yml
─────────────────────────────────────────────────────────────────────────────
"Payroll — payroll@company.com"                 triggerQueries:
"IT issues — it@company.com"                      - payroll
"Finance — finance@company.com"                   - what is my salary
                                                  - IT support
                                                  - expense reimbursement

                                                SendActivity:
                                                  "I'm only set up for [domain].
                                                   For [topic], [contact] is best."
```

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

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch. If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/HR Assistant/`) and already contains topic files. Topic files need rename-on-copy — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

Replace `hr_assistant` with your agent's schemaName throughout.

```bash
# Mac / Linux
mkdir -p agents/hr_assistant/topics agents/hr_assistant/variables

cp base/agent.mcs.yml                       agents/hr_assistant/
cp base/settings.mcs.yml                    agents/hr_assistant/
cp base/topics/Greeting.topic.mcs.yml       agents/hr_assistant/topics/
cp base/topics/Fallback.topic.mcs.yml       agents/hr_assistant/topics/
cp base/topics/OnError.topic.mcs.yml        agents/hr_assistant/topics/
cp base/topics/OutOfScope.topic.mcs.yml     agents/hr_assistant/topics/

cp components/topics/auth/SignIn.topic.mcs.yml                       agents/hr_assistant/topics/
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml agents/hr_assistant/topics/

cp components/variables/user-display-name/UserDisplayName.variable.mcs.yml  agents/hr_assistant/variables/
cp components/variables/user-country/UserCountry.variable.mcs.yml            agents/hr_assistant/variables/
```

```powershell
# Windows PowerShell
$a = "agents\hr_assistant"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\variables"

Copy-Item base\agent.mcs.yml                    $a\
Copy-Item base\settings.mcs.yml                 $a\
Copy-Item base\topics\Greeting.topic.mcs.yml    $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml    $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml     $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml  $a\topics\

Copy-Item components\topics\auth\SignIn.topic.mcs.yml                        $a\topics\
Copy-Item components\topics\conversation-init\ConversationInit.topic.mcs.yml $a\topics\

Copy-Item components\variables\user-display-name\UserDisplayName.variable.mcs.yml  $a\variables\
Copy-Item components\variables\user-country\UserCountry.variable.mcs.yml            $a\variables\
```

**Run the ID replacement script** — replaces all `_REPLACE` node IDs and `<PLACEHOLDER>` values in one pass.
→ See [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids). Set `$schema = "hr_assistant"`.

**Verify nothing was missed before pushing:**

```powershell
# Windows — must return zero output
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\hr_assistant" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\hr_assistant" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/hr_assistant --include="*.mcs.yml"
grep -rn "_REPLACE" agents/hr_assistant --include="*.mcs.yml"
```

## Setup Checklist

- [ ] Files copied and ID script run (verify returns zero output)
- [ ] `settings.mcs.yml` — `authenticationMode` set to `ManualAzureAD` or `IntegratedAzureAD`
- [ ] `agent.mcs.yml` — system prompt includes `"Address the user as {Global.UserDisplayName}"`
- [ ] `topics/ConversationInit.topic.mcs.yml` — remove Glossary block if not using a glossary knowledge source
- [ ] Add **Office 365 Users** connector connection in your environment (required by ConversationInit)
- [ ] VS Code → **Copilot Studio: Apply Changes**
- [ ] Test: open the agent, sign in, confirm greeting uses your name

## Optional Additions

- Add [`knowledge-search`](../components/topics/knowledge-search/) for generative Q&A
- Add [`sharepoint`](../components/knowledge/sharepoint/) knowledge scoped to the user's region using `Global.UserCountry`
- Add connector actions that call APIs on behalf of the signed-in user
