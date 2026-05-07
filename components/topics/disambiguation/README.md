# Disambiguation Topic

**Trigger:** `OnSelectIntent`
**Telemetry:** `Agent.DisambiguationTriggered`

Fires when the recognizer finds multiple topics with similar confidence scores. Presents the top candidates as a choice card so the user can clarify their intent.

## Files

| File | Purpose |
|------|---------|
| `Disambiguation.topic.mcs.yml` | Choice card + `Agent.DisambiguationTriggered` telemetry |

## Quick start

```bash
cp components/topics/disambiguation/Disambiguation.topic.mcs.yml \
   agents/<your-agent>/topics/Disambiguation.topic.mcs.yml
```

No configuration required — the topic reads the competing intents from the system and generates the choice list automatically.

**When to monitor:** High `Agent.DisambiguationTriggered` rates in Application Insights indicate overlapping trigger phrases — refine topic triggers to reduce ambiguity.
