# Feedback Topic

Collects user CSAT feedback at the end of a conversation using a three-stage sequence:

```
👍 / 👎  Thumbs up / down
    │
    ├─ Positive → "Thank you" → end
    │
    └─ Negative → ⭐ Star rating (1–5)
                      │
                      ├─ 4–5 → "Thank you" → end
                      │
                      └─ 1–3 → 💬 Free text + category → log → "Thank you"
```

All responses are logged to Application Insights as custom events (`Feedback.Thumbs`, `Feedback.Rating`, `Feedback.Text`).

---

## Files

| File | Purpose |
|------|---------|
| `Feedback.topic.mcs.yml` | Topic YAML — triggers + card sequence + telemetry |
| `../feedback-thumbs.json` | Standalone thumbs card (use if you only want yes/no) |
| `../feedback-rating.json` | Standalone star rating card (1–5) |
| `../feedback-text.json` | Standalone free text + category card |

---

## Setup

1. Copy `Feedback.topic.mcs.yml` into your agent's `topics/` folder
2. Replace `<SCHEMA_NAME>` with your agent's `schemaName`
3. Replace all `_REPLACE` ID suffixes with unique 6-char alphanumeric strings
4. Choose when to trigger feedback — see **Trigger Options** below

---

## Trigger Options

### Option A — User-initiated (default)
The topic is already configured with trigger phrases (`feedback`, `rate this`, `was this helpful`, etc.). Users can ask for it at any time.

### Option B — Auto-trigger after topic completion
To automatically show feedback after a specific topic resolves, add a `BeginDialog` call at the end of that topic:

```yaml
- kind: BeginDialog
  id: triggerFeedback_REPLACE
  dialog: <SCHEMA_NAME>_feedback_REPLACE
```

### Option C — Auto-trigger at conversation end
To show feedback at the end of every conversation, add the `BeginDialog` call to the last node of your `Fallback` topic's escalation path, or use the `OnConversationEnd` trigger if available in your SDK version.

---

## Telemetry Events

| Event | When fired | Properties |
|-------|-----------|-----------|
| `Feedback.Thumbs` | After thumbs response | `feedbackValue` (positive/negative), `score` (1/0), `conversationId` |
| `Feedback.Rating` | After star rating | `score` (1–5), `conversationId` |
| `Feedback.Text` | After free text (non-skipped) | `feedbackText`, `feedbackCategory`, `ratingScore`, `conversationId` |

---

## Querying Feedback in Application Insights

```kusto
-- CSAT thumbs-up rate
customEvents
| where name == "Feedback.Thumbs"
| extend score = toint(customDimensions["score"])
| summarize
    total = count(),
    positive = countif(score == 1),
    thumbsUpRate = round(100.0 * countif(score == 1) / count(), 1)
| project total, positive, thumbsUpRate

-- Average star rating
customEvents
| where name == "Feedback.Rating"
| extend score = toint(customDimensions["score"])
| summarize avgRating = round(avg(score), 2), totalRatings = count()

-- Top feedback categories (from low ratings)
customEvents
| where name == "Feedback.Text"
| extend category = tostring(customDimensions["feedbackCategory"])
| summarize count() by category
| order by count_ desc

-- Verbatim feedback comments
customEvents
| where name == "Feedback.Text"
| extend
    comment = tostring(customDimensions["feedbackText"]),
    category = tostring(customDimensions["feedbackCategory"]),
    rating = tostring(customDimensions["ratingScore"])
| where isnotempty(comment)
| project timestamp, rating, category, comment
| order by timestamp desc
```

Add these to `operations/monitoring-queries.md` for ongoing review.

---

## Variables Used

| Variable | Scope | Type | Purpose |
|----------|-------|------|---------|
| `Topic.ThumbsResponse` | Topic | Object | Full card submit payload from thumbs card |
| `Topic.ThumbsScore` | Topic | Number | 1 (positive) or 0 (negative) |
| `Topic.RatingResponse` | Topic | Object | Full card submit payload from rating card |
| `Topic.RatingScore` | Topic | Number | 1–5 |
| `Topic.TextResponse` | Topic | Object | Full card submit payload from text card |
