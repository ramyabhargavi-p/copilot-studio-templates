# Recipe 05 — Orchestrator Agent

A parent agent that routes user requests to specialist child agents, each handling a specific domain.

## Use Case

- Corporate assistant with HR, IT, and Finance specialists
- Multi-product support agent where each product has its own specialist
- Any agent where domain separation improves quality, maintainability, or compliance

## Components

```
base/                                       ← the parent orchestrator agent
├── agent.mcs.yml                           ← orchestrator instructions (routing, not domain knowledge)
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   └── disambiguation/
│       └── Disambiguation.topic.mcs.yml    ← when multiple specialists could apply
└── agents/
    └── child-agent/
        └── child-agent.mcs.yml             ← one copy per specialist (rename per domain)
```

## How It Works

```
User message
    │
    ▼
[Parent Orchestrator] reads child agent descriptions
    │
    ├─ Clear match → routes directly to matching child agent
    │
    ├─ Ambiguous match → Disambiguation topic → user clarifies
    │
    └─ No match → Fallback topic

[Child Agent] handles the request with its own instructions + knowledge + actions
    │
    └─ Returns result → Parent delivers to user
```

## Write Instructions and OutOfScope Content

These two files define your orchestrator's routing scope — write them together.

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` → `instructions:` | Routing rules — lists specialists and when to delegate to each |
| `topics/OutOfScope.topic.mcs.yml` | Trigger phrases for questions outside ALL specialist domains |

**The `generate-agent-instructions.md` prompt writes both in one pass.** Its "What I cannot help with" section covers what no specialist handles.

### Step 1 — Parent orchestrator instructions

The parent's `instructions:` must focus on **routing only** — not domain knowledge. No ready-made persona fits this exactly, so use Option B.

**Option B — Generate both with Claude (recommended)**

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into a Claude conversation
3. Fill in:
     Project brief:    "Orchestrator agent that routes user requests to specialist child agents.
                        Specialists: [list each domain, e.g. HR, IT, Finance].
                        The orchestrator must NOT answer domain questions itself.
                        Always delegate to the correct specialist.
                        Out-of-scope: anything no specialist handles → redirect to [contact]."
     Agent name:       Corporate Assistant
     Primary users:    Internal employees
     Authentication:   ManualAzureAD or IntegratedAzureAD
     Tone:             Professional
4. Paste Claude's output into agent.mcs.yml
```

**Or write it directly** — the orchestrator instructions are short by design:

```yaml
instructions: |
  You are an orchestrator. Your only job is to route user requests to the right specialist.

  Available specialists:
  - HR Specialist: leave policies, benefits, onboarding, HR procedures
  - IT Helpdesk: password resets, hardware issues, software access, VPN
  - Finance Queries: expenses, reimbursements, purchase orders, finance approvals

  Rules:
  - Never answer domain-specific questions yourself — always delegate to a specialist
  - If the user's request could fit more than one specialist, use the Disambiguation topic to clarify
  - If no specialist applies, say so and tell the user what you can help with
```

### Step 2 — Apply to agent.mcs.yml

Paste replacing the entire `instructions: |` block. Every line must be indented 2 spaces — YAML is whitespace-sensitive.

### Step 3 — Apply to OutOfScope.topic.mcs.yml

Claude's "What I cannot help with" section covers questions no specialist handles — map those to trigger phrases.

**Mapping:**

```
Claude output                                →  OutOfScope.topic.mcs.yml
─────────────────────────────────────────────────────────────────────────────
"Facilities bookings — facilities@co.com"       triggerQueries:
"Legal queries — legal@co.com"                    - book a meeting room
"Marketing requests — mktg@co.com"               - legal contract review
                                                  - marketing budget

                                                SendActivity:
                                                  "That's outside what I can route.
                                                   For [topic], contact [contact]."
```

**Need more trigger phrases?** Ask Claude:

```
Generate 10 trigger phrases for a Copilot Studio OutOfScope topic.
The agent routes to: HR, IT, and Finance specialists.
Out-of-scope areas: [list from your instructions — what no specialist handles].
Include: formal, casual, abbreviated, and question variations.
Output as a YAML list (- phrase format).
```

→ Template: [`prompts/ai-prompts/generate-topic.md`](../prompts/ai-prompts/generate-topic.md) → "Generate trigger phrases only"
→ All prompt templates: [`prompts/README.md`](../prompts/README.md)

### Child agent descriptions

Each child agent's `description:` field is what the parent reads to make routing decisions. Write it in `agents/<name>.mcs.yml` under the `description:` key. Be specific and mutually exclusive.

| Child agent | Good description | Bad description (too vague) |
|---|---|---|
| HR Specialist | `Handles leave policies, leave balance queries, and leave requests. Use for annual leave, sick leave, or parental leave questions.` | `Handles HR questions.` |
| IT Helpdesk | `Handles IT support — password resets, hardware faults, software access requests, VPN issues. Do not use for HR or Finance.` | `Handles IT issues.` |
| Finance Queries | `Handles expense claims, purchase order approvals, reimbursements, and finance-related queries.` | `Handles money questions.` |

---

## How to Copy the Components

> **YAML indentation:** Always use **2 spaces** — never tabs. When pasting content between files, match the indentation level of the surrounding block exactly. A single wrong indent silently breaks the file. VS Code shows indentation errors as red underlines in the Problems panel (`Ctrl+Shift+M`).

> **Fresh folder vs cloned folder:** The commands below build a fresh agents folder from scratch. If you are using the Cloud-First path (VS Code Clone Agent), your folder will be named after the display name (e.g. `agents/Corporate Assistant/`) and already contains topic files. Topic files need rename-on-copy — a plain `cp Greeting.topic.mcs.yml` creates a duplicate alongside the existing `Greeting.mcs.yml`. See [troubleshooting/README.md → 2a](../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder) for the rename command.

Replace `hr_orchestrator` with your parent agent's schemaName.

### Step 1 — Create folders

```bash
# Mac / Linux
mkdir -p agents/hr_orchestrator/topics agents/hr_orchestrator/agents
```

```powershell
# Windows PowerShell
$a = "agents\hr_orchestrator"
New-Item -ItemType Directory -Force -Path "$a\topics","$a\agents"
```

### Step 2 — Copy base + disambiguation

```bash
# Mac / Linux
cp base/agent.mcs.yml                       agents/hr_orchestrator/
cp base/settings.mcs.yml                    agents/hr_orchestrator/
cp base/topics/Greeting.topic.mcs.yml       agents/hr_orchestrator/topics/
cp base/topics/Fallback.topic.mcs.yml       agents/hr_orchestrator/topics/
cp base/topics/OnError.topic.mcs.yml        agents/hr_orchestrator/topics/
cp base/topics/OutOfScope.topic.mcs.yml     agents/hr_orchestrator/topics/
cp components/topics/disambiguation/Disambiguation.topic.mcs.yml  agents/hr_orchestrator/topics/
```

```powershell
# Windows PowerShell
$a = "agents\hr_orchestrator"
Copy-Item base\agent.mcs.yml                    $a\
Copy-Item base\settings.mcs.yml                 $a\
Copy-Item base\topics\Greeting.topic.mcs.yml    $a\topics\
Copy-Item base\topics\Fallback.topic.mcs.yml    $a\topics\
Copy-Item base\topics\OnError.topic.mcs.yml     $a\topics\
Copy-Item base\topics\OutOfScope.topic.mcs.yml  $a\topics\
Copy-Item components\topics\disambiguation\Disambiguation.topic.mcs.yml  $a\topics\
```

### Step 3 — Copy one child agent file per specialist domain

```bash
# Mac / Linux — rename each copy to match the domain it handles
cp components/agents/child-agent/child-agent.mcs.yml  agents/hr_orchestrator/agents/HRSpecialist.mcs.yml
cp components/agents/child-agent/child-agent.mcs.yml  agents/hr_orchestrator/agents/ITHelpdesk.mcs.yml
cp components/agents/child-agent/child-agent.mcs.yml  agents/hr_orchestrator/agents/FinanceQueries.mcs.yml
```

```powershell
# Windows PowerShell
$a = "agents\hr_orchestrator"
Copy-Item components\agents\child-agent\child-agent.mcs.yml  $a\agents\HRSpecialist.mcs.yml
Copy-Item components\agents\child-agent\child-agent.mcs.yml  $a\agents\ITHelpdesk.mcs.yml
Copy-Item components\agents\child-agent\child-agent.mcs.yml  $a\agents\FinanceQueries.mcs.yml
```

### Step 4 — Run the ID replacement script

→ See [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids). Set `$schema = "hr_orchestrator"`.

### Step 5 — Fill in child agent descriptions (manual — script cannot do this)

Open each file in `agents/hr_orchestrator/agents/` and replace the `description` placeholder. **This is the most important field — the parent routes entirely based on it.**

| File | `description` example |
|------|----------------------|
| `HRSpecialist.mcs.yml` | `Handles all questions about leave policies, leave balances, and leave requests. Use when the user asks about annual leave, sick leave, or parental leave.` |
| `ITHelpdesk.mcs.yml` | `Handles IT support requests — password resets, hardware issues, software access, VPN problems. Do not use for HR or Finance queries.` |
| `FinanceQueries.mcs.yml` | `Handles questions about expenses, reimbursements, purchase orders, and finance approvals. Use when the user asks about paying for something or claiming money back.` |

Be specific and mutually exclusive — vague or overlapping descriptions cause misrouting.

Also write the parent's `instructions` in `agent.mcs.yml` focused on routing, not domain knowledge:

```
You are an orchestrator. Route user requests to the appropriate specialist agent.
Do not answer domain-specific questions yourself — always delegate.
If the user's intent is unclear, use the Disambiguation topic to clarify before routing.
```

**Verify nothing was missed before pushing:**

```powershell
# Windows — must return zero output
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\hr_orchestrator" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\hr_orchestrator" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/hr_orchestrator --include="*.mcs.yml"
grep -rn "_REPLACE" agents/hr_orchestrator --include="*.mcs.yml"
```

## Setup Checklist

### Parent

- [ ] Files copied and ID script run (verify returns zero output)
- [ ] `agent.mcs.yml` — routing-focused instructions written (not domain-specific)
- [ ] Each child agent `description` is specific and mutually exclusive

### Child agents

- [ ] In Copilot Studio, open each child agent and configure its knowledge sources and actions
- [ ] VS Code → **Copilot Studio: Apply Changes**

### Testing

- [ ] Ask a question clearly belonging to each domain — verify the right specialist answers
- [ ] Ask an ambiguous question (e.g. "I need help") — verify Disambiguation topic fires
- [ ] Ask something outside all domains — verify Fallback fires on the parent

## Naming Child Agent Files

```
agents/
├── HRSpecialist.mcs.yml
├── ITHelpdesk.mcs.yml
└── FinanceQueries.mcs.yml
```

## Gotchas

- Child agent `description` fields drive all routing — test routing with ambiguous queries to identify gaps
- Overlap between specialist domains causes misrouting — make descriptions mutually exclusive
- Child agents are YAML-only (not available in the Copilot Studio canvas UI)
- Each child agent can have its own knowledge sources and actions configured separately in Copilot Studio
