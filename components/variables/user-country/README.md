# UserCountry Variable

**Variable:** `Global.UserCountry`
**Type:** `String`
**AI visibility:** `UseInAIContext` — the AI can reference this value in responses

Stores the authenticated user's M365 country. Loaded once at conversation start by the `conversation-init` topic. Use for country-aware responses (e.g., different HR policies by region).

## Files

| File | Purpose |
|------|---------|
| `UserCountry.variable.mcs.yml` | Variable declaration with `UseInAIContext` visibility |

## Usage in agent instructions

```
## Current context
User country: {Global.UserCountry}
```

→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
