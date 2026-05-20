# UserCountry Variable

**Variable:** `Global.UserCountry`
**Type:** `String`
**AI visibility:** `UseInAIContext` — the AI can reference this value in responses

Stores the authenticated user's M365 country. Loaded once at conversation start by the `conversation-init` topic. Enables the agent to give country-specific answers (e.g., different leave entitlements, local public holidays, notice periods) without asking the user their location.

## When to add

Add alongside `UserDisplayName` and `conversation-init` — all three are typically added together.

| Add UserCountry | Skip it |
|---|---|
| Agent answers differ by country (HR policies, compliance, local holidays) | Agent gives the same answer to all users regardless of location |
| `{Global.UserCountry}` is referenced in `agent.mcs.yml` instructions | Anonymous agent (no authenticated user) |

## Quick start

```bash
cp components/variables/user-country/UserCountry.variable.mcs.yml \
   agents/hr_assistant/variables/UserCountry.variable.mcs.yml
```

## Placeholder

| Placeholder | Line | Example |
|---|---|---|
| `<AGENT-SCHEMA-NAME>` | `schemaName` | `hr_assistant` |

## Before → after

```yaml
# Before
schemaName: <AGENT-SCHEMA-NAME>.globalvariable.UserCountry

# After
schemaName: hr_assistant.globalvariable.UserCountry
```

Note: the prefix is `.globalvariable.` — not `.variable.`.

## Apply Changes limitation

> **Apply Changes export error?** See [Known issue — Apply Changes export error](../README.md#known-issue--apply-changes-export-error) in the variables README.

## Usage in agent instructions

```yaml
instructions: |
  Country: {Global.UserCountry}
  When a user's question depends on their location (e.g. WFH policy, local holidays, notice period),
  use the country above to search knowledge sources or interpret answers in the correct country context.
  Do not ask the user for their country — it is already known.
  If the country is "Unknown", answer with the general policy and note that it may vary by country.
```

## Fallback behaviour

If the user's M365 profile has no country set, `Global.UserCountry` is set to `"Unknown"` by the `conversation-init` topic. The instructions block above handles this case.

→ Loaded by: [`../../topics/conversation-init/README.md`](../../topics/conversation-init/README.md)
→ Paired with: [`../user-display-name/README.md`](../user-display-name/README.md)
