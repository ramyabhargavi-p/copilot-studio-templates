# Component: Question Branch

A topic triggered by user intent that asks a question and branches the conversation based on the answer.

## When to Use

Use this as the **starting point for any new topic** that:
- Has an identifiable user intent (e.g. "check leave balance", "reset password")
- Needs to collect one piece of information before responding
- Has different responses depending on what the user says

For topics that don't need a question (just a direct response), remove the `Question` node.
For topics that need multiple questions, duplicate the `Question` + `ConditionGroup` pattern.

## File

| File | Purpose |
|------|---------|
| `QuestionBranch.topic.mcs.yml` | OnRecognizedIntent — collects user input and branches on the answer |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<Topic Name>` | Display name for this topic (shown in Copilot Studio UI) |
| `<trigger phrase 1..5>` | 5+ example user phrases that should trigger this topic |
| `<Intro message...>` | Optional welcome message (or remove the SendActivity node) |
| `<Question prompt text>` | The question to ask the user |
| `<Option 1>`, `<Option 2>` | Expected user responses to branch on |
| `<Response for Option N>` | What to say for each branch |
| `<Fallback response...>` | What to say when no condition matches |

## Entity Types

The `entity` field on the `Question` node controls what type of answer is expected:

| Entity | Use for |
|--------|---------|
| `StringPrebuiltEntity` | Free-text answers |
| `BooleanPrebuiltEntity` | Yes/No questions |
| `NumberPrebuiltEntity` | Numeric answers |
| `DateTimePrebuiltEntity` | Dates and times |

## Extending the Branch

To add more branches, copy a `conditionItem` block and increment the ID:
```yaml
- id: conditionItem_REPLACE9
  condition: =Topic.UserChoice = '<Option 3>'
  actions:
    - kind: SendActivity
      id: sendMessage_REPLACE10
      activity: <Response for Option 3>
```

## Gotchas

- `alwaysPrompt: true` means the question is always asked even if the entity was already extracted from the trigger phrase. Set to `false` to skip if the answer is already known
- `allowInterruption: false` prevents other topics from firing mid-question. Set to `true` if the user should be able to change subject while answering
- Trigger queries are case-insensitive but must be distinct enough from other topics to avoid disambiguation
