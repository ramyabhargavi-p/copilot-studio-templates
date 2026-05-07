# Glossary Variable

**Variable:** `Global.Glossary`
**Type:** `String`
**AI visibility:** `Hidden` — injected into the system prompt via instructions, not surfaced directly to the AI

Stores the customer-specific acronym glossary loaded from Dataverse. Injected into the agent's instructions block so the AI can resolve acronyms without querying the knowledge source on every message.

## Files

| File | Purpose |
|------|---------|
| `Glossary.variable.mcs.yml` | Variable declaration with `Hidden` AI visibility |

## Usage in agent instructions

```
## Glossary
{Global.Glossary}
```

Remove this block from `agent.mcs.yml` instructions if your agent does not use the glossary knowledge source.

→ Glossary knowledge source: [`../../knowledge/glossary/README.md`](../../knowledge/glossary/README.md)
→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
