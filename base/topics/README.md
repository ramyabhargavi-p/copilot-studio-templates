# Base Topics

3 topics every agent must have. These are included in `base/` and should not be removed.

| File | Trigger | Purpose |
|------|---------|---------|
| `Greeting.topic.mcs.yml` | `Conversation.Started` | Welcome message + `Conversation.Started` telemetry |
| `Fallback.topic.mcs.yml` | `OnUnknownIntent` | Unknown intent — retries 3× then calls Escalation |
| `OnError.topic.mcs.yml` | `OnError` | System error handler — safe message + `Agent.ErrorOccurred` telemetry |

These topics are pre-configured in `base/`. Replace `<AGENT_NAME>` and `<SCHEMA>` placeholders with your agent's values.

> **CMD scripts** — all `<PLACEHOLDER>` and `_REPLACE` node IDs in these files are handled by the PowerShell/bash scripts in [QUICKSTART.md → Step 4 — Replace node IDs](../../docs/QUICKSTART.md#step-4--replace-node-ids). Run the script once after copying files into your agent folder.

→ Full base setup: [`../README.md`](../README.md)
