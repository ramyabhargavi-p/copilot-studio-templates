# Component: Disambiguation

Shows a clarifying prompt when the recognizer matches multiple topics with similar confidence scores.

## When to Use

Add this component when:
- Your agent has many topics and topic overlap is likely (e.g. "leave request" vs "leave balance" vs "leave policy")
- You want the agent to ask rather than guess when intent is ambiguous
- You prefer explicitness over probabilistic topic selection

You may **not** need this component if:
- The agent has very few topics with clearly distinct triggers
- You prefer the recognizer to always pick the highest-scoring topic silently

## File

| File | Purpose |
|------|---------|
| `Disambiguation.topic.mcs.yml` | OnSelectIntent — presents a choice list of matched topics |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<AGENT_SCHEMA>` | Your agent's `schemaName` from `settings.mcs.yml` |

## How It Works

1. Fires when `OnSelectIntent` triggers (multiple topics matched)
2. Appends a "None of these" option to the matched topics list
3. Presents a dynamic choice card: "To clarify, did you mean: [Topic A] [Topic B] [None of these]"
4. If the user picks "None of these", the Fallback topic runs

## Adjusting Sensitivity

The recogniser fires `OnSelectIntent` when multiple topics score above a threshold. You can adjust this in Copilot Studio's **Settings > AI** — lowering the disambiguation threshold means fewer clarifying prompts; raising it means more.

## Gotchas

- `triggerBehavior: Always` means this fires even if one topic scores clearly higher than others. Change to `triggerBehavior: WhenMultipleTopicsAreAmbiguous` if you only want disambiguation for genuinely ambiguous cases
- The `Fallback` topic must exist in your agent for the "None of these" path to work — it's included in `base/`
