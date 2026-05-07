# Action Components

2 action templates — one for Power Platform connectors, one for MCP server tools. Copy one per connector operation or MCP tool your agent calls.

---

## Actions

| Folder | Kind | Use when… |
|--------|------|-----------|
| [`connector/`](connector/) | `InvokeConnectorTaskAction` | Calling a Power Platform connector (Office 365, SharePoint, Dataverse, custom connectors) |
| [`mcp/`](mcp/) | `InvokeExternalAgentTaskAction` | Calling an MCP server tool |

---

## Usage

Each action template is a single `.mcs.yml` file. Copy it once per operation — if you call three connector operations, you create three action files.

```bash
cp components/actions/connector/connector-action.mcs.yml \
   agents/<your-agent>/actions/<ConnectorName><OperationName>.mcs.yml
```

Actions are called from topics using `BeginDialog`. See `components/topics/action-invoke/` for the topic template that pairs with these action files.

→ Safety tiers and confirmation patterns: [`../../docs/ACTION-SAFETY-PATTERNS.md`](../../docs/ACTION-SAFETY-PATTERNS.md)
