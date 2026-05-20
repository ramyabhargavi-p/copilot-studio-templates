# question-branch — Question Branch Topic

Asks the user one question and branches the conversation based on their answer. Use for multi-path flows where the correct response depends on a single choice.

## When to use

| Use question-branch | Use something else |
|---|---|
| "Are you full-time or part-time?" → different policy answers | `action-invoke/` — if you need to call a connector for the answer |
| "Which department are you in?" → route to different teams | `_scaffold/` Option B — if branching drives a connector call |
| 2–4 clear options, each with a fixed response | AI generative answers — if the branches have many variations |

## Quick start

```bash
cp components/topics/question-branch/QuestionBranch.topic.mcs.yml \
   agents/hr_assistant/topics/CheckEmploymentType.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Placeholders

| Placeholder | Example |
|---|---|
| `<Topic Name>` | `Check Employment Type` |
| trigger phrases | `"am I full time"`, `"what's my employment type"`, `"full time or part time"` |
| `<Intro message>` | `"I can help with that."` |
| `<Question prompt text>` | `"Are you full-time or part-time?"` |
| `<Option 1>` | `Full-time` |
| `<Option 2>` | `Part-time` |
| `<Response for Option 1>` | Answer for full-time employees |
| `<Response for Option 2>` | Answer for part-time employees |
| `<Fallback response>` | `"I'll need to check with HR on that. Please contact hr@contoso.com."` |
| `_REPLACE0–8` | Run ID script (starts at 0, not 1) |

## Before → after (question node)

The template uses `StringPrebuiltEntity` — the user types their answer as free text. There is **no rendered choice list**; the `<Option 1>` / `<Option 2>` placeholders are matched by exact text, not displayed as buttons.

```yaml
# Before
- kind: Question
  id: question_REPLACE2
  interruptionPolicy:
    allowInterruption: false
  alwaysPrompt: true
  variable: init:Topic.UserChoice
  prompt: <Question prompt text>
  entity: StringPrebuiltEntity

# After (HR Assistant — employment type check)
- kind: Question
  id: question_abc123
  interruptionPolicy:
    allowInterruption: false
  alwaysPrompt: true
  variable: init:Topic.UserChoice
  prompt: "Are you a full-time or part-time employee?"
  entity: StringPrebuiltEntity
```

The user types "Full-time" or "Part-time", and the `ConditionGroup` matches by exact text. The match is case-insensitive but must be exact — "full time" (with a space) would not match "Full-time".

## Before → after (branch responses)

```yaml
# Before
- kind: ConditionGroup
  conditions:
    - condition: =Topic.UserChoice = '<Option 1>'
      actions:
        - kind: SendActivity
          activity: <Response for Option 1>
    - condition: =Topic.UserChoice = '<Option 2>'
      actions:
        - kind: SendActivity
          activity: <Response for Option 2>
  elseActions:
    - kind: SendActivity
      activity: <Fallback response when no condition matches>

# After
- kind: ConditionGroup
  conditions:
    - condition: =Topic.UserChoice = 'Full-time'
      actions:
        - kind: SendActivity
          activity: "Full-time employees receive 25 days annual leave per year..."
    - condition: =Topic.UserChoice = 'Part-time'
      actions:
        - kind: SendActivity
          activity: "Part-time leave is calculated pro-rata based on your contracted hours..."
  elseActions:
    - kind: SendActivity
      activity: "I'll need to check with HR on that. Please contact hr@contoso.com."
```

## Common mistakes

- **Using `_REPLACE0–8` (starts at 0)** — unlike other topics that start at `_REPLACE1`, this one starts at `_REPLACE0`; VS Code handles it, but be aware if running the script manually
- **More than 4 branches** — many `ConditionGroup` branches are hard to maintain; if you have 5+ variations consider a knowledge search topic or AI-generated response instead
- **Using for connector calls** — if each branch triggers an API call, use `action-invoke/` per branch or `_scaffold/` Option B; `question-branch` is for branching to static responses only

→ Calling a connector: [`../action-invoke/README.md`](../action-invoke/README.md)
→ Start from scaffold for custom logic: [`../_scaffold/README.md`](../_scaffold/README.md)
