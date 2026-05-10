# escalation — Escalation Topic

Hands the conversation to a live agent queue via `TransferConversation`. Triggered by user request or automatically by the Fallback topic after repeated failures.

## When to use

Add to any agent that has a **human escalation path** (contact centre queue, Teams channel, Omnichannel).

| Add escalation | Skip it |
|---|---|
| Agent is connected to a contact centre | Internal-only / demo agents with no live agent handoff |
| Users should be able to request a human | Self-service only agents |
| Fallback topic should auto-escalate after 3 retries | — |

## Quick start

```bash
cp components/topics/escalation/Escalation.topic.mcs.yml \
   agents/hr_assistant/topics/Escalation.topic.mcs.yml
```

Then run the `_REPLACE` ID script — see [QUICKSTART.md](../../../docs/QUICKSTART.md) → Replace node IDs.

## Placeholders

| Placeholder | Line | Example |
|---|---|---|
| `<EscalationQueueName>` | `targetName` field | `HR Support Queue` |
| `_REPLACE1–3` | — | Run ID script |

## Before → after

```yaml
# Before
- kind: TransferConversation
  targetName: <EscalationQueueName>

# After
- kind: TransferConversation
  targetName: HR Support Queue
```

## Default trigger phrases

```
speak to a human, talk to a person, I need a human,
connect me to a real person, speak to an agent, human please,
transfer me, let me speak to your team, I want to raise a complaint
```

Add domain-specific phrases your users actually say (e.g. `"I need to speak to HR directly"`).

## How Fallback and OutOfScope call it

The `base/topics/Fallback.topic.mcs.yml` already calls this topic via `BeginDialog` after 3 failed retries:

```yaml
- kind: BeginDialog
  dialog: <AGENT_SCHEMA>.topic.Escalate    # ← set to your schemaName in Fallback.topic.mcs.yml
```

No additional wiring needed — just ensure the `<AGENT_SCHEMA>` placeholder in your Fallback file matches your `schemaName`.

## Common mistakes

- **Wrong queue name format** — the queue name must exactly match the name configured in your contact centre (Omnichannel for Customer Service, Teams channel, etc.); check with the contact centre team
- **Missing `<AGENT_SCHEMA>` in Fallback** — if Fallback still has `<AGENT_SCHEMA>.topic.Escalate` unfilled, the auto-escalation path breaks silently
- **Adding this topic but no contact centre connection** — `TransferConversation` succeeds in YAML but fails at runtime if the channel doesn't support handoff

→ Fallback topic: [`../../../base/topics/Fallback.topic.mcs.yml`](../../../base/topics/Fallback.topic.mcs.yml)
→ Escalation telemetry query: [`../../../operations/monitoring-queries.md`](../../../operations/monitoring-queries.md)
