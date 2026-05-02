# Component: Escalation

Transfers the conversation to a human agent — triggered either by the user asking directly or called programmatically from Fallback/OutOfScope.

## When to Use

Add this component to every agent that:
- Has a human fallback path (live chat queue, Teams handoff, etc.)
- References `<AGENT_SCHEMA>.topic.Escalate` in Fallback or OutOfScope topics

The base `Fallback.topic.mcs.yml` already calls this topic by schema name after 3 unresolved intents. **This topic must exist in the agent for that call to work.**

## File

| File | Purpose |
|------|---------|
| `Escalation.topic.mcs.yml` | Handles human handoff — triggered by user phrase OR called via BeginDialog |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |
| `<EscalationQueueName>` | Your live-agent queue name (configured in Copilot Studio escalation settings) |

## Two Trigger Paths

### Path 1 — User asks directly
The topic fires via `OnRecognizedIntent` when the user says "speak to a human", "transfer me", etc.

### Path 2 — Called programmatically
The base `Fallback` and `OutOfScope` topics call this via:
```yaml
- kind: BeginDialog
  dialog: <AGENT_SCHEMA>.topic.Escalate
```
Where `<AGENT_SCHEMA>` is the agent's `schemaName` and `Escalate` is the topic's display name. The display name in this template is "Escalate to Human" — the schema name will be `<schemaName>.topic.EscalatetoHuman`. Update the `BeginDialog` call in Fallback/OutOfScope to match, or rename the display name to `Escalate`.

## Telemetry

This topic logs `Agent.EscalationTriggered` with:
- `Reason` — always `"UserRequested"` when triggered directly; set to `"FallbackExhausted"` or `"OutOfScope"` when called programmatically
- `UserQuery` — the last user message before escalation
- `FallbackCount` — how many unresolved attempts before escalation
- `ConversationId`, `Channel`, `TimeUTC` — for correlation and reporting

To set the reason from Fallback, pass it as a parameter when calling BeginDialog (advanced pattern — see BEST-PRACTICES.md).

## `TransferConversation` Requirements

The `TransferConversation` node requires:
1. A live-agent escalation provider configured in Copilot Studio (Omnichannel for Customer Service, Genesys, etc.)
2. The `targetName` must match the queue/bot name exactly as configured

If you don't have a live-agent provider, replace `TransferConversation` with a `SendActivity` directing users to an email or phone number.

## Gotchas

- If `TransferConversation` fails (no agent available, outside hours), the `OnError` topic fires — ensure your error message handles this gracefully
- The topic will only trigger via its intent phrases if the `GenerativeAIRecognizer` is active — it won't fire in bots using rules-based recognizers
- In Teams, `TransferConversation` requires the bot to be connected to Omnichannel or equivalent
