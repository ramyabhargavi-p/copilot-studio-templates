# Base Topics

3 topics every agent must have. These are included in `base/` and should not be removed.

| File | Trigger | Purpose |
|------|---------|---------|
| `Greeting.topic.mcs.yml` | `Conversation.Started` | Welcome message + `Conversation.Started` telemetry |
| `Fallback.topic.mcs.yml` | `OnUnknownIntent` | Unknown intent — retries 3× then calls Escalation |
| `OnError.topic.mcs.yml` | `OnError` | System error handler — safe message + `Agent.ErrorOccurred` telemetry |

These topics are pre-configured in `base/`. Replace `<AGENT_NAME>` and `<SCHEMA>` placeholders with your agent's values.

→ Full base setup: [`../README.md`](../README.md)
