# Component: Connector Action

Calls a Power Platform connector operation (SharePoint, Outlook, Dataverse, ServiceNow, etc.) as an AI-invokable action.

## When to Use

Add this component when the agent needs to:
- Read or write data from a Power Platform connector (SharePoint lists, Outlook calendar, Dataverse tables, etc.)
- Perform an operation triggered by the user's request (e.g. "create a ticket", "check my leave balance", "send an email")
- Expose a connector API operation to the AI as a named capability

## File

| File | Purpose |
|------|---------|
| `connector-action.mcs.yml` | TaskDialog with InvokeConnectorTaskAction — wraps a connector operation |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `<Action Name>` | Descriptive name (e.g. `GetLeaveBalance`, `CreateSupportTicket`) |
| `<connection-reference-logical-name>` | The logical name of the connection reference in Power Platform |
| `<OperationId>` | The connector's operation ID (see table below) |
| `<FixedPropertyName>` / `<Fixed Value>` | Hard-coded connector params (or remove this input block if not needed) |
| `<DynamicPropertyName>` | Connector param the AI collects from the user |
| `modelDisplayName` / `modelDescription` | What the AI sees — be specific for accurate routing |

## Common Connection References & Operation IDs

| Connector | Connection Reference | Common OperationIds |
|-----------|---------------------|-------------------|
| SharePoint | `shared_sharepointonline` | `GetItems`, `CreateItem`, `UpdateItem`, `DeleteItem` |
| Office 365 Outlook | `shared_office365` | `CalendarGetItems_V3`, `SendEmailV2`, `CreateEventV4` |
| Office 365 Users | `shared_office365users` | `UserGet_V2`, `SearchUser_V2`, `MyProfile_V2` |
| Dataverse | `shared_commondataservice` | `ListRecords`, `CreateRecord`, `UpdateRecord` |
| Microsoft Teams | `shared_teams` | `PostMessageToConversation`, `GetTeamsChannels` |

Find the full list in the [Power Platform connector reference](https://learn.microsoft.com/en-us/connectors/connector-reference/).

## Input Types

| Kind | Use when |
|------|----------|
| `ManualTaskInput` | Value is always the same (e.g. a site URL, a table name) |
| `AutomaticTaskInput` | Value comes from the user or is inferred from the conversation |

## `mode` Values

| Value | Meaning |
|-------|---------|
| `Invoker` | Runs as the signed-in user — requires `ManualAzureAD` or `IntegratedAzureAD` auth |
| `Caller` | Runs as the agent's service principal — works with `authenticationMode: None` |

## OData Parameter Names (SharePoint)

SharePoint uses `$`-prefixed OData parameters (`$filter`, `$select`, `$top`). Because `$` is a special character in YAML, wrap the parameter name in single quotes inside the double-quoted string:

```yaml
propertyName: "'$filter'"
value: "Title eq 'Active'"
```

## Gotchas

- `modelDescription` is what the AI reads to decide whether to invoke this action — make it specific. Vague descriptions cause the AI to invoke the wrong action or miss it entirely
- `shouldPromptUser: true` means the AI will ask the user for the value if it can't infer it from context. Set to `false` only if the value is always derivable from the conversation
- Add one YAML file per action — don't combine multiple operations into one TaskDialog
