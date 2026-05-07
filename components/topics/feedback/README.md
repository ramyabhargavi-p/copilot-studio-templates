# Feedback Topic

**Trigger:** `OnRecognizedIntent` ("give feedback", "rate this") or `BeginDialog` (called from other topics)
**Telemetry:** `Feedback.Thumbs`, `Feedback.Rating`, `Feedback.Text`

Three-step CSAT sequence: thumbs up/down → 1–5 star rating → free text comment. Fires once per conversation (guarded by a session flag).

## Files

| File | Purpose |
|------|---------|
| `Feedback.topic.mcs.yml` | Full CSAT flow using the three feedback adaptive cards |

## Quick start

```bash
cp components/topics/feedback/Feedback.topic.mcs.yml \
   agents/<your-agent>/topics/Feedback.topic.mcs.yml
```

The scaffold topic (`_scaffold/`) already includes a `BeginDialog` call to this topic at the end of every topic — no additional wiring needed when you use the scaffold.

→ Card templates used: [`../../adaptive-cards/README.md`](../../adaptive-cards/README.md)
→ KQL query for CSAT data: [`../../../operations/monitoring-queries.md`](../../../operations/monitoring-queries.md)
