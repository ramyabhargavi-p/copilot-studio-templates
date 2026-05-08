# Visual Quick Start — 5-Minute Agent Deployment

**Fastest path from zero to a working agent in the cloud.**

---

## Phase 1: Verify Prerequisites (2 minutes)

Check that these are installed:

```
✅ pac CLI installed?
   Command: pac --version
   Expected: pac (Power Apps CLI) version 2.7.x or higher

✅ VS Code + Copilot Studio extension?
   Open VS Code → Extensions (Ctrl+Shift+X) → search "Copilot Studio"
   Expected: See "Copilot Studio" by Microsoft with Install button (or already installed)

✅ Authenticated to Power Platform?
   Command: pac env who
   Expected: Connected to: [Your Environment] | your@email.com

✅ Repository cloned?
   Command: ls base/
   Expected: Shows files like agent.mcs.yml, settings.mcs.yml, etc.
```

**If any of these fail,** go to [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) Phase 1 (20 minutes).

---

## Phase 2: Copy & Configure (3 minutes)

### Step 1 — Copy Base Template
```bash
cp -r base/ agents/my_first_agent/
```

### Step 2 — Replace 5 Placeholders

Open these 3 files in VS Code and use **Find & Replace (Ctrl+H)**:

**File 1: `agents/my_first_agent/agent.mcs.yml`**
```
Find: <AgentName>                    Replace with: my_first_agent
Find: <Agent Display Name>           Replace with: My First Agent
Find: <SYSTEM_PROMPT>                Replace with: I help users with questions about company policies.
```

**File 2: `agents/my_first_agent/settings.mcs.yml`**
```
Find: <agent_schema_name>            Replace with: my_first_agent
```

**File 3: `agents/my_first_agent/Fallback.topic.mcs.yml`**
```
Find: <AGENT_SCHEMA>                 Replace with: my_first_agent
```

### Step 3 — Auto-Replace Node IDs
```
Open any .mcs.yml file in VS Code
Press Ctrl+S (Save)
→ Extension auto-replaces _REPLACE IDs with unique IDs
```

**Verify:** No red squiggles in VS Code (check left side line numbers).

---

## Phase 3: Deploy to Cloud (1 minute)

```
1. In VS Code, press Ctrl+Shift+P
2. Type: Copilot Studio: Apply Changes
3. Press Enter
4. Wait 10–30 seconds for completion

Expected output:
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...
✓ Complete
```

---

## Phase 4: Test & Publish (1 minute)

### Test in Cloud
```
1. Open https://make.microsoft.com
2. Select your environment (top right)
3. Find your agent ("My First Agent")
4. Click the agent name
5. Click "Test" pane (right side)
6. Type: "Hello"
→ Agent responds with greeting ✅
```

### Publish for Users
```
1. In Copilot Studio, find your agent
2. Click "..." menu (top right)
3. Click "Publish"
4. Confirm

Your agent is now LIVE! 🎉
```

---

## Diagram: What Just Happened

```
┌─────────────────────────────────────────┐
│  Your Computer                          │
│  ┌─────────────────────────────────────┐│
│  │ VS Code                             ││
│  │ ┌────────┐  ┌────────┐  ┌────────┐ ││
│  │ │YAML    │→ │Replace │→ │Deploy  │ ││
│  │ │Files   │  │Values  │  │Button  │ ││
│  │ └────────┘  └────────┘  └────────┘ ││
│  └──────────────────────────────────────┘│
│             ↓ Ctrl+Shift+P               │
└─────────────────────────────────────────┘
             ↓ "Apply Changes"
┌─────────────────────────────────────────┐
│  Azure Cloud (Power Platform)           │
│  ┌─────────────────────────────────────┐│
│  │ Copilot Studio                      ││
│  │ ┌──────────────┐ ┌───────────────┐ ││
│  │ │ Your Agent   │ │ In "Draft"    │ ││
│  │ │ (Published)  │ │ Status        │ ││
│  │ └──────────────┘ └───────────────┘ ││
│  └──────────────────────────────────────┘│
│             ↓ Click "Publish"            │
│  ┌─────────────────────────────────────┐│
│  │ Agent Now LIVE for Users            ││
│  └──────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

---

## What Each File Does

| File | What it controls | When to edit |
|------|-----------------|-------------|
| `agent.mcs.yml` | Agent name, system prompt, knowledge sources | Now (Step 2) |
| `settings.mcs.yml` | Auth, language, who can access | If needed |
| `Greeting.topic.mcs.yml` | First message users see | If you want to customize |
| `Fallback.topic.mcs.yml` | What happens when agent doesn't understand | Generally leave as-is |
| `OnError.topic.mcs.yml` | What happens if agent crashes | Generally leave as-is |

---

## Common Issues & Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| **VS Code doesn't have Copilot Studio extension** | Open Extensions (Ctrl+Shift+X), search "Copilot Studio", click Install |
| **"Apply Changes" button not found** | Reload VS Code (Ctrl+Shift+P → "Developer: Reload Window") |
| **Agent created but doesn't respond in test** | Check `Fallback.topic.mcs.yml` — verify `<AGENT_SCHEMA>` matches your agent name exactly |
| **Can't find your agent in Copilot Studio** | Verify you're in the correct environment (top right dropdown). Try refreshing the page. |
| **Red squiggles in YAML files** | Indentation error. Use indent-rainbow extension (View → Extensions) to see indentation levels. |
| **"YAML validation error" when deploying** | Check VS Code Problems panel (View → Problems). Fix all red errors and try again. |

---

## Next Steps

After your first agent works:

| What | How | Time |
|------|-----|------|
| **Add SharePoint FAQ knowledge** | `cp components/knowledge/sharepoint/*.mcs.yml agents/my_first_agent/knowledge/` | 5 min |
| **Add feedback collection** | `cp -r components/topics/feedback/ agents/my_first_agent/topics/` | 5 min |
| **Add action (submit data)** | Follow `recipes/03-connector-action-agent.md` | 30 min |
| **Add user sign-in** | Follow `recipes/02-authenticated-agent.md` | 45 min |
| **Full enterprise setup** | Read `DEVELOPER-SETUP-GUIDE.md` phases 5+ | Varies |

---

## Command Cheat Sheet (Copy & Paste)

```bash
# Clone repo
git clone https://github.com/microsoft/copilot-studio-templates.git
cd copilot-studio-templates

# Create feature branch
git checkout -b feature/my-first-agent

# Copy template
cp -r base/ agents/my_first_agent/

# Check auth
pac env who

# List agents
pac copilot list

# Verify setup
pac --version
```

---

## Architecture (What You're Building)

```
Your Agent
├── Agent Configuration (agent.mcs.yml)
│   ├── Name: "My First Agent"
│   ├── System Prompt: "I help with company policies..."
│   └── Knowledge Sources: [Connected to SharePoint]
│
├── Settings (settings.mcs.yml)
│   ├── Auth: [Not required for this demo]
│   └── Access: [Everyone can use]
│
└── Topics (Conversations)
    ├── Greeting (Greeting.topic.mcs.yml)
    │   └── First message users see
    ├── Knowledge Search (KnowledgeSearch.topic.mcs.yml) [Optional]
    │   └── Search SharePoint documents
    ├── Fallback (Fallback.topic.mcs.yml)
    │   └── When agent doesn't understand
    └── Error Handler (OnError.topic.mcs.yml)
        └── When agent crashes
```

---

## Success Checklist

After Phase 4, you should be able to check all of these:

```
✅ Agent appears in Copilot Studio list
✅ Agent responds to test messages
✅ Agent greeting appears when you start a chat
✅ Agent is published (not in "Draft" status)
✅ You can ask a question and get a response
✅ Users can find and use the agent
```

If all checked, you're done! 🎉

---

## Getting Help

| Problem | Where to go |
|---------|---------|
| More details on Phase 1 | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) |
| More details on Phase 2 | [COPY-AND-SETUP-TEMPLATES.md](COPY-AND-SETUP-TEMPLATES.md) |
| More details on Phase 3-4 | [DEVELOPER-SETUP-GUIDE.md](DEVELOPER-SETUP-GUIDE.md) Phases 3-4 |
| Command reference | [VERIFIED-COMMANDS.md](VERIFIED-COMMANDS.md) |
| Troubleshooting | [troubleshooting/README.md](../troubleshooting/README.md) |
| All guides | [DOCUMENTATION-MAP.md](DOCUMENTATION-MAP.md) |

---

**Your agent is live! Now go add features. 🚀**
