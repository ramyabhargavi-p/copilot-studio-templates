# Component: Global Variable

Declares a conversation-scoped variable that is accessible across all topics in the agent.

## When to Use

Add a global variable when:
- State needs to be shared between multiple topics (e.g. signed-in user's country, locale, or role)
- A value is loaded once (e.g. in `conversation-init`) and read many times throughout the session
- The AI needs to be aware of the variable's value to make decisions

Use **topic variables** (`Topic.MyVar`) when the value is only needed within a single topic.

## File

| File | Purpose |
|------|---------|
| `global-variable.variable.mcs.yml` | GlobalVariableComponent declaration |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE_DISPLAY_NAME` | Friendly name shown in Copilot Studio (e.g. `User Country`) |
| `_REPLACE_NAME` | camelCase variable name, no spaces (e.g. `userCountry`) |
| `_REPLACE_DESCRIPTION` | One sentence describing what this variable stores |
| `_REPLACE_SCHEMA_PREFIX` | Your agent's `schemaName` from `settings.mcs.yml` |
| `defaultValue` | The initial value before any topic sets it |

## `aIVisibility`

| Value | Behaviour |
|-------|-----------|
| `UseInAIContext` | The AI model can read this variable and use it in its responses (e.g. to personalise answers by country) |
| `Hidden` | The variable exists but the AI cannot see it — use for sensitive values like auth tokens or internal flags |

## Common Global Variables

| Variable | Name | Type | AI Visibility |
|----------|------|------|--------------|
| User's display name | `userDisplayName` | String | `UseInAIContext` |
| User's country | `userCountry` | String | `UseInAIContext` |
| User's preferred language | `userLocale` | String | `UseInAIContext` |
| Domain glossary | `glossary` | String | `UseInAIContext` |
| Auth token (sensitive) | `authToken` | String | `Hidden` |
| User role / permissions flag | `userRole` | String | `Hidden` |

## One File Per Variable

Create one `.variable.mcs.yml` file per global variable. Do not combine multiple variables into one file.

## Gotchas

- `scope: Conversation` is the only valid value for global variables — it means the variable resets at the end of each conversation
- `schemaName` must follow the pattern `<agentSchemaName>.globalvariable.<variableName>` exactly
- Global variables must be declared before they can be used in topics — always add the variable file before referencing it in topic YAML
