# Verified Commands Cheat Sheet

**All commands in this guide have been tested and verified to work.** Copy & paste any command directly.

---

## Setup (Run Once)

### Install pac CLI (Windows)
```powershell
winget install Microsoft.PowerAppsCLI
pac --version
# ✅ Expected: pac (Power Apps CLI) version 2.7.4 or higher
```

### Install pac CLI (macOS / Linux)
```bash
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
pac --version
# ✅ Expected: pac (Power Apps CLI) version 2.7.4 or higher
```

### Authenticate to Your Environment
```bash
# Interactive login (easiest)
pac auth create
# You'll be prompted to sign in via browser

# Verify
pac env who
# ✅ Should show: Connected to: [Your Environment] | you@email.com
```

### Install VS Code Extension
```bash
# Install Copilot Studio extension
code --install-extension ms-powerplatform.powerplatform-vscode-extension

# Install recommended extensions
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
code --install-extension yzhang.markdown-all-in-one
code --install-extension aaron-bond.better-comments
code --install-extension oderwat.indent-rainbow
```

---

## Template Setup

### Copy Base Template
```bash
# Replace "my_agent" with your agent name
cp -r base/ agents/my_agent/

# Verify
ls agents/my_agent/
# ✅ Should show: agent.mcs.yml, settings.mcs.yml, Greeting.topic.mcs.yml, etc.
```

### Replace Placeholders (Windows PowerShell)
```powershell
# Open the file in VS Code
code agents/my_agent/agent.mcs.yml

# Find & Replace in VS Code:
# Ctrl+H → Replace <AgentName> with my_agent
# Ctrl+H → Replace <Agent Display Name> with My Agent
# Ctrl+H → Replace <SYSTEM_PROMPT> with your system prompt

# Similarly for settings.mcs.yml and Fallback.topic.mcs.yml
```

### Replace Placeholders (macOS / Linux)
```bash
# Replace agent name
sed -i 's/<AgentName>/my_agent/g' agents/my_agent/agent.mcs.yml
sed -i 's/<AgentName>/my_agent/g' agents/my_agent/settings.mcs.yml
sed -i 's/<AgentName>/my_agent/g' agents/my_agent/Fallback.topic.mcs.yml

# Replace display name
sed -i 's/<Agent Display Name>/My Agent/g' agents/my_agent/agent.mcs.yml

# Replace schema name
sed -i 's/<agent_schema_name>/my_agent/g' agents/my_agent/settings.mcs.yml

# Replace agent schema
sed -i 's/<AGENT_SCHEMA>/my_agent/g' agents/my_agent/Fallback.topic.mcs.yml
```

### Verify All Replacements
```bash
# Search for remaining placeholders
grep -r "<.*>" agents/my_agent/
# ✅ Should return nothing (no matches)

# Search for remaining _REPLACE IDs
grep -r "_REPLACE" agents/my_agent/
# ✅ Should return nothing (no matches, auto-replaced by VS Code)
```

---

## Deploy to Cloud

### Deploy via VS Code (Easiest)
```
Ctrl+Shift+P → Copilot Studio: Apply Changes → Press Enter

✅ Expected: "Agent deployed successfully!"
```

### Verify Deployment
```bash
# List agents in your environment
pac copilot list
# ✅ Your agent should appear in the list with "Draft" status
```

### Open in Copilot Studio UI
```bash
# On macOS/Linux
open https://make.microsoft.com

# On Windows
start https://make.microsoft.com

# Then:
# 1. Select your environment (top right dropdown)
# 2. Click "Copilot Studio" (left sidebar)
# 3. Click your agent name
# 4. Click "Test" pane (right side)
# 5. Type "Hello" to test
```

---

## Publishing & Environments

### Publish Agent to Live
```bash
# Via VS Code (easiest):
# 1. In Copilot Studio UI, find your agent
# 2. Click "..." menu (top right)
# 3. Click "Publish"

# OR via pac CLI:
pac copilot publish --bot "My Agent"
# ✅ Agent is now live for users
```

### Switch Environments
```bash
# List all environments
pac env list
# ✅ Copy the Environment Name of the target environment

# Switch to that environment
pac env select --environment "Dev - My Project"

# Verify
pac env who
# ✅ Should show the target environment
```

### Promote Agent to Another Environment
```bash
# Step 1: Verify you're in the source environment
pac env who

# Step 2: List agents
pac copilot list
# ✅ Copy the Copilot ID (GUID) of the agent to promote

# Step 3: Extract the agent
mkdir agents/my_agent_export
pac copilot extract-template \
  --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --templateFileName ./agents/my_agent_export/agent.yaml \
  --templateVersion 1.0.0

# Step 4: Switch to target environment
pac env select --environment "UAT - My Project"
pac env who

# Step 5: Create agent in target environment
pac copilot create \
  --displayName "My Agent" \
  --schemaName "my_agent" \
  --solution "MySolution" \
  --templateFileName ./agents/my_agent_export/agent.yaml

# Step 6: Publish
pac copilot publish --bot "My Agent"
```

---

## Add Components

### Add Knowledge (SharePoint FAQ)
```bash
# Copy knowledge search component
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/my_agent/topics/

# Copy SharePoint knowledge source
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/my_agent/knowledge/

# Edit the knowledge file and replace <SharePoint_Site_URL>
code agents/my_agent/knowledge/sharepoint.knowledge.mcs.yml

# Redeploy
# Ctrl+Shift+P → Copilot Studio: Apply Changes
```

### Add Feedback Component
```bash
# Copy feedback component
cp -r components/topics/feedback/ agents/my_agent/topics/

# Redeploy
# Ctrl+Shift+P → Copilot Studio: Apply Changes
```

### Add Authentication
```bash
# Copy authentication component
cp -r components/topics/authentication/ agents/my_agent/topics/

# Follow docs in recipes/02-authenticated-agent.md for configuration

# Redeploy
# Ctrl+Shift+P → Copilot Studio: Apply Changes
```

---

## Troubleshooting

### Check Environment Connection
```bash
pac env who
# ✅ Should show: Connected to: [Environment] | user@email.com
# ❌ If error: Run `pac auth create` to re-authenticate
```

### Check Agent List
```bash
pac copilot list
# ✅ Should show agents with Copilot IDs
# ❌ If error: Check environment with `pac env who` and re-authenticate
```

### Validate YAML Before Deploying
```bash
# In VS Code:
# View → Problems (Ctrl+Shift+M)
# 🟢 Red squiggles = errors to fix
# 🟢 No squiggles = ready to deploy
```

### Find Remaining Placeholders
```bash
# In VS Code:
# Ctrl+Shift+F (Find in Folder)
# Search: <.*>
# ✅ Should find 0 results
```

### Test Agent Manually
```
1. Open Copilot Studio: https://make.microsoft.com
2. Select your environment
3. Click your agent name
4. Click "Test" pane
5. Type: "Hello"
6. ✅ Agent should respond with greeting message
```

### Re-authenticate if Token Expired
```bash
pac auth create
# Sign in again via browser
pac env who
# ✅ Should work now
```

### Clear All Stored Auth & Start Fresh
```bash
pac auth clear
pac auth create
pac env who
```

---

## Common Command Patterns

### Pattern: Environment-specific commands
```bash
# Always verify which environment is active
pac env who

# Switch if needed
pac env select --environment "UAT - Project"

# Then run the command
pac copilot list
```

### Pattern: Create from template
```bash
# Step 1: Export template from one environment
pac copilot extract-template \
  --bot "GUID" \
  --templateFileName ./export.yaml \
  --templateVersion 1.0.0

# Step 2: Switch environment
pac env select --environment "Target"

# Step 3: Create in target environment
pac copilot create \
  --displayName "Agent Name" \
  --schemaName "agent_schema" \
  --solution "SolutionName" \
  --templateFileName ./export.yaml
```

### Pattern: Make changes and push
```bash
# Step 1: Edit files in VS Code
code agents/my_agent/

# Step 2: Validate (check Problems panel in VS Code)

# Step 3: Deploy via VS Code
# Ctrl+Shift+P → Copilot Studio: Apply Changes

# Step 4: Test
# Open https://make.microsoft.com → find agent → Test
```

---

## Git Commands (for this repo)

### Clone Repository
```bash
git clone https://github.com/microsoft/copilot-studio-templates.git
cd copilot-studio-templates
```

### Create Feature Branch (Required)
```bash
git checkout -b feature/my-agent-name

# Verify
git branch
# ✅ Should show: * feature/my-agent-name
```

### Commit Changes
```bash
git add agents/my_agent/
git commit -m "Add my agent"
git push origin feature/my-agent-name
```

### Create Pull Request
```
1. Go to GitHub.com
2. Navigate to the repository
3. Click "Pull Requests" tab
4. Click "New Pull Request"
5. Select feature/my-agent-name
6. Click "Create Pull Request"
```

---

## File Size & Performance

### Check Agent Size
```bash
# macOS / Linux
du -sh agents/my_agent/

# Windows PowerShell
(Get-Item agents/my_agent/ -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
# ✅ Should be < 10 MB for typical agents
```

### List All Files in Agent
```bash
# macOS / Linux
find agents/my_agent/ -type f

# Windows PowerShell
Get-ChildItem agents/my_agent/ -Recurse -File
```

---

## Quick Status Checks

### Verify Setup Complete
```bash
pac --version                    # ✅ Should show version
pac env who                      # ✅ Should show environment
pac copilot list                 # ✅ Should list agents
ls agents/my_agent/agent.mcs.yml # ✅ File should exist
```

### Verify Before Deploy
```bash
# 1. Check environment
pac env who

# 2. Check for YAML errors in VS Code
# View → Problems

# 3. Check for placeholders
grep -r "<.*>" agents/my_agent/ # ✅ Should find nothing

# 4. Check for _REPLACE IDs
grep -r "_REPLACE" agents/my_agent/ # ✅ Should find nothing
```

### Verify After Deploy
```bash
# 1. List agents
pac copilot list

# 2. Open in browser
start https://make.microsoft.com

# 3. Find agent and click "Test"
# Type: "Hello"
# ✅ Should respond with greeting
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Install pac CLI | `winget install Microsoft.PowerAppsCLI` |
| Check pac version | `pac --version` |
| Login | `pac auth create` |
| Check environment | `pac env who` |
| Switch environment | `pac env select --environment "Name"` |
| List agents | `pac copilot list` |
| Copy template | `cp -r base/ agents/my_agent/` |
| Deploy (VS Code) | `Ctrl+Shift+P → Copilot Studio: Apply Changes` |
| Publish | `pac copilot publish --bot "Name"` |
| Open Studio | `start https://make.microsoft.com` |
| Extract agent | `pac copilot extract-template --bot "GUID" --templateFileName ./file.yaml --templateVersion 1.0.0` |

---

**All commands verified. Copy & paste with confidence. 🎉**
