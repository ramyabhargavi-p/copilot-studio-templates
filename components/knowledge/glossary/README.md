# Glossary Knowledge Source

**Source type:** Dataverse (CSV upload)

On-demand acronym and term glossary. Unlike other knowledge sources, this one is loaded explicitly by the `conversation-init` topic rather than queried automatically on every unknown intent.

## Files

| File | Purpose |
|------|---------|
| `glossary.knowledge.mcs.yml` | Template — `triggerCondition: false`, loaded via `conversation-init` |

## How it works

1. Upload your glossary as a `.txt` file to Dataverse (one term per line: `TERM: Definition`)
2. Configure this knowledge source with `triggerCondition: false` — it won't fire automatically
3. `conversation-init` loads the glossary into `Global.Glossary`
4. The agent instructions reference `{Global.Glossary}` to inject the glossary into context

## Quick start

```bash
cp components/knowledge/glossary/glossary.knowledge.mcs.yml \
   agents/<your-agent>/knowledge/glossary.knowledge.mcs.yml
```

**Constraint:** Dataverse storage only (not SharePoint or public URL) for this pattern.

→ How `Global.Glossary` is loaded: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
→ Variable definition: [`../../variables/glossary-var/README.md`](../../variables/glossary-var/README.md)
