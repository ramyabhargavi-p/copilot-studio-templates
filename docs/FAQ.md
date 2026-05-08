# Frequently Asked Questions — Agent Deployment & Development

Quick answers to common questions about creating, deploying, and managing agents.

---

## 🚀 Deployment & "Apply Changes"

### Q: When I run "Copilot Studio: Apply Changes", does it automatically create the agent?

**A: YES.** On your **first run**, "Apply Changes" automatically creates a new agent in the cloud.

| Scenario | What Happens |
|----------|-------------|
| **First deployment** (agent doesn't exist in cloud) | ✅ **Automatically creates** a new agent |
| **Second+ deployment** (agent already exists) | ✅ **Updates** the existing agent |

The agent is created using your YAML configuration:
- **Agent name:** From `<AgentName>` in `agent.mcs.yml`
- **Display name:** From `<Agent Display Name>` in `agent.mcs.yml`
- **System prompt:** From `<SYSTEM_PROMPT>` in `agent.mcs.yml`
- **Schema name:** Used as the internal ID (must match in `settings.mcs.yml` and `Fallback.topic.mcs.yml`)

**Expected output:**
```
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...    ← New agent created automatically
✓ Complete
```

---

### Q: Do I need to use the Copilot Studio web UI to create the agent first?

**A: NO.** "Apply Changes" handles everything. You **don't need to create the agent in the web UI** — it's created automatically on first deployment.

**Workflow:**
```
1. Copy template files locally
2. Edit YAML in VS Code
3. Press Ctrl+Shift+P → "Copilot Studio: Apply Changes"
4. Agent is automatically created in the cloud as a draft
5. Done!
```

---

### Q: What's the difference between "creating" and "updating"?

**A:**
- **Create:** First deployment. Agent doesn't exist in cloud yet. "Apply Changes" creates it with all your YAML configuration.
- **Update:** Subsequent deployments. Agent exists. "Apply Changes" modifies its configuration (name, prompt, topics, knowledge, etc.).

---

### Q: Can I deploy multiple agents?

**A: YES.** Each agent has a different schema name and folder.

```bash
# Agent 1
cp -r base/ agents/hr_assistant/
# Edit and deploy

# Agent 2
cp -r base/ agents/leave_request_bot/
# Edit and deploy

# Both are now live as separate agents
```

---

### Q: What if "Apply Changes" fails?

**A:** Check these in order:

1. **YAML syntax errors?**
   - View → Problems panel in VS Code
   - Fix red squiggles and try again

2. **Not authenticated?**
   - Terminal: `pac env who`
   - If error: `pac auth create` to re-authenticate

3. **Wrong environment?**
   - Check top-right environment dropdown in Copilot Studio
   - Verify: `pac env who`
   - If wrong: `pac env select --environment "Name"`

4. **Schema name missing or invalid?**
   - Open `agent.mcs.yml`
   - Verify `<AgentName>` is replaced and valid (lowercase, no spaces)
   - Try again

---

## 📋 Templates & Configuration

### Q: Do I have to replace all the `<PLACEHOLDER>` values?

**A: YES.** All placeholders must be replaced before deploying:

| Placeholder | Where | Replace with |
|-------------|-------|-------------|
| `<AgentName>` | `agent.mcs.yml` | Your schema name (lowercase) |
| `<Agent Display Name>` | `agent.mcs.yml` | Display name (with spaces OK) |
| `<SYSTEM_PROMPT>` | `agent.mcs.yml` | What your agent does |
| `<agent_schema_name>` | `settings.mcs.yml` | Same schema name |
| `<AGENT_SCHEMA>` | `Fallback.topic.mcs.yml` | Same schema name |

If any are left, deployment will fail with a schema error.

---

### Q: What are `_REPLACE` IDs and do I need to replace them manually?

**A: NO.** VS Code's Copilot Studio extension auto-replaces them when you save.

```
1. Open any .mcs.yml file in VS Code
2. Press Ctrl+S (Save)
3. All _REPLACE IDs are automatically replaced with unique IDs
```

If you still see `_REPLACE` after saving:
- Reload VS Code: Ctrl+Shift+P → "Developer: Reload Window"
- Ensure extension is installed: Ctrl+Shift+X → search "Copilot Studio"

---

### Q: Can I use the same agent files in multiple environments?

**A: YES, but with caution.**

```bash
# Safe: Different agents in different environments
pac env select --environment "Dev"
# Deploy agent 1

pac env select --environment "UAT"
# Deploy agent 2 (different copy)

# NOT safe: Same agent files, different env
# This will create duplicate agents with same schema name
```

**Best practice:** Use the same schema name in all environments, but deploy to each environment separately.

---

## 🛠️ CLI & Commands

### Q: Which commands do I actually need?

**A: Just these:**

```bash
# Check environment
pac env who

# (Optional) List agents
pac copilot list

# Publish after deploying
pac copilot publish --bot "Agent Display Name"
```

**That's it!** Everything else happens via "Copilot Studio: Apply Changes" in VS Code.

---

### Q: What's the difference between `pac copilot push` and "Apply Changes"?

**A:**
- **"Apply Changes"** (VS Code button) ← **Use this** — easier, built-in
- **`pac copilot push`** (CLI command) ← Optional, requires Copilot Studio Kit

They do the same thing. Use "Apply Changes" unless you're automating (CI/CD).

---

### Q: When do I use `pac copilot extract-template`?

**A:** Only when you want to **download an existing agent** to edit locally.

```bash
# Get the GUID from pac copilot list
pac copilot list

# Download it
mkdir agents/export
pac copilot extract-template \
  --bot "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --templateFileName ./agents/export/agent.yaml \
  --templateVersion 1.0.0

# Edit locally, then redeploy
```

**Most of the time:** Use VS Code's "Copilot Studio: Clone Agent" instead (easier).

---

## 🧪 Testing & Publishing

### Q: After deploying, how do I test the agent?

**A:**
1. Open: https://make.microsoft.com
2. Select your environment (top right)
3. Click your agent
4. Click **Test** pane (right side)
5. Type a message and chat with the agent

**If it doesn't respond:**
- Check `OnError.topic.mcs.yml` — verify schema name matches exactly
- Re-deploy: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
- Test again

---

### Q: What's the difference between "Draft" and "Published"?

**A:**
- **Draft:** Agent exists in cloud but users can't see it
- **Published:** Agent is live and users can access it

**Default after deployment:** Draft

**Publish it:**
1. In Copilot Studio, find your agent
2. Click **Publish** (or use: `pac copilot publish --bot "Name"`)

---

### Q: Can I have the same agent in Draft AND Published?

**A: NO.** There's one version per agent per environment.

When you publish:
- Draft → Published (replaces old published version)
- Users immediately see the new version

---

## 📊 Knowledge & Components

### Q: How do I add knowledge (SharePoint FAQ)?

**A:**
```bash
# Copy knowledge component
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/my_agent/knowledge/

# Edit the file and replace SharePoint URL
code agents/my_agent/knowledge/sharepoint.knowledge.mcs.yml

# Deploy
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

Agent now searches that SharePoint site for answers.

---

### Q: How do I add an action (submit data)?

**A:**
```bash
# Option 1: Use Claude skill
/copilot-studio:add-action "Add leave request submission"

# Option 2: Copy component
cp components/actions/leave-request/leave-request.action.mcs.yml agents/my_agent/actions/

# Edit configuration and deploy
```

---

## 🚀 Production & Enterprise

### Q: Can I have agents in multiple environments (Dev, UAT, Prod)?

**A: YES.** Standard ALM (Application Lifecycle Management).

```bash
# Step 1: Deploy to Dev
pac env select --environment "Dev"
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"
# Test and verify

# Step 2: Deploy to UAT
pac env select --environment "UAT"
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"
# UAT team tests

# Step 3: Deploy to Prod
pac env select --environment "Prod"
# Ctrl+Shift+P → "Copilot Studio: Apply Changes"
# Publish when ready
```

---

### Q: How do I automate deployments?

**A:** Use GitHub Actions (CI/CD).

See: `ci-cd/` folder for pipelines that auto-deploy on commits.

---

### Q: What security checks should I do before going live?

**A:**
1. Read: `governance/ai-ethics-checklist.md`
2. Read: `governance/security-review-checklist.md`
3. Check: `docs/PII-SCRUBBING.md` (no sensitive data in prompts)
4. Check: `docs/ACTION-SAFETY-PATTERNS.md` (safe action handling)

All in: `governance/` folder.

---

## ❌ Common Mistakes

### Q: I replaced all placeholders but deployment still fails. What's wrong?

**A: Check these:**

1. **Spaces or capitals in schema name?**
   - Schema must be: lowercase, no spaces
   - ✅ `hr_assistant`, `leave_bot`
   - ❌ `HR Assistant`, `LeaveBot`, `hr-assistant`

2. **Schema name doesn't match across files?**
   - `<AgentName>` in `agent.mcs.yml` must equal
   - `<agent_schema_name>` in `settings.mcs.yml` must equal
   - `<AGENT_SCHEMA>` in `Fallback.topic.mcs.yml`
   - Use Find & Replace (Ctrl+H) to fix at once

3. **Still have `<PLACEHOLDER>` text?**
   - Search: Ctrl+Shift+F, search `<`
   - Should find 0 results

---

### Q: "Apply Changes" doesn't appear as an option. What do I do?

**A:**
1. Open Extensions (Ctrl+Shift+X)
2. Search "Copilot Studio" (by Microsoft)
3. Click **Install**
4. Reload VS Code: Ctrl+Shift+P → "Developer: Reload Window"
5. Try again

---

### Q: I deployed but the agent doesn't show up in Copilot Studio.

**A:**
1. Refresh the page (Ctrl+R)
2. Check correct environment (top right dropdown)
3. List agents: Terminal → `pac copilot list`
4. If not there, check VS Code Output panel for errors

---

## 🆘 Troubleshooting

### Q: Which guide should I read for my situation?

**A:** Use the decision tree:

1. **Is this your first time?** → [DEVELOPER-SETUP-GUIDE.md](docs/DEVELOPER-SETUP-GUIDE.md)
2. **Are you copying templates?** → [COPY-AND-SETUP-TEMPLATES.md](docs/COPY-AND-SETUP-TEMPLATES.md)
3. **Are you using skills?** → [SKILLS-QUICK-REFERENCE.md](docs/SKILLS-QUICK-REFERENCE.md)
4. **Is something broken?** → [troubleshooting/README.md](troubleshooting/README.md)
5. **Are you lost?** → [DOCUMENTATION-MAP.md](docs/DOCUMENTATION-MAP.md)

---

### Q: Where do I find commands?

**A:** See: [VERIFIED-COMMANDS.md](docs/VERIFIED-COMMANDS.md)

All commands tested and verified to work.

---

## 📞 Still Need Help?

| Need | Where |
|------|-------|
| Setup help | [DEVELOPER-SETUP-GUIDE.md](docs/DEVELOPER-SETUP-GUIDE.md) |
| Command reference | [VERIFIED-COMMANDS.md](docs/VERIFIED-COMMANDS.md) |
| Skill help | [SKILLS-QUICK-REFERENCE.md](docs/SKILLS-QUICK-REFERENCE.md) |
| Design patterns | [recipes/](recipes/) |
| Errors & fixes | [troubleshooting/README.md](troubleshooting/README.md) |
| Navigation | [DOCUMENTATION-MAP.md](docs/DOCUMENTATION-MAP.md) |

---

**Happy building! 🚀**
