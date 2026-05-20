# Commands — Copilot Studio Dev Reference

One file. All commands. Find what you need by section or use the quick-start table below.

---

## Quick start — the commands you use every day

| Task | Command |
|------|---------|
| Confirm active environment | `pac env who` |
| List agents + get GUIDs | `pac copilot list` |
| Apply YAML edits to agent | VS Code → `Ctrl+Shift+P` → `Copilot Studio: Apply Changes` |
| Publish draft live | `pac copilot publish --bot "<display name>"` |
| See changes | `git status` / `git diff` |
| Stage and commit | `git add agents/my-agent/` → `git commit -m "message"` |
| Push branch | `git push origin feature/my-branch` |
| Find unreplaced placeholders | VS Code `Ctrl+Shift+F` → search `_REPLACE` or `<` |

> **`pac copilot push` does not exist.** Use VS Code → `Copilot Studio: Apply Changes` to push YAML edits.

---

## pac CLI

### Install

> Full install guide: [`../docs/TOOLS-AND-PLUGINS.md`](../docs/TOOLS-AND-PLUGINS.md)

```powershell
# Windows via winget (recommended)
winget install Microsoft.PowerAppsCLI

# Verify
pac --version
```

### Authentication

```bash
# Login via browser (dev machines)
pac auth create

# Login with service principal (CI/CD)
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID>

# List saved profiles
pac auth list

# Switch profile
pac auth select --index 1

# Remove all
pac auth clear
```

### Environments

```bash
pac env list                                           # list all environments
pac env select --environment "Dev - My Project"        # connect by name
pac env select --environment https://yourorg.crm...    # connect by URL
pac env who                                            # confirm active environment
```

### Agents

```bash
pac copilot list                                       # list agents — copy the Copilot ID (GUID)
pac copilot publish --bot "<display name or GUID>"     # publish draft → live
```

> **Important:** `--bot` accepts a GUID or schema name — not the display name shown in the UI.
> Copy the Copilot ID from `pac copilot list` if the display name fails.

### Download an agent to edit locally

**Method A — pac CLI (single YAML file)**

```bash
# Step 1 — get the Copilot ID
pac copilot list

# Step 2 — create output directory first
mkdir agents\hr_assistant

# Step 3 — extract (use GUID, not display name)
pac copilot extract-template \
  --bot "f1714949-c144-f111-88b5-00224809a00b" \
  --templateFileName ./agents/hr_assistant/agent.yaml \
  --templateVersion 1.0.0
```

> pac 2.7.4 bug: `--templateVersion` is required even though help says it's optional. Pass `1.0.0` explicitly.

**Method B — VS Code extension (full folder structure, recommended)**

```
Ctrl+Shift+P → "Copilot Studio: Clone Agent"
→ Sign in → select environment → select agent → choose output folder
```

### Promote Dev → UAT → Prod

```bash
pac env select --environment "UAT - My Project"
# VS Code → Ctrl+Shift+P → "Copilot Studio: Apply Changes"
pac copilot publish --bot "HR Assistant"

pac env select --environment "Prod - My Project"
# VS Code → Ctrl+Shift+P → "Copilot Studio: Apply Changes"
pac copilot publish --bot "HR Assistant"
```

### Solution commands (ALM / managed environments)

```bash
pac solution export --name MySolution --path ./solutions/MySolution.zip
pac solution import --path ./solutions/MySolution.zip --publish-changes
pac solution unpack --zipfile ./solutions/MySolution.zip --folder ./solutions/unpacked/
pac solution pack --zipfile ./solutions/updated.zip --folder ./solutions/unpacked/
```

### pac commands that do NOT exist

| Wrong | Correct |
|-------|---------|
| `pac copilot push` | VS Code → `Copilot Studio: Apply Changes` |
| `pac copilot pull` | `pac copilot extract-template --bot "<GUID>" ...` |
| `pac copilot delete` | Delete via Copilot Studio web UI |

### pac troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `No bots were found using search pattern 'AgentName'` | Display name passed to `--bot` | Use GUID from `pac copilot list` |
| `Argument --templateVersion is invalid` | pac 2.7.4 bug | Pass `--templateVersion 1.0.0` explicitly |
| `System.IO.DirectoryNotFoundException` | Output directory missing | `mkdir agents\my-agent` before running |
| Auth token expired | Session expired | `pac auth create` |

---

## VS Code

### Copilot Studio extension commands

Open Command Palette: `Ctrl+Shift+P`

| Command | What it does |
|---------|-------------|
| `Copilot Studio: Apply Changes` | Push YAML edits to connected environment (replaces `pac copilot push`) |
| `Copilot Studio: Clone Agent` | Pull agent from environment into local folder |
| `Copilot Studio: Get Changes` | Pull remote changes made in the UI back to local files |
| `Copilot Studio: Publish Agent` | Publish current draft live |
| `Copilot Studio: Validate Agent` | Validate YAML schema without pushing |
| `Copilot Studio: Select Environment` | Switch active environment |

### Essential keyboard shortcuts

| Shortcut | What it does |
|----------|-------------|
| `Ctrl+P` | Quick open — jump to any file by name |
| `Ctrl+Shift+F` | Search across all files |
| `Ctrl+H` | Find and replace |
| `Ctrl+Shift+L` | Select all occurrences of highlighted text |
| `Ctrl+Space` | Trigger IntelliSense / autocomplete |
| `Alt+Shift+F` | Format document (YAML) |
| `` Ctrl+` `` | Open integrated terminal |
| `Ctrl+G` | Go to line number |

### Replace `_REPLACE` node IDs

After copying any template, replace all `_REPLACE` suffixes:

1. `Ctrl+H` → open Find and Replace
2. Find: `_REPLACE\d*` — enable **Use Regular Expression** (`Alt+R`)
3. Click **Replace** one at a time — each ID must be unique

**Or use the PowerShell script:**

```powershell
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = [regex]::Replace($content, '_REPLACE\d*', $id, 1)
  }
  Set-Content $_.FullName $content
}
```

### Recommended VS Code settings for YAML

Add to `.vscode/settings.json`:

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "files.associations": { "*.mcs.yml": "yaml" },
  "editor.formatOnSave": false
}
```

> `formatOnSave: false` — YAML auto-formatters can break indentation in `.mcs.yml` files.

---

## Git

### First-time setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@org.com"
git config --global init.defaultBranch main
```

### Daily development

```bash
git status                              # see what changed
git diff                                # see line-by-line changes
git add agents/hr-assistant/            # stage your agent folder
git commit -m "add HR policy topic"
git push origin feature/hr-assistant
```

### Branch strategy

```
main          ← production, protected
  └── feature/hr-assistant  ← your work
```

```bash
git checkout -b feature/hr-assistant    # create branch
git checkout main                       # switch to main
git merge feature/hr-assistant          # merge when done
git tag v1.0.0                          # tag production release
git push origin v1.0.0
```

### Useful commands

```bash
git log --oneline -10                   # recent commits
git diff --staged                       # what's staged
git restore --staged <file>             # unstage a file
git reset --soft HEAD~1                 # undo last commit, keep changes
git show HEAD~1:<file>                  # see file at previous commit
```

### .gitignore — always exclude

```
.env
*.secret
*credentials*
.pac/
.DS_Store
```

---

## Node.js / npm

Only needed if you run the Copilot Studio Kit batch evaluations or install pac CLI via npm.

### Install

```powershell
winget install OpenJS.NodeJS.LTS

node --version    # v20.X.X
npm --version     # 10.X.X
```

### Copilot Studio Kit — batch evaluation

```bash
npm install
npm run build
npm run eval -- --agent-name "HR Assistant" --environment <ENV_URL>
npm run eval -- --scenarios ./project-delivery/12-eval-scenarios.yml
```

### pac CLI via npm (if winget unavailable)

```bash
# Run PowerShell as Administrator first
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
npm install -g @microsoft/powerplatform-cli
pac --version
```

### npm troubleshooting

```bash
npm cache clean --force         # fixes most install errors
npm install --verbose           # see full error detail
npm list -g --depth=0           # list global packages
winget upgrade OpenJS.NodeJS.LTS  # update Node.js
```
