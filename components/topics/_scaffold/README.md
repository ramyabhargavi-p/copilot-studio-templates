# Topic Scaffold

**Start every new topic here.** Built-in error handling, telemetry, and CSAT — nothing to add by hand.

## What's included

| Section | What it does | Remove when… |
|---------|-------------|--------------|
| `1. TELEMETRY: TOPIC START` | Logs `Topic.Started` to App Insights | Never |
| `2. MAIN LOGIC` | Your topic content — Option A (response) or B (action call) | Replace with your logic |
| `3. ERROR HANDLING` | Validates action response; logs `Topic.ErrorOccurred` on failure | You chose Option A (no action) |
| `4. CSAT FEEDBACK` | Thumbs → rating → text, once per conversation | Sub-topics and utility dialogs |

## Quick start

```bash
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/<TopicName>.topic.mcs.yml
```

Then:
1. Replace `<SCHEMA>` with your `schemaName`
2. Replace `<TOPIC_NAME>` with the display name
3. Add trigger phrases
4. Pick Option A or B in the MAIN LOGIC section
5. Run the `_REPLACE` script

## When to use Option A vs B

| Scenario | Option |
|---------|--------|
| Answer a question / show policy / explain a process | A — SendActivity |
| Look up data, submit a form, call a connector | B — Question → BeginDialog → action |

## Telemetry events fired

| Event | When |
|-------|------|
| `Topic.Started` | Always, at trigger |
| `Topic.Completed` | On successful action response (Option B only) |
| `Topic.ErrorOccurred` | When action returns empty/null (Option B only) |
| `Feedback.Thumbs` / `Feedback.Rating` / `Feedback.Text` | Via Feedback topic at end |

→ KQL queries for these events: [`operations/monitoring-queries.md`](../../../operations/monitoring-queries.md)
