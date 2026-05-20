# remove-citations — Remove Citations Topic

Strips `[1]` through `[10]` citation markers from every AI-generated response. Fires automatically after every generative answer.

## When to add

Add whenever **knowledge-search is active** and citation markers appear in test canvas responses.

| Add remove-citations | Skip it |
|---|---|
| Agent uses `knowledge-search/` topic | Agent has no knowledge sources |
| Citations like `[1][2]` appear in Teams or web chat | Channels that render citations natively (if any) |
| Responses look cluttered with inline numbers | — |

## Quick start

```bash
cp components/topics/remove-citations/RemoveCitations.topic.mcs.yml \
   agents/hr_assistant/topics/RemoveCitations.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Placeholders

Only `_REPLACE1–3` — all replaced automatically by VS Code on save. No manual placeholders.

## How it works

The topic fires on `OnGeneratedResponse` — a system event that intercepts the AI's output before it's sent to the user. It applies a chain of `Substitute()` calls to strip markers:

```
[1] → ""    [2] → ""    [3] → ""   ...   [10] → ""
```

The cleaned text replaces the original response. The user never sees the citation numbers.

## Extending beyond [10] citations

The template strips markers [1] through [10]. If your knowledge source returns more:

1. Open `RemoveCitations.topic.mcs.yml`
2. Copy one of the existing `SetVariable` / `Substitute` nodes
3. Change the marker number (e.g. add [11], [12], etc.)
4. Update the final node to use the last substituted variable

```yaml
# Example — add [11] and [12] after the existing chain:
- kind: SetVariable
  variable: Topic.CleanedText
  value: =Substitute(Topic.CleanedText, "[11]", "")

- kind: SetVariable
  variable: Topic.CleanedText
  value: =Substitute(Topic.CleanedText, "[12]", "")
```

## Common mistakes

- **Not adding when using knowledge-search** — citations appear as `[1][2]` noise in user-facing responses
- **Adding to voice channels** — `OnGeneratedResponse` fires for voice too; citation stripping is harmless but unnecessary since TTS already skips non-speech characters
- **Placing before knowledge-search in topic order** — topic order doesn't matter here; `OnGeneratedResponse` fires as a post-processing hook regardless

→ Knowledge search topic: [`../knowledge-search/README.md`](../knowledge-search/README.md)
