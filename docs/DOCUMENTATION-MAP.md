# Documentation Map — Find What You Need

This page shows you exactly where to find the information you need, organized by **what you're trying to do**.

---

## I want to...

### 🚀 Get Started (First Time)

| Goal | Where to go | Time |
|------|---------|------|
| **Set up my development environment** (install tools, authenticate) | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) — Phase 1 | 20 min |
| **Copy templates and deploy my first agent** | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) — Phases 2–4 | 30 min |
| **Copy templates step-by-step with visuals** | [COPY-AND-SETUP-TEMPLATES.md](COPY-AND-SETUP-TEMPLATES.md) | 15 min |
| **Understand how to use Claude skills** | [SKILLS-QUICK-REFERENCE.md](SKILLS-QUICK-REFERENCE.md) | 10 min |

### 📋 Build Specific Agent Types

| Agent type | Where to go | Time |
|-----------|---------|------|
| **FAQ bot** (answers questions from SharePoint) | [recipes/01-basic-faq.md](../recipes/01-basic-faq.md) | 30 min |
| **FAQ bot with user sign-in** | [recipes/02-authenticated-agent.md](../recipes/02-authenticated-agent.md) | 45 min |
| **Submit data to a system** (tickets, leave requests) | [recipes/03-connector-action-agent.md](../recipes/03-connector-action-agent.md) | 60 min |
| **Call external tools/APIs** (MCP) | [recipes/04-mcp-action-agent.md](../recipes/04-mcp-action-agent.md) | 60 min |
| **Multiple agents working together** (orchestrator pattern) | [recipes/05-orchestrator-agent.md](../recipes/05-orchestrator-agent.md) | 2+ hrs |
| **All of the above combined** | [recipes/06-full-featured-agent.md](../recipes/06-full-featured-agent.md) | 2+ hrs |

### 🛠️ Find Command Reference

| Topic | Where to go |
|-------|---------|
| **pac CLI commands** | [commands/pac-commands.md](../commands/pac-commands.md) |
| **Git commands** | [commands/git-commands.md](../commands/git-commands.md) |
| **Node.js / npm commands** | [commands/nodejs-commands.md](../commands/nodejs-commands.md) |
| **VS Code tips** | [commands/vscode-commands.md](../commands/vscode-commands.md) |

### 🎨 Add Features & Components

| Feature | Where to go | Time |
|---------|---------|------|
| **Add knowledge from SharePoint** | [COPY-AND-SETUP-TEMPLATES.md](COPY-AND-SETUP-TEMPLATES.md) — Step 9.1 | 10 min |
| **Add feedback collection** | [COPY-AND-SETUP-TEMPLATES.md](COPY-AND-SETUP-TEMPLATES.md) — Step 9.2 | 5 min |
| **Browse all components** | [components/](../components/) folder | — |
| **See all component details** | [docs/COMPONENT-REGISTRY.md](COMPONENT-REGISTRY.md) | 20 min |
| **Reusable topics, knowledge, actions, variables** | [docs/BEST-PRACTICES.md](BEST-PRACTICES.md) | 15 min |

### 🧪 Test & Validate

| Task | Where to go |
|------|---------|
| **Run automated accuracy tests** | Use skill: `/copilot-studio:run-eval` |
| **Test agent manually** | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) — Phase 3, Step 3.3 |
| **Validate YAML before pushing** | Use skill: `/copilot-studio:validate` or [commands/pac-commands.md](../commands/pac-commands.md) |
| **Create test scenarios** | [project-delivery/05-eval-scenarios.md](../project-delivery/05-eval-scenarios.md) |

### 📤 Deploy to Cloud

| Scenario | Where to go |
|----------|---------|
| **Deploy via VS Code (easiest)** | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) — Phase 3 |
| **Deploy via pac CLI** | [commands/pac-commands.md](../commands/pac-commands.md) |
| **Deploy with Git + CI/CD** | [ci-cd/](../ci-cd/) folder |
| **Promote Dev → UAT → Prod** | [commands/pac-commands.md](../commands/pac-commands.md) — Section 9 |

### 🚀 Go Live & Launch

| Task | Where to go | Time |
|------|---------|------|
| **Pre-launch checklist** | [launch/launch-checklist.md](../launch/launch-checklist.md) | 30 min |
| **Publish agent for users** | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) — Phase 4 | 2 min |
| **User communications** | [launch/user-communication-templates.md](../launch/user-communication-templates.md) | 15 min |
| **Hypercare guide** | [launch/hypercare-guide.md](../launch/hypercare-guide.md) | — |

### 📊 Monitor & Operate

| Task | Where to go |
|------|---------|
| **Monitor agent performance** | [operations/kql-queries.md](../operations/kql-queries.md) |
| **Set up alerts** | [operations/alert-setup.md](../operations/alert-setup.md) |
| **Troubleshoot issues** | [troubleshooting/README.md](../troubleshooting/README.md) |
| **Post-launch runbook** | [operations/runbook.md](../operations/runbook.md) |

### ✅ Enterprise Delivery (Full Process)

| Phase | Where to go | Time |
|-------|---------|------|
| **Full end-to-end delivery guide** | [docs/START-HERE.md](START-HERE.md) | Varies |
| **Discovery & requirements** | [project-delivery/00-ai-decision-framework.md](../project-delivery/00-ai-decision-framework.md) | 2 hrs |
| **Design & architecture** | [project-delivery/01-requirements-discovery.md](../project-delivery/01-requirements-discovery.md) | 3 hrs |
| **Responsible AI review** | [governance/ai-ethics-checklist.md](../governance/ai-ethics-checklist.md) | 1 hr |
| **Security review** | [governance/security-review-checklist.md](../governance/security-review-checklist.md) | 1 hr |
| **All delivery phases** | [project-delivery/](../project-delivery/) folder | — |

### 🔐 Security & Responsible AI

| Topic | Where to go |
|-------|---------|
| **Responsible AI checklist** | [governance/ai-ethics-checklist.md](../governance/ai-ethics-checklist.md) |
| **Security review** | [governance/security-review-checklist.md](../governance/security-review-checklist.md) |
| **PII prevention** | [docs/PII-SCRUBBING.md](PII-SCRUBBING.md) |
| **Action safety patterns** | [docs/ACTION-SAFETY-PATTERNS.md](ACTION-SAFETY-PATTERNS.md) |
| **Environment variables** | [docs/ENV-VARIABLES.md](ENV-VARIABLES.md) |

### 🪛 Troubleshoot Issues

| Problem | Where to go |
|---------|---------|
| **"Apply Changes" command not working** | [troubleshooting/README.md](../troubleshooting/README.md) — VS Code section |
| **Agent doesn't respond in test** | [troubleshooting/README.md](../troubleshooting/README.md) — Agent behavior section |
| **YAML validation errors** | [troubleshooting/README.md](../troubleshooting/README.md) — YAML errors section |
| **Deployment failed** | [troubleshooting/README.md](../troubleshooting/README.md) — Deployment section |
| **pac CLI errors** | [commands/pac-commands.md](../commands/pac-commands.md) — Troubleshooting section |
| **Common mistakes** | [docs/BEST-PRACTICES.md](BEST-PRACTICES.md) |

---

## Documentation Structure

```
📄 Master Navigation (this file)
│
├─ 🚀 GET STARTED
│  ├─ DEVELOPER-SETUP-GUIDE.md          (Install + First agent)
│  ├─ COPY-AND-SETUP-TEMPLATES.md       (Copy templates step-by-step)
│  ├─ SKILLS-QUICK-REFERENCE.md         (How to use Claude skills)
│  └─ QUICKSTART.md                     (Quick overview)
│
├─ 📋 BUILD AGENTS
│  ├─ recipes/                          (6 agent templates)
│  ├─ components/                       (Reusable parts)
│  ├─ COMPONENT-REGISTRY.md             (What's available)
│  ├─ BEST-PRACTICES.md                 (Design rules)
│  ├─ TEMPLATES.md                      (Full inventory)
│  └─ examples/                         (End-to-end example)
│
├─ 🛠️ REFERENCE
│  ├─ commands/                         (CLI command reference)
│  ├─ prompts/                          (System prompt templates)
│  ├─ TOOLS-AND-PLUGINS.md              (Setup instructions)
│  └─ TEAM-GUIDE.md                     (Role-based entry points)
│
├─ 📤 DEPLOY & LAUNCH
│  ├─ ci-cd/                            (GitHub Actions pipelines)
│  ├─ launch/                           (Go-live guide)
│  └─ operations/                       (Post-launch monitoring)
│
├─ ✅ GOVERNANCE
│  ├─ governance/                       (Security & RAI checklists)
│  ├─ project-delivery/                 (Full delivery phases)
│  └─ ENGINEERING-PLAYBOOK.md           (Complete playbook)
│
└─ 🪧 TROUBLESHOOT
   └─ troubleshooting/                  (Issues & solutions)
```

---

## Quick Decision Tree

**Answer these questions to find your path:**

### 1. Is this your first time?
- **Yes** → Go to [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md)
- **No** → Continue to question 2

### 2. Are you deploying a new agent?
- **Yes** → Go to [COPY-AND-SETUP-TEMPLATES.md](COPY-AND-SETUP-TEMPLATES.md)
- **No** → Continue to question 3

### 3. Are you adding a feature?
- **Yes** → Go to [SKILLS-QUICK-REFERENCE.md](SKILLS-QUICK-REFERENCE.md)
- **No** → Continue to question 4

### 4. Is something broken?
- **Yes** → Go to [troubleshooting/README.md](../troubleshooting/README.md)
- **No** → Go to [START-HERE.md](START-HERE.md) for full guidance

---

## File Naming Convention

| Pattern | Meaning | Example |
|---------|---------|---------|
| `CAPS-WITH-DASHES.md` | Main documentation | `DEVELOPER-SETUP-GUIDE.md` |
| `lowercase-with-dashes/` | Category folder | `recipes/`, `components/` |
| `number-dash-description.md` | Ordered phases | `00-ai-decision-framework.md` |
| `*.topic.mcs.yml` | Copilot Studio topic file | `Greeting.topic.mcs.yml` |
| `*.knowledge.mcs.yml` | Knowledge source file | `sharepoint.knowledge.mcs.yml` |
| `*.action.mcs.yml` | Action/connector file | `leave-request.action.mcs.yml` |

---

## How to Navigate This Repo

### Option 1: Start from a guide
1. Determine your goal from the table above (I want to...)
2. Click the link
3. Follow the step-by-step instructions

### Option 2: Use the decision tree
1. Answer the 4 questions above
2. Click the final link
3. Follow the path

### Option 3: Browse by folder
- **Getting started?** → Read `DEVELOPER-SETUP-GUIDE.md` first
- **Building agents?** → Browse `recipes/` folder
- **Need CLI commands?** → Go to `commands/` folder
- **Deploying?** → Go to `launch/` folder
- **Something broken?** → Go to `troubleshooting/` folder

### Option 4: Use search
- In GitHub, press `/` to open search
- Search for keywords: "knowledge", "action", "troubleshoot", etc.

---

## Common Entry Points by Role

| Your role | Start here |
|-----------|-----------|
| **Developer** (building first agent) | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) |
| **Developer** (adding features) | [SKILLS-QUICK-REFERENCE.md](SKILLS-QUICK-REFERENCE.md) |
| **Tech Lead** (review) | [BEST-PRACTICES.md](BEST-PRACTICES.md) |
| **Security** (compliance) | [governance/security-review-checklist.md](../governance/security-review-checklist.md) |
| **AI Officer** (responsible AI) | [governance/ai-ethics-checklist.md](../governance/ai-ethics-checklist.md) |
| **DevOps** (CI/CD) | [ci-cd/README.md](../ci-cd/README.md) |
| **Product** (go-live) | [launch/launch-checklist.md](../launch/launch-checklist.md) |
| **Support** (operations) | [operations/README.md](../operations/README.md) |

---

## Legend

| Icon | Meaning |
|------|---------|
| 🚀 | Getting started / First-time setup |
| 📋 | Documentation / Reference |
| 🛠️ | Tools / Commands |
| 🎨 | Components / Building blocks |
| 🧪 | Testing / Validation |
| 📤 | Deployment / Launch |
| ✅ | Quality assurance / Governance |
| 🔐 | Security / Compliance |
| 📊 | Monitoring / Operations |
| 🪧 | Troubleshooting / Help |

---

**Still lost? Ask in the README or see [TEAM-GUIDE.md](TEAM-GUIDE.md) for role-specific entry points.**
