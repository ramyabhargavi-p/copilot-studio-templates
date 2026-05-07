# Conversation Init Topic

**Trigger:** `OnActivity` (fires on the first message of every conversation)
**Telemetry:** `ConversationInit.Completed`, `ConversationInit.ProfileLoadFailed`

Loads the authenticated user's M365 profile into global variables at the start of every conversation. Must run before any topic that uses `Global.UserDisplayName` or `Global.UserCountry`.

## Files

| File | Purpose |
|------|---------|
| `ConversationInit.topic.mcs.yml` | Loads user profile via Office365Users connector |

## What it loads

| Variable | Source | Used for |
|----------|--------|---------|
| `Global.UserDisplayName` | Office 365 Users connector (`UserGet_V2` operation) → `displayName` | Personalised responses |
| `Global.UserCountry` | Office 365 Users connector (`UserGet_V2` operation) → `country` | Country-aware answers |
| `Global.Glossary` | `SearchAndSummarizeContent` against `*.knowledge.glossary` knowledge source | Acronym injection into instructions |

## Quick start

```bash
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml \
   agents/<your-agent>/topics/ConversationInit.topic.mcs.yml
```

**Requires:** Office365Users connection with `User.Read` scope and `authenticationMode` set to `IntegratedAzureAD` or `ManualAzureAD`.

→ Variable definitions: [`../../variables/user-display-name/README.md`](../../variables/user-display-name/README.md)
