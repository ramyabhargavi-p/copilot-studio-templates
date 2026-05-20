# User Feedback and CSAT

Strategy, templates, and KPI targets for collecting user feedback from your Copilot Studio agent.

---

## Why Collect Feedback

Agent analytics (fallback rate, escalation rate, knowledge hit rate) tell you what the agent did. Feedback tells you whether users found it useful. Both are needed. Feedback without analytics is opinion. Analytics without feedback misses silent dissatisfaction.

**Minimum viable feedback:** Thumbs up / down after every conversation. This is one card, zero friction, and gives you a CSAT trendline from day one.

---

## Three Feedback Types

### 1 — Thumbs Up / Down (Yes / No)

**Best for:** Every agent, every conversation. The default.

**When to show:** End of any resolved conversation, or when the agent detects it has answered the user's question (topic reached `EndDialog`).

**Card file:** `components/adaptive-cards/feedback-thumbs.json`

**What it measures:** Binary satisfaction — did the agent help or not?

**Target:** Thumbs-up rate ≥ 75% at 3 months, ≥ 85% at 6 months.

**Template card:**

> **Was this helpful?**
> Your feedback helps us improve this assistant.
>
> `👍  Yes, it helped`   `👎  No, it didn't`

---

### 2 — Star Rating (1–5)

**Best for:** After key topic completions (leave request submitted, ticket raised, policy lookup). Use when you need a granular score, not just binary.

**When to show:** After thumbs-down, or as the primary method for high-value topics. Do not show after every message — friction kills response rate.

**Card file:** `components/adaptive-cards/feedback-rating.json`

**What it measures:** Degree of satisfaction. Enables NPS-style trending over time.

**Score interpretation:**

| Score | Meaning | Action |
|-------|---------|--------|
| 1–2 | Very dissatisfied | Investigate immediately — check conversation transcript |
| 3 | Neutral | Watch for patterns — may indicate incomplete answers |
| 4 | Satisfied | Monitor — acceptable |
| 5 | Very satisfied | Identify what worked and replicate |

**Target:** Average rating ≥ 4.0 at 3 months.

**Template card:**

> **How would you rate this conversation?**
> 1 = Very poor  ·  5 = Excellent
>
> `⭐ 1`   `⭐⭐ 2`   `⭐⭐⭐ 3`   `⭐⭐⭐⭐ 4`   `⭐⭐⭐⭐⭐ 5`

---

### 3 — Statement / Free Text

**Best for:** When rating is 3 or below. Captures the specific reason for dissatisfaction.

**When to show:** Automatically after a low rating. Always optional (include Skip button).

**Card file:** `components/adaptive-cards/feedback-text.json`

**What it measures:** Qualitative themes. Uncovers problems analytics cannot detect (wrong answer, topic not covered, confusing flow).

**Category options in the card:**

| Category value | Display label |
|---|---|
| `wrong_answer` | Answer was wrong or inaccurate |
| `incomplete` | Answer was incomplete |
| `not_understood` | Couldn't understand my question |
| `out_of_scope` | Topic not covered |
| `too_slow` | Took too long / too many steps |
| `other` | Other |

**Review cadence:** Read verbatim comments monthly. Group by category quarterly. Feed themes into agent improvement backlog.

---

## Recommended Sequence

The three types work best together in a progressive sequence:

```
End of conversation
        │
        ▼
┌─────────────────────────────┐
│  👍 / 👎  Thumbs Up/Down    │   ← always shown
└─────────────────────────────┘
        │
        ├─ 👍 Positive ──────────────── "Thank you 😊" → end
        │
        └─ 👎 Negative
                │
                ▼
        ┌─────────────────────────────┐
        │  ⭐ Star Rating (1–5)       │   ← shown on negative
        └─────────────────────────────┘
                │
                ├─ 4–5 ──────────────── "Thank you" → end
                │
                └─ 1–3
                        │
                        ▼
                ┌─────────────────────────────┐
                │  💬 Free Text + Category    │   ← shown on low rating
                └─────────────────────────────┘   (Skip button available)
                        │
                        ▼
                "Thank you for your feedback" → end
```

**YAML implementation:** `components/topics/feedback/Feedback.topic.mcs.yml`

---

## How to Wire Up in Your Agent

### Option A — User-initiated only
No changes needed. The `Feedback` topic already has trigger phrases (`feedback`, `rate this`, `was this helpful`, etc.). Users can ask at any time.

### Option B — Auto-trigger after a specific topic
Add this at the end of any topic that resolves a user request:

```yaml
- kind: BeginDialog
  id: triggerFeedback_REPLACE
  dialog: <SCHEMA_NAME>_feedback_REPLACE
```

Add it after the "success" branch — not on error paths.

### Option C — Auto-trigger after knowledge search answer
In `components/topics/knowledge-search/`, add the `BeginDialog` call after the `Knowledge.AnswerFound` telemetry node.

---

## Telemetry Events

All feedback is logged to Application Insights. Add these to your monitoring dashboard.

| Event | Properties | When fired |
|-------|-----------|-----------|
| `Feedback.Thumbs` | `feedbackValue`, `score`, `conversationId` | After every thumbs response |
| `Feedback.Rating` | `score`, `conversationId` | After star rating |
| `Feedback.Text` | `feedbackText`, `feedbackCategory`, `ratingScore`, `conversationId` | After free text (non-skipped only) |

---

## KPI Targets

Set these in your requirements questionnaire (Q18) and review monthly.

| KPI | Definition | Minimum target | Good target |
|-----|-----------|----------------|-------------|
| **Thumbs-up rate** | % of thumbs responses that are positive | ≥ 70% | ≥ 85% |
| **Rating response rate** | % of conversations where a rating was submitted | ≥ 20% | ≥ 40% |
| **Average star rating** | Mean of all star rating scores | ≥ 3.5 / 5 | ≥ 4.2 / 5 |
| **Text feedback rate** | % of low ratings that include a comment | ≥ 30% | ≥ 50% |
| **Top negative category** | Most common category in text feedback | — | `out_of_scope` or `incomplete` (fixable) |

If `wrong_answer` is the top category, that is a grounding / hallucination problem — review the knowledge sources immediately.

---

## Application Insights Queries

Paste these into `operations/02-monitoring-queries.md` or run directly in your App Insights workspace.

```kusto
// Thumbs-up rate over time
customEvents
| where name == "Feedback.Thumbs"
| extend score = toint(customDimensions["score"])
| summarize
    thumbsUpRate = round(100.0 * countif(score == 1) / count(), 1),
    total = count()
    by bin(timestamp, 1d)
| order by timestamp asc

// Average star rating by week
customEvents
| where name == "Feedback.Rating"
| extend score = toint(customDimensions["score"])
| summarize avgRating = round(avg(score), 2), totalRatings = count()
    by bin(timestamp, 7d)
| order by timestamp asc

// Feedback category breakdown
customEvents
| where name == "Feedback.Text"
| extend category = tostring(customDimensions["feedbackCategory"])
| summarize count() by category
| order by count_ desc

// Verbatim low-rating comments (last 30 days)
customEvents
| where name == "Feedback.Text"
    and timestamp >= ago(30d)
| extend
    comment    = tostring(customDimensions["feedbackText"]),
    category   = tostring(customDimensions["feedbackCategory"]),
    rating     = tostring(customDimensions["ratingScore"])
| where isnotempty(comment)
| project timestamp, rating, category, comment
| order by timestamp desc
```

---

## WorkIQ Integration

After go-live, use WorkIQ to surface feedback that users may have shared outside the agent:

| Query | When to run |
|---|---|
| `/workiq` → `"Any Teams messages or emails about the [agent name] assistant?"` | Weekly — catch feedback not submitted via the card |
| `/workiq` → `"What did [team] say about the agent in the [channel] channel this week?"` | Weekly — support channel monitoring |
| `/workiq:channel-digest` on the agent support channel | Weekly — structured activity summary |
| `/workiq:action-item-extractor` after any agent review meeting | After monthly/quarterly reviews — extract improvement actions |

---

## Review Cadence

| Frequency | What to review | Where |
|-----------|---------------|-------|
| Weekly | Thumbs-up rate trend + any score of 1 or 2 | App Insights or monitoring dashboard |
| Monthly | Average star rating trend + top feedback categories | Verbatim comments query above |
| Quarterly | Full feedback theme analysis → feed into backlog | Agent review with developer |
| On alert | Thumbs-up rate drops > 10% week-on-week | Azure Monitor alert on `Feedback.Thumbs` score |
