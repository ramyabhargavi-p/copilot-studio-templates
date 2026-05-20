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

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | Who the agent is, what it answers, user context, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect message for out-of-domain questions |

**Option A personas:** `prompts/system-prompts/hr-assistant.md` or `it-helpdesk.md`

**After pasting either option** — add these lines at the top of the `instructions:` block:

```yaml
instructions: |
  User: {Global.UserDisplayName}
  Country: {Global.UserCountry}
  ## ... rest of your instructions below
```

**Option B project brief:**

```
"Authenticated agent for internal employees. Users are greeted by name.
 Answers questions about [domain]. Country-aware ({Global.UserCountry}).
 Must NOT handle [out-of-scope]. Redirect those to [contact]."
Agent name: [Your Agent Name] | Auth: ManualAzureAD | Tone: Empathetic
```

→ **Follow the full steps** (apply to both files): [`docs/SYSTEM-PROMPT-PATTERN.md`](../docs/SYSTEM-PROMPT-PATTERN.md)

---

## How to Copy the Components

> **Before copying:** Use 2-space indentation (never tabs). Cloud-First (cloned folder) users need rename-on-copy — see [troubleshooting → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder).

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

→ **Verify before pushing:** see [docs/QUICKSTART.md → Verify](../docs/QUICKSTART.md) — both commands must return zero output.

## Setup Checklist

- [ ] Files copied and ID script run (verify returns zero output)
- [ ] `settings.mcs.yml` — `authenticationMode` set to `ManualAzureAD` or `Integrated`
- [ ] `agent.mcs.yml` — system prompt includes `"Address the user as {Global.UserDisplayName}"`
- [ ] `topics/ConversationInit.topic.mcs.yml` — remove Glossary block if not using a glossary knowledge source
- [ ] Add **Office 365 Users** connector connection in your environment (required by ConversationInit)
- [ ] VS Code → **Copilot Studio: Apply Changes**
- [ ] Test: open the agent, sign in, confirm greeting uses your name

## Optional Additions

- Add [`knowledge-search`](../components/topics/knowledge-search/) for generative Q&A
- Add [`sharepoint`](../components/knowledge/sharepoint/) knowledge scoped to the user's region using `Global.UserCountry`
- Add connector actions that call APIs on behalf of the signed-in user
