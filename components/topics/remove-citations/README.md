# Component: Remove Citations

Strips `[1]`, `[2]` … `[10]` citation markers from AI-generated responses before they reach the user.

## When to Use

Add this component when:
- The agent uses knowledge sources and generates answers with citation markers
- Citations are referencing internal documents that users shouldn't see referenced
- The response format needs to be clean prose without footnote-style markers

Do **not** add this if:
- You want users to see citations (e.g. for a research or compliance use case)
- The agent doesn't use generative knowledge search

## File

| File | Purpose |
|------|---------|
| `RemoveCitations.topic.mcs.yml` | OnGeneratedResponse — intercepts every AI response and removes citation markers |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |

## How It Works

1. `System.ContinueResponse = false` suppresses the raw AI response from being sent
2. A chain of `Substitute()` calls strips `[1]` through `[10]` from `System.Response.FormattedText`
3. The cleaned text is sent as a new `SendActivity`

## Extending Beyond 10 Citations

If your agent has more than 10 knowledge sources, wrap the `Substitute()` chain with more calls:

```yaml
value: >-
  =Substitute(
    Substitute(... existing chain ...,
      "[10]", ""),
    "[11]", "")
```

## Gotchas

- `OnGeneratedResponse` fires after **every** AI-generated response in the agent — not just from the knowledge-search topic. This is intentional but means all generative answers are processed through this topic
- The `Substitute()` formula is order-dependent but since each target is a unique string (`[1]`, `[2]`…) order doesn't matter here
- Whitespace left by removed markers is not trimmed — if double-spaces bother you, add `Substitute(..., "  ", " ")` as the outermost call
- This topic uses `OnGeneratedResponse`, which is a YAML-only trigger (not available in the Copilot Studio canvas UI)
