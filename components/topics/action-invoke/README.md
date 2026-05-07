# Action Invoke Topic

**Trigger:** `OnRecognizedIntent`
**Telemetry:** `Topic.Started`, `Action.Succeeded`, `Action.Failed`, `Topic.ErrorOccurred`

Template for topics that call a connector or MCP action. Collects user input, calls the action, validates the response, and handles the success and failure paths — with telemetry on every branch.

## Files

| File | Purpose |
|------|---------|
| `ActionInvoke.topic.mcs.yml` | Full action-calling topic with input collection, validation, and error handling |

## Quick start

```bash
cp components/topics/action-invoke/ActionInvoke.topic.mcs.yml \
   agents/<your-agent>/topics/<ActionName>.topic.mcs.yml
```

Then:
1. Add trigger phrases
2. Set the `BeginDialog` target to your action file
3. Configure the input question(s)
4. Update the success and failure response messages

**Guardrail:** For Medium or High safety tier actions (write/delete operations), add a `confirmation-card` before the `BeginDialog` call.

→ Safety tiers: [`../../../ACTION-SAFETY-PATTERNS.md`](../../../ACTION-SAFETY-PATTERNS.md)
→ Confirmation card: [`../../adaptive-cards/README.md`](../../adaptive-cards/README.md)
