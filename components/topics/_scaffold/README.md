# _scaffold — Topic Scaffold

Start every new custom topic here. The scaffold gives you telemetry, error handling, and an optional CSAT prompt before you write a single line of logic.

## When to use

Use the scaffold when creating a **custom topic triggered by user intent**.

| Use scaffold | Use dedicated component instead |
|---|---|
| Answer a question from AI or fixed text | — |
| Call a connector (look up data, submit form) | `action-invoke/` — pre-wired for action calls |
| Branch based on user's answer | `question-branch/` — pre-wired for branching |
| **Don't** use for system-trigger topics | `disambiguation/`, `remove-citations/`, `conversation-init/` — each has its own template |

**Rule:** Never write a topic from scratch. The scaffold ensures telemetry is always present.

## What's included

| Section | Purpose | Remove when… |
|---|---|---|
| `1. TELEMETRY: TOPIC START` | Logs `Topic.Started` | Never |
| `2. MAIN LOGIC — Option A` | `SendActivity` — return a text response | You chose Option B |
| `2. MAIN LOGIC — Option B` | `Question` → `BeginDialog` → action call | You chose Option A |
| `3. ERROR HANDLING` | Null-check on action result; logs `Topic.ErrorOccurred` | You chose Option A (no action) |
| `4. CSAT FEEDBACK` | Calls Feedback topic once per conversation | Agent has no Feedback topic |

## Quick start

```bash
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/hr_assistant/topics/GetLeavePolicy.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Placeholders

| Placeholder | Where | Example |
|---|---|---|
| `<SCHEMA>` | `schemaName` field | `hr_assistant` |
| `<TOPIC_NAME>` | `componentName`, telemetry events | `GetLeavePolicy` |
| trigger phrases | `triggerQueries` block | `"annual leave policy"`, `"how many leave days"` |
| `_REPLACE1–16` | Node IDs throughout | Run ID script (includes commented-out Option B nodes) |

## Before → after

```yaml
# Before
mcs.metadata:
  componentName: <TOPIC_NAME>
  schemaName: <SCHEMA>.topic.<TOPIC_NAME>

# After
mcs.metadata:
  componentName: GetLeavePolicy
  schemaName: hr_assistant.topic.GetLeavePolicy
```

## Option A vs Option B

| You need to… | Use |
|---|---|
| Return a fixed or AI-generated answer | **Option A** — delete Option B block and Error Handling section |
| Call a connector (SharePoint, ServiceNow, etc.) | **Option B** — delete Option A, keep Error Handling |

**Option A example** (HR leave policy answer):
```yaml
- kind: SendActivity
  id: sendMessage_abc123
  activity:
    text:
      - "Employees are entitled to 25 days annual leave per year. You must submit requests at least 2 weeks in advance via the HR portal."
```

**Option B example** (collect input then call a sub-topic or action):
```yaml
- kind: Question
  id: collectInput_abc123
  variable: init:Topic.UserInput
  prompt: "I can check that for you. What's your employee ID?"
  entity: StringPrebuiltEntity
  alwaysPrompt: false
  interruptionPolicy:
    allowInterruption: true

- kind: BeginDialog
  id: invokeAction_abc123
  dialog: hr_assistant.topic.GetLeaveBalance   # .topic. — references another topic
  input:
    binding:
      InputParam: =Topic.UserInput
  output:
    binding:
      Response: Topic.ActionResponse
```

Note: the output variable in the template is `Topic.ActionResponse` — check the condition in Error Handling section uses the same variable name.

## Common mistakes

- **Leaving both Option A and Option B** — delete whichever you're not using before pushing
- **Removing Error Handling when using Option B** — the agent silently fails on null action responses without it
- **Using scaffold instead of `action-invoke/`** — if calling a connector, use `action-invoke/` directly; it's pre-configured
- **Forgetting `<SCHEMA>`** — causes `schemaName` validation error on Apply Changes

## Telemetry events

| Event | Fired when |
|---|---|
| `Topic.Started` | Always, on trigger |
| `Topic.Completed` | Option B: action returned a non-null result |
| `Topic.ErrorOccurred` | Option B: action returned null or empty |
| `Feedback.*` | Via Feedback topic at end of main logic |

→ KQL queries for all events: [`../../../operations/monitoring-queries.md`](../../../operations/monitoring-queries.md)
→ Calling a connector: [`../action-invoke/README.md`](../action-invoke/README.md)
