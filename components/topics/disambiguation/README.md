# disambiguation — Disambiguation Topic

Fires when multiple topics match the user's message at similar confidence scores, and asks the user to choose rather than silently picking the wrong one.

## When to use

Add to any agent with **5 or more topics** or where topic trigger phrases overlap.

| Add disambiguation | Skip it |
|---|---|
| Multiple topics have similar trigger phrases | Single-topic agent |
| Users regularly hit the wrong topic by accident | Agent has well-separated, non-overlapping triggers |
| You want `Agent.DisambiguationTriggered` telemetry for monitoring | — |

## Quick start

```bash
cp components/topics/disambiguation/Disambiguation.topic.mcs.yml \
   agents/hr_assistant/topics/Disambiguation.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Placeholders

| Placeholder | Line | Example |
|---|---|---|
| `<AGENT_SCHEMA>` | 70 | `hr_assistant` |
| `_REPLACE1–8` | — | Run ID script |

## How it works

1. User sends a message that matches 2+ topics above the confidence threshold
2. System fires `OnSelectIntent` with `System.Recognizer.IntentOptions` populated
3. This topic generates a choice card listing the matched topic names
4. User picks one → conversation routes to the selected topic

No additional configuration — the topic reads matched intents automatically from `System.Recognizer.IntentOptions`.

## Before → after

```yaml
# Before
schemaName: <AGENT_SCHEMA>.topic.Disambiguation

# After
schemaName: hr_assistant.topic.Disambiguation
```

## Monitoring

High `Agent.DisambiguationTriggered` rates in App Insights mean trigger phrases are overlapping. Fix by making triggers more specific:

```
# Instead of these overlapping phrases:
Topic A: "leave", "time off", "days off"
Topic B: "leave balance", "check leave", "days remaining"

# Use distinct phrases:
Topic A: "leave policy", "annual leave rules", "how does leave work"
Topic B: "check leave balance", "how many days left", "remaining leave"
```

→ KQL query for disambiguation rates: [`../../../operations/02-monitoring-queries.md`](../../../operations/02-monitoring-queries.md)
