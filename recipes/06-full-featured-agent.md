# Recipe 06 — Full-Featured Agent

An agent with authentication, personalised context, generative knowledge search, a connector action, and disambiguation. The kitchen-sink starting point.

## Use Case

- Internal enterprise agent where users are identified and content is personalised
- Agent that both answers questions (from knowledge) and takes actions (via connector)
- Production-grade agent with proper error handling, telemetry, and citation management

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml                        ← authenticationMode: ManualAzureAD or Integrated
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   ├── auth/
│   │   └── SignIn.topic.mcs.yml
│   ├── conversation-init/
│   │   └── ConversationInit.topic.mcs.yml
│   ├── disambiguation/
│   │   └── Disambiguation.topic.mcs.yml
│   ├── knowledge-search/
│   │   └── KnowledgeSearch.topic.mcs.yml
│   └── remove-citations/
│       └── RemoveCitations.topic.mcs.yml
├── actions/
│   └── connector/
│       └── connector-action.mcs.yml        ← one per operation
├── knowledge/
│   └── sharepoint/
│       └── sharepoint.knowledge.mcs.yml    ← one per library
└── variables/
    └── global-variable/
        ├── UserCountry.variable.mcs.yml
        └── UserDisplayName.variable.mcs.yml
```

## Conversation Flow

```
User opens conversation
    └─ [Greeting] fires → welcome message

User sends first message
    └─ [ConversationInit] fires once → loads M365 profile into Global.UserCountry, Global.UserDisplayName
    └─ [SignIn] fires if not authenticated → OAuthInput

Subsequent messages
    │
    ▼
[GenerativeAIRecognizer]
    │
    ├─ Single match → fires matched topic or connector action
    │
    ├─ Multiple matches → [Disambiguation] → user clarifies
    │
    └─ No match → [KnowledgeSearch] → generative answer from SharePoint
                        │
                        ├─ Answer found → [RemoveCitations] strips markers → clean response sent
                        └─ No answer → [Fallback] → retry or escalate

Any error → [OnError] → debug info (test) or safe message (prod) + telemetry log
```

## Write Instructions and OutOfScope Content

These two files define your agent's domain — write them together.

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | Who the agent is, what it answers, user context, available actions, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect message for out-of-domain questions |

**The `generate-agent-instructions.md` prompt writes both in one pass.**

### Step 1 — Option A: Use a ready-made persona (5 min)

```
1. Open prompts/system-prompts/hr-assistant.md  (or customer-support.md, it-helpdesk.md)
2. Copy everything inside the triple backticks
3. Paste into agent.mcs.yml replacing the entire instructions: | block
4. Replace every [BRACKET] value:
     [Company Name]  →  e.g. Contoso
     [company].com   →  your contact email domain
5. Then go to Step 3 to fill OutOfScope.topic.mcs.yml manually
```

### Step 1 — Option B: Generate both with Claude (10 min, recommended)

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into a Claude conversation
3. Fill in:
     Project brief:    "Authenticated enterprise agent for [domain]. Users are identified
                        via Azure AD. The agent answers questions from SharePoint and can
                        [describe connector action]. Must NOT handle [out-of-scope].
                        Redirect those to [contact]."
     Agent name:       HR Assistant
     Primary users:    Internal employees (authenticated)
     Authentication:   ManualAzureAD or Integrated
     Tone:             Empathetic
4. Paste Claude's output into agent.mcs.yml
```

**After pasting either option** — add these lines at the top of the `instructions:` block:

```yaml
instructions: |
  User: {Global.UserDisplayName}
  Country: {Global.UserCountry}

  ## Glossary
  {Global.Glossary}
  Silently expand any acronym found above before interpreting the user's message.

  ## ... rest of your domain instructions below
```

Remove the `## Glossary` block if you are not using the glossary component.

### Step 2 — Apply to agent.mcs.yml

Paste the output replacing the entire `instructions: |` block. Every line must be indented 2 spaces — YAML is whitespace-sensitive.

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

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch. If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/HR Assistant/`) and already contains topic files. Topic files need rename-on-copy — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

Replace `hr_assistant` with your agent's schemaName throughout.

### Step 1 — Create your agent folder

```bash
# Mac / Linux
mkdir -p agents/hr_assistant/topics agents/hr_assistant/actions \
          agents/hr_assistant/knowledge agents/hr_assistant/variables

# Windows PowerShell
$a = "agents\hr_assistant"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\actions","$a\knowledge","$a\variables"
```

### Step 2 — Copy base files

```bash
# Mac / Linux
cp base/agent.mcs.yml            agents/hr_assistant/
cp base/settings.mcs.yml         agents/hr_assistant/
cp base/topics/Greeting.topic.mcs.yml   agents/hr_assistant/topics/
cp base/topics/Fallback.topic.mcs.yml   agents/hr_assistant/topics/
cp base/topics/OnError.topic.mcs.yml    agents/hr_assistant/topics/
cp base/topics/OutOfScope.topic.mcs.yml agents/hr_assistant/topics/
```

```powershell
# Windows PowerShell
$a = "agents\hr_assistant"
Copy-Item base\agent.mcs.yml                      $a\
Copy-Item base\settings.mcs.yml                   $a\
Copy-Item base\topics\Greeting.topic.mcs.yml      $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml      $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml       $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml    $a\topics\
```

### Step 3 — Copy components

```bash
# Mac / Linux
cp components/topics/auth/SignIn.topic.mcs.yml                       agents/hr_assistant/topics/
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml agents/hr_assistant/topics/
cp components/topics/disambiguation/Disambiguation.topic.mcs.yml      agents/hr_assistant/topics/
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml   agents/hr_assistant/topics/
cp components/topics/remove-citations/RemoveCitations.topic.mcs.yml   agents/hr_assistant/topics/

# Rename the action file to match what it does (one copy per connector operation)
cp components/actions/connector/connector-action.mcs.yml  agents/hr_assistant/actions/GetLeaveBalance.mcs.yml

cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml  agents/hr_assistant/knowledge/

cp components/variables/user-display-name/UserDisplayName.variable.mcs.yml  agents/hr_assistant/variables/
cp components/variables/user-country/UserCountry.variable.mcs.yml            agents/hr_assistant/variables/
```

```powershell
# Windows PowerShell
$a = "agents\hr_assistant"
Copy-Item components\topics\auth\SignIn.topic.mcs.yml                        $a\topics\
Copy-Item components\topics\conversation-init\ConversationInit.topic.mcs.yml $a\topics\
Copy-Item components\topics\disambiguation\Disambiguation.topic.mcs.yml      $a\topics\
Copy-Item components\topics\knowledge-search\KnowledgeSearch.topic.mcs.yml   $a\topics\
Copy-Item components\topics\remove-citations\RemoveCitations.topic.mcs.yml   $a\topics\

# Rename the action file to match what it does
Copy-Item components\actions\connector\connector-action.mcs.yml  $a\actions\GetLeaveBalance.mcs.yml

Copy-Item components\knowledge\sharepoint\sharepoint.knowledge.mcs.yml        $a\knowledge\

Copy-Item components\variables\user-display-name\UserDisplayName.variable.mcs.yml  $a\variables\
Copy-Item components\variables\user-country\UserCountry.variable.mcs.yml            $a\variables\
```

### Step 4 — Run the ID replacement script

Replaces all `_REPLACE` node IDs and `<PLACEHOLDER>` values in one pass.

→ See **[QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids)** for the PowerShell and bash scripts.

Set `$schema = "hr_assistant"` and `$displayName = "HR Assistant"` (or your values) before running.

### Step 5 — Fill in remaining placeholders manually

After the script runs, a few values still need manual edits:

| File | Placeholder | Example |
|------|------------|---------|
| `agent.mcs.yml` | System prompt | Your domain, scope, out-of-scope instructions |
| `settings.mcs.yml` | `authenticationMode` | `ManualAzureAD` or `Integrated` |
| `topics/OutOfScope.topic.mcs.yml` | `<DOMAIN>`, `<OUT-OF-SCOPE-TOPIC>`, `<CONTACT>` | `HR policies`, `IT support`, `it@contoso.com` |
| `knowledge/<name>.knowledge.mcs.yml` | SharePoint URL | `https://contoso.sharepoint.com/sites/HR/...` |
| `actions/GetLeaveBalance.mcs.yml` | `<connection-reference-logical-name>`, `<OperationId>` | `shared_sharepointonline`, `GetItem` |

Verify nothing was missed before pushing:

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

---

## Setup Checklist

**File preparation (Steps 1–5 above):**
- [ ] Files copied, ID script run, verify commands return zero output

**Configuration:**
- [ ] `settings.mcs.yml` — set `authenticationMode: ManualAzureAD` or `Integrated`
- [ ] `agent.mcs.yml` — write `instructions` referencing `{Global.UserDisplayName}` and `{Global.UserCountry}`
- [ ] `topics/ConversationInit.topic.mcs.yml` — remove the Glossary block if you are not using a glossary knowledge source

**Copilot Studio portal (before pushing):**
- [ ] Add the **Office 365 Users** connector connection in your environment (required by ConversationInit)
- [ ] Add the connector connection your action uses (e.g. SharePoint, Dataverse)

**Push and test:**
- [ ] VS Code: Ctrl+Shift+P → **Copilot Studio: Apply Changes**
- [ ] Sign-in flow works
- [ ] User is greeted by name on first message
- [ ] Knowledge search returns answers without `[1][2]` citation markers
- [ ] Connector action is invoked and returns data correctly
- [ ] Ambiguous queries trigger the disambiguation prompt
- [ ] Unknown queries hit Fallback after 3 retries, then escalate
- [ ] Forced error (break a topic temporarily) shows safe message in published mode

## Scaling This Recipe

- Add more `connector-action.mcs.yml` files for additional operations
- Add more `sharepoint.knowledge.mcs.yml` files for additional libraries
- Evolve into the [orchestrator pattern](05-orchestrator-agent.md) by replacing the parent's domain logic with child agents
