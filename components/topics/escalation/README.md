# Escalation Topic

**Primary trigger:** `OnRecognizedIntent` — user phrases like "speak to a human", "talk to a person", "transfer me"
**Also called via:** `BeginDialog` from Fallback topic (after 3 failed retries) and OutOfScope topic
**Telemetry:** `Agent.EscalationTriggered` (includes `Reason`, `UserQuery`, `FallbackCount`, `Channel`)

Hands the conversation to a human agent via `TransferConversation`. The Fallback topic references this as `<AGENT_SCHEMA>.topic.Escalate`.

## Files

| File | Purpose |
|------|---------|
| `Escalation.topic.mcs.yml` | `OnRecognizedIntent` trigger + `TransferConversation` node + telemetry |

## Trigger phrases (from the YAML)

```
speak to a human, talk to a person, I need a human,
connect me to a real person, speak to an agent, human please,
transfer me, let me speak to your team, I want to raise a complaint
```

Add or remove phrases to match how your users phrase escalation requests.

## Quick start

```bash
cp components/topics/escalation/Escalation.topic.mcs.yml \
   agents/<your-agent>/topics/Escalation.topic.mcs.yml
```

Replace `<EscalationQueueName>` with your live-agent handoff queue name.

**Note:** The Fallback topic in `base/` already calls this after 3 failed retries via `BeginDialog`. No additional wiring needed if you use the base Fallback.
