# UserDisplayName Variable

**Variable:** `Global.UserDisplayName`
**Type:** `String`
**AI visibility:** `UseInAIContext` — the AI can reference this value in responses

Stores the authenticated user's M365 display name. Loaded once at conversation start by the `conversation-init` topic.

## Files

| File | Purpose |
|------|---------|
| `UserDisplayName.variable.mcs.yml` | Variable declaration with `UseInAIContext` visibility |

## Usage in agent instructions

```
## Current context
User: {Global.UserDisplayName}
```

→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
