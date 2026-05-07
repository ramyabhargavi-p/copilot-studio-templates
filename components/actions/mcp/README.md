# MCP Action

**Kind:** `InvokeExternalAgentTaskAction`

Calls a tool exposed by an MCP (Model Context Protocol) server. One file per MCP tool.

## Files

| File | Purpose |
|------|---------|
| `mcp-action.mcs.yml` | Template — configure `agentEndpoint`, `toolName`, and input parameters |

## Quick start

```bash
cp components/actions/mcp/mcp-action.mcs.yml \
   agents/<your-agent>/actions/<ServerName><ToolName>.mcs.yml
```

Replace: `<SCHEMA>`, `<MCP_ENDPOINT>`, `<TOOL_NAME>`, and input parameter placeholders.

→ Full MCP recipe: [`../../../recipes/04-mcp-action-agent.md`](../../../recipes/04-mcp-action-agent.md)
