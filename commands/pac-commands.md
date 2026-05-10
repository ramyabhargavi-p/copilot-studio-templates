# pac CLI Commands — Full Reference

**Quick Note:** This guide assumes you're using VS Code with the Copilot Studio extension for daily development. The VS Code command **"Copilot Studio: Apply Changes"** (Ctrl+Shift+P) is easier than `pac` CLI for pushing agents. However, the `pac` commands below are still useful for environment management, listing agents, and CI/CD automation.

---

## Common pac copilot Commands (v2.7.x and higher)

```bash
pac copilot list                # List agents in your environment
pac copilot publish --bot "<display name or Copilot ID>"   # Publish a draft agent to live — NOT schema name
pac copilot status --bot ""     # Check deployment status
pac copilot extract-template    # Download an existing agent as YAML
pac copilot create              # Create a new agent from a template file
```

**`pac copilot push` does not exist** in the standard pac CLI. To push YAML changes to an existing agent, **use VS Code's "Copilot Studio: Apply Changes"** command (Ctrl+Shift+P).

---

## 1. Install

```powershell
# Recommended on Windows
winget install Microsoft.PowerAppsCLI

# Alternative
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

After install, close and reopen terminal:

```bash
pac --version
# Expected: pac (Power Apps CLI) version 2.X.X
```

---

## 2. Authentication

```bash
# Login via browser (recommended for dev machines — no secrets needed)
pac auth create

# Login with service principal (CI/CD, automated pipelines)
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID>

# See all saved auth profiles
pac auth list
# Index | Active | Kind          | Name   | User         | Environment
#   1   |        | Interactive   | Dev    | you@org.com  | Dev - Project
#   2   |   *    | Interactive   | UAT    | you@org.com  | UAT - Project

# Switch between saved profiles
pac auth select --index 1

# Delete a saved profile
pac auth delete --index 2

# Remove all saved profiles
pac auth clear
```

---

## 3. Environments

```bash
# List all environments you have access to
pac env list
# Environment Name      | Type        | URL                              | Environment ID
# Dev - My Project      | Developer   | https://yourorg-dev.crm.dyn...   | xxxxxxxx-xxxx-...
# UAT - My Project      | Sandbox     | https://yourorg-uat.crm.dyn...   | xxxxxxxx-xxxx-...
# Prod - My Project     | Production  | https://yourorg.crm.dyn...       | xxxxxxxx-xxxx-...

# Connect to a specific environment by name
pac env select --environment "Dev - My Project"

# Connect by URL
pac env select --environment https://yourorg-dev.crm.dynamics.com

# Connect by Environment ID
pac env select --environment xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Confirm which environment is currently active
pac env who
# Connected to: Dev - My Project | https://yourorg-dev.crm.dynamics.com | you@org.com
```

---

## 4. See agents in the active environment

```bash
pac copilot list
```

Actual output format (pac 2.7.4):

```
Name     Copilot ID                           Component State  Is Managed  Solution ID                          Status Code  State Code
TestGIA  f1714949-c144-f111-88b5-00224809a00b Published        False       fd140aae-4df4-11dd-bd17-0019b9312238 Active       Provisioned
```

> **Important:** The `Name` column is the display name — it is NOT what `--bot` accepts.
> Always copy the **Copilot ID** (GUID) from this output and use that with `--bot`.

---

## 5. Download an existing agent to edit locally

`pac copilot pull` does not exist. Use one of these two methods:

### Method A — pac copilot extract-template (CLI)

Downloads the agent as a single YAML template file.

**Required steps — do these in order:**

```bash
# Step 1 — get the Copilot ID (GUID) from this output, NOT the display name
pac copilot list

# Step 2 — create the output directory first (command fails with DirectoryNotFoundException if missing)
mkdir agents\TestGIA

# Step 3 — extract using the GUID and explicit --templateVersion
pac copilot extract-template \
  --bot "f1714949-c144-f111-88b5-00224809a00b" \
  --templateFileName ./agents/TestGIA/TestGIA.yaml \
  --templateVersion 1.0.0
```

**Why GUID, not display name?**
`--bot` accepts a Copilot ID (GUID) or schema name — not the display name shown in the UI.
Using the display name causes: `No bots were found using search pattern 'TestGIA'`

**Why `--templateVersion 1.0.0`?**
In pac 2.7.4, omitting `--templateVersion` causes `Argument --templateVersion is invalid` even
though the help says it defaults to `1.0.0`. Pass it explicitly to avoid the error.

**With an explicit environment:**

```bash
pac copilot extract-template \
  --bot "f1714949-c144-f111-88b5-00224809a00b" \
  --templateFileName ./agents/TestGIA/TestGIA.yaml \
  --templateVersion 1.0.0 \
  --environment "Dev - My Project"
```

**Overwrite an existing file:**

```bash
pac copilot extract-template \
  --bot "f1714949-c144-f111-88b5-00224809a00b" \
  --templateFileName ./agents/TestGIA/TestGIA.yaml \
  --templateVersion 1.0.0 \
  --overwrite
```

Output: a single `.yaml` file you can edit and re-create from.

### Method B — VS Code Copilot Studio Extension (recommended for full editing)

The extension clones the full agent folder structure (all topics, knowledge, actions as separate files):

```
Ctrl+Shift+P → "Copilot Studio: Clone Agent"
→ Sign in → select environment → select agent → choose output folder
→ Full agent folder created locally with all YAML files
```

---

## 6. Edit locally and apply changes back

`pac copilot push` does not exist in the standard pac CLI. Use one of these methods:

### Method A — VS Code extension (recommended)

```
Edit YAML files in VS Code
Ctrl+Shift+P → "Copilot Studio: Apply Changes"
→ Changes uploaded to Copilot Studio as draft
```

To pull remote changes made in the UI back to local files:

```
Ctrl+Shift+P → "Copilot Studio: Get Changes"
```

### Method B — Create new agent from template (pac CLI)

For a new agent only (not for updating an existing one):

```bash
pac copilot create \
  --displayName "HR Assistant" \
  --schemaName "hr_assistant" \
  --solution "HRAgentSolution" \
  --templateFileName ./agents/hr-assistant/hr-assistant.yaml
```

### Method C — Solution import (ALM / team environments)

```bash
# Export the solution containing your agent
pac solution export --name HRAgentSolution --path ./solutions/HRAgent.zip

# Unpack to edit YAML files
pac solution unpack --zipfile ./solutions/HRAgent.zip --folder ./solutions/unpacked/

# Edit files in ./solutions/unpacked/
# Then pack and import back

pac solution pack --zipfile ./solutions/HRAgent_updated.zip --folder ./solutions/unpacked/
pac solution import --path ./solutions/HRAgent_updated.zip --publish-changes
```

---

## 7. Publish

```bash
# Publish a draft agent → makes it live for users
pac copilot publish --bot "HR Assistant"

# Check publish status
pac copilot status --bot "HR Assistant"
```

---

## 8. Everyday Dev Loop (corrected)

```bash
# Step 1 — confirm active environment
pac env who

# Step 2 — list agents (copy the Copilot ID GUID you need)
pac copilot list

# Step 3 — download agent to edit (first time only)
# Create output directory first
mkdir agents\my-agent
# Then extract using the GUID from Step 2
pac copilot extract-template \
  --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --templateFileName ./agents/my-agent/agent.yaml \
  --templateVersion 1.0.0
# OR use VS Code: Ctrl+Shift+P → "Copilot Studio: Clone Agent"

# Step 4 — edit YAML files
code ./agents/my-agent/

# Step 5 — apply changes back
# VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"

# Step 6 — test in browser
start https://make.preview.microsoft.com
# Navigate to your environment → Copilot Studio → your agent → Test pane

# Step 7 — repeat steps 4–6 until done

# Step 8 — publish to users
pac copilot publish --bot "HR Assistant"
```

---

## 9. Promote Dev → UAT → Prod

```bash
# Switch to UAT
pac env select --environment "UAT - My Project"
pac env who                                       # confirm

# Apply changes (VS Code extension)
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"

pac copilot publish --bot "HR Assistant"          # publish to UAT

# Switch to Prod
pac env select --environment "Prod - My Project"
pac env who                                       # confirm

# Apply changes (VS Code extension)
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"

pac copilot publish --bot "HR Assistant"          # go live
```

---

## 10. Solution Commands (ALM / managed environments)

```bash
# Export agent as a solution zip
pac solution export --name MySolution --path ./solutions/MySolution.zip

# Import a solution into an environment
pac solution import --path ./solutions/MySolution.zip --publish-changes

# Unpack solution zip into editable files
pac solution unpack --zipfile ./solutions/MySolution.zip --folder ./solutions/unpacked/

# Pack edited files back into a solution zip
pac solution pack --zipfile ./solutions/MySolution_updated.zip --folder ./solutions/unpacked/
```

---

## 11. Troubleshooting

### "No bots were found using search pattern 'AgentName'"

You passed the display name to `--bot`. It requires the GUID or schema name.

```bash
pac copilot list   # copy the Copilot ID (GUID) from the output
pac copilot extract-template --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" ...
```

### "Argument --templateVersion is invalid. Expected type 1.0.0 and got:"

pac 2.7.4 bug — the argument is required even though the help says it's optional.

```bash
pac copilot extract-template --bot "..." --templateFileName ./path/agent.yaml --templateVersion 1.0.0
```

### "System.IO.DirectoryNotFoundException"

The output directory does not exist. Create it before running extract-template.

```bash
mkdir agents\my-agent
pac copilot extract-template --bot "..." --templateFileName ./agents/my-agent/agent.yaml --templateVersion 1.0.0
```

### Auth token expired

```bash
pac auth create     # login again
```

### Check or upgrade pac CLI

```bash
pac --version
winget upgrade Microsoft.PowerAppsCLI
```

### See all available pac copilot subcommands

```bash
pac copilot --help
```

---

## Quick Reference Card

| Task | Correct command |
|------|----------------|
| Login | `pac auth create` |
| See environments | `pac env list` |
| Connect to env | `pac env select --environment "Name"` |
| Confirm active env | `pac env who` |
| List agents + get GUIDs | `pac copilot list` |
| Download agent (CLI) | `pac copilot extract-template --bot "<GUID>" --templateFileName ./path/agent.yaml --templateVersion 1.0.0` |
| Download agent (VS Code) | `Ctrl+Shift+P` → `Copilot Studio: Clone Agent` |
| Apply changes (VS Code) | `Ctrl+Shift+P` → `Copilot Studio: Apply Changes` |
| Pull remote changes (VS Code) | `Ctrl+Shift+P` → `Copilot Studio: Get Changes` |
| Publish live | `pac copilot publish --bot "Name"` |
| Open in browser | `start https://make.preview.microsoft.com` |
| Switch to UAT | `pac env select --environment "UAT - Project"` |

---

## Commands that do NOT exist (common mistakes)

| Wrong command | Correct alternative |
|---------------|-------------------|
| `pac copilot push` | VS Code → `Copilot Studio: Apply Changes` |
| `pac copilot pull` | `pac copilot extract-template --bot "<GUID>" --templateFileName ./path/agent.yaml --templateVersion 1.0.0` |
| `pac copilot open` | Open browser manually: `start https://make.preview.microsoft.com` |
| `pac copilot push --publish` | Apply changes via VS Code, then `pac copilot publish --bot "Name"` |
| `pac copilot delete` | Delete via Copilot Studio web UI |

---

## Known pac 2.7.4 Bugs

| Bug | Symptom | Workaround |
|-----|---------|------------|
| `--templateVersion` required | `Argument --templateVersion is invalid` even when not passed | Always pass `--templateVersion 1.0.0` |
| `--bot` rejects display names | `No bots were found using search pattern 'AgentName'` | Use the GUID from `pac copilot list` |
| `DirectoryNotFoundException` | Command exits with non-recoverable error | Create output directory before running extract-template |
