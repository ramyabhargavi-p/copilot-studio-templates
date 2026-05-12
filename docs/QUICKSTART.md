# Quickstart — Working Agent in Under 1 Hour

Pick your agent type. Follow the steps. Deploy.

**Prerequisites before you start:**
1. `pac` CLI installed → `dotnet tool install --global Microsoft.PowerApps.CLI.Tool`
2. Authenticated to your Dev environment → `pac auth create`
3. This repo cloned and a feature branch created → `git checkout -b feature/<your-agent>`
4. VS Code with Copilot Studio extension active (Copilot Studio icon in status bar)

Not done yet? → [`ENGINEERING-PLAYBOOK.md`](../ENGINEERING-PLAYBOOK.md) Stage 1 walks every step.

---

## Step 1 — Pick your agent type

| I want to build… | Use recipe | Time |
|---|---|---|
| FAQ / knowledge bot — answers questions from SharePoint | [`01-basic-faq`](../recipes/01-basic-faq.md) | 30 min |
| Same, but users must sign in + greeted by name | [`02-authenticated-agent`](../recipes/02-authenticated-agent.md) | 45 min |
| Agent that submits data to a system (tickets, requests) | [`03-connector-action-agent`](../recipes/03-connector-action-agent.md) | 60 min |
| Agent that calls an MCP tool | [`04-mcp-action-agent`](../recipes/04-mcp-action-agent.md) | 60 min |
| Orchestrator with specialist child agents | [`05-orchestrator-agent`](../recipes/05-orchestrator-agent.md) | 2+ hrs |

---

## Step 2 — Create your agent

**For most developers: use Path 1.** Path 2 is only for automation and CI/CD pipelines.

---

### Path 1 — Cloud-First (use this by default)

> **How it works:** The VS Code "Apply Changes" command updates an *existing* agent draft.
> It cannot create a new agent. Create it in the browser first, then work locally.

```
1. Browser: make.preview.microsoft.com → Create → New blank agent → name it → Create

2. VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"
   → sign in → select your environment → select the agent → choose output folder

   ⚠ IMPORTANT — the extension always creates a subfolder named after the agent display name
   inside the folder you select. Example:
     You select:    agents\
     Extension creates: agents\HR Assistant\    ← this is your working folder
   If you select agents\hr_assistant\ as output, result is agents\hr_assistant\HR Assistant\

   Recommended: select agents\ as output → rename the created folder to hr_assistant\ if needed.
   Never manually copy files into the output folder — conn.json (needed for Apply Changes) is only
   created by the Clone Agent command and must stay in place.

   Result: agents\<display name>\ with Greeting, Fallback, OnError (minimal — no telemetry or retry logic).
   OutOfScope is NOT created by a blank agent — it comes from base/topics.

3. Copy the 4 base/ topic files into your cloned folder. Run the ID script (Step 4) before or after — either order works.

   ⚠ NAMING DIFFERENCE — Clone Agent downloads topics as `Greeting.mcs.yml` (no `.topic.` prefix).
   Templates in base/ are named `Greeting.topic.mcs.yml` (with `.topic.`). A plain `cp` creates a
   NEW file alongside the existing one — both declare `componentName: Greeting` — Apply Changes
   fails with a duplicate component error. Copy WITH RENAME:

   # Windows PowerShell — replace "HR Assistant" with your agent's display name
   $clone = "agents\HR Assistant"
   @("Greeting","Fallback","OnError","OutOfScope") | ForEach-Object {
       Copy-Item "base\topics\$_.topic.mcs.yml" "$clone\topics\$_.mcs.yml" -Force
   }

   # Mac / Linux
   CLONE="agents/HR Assistant"
   for t in Greeting Fallback OnError OutOfScope; do
       cp "base/topics/$t.topic.mcs.yml" "$CLONE/topics/$t.mcs.yml"
   done

   ✓ agent.mcs.yml and settings.mcs.yml have the same names in both base/ and the clone — plain cp works for those.
   ✓ New files you add from components/ (knowledge, actions, variables, extra topics) don't conflict — the clone doesn't have them yet.

4. Write the system prompt for agent.mcs.yml — two options:

   OPTION A — Use a ready-made persona (fastest, 5 min):
   → Open prompts/system-prompts/<type>.md  (hr-assistant, it-helpdesk, customer-support, knowledge-base)
   → Copy everything inside the triple backticks
   → Paste it into agent.mcs.yml replacing the entire instructions: | block
   → Replace all [BRACKET] values: [Company Name], [company].com contacts, etc.

   OPTION B — Generate a custom prompt with Claude (recommended for real projects, 10 min):
   → Open prompts/ai-prompts/generate-agent-instructions.md
   → Copy the prompt template (the block starting "You are a Copilot Studio specialist...")
   → Paste it into a Claude conversation (or this Claude Code session)
   → Fill in the [PASTE SOW SECTION OR PROJECT BRIEF HERE] with 3-5 sentences describing:
        - what the agent does, who uses it, what it must NOT handle, where out-of-scope topics redirect
   → Fill in: Agent name, Primary users, Authentication, Tone
   → Claude returns a ready-to-paste instructions: | block — copy it into agent.mcs.yml

   Both options produce content for the same field:
   agent.mcs.yml → instructions: | block (lines 6 onwards)

5. Fill in OutOfScope.topic.mcs.yml placeholders:
   <DOMAIN>              → what your agent handles (e.g. HR policies)
   <OUT-OF-SCOPE-TOPIC>  → what it does NOT handle (e.g. IT support)
   <CONTACT>             → where to redirect (e.g. it@company.com)

6. Run the node ID replacement script (base/ topics have _REPLACE IDs — see Step 4 below)

7. Add capabilities from components/ as needed:
   knowledge/sharepoint, topics/escalation, topics/feedback (CSAT), actions/connector, etc.

8. VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"

9. Test: make.preview.microsoft.com → your agent → Test pane → Publish
```

**What base/ topics add over the blank agent's defaults:**

| Topic | Blank agent | base/ version |
|-------|------------|--------------|
| Greeting | Welcome message | Welcome message + `Conversation.Started` telemetry |
| Fallback | Generic "I don't understand" | Telemetry + 3-retry logic + auto-escalate |
| OnError | Silent failure | Debug details in test mode, safe message in production + `Agent.ErrorOccurred` telemetry |
| OutOfScope | Not present | Telemetry + redirect message with domain-specific placeholders |

**CSAT is not in base/** — add it from `components/topics/feedback/` when needed.

**Time:** 30–45 minutes for a working FAQ agent
**Concrete example:** → [`examples/team-demo/DEMO-WALKTHROUGH.md`](../examples/team-demo/DEMO-WALKTHROUGH.md)

---

### Path 2 — CLI-only (`pac copilot create`) — automation and CI/CD only

> **Use this only when scripting agent creation (pipelines, cloning, multi-environment promotion).**
> It is NOT simpler than Path 1 for a developer building a single agent.
>
> **Prerequisite: at least one agent must already exist in your environment.**
> `pac copilot create` requires a template YAML extracted from an existing agent — it cannot create from scratch.

```
1. Authenticate (one-time)
   pac auth create
   pac env select --environment "Dev - My Project"

2. Extract a template from your existing agent:
   pac copilot list                          ← find your agent's schema name or Copilot ID
   pac copilot extract-template --bot "<schema-name-or-copilot-id>" --templateFileName "agents\hr_assistant\template.yaml"

3. Create the new agent from that template:
   pac copilot create --displayName "HR Assistant" --schemaName "hr_assistant" --solution "Default" --templateFileName "agents\hr_assistant\template.yaml"

4. Clone the created agent locally for multi-file YAML editing:
   VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent" → select hr_assistant

5. Edit topics, actions, knowledge in the cloned folder

6. Push changes back:
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"

7. Publish — use the display name or Copilot ID from pac copilot list, NOT the schema name
   pac copilot publish --bot "HR Assistant"
```

**When to use this path:** Second agent onwards. Creating a copy or variant of an existing agent without touching the browser.

**Time:** 45–60 minutes first time

---

## Step 3 — Fill in the 5 values (Path 1 only)

> **Path 2 users: skip this step.** Your cloned files already have real values set by `pac copilot create`.
> Focus on updating the system prompt and replacing topics with ones from `base/` or `components/`.

> `<AGENT_SCHEMA>`, `<SCHEMA>`, `<agent_schema_name>`, `<AGENT-SCHEMA-NAME>` all mean the same
> thing — your agent's **schemaName**. Set it once; it goes everywhere.
>
> Rules: lowercase, underscores instead of spaces, ≤ 30 characters. Example: `hr_assistant`

| # | Placeholder | File | Line | Example value |
|---|-------------|------|------|--------------|
| 1 | `<AgentName>` | `agent.mcs.yml` | 2 | `hr_assistant` |
| 2 | `<Agent Display Name>` | `agent.mcs.yml` line 4 and `settings.mcs.yml` line 1 | 4 / 1 | `HR Assistant` |
| 3 | `<agent_schema_name>` | `settings.mcs.yml` | 2 | `hr_assistant` (same as #1) |
| 4 | `<AGENT_SCHEMA>` | `topics/Fallback.topic.mcs.yml` | 53 | `hr_assistant` (same as #1) |
| 5 | System prompt | `agent.mcs.yml` | 32–48 | Your domain, scope, out-of-scope |

### `agent.mcs.yml` — change lines 2 and 4

```yaml
# Before                              # After (example)
componentName: <AgentName>            componentName: hr_assistant
displayName: <Agent Display Name>     displayName: HR Assistant
```

### `settings.mcs.yml` — change lines 1 and 2

```yaml
# Before                              # After (example)
displayName: <Agent Display Name>     displayName: HR Assistant
schemaName: <agent_schema_name>       schemaName: hr_assistant
```

### `topics/Fallback.topic.mcs.yml` — change line 53

```yaml
# Before                                        # After (example)
dialog: <AGENT_SCHEMA>.topic.Escalate           dialog: hr_assistant.topic.Escalate
```

---

## Step 4 — Replace node IDs

Every YAML node needs a unique ID. The VS Code extension auto-generates these on save.
Or run this script once:

### Windows (PowerShell)

```powershell
$schema      = "hr_assistant"        # ← your schemaName (used in YAML values)
$displayName = "HR Assistant"        # ← your display name
$folder      = "agents\$displayName" # ← folder on disk — VS Code Clone Agent names it after the display name

# Step 1 — replace _REPLACE node IDs
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path $folder | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    while ($content -match '_REPLACE\d*') {
        $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
        $content = [regex]::Replace($content, '_REPLACE\d*', "_$id", 1)
    }
    Set-Content $_.FullName $content
}

# Step 2 — replace all name/schema placeholders
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path $folder |
    ForEach-Object {
        (Get-Content $_.FullName) `
            -replace '<AgentName>',          $schema `
            -replace '<Agent Display Name>', $displayName `
            -replace '<agent_schema_name>',  $schema `
            -replace '<AGENT_SCHEMA>',       $schema `
            -replace '<AGENT-SCHEMA-NAME>',  $schema `
            -replace '<SCHEMA>',             $schema |
        Set-Content $_.FullName
    }
```

### Mac / Linux (bash)

```bash
SCHEMA="hr_assistant"        # ← your schemaName (used in YAML values)
DISPLAY_NAME="HR Assistant"  # ← your display name
FOLDER="agents/$DISPLAY_NAME" # ← folder on disk — VS Code Clone Agent names it after the display name
find "$FOLDER" -name "*.mcs.yml" | while read f; do
  while grep -qE '_REPLACE[0-9]*' "$f"; do
    id=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c6)
    sed -i "0,/_REPLACE[0-9]*/s/_REPLACE[0-9]*/_${id}/" "$f"
  done
  sed -i "s/<AgentName>/$SCHEMA/g" "$f"
  sed -i "s/<Agent Display Name>/$DISPLAY_NAME/g" "$f"
  sed -i "s/<agent_schema_name>/$SCHEMA/g" "$f"
  sed -i "s/<AGENT_SCHEMA>/$SCHEMA/g" "$f"
  sed -i "s/<AGENT-SCHEMA-NAME>/$SCHEMA/g" "$f"
  sed -i "s/<SCHEMA>/$SCHEMA/g" "$f"
done
```

### Verify — must return zero lines before pushing

> **Note:** `<[A-Za-z]` matches placeholder-style angle brackets only — it ignores Power Fx
> operators like `< 3` or `> 0` which are valid code, not placeholders.

```powershell
# Windows PowerShell — use display name (folder is named by display name, not schema)
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\HR Assistant" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\HR Assistant" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" "agents/HR Assistant" --include="*.mcs.yml"
grep -rn "_REPLACE" agents/hr_assistant --include="*.mcs.yml"
```

---

## Step 5 — Add components

Copy components from `components/` into your agent folder and fill in their placeholders.

→ **Full per-component guide** (what to copy, exact placeholders, examples):
[`components/README.md`](../components/README.md#component-quick-reference)

Quick reference — what each component folder provides:

| Folder | What you get |
|--------|-------------|
| `topics/action-invoke/` | Call a connector from a topic — question + action + CSAT |
| `topics/escalation/` | Hand off to a live agent queue |
| `topics/feedback/` | CSAT thumbs/rating/category at end of conversation |
| `topics/out-of-scope/` | Redirect questions outside agent scope |
| `topics/conversation-init/` | Load M365 user profile + glossary on first turn |
| `topics/question-branch/` | Ask a question, branch on the answer |
| `actions/connector/` | Power Platform connector action template |
| `actions/mcp/` | MCP tool action template |
| `knowledge/sharepoint/` | SharePoint knowledge source |
| `knowledge/public-website/` | Bing-backed public website knowledge |
| `knowledge/glossary/` | Acronym expansion via Dataverse |
| `adaptive-cards/` | Confirmation, form, status, feedback cards |
| `agents/child-agent/` | Child agent for orchestrator pattern |
| `variables/` | UserDisplayName, UserCountry, Glossary, custom |

---

## Step 6 — Before you go live

| Check | How |
|-------|-----|
| Routing accuracy ≥ 85% | `/copilot-studio:run-eval` or `project-delivery/05-eval-scenarios.md` |
| No YAML errors | `/copilot-studio:validate` — zero red errors in VS Code Problems panel |
| Responsible AI review | `governance/ai-ethics-checklist.md` — tick every box |

---

## What's in each base file

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` | Agent name, system prompt, conversation starters, AI model |
| `settings.mcs.yml` | Auth mode, language, recognizer, who can access the agent |
| `topics/Greeting.topic.mcs.yml` | First message users see |
| `topics/Fallback.topic.mcs.yml` | When agent doesn't understand — retries, then escalates |
| `topics/OnError.topic.mcs.yml` | When agent crashes — shows a safe message |
| `topics/OutOfScope.topic.mcs.yml` | Redirects questions outside agent scope |

---

## Common issues

| Problem | Fix |
|---------|-----|
| Apply Changes fails | Confirm the agent exists in the cloud — Apply Changes cannot create a new agent |
| Push not working via CLI | `pac copilot push` does not exist — use VS Code → "Copilot Studio: Apply Changes" to push multi-file YAML |
| Agent doesn't answer from SharePoint | Confirm the SharePoint URL is accessible and the service principal has Read access |
| `_REPLACE` still in YAML | Windows: `Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\<name>" \| Select-String "_REPLACE"` / Mac: `grep -rn "_REPLACE" agents/<name> --include="*.mcs.yml"` |
| Agent in Copilot Studio shows error | Check `topics/Fallback.topic.mcs.yml` line 53 — `<AGENT_SCHEMA>` must match your `schemaName` |
| Teams channel not showing agent | Agent must be **published** (not just pushed) via Copilot Studio → Publish |
