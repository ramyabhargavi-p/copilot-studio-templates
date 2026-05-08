# How to Copy & Use Templates — Complete Step-by-Step

A simple, visual guide to copying templates from this repo, configuring them, and deploying them to the cloud.

---

## Step 1: Choose Your Template Type

Based on what you want to build:

| What to build | Template folder | Time | Start with |
|---|---|---|---|
| FAQ bot that answers questions from SharePoint | `base/` + `components/knowledge/sharepoint/` | 30 min | Section 2 |
| Same, but users must sign in first | `recipes/02-authenticated-agent.md` | 45 min | Recipe 2 |
| Bot that submits data to a system (tickets, leave requests) | `recipes/03-connector-action-agent.md` | 60 min | Recipe 3 |
| Bot that calls external tools/APIs | `recipes/04-mcp-action-agent.md` | 60 min | Recipe 4 |
| Starter for any custom agent | `base/` | 30 min | Section 2 |

**For this guide, we'll build a FAQ bot using the base template. The process is the same for all templates.**

---

## Step 2: Copy the Base Template Files

All templates start with these 6 foundational files in the `base/` folder.

```bash
# Copy the base template to your agents folder
cp -r base/ agents/my_first_agent/
```

**What you just copied:**
```
agents/
└── my_first_agent/
    ├── agent.mcs.yml              (Agent name, system prompt, knowledge sources)
    ├── settings.mcs.yml           (Auth settings, language, access control)
    ├── Greeting.topic.mcs.yml     (First message users see)
    ├── Fallback.topic.mcs.yml     (What happens when agent doesn't understand)
    ├── OnError.topic.mcs.yml      (What happens if agent crashes)
    └── .gitignore                 (Which files to ignore in git)
```

---

## Step 3: Replace the 5 Required Placeholders

These 5 values must be replaced in your agent files before deployment. Use VS Code's Find & Replace (Ctrl+H).

### 3.1 — Update `agent.mcs.yml`

Open `agents/my_first_agent/agent.mcs.yml` and replace 3 values:

| Find | Replace with | Example |
|------|-------------|---------|
| `<AgentName>` | Your schema name (lowercase, no spaces) | `my_first_agent` |
| `<Agent Display Name>` | Display name (can have spaces) | `My First Agent` |
| `<SYSTEM_PROMPT>` | What your agent does (2–3 sentences) | `You are a helpful assistant that answers questions about company policies and procedures. You have access to our HR knowledge base. Always be friendly and professional.` |

**How to replace:**
1. Open the file in VS Code
2. Press **Ctrl+H** to open Find & Replace
3. Type the placeholder in the "Find" box
4. Type the replacement in the "Replace" box
5. Click "Replace All"
6. Save (Ctrl+S)

**Verify:** The file should now show your agent name instead of `<AgentName>`.

---

### 3.2 — Update `settings.mcs.yml`

Open `agents/my_first_agent/settings.mcs.yml` and replace 1 value:

| Find | Replace with | Example |
|------|-------------|---------|
| `<agent_schema_name>` | Same schema name from step 3.1 | `my_first_agent` |

---

### 3.3 — Update `Fallback.topic.mcs.yml`

Open `agents/my_first_agent/Fallback.topic.mcs.yml` and replace 1 value:

| Find | Replace with | Example |
|------|-------------|---------|
| `<AGENT_SCHEMA>` | Same schema name from step 3.1 | `my_first_agent` |

---

### 3.4 — Verify All Replacements

Search for remaining placeholders to make sure you didn't miss any:

```bash
# In VS Code: Ctrl+Shift+F (Find in Folder)
# Search for: <.*>
# Look for any remaining angle brackets

# Or from terminal:
grep -r "<.*>" agents/my_first_agent/
# Should return: (nothing — all placeholders replaced)
```

---

## Step 4: Auto-Replace Node IDs

The template uses `_REPLACE` placeholders for internal node IDs. The VS Code Copilot Studio extension auto-replaces these when you save.

```
1. Open any .mcs.yml file in VS Code
2. Press Ctrl+S (Save)
3. The extension auto-replaces all _REPLACE IDs with unique IDs
```

**Verify:** Search for `_REPLACE` — should find nothing.

---

## Step 5: Open in VS Code

```bash
# Open your agent folder in VS Code
code agents/my_first_agent/
```

You should see:
- ✅ 6 files listed in the Explorer (left sidebar)
- ✅ Copilot Studio icon in the status bar (extension is active)
- ✅ No red error squiggles in the files

If any of these are missing, go back to prerequisites (docs/DEVELOPER-SETUP-GUIDE.md).

---

## Step 6: Deploy to Cloud via VS Code

This is the key part. You'll deploy your agent to the cloud **without using the web UI**. On the first run, VS Code will **automatically create the agent**.

### 6.1 — Deploy (First Time = Automatic Creation)

1. In VS Code, press **Ctrl+Shift+P** (or Cmd+Shift+P on macOS)
2. Type: `Copilot Studio: Apply Changes`
3. Press Enter

You should see a progress bar. After 10–30 seconds:

```
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...        ← Agent AUTOMATICALLY created
✓ Complete

Agent deployed successfully!
```

**Yes! On the FIRST run, "Apply Changes" automatically creates a new agent in the cloud.**

| When | Action |
|------|--------|
| **First time** | ✅ Automatically **creates** new agent |
| **Subsequent times** | ✅ Updates existing agent |

The agent name comes from your `agent.mcs.yml`:
- **Schema name** (internal ID): `my_first_agent`
- **Display name** (what users see): `My First Agent`

### 6.2 — Verify Deployment

Your agent is now in the cloud (as a draft). Check it in Copilot Studio:

1. Open: https://make.microsoft.com
2. Select your environment (top right dropdown)
3. Click **Copilot Studio** (left sidebar)
4. You should see your agent listed (e.g., "My First Agent") with a **Draft** label

**If you don't see it:**
- Refresh the page (Ctrl+R)
- Check you're in the correct environment (dropdown)
- Check VS Code Output panel (View → Output) for error messages

---

## Step 7: Test Your Agent

1. In Copilot Studio, click your agent name
2. Click the **Test** pane (right side)
3. Type a message: "Hello"

Your agent should respond with the greeting message from `Greeting.topic.mcs.yml`.

**If the agent doesn't respond:**
- Check the error message in the test pane
- Open `OnError.topic.mcs.yml` — verify `<AGENT_SCHEMA>` matches your schema name exactly
- In VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes" again
- Test again

---

## Step 8: Publish to Live

Your agent is now live in the cloud as a **draft**. Publish it so users can access it.

```
1. In Copilot Studio, find your agent
2. Click the "..." menu (top right)
3. Click "Publish"
4. Confirm
```

Your agent is now live! Users can find it in Copilot Studio.

---

## Step 9: (Optional) Add Components

Now that your agent works, you can add features using templates in the `components/` folder.

### 9.1 — Add Knowledge (SharePoint FAQ)

Copy the knowledge search components:

```bash
# Copy the topic that searches knowledge
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/my_first_agent/topics/

# Copy the SharePoint knowledge source
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/my_first_agent/knowledge/
```

Open the knowledge file and replace `<SharePoint_Site_URL>` with your SharePoint site URL.

Then redeploy:
```
Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

### 9.2 — Add Feedback Collection

Copy the feedback component:

```bash
cp -r components/topics/feedback/ agents/my_first_agent/topics/
```

This lets users rate the agent's responses. Redeploy to enable it.

### 9.3 — Add Authentication (Users Must Sign In)

For a more advanced agent with user sign-in:

```bash
# Follow the recipe
open recipes/02-authenticated-agent.md
```

---

## Template Structure Reference

When you copy templates, you're copying **YAML files**. Here's what each file does:

| File | What it controls | When to edit |
|------|-----------------|-------------|
| `agent.mcs.yml` | Agent name, system prompt, knowledge sources, AI model | When creating agent or changing the purpose |
| `settings.mcs.yml` | Auth mode, language, who can access | When changing auth or access control |
| `Greeting.topic.mcs.yml` | First message users see | When changing greeting |
| `Fallback.topic.mcs.yml` | What happens when agent doesn't understand | When changing error handling |
| `OnError.topic.mcs.yml` | What happens if agent crashes | When changing crash behavior |
| Topic files in `topics/` | Conversation flows and logic | When adding features |
| Knowledge files in `knowledge/` | FAQ content and sources | When adding knowledge |
| Action files in `actions/` | Integrations with systems | When adding system integrations |
| Variable files in `variables/` | State and data storage | When adding state management |

---

## Troubleshooting Template Copy Issues

### Issue: "Apply Changes" fails with "YAML validation error"

**Cause:** Indentation error or missing placeholder replacement  
**Fix:**
1. Check for red squiggles in VS Code (left side line numbers)
2. Make sure all `<PLACEHOLDER>` values are replaced
3. Use indent-rainbow extension to verify indentation (View → Extensions → search "indent-rainbow")
4. Save the file (Ctrl+S)
5. Try "Apply Changes" again

---

### Issue: Agent created but doesn't respond in test

**Cause:** Schema name mismatch  
**Fix:**
1. Open `Fallback.topic.mcs.yml`
2. Find the line with `<AGENT_SCHEMA>` (should be replaced)
3. Verify it matches your schema name exactly (case-sensitive)
4. Save and re-apply changes

---

### Issue: "I copied the template but don't know what to edit next"

**Cause:** Template has too many options  
**Fix:** Follow the recipe for your use case:
- FAQ bot? → `recipes/01-basic-faq.md`
- Authentication? → `recipes/02-authenticated-agent.md`
- Action agent? → `recipes/03-connector-action-agent.md`

---

### Issue: _REPLACE still appears in files after auto-replace

**Cause:** VS Code extension not active or not installed  
**Fix:**
1. Open Extensions (Ctrl+Shift+X)
2. Search "Copilot Studio"
3. Click Install (if not already installed)
4. Reload VS Code (Ctrl+Shift+P → "Developer: Reload Window")
5. Open a .mcs.yml file and save again (Ctrl+S)

---

## Quick Reference: Copy Commands

| Use case | Command |
|----------|---------|
| Copy base template | `cp -r base/ agents/my_agent/` |
| Copy FAQ knowledge source | `cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/my_agent/knowledge/` |
| Copy knowledge search topic | `cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/my_agent/topics/` |
| Copy feedback component | `cp -r components/topics/feedback/ agents/my_agent/topics/` |
| Copy all components (careful — may include extras) | `cp -r components/* agents/my_agent/` |
| Deploy to cloud | Ctrl+Shift+P → "Copilot Studio: Apply Changes" |
| Check for remaining placeholders | Ctrl+Shift+F in VS Code, search `<.*>` |
| Check for remaining _REPLACE IDs | Ctrl+Shift+F in VS Code, search `_REPLACE` |

---

## Next Steps

1. ✅ **Agent working?** → Go to [SKILLS-QUICK-REFERENCE.md](SKILLS-QUICK-REFERENCE.md) to add features
2. ✅ **Want more components?** → Browse `components/` folder
3. ✅ **Ready for UAT?** → See [START-HERE.md](START-HERE.md) for full delivery guide
4. ✅ **Something broken?** → See [troubleshooting/README.md](../troubleshooting/README.md)

---

**Your agent is now live! 🎉**
