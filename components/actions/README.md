# Action Components

Each folder is an action definition that your topics can call via `BeginDialog` or `InvokeConnectorAction`.

## Available Actions

| Component | Kind | What it does |
|-----------|------|-------------|
| [`connector/`](connector/) | `InvokeConnectorTaskAction` | Calls a Power Platform connector operation |
| [`mcp/`](mcp/) | `InvokeExternalAgentTaskAction` | Calls an MCP server tool |

## Usage Pattern

Actions are called from topics. Use the `action-invoke` topic component (`components/topics/action-invoke/`) as the driving topic — it handles input collection, calls the action via `BeginDialog`, validates the output, and sends the response with full error handling.

## How to add an action to your agent

1. Copy the component folder into your agent project
2. Replace all `<PLACEHOLDER>` values (connector name, operation name, parameters)
3. Replace all `_REPLACE` node ID suffixes
4. Add the corresponding `action-invoke` topic and wire the `BeginDialog` to this action
5. Push with `pac copilot push`

Each component has its own README with specific setup instructions.
