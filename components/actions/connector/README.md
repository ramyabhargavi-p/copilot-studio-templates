# Connector Action

**Kind:** `InvokeConnectorTaskAction`

Calls a Power Platform connector operation (Office 365, SharePoint, Dataverse, HTTP, custom connectors). One file per operation.

## Files

| File | Purpose |
|------|---------|
| `connector-action.mcs.yml` | Template — configure `connectionReference`, `operationId`, and input parameters |

## Quick start

```bash
cp components/actions/connector/connector-action.mcs.yml \
   agents/<your-agent>/actions/<ConnectorName><Operation>.mcs.yml
```

Replace: `<SCHEMA>`, `<CONNECTION_REFERENCE>`, `<OPERATION_ID>`, and any input parameter placeholders.

→ Lookup available connectors and operations: run `node scripts/connector-lookup.bundle.js list`
→ Safety tiers (when confirmation is required): [`../../../ACTION-SAFETY-PATTERNS.md`](../../../ACTION-SAFETY-PATTERNS.md)
