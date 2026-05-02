# Component: Action Invoke (with Error Handling)

A topic template that calls a connector action with full error handling, output validation, and telemetry. Use this instead of `question-branch` when the topic's primary job is to invoke an action.

## When to Use

Use this template when:
- A topic's main purpose is to call a connector or MCP action
- You need to handle action failures gracefully (action returned null, API was unavailable, etc.)
- You want structured telemetry for action success/failure rates

Use `question-branch` instead when the topic collects user input and branches on the answer — without calling an action.

## File

| File | Purpose |
|------|---------|
| `ActionInvoke.topic.mcs.yml` | OnRecognizedIntent — collects input, calls action, validates response, handles errors, logs result |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<Topic Name>` | Display name for the topic (e.g. `Get Leave Balance`) |
| `<trigger phrase N>` | Phrases that trigger this topic |
| `<AGENT_SCHEMA>` | Your agent's `schemaName` |
| `<ActionName>` | The display name of the action to invoke |
| `<InputParam>` | The input parameter name expected by the action |
| Question prompt | What to ask the user if input is needed |

## Error Handling Pattern

The core pattern is a `ConditionGroup` after `BeginDialog`:

```
BeginDialog (invoke action) → output: Topic.ActionResponse
    │
    ▼
ConditionGroup: IsBlank(Topic.ActionResponse)?
    ├─ Not blank → SUCCESS: send response + log Action.Succeeded
    └─ Blank      → FAILURE: send safe error message + log Action.Failed
```

Actions in Copilot Studio don't throw exceptions to the topic level — a failed connector call returns a null/empty response. **Always check for blank before using the output.**

## Telemetry Events

| Event | When fired |
|-------|-----------|
| `Topic.Started` | When the topic triggers — includes user query |
| `Action.Succeeded` | When the action returns a non-blank response |
| `Action.Failed` | When the action returns blank/null |

Monitor `Action.Failed` rates per `ActionName` to catch connector reliability issues early.

## Skipping the Question Node

Remove the `Question` node if:
- The action has no required inputs (e.g. "get my profile")
- The AI can infer all inputs from conversation context (`shouldPromptUser: false` on `AutomaticTaskInput`)

## Multiple Actions in One Topic

If the topic needs to call two actions in sequence, chain `BeginDialog` calls — each with its own output variable and ConditionGroup:

```yaml
- kind: BeginDialog        # Call Action 1
  output: binding: Result1: Topic.Result1
- kind: ConditionGroup     # Validate Result1
  ...
- kind: BeginDialog        # Call Action 2 (only if Result1 was valid)
  output: binding: Result2: Topic.Result2
- kind: ConditionGroup     # Validate Result2
  ...
```

## Gotchas

- `alwaysPrompt: false` on the Question means the AI skips asking if it already extracted the value — set to `true` if the confirmation prompt is important for safety (e.g. destructive operations)
- The `TransferConversation` path from `Fallback` is NOT triggered on `Action.Failed` — that's by design. Action failures are recoverable; the user can try again. Only escalate if the user is truly stuck
- The `<AGENT_SCHEMA>.topic.<ActionName>` schema name is auto-generated from the action's display name — spaces are removed. "Get Leave Balance" becomes `GetLeaveBalance`
