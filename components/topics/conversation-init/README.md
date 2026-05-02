# Component: Conversation Init

Loads user context once at the start of each conversation — before any topic logic runs.

## When to Use

Add this component when:
- You need the user's M365 profile (country, job title, department) available throughout the conversation
- You want to load a domain-specific glossary into the AI's context at the start of each session
- You need to pre-populate global variables on the first user message

## File

| File | Purpose |
|------|---------|
| `ConversationInit.topic.mcs.yml` | OnActivity (first message only) — loads M365 profile and/or glossary |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<AGENT-SCHEMA-NAME>` | Your agent's `schemaName` from `settings.mcs.yml` (e.g. `hr_assistant`) |

## Prerequisites

### For the M365 Profile block
- Add the **Office 365 Users** connector to the agent (`shared_office365users`)
- Declare `Global.UserCountry` and `Global.UserDisplayName` as global variables (see [`global-variable`](../../variables/global-variable/))
- Agent must use `ManualAzureAD` or `IntegratedAzureAD` auth so a user identity exists

### For the Glossary block
- A knowledge source named `<schemaName>.knowledge.glossary` must be added to the agent
- Declare `Global.Glossary` as a global variable

## Customisation

Remove either block (M365 Profile or Glossary) if you don't need it. The template is intentionally two separate blocks so you can keep just one.

You can add other initialisation steps here — e.g., loading feature flags, checking user roles, setting a locale variable from `Topic.M365Profile.preferredLanguage`.

## How the Guard Condition Works

```yaml
condition: =IsBlank(Global.UserCountry)
```

This ensures the topic only runs once per conversation. On every subsequent message, `Global.UserCountry` is already set, so the topic is skipped. Adjust the guard variable if you remove the M365 Profile block.

## Gotchas

- This topic fires on `OnActivity` (type: Message), which means it competes with other topics. The guard condition ensures it only runs once
- If the Office 365 Users API call fails, `Global.UserCountry` remains blank — the topic will retry on the next message. Add error handling if this causes issues in your agent
