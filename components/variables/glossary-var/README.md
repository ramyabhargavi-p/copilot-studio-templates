# Glossary Variable

**Variable:** `Global.Glossary`
**Type:** `String`
**AI visibility:** `Hidden` — injected into the system prompt via instructions, not surfaced directly to the AI

Holds the customer-specific acronym glossary as a comma-separated string, loaded from Dataverse once at conversation start. The AI uses it to silently expand acronyms (PTO, WFH, L&D) before interpreting user messages or searching knowledge sources.

## When to add

Add this variable when using the **glossary knowledge source**.

| Add Glossary variable | Skip it |
|---|---|
| Agent must interpret domain acronyms (PTO, WFH, SLA, etc.) | No domain acronyms in use |
| Glossary knowledge source exists in `knowledge/` | — |
| `{Global.Glossary}` is in `agent.mcs.yml` instructions | — |

All three — variable file + knowledge source + `conversation-init` topic — must be present together.

## Quick start

```bash
cp components/variables/glossary-var/Glossary.variable.mcs.yml \
   agents/hr_assistant/variables/Glossary.variable.mcs.yml
```

## Placeholder

| Placeholder | Line | Example |
|---|---|---|
| `<AGENT-SCHEMA-NAME>` | `schemaName` | `hr_assistant` |

## Before → after

```yaml
# Before
schemaName: <AGENT-SCHEMA-NAME>.globalvariable.Glossary

# After
schemaName: hr_assistant.globalvariable.Glossary
```

Note: the prefix is `.globalvariable.` — not `.variable.`.

## Apply Changes limitation

> If pushing this file causes `[0x800608ad:ExportKeyAttributeInvalidPrefix]`:
> 1. Delete this file from your agent's `variables/` folder
> 2. Run Apply Changes to push topics and settings first
> 3. Re-add this file and run Apply Changes again

## Usage in agent instructions

```yaml
instructions: |
  ## Glossary
  {Global.Glossary}
  The above is the customer glossary (format: ACRONYM,Definition, one per line).
  Silently expand any acronym found in it before interpreting the user's message.
  Do not mention the glossary to the user unless they explicitly ask for a list of acronyms.
```

## Glossary data format

Data is stored in Dataverse (not in YAML) as `ACRONYM,Definition` rows:
```
PTO,Paid Time Off
WFH,Work From Home
L&D,Learning and Development
SLA,Service Level Agreement
```

The `conversation-init` topic loads these rows into `Global.Glossary` as a newline-separated string on the first turn.

→ Glossary knowledge source: [`../../knowledge/glossary/README.md`](../../knowledge/glossary/README.md)
→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
