# Base Topics

The three system topics that every agent needs. These come with `base/` — do not remove them.

## Topics

| File | Trigger | Purpose |
|------|---------|---------|
| [`Greeting.topic.mcs.yml`](Greeting.topic.mcs.yml) | `OnConversationStart` | Welcome message + `Conversation.Started` telemetry |
| [`Fallback.topic.mcs.yml`](Fallback.topic.mcs.yml) | `OnUnknownIntent` | Retries 3× with rephrasing prompts, then escalates with `Agent.EscalationTriggered` telemetry |
| [`OnError.topic.mcs.yml`](OnError.topic.mcs.yml) | `OnError` | Safe error message in prod; full error details in test mode; `Agent.ErrorOccurred` telemetry |

## What to customise

| Topic | What to change |
|-------|---------------|
| Greeting | Replace `<BOT_NAME>` and the welcome message text with your agent's name and purpose |
| Fallback | Replace `<AGENT_SCHEMA>.topic.Escalate` with your escalation topic's dialog name |
| OnError | The safe message ("I'm experiencing a technical issue") can be customised — keep it brief |

## What NOT to change

- Do not remove the `LogCustomTelemetryEvent` nodes — telemetry is required for monitoring
- Do not remove the `ConditionGroup` in Fallback that counts retry attempts — it controls escalation
- Do not change `startBehavior` in OnError — `UseLatestPublishedContentAndCancelOtherTopics` is required for the error handler to fire reliably

See `base/README.md` for the full setup guide.
