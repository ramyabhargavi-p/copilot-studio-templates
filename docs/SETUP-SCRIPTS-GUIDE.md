# 🚀 Setup Scripts Complete Guide

**Comprehensive documentation for `setup-agent-dev.ps1` and `setup-agent-dev.sh`**

---

## Overview

Two automation scripts eliminate repetitive setup steps:

- **`setup-agent-dev.ps1`** — Windows PowerShell version
- **`setup-agent-dev.sh`** — macOS/Linux Bash version

Both scripts automate the same 9 phases, adapting to their OS.

---

## When to Use Scripts

✅ **Use scripts if:**
- You're setting up your first agent
- You want to automate placeholder replacement
- You prefer automation over manual steps
- You're setting up multiple agents

❌ **Don't use if:**
- You want manual control over each step
- You already have the environment set up
- You prefer understanding each step before running
  → Read [AGENT-DEVELOPER-JOURNEY.md](./AGENT-DEVELOPER-JOURNEY.md) instead

---

## Quick Start

### Windows (PowerShell)

```powershell
# 1. Open PowerShell as Administrator
# 2. Navigate to repository
cd C:\projects\copilot-studio-templates

# 3. Allow script execution (one-time)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 4. Run the script
.\scripts\setup-agent-dev.ps1 -AgentName "my_agent" -DisplayName "My Agent" -Template "base"
```

### macOS/Linux (Bash)

```bash
# 1. Navigate to repository
cd ~/projects/copilot-studio-templates

# 2. Make script executable (one-time)
chmod +x scripts/setup-agent-dev.sh

# 3. Run the script
./scripts/setup-agent-dev.sh --agent-name my_agent --display-name "My Agent" --template base
```

---

## Script Parameters

### Windows Parameters (PowerShell)

```powershell
.\setup-agent-dev.ps1 `
  -AgentName "my_agent" `           # [Required] YAML-safe name (lowercase, underscores)
  -DisplayName "My Agent" `         # [Required] User-friendly display name
  -Template "base" `               # [Optional] Template folder: base/recipes/examples
  -SkipInstall                     # [Optional] Skip tool installation
  -SkipAuth                        # [Optional] Skip authentication
  -Verbose                         # [Optional] Show detailed output
```

### macOS/Linux Parameters (Bash)

```bash
./scripts/setup-agent-dev.sh \
  --agent-name my_agent \          # [Required] Lowercase, underscores
  --display-name "My Agent" \      # [Required] User-friendly name
  --template base \               # [Optional] Template: base/recipes/examples
  --skip-install \                # [Optional] Skip tool installation
  --skip-auth \                   # [Optional] Skip authentication
  --verbose                       # [Optional] Show detailed output
```

---

## 9 Phases Explained

Both scripts run through identical phases:

### Phase 1: Check Prerequisites

**What it does:**
- Verify PowerShell version (Windows) or Bash (macOS/Linux)
- Check if Git is installed
- Check if Node.js is available (for schema generation)

**Expected Output:**
```
✓ PowerShell 5.0 or later detected
✓ Git found at: C:\Program Files\Git\bin\git.exe
✓ Node.js found at: C:\Program Files\nodejs\node.exe
```

**If fails:**
- Windows: Download Git from https://git-scm.com/
- macOS: `brew install git`
- Linux: `sudo apt-get install git`

---

### Phase 2: Detect/Install pac CLI

**What it does:**
- Detects if Power Apps CLI (`pac`) is already installed
- If missing, installs it via package manager
- Verifies installation

**Windows (via winget):**
```powershell
winget install Microsoft.PowerApps.CLI
```

**macOS (via Homebrew):**
```bash
brew tap microsoft/powercat
brew install powerapps-cli
```

**Linux (manual installation):**
```bash
dotnet tool install --global Microsoft.PowerApps.CLI
```

**Expected Output:**
```
✓ pac CLI version: 1.x.x.x
✓ Location: C:\Users\user\.dotnet\tools\pac.exe
```

**If fails:**
- Windows: Ensure you have admin rights; try manual install
- macOS: `brew update && brew install powerapps-cli`
- Linux: `dotnet tool install --global Microsoft.PowerApps.CLI`

---

### Phase 3: Detect/Install VS Code Extensions

**What it does:**
- Checks if VS Code is installed
- Verifies "Copilot Studio" extension is installed
- Installs missing extension

**Expected Output:**
```
✓ VS Code found at: C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe
✓ Copilot Studio extension (v1.x) installed
```

**If fails:**
- Install VS Code: https://code.visualstudio.com/
- Install extension manually: Open VS Code → Extensions → Search "Copilot Studio"

---

### Phase 4: Verify Authentication

**What it does:**
- Tests `pac auth list` to verify PowerApps connection
- If no auth exists, prompts for interactive login
- Verifies you can access your organization

**Expected Output:**
```
✓ Authenticated as: user@contoso.com
✓ Default environment: Default-12345abcde
✓ Can access Power Platform: YES
```

**If fails:**
- Manual auth: `pac auth create --url https://your-env.crm.dynamics.com`
- Interactive login: `pac auth login`

---

### Phase 5: Create Agent Folder Structure

**What it does:**
- Creates folder: `agents/<AgentName>/`
- Creates subfolders: `topics/`, `skills/`, `media/`
- Creates placeholder files

**Expected Output:**
```
✓ Created: agents\my_agent\
✓ Created: agents\my_agent\topics\
✓ Created: agents\my_agent\skills\
✓ Created: agents\my_agent\media\
```

**Folder structure created:**
```
agents/
└── my_agent/
    ├── agent.mcs.yml
    ├── settings.mcs.yml
    ├── topics/
    │   └── Greeting.topic.mcs.yml
    ├── skills/
    └── media/
```

---

### Phase 6: Copy Template Files

**What it does:**
- Copies template from `base/` (or specified template)
- Copies to `agents/<AgentName>/`
- Preserves folder structure

**Expected Output:**
```
✓ Copied template: base/* → agents\my_agent\
✓ Files copied: 8
✓ Folders copied: 3
```

**What gets copied:**
- `agent.mcs.yml` (agent metadata)
- `settings.mcs.yml` (configuration)
- Topic `.yaml` files
- README with setup instructions

---

### Phase 7: Replace Placeholders

**What it does:**
- Finds all `<PLACEHOLDER>` values in YAML files
- Prompts you for each replacement
- Updates all files with your values

**Expected Replacements:**
```
Enter replacement for <AGENT_NAME>: my_agent
Enter replacement for <AGENT_DISPLAY_NAME>: My Agent
Enter replacement for <SYSTEM_PROMPT>: [paste your prompt]
Enter replacement for <SCHEMA_NAME>: my_agent_schema
```

**What changes:**
- `agent.mcs.yml`: Updates schema name, display name, instructions
- `settings.mcs.yml`: Updates authentication, features
- Topics: Update references to schema

**Expected Output:**
```
✓ Replaced 12 occurrences of <AGENT_NAME>
✓ Replaced 4 occurrences of <DISPLAY_NAME>
✓ Replaced 1 system prompt
✓ All placeholders resolved
```

---

### Phase 8: Generate Unique Node IDs

**What it does:**
- Finds all `_REPLACE` node IDs in YAML
- Generates unique 6-character strings
- Updates all references consistently

**Example:**
```yaml
# Before:
nodes:
  - id: message_REPLACE
    activity: "Hello"
  - id: question_REPLACE
    activity: "What next?"

# After:
nodes:
  - id: message_a7k9m2
    activity: "Hello"
  - id: question_b3p5n8
    activity: "What next?"
```

**Expected Output:**
```
✓ Generated 24 unique node IDs
✓ Updated all references
✓ Verified no duplicate IDs
```

---

### Phase 9: Verify & Summary

**What it does:**
- Validates all YAML files (syntax check)
- Verifies folder structure
- Tests VS Code can open project
- Displays setup completion summary

**Expected Output:**
```
✓ Syntax validation: PASS
✓ Folder structure: VALID
✓ Schema references: CONSISTENT
✓ All node IDs: UNIQUE

Setup Complete!
├─ Agent: my_agent
├─ Display Name: My Agent
├─ Location: agents\my_agent\
├─ Ready to: Open in VS Code
└─ Next step: Apply Changes
```

---

## Using the Scripts: Step-by-Step

### Scenario 1: First Agent Setup (Windows)

```powershell
# Open PowerShell as Admin
# Navigate to repo
cd C:\path\to\copilot-studio-templates

# Allow scripts to run (one-time)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run setup
.\scripts\setup-agent-dev.ps1 -AgentName "hr_bot" -DisplayName "HR Assistant" -Template "base"

# The script prompts you:
# "Enter replacement for <SYSTEM_PROMPT>:"
# → Paste your HR system prompt (see PROMPTS-GUIDE.md)

# After completion:
# → Open agents\hr_bot\ in VS Code
# → Click "Apply Changes"
# → Agent created in Copilot Studio!
```

**Expected time:** 5 minutes  
**Success criteria:** Agent folder exists and shows "Ready to apply"

---

### Scenario 2: Multiple Agents (macOS)

```bash
# Set up first agent
./scripts/setup-agent-dev.sh --agent-name it_support --display-name "IT Support" --template base

# Set up second agent (reuses auth from first)
./scripts/setup-agent-dev.sh --agent-name customer_help --display-name "Customer Support" --template recipes

# Both agents now exist:
# agents/
# ├── it_support/
# └── customer_help/

# Deploy both:
# 1. Open agents/it_support/ in VS Code → Apply Changes
# 2. Open agents/customer_help/ in VS Code → Apply Changes
```

---

### Scenario 3: Skip Auth (Already Logged In)

```powershell
# If you already authenticated and want to skip that phase:
.\scripts\setup-agent-dev.ps1 -AgentName "quick_test" -Template "base" -SkipAuth

# Script skips Phase 4 (authentication check)
# Saves ~30 seconds
```

---

## Troubleshooting

### "pac CLI not found"

**Windows:**
```powershell
# Manual install
winget install Microsoft.PowerApps.CLI
# Then verify
pac version
```

**macOS:**
```bash
# Manual install via Homebrew
brew tap microsoft/powercat
brew install powerapps-cli
# Then verify
pac version
```

**Linux:**
```bash
# Install via dotnet
dotnet tool install --global Microsoft.PowerApps.CLI
# Then add to PATH
export PATH="$HOME/.dotnet/tools:$PATH"
pac version
```

---

### "VS Code extension not found"

```
Solution: Manually install from VS Code
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Copilot Studio"
4. Install official Microsoft extension
5. Reload VS Code
6. Re-run setup script
```

---

### "Authentication failed"

```
Solution: Manual authentication
pac auth create --url https://your-env.crm.dynamics.com

Or interactive login:
pac auth login

Then verify:
pac auth list
```

---

### "YAML Syntax Error"

```
Cause: Placeholder replacement created invalid YAML
Solution:
1. Open agents/<AgentName>/agent.mcs.yml
2. Check indentation (YAML is indent-sensitive)
3. Verify no special characters in values
4. Run script again with correct values
```

---

### "Node ID Conflicts"

```
Cause: Generated IDs weren't unique
Solution: This is rare, but if it happens:
1. Re-run Phase 8: ./scripts/setup-agent-dev.sh --phase 8
2. Or manually rename one ID in the YAML file
3. Verify consistency across all files
```

---

## Script Parameters Reference

### PowerShell (Complete Reference)

```powershell
.\setup-agent-dev.ps1 `
  -AgentName <string> `              # Required. Lowercase, underscores, numbers
  -DisplayName <string> `            # Required. User-friendly name (any characters)
  -Template <string> `               # Optional. Default: "base"
                                     # Options: base, recipes, examples
  -SkipInstall <switch> `            # Optional. Don't install/update tools
  -SkipAuth <switch> `               # Optional. Don't check authentication
  -Verbose <switch> `                # Optional. Show detailed output
  -WhatIf <switch> `                 # Optional. Dry-run (show what would happen)
```

**Common combinations:**

```powershell
# Simple: just provide required params
.\setup-agent-dev.ps1 -AgentName "my_bot" -DisplayName "My Bot"

# With recipe template
.\setup-agent-dev.ps1 -AgentName "support" -DisplayName "Support Bot" -Template "recipes"

# Dry-run (don't actually create anything)
.\setup-agent-dev.ps1 -AgentName "test" -DisplayName "Test" -WhatIf

# Already authenticated, skip auth check
.\setup-agent-dev.ps1 -AgentName "fast" -DisplayName "Fast Setup" -SkipAuth

# Verbose output for debugging
.\setup-agent-dev.ps1 -AgentName "debug" -DisplayName "Debug Mode" -Verbose
```

---

### Bash (Complete Reference)

```bash
./scripts/setup-agent-dev.sh \
  --agent-name <name> \              # Required. Lowercase, underscores, numbers
  --display-name <name> \            # Required. User-friendly name
  --template <name> \                # Optional. Default: base
                                     # Options: base, recipes, examples
  --skip-install \                   # Optional. Don't install tools
  --skip-auth \                      # Optional. Don't check authentication
  --verbose \                        # Optional. Show detailed output
  --dry-run                          # Optional. Show what would happen
```

**Common combinations:**

```bash
# Simple
./scripts/setup-agent-dev.sh --agent-name my_bot --display-name "My Bot"

# With example template
./scripts/setup-agent-dev.sh --agent-name demo --display-name "Demo" --template examples

# Dry-run
./scripts/setup-agent-dev.sh --agent-name test --display-name "Test" --dry-run

# Already authenticated
./scripts/setup-agent-dev.sh --agent-name fast --display-name "Fast" --skip-auth

# Verbose debugging
./scripts/setup-agent-dev.sh --agent-name debug --display-name "Debug" --verbose
```

---

## Advanced Usage

### Customizing Placeholders

If the script doesn't ask for a placeholder you need to replace:

```powershell
# After script completes, manually edit:
notepad agents\my_agent\agent.mcs.yml

# Find and replace:
# Search for: <YOUR_PLACEHOLDER>
# Replace with: your_value

# Save and verify syntax
```

---

### Reusing Auth Across Multiple Setups

```powershell
# First setup (full)
.\setup-agent-dev.ps1 -AgentName "agent1" -DisplayName "Agent 1"

# Subsequent setups (skip auth)
.\setup-agent-dev.ps1 -AgentName "agent2" -DisplayName "Agent 2" -SkipAuth
.\setup-agent-dev.ps1 -AgentName "agent3" -DisplayName "Agent 3" -SkipAuth
```

---

### Creating Agents Programmatically

Use script in CI/CD pipeline:

```powershell
# In your GitHub Actions or Azure DevOps pipeline:
.\scripts\setup-agent-dev.ps1 `
  -AgentName ${{ github.event.inputs.agentName }} `
  -DisplayName ${{ github.event.inputs.displayName }} `
  -Template "base" `
  -SkipAuth
```

---

## What Happens After Setup

**After script completes successfully:**

```
agents/my_agent/
├── agent.mcs.yml          ← Ready for VS Code
├── settings.mcs.yml       ← Configuration applied
├── topics/
│   ├── Greeting.topic.mcs.yml
│   └── Escalate.topic.mcs.yml
├── README.md              ← Next steps
└── [All placeholders replaced]
```

**Next steps:**

1. **Open in VS Code:**
   ```powershell
   code agents\my_agent\
   ```

2. **Click "Apply Changes"** (VS Code extension button)

3. **Verify in Copilot Studio:**
   - Navigate to https://copilotstudio.microsoft.com
   - Your agent should appear in the agents list

4. **Test the agent:** Open the test pane and chat

---

## Return Codes (Advanced)

Scripts return exit codes for automation:

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Agent created and ready |
| 1 | General error | Check output for details |
| 2 | Missing required parameter | Provide -AgentName and -DisplayName |
| 3 | Tool not installed | Install missing tool (pac, VS Code) |
| 4 | Authentication failed | Run `pac auth login` manually |
| 5 | YAML syntax error | Check placeholder values |

---

## Performance Tips

✅ **Speed up setup:**
- Use `-SkipAuth` after first setup
- Use `-SkipInstall` if all tools already installed
- Batch multiple agents together

⚠️ **Avoid delays:**
- Don't run multiple scripts in parallel (they share auth)
- Close VS Code before running script (prevents file lock)
- Disable antivirus scanning on script folders temporarily

---

## Getting Help

**If script fails:**

1. **Run with `-Verbose` flag:**
   ```powershell
   .\setup-agent-dev.ps1 -AgentName "debug" -DisplayName "Debug" -Verbose
   ```

2. **Check the output** for which phase failed

3. **Refer to "Phase X" section** above for that phase

4. **Manual workaround:**
   - Skip the failing phase with `-Skip*` flag
   - Do that phase manually
   - Continue

---

## Summary

| Task | Windows | macOS/Linux |
|------|---------|-----------|
| Run script | `.\setup-agent-dev.ps1` | `./setup-agent-dev.sh` |
| First-time auth | Prompted automatically | Prompted automatically |
| Skip auth | `-SkipAuth` flag | `--skip-auth` flag |
| Custom template | `-Template recipes` | `--template recipes` |
| Dry-run | `-WhatIf` flag | `--dry-run` flag |

**Time to complete:** 5–10 minutes (depending on tool installation)

---

**Next:** 
- See [AGENT-DEVELOPER-JOURNEY.md](./AGENT-DEVELOPER-JOURNEY.md) for complete walkthrough
- See [PROMPTS-GUIDE.md](./PROMPTS-GUIDE.md) for system prompts
