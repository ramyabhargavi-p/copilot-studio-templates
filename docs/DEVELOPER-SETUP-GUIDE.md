# Developer Setup Guide — From Zero to Agent in Cloud

Complete, step-by-step guide to set up your development environment and deploy your first Copilot Studio agent using VS Code directly to Azure cloud.

**Time required:** 45–90 minutes  
**What you'll have after:** A working agent published to your Power Platform environment

---

## Phase 1: Prerequisites (15–20 minutes)

Complete these setup steps **once** at the beginning. You won't need to repeat them for subsequent agents.

### Step 1.1 — Install Power Platform CLI (`pac`)

The `pac` CLI is the command-line tool that pushes your YAML code to Copilot Studio in the cloud.

**Windows (Recommended):**
```powershell
# Install via winget (easiest on Windows)
winget install Microsoft.PowerAppsCLI

# Verify installation
pac --version
# Expected output: pac (Power Apps CLI) version 2.7.4 or higher
```

**macOS / Linux:**
```bash
# Install via dotnet
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version
```

**Troubleshooting:**
- If `pac --version` fails after install, close and reopen your terminal
- If you're on Windows and winget fails, use the dotnet option instead
- See [pac-commands.md](pac-commands.md) if you still have issues

---

### Step 1.2 — Install VS Code Copilot Studio Extension

The VS Code extension provides:
- Real-time YAML validation as you type
- Auto-generated node IDs (replaces `_REPLACE` placeholders)
- IntelliSense for Copilot Studio YAML syntax

**Install:**
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for **"Copilot Studio"** (by Microsoft)
4. Click Install

**Verify:** Open any `.mcs.yml` file and confirm you see the Copilot Studio icon in the status bar.

---

### Step 1.3 — Install Recommended VS Code Extensions

These make development significantly smoother:

```powershell
# Paste this into PowerShell to install all at once
code --install-extension ms-powerplatform.powerplatform-vscode-extension
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
code --install-extension yzhang.markdown-all-in-one
code --install-extension aaron-bond.better-comments
code --install-extension oderwat.indent-rainbow
```

**What each does:**
| Extension | Why | 
|-----------|-----|
| **Copilot Studio** | YAML validation and IntelliSense — **essential** |
| **YAML** | Shows indentation errors and whitespace issues |
| **GitLens** | Track changes to your YAML over time |
| **Markdown All in One** | Preview and edit `.md` files in this repo |
| **Better Comments** | Color-codes `# TODO` and `# !` comments in YAML |
| **indent-rainbow** | Visually highlights indentation levels (critical for YAML) |

---

### Step 1.4 — Authenticate to Your Power Platform Environment

The `pac` CLI needs permission to access your Power Platform environment.

**Step A — Get your environment details:**

1. Open Power Platform Admin Center: https://admin.powerplatform.microsoft.com
2. Go to **Environments**
3. Find your **Development** environment
4. Copy the **Environment URL** (looks like: `https://yourorg-dev.crm.dynamics.com`)
5. Note your **Environment ID** (you'll need this later)

**Step B — Authenticate via pac CLI:**

```bash
# Interactive login (recommended for developers)
pac auth create

# You'll be prompted:
# 1. Enter environment name (e.g., "Dev")
# 2. Paste the environment URL from Step A
# 3. A browser will open to sign in — authenticate and return to terminal
```

**Verify authentication:**
```bash
pac auth list
# Should show your environment as "Active"

pac env who
# Should display: Connected to: [Your Environment] | you@organization.com
```

**If you get an error:**
- Make sure the URL is correct (check Power Platform Admin Center)
- Make sure you have access to the environment (ask your Power Platform admin)
- Try again: `pac auth clear` then `pac auth create`

---

### Step 1.5 — Clone This Repository

```bash
# Clone to your local machine
git clone https://github.com/microsoft/copilot-studio-templates.git

# Navigate to the folder
cd copilot-studio-templates

# Create your feature branch (required — never work on main)
git checkout -b feature/my-first-agent
```

**Verify:** You should see folders like `base/`, `components/`, `recipes/`, etc.

---

### Step 1.6 — Setup Checklist

Before moving to Phase 2, confirm all of these work:

```
[ ] pac --version shows a version number ≥ 2.7.0
[ ] VS Code has Copilot Studio extension active (check status bar)
[ ] pac env who connects successfully and shows your environment
[ ] git clone completed and feature branch created
[ ] You can open a .mcs.yml file in VS Code without errors
```

If any of these fail, go back to the corresponding step above.

---

## Phase 2: Copy Template Files (10 minutes)

Now you're ready to create your first agent. We'll copy the base template files and fill in the required configuration.

### Step 2.1 — Choose Your Agent Type

| I want to build… | Template | Time | Start at step |
|---|---|---|---|
| FAQ / knowledge bot | `recipes/01-basic-faq.md` | 30 min | 2.2 |
| Authentication + personalization | `recipes/02-authenticated-agent.md` | 45 min | 2.2 |
| Submit data to a system (tickets, requests) | `recipes/03-connector-action-agent.md` | 60 min | 2.2 |
| Call an external tool (MCP) | `recipes/04-mcp-action-agent.md` | 60 min | 2.2 |

**For this guide, we'll build a simple FAQ agent. If you want something else, follow the recipe and adapt Step 2.2 accordingly.**

---

### Step 2.2 — Copy the Base Files

The `base/` folder contains the 6 files every agent needs.

```bash
# From the copilot-studio-templates root directory
# Choose a schema name (lowercase, no spaces, e.g. "hr_assistant")

cp -r base/ agents/hr_assistant/
```

**What you just copied:**
- `agent.mcs.yml` — Agent name, system prompt, knowledge sources
- `settings.mcs.yml` — Auth mode, language, access control
- `Greeting.topic.mcs.yml` — First message users see
- `Fallback.topic.mcs.yml` — What happens when the agent doesn't understand
- `OnError.topic.mcs.yml` — What happens if the agent crashes
- `.gitignore` — Tells git which files to ignore

---

### Step 2.3 — Update the 5 Required Placeholders

Open each file in VS Code and replace the placeholders. This takes 5 minutes.

| File | Find | Replace with | Example |
|------|------|-------------|---------|
| `agents/hr_assistant/agent.mcs.yml` | `<AgentName>` | Your schema name (no spaces) | `hr_assistant` |
| `agents/hr_assistant/agent.mcs.yml` | `<Agent Display Name>` | Display name (can have spaces) | `HR Assistant` |
| `agents/hr_assistant/agent.mcs.yml` | `<SYSTEM_PROMPT>` | Your agent's purpose (2–3 sentences) | `You are an HR assistant that answers questions about company policies and leave requests.` |
| `agents/hr_assistant/settings.mcs.yml` | `<agent_schema_name>` | Same schema name as above | `hr_assistant` |
| `agents/hr_assistant/Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | Same schema name as above | `hr_assistant` |

**How to replace:**
1. Open the file in VS Code
2. Press Ctrl+H to open Find and Replace
3. Type the placeholder in "Find"
4. Type the replacement in "Replace"
5. Click "Replace All"

---

### Step 2.4 — Replace _REPLACE Node IDs

The template uses `_REPLACE` placeholders for internal node IDs. VS Code's Copilot Studio extension auto-replaces these when you save.

**Auto-replace (easiest):**
1. Open `agents/hr_assistant/agent.mcs.yml` in VS Code
2. Press Ctrl+S to save
3. The extension automatically replaces all `_REPLACE` IDs with unique IDs

**Verify:** Open the file and search for `_REPLACE` — there should be none left.

---

### Step 2.5 — Open Your Agent in VS Code

```bash
# Open the agents/hr_assistant folder in VS Code
code agents/hr_assistant/
```

You should see:
- The 6 files listed in Explorer
- IntelliSense hints when editing YAML
- Copilot Studio icon in the status bar (extension is active)

---

## Phase 3: Deploy to Cloud via VS Code (10–15 minutes)

This is the key part: **using VS Code to push directly to your Power Platform environment without the web UI.**

### Step 3.1 — Deploy via VS Code Extension

The Copilot Studio VS Code extension has a command to apply your changes directly to the cloud.

**Deploy your agent:**
1. In VS Code, press **Ctrl+Shift+P** (or Cmd+Shift+P on macOS)
2. Type: `Copilot Studio: Apply Changes`
3. Select the command from the dropdown
4. VS Code will show a progress bar

**Expected output:**
```
Copilot Studio: Apply Changes

✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...
✓ Complete

Your agent has been created as a draft. It's not yet live to users.
```

**What "Apply Changes" does:**
- Validates your YAML syntax
- Connects to your authenticated Power Platform environment
- Creates or updates your agent in the cloud
- Deploys as a **draft** (not published yet)

---

### Step 3.2 — Verify Deployment in Copilot Studio UI

After "Apply Changes" completes:

1. Open Copilot Studio: https://make.microsoft.com/consent?redirectURL=%2Fextensions/2e8a4b8d-6a47-4a6e-8c51-c0e8ae5e5c5e
2. Go to your environment (top right dropdown)
3. Look for your agent in the list (e.g., "HR Assistant")
4. You should see it with a **Draft** label

**If you don't see it:**
- Check that you're in the correct environment (top right dropdown)
- Refresh the page (Ctrl+R)
- Check the Output panel in VS Code (View → Output) for error messages

---

### Step 3.3 — Test Your Agent

1. In Copilot Studio, click your agent (e.g., "HR Assistant")
2. Click the **Test** pane on the right
3. Type a message: "Hello"
4. Your agent should respond with the greeting from `Greeting.topic.mcs.yml`

**If the agent doesn't respond:**
- Check the error message in the test pane
- Open `OnError.topic.mcs.yml` and verify `<AGENT_SCHEMA>` matches your schema name
- Try "Apply Changes" again from VS Code

---

## Phase 4: Publish to Live (2 minutes)

Your agent is now in the cloud but as a **draft**. Users can't see it yet. Publish it to make it live.

### Step 4.1 — Publish via Copilot Studio UI

1. In Copilot Studio, find your agent
2. Click **Publish** (top right)
3. Confirm the publication

Your agent is now live! Users can find it in Copilot Studio.

---

### Step 4.2 — Publish via pac CLI (Alternative)

If you prefer the command line:

```bash
# Get your agent's display name from Copilot Studio
pac copilot publish --bot "HR Assistant"
```

---

## Phase 5: Add Knowledge (Optional — 15 minutes)

Now your agent is working! To make it useful, add knowledge (FAQ content, documents, etc.).

### Step 5.1 — Copy the Knowledge Search Component

Knowledge Search lets your agent answer questions from SharePoint sites, documents, or web pages.

```bash
# Copy the knowledge search topic
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/hr_assistant/topics/

# Copy the SharePoint knowledge source
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/hr_assistant/knowledge/
```

---

### Step 5.2 — Update Knowledge Source Configuration

Open `agents/hr_assistant/knowledge/sharepoint.knowledge.mcs.yml` and update:

| Field | What to do |
|-------|-----------|
| `<SharePoint_Site_URL>` | Replace with your SharePoint site URL (e.g., `https://yourorg.sharepoint.com/sites/HR`) |
| `<SharePointList_Name>` | Replace with the list or library name (e.g., `HR Policies`) |

---

### Step 5.3 — Re-deploy

```bash
# In VS Code
Ctrl+Shift+P → Copilot Studio: Apply Changes
```

Your agent now has access to SharePoint knowledge. Ask it a question about HR policies!

---

## Phase 6: Troubleshooting Common Issues

### Issue: "Copilot Studio: Apply Changes" command not found

**Cause:** Copilot Studio extension not installed or not active  
**Fix:**
1. Open Extensions (Ctrl+Shift+X)
2. Search "Copilot Studio"
3. Click Install (if not already installed)
4. Reload VS Code (Ctrl+Shift+P → "Developer: Reload Window")

---

### Issue: "Environment not found" when applying changes

**Cause:** Not authenticated to the correct environment  
**Fix:**
```bash
# Check which environment is active
pac env who

# If wrong, switch to the correct one
pac env list  # See all environments
pac env select --environment "Dev - My Project"
pac env who   # Confirm
```

Then try "Apply Changes" again in VS Code.

---

### Issue: Agent created but doesn't respond in test

**Cause:** Schema name mismatch or greeting topic error  
**Fix:**
1. Open `agents/hr_assistant/Fallback.topic.mcs.yml`
2. Find `<AGENT_SCHEMA>` and verify it matches your schema name (e.g., `hr_assistant`)
3. In VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
4. Test again

---

### Issue: YAML validation error when applying changes

**Cause:** Indentation error or invalid YAML syntax  
**Fix:**
1. In VS Code, check the Problems panel (View → Problems)
2. Red squiggles show syntax errors
3. Use indent-rainbow extension to verify indentation is correct
4. Fix the error and save (Ctrl+S)
5. Try "Apply Changes" again

---

### Issue: "Command 'Apply Changes' timed out"

**Cause:** Network issue or environment unreachable  
**Fix:**
```bash
# Verify environment is accessible
pac env who

# Re-authenticate if needed
pac auth create

# Try Apply Changes again
```

---

## Quick Reference: Common Commands

| Task | How | Time |
|------|-----|------|
| Create a new agent | Phase 2, Step 2.2 | 5 min |
| Deploy to cloud | Phase 3, Step 3.1 | 2 min |
| Test in Copilot Studio | Phase 3, Step 3.3 | 2 min |
| Publish to users | Phase 4, Step 4.1 | 1 min |
| Add knowledge source | Phase 5, Step 5.1 | 5 min |
| Check what environment you're in | `pac env who` | 30 sec |
| Switch environments | `pac env list` then `pac env select --environment "Name"` | 1 min |

---

## Next Steps After Your First Agent

| What to do | Where | Time |
|---|---|---|
| Add user sign-in + personalization | `recipes/02-authenticated-agent.md` | 30 min |
| Add action to submit data | `recipes/03-connector-action-agent.md` | 45 min |
| Add feedback collection | `components/topics/feedback/` | 10 min |
| Full enterprise delivery guide | `docs/START-HERE.md` | Varies |
| Troubleshoot errors | `troubleshooting/README.md` | As needed |

---

## Getting Help

| Problem | Where to look |
|---------|---------------|
| pac CLI commands | `commands/pac-commands.md` |
| VS Code setup | `docs/TOOLS-AND-PLUGINS.md` |
| Agent design patterns | `recipes/` folder |
| Reusable components | `docs/COMPONENT-REGISTRY.md` |
| Errors and fixes | `troubleshooting/README.md` |
| Full governance guide | `ENGINEERING-PLAYBOOK.md` |

---

**You've completed setup! Your agent is now live in the cloud. 🎉**
