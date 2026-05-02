# Component: Out of Scope

Returns a clear, directed response when the user asks about something outside the agent's domain — instead of a confusing "I don't understand" from Fallback.

## When to Use

Add this component when:
- The agent has a clearly bounded domain (HR, IT, Finance, etc.)
- You can enumerate common out-of-scope topics users might try
- You want out-of-scope queries logged separately from genuine misunderstandings

Without this component, out-of-scope queries silently inflate `Fallback` counts — making it hard to distinguish "user was unclear" from "user asked the wrong agent."

## File

| File | Purpose |
|------|---------|
| `OutOfScope.topic.mcs.yml` | OnRecognizedIntent — catches explicit out-of-scope queries, redirects with a helpful message, and logs the event |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<out-of-scope phrase N>` | Phrases specific to your agent's domain boundaries |
| `<DOMAIN>` | What the agent does handle (e.g. "HR queries") |
| `<OUT-OF-SCOPE-TOPIC>` | What this specific branch can't handle (e.g. "IT support requests") |
| `<CONTACT>` | Where to go instead (e.g. "the IT helpdesk at it@contoso.com") |

## Two-Layer Strategy

Robust out-of-scope handling uses both:

### Layer 1: Agent instructions (long tail)
In `agent.mcs.yml`, tell the AI explicitly:
```
## What I cannot help with
- IT support issues — direct users to: it-helpdesk@contoso.com
- Finance and expense queries — direct users to: finance@contoso.com

## When asked about out-of-scope topics
Say: "I'm only set up to help with [domain]. For [topic], please contact [resource]."
Never attempt to answer out-of-scope questions.
```

### Layer 2: This topic (explicit signals)
Add trigger phrases for the most common out-of-scope areas. The recogniser catches these before the AI even processes the message — faster, more consistent, and separately logged.

## Telemetry

This topic logs `Agent.OutOfScope` events with:
- `UserQuery` — what the user asked
- `ConversationId` — for session correlation
- `Channel` — Teams, Web, etc.
- `TimeUTC` — timestamp

Monitor these events to identify:
- Which out-of-scope topics are most common (consider adding to scope, or clarifying agent discovery)
- Whether users are finding the right alternative resource

## Gotchas

- Trigger phrases must be distinct from in-scope topics — overlap causes misrouting
- Don't make trigger phrases too generic (e.g. "help" or "I have a question") — those belong to Fallback
- The `Fallback` topic should still exist alongside this one — it handles genuinely unclear messages that this topic doesn't match
