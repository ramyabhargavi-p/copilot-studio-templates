# conversation-init — Conversation Init Topic

Loads the authenticated user's M365 profile into global variables on the first message of every conversation. Required for any agent that personalises responses by name or location.

## When to use

Add this topic to every **authenticated agent** that uses `{Global.UserDisplayName}` or `{Global.UserCountry}` in its system prompt or topics.

| Add conversation-init | Skip it |
|---|---|
| Agent uses `{Global.UserDisplayName}` in instructions | Anonymous agents — no signed-in user |
| Agent gives country-specific answers (HR policies, local holidays) | Agent doesn't need personalisation |
| Agent uses the glossary knowledge source | — |

## What it loads

| Variable | Source | Fallback |
|---|---|---|
| `Global.UserDisplayName` | Office 365 Users `UserGet_V2` → `displayName` | `"there"` (if blank in Azure AD) |
| `Global.UserCountry` | Office 365 Users `UserGet_V2` → `country` | `"Unknown"` (if blank in Azure AD) |
| `Global.Glossary` | `SearchAndSummarizeContent` against glossary knowledge source | `""` (if no glossary source) |

## Quick start

```bash
# Topic
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml \
   agents/hr_assistant/topics/ConversationInit.topic.mcs.yml

# Variable declarations (needed for VS Code IntelliSense)
cp components/variables/user-display-name/UserDisplayName.variable.mcs.yml \
   agents/hr_assistant/variables/UserDisplayName.variable.mcs.yml
cp components/variables/user-country/UserCountry.variable.mcs.yml \
   agents/hr_assistant/variables/UserCountry.variable.mcs.yml
```

Then run the `_REPLACE` ID script — see [QUICKSTART.md](../../../docs/QUICKSTART.md) → Replace node IDs.

## Placeholders

| Placeholder | Where | Example |
|---|---|---|
| `<AGENT-SCHEMA-NAME>` | `schemaName` field and description metadata | `hr_assistant` |
| `_REPLACE1–13` | Node IDs throughout | Run ID script |

Note: uses `<AGENT-SCHEMA-NAME>` with **hyphens** — different from other components that use `<AGENT_SCHEMA>` with underscores. Same value, different format.

## Before → after

```yaml
# ConversationInit.topic.mcs.yml — before
schemaName: <AGENT-SCHEMA-NAME>.topic.ConversationInit

# After
schemaName: hr_assistant.topic.ConversationInit
```

## Prerequisites checklist

- [ ] `authenticationMode: Integrated` or `ManualAzureAD` in `settings.mcs.yml`
- [ ] Office 365 Users connector connection exists in the Power Platform environment
- [ ] Connection has `User.Read` scope
- [ ] If using glossary: glossary knowledge source exists in `agents/<schema>/knowledge/`

## Variable file warning

> **Apply Changes limitation:** If pushing variable files causes `[0x800608ad:ExportKeyAttributeInvalidPrefix]`:
> 1. Delete the `.variable.mcs.yml` files from your `variables/` folder
> 2. Run Apply Changes to push the topic first
> 3. Re-add the variable files and run Apply Changes again
>
> Variable declarations exist for VS Code IntelliSense only. The agent populates variables at runtime via `SetVariable` — the declaration files are optional.

## Common mistakes

- **Adding without authentication configured** — the Office 365 Users connector call returns null; `UserDisplayName` stays blank
- **Using `{Global.UserDisplayName}` in instructions before variable files are declared** — VS Code shows `IdentifierNotRecognized`; use `[Global.UserDisplayName]` (square brackets) as a temporary workaround
- **Skipping glossary variable** when using the glossary knowledge source — `{Global.Glossary}` in instructions will reference an undeclared variable

## How to use variables in the system prompt

Once this topic is in your agent:

```yaml
# In agent.mcs.yml instructions block:
User: {Global.UserDisplayName}
Country: {Global.UserCountry}
When the user asks a location-specific question (e.g., notice period, local holidays),
use the country above to search knowledge sources and interpret answers in the correct context.
```

→ Variable declaration files: [`../../variables/user-display-name/README.md`](../../variables/user-display-name/README.md)
→ Glossary setup: [`../../knowledge/glossary/README.md`](../../knowledge/glossary/README.md)
