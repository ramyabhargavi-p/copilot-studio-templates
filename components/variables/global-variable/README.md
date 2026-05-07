# Global Variable Template

Generic template for declaring a conversation-scoped global variable. Copy once per variable your agent needs.

## Files

| File | Purpose |
|------|---------|
| `global-variable.variable.mcs.yml` | Template — configure name, type, and AI visibility |

## Quick start

```bash
cp components/variables/global-variable/global-variable.variable.mcs.yml \
   agents/<your-agent>/variables/<VariableName>.variable.mcs.yml
```

Configure:
- `variableName` — the variable name (e.g., `Global.UserTier`)
- `type` — `String`, `Boolean`, `Number`, or `Table`
- `aIVisibility` — `UseInAIContext` (AI can read it) or `Hidden` (injected via instructions only)

→ Built-in variable examples: [`../user-display-name/README.md`](../user-display-name/README.md)
