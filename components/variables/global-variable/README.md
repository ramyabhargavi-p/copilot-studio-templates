# Global Variable Template

Generic template for declaring any conversation-scoped global variable. Copy once per variable your agent needs to share across topics.

## When to use

Use a global variable when a value is **set once and read by multiple topics** in the same conversation.

| Use global variable | Use topic variable instead |
|---|---|
| User tier / plan loaded at conversation start, read by 5 topics | Value used only within a single topic |
| Authentication flag (`Global.IsAuthenticated`) checked in all topics | Intermediate calculation result |
| Any value referenced in the system prompt via `{Global.VarName}` | — |

## Quick start

```bash
cp components/variables/global-variable/global-variable.variable.mcs.yml \
   agents/hr_assistant/variables/TicketNumber.variable.mcs.yml
```

Open in VS Code. Replace the two placeholders.

## Placeholders

| Placeholder | Example |
|---|---|
| `_REPLACE_NAME` | `TicketNumber` (becomes the variable name) |
| `_REPLACE_SCHEMA_PREFIX` | `hr_assistant` (your `schemaName`) |

## Before → after

```yaml
# Before
schemaName: _REPLACE_SCHEMA_PREFIX.globalvariable._REPLACE_NAME
displayName: _REPLACE_NAME
variable:
  name: _REPLACE_NAME

# After
schemaName: hr_assistant.globalvariable.TicketNumber
displayName: TicketNumber
variable:
  name: TicketNumber
```

Note: the prefix is `.globalvariable.` — not `.variable.`.

## AI visibility options

| Value | When to use |
|---|---|
| `UseInAIContext` | AI should reference this value in responses (e.g., user name, user tier) |
| `Hidden` | Value is injected into instructions via `{Global.VarName}` but AI should not reference it directly (e.g., glossary, internal flags) |

## Apply Changes limitation

> If pushing this file causes `[0x800608ad:ExportKeyAttributeInvalidPrefix]`:
> 1. Delete this file from your agent's `variables/` folder
> 2. Run Apply Changes to push topics and settings first
> 3. Re-add this file and run Apply Changes again
>
> Global variables are created at runtime by `SetVariable` — the declaration file exists for VS Code IntelliSense only.

## Example — session flag to track authentication

```yaml
# agents/hr_assistant/variables/IsAuthenticated.variable.mcs.yml
schemaName: hr_assistant.globalvariable.IsAuthenticated
displayName: IsAuthenticated
variable:
  name: IsAuthenticated
  aIVisibility: Hidden
  scope: Conversation
  defaultValue: false
  type: Boolean
```

→ Pre-built variables for M365 profile: [`../user-display-name/README.md`](../user-display-name/README.md)
→ Variables parent guide: [`../README.md`](../README.md)
