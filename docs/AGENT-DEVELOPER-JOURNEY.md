# Agent Developer Journey: Complete Guide from Zero to Live

**The complete step-by-step guide for building, deploying, and publishing your first Copilot Studio agent.**

**Time to completion:** 90–120 minutes  
**What you'll have:** A working agent live in the cloud, serving real users

---

## Table of Contents

1. [Phase 1: Setup & Prerequisites](#phase-1-setup--prerequisites)
2. [Phase 2: Understanding Templates & Skills](#phase-2-understanding-templates--skills)
3. [Phase 3: Create Your First Agent](#phase-3-create-your-first-agent)
4. [Phase 4: Deploy to Cloud](#phase-4-deploy-to-cloud)
5. [Phase 5: Test & Publish](#phase-5-test--publish)
6. [Phase 6: Add Features & Enhance](#phase-6-add-features--enhance)

---

---

# Phase 1: Setup & Prerequisites

**Time: 20–30 minutes**

Get your development environment ready. This is a one-time setup.

## 1.1 Install Power Platform CLI (pac)

The `pac` CLI is the command-line interface for deploying agents to the cloud.

### Windows (Recommended)

```powershell
winget install Microsoft.PowerAppsCLI

# Verify installation
pac --version
# ✅ Expected output: pac (Power Apps CLI) version 2.7.4 or higher
```

### macOS / Linux

```bash
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

pac --version
# ✅ Expected output: pac (Power Apps CLI) version 2.7.4 or higher
```

**Troubleshooting:**
- If `pac --version` fails after install, close and reopen your terminal
- On Windows, if winget fails, use the dotnet option instead

---

## 1.2 Install VS Code & Extensions

VS Code is where you'll edit your agent files. The Copilot Studio extension provides real-time validation and auto-generates node IDs.

### Install VS Code

- Download from: https://code.visualstudio.com
- Install and launch

### Install Copilot Studio Extension

1. Open VS Code
2. Press **Ctrl+Shift+X** (Extensions panel)
3. Search: **"Copilot Studio"** (by Microsoft)
4. Click **Install**

**Verify:** Open any `.mcs.yml` file and confirm the Copilot Studio icon appears in the status bar.

### Install Recommended Extensions (Optional but Helpful)

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
- **YAML** — Shows indentation errors (critical for YAML)
- **GitLens** — Track changes to your YAML over time
- **indent-rainbow** — Highlights indentation levels visually
- **Better Comments** — Color-codes `# TODO` comments
- **Markdown All in One** — Preview readme files

---

## 1.3 Authenticate to Your Power Platform Environment

Tell `pac` which Power Platform environment you're developing in.

### Get Your Environment Details

1. Open Power Platform Admin Center: https://admin.powerplatform.microsoft.com
2. Go to **Environments**
3. Find your **Development** environment
4. Copy the **Environment URL** (looks like: `https://yourorg-dev.crm.dynamics.com`)

### Authenticate

```bash
pac auth create

# You'll be prompted:
# 1. Press Enter to open browser
# 2. Sign in with your work account
# 3. Return to terminal when done
```

### Verify Authentication

```bash
pac env who
# ✅ Expected output: Connected to: Dev - My Project | you@organization.com

pac env list
# ✅ Should show all environments you have access to
```

**Troubleshooting:**
- If error: "No environments found," you may not have access. Contact your Power Platform admin.
- If error: "Authentication failed," run `pac auth create` again

---

## 1.4 Clone This Repository

```bash
# Clone the templates repo
git clone https://github.com/microsoft/copilot-studio-templates.git

# Navigate to the folder
cd copilot-studio-templates

# Create your feature branch (required — never work on main)
git checkout -b feature/my-first-agent
```

**Verify:** 
```bash
ls -la
# ✅ Should show: base/, components/, recipes/, docs/, ci-cd/, etc.
```

---

## 1.5 Setup Verification Checklist

Before moving to Phase 2, confirm all of these:

```
✅ pac --version shows version ≥ 2.7.0
✅ VS Code has Copilot Studio extension active
✅ pac env who shows your environment (not an error)
✅ Repository cloned and feature branch created
✅ You can open a .mcs.yml file without errors
```

**Not all checked?** Go back to the relevant step above.

---

---

# Phase 2: Understanding Templates & Skills

**Time: 15–20 minutes**

Learn what templates are, how skills work, and when to use each.

## 2.1 What Are Templates?

Templates are pre-built YAML files (configuration) for agents. They include:

- **Base template** (`base/`) — 6 files every agent needs
- **Component templates** (`components/`) — Reusable pieces (topics, knowledge, actions)
- **Recipe templates** (`recipes/`) — End-to-end examples for specific agent types

### The Base Template (6 Files)

Every agent starts with these 6 files:

| File | What it does |
|------|------------|
| `agent.mcs.yml` | Agent name, system prompt, knowledge sources |
| `settings.mcs.yml` | Auth mode, language, access control |
| `Greeting.topic.mcs.yml` | First message users see |
| `Fallback.topic.mcs.yml` | What happens when agent doesn't understand |
| `OnError.topic.mcs.yml` | What happens if agent crashes |
| `.gitignore` | Which files to ignore in git |

### Component Templates

Reusable building blocks you can add:

| Component | What it does | When to use |
|-----------|------------|------------|
| **Knowledge (SharePoint)** | Search a SharePoint site for answers | FAQ agents |
| **Action (Connector)** | Submit data to a system | Action agents (submit tickets, leave requests) |
| **Topic** | Conversation flow for a feature | When adding capabilities |
| **Adaptive Card** | Form or display UI | When collecting data or showing results |
| **Feedback** | Collect user ratings | All agents (measure quality) |

### Recipe Templates

End-to-end templates for specific agent types:

| Recipe | Use case | Time |
|--------|----------|------|
| **01-basic-faq** | Answer questions from SharePoint | 30 min |
| **02-authenticated-agent** | FAQ + user sign-in | 45 min |
| **03-connector-action-agent** | Submit data to a system | 60 min |
| **04-mcp-action-agent** | Call external APIs/tools | 60 min |
| **05-orchestrator-agent** | Multiple agents working together | 2+ hrs |

---

## 2.2 What Are Skills?

Skills are Claude AI features that help you build agents faster. They're invoked via slash commands in your Claude session.

### WorkIQ Skills (Gather Context)

Load context from your Microsoft 365 data:

```
/workiq "What were discussed in the requirements meeting?"
→ Copilot pulls from emails, Teams, meetings, documents
→ You have instant context
```

| Skill | What it does | When to use |
|-------|------------|------------|
| `/workiq` | Query M365 data in plain English | Before design starts |
| `/workiq:action-item-extractor` | Extract action items from meetings | After meetings to track tasks |
| `/workiq:site-explorer` | Find SharePoint sites | When looking for knowledge sources |
| `/workiq:org-chart` | Show org chart for a person | When finding system owners |

### Copilot Studio Skills (Build Agents)

Build and deploy agents:

```
/copilot-studio:add-knowledge "Add HR policies from SharePoint"
→ Copilot creates knowledge connection for you
```

| Skill | What it does | When to use |
|-------|------------|------------|
| `/copilot-studio:new-topic` | Create a new conversation topic | Adding features |
| `/copilot-studio:add-knowledge` | Add SharePoint/web knowledge | FAQ agents |
| `/copilot-studio:add-action` | Add connector or API action | Action agents |
| `/copilot-studio:validate` | Check YAML for errors | Before deploying |
| `/copilot-studio:manage-agent` | Deploy and publish | Going live |

---

## 2.3 Templates vs. Skills: When to Use Each

### Use Templates When

- ✅ You want to start from a working example
- ✅ You need specific agent features (FAQ, actions, etc.)
- ✅ You want to control every detail
- ✅ You're learning how agents are built

### Use Skills When

- ✅ You want Copilot to generate components for you
- ✅ You want to work faster (less manual typing)
- ✅ You need context from M365 data
- ✅ You want hands-off automation

### Best Practice: Use Both

```
Workflow:
1. /workiq "Load context from meeting"
2. Copy base template locally
3. Edit in VS Code
4. /copilot-studio:validate before deploying
5. Deploy via VS Code: Ctrl+Shift+P → Apply Changes
```

---

## 2.4 Understanding Phase 2 Summary

After this phase, you should understand:

```
✅ Base template = 6 files every agent needs
✅ Components = reusable building blocks
✅ Recipes = end-to-end examples
✅ Skills = shortcuts and automation
✅ When to use templates vs. skills
```

---

---

# Phase 3: Create Your First Agent

**Time: 30–40 minutes**

Create and configure your agent locally.

## 3.1 Choose Your Agent Type

Decide what your agent will do. For this guide, we'll build a **FAQ agent** (answers questions from SharePoint).

| Agent type | What it does | Time | Start with |
|-----------|------------|------|-----------|
| **FAQ** | Answers questions from documents | 30 min | base/ + knowledge |
| **FAQ + Sign-in** | FAQ + requires login | 45 min | recipe 02 |
| **Action** | Submits data to a system | 60 min | recipe 03 |
| **Multi-agent** | Multiple agents working together | 2+ hrs | recipe 05 |

**We'll use: FAQ agent (simplest)**

---

## 3.2 Copy the Base Template

Copy the base files to your local agents folder:

```bash
# Create agent folder and copy base template
cp -r base/ agents/my_first_agent/

# Verify
ls agents/my_first_agent/
# ✅ Should show 6 files: agent.mcs.yml, settings.mcs.yml, Greeting.topic.mcs.yml, etc.
```

---

## 3.3 Replace the 5 Required Placeholders

Open files in VS Code and replace these 5 values. Use **Find & Replace (Ctrl+H)** to do this quickly.

### File 1: agent.mcs.yml

Open `agents/my_first_agent/agent.mcs.yml` and replace:

| Find | Replace with | Example |
|------|-------------|---------|
| `<AgentName>` | Your schema name (lowercase, no spaces) | `my_first_agent` |
| `<Agent Display Name>` | Display name (can have spaces) | `My First Agent` |
| `<SYSTEM_PROMPT>` | What your agent does (2–3 sentences) | `You are a helpful HR assistant that answers questions about company policies and procedures.` |

**How to replace:**
1. Press **Ctrl+H** (Find & Replace)
2. Type the placeholder in "Find"
3. Type the replacement in "Replace"
4. Click "Replace All"

### File 2: settings.mcs.yml

Open `agents/my_first_agent/settings.mcs.yml` and replace:

| Find | Replace with | Example |
|------|-------------|---------|
| `<agent_schema_name>` | Same schema name as above | `my_first_agent` |

### File 3: Fallback.topic.mcs.yml

Open `agents/my_first_agent/Fallback.topic.mcs.yml` and replace:

| Find | Replace with | Example |
|------|-------------|---------|
| `<AGENT_SCHEMA>` | Same schema name as above | `my_first_agent` |

---

## 3.4 Verify All Replacements

Search for remaining placeholders to make sure you didn't miss any:

```bash
# Search for remaining placeholders
grep -r "<.*>" agents/my_first_agent/
# ✅ Should return nothing (no matches)
```

In VS Code:
1. Press **Ctrl+Shift+F** (Find in Folder)
2. Search: `<`
3. Should find 0 results

---

## 3.5 Auto-Replace Node IDs

The template uses `_REPLACE` placeholders for internal node IDs. VS Code's extension auto-replaces these when you save.

```
1. Open any .mcs.yml file in VS Code
2. Press Ctrl+S (Save)
3. All _REPLACE IDs are automatically replaced
```

**Verify:**
```bash
grep -r "_REPLACE" agents/my_first_agent/
# ✅ Should return nothing (no matches after save)
```

---

## 3.6 Open in VS Code

```bash
# Open your agent folder in VS Code
code agents/my_first_agent/
```

You should see:
- ✅ 6 files listed in the Explorer (left sidebar)
- ✅ Copilot Studio icon in the status bar (extension active)
- ✅ No red error squiggles in the files (check left side line numbers)

---

## 3.7 Phase 3 Summary

Your agent is now configured locally. Before deploying, verify:

```
✅ All 5 placeholders replaced
✅ No _REPLACE IDs remaining (auto-replaced on save)
✅ No red error squiggles in VS Code
✅ All 6 base files present
```

---

---

# Phase 4: Deploy to Cloud

**Time: 5–10 minutes**

Push your agent to the cloud using VS Code.

## 4.1 Deploy Via VS Code

The VS Code extension has a built-in command to deploy your agent directly to the cloud.

**Deploy:**
1. In VS Code, press **Ctrl+Shift+P** (or Cmd+Shift+P on macOS)
2. Type: `Copilot Studio: Apply Changes`
3. Press **Enter**
4. Wait 10–30 seconds

**Expected output:**
```
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...     ← Agent AUTOMATICALLY CREATED
✓ Complete

Agent deployed successfully!
```

**What happens:**
- ✅ VS Code validates your YAML for syntax errors
- ✅ VS Code connects to your Power Platform environment
- ✅ **On first deployment: Agent is automatically created** with your schema name
- ✅ On subsequent deployments: Agent is updated
- ✅ Agent is deployed as a **Draft** (not yet published)

---

## 4.2 Verify Deployment

Your agent is now in the cloud! Verify it was created:

1. Open: https://make.microsoft.com
2. Select your environment (top right dropdown)
3. Click **Copilot Studio** (left sidebar)
4. You should see your agent listed (e.g., "My First Agent") with a **Draft** label

**If you don't see it:**
- Refresh the page (Ctrl+R)
- Check you're in the correct environment (dropdown, top right)
- Check VS Code Output panel for errors:
  - View → Output
  - Select "Copilot Studio" from dropdown
  - Look for error messages

---

## 4.3 Expected Agent Structure

Your agent in the cloud now has:

```
My First Agent
├── Configuration
│   ├── Name: "My First Agent"
│   ├── Schema: "my_first_agent"
│   ├── System Prompt: "You are a helpful HR assistant..."
│   └── Settings: Auth mode, language, access
│
└── Topics (Conversations)
    ├── Greeting (says hello when chat starts)
    ├── Fallback (says "I don't understand" if confused)
    └── OnError (error handling)
```

---

## 4.4 Phase 4 Summary

Your agent is now deployed to the cloud as a **Draft**. Users can't see it yet, but it exists in your environment.

```
✅ Agent created in cloud
✅ Deployment successful
✅ Status: DRAFT (not yet published)
✅ Ready to test
```

---

---

# Phase 5: Test & Publish

**Time: 10–15 minutes**

Test your agent and publish it for users to access.

## 5.1 Test Your Agent

Test the agent in Copilot Studio:

1. In Copilot Studio (https://make.microsoft.com), click your agent
2. Click the **Test** pane (right side)
3. Type a message: "Hello"
4. Your agent should respond with the greeting

**Expected output:**
```
User: Hello
Agent: Hello! I'm here to help with any questions about company policies and procedures.
```

**If the agent doesn't respond:**

| Problem | Solution |
|---------|----------|
| Agent shows error | Check `OnError.topic.mcs.yml` — verify `<AGENT_SCHEMA>` matches your schema name exactly |
| Agent doesn't understand | Agent is working — "I don't understand" is the fallback response |
| Test pane is empty | Refresh page (Ctrl+R) or redeploy: Ctrl+Shift+P → Apply Changes |

---

## 5.2 Publish for Users

Your agent is working! Now publish it so users can access it.

### Option A: Via Copilot Studio UI (Easiest)

1. In Copilot Studio, find your agent
2. Look for the status badge (currently says "Draft")
3. Click the **"..."** menu (top right)
4. Click **Publish**
5. Confirm when prompted

**Expected output:**
```
Publish successful
Your agent is now live for users.
```

### Option B: Via Command Line (Optional)

```bash
pac copilot publish --bot "My First Agent"
# ✅ Expected output: Agent published successfully
```

---

## 5.3 Verify Agent is Live

1. In Copilot Studio, find your agent
2. Status badge should now say **"Published"** instead of "Draft"
3. Agent is now accessible to all users in your environment

---

## 5.4 Share With Users

Your agent is now live! Users can find it in:

- **Copilot Studio:** https://make.microsoft.com → find your agent → chat
- **Teams:** If enabled in your organization
- **Power Automate:** If you configured integrations

---

## 5.5 Phase 5 Summary

Your agent is now published and live!

```
✅ Agent tested successfully
✅ Agent published to production
✅ Users can access the agent
✅ Status changed from DRAFT to Published
```

---

---

# Phase 6: Add Features & Enhance

**Time: 30–60 minutes (optional)**

Make your agent more useful by adding features.

## 6.1 Add Knowledge (SharePoint FAQ)

Let your agent search SharePoint documents for answers.

```bash
# Copy the knowledge search component
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/my_first_agent/topics/

# Copy the SharePoint knowledge source
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/my_first_agent/knowledge/
```

### Configure the Knowledge Source

1. Open `agents/my_first_agent/knowledge/sharepoint.knowledge.mcs.yml`
2. Find `<SharePoint_Site_URL>`
3. Replace with your SharePoint site URL (e.g., `https://yourorg.sharepoint.com/sites/HR`)

### Redeploy

```
Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

Your agent now searches that SharePoint site for answers!

---

## 6.2 Add Feedback Collection

Collect user satisfaction ratings:

```bash
# Copy feedback component
cp -r components/topics/feedback/ agents/my_first_agent/topics/

# Redeploy
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

Users can now rate the agent's responses.

---

## 6.3 Add User Sign-In

Require users to sign in before chatting:

See: `recipes/02-authenticated-agent.md` for detailed instructions.

---

## 6.4 Add Actions (Submit Data)

Let users submit data to a system (tickets, leave requests, etc.):

See: `recipes/03-connector-action-agent.md` for detailed instructions.

---

## 6.5 Use Claude Skills to Add Features

Instead of manually copying files, use skills:

```
/copilot-studio:add-action "Add leave request submission to HR system"
→ Copilot generates the action for you

/copilot-studio:new-topic "Create a topic for leave inquiries"
→ Copilot creates the topic with trigger phrases

/copilot-studio:validate
→ Check for errors before deploying
```

---

## 6.6 Phase 6 Summary

Your agent can now be enhanced with:

```
✅ Knowledge sources (SharePoint, web)
✅ Actions (submit data to systems)
✅ Feedback collection
✅ User authentication
✅ Multiple conversation topics
✅ Advanced patterns (orchestration, etc.)
```

---

---

# Troubleshooting

Common issues and quick fixes:

## Deployment Issues

| Problem | Solution |
|---------|----------|
| "Apply Changes" button not found | Open Extensions (Ctrl+Shift+X) → search "Copilot Studio" → Install → Reload VS Code |
| YAML validation error | Check VS Code Problems panel (View → Problems) → fix red squiggles |
| Agent not created in cloud | Check `pac env who` — verify you're connected to the right environment |
| Can't find agent after deploying | Refresh browser (Ctrl+R) → check environment dropdown (top right) → verify in `pac copilot list` |

## Agent Behavior Issues

| Problem | Solution |
|---------|----------|
| Agent doesn't respond in test | Check `OnError.topic.mcs.yml` — verify schema name matches exactly |
| Agent says "I don't understand" | This is normal — it's the fallback. The agent needs more training (topics, knowledge) |
| Deployment fails with schema error | Verify all `<PLACEHOLDER>` values are replaced → check schema name matches across all 3 files |

## Configuration Issues

| Problem | Solution |
|---------|----------|
| Can't authenticate (`pac auth create` fails) | You may not have access to the environment → contact Power Platform admin |
| Wrong environment selected | Run `pac env select --environment "Name"` to switch |
| _REPLACE IDs still in files after saving | Reload VS Code (Ctrl+Shift+P → Developer: Reload Window) → Save again |

---

---

# Next Steps

### After Phase 1–5 (Agent is Live)

1. ✅ **Monitor:** Check user feedback in Copilot Studio
2. ✅ **Enhance:** Add knowledge or actions (Phase 6)
3. ✅ **Improve:** Use `/copilot-studio:run-eval` to test accuracy
4. ✅ **Scale:** Create more agents for other use cases

### Learn More

| Topic | Where to go |
|-------|---------|
| Share agent with more teams | See: `launch/user-communication-templates.md` |
| Multi-agent patterns | See: `recipes/05-orchestrator-agent.md` |
| Security & compliance | See: `governance/` folder |
| Monitor performance | See: `operations/kql-queries.md` |
| Automate deployment | See: `ci-cd/` folder |

---

---

# Reference Materials

| Resource | Purpose |
|----------|---------|
| [DEVELOPER-SETUP-GUIDE.md](docs/DEVELOPER-SETUP-GUIDE.md) | Detailed setup guide |
| [COPY-AND-SETUP-TEMPLATES.md](docs/COPY-AND-SETUP-TEMPLATES.md) | Template copy walkthrough |
| [SKILLS-QUICK-REFERENCE.md](docs/SKILLS-QUICK-REFERENCE.md) | Skills reference |
| [VERIFIED-COMMANDS.md](docs/VERIFIED-COMMANDS.md) | Command reference |
| [FAQ.md](docs/FAQ.md) | Common questions & answers |
| [DOCUMENTATION-MAP.md](docs/DOCUMENTATION-MAP.md) | Navigation guide |
| [recipes/](recipes/) | End-to-end examples |
| [components/](components/) | Reusable building blocks |

---

---

# Checklist: From Zero to Live

Track your progress:

```
PHASE 1: Setup
  [ ] pac CLI installed (pac --version works)
  [ ] VS Code Copilot Studio extension installed
  [ ] Authenticated to environment (pac env who works)
  [ ] Repository cloned and feature branch created

PHASE 2: Understanding
  [ ] Understand base template (6 files)
  [ ] Understand components
  [ ] Understand skills
  [ ] Know when to use templates vs. skills

PHASE 3: Create Agent
  [ ] Copied base template
  [ ] Replaced all 5 placeholders
  [ ] Verified no remaining placeholders
  [ ] Verified no red squiggles in VS Code
  [ ] Opened in VS Code successfully

PHASE 4: Deploy
  [ ] Ran "Copilot Studio: Apply Changes"
  [ ] Agent created in cloud (verified in UI)
  [ ] Agent status is DRAFT
  [ ] Agent configuration looks correct

PHASE 5: Test & Publish
  [ ] Tested agent (said "Hello")
  [ ] Agent responded with greeting
  [ ] Published agent (status changed to Published)
  [ ] Agent is now live for users

PHASE 6: Enhance (Optional)
  [ ] Added knowledge source (SharePoint)
  [ ] Added feedback collection
  [ ] Added actions or other features
  [ ] Tested enhancements
```

---

# Success! 🎉

You've successfully:

✅ Set up your development environment  
✅ Learned about templates and skills  
✅ Created an agent from scratch  
✅ Deployed to the cloud  
✅ Published for users  
✅ Enhanced with features  

Your agent is now **live and serving real users!**

---

**Questions? See [FAQ.md](docs/FAQ.md) or [DOCUMENTATION-MAP.md](docs/DOCUMENTATION-MAP.md)**

**Ready to build more? See [recipes/](recipes/) for other agent types.**

**Happy building! 🚀**
