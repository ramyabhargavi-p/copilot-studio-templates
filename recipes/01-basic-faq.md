# Recipe 01 — Basic FAQ Agent

An agent that answers questions from a SharePoint knowledge base using generative AI.

## Use Case

- Internal knowledge base assistant (HR policies, IT runbooks, company procedures)
- First responder that deflects common questions without a human agent
- Anonymous agent — no sign-in required

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml          ← catches questions the knowledge base can't answer
    └── OnError.topic.mcs.yml

components/
├── topics/
│   └── knowledge-search/
│       └── KnowledgeSearch.topic.mcs.yml   ← generative answers from SharePoint
└── knowledge/
    └── sharepoint/
        └── sharepoint.knowledge.mcs.yml    ← points to your SharePoint library
```

## How It Works

```
User message
    │
    ▼
[GenerativeAIRecognizer]
    │
    ├─ Recognised intent → route to matching topic
    │
    └─ No match → KnowledgeSearch topic
                    │
                    ├─ Answer found → send generated response
                    │
                    └─ No answer → Fallback topic → retry or escalate
```

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | **Option A:** copy from `prompts/system-prompts/knowledge-base.md` → replace `[BRACKET]` values. **Option B:** use `prompts/ai-prompts/generate-agent-instructions.md` with Claude. See [`prompts/README.md`](../prompts/README.md). |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` above |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` above |
| `sharepoint.knowledge.mcs.yml` | `<SHAREPOINT_SITE_URL>` | your SharePoint library URL |

## Write Instructions and OutOfScope Content

→ Full steps: [`docs/SYSTEM-PROMPT-PATTERN.md`](../docs/SYSTEM-PROMPT-PATTERN.md)

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | Who the agent is, what it answers, tone, escalation |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases + redirect message for out-of-domain questions |

**Option A persona:** `prompts/system-prompts/knowledge-base.md`

**Option B project brief:**

```
"Answers questions about [topic] from a SharePoint knowledge base.
 Must NOT handle [out-of-scope areas]. Redirect those to [contact]."
Agent name: [Your Agent Name] | Auth: None | Tone: Professional
```

---

## How to Copy the Components

> **YAML indentation:** Always use **2 spaces** — never tabs. When pasting content between files, match the indentation level of the surrounding block exactly. A single wrong indent silently breaks the file. VS Code shows indentation errors as red underlines in the Problems panel (`Ctrl+Shift+M`).

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch (schema-name folder, e.g. `agents/hr_assistant/`). If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/HR Assistant/`) and already contains topic files. Topic files need rename-on-copy in that case — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

Replace `hr_assistant` with your agent's schemaName throughout.

```bash
# Mac / Linux
mkdir -p agents/hr_assistant/topics agents/hr_assistant/knowledge

cp base/agent.mcs.yml                       agents/hr_assistant/
cp base/settings.mcs.yml                    agents/hr_assistant/
cp base/topics/Greeting.topic.mcs.yml       agents/hr_assistant/topics/
cp base/topics/Fallback.topic.mcs.yml       agents/hr_assistant/topics/
cp base/topics/OnError.topic.mcs.yml        agents/hr_assistant/topics/
cp base/topics/OutOfScope.topic.mcs.yml     agents/hr_assistant/topics/

cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml  agents/hr_assistant/topics/
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml       agents/hr_assistant/knowledge/
```

```powershell
# Windows PowerShell
$a = "agents\hr_assistant"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\knowledge"

Copy-Item base\agent.mcs.yml                    $a\
Copy-Item base\settings.mcs.yml                 $a\
Copy-Item base\topics\Greeting.topic.mcs.yml    $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml    $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml     $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml  $a\topics\

Copy-Item components\topics\knowledge-search\KnowledgeSearch.topic.mcs.yml  $a\topics\
Copy-Item components\knowledge\sharepoint\sharepoint.knowledge.mcs.yml       $a\knowledge\
```

**Run the ID replacement script** — replaces all `_REPLACE` node IDs and `<PLACEHOLDER>` values in one pass.
→ See [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids). Set `$schema = "hr_assistant"`.

After the script runs, fill in the SharePoint URL in `knowledge/sharepoint.knowledge.mcs.yml` (the script doesn't know your URL).

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
- [ ] `agent.mcs.yml` — system prompt written (what the agent does, what it won't answer)
- [ ] `knowledge/sharepoint.knowledge.mcs.yml` — SharePoint URL replaced
- [ ] VS Code → **Copilot Studio: Apply Changes**
- [ ] Test: ask 3 questions the knowledge base should answer; confirm no `[1][2]` citation markers appear

## Optional Additions

- Add [`remove-citations`](../components/topics/remove-citations/) to strip `[1][2]` markers from responses
- Add a second `sharepoint.knowledge.mcs.yml` pointing to a different library for broader coverage
- Add [`public-website`](../components/knowledge/public-website/) knowledge if some answers come from public docs
