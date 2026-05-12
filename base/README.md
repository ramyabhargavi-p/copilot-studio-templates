# Base Agent Template — Start Here

The **minimum viable Copilot Studio agent**. Copy this entire folder to create a new agent project.

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
- `<SYSTEM_PROMPT>` → the agent's instructions block — choose one path:

**Option A — Use a ready-made persona (5 min, fastest):**
```
1. Open prompts/system-prompts/<type>.md
   (hr-assistant, it-helpdesk, customer-support, or knowledge-base)
2. Copy the full text inside the triple backticks
3. Paste it into agent.mcs.yml, replacing the entire instructions: | block
4. Replace every [BRACKET] value (e.g. [Company Name], [company].com) with real values
```

**Option B — Generate a custom prompt with Claude (10 min, recommended for real projects):**
```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template block
3. Paste into Claude (this session or claude.ai); fill in:
   - Project brief: what the agent does, who uses it, what it must NOT handle
   - Agent name, primary users, authentication mode, tone
4. Claude returns a ready-to-paste instructions: | block — copy it into agent.mcs.yml
```

→ Full prompt guide: [`prompts/README.md`](../prompts/README.md)

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

## Key Decisions

### `authenticationMode`

| Value | Meaning |
|-------|---------|
| `None` | Anonymous — no user identity; suitable for public-facing or Teams-embedded agents without personalisation |
| `ManualAzureAD` | Users sign in explicitly; add the [`auth` component](../components/topics/auth/) |
| `IntegratedAzureAD` | Silent SSO via Teams / M365; user identity auto-available in `System.User.*` |

### `schemaName`

Every component in the agent uses this as its prefix. If `schemaName` is `hr_assistant`, the greeting topic's full ID is `hr_assistant.topic.Greeting`. Keep it:
- lowercase
- underscores instead of spaces
- short (≤ 30 chars)

### `GenerativeActionsEnabled`

| Value | Behaviour |
|-------|-----------|
| `false` *(default)* | AI only invokes actions when an explicit topic is triggered |
| `true` | AI automatically selects and invokes actions based on conversation context — useful for highly dynamic agents |

### Node IDs (`_REPLACE` suffix)

Every YAML node has an `id` field. IDs must be **unique within the entire agent**. Replace `_REPLACE` (and numbered variants like `_REPLACE1`) with a short random alphanumeric string. A 6-character string is sufficient (e.g. `_a1b2c3`).

Run the PowerShell/bash script in [QUICKSTART.md → Step 4 — Replace node IDs](../docs/QUICKSTART.md#step-4--replace-node-ids) to replace all `_REPLACE` IDs and `<PLACEHOLDER>` values in one pass.

### `template:` field

After you clone an agent, Copilot Studio adds a `template:` line to `settings.mcs.yml` (e.g. `template: kickStartTemplate-1.0.0`). This is auto-generated metadata — leave it in place. The `base/settings.mcs.yml` intentionally omits it; it is not a value you set manually.

## What to Add Next

Once the base is set up, see [`recipes/`](../recipes/) for recommended component combinations, or browse [`components/`](../components/) to add features one by one.
