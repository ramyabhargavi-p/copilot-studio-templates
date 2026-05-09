# 🔄 Complete Templates Folder Rewrite Guide

**Comprehensive guide to all template files, updated documentation, and clear navigation paths.**

---

## 📋 FOLDER STRUCTURE AT A GLANCE

```
copilot-studio-templates/
│
├── 📖 START HERE
│   ├── README.md ..................... Main entry point (↓ rewritten below)
│   └── docs/AGENT-DEVELOPER-JOURNEY.md ... Master tutorial
│
├── 🚀 GETTING STARTED
│   ├── base/ ......................... Minimum viable agent template
│   ├── recipes/ ...................... 8 step-by-step guides (by agent type)
│   ├── examples/ ..................... Real-world IT Helpdesk example
│   └── components/ ................... Drop-in pieces (topics, knowledge, actions)
│
├── 📚 REFERENCE
│   ├── docs/ ......................... All documentation and guides
│   ├── prompts/ ...................... System prompt templates
│   └── commands/ ..................... Command reference sheets
│
├── 🏢 ENTERPRISE
│   ├── project-delivery/ ............ Governance and delivery phases
│   ├── governance/ .................. Security and compliance checklists
│   ├── launch/ ....................... Go-live checklist
│   ├── operations/ .................. Monitoring and runbooks
│   └── ci-cd/ ........................ GitHub Actions pipelines
│
└── ⚙️ TOOLS
    ├── scripts/ ...................... Automation scripts
    ├── troubleshooting/ ............. Common issues and fixes
    └── commands/ ..................... CLI command reference
```

---

## 🎯 REWRITTEN README STRUCTURE

### Main `README.md` (Completely Rewritten)

**Purpose:** Clear, beginner-friendly entry point with role-based navigation.

```markdown
# Copilot Studio Templates & Guides

Production-ready YAML templates + comprehensive guides for building 
Copilot Studio agents from setup through deployment and operations.

## 🎯 Quick Start (Choose Your Path)

### Path 1: I'm Brand New (First Time Developer)
- Read: docs/AGENT-DEVELOPER-JOURNEY.md (90–120 min)
- Copy template: base/
- Deploy: "Apply Changes" in VS Code
- ✅ Live in 10–15 minutes

### Path 2: I'm Building a Specific Agent Type
- Choose recipe: recipes/ folder
  - FAQ bot: 01-basic-faq.md
  - Auth required: 02-authenticated-agent.md
  - Real-world example: examples/it-helpdesk/
- Follow 4-step setup
- ✅ Ready to customize

### Path 3: I'm Working in a Team (Enterprise)
- Setup CI/CD: ci-cd/README.md
- Define governance: governance/
- Plan delivery: project-delivery/
- Monitor live: operations/
- ✅ Multi-environment controlled deployment

### Path 4: I'm Extending/Pro-Coding
- Recipe 07: M365 Agents SDK
- Recipe 08: Azure AI Foundry
- Add components: components/ folder
- ✅ Custom orchestration or scaling

## 📚 By Role

| Role | Start Here | Then | Finally |
|------|-----------|------|---------|
| **Developer** | AGENT-DEVELOPER-JOURNEY.md | recipes/01–06 | components/ |
| **Tech Lead** | AGENT-DEVELOPER-JOURNEY.md | project-delivery/ | governance/ |
| **DevOps** | ci-cd/README.md | ci-cd/push-on-pr.yml | operations/ |
| **Pro-Dev** | recipes/07 or 08 | components/ | docs/BEST-PRACTICES.md |
| **Manager** | ENGINEERING-PLAYBOOK.md | project-delivery/00–13 | governance/ |

## 📖 Complete Guide Suite (6 Components)

See docs/ for all documentation.

## 📁 Folder Reference

### Getting Started
- **base/** - Copy this to start. 6 minimum files: agent, settings, 4 topics
- **recipes/** - 8 step-by-step guides by agent type (FAQ, Auth, Actions, etc.)
- **examples/** - Real IT Helpdesk end-to-end walkthrough
- **components/** - 49 drop-in pieces: topics, knowledge, actions, variables

### Reference & Documentation
- **docs/** - Complete documentation (20+ guides, quick refs, FAQs)
- **prompts/** - System prompt templates and generation patterns
- **commands/** - CLI command reference (pac, git, VS Code)
- **troubleshooting/** - Error solutions and debugging

### Enterprise & Operations
- **project-delivery/** - Governance phases (requirements, design, build, UAT, etc.)
- **governance/** - Security, compliance, responsible AI checklists
- **launch/** - Go-live checklist and hypercare guide
- **operations/** - KQL monitoring queries, alerts, runbooks
- **ci-cd/** - GitHub Actions pipelines for multi-environment deployment

### Tools & Scripts
- **scripts/** - Automation (setup, validation, deployment)

## 🚀 Typical Workflows

### Workflow 1: Build & Test Locally
1. Copy base/ → agents/my_agent/
2. Edit YAML in VS Code
3. Apply Changes → Deploy to Dev
4. Test in Copilot Studio
5. Commit to git

### Workflow 2: Deploy to Production
1. Create feature branch
2. Edit agent files
3. Commit & push → PR
4. CI/CD validates & deploys to Dev (push-on-pr.yml)
5. Merge → CI/CD promotes to UAT (promote-dev-to-uat.yml)
6. Create Release → CI/CD deploys to Prod (promote-uat-to-prod.yml)
7. ✅ Live & monitored

### Workflow 3: Extend with Custom Logic
1. Copy recipes/06 → agents/my_enhanced_agent/
2. Add recipe/07 (M365 SDK) for orchestration
3. Add components/actions/connectors/ for business systems
4. Add components/knowledge/ for knowledge sources
5. Test & deploy

## 📚 What to Read When

| Need | Read |
|------|------|
| First deployment? | docs/AGENT-DEVELOPER-JOURNEY.md |
| How to copy templates? | docs/COPY-AND-SETUP-TEMPLATES.md |
| Specific agent type? | recipes/ folder (pick recipe) |
| Complete real example? | examples/it-helpdesk/ |
| Add a feature? | components/ folder |
| Team deployment? | ci-cd/README.md |
| Go live? | launch/launch-checklist.md |
| Something broken? | troubleshooting/README.md |

## 🔗 Quick Links

- **Master Tutorial:** docs/AGENT-DEVELOPER-JOURNEY.md
- **Deployment Options:** docs/DEPLOYMENT-OPTIONS.md
- **All Templates:** docs/TEMPLATES.md
- **CLI Commands:** commands/pac-commands.md
- **Best Practices:** docs/BEST-PRACTICES.md
- **FAQ:** docs/FAQ.md

---

## ✅ Success Criteria

You're on the right path if:
- ✅ You found the guide for YOUR role above
- ✅ You know which recipe (01–08) matches your agent type
- ✅ You can find docs/ for reference anytime
- ✅ You understand the workflow (local → test → deploy → live)
- ✅ You know where to go if stuck (troubleshooting/ or FAQ)
```

---

## 🎨 REWRITTEN FOLDER README FILES

### base/README.md (Rewritten for Clarity)

**Key Changes:**
- Add "Why copy this first?" explanation
- Better placeholder explanation
- Clear 6-step setup (not 7, more scannable)
- Link to AGENT-DEVELOPER-JOURNEY.md Phase 3
- Visual checklist format

```markdown
# Base Agent Template — Start Here

The **minimum viable Copilot Studio agent**. Copy this entire folder 
to create a new agent project.

## Why Start With base/?

- ✅ Has all 6 files every agent needs
- ✅ Includes error handling (Fallback, OnError, OutOfScope)
- ✅ Follows Copilot Studio best practices
- ✅ Ready to customize and deploy in 15 minutes
- ✅ Used by all recipes (01–06) as foundation

## What's Inside (6 Files)

| File | Purpose | You'll Edit |
|------|---------|-----------|
| `agent.mcs.yml` | Agent identity & system prompt | ✅ Yes — your prompt |
| `settings.mcs.yml` | Runtime config (auth, language) | ✅ Yes — auth mode |
| `topics/Greeting.topic.mcs.yml` | Welcome message (fires first) | ⚪ Usually not |
| `topics/Fallback.topic.mcs.yml` | "I don't understand" (built-in) | ⚪ Usually not |
| `topics/OnError.topic.mcs.yml` | Error handling (safety) | ⚪ Usually not |
| `topics/OutOfScope.topic.mcs.yml` | "Not my area" + redirect | ✅ Yes — add domain |

## Setup (6 Steps)

### Step 1: Copy to Your Project
```bash
cp -r base/ agents/my_agent/
cd agents/my_agent/
code .
```

### Step 2: Edit agent.mcs.yml
Replace these **3 values**:
- `<AgentName>` → lowercase schema name (e.g., `my_agent`)
- `<Agent Display Name>` → friendly name (e.g., `My First Agent`)
- `<SYSTEM_PROMPT>` → what your agent does (2–3 sentences)

### Step 3: Edit settings.mcs.yml
Replace this **1 value**:
- `<agent_schema_name>` → same as AgentName above

### Step 4: Edit Fallback.topic.mcs.yml
Replace this **1 value**:
- `<AGENT_SCHEMA>` → same as AgentName above

### Step 5: Verify (VS Code)
- Save (Ctrl+S)
- View → Problems → Should see 0 red errors
- Expected: green checkmarks or no problems

### Step 6: Deploy to Cloud
```
Ctrl+Shift+P → Copilot Studio: Apply Changes
```

✅ **Agent is now in cloud (Draft status)**

## Next: Add Features or Choose a Recipe

- **Basic setup done?** Add features from `../components/`
- **Want a full example?** Use `../recipes/` (pick recipe 01–06)
- **Full walkthrough?** Follow `../docs/AGENT-DEVELOPER-JOURNEY.md`

---

## Key Concepts Explained

### Agent Schema Name
The unique identifier for your agent. Used as prefix for all components.
- Lowercase only
- Underscores instead of spaces
- Examples: `hr_assistant`, `leave_request_bot`, `it_helpdesk`
- ⚠️ Must match in `agent.mcs.yml`, `settings.mcs.yml`, and `Fallback.topic.mcs.yml`

### Authentication Mode
Choose in `settings.mcs.yml`:

| Mode | Use When |
|------|----------|
| `None` | Public agent, no user identity needed |
| `ManualAzureAD` | Users explicitly sign in (add auth topic) |
| `IntegratedAzureAD` | Silent SSO in Teams (user auto-available) |

### Topic Files
Each `.topic.mcs.yml` file is a conversation flow.
- **Greeting:** Fires when chat starts (your welcome message)
- **Fallback:** Fires when AI doesn't understand user
- **OnError:** Fires on system errors (debug-safe)
- **OutOfScope:** Fires when user asks outside your domain

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Schema name error" | Check all 3 files have same schema name |
| Red squiggles in VS Code | Likely missing placeholder replacements. Check Problems panel |
| Deploy fails | Ensure YAML is valid: `pac copilot validate agents/my_agent/` |
| Agent doesn't respond | Check Fallback.topic — verify schema name matches |
```

---

### recipes/README.md (Rewritten for Clarity)

**Key Changes:**
- Add "Which recipe for me?" decision tree at top
- Simplify complexity ratings
- Add time estimates
- Clear "copy and customize" path for each

```markdown
# Recipes: Step-by-Step Agent Builds

Eight complete guides for the most common agent types. Pick one, follow it, done.

## 🎯 Which Recipe for You?

**Step 1:** Does the agent need to sign in users?
- No → Go to Step 2
- Yes → Use **Recipe 02** (Authentication)

**Step 2:** Does the agent need to read/write business data?
- No → Use **Recipe 01** (FAQ)
- Yes → Go to Step 3

**Step 3:** Where is the data stored?
- SharePoint, Dataverse, ServiceNow → Use **Recipe 03** (Connector Actions)
- Custom API → Use **Recipe 04** (MCP Actions)

**Step 4:** Does the agent need to route across multiple sub-agents?
- No → Use recipe from above
- Yes → Use **Recipe 05** (Orchestrator)

**Step 5:** Do you need everything (Auth + Knowledge + Actions + Feedback)?
- Yes → Use **Recipe 06** (Full Featured)

**Need custom pro-code logic?**
- Yes → Use **Recipe 07** (M365 Agents SDK) or **Recipe 08** (Azure Foundry)

---

## 📖 All 8 Recipes

### Copilot Studio (Low-Code YAML)

| Recipe | For | Complexity | Time |
|--------|-----|-----------|------|
| **01-basic-faq** | Questions answered in docs | ⭐ Easy | 30 min |
| **02-authenticated** | Users sign in first | ⭐⭐ Medium | 45 min |
| **03-connector-actions** | Read/write business systems | ⭐⭐ Medium | 60 min |
| **04-mcp-actions** | Call external APIs | ⭐⭐ Medium | 60 min |
| **05-orchestrator** | Route across sub-agents | ⭐⭐⭐ Hard | 2+ hr |
| **06-full-featured** | Everything combined | ⭐⭐⭐ Hard | 2+ hr |

### Pro-Code (SDK)

| Recipe | For | Complexity | Time |
|--------|-----|-----------|------|
| **07-m365-sdk** | Custom orchestration, fine-grained control | ⭐⭐⭐ Hard | 2+ hr |
| **08-foundry** | Code execution, scaling, custom models | ⭐⭐⭐ Hard | 3+ hr |

---

## 📋 How to Use Each Recipe

### For Recipes 01–06 (Copilot Studio)

Each recipe includes:
1. **Checklist:** What to copy and customize
2. **Component list:** Exact files to include
3. **Find & Replace table:** What values to change
4. **Setup commands:** Copy-paste commands
5. **Test checklist:** Verify before deploying
6. **Expected results:** What success looks like

### For Recipes 07–08 (Pro-Code)

Each includes:
1. **When to use:** Decision vs Copilot Studio
2. **Setup:** Dev environment + SDKs
3. **Code template:** Start with this
4. **Deploy:** Integration with Copilot Studio
5. **Test:** How to verify

---

## ✅ Typical Recipe Flow

```
1. Pick your recipe (01–08)
2. Copy base/ OR recipe code
3. Follow setup checklist
4. Replace find/replace values
5. Run setup commands
6. Test locally (vs code or dev server)
7. Deploy to cloud
8. Verify in Copilot Studio
9. Publish to go live
10. Monitor & iterate
```

---

## 💡 Pro Tips

- **Start with 01 or 02** if you're new
- **Use 03/04** when you have business data to connect
- **Use 05/06** when handling multiple domains
- **Use 07/08** when Copilot Studio can't do what you need
- **Combine recipes** — start with 01, add auth (02), add actions (03)
```

---

### examples/README.md (Rewritten for Clarity)

```markdown
# Real-World Examples

Complete end-to-end walkthroughs with real project values filled in.

## Available Examples

### IT Helpdesk (Full-Featured)
**Scenario:** Contoso IT Support Bot in Teams
- Users: IT staff + employees
- Features: FAQ, sign-in required, SharePoint knowledge, ServiceNow tickets, CSAT feedback
- Recipe used: 06-full-featured-agent
- Files: All real values (no `<PLACEHOLDER>` style)

**What's Included:**
- ✅ Requirements answered
- ✅ Architecture decisions
- ✅ All YAML files (ready to copy)
- ✅ Setup & test checklist
- ✅ Expected outcomes
- ✅ Dev → UAT → Prod commands
- ✅ Week 2 monitoring & improvements

**Time to Live:** 2–3 hours (full setup + testing)

**Start Here:** [`it-helpdesk/walkthrough.md`](it-helpdesk/walkthrough.md)

---

## Learning Path

1. Read: docs/AGENT-DEVELOPER-JOURNEY.md (full tutorial)
2. Pick recipe: recipes/01–06 matching your agent type
3. Compare to: examples/it-helpdesk/ (see a real one)
4. Copy & customize: Use example as reference
5. Deploy & test: Follow example's test checklist

---

## How to Adapt This Example

**Change from IT Helpdesk to HR?**
1. Copy example structure
2. Replace IT-specific components (knowledge, actions) with HR ones
3. Update system prompt & greeting
4. Replace ServiceNow action with HR system (Workday, etc.)
5. Customize security/compliance as needed

**Change from Contoso to your org?**
1. Update org name everywhere
2. Replace SharePoint sites (point to your HR wiki)
3. Replace connector action (point to your systems)
4. Update SSO configuration (your Azure AD tenant)
5. Update monitoring (your operations team)
```

---

## 📦 REWRITTEN COMPONENTS FOLDER

### components/README.md (Completely New)

```markdown
# Components: Drop-In Building Blocks

49 pre-built pieces you can add to any agent.

## 📁 Component Categories

### Topics (Conversation Flows)
Pre-written conversation flows for common scenarios:
- `auth/` — User sign-in flow
- `disambiguation/` — Multi-choice clarification
- `escalate/` — Hand-off to human
- `feedback/` — CSAT survey

### Knowledge Sources
Connect to document repositories:
- `sharepoint-lists/` — Read from SharePoint lists
- `sharepoint-docs/` — Index documents
- `web-search/` — Search public web

### Actions (Read/Write Data)
Connectors to business systems:
- `connectors/dataverse/` — Microsoft Dataverse
- `connectors/servicenow/` — ServiceNow
- `connectors/salesforce/` — Salesforce
- `connectors/sharepoint-lists/` — Write to SharePoint

### Variables (Reusable Data)
Configuration and state storage:
- `global-variables/` — Settings used everywhere
- `session-variables/` — Per-conversation state

---

## 🎯 How to Add a Component

### Step 1: Find the component you need
Browse categories above or search: "I want to..."

### Step 2: Copy files to your agent
```bash
cp -r components/topics/auth/ agents/my_agent/topics/
```

### Step 3: Replace placeholders
- Update `<AgentName>` with your schema name
- Update `<SYSTEM_PROMPT>` if relevant
- Replace resource IDs (SharePoint site, etc.)

### Step 4: Test
- Save (Ctrl+S) — VS Code auto-validates
- Deploy: Ctrl+Shift+P → Apply Changes
- Test: Open Copilot Studio, chat with agent

---

## 📚 Component Glossary

| Component | Purpose | Add When |
|-----------|---------|----------|
| topics/auth | User sign-in | Need user identity |
| topics/feedback | CSAT survey | Gathering feedback |
| actions/connector/* | Read/write systems | Need data integration |
| knowledge/sharepoint | Search docs | Have docs to index |
| variables/globals | Config values | Need reusable settings |

---

## 💡 Common Combinations

**FAQ Bot:**
- base/ + topics/auth + knowledge/sharepoint + topics/feedback

**Ticket System Bot:**
- base/ + topics/auth + actions/connector/servicenow + topics/escalate

**Multi-domain Bot:**
- base/ + topics/disambiguation + components/* (multiple)
```

---

## ✅ VALIDATION & NEXT STEPS

All rewritten files provide:
- ✅ Clear entry points for different roles
- ✅ Beginner-friendly language
- ✅ Visual hierarchy (markdown headings, tables, lists)
- ✅ Cross-links between guides
- ✅ Decision trees (which recipe, which component, which guide)
- ✅ Copy-paste ready commands
- ✅ Success criteria (how to know it's working)

---

**This rewrite consolidates guidance, makes navigation obvious, and empowers developers to find what they need in seconds instead of minutes.**

**Ready to implement these changes? Start with main README.md rewrite, then cascade to folder-level READMEs.**
