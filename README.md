# Copilot Studio Templates

Reusable YAML templates for building Copilot Studio agents — with error handling, telemetry, and CSAT built in. Copy, configure, push.

---

## How to build an agent in 4 steps

### Step 1 — Set up tools (once per machine, ~20 min)

```powershell
# Install pac CLI
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Authenticate to your Dev environment
pac auth create
pac env select --environment "Dev - My Project"
```

Install VS Code extensions:
```bash
code --install-extension ms-CopilotStudio.vscode-copilotstudio   # Copilot Studio YAML validation
code --install-extension redhat.vscode-yaml                                  # YAML support
code --install-extension oderwat.indent-rainbow                              # indentation highlight
```

Full tool setup guide: [`docs/TOOLS-AND-PLUGINS.md`](docs/TOOLS-AND-PLUGINS.md)

---

### Step 2 — Pick your agent type

| I want to build… | Recipe | Time |
|---|---|---|
| FAQ / knowledge bot from SharePoint | [`recipes/01-basic-faq.md`](recipes/01-basic-faq.md) | 30 min |
| Same + users sign in and are greeted by name | [`recipes/02-authenticated-agent.md`](recipes/02-authenticated-agent.md) | 45 min |
| Agent that submits data (tickets, requests) | [`recipes/03-connector-action-agent.md`](recipes/03-connector-action-agent.md) | 60 min |
| Agent that calls an MCP tool | [`recipes/04-mcp-action-agent.md`](recipes/04-mcp-action-agent.md) | 60 min |
| Orchestrator with specialist sub-agents | [`recipes/05-orchestrator-agent.md`](recipes/05-orchestrator-agent.md) | 2+ hrs |
| Everything combined (full-featured) | [`recipes/06-full-featured-agent.md`](recipes/06-full-featured-agent.md) | 2+ hrs |

---

### Step 3 — Create and configure your agent

> **Two paths — choose before you start.**

**Path A — Cloud-First** (recommended, no extra tools):
```
1. Browser: make.preview.microsoft.com → Create → New blank agent → name it → Create
2. VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent" → sign in → pick agent → pick folder
   ⚠ The extension creates a subfolder named after the agent display name inside your chosen folder.
   Select agents\ as output → extension creates agents\HR Assistant\ (your working folder).
   Never manually copy files in — conn.json (needed for Apply Changes) is only created by Clone Agent.
   Result: agents\<display name>\ with Greeting, Fallback, OnError (minimal). OutOfScope NOT included — comes from base/topics.
3. Update the cloned files — use base/ as reference for what to put in each file:
   - agent.mcs.yml         → replace system prompt with your domain (copy structure from base/agent.mcs.yml)
   - settings.mcs.yml      → set auth mode if needed
   - topics/Greeting       → update welcome message text
   - topics/Fallback       → usually fine as cloned
   Then add capabilities from components/ (knowledge, actions, additional topics)
4. VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
5. Test in the Copilot Studio test pane → Publish
```

**What base/ is for** (Path A): `base/` is a reference showing best-practice versions of each system file.
You update your cloned files using it as a guide — you do NOT copy base/ files wholesale into the cloned folder.

**What to update in the cloned files** (Path A only):

| Placeholder | File | Example value |
|-------------|------|--------------|
| `<AgentName>` | `agent.mcs.yml` line 2 | `hr_assistant` |
| `<Agent Display Name>` | `agent.mcs.yml` line 4 | `HR Assistant` |
| `<agent_schema_name>` | `settings.mcs.yml` line 2 | `hr_assistant` |
| `<AGENT_SCHEMA>` | `topics/Fallback.topic.mcs.yml` line 53 | `hr_assistant` |
| System prompt | `agent.mcs.yml` `instructions:` block | Your domain and scope |

> `<AgentName>`, `<agent_schema_name>`, and `<AGENT_SCHEMA>` are always the same value — your schema name (lowercase, underscores, ≤ 30 chars).

**Writing the system prompt — two options:**

| Option | When to use | How |
|--------|------------|-----|
| **Use a ready-made persona** | Agent fits a known type (HR, IT, customer support, knowledge base) | Open `prompts/system-prompts/<type>.md` → copy the block inside the triple backticks → paste into `agent.mcs.yml` `instructions:` → replace `[BRACKET]` values |
| **Generate with Claude** | Custom agent or real project brief | Open `prompts/ai-prompts/generate-agent-instructions.md` → copy the prompt template → paste into Claude with your project brief → copy Claude's output into `agent.mcs.yml` `instructions:` |

→ Full how-to: [`prompts/README.md`](prompts/README.md)

---

**Path B — CLI-only** (automation and CI/CD only — not simpler than Path A for individual developers):

> **Prerequisite: at least one agent must already exist in your environment.**
> `pac copilot create` requires a template extracted from an existing agent.
> Use Path A for your first agent. Use Path B for every agent after that.

```
1. Extract a template from an existing agent:
   pac copilot list
   pac copilot extract-template --bot "<schema-name-or-copilot-id>" --templateFileName agents/<schema>/template.yaml

2. Create the new agent from that template:
   pac copilot create --displayName "HR Assistant" --schemaName "hr_assistant" --solution "Default" --templateFileName agents/hr_assistant/template.yaml

3. Clone locally — the cloned files already have real values (copied from the source agent, not placeholders):
   VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent" → select hr_assistant
   Then update the system prompt and replace topics with ones from base/ or components/

4. Push and publish:
   VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
   pac copilot publish --bot "HR Assistant"   # use display name or Copilot ID, NOT schema name
```

> **No placeholder replacement needed for Path B.** The cloned files already have the correct
> schema name and display name set by `pac copilot create`. Focus on updating the system prompt
> and swapping in topics/knowledge from `base/` and `components/`.

**Replace node IDs and all placeholders** (run once after filling in values):
```powershell
# Windows PowerShell
$schema      = "hr_assistant"        # ← your schemaName (used in YAML values)
$displayName = "HR Assistant"        # ← your display name
$folder      = "agents\$displayName" # ← folder on disk — Clone Agent names it after the display name

# Step 1 — replace _REPLACE node IDs
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path $folder | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    while ($content -match '_REPLACE\d*') {
        $id = -join ((97..122)+(48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
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

```bash
# Mac / Linux
SCHEMA="hr_assistant"        # ← your schemaName (used in YAML values)
DISPLAY_NAME="HR Assistant"  # ← your display name
find "agents/$DISPLAY_NAME" -name "*.mcs.yml" | while read f; do
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

**Verify before pushing** — must return zero results:
```powershell
# Windows PowerShell
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\HR Assistant" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\HR Assistant" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```
```bash
# Mac / Linux
grep -rn "<[A-Za-z]" "agents/HR Assistant" --include="*.mcs.yml"
grep -rn "_REPLACE" agents/hr_assistant --include="*.mcs.yml"
```

Full step-by-step: [`docs/QUICKSTART.md`](docs/QUICKSTART.md)

---

### Step 4 — Add capabilities from components/

Copy a component into your agent folder, replace its placeholders, and apply changes.

| What I need | Component to copy |
|-------------|-----------------|
| Answer questions from SharePoint | `components/knowledge/sharepoint/` |
| Answer questions from a public website | `components/knowledge/public-website/` |
| Call a Power Platform connector | `components/actions/connector/` |
| Call an MCP tool | `components/actions/mcp/` |
| Hand off to a live agent | `components/topics/escalation/` |
| Collect CSAT feedback | `components/topics/feedback/` + 3 adaptive cards |
| Load user's name and country from M365 | `components/topics/conversation-init/` + 2 variables |
| Redirect out-of-scope questions | `components/topics/out-of-scope/` |
| Show confirmation before an action | `components/adaptive-cards/confirmation-card.json` |
| Delegate a domain to a child agent | `components/agents/child-agent/` |

Full per-component placeholder guide and examples: [`components/README.md`](components/README.md)

---

## Folder structure

| Folder | What's inside |
|--------|--------------|
| [`base/`](base/) | 6 files every agent starts with (agent, settings, Greeting, Fallback, OnError, OutOfScope) |
| [`components/`](components/) | Drop-in topics, actions, knowledge, cards, variables, child agents |
| [`recipes/`](recipes/) | Complete build guides for 8 agent patterns |
| [`prompts/`](prompts/) | System prompt templates and AI generation prompts |
| [`examples/`](examples/) | Full worked examples — [`team-demo/`](examples/team-demo/) and [`it-helpdesk/`](examples/it-helpdesk/) |
| [`docs/`](docs/) | Reference guides (quickstart, component registry, best practices) |
| [`commands/`](commands/) | pac, git, and VS Code command reference sheets |
| [`ci-cd/`](ci-cd/) | GitHub Actions pipelines for Dev → UAT → Prod |
| [`project-delivery/`](project-delivery/) | Discovery → Design → Build → UAT documents |
| [`governance/`](governance/) | Responsible AI and security review checklists |
| [`launch/`](launch/) | Go-live checklist, user communications, hypercare guide |
| [`operations/`](operations/) | KQL monitoring queries, alerts, runbook |
| [`troubleshooting/`](troubleshooting/) | Common errors and fixes |

---

## Reference docs

| Doc | What it covers |
|-----|---------------|
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Creation paths, placeholder guide, node ID scripts |
| [`docs/TEMPLATES.md`](docs/TEMPLATES.md) | Full inventory of all 56 templates |
| [`docs/COMPONENT-REGISTRY.md`](docs/COMPONENT-REGISTRY.md) | Call signatures and I/O for every component |
| [`docs/BEST-PRACTICES.md`](docs/BEST-PRACTICES.md) | Design rules, error handling, naming, telemetry |
| [`docs/TOOLS-AND-PLUGINS.md`](docs/TOOLS-AND-PLUGINS.md) | pac CLI, VS Code extensions, Copilot Studio Kit |
| [`docs/ACTION-SAFETY-PATTERNS.md`](docs/ACTION-SAFETY-PATTERNS.md) | Safety tiers for write and destructive actions |
| [`docs/ENV-VARIABLES.md`](docs/ENV-VARIABLES.md) | Env variables in CPS (low-code) and Azure (pro-code) |
| [`docs/PII-SCRUBBING.md`](docs/PII-SCRUBBING.md) | PII prevention in telemetry and DLP policies |
| [`docs/SKILLS-REFERENCE.md`](docs/SKILLS-REFERENCE.md) | Claude skills for generating topics and running evals |
| [`ENGINEERING-PLAYBOOK.md`](ENGINEERING-PLAYBOOK.md) | Full delivery reference — platform decision to production |

---

## Conventions

| Convention | Rule |
|------------|------|
| `<AngleBrackets>` | Replace before pushing — these are required values |
| `_REPLACE` suffixes | Node IDs — auto-replaced by VS Code extension on save |
| Schema name | Lowercase, underscores, ≤ 30 chars — used as prefix for all IDs |
| One file per component | Never combine actions, knowledge, or agents into one file |
| Feature branch | Never work on `main` — use `git checkout -b feature/<agent-name>` |
