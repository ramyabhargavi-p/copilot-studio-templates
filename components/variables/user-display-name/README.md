# UserDisplayName Variable

**Variable:** `Global.UserDisplayName`
**Type:** `String`
**AI visibility:** `UseInAIContext` — the AI can reference this value in responses

Stores the authenticated user's M365 display name. Loaded once at conversation start by the `conversation-init` topic. Lets the agent address the user by name without asking.

## When to add

Add this variable file and the `conversation-init` topic together — they are paired.

| Add UserDisplayName | Skip it |
|---|---|
| `{Global.UserDisplayName}` is referenced in `agent.mcs.yml` instructions | Anonymous agent (no authenticated user) |
| Topics personalise responses using the user's name | Agent doesn't need personalisation |

## Quick start

```bash
cp components/variables/user-display-name/UserDisplayName.variable.mcs.yml \
   agents/hr_assistant/variables/UserDisplayName.variable.mcs.yml
```

## Placeholder

| Placeholder | Line | Example |
|---|---|---|
| `<AGENT-SCHEMA-NAME>` | `schemaName` | `hr_assistant` |

## Before → after

```yaml
# Before
schemaName: <AGENT-SCHEMA-NAME>.globalvariable.UserDisplayName

# After
schemaName: hr_assistant.globalvariable.UserDisplayName
```

Note: the prefix is `.globalvariable.` — not `.variable.`.

## Apply Changes limitation

> If pushing this file causes `[0x800608ad:ExportKeyAttributeInvalidPrefix]`:
> 1. Delete this file from your agent's `variables/` folder
> 2. Run Apply Changes to push topics and settings first
> 3. Re-add this file and run Apply Changes again
>
> The declaration exists for VS Code IntelliSense only. The `conversation-init` topic populates `Global.UserDisplayName` at runtime via `SetVariable` — the declaration file is optional.

## Usage in agent instructions

```yaml
instructions: |
  User: {Global.UserDisplayName}
  When the user asks a question, address them by their first name where natural.
```

→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
→ Paired with: [`../user-country/README.md`](../user-country/README.md)
