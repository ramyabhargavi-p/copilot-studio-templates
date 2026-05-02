# Component: MCP Action

Calls an MCP (Model Context Protocol) server tool as an AI-invokable action.

## When to Use

Add this component when the agent needs to call an external MCP server — for example:
- A custom Python/Node.js tool that fetches data from a proprietary API
- An MCP-compatible service (GitHub, Jira, Confluence, etc.) registered as a Power Platform connection
- Any external capability exposed via the MCP protocol

Use the [`connector`](../connector/) component instead for standard Power Platform connector operations.

## File

| File | Purpose |
|------|---------|
| `mcp-action.mcs.yml` | TaskDialog with InvokeExternalAgentTaskAction — calls an MCP server operation |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `<MCP Server Name>` | Descriptive name for this MCP action (e.g. `SearchJiraIssues`) |
| `<connection-reference-logical-name>` | The logical name of the MCP connection in Power Platform |
| `<mcp_OperationId>` | The operation ID as registered in the MCP connection |
| `modelDisplayName` / `modelDescription` | What the AI sees — be specific for accurate routing |

## Finding the Operation ID

1. Open [make.powerapps.com](https://make.powerapps.com)
2. Go to **Connections** and find your MCP connection
3. Click the connection → **API Reference** to see available operations and their IDs

## Inputs and Outputs

Unlike connector actions, MCP actions don't define explicit `inputs` and `outputs` blocks in the YAML. The MCP server's tool schema defines the parameters — the AI infers what to pass based on the `modelDescription`.

If you need to pass structured inputs, extend the YAML:

```yaml
inputs:
  - kind: AutomaticTaskInput
    propertyName: query
    description: The search query to send to the MCP server
    entity: StringPrebuiltEntity
    shouldPromptUser: true
```

## `mode` Values

| Value | Meaning |
|-------|---------|
| `Invoker` | Runs as the signed-in user |
| `Caller` | Runs as the agent's service principal |

## Gotchas

- MCP connections must be registered in Power Platform before they appear in Copilot Studio
- The MCP server must be publicly accessible or reachable from Power Platform's network
- `modelDescription` drives AI routing — a vague description means unreliable invocation
