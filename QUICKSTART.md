# Quickstart — Working Agent in Under 1 Hour

Pick your agent type. Follow the steps. Deploy.

**Prerequisites before you start:**
1. `pac` CLI installed → `dotnet tool install --global Microsoft.PowerApps.CLI.Tool`
2. Authenticated to your Dev environment → `pac auth create --environment https://<dev>.crm.dynamics.com`
3. This repo cloned and a feature branch created → `git checkout -b feature/<your-agent>`
4. VS Code with Power Platform extension active (Copilot Studio icon in status bar)

Not done yet? → [`ENGINEERING-PLAYBOOK.md`](ENGINEERING-PLAYBOOK.md) Stage 1 walks every step.

---

## Step 1 — Pick your agent type

| I want to build… | Use recipe | Time | Claude skill |
|---|---|---|---|
| FAQ / knowledge bot — answers questions from SharePoint | [`01-basic-faq`](recipes/01-basic-faq.md) | 30 min | `/copilot-studio:add-knowledge` |
| Same, but users must sign in + greeted by name | [`02-authenticated-agent`](recipes/02-authenticated-agent.md) | 45 min | `/copilot-studio:new-topic` |
| Agent that submits data to a system (tickets, requests) | [`03-connector-action-agent`](recipes/03-connector-action-agent.md) | 60 min | `/copilot-studio:add-action` |
| Agent that calls an MCP tool | [`04-mcp-action-agent`](recipes/04-mcp-action-agent.md) | 60 min | `/copilot-studio:add-action` |
| Orchestrator with specialist child agents | [`05-orchestrator-agent`](recipes/05-orchestrator-agent.md) | 2+ hrs | `/copilot-studio:new-topic` |
| All of the above combined | [`06-full-featured-agent`](recipes/06-full-featured-agent.md) | 2+ hrs | All skills |

---

## Step 2 — Build it

Choose how you're working:

---

### Path A — Using Claude skills (fastest)

```
1. Load context from meetings / emails
   → /workiq  "What was discussed about the [agent] requirements?"

2. Start a new agent
   → /copilot-studio:detect-mode
   → /copilot-studio:clone-agent

3. Add knowledge or actions
   → /copilot-studio:add-knowledge     (for FAQ agents)
   → /copilot-studio:add-action        (for action agents)

4. Validate before pushing
   → /copilot-studio:validate

5. Deploy
   → /copilot-studio:manage-agent

6. Test immediately — no publishing needed
   → /copilot-studio:chat-with-agent
```

---

### Path B — Manual (copy and replace)

**Prerequisites:** `pac` CLI installed, authenticated to your environment.

```bash
# Authenticate first (run once)
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID> \
  --environment <ENV_URL>
```

**1. Copy the base**
```bash
cp -r base/ agents/<your-agent-name>/
```

**2. Replace the 5 required values**

Open each file and replace:

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | your schema name, e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | your display name, e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | your agent's purpose (2–3 sentences) |
| `settings.mcs.yml` | `<agent_schema_name>` | same schema name as above |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same schema name as above |

**3. Replace all `_REPLACE` node IDs with unique strings**

Run this from inside your agent folder:

```bash
# macOS / Linux
for f in $(find . -name "*.yml"); do
  while grep -q '_REPLACE' "$f"; do
    id=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c6)
    sed -i "s/_REPLACE/$id/" "$f"
  done
done

# Windows PowerShell
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = $content -replace '_REPLACE\d*', "_$id", 1
  }
  Set-Content $_.FullName $content
}
```

**4. Add your recipe components**

Each recipe's README has a one-line copy command per component. Example for FAQ:
```bash
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/<your-agent>/topics/
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/<your-agent>/knowledge/
```
Then fill in the SharePoint URL in the knowledge file.

**5. Push to Copilot Studio**
```bash
cd agents/<your-agent-name>
pac copilot push --environment <ENV_URL>
```

**6. Test in Copilot Studio**
Open Copilot Studio → find your agent → click **Test** → ask questions.

---

## Step 3 — Before you go live

Run these three checks — takes 15 minutes:

| Check | How |
|-------|-----|
| Routing accuracy ≥ 85% | `/copilot-studio:run-eval` or follow `project-delivery/05-eval-scenarios.md` |
| No YAML errors | `/copilot-studio:validate` or `pac copilot push` (errors appear in output) |
| Responsible AI review | `governance/ai-ethics-checklist.md` — tick every box |

Then: `launch/launch-checklist.md` — complete all items → publish.

---

## What's in each file you just edited

| File | What it controls |
|------|----------------|
| `agent.mcs.yml` | Agent name, instructions (system prompt), conversation starters, AI model, knowledge sources |
| `settings.mcs.yml` | Auth mode, language, recognizer, who can access the agent |
| `Greeting.topic.mcs.yml` | First message users see |
| `Fallback.topic.mcs.yml` | What happens when the agent doesn't understand — retries then escalates |
| `OnError.topic.mcs.yml` | What happens when the agent crashes — shows a safe message |

---

## Common issues in the first 30 minutes

| Problem | Fix |
|---------|-----|
| `pac copilot push` fails with schema error | Run `/copilot-studio:validate` or check for any remaining `<PLACEHOLDER>` values |
| Agent doesn't answer from SharePoint | Confirm the SharePoint URL in the knowledge file is accessible and indexed |
| `_REPLACE` still in YAML after the script | Run `grep -r '_REPLACE' .` to find remaining ones; replace manually |
| Agent appears in Copilot Studio but shows error | Check `OnError.topic.mcs.yml` — `<AGENT_SCHEMA>` must match your `schemaName` exactly |
| Teams channel not showing the agent | Agent must be **published** (not just pushed) via Copilot Studio → Publish |

Full troubleshooting: [`troubleshooting/README.md`](troubleshooting/README.md)

---

## Next steps after your first working agent

| What to add | File |
|---|---|
| CSAT feedback collection | Add `components/topics/feedback/` → call via `BeginDialog` at topic end |
| User sign-in + personalisation | Follow recipe 02 |
| Connector action (submit data) | Follow recipe 03 |
| Better routing accuracy | `project-delivery/05-eval-scenarios.md` |
| Full governance for enterprise rollout | `project-delivery/00-ai-decision-framework.md` → work through phases |
| All reusable components | `COMPONENT-REGISTRY.md` |
