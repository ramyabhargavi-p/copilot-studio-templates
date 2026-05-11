# feedback — Feedback (CSAT) Topic

Collects end-of-conversation satisfaction data: thumbs up/down → star rating (if negative) → improvement category (if rating ≤ 3). Fires once per conversation, guarded by `Global.FeedbackShown`.

## When to use

Add to every **production agent**. Skip for demos and prototypes.

| Add feedback | Skip it |
|---|---|
| Production agent — quality monitoring needed | Demo / prototype |
| You want CSAT data in App Insights | Internal tooling without exec visibility |
| Scaffold topics already call it via `BeginDialog` | — |

## Quick start

```bash
cp components/topics/feedback/Feedback.topic.mcs.yml \
   agents/hr_assistant/topics/Feedback.topic.mcs.yml
```

The adaptive card UI is **inline in the YAML** — no separate card JSON files needed.

Then run the `_REPLACE` ID script — see [QUICKSTART.md](../../../docs/QUICKSTART.md) → Replace node IDs.

## Placeholders

| Placeholder | Example |
|---|---|
| `<SCHEMA>` | `hr_assistant` (appears in the topic `id` field) |
| `_REPLACE1–27` | Run ID script — all 27, don't skip any |

## Before → after

```yaml
# Before
id: <SCHEMA>_feedback_REPLACE1

# After
id: hr_assistant_feedback_abc123   # <SCHEMA> replaced + _REPLACE1 gets a random ID
```

## How the flow works

The sequence adapts based on the response:

| Thumbs result | Steps |
|---|---|
| Positive | Thumbs → thank you message → end |
| Negative (rating > 3) | Thumbs → star rating → thank you message |
| Negative (rating ≤ 3) | Thumbs → star rating → category dropdown → thank you message |

The category dropdown (not free text) is what gets logged — no PII is collected.

## Telemetry events

| Event | When fired |
|---|---|
| `Feedback.Thumbs` | After thumbs response (logs `feedbackValue`, `score`) |
| `Feedback.Rating` | After star rating (logs `score`) |
| `Feedback.Category` | After category selected AND rating ≤ 3 AND not skipped |

## How the once-per-conversation guard works

The scaffold checks `Global.FeedbackShown` before calling `BeginDialog`. On first call, the topic sets `Global.FeedbackShown = true`. Subsequent calls within the same conversation are skipped. Nothing to configure.

## Wiring from scaffold topics

When you use `_scaffold/`, Section 4 calls the Feedback topic. Replace `<SCHEMA>` in both files with your schemaName, then run the ID script so the dialog reference IDs are consistent.

## Common mistakes

- **Skipping `_REPLACE` IDs** — there are 27 node IDs to replace; the ID script handles all of them
- **Adding to a demo agent** — users rarely complete the full flow in demos, generating noisy CSAT data
- **Expecting free-text comments in telemetry** — the template logs only a category dropdown value, not free text, to avoid PII

→ CSAT KQL queries: [`../../../operations/monitoring-queries.md`](../../../operations/monitoring-queries.md)
