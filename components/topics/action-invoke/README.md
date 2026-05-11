# action-invoke — Connector Action Topic

Calls a Power Platform connector operation directly from the topic, validates the response, and returns the result to the user — with telemetry on every branch.

## When to use

Use when a topic needs to **read from or write to an external system** (SharePoint, ServiceNow, SQL, etc.) inline, without a separate action file.

| Use action-invoke | Use something else |
|---|---|
| Fetch live data (leave balance, ticket status) | `_scaffold/` Option A — for static/AI answers only |
| Submit a form or create a record | `_scaffold/` Option B — when you want to call a reusable sub-topic |
| Single connector call per topic | `components/actions/connector/` — for a shared action file called from multiple topics |

This template calls the connector **directly inside the topic** using `InvokeConnectorAction`. No separate action file is needed.

## Quick start

```bash
cp components/topics/action-invoke/ActionInvoke.topic.mcs.yml \
   agents/hr_assistant/topics/GetLeaveBalance.topic.mcs.yml
```

Then run the `_REPLACE` ID script — see [QUICKSTART.md](../../../docs/QUICKSTART.md) → Replace node IDs.

## Placeholders

| Placeholder | Example |
|---|---|
| `<Topic Name>` | `Get Leave Balance` |
| trigger phrases | `"check my leave"`, `"how many days off do I have"` |
| `<connector_reference>` | `shared_sharepointonline` |
| `<OperationId>` | `GetItem` |
| `<param1>` | `id` (connector input parameter name) |
| `<ActionName>` | `LeaveBalance` (used in telemetry events `Action.Succeeded`, `Action.Failed`) |
| `<AGENT_SCHEMA>` | `hr_assistant` (used in the CSAT `BeginDialog` reference to the Feedback topic) |
| `<Message using the action result>` | `"Your remaining leave is {Topic.ActionResult.balance} days."` |
| `_REPLACE1–13` | Run ID script |

## Before → after (connector call node)

```yaml
# Before
- kind: InvokeConnectorAction
  id: callAction_REPLACE3
  output:
    kind: SingleVariableOutputBinding
    variable: init:Topic.ActionResult
  connectionReference: <connector_reference>
  connectionProperties:
    mode: Invoker
  operationId: <OperationId>
  parameters:
    <param1>: =Topic.UserInput

# After (HR Assistant — get leave balance from SharePoint)
- kind: InvokeConnectorAction
  id: callAction_abc123
  output:
    kind: SingleVariableOutputBinding
    variable: init:Topic.ActionResult
  connectionReference: shared_sharepointonline
  connectionProperties:
    mode: Invoker
  operationId: GetItem
  parameters:
    id: =Topic.UserInput
```

## Before → after (success message)

```yaml
# Before
- kind: SendActivity
  activity: <Message using the action result>

# After
- kind: SendActivity
  activity: "Your remaining leave is {Topic.ActionResult.daysLeft} days."
```

## Prerequisites checklist

- [ ] Connector connection exists in the Power Platform environment
- [ ] You know the `connectionReference` (logical name, e.g. `shared_sharepointonline`) and `operationId`
- [ ] To find the operationId: `pac connector show --connector-id shared_sharepointonline`

No separate action file is needed — the connector call is inside this topic.

## Common mistakes

- **Using `<connector_reference>` as the display name** — it must be the logical name (e.g. `shared_sharepointonline`), not the friendly name ("SharePoint")
- **Wrong `operationId` casing** — operationIds are case-sensitive; copy exactly from `pac connector show` output
- **Removing the error handling branch** — the `ConditionGroup` on `Topic.ActionResult` is what catches null/empty responses; don't remove it
- **Referencing a non-existent connector connection** — the connection must be added to the agent in the Copilot Studio portal (Settings → Connections) before Apply Changes

## Guardrail for write operations

For create, update, or delete operations, add a `SendActivity` confirmation card node before `InvokeConnectorAction`:

→ Confirmation card: [`../../adaptive-cards/README.md`](../../adaptive-cards/README.md)
→ Connector action file (alternative shared-action pattern): [`../../actions/connector/README.md`](../../actions/connector/README.md)
