# Quick Reference Cards — One-Page Cheat Sheets

**Print these cards or keep them open in a browser tab for quick reference during development.**

---

## CARD 1: SETUP QUICK REFERENCE

**Use this card during Phase 1 (Setup)**

### Install & Verify

```bash
# Install pac CLI (Windows)
winget install Microsoft.PowerAppsCLI

# Install pac CLI (macOS/Linux)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version
# Expected: pac (Power Apps CLI) version 2.7.4 or higher
```

### Authenticate

```bash
# First-time login
pac auth create
# Browser opens → Sign in → Return to terminal

# Check authentication
pac env who
# Expected: Connected to: [Your Environment] | you@email.com

# List environments
pac env list

# Switch environments
pac env select --environment "Environment Name"
```

### Repository Setup

```bash
# Clone repo
git clone https://github.com/microsoft/copilot-studio-templates.git

# Enter directory
cd copilot-studio-templates

# Create feature branch
git checkout -b feature/my-first-agent

# Check branch
git branch
# Expected: * feature/my-first-agent
```

### VS Code Extensions

```bash
# Install Copilot Studio extension (primary)
code --install-extension ms-powerplatform.powerplatform-vscode-extension

# Install recommended extensions
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
code --install-extension oderwat.indent-rainbow
```

### Setup Checklist

- [ ] pac --version works
- [ ] pac env who shows environment
- [ ] VS Code Copilot Studio extension active
- [ ] Repository cloned
- [ ] Feature branch created
- [ ] Ready to copy template

---

## CARD 2: TEMPLATE COPY QUICK REFERENCE

**Use this card during Phase 3 (Create Agent)**

### Copy Template

```bash
# Copy base template
cp -r base/ agents/my_agent/

# Verify copy
ls agents/my_agent/
# Expected: 6 files including agent.mcs.yml
```

### Placeholders to Replace

| File | Find | Replace with |
|------|------|-------------|
| agent.mcs.yml | `<AgentName>` | my_agent (lowercase, no spaces) |
| agent.mcs.yml | `<Agent Display Name>` | My Agent (can have spaces) |
| agent.mcs.yml | `<SYSTEM_PROMPT>` | What your agent does (2-3 sentences) |
| settings.mcs.yml | `<agent_schema_name>` | my_agent (same as AgentName) |
| Fallback.topic.mcs.yml | `<AGENT_SCHEMA>` | my_agent (same as AgentName) |

### Replace in VS Code

```
1. Open agents/my_agent/agent.mcs.yml
2. Ctrl+H (Find & Replace)
3. Find: <AgentName>
4. Replace: my_agent
5. Click "Replace All"
6. Repeat for other 4 replaceholders
```

### Verify Replacements

```bash
# Search for remaining placeholders
grep -r "<.*>" agents/my_agent/
# Expected: No matches (empty result)

# Or in VS Code:
# Ctrl+Shift+F → Search for "<"
# Expected: 0 matches
```

### Auto-Replace Node IDs

```
1. Open any .mcs.yml file in VS Code
2. Save: Ctrl+S
3. VS Code extension auto-replaces _REPLACE IDs
4. Verify no _REPLACE remaining: Search returns 0 matches
```

### Verify Configuration

```bash
# Check files exist
ls agents/my_agent/
# Expected: agent.mcs.yml, settings.mcs.yml, Greeting.topic.mcs.yml, etc.

# Check for errors in VS Code
# View → Problems
# Expected: No red errors
```

---

## CARD 3: SKILLS QUICK REFERENCE

**Use this card during development**

### WorkIQ Skills (Load Context)

```
/workiq "What were discussed in the requirements meeting?"
→ Pulls emails, Teams messages, documents, meetings

/workiq:action-item-extractor "Extract action items from meeting"
→ Turns meeting chat into tracked tasks

/workiq:site-explorer "Find HR SharePoint sites"
→ Discover knowledge sources
```

### Copilot Studio Skills (Build Agent)

```
/copilot-studio:new-topic "Create leave request topic"
→ Generates topic with triggers and nodes

/copilot-studio:add-knowledge "Add HR policies from SharePoint"
→ Connects SharePoint site as knowledge source

/copilot-studio:add-action "Add submit ticket action"
→ Adds connector or API action

/copilot-studio:validate
→ Checks YAML for errors before deploying

/copilot-studio:manage-agent "Deploy and publish"
→ Handles cloud deployment and publishing
```

### Skill Workflow

```
1. /workiq "Load context"
   ↓
2. Choose: Copy template OR Use skills
   ↓
3. Edit locally in VS Code
   ↓
4. /copilot-studio:validate
   ↓
5. Deploy: Ctrl+Shift+P → Apply Changes
   ↓
6. Test: Open https://make.microsoft.com
   ↓
7. Publish: Click "Publish"
   ↓
8. ✓ LIVE
```

---

## CARD 4: DEPLOYMENT QUICK REFERENCE

**Use this card during Phase 4 (Deploy to Cloud)**

### Deploy to Cloud

```
1. In VS Code, press: Ctrl+Shift+P
2. Type: Copilot Studio: Apply Changes
3. Press Enter
4. Wait 10-30 seconds
5. See success message: "Complete"

Expected Output:
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...
✓ Complete
```

### Verify Deployment

```bash
# List agents in environment
pac copilot list
# Expected: Your agent appears with Copilot ID (GUID)

# Open in browser
start https://make.microsoft.com
# Select environment → Find your agent → Status: Draft
```

### Troubleshooting Deployment

| Problem | Solution |
|---------|----------|
| "Apply Changes" not found | Reload VS Code (Ctrl+Shift+P → Developer: Reload Window) |
| YAML validation error | View → Problems panel → Fix red squiggles |
| Agent not in cloud | Check environment (top right) → Refresh browser → Try redeploy |
| Wrong environment | pac env select --environment "Name" |

---

## CARD 5: PUBLISHING QUICK REFERENCE

**Use this card during Phase 5 (Test & Publish)**

### Test Agent

```bash
# Open Copilot Studio
start https://make.microsoft.com

# Find your agent
Select environment → Find agent in list

# Test
Click agent → Click "Test" pane → Type "Hello"
Expected: Agent responds with greeting
```

### Publish Agent (Option A — Web UI)

```
1. In Copilot Studio, find your agent
2. Click "..." menu (top right)
3. Click "Publish"
4. Confirm
5. Status changes from "Draft" to "Published"
```

### Publish Agent (Option B — CLI)

```bash
pac copilot publish --bot "My Agent"
# Expected: Agent published successfully
```

### Verify Agent is Live

```bash
# In Copilot Studio
Check status badge → Should show "Published"

# Users can now:
→ Find in Copilot Studio
→ Access via Teams (if enabled)
→ Use the agent
```

### Common Test Issues

| Problem | Fix |
|---------|-----|
| Agent doesn't respond | Check OnError.topic — verify schema name match |
| Agent says "I don't understand" | Normal — fallback is working |
| Test pane is empty | Refresh browser (Ctrl+R) or redeploy |
| Can't find agent after publish | Check environment dropdown (top right) |

---

## CARD 6: TROUBLESHOOTING QUICK REFERENCE

**Use this card when something breaks**

### Verify Environment

```bash
# Check which environment you're in
pac env who
# Expected: Connected to: [Your Environment] | you@email.com

# If wrong, switch
pac env select --environment "Correct Environment"
pac env who
# Verify connection
```

### Check for YAML Errors

```bash
# In VS Code
View → Problems panel
# Red = errors to fix
# Green/Yellow = warnings (can ignore usually)

# Fix indentation with indent-rainbow extension
View → Extensions → search "indent-rainbow"
```

### Verify Placeholders Replaced

```bash
# In VS Code
Ctrl+Shift+F → Search for "<"
# Expected: 0 matches

# If found:
# Find each <PLACEHOLDER> and replace manually
```

### Re-authenticate if Token Expired

```bash
# If you get "not authenticated" error
pac auth create
# Complete browser sign-in again

# Verify
pac env who
# Should work now
```

### Reset Authentication (Start Fresh)

```bash
pac auth clear
pac auth create
# Complete browser sign-in
pac env who
# Verify
```

### Common Commands

```bash
# List all agents
pac copilot list

# Get agent details
pac env who

# Switch environment
pac env select --environment "Name"

# Open Copilot Studio
start https://make.microsoft.com

# Check repo status
git status

# Create new branch
git checkout -b feature/new-agent
```

### Getting Help

| Need | Resource |
|------|----------|
| Detailed walkthrough | [AGENT-DEVELOPER-JOURNEY.md](docs/AGENT-DEVELOPER-JOURNEY.md) |
| Common Q&A | [FAQ.md](docs/FAQ.md) |
| Troubleshooting guide | [troubleshooting/README.md](troubleshooting/README.md) |
| Command reference | [VERIFIED-COMMANDS.md](docs/VERIFIED-COMMANDS.md) |
| Flowcharts & diagrams | [VISUAL-FLOWCHARTS.md](docs/VISUAL-FLOWCHARTS.md) |

---

## BONUS: SETUP SCRIPT QUICK REFERENCE

**Use this to automate Phases 1-3**

### Windows (PowerShell)

```powershell
# Navigate to repo
cd copilot-studio-templates

# Run setup script
.\scripts\setup-agent-dev.ps1 -AgentName "my_agent" -DisplayName "My Agent"

# Script does:
✓ Installs pac CLI
✓ Installs VS Code extensions
✓ Tests authentication
✓ Creates agent folder
✓ Copies base template
✓ Replaces all placeholders
✓ Generates node IDs
```

### macOS / Linux (Bash)

```bash
# Navigate to repo
cd copilot-studio-templates

# Make script executable
chmod +x scripts/setup-agent-dev.sh

# Run setup script
./scripts/setup-agent-dev.sh -a my_agent -d "My Agent"

# Script does: (same as Windows)
```

### After Script Completes

```bash
1. Open in VS Code: code agents/my_agent/
2. Deploy: Ctrl+Shift+P → Apply Changes
3. Test: https://make.microsoft.com
4. Publish: Click "Publish"
5. ✓ Agent is LIVE!
```

---

## PRINT THESE CARDS

```
┌────────────────────────────────────────┐
│  Print all 6 cards (double-sided)      │
│  Keep at your desk during development  │
│  Reference as needed                   │
└────────────────────────────────────────┘
```

**Total print time: 5-10 minutes**

---

**Keep these cards handy. They cover 95% of what you'll need day-to-day!**
