# Base Agent

The minimum viable Copilot Studio agent. **Copy this folder to start every new agent project.**

## What's Included

| File | Purpose |
|------|---------|
| `agent.mcs.yml` | Agent identity — display name, system prompt, conversation starters, AI model |
| `settings.mcs.yml` | Runtime config — auth mode, recognizer, language, access policy |
| `topics/Greeting.topic.mcs.yml` | Fires on conversation start; sends a welcome message |
| `topics/Fallback.topic.mcs.yml` | Fires on unmatched intent; retries 3× then escalates to human |
| `topics/OnError.topic.mcs.yml` | Fires on system errors; debug-friendly in test mode, safe in production |
| `topics/OutOfScope.topic.mcs.yml` | Fires on explicit out-of-domain phrases; returns a clear redirect instead of a fallback |

## Setup Steps

1. Copy this entire `base/` folder into your new agent project directory
2. **`agent.mcs.yml`** — replace `<AgentName>`, `<Agent Display Name>`, and update `instructions`
3. **`settings.mcs.yml`** — replace `<agent_schema_name>` and `<Agent Display Name>`; set `authenticationMode`
4. **All topic files** — replace every `_REPLACE` suffix with a unique random string (e.g. `_a1b2c3`)
5. **`Fallback.topic.mcs.yml`** — replace `<AGENT_SCHEMA>` with your agent's `schemaName`
6. **`OutOfScope.topic.mcs.yml`** — replace `<DOMAIN>`, `<OUT-OF-SCOPE-TOPIC>`, `<CONTACT>` and add domain-specific trigger phrases
7. Push to Copilot Studio using `pac copilot push` or the VS Code Copilot Studio extension

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

The VS Code Copilot Studio extension can auto-generate IDs for you.

## What to Add Next

Once the base is set up, see [`recipes/`](../recipes/) for recommended component combinations, or browse [`components/`](../components/) to add features one by one.
