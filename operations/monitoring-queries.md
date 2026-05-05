# Monitoring Queries — Application Insights KQL

These queries are built around the exact telemetry events fired by the templates in this repository. Paste them into your Application Insights **Logs** blade.

Replace `<BOT_NAME>` and `<ENVIRONMENT_ID>` with your values. All events use `{Category}.{Action}` naming — see the Telemetry Events Reference in [README.md](../README.md).

---

## Dashboard Queries

### 1 — Conversation volume (last 30 days)

```kusto
customEvents
| where name == "Conversation.Started"
| where timestamp > ago(30d)
| summarize Conversations = count() by bin(timestamp, 1d)
| render timechart
```

### 2 — Topic routing breakdown

```kusto
customEvents
| where name in ("Topic.Started", "Knowledge.SearchInvoked", "Agent.FallbackTriggered", "Agent.OutOfScope")
| where timestamp > ago(7d)
| summarize Count = count() by name
| order by Count desc
| render barchart
```

### 3 — Fallback rate (% of conversations that hit fallback)

```kusto
let total = customEvents
    | where name == "Conversation.Started"
    | where timestamp > ago(7d)
    | summarize count();
let fallbacks = customEvents
    | where name == "Agent.FallbackTriggered"
    | where timestamp > ago(7d)
    | summarize count();
fallbacks
| extend FallbackRate = 100.0 * toscalar(fallbacks) / toscalar(total)
| project FallbackRate
```

### 4 — Escalation rate and reasons

```kusto
customEvents
| where name == "Agent.EscalationTriggered"
| where timestamp > ago(7d)
| extend Reason = tostring(customDimensions["Reason"])
| summarize Count = count() by Reason
| order by Count desc
```

### 5 — Knowledge search answer rate

```kusto
let invoked = customEvents
    | where name == "Knowledge.SearchInvoked"
    | where timestamp > ago(7d)
    | summarize Invoked = count();
let found = customEvents
    | where name == "Knowledge.AnswerFound"
    | where timestamp > ago(7d)
    | summarize Found = count();
invoked
| extend AnswerRate = 100.0 * toscalar(found) / toscalar(invoked)
| project Invoked = toscalar(invoked), Found = toscalar(found), AnswerRate
```

### 6 — Action success / failure rate

```kusto
customEvents
| where name in ("Action.Succeeded", "Action.Failed")
| where timestamp > ago(7d)
| extend ActionName = tostring(customDimensions["ActionName"])
| summarize Succeeded = countif(name == "Action.Succeeded"), Failed = countif(name == "Action.Failed") by ActionName
| extend SuccessRate = 100.0 * Succeeded / (Succeeded + Failed)
| order by SuccessRate asc
```

### 7 — Error frequency and codes

```kusto
customEvents
| where name == "Agent.ErrorOccurred"
| where timestamp > ago(7d)
| extend ErrorCode = tostring(customDimensions["ErrorCode"]),
         ErrorMessage = tostring(customDimensions["ErrorMessage"]),
         IsTestMode = tostring(customDimensions["IsTestMode"])
| where IsTestMode == "false"
| summarize Count = count() by ErrorCode, ErrorMessage
| order by Count desc
```

### 8 — Out-of-scope topics (what users ask outside scope)

```kusto
customEvents
| where name == "Agent.OutOfScope"
| where timestamp > ago(7d)
| extend UserQuery = tostring(customDimensions["UserQuery"])
| summarize Count = count() by UserQuery
| order by Count desc
| take 50
```

---

## Alerting Queries

Use these in **Azure Monitor → Alerts → Create alert rule → Custom log search**.

### Alert: Error rate spike

Fires when more than 5 errors occur in a 15-minute window.

```kusto
customEvents
| where name == "Agent.ErrorOccurred"
| where timestamp > ago(15m)
| where tostring(customDimensions["IsTestMode"]) == "false"
| summarize ErrorCount = count()
| where ErrorCount > 5
```

Recommended: Severity 2, check every 5 minutes.

### Alert: High fallback rate

Fires when fallback rate exceeds 40% of conversations in the last hour.

```kusto
let total = toscalar(customEvents
    | where name == "Conversation.Started"
    | where timestamp > ago(1h)
    | count);
let fallbacks = toscalar(customEvents
    | where name == "Agent.FallbackTriggered"
    | where timestamp > ago(1h)
    | count);
print FallbackRate = iif(total > 0, 100.0 * fallbacks / total, 0.0)
| where FallbackRate > 40
```

Recommended: Severity 3, check every 15 minutes, suppress for 1 hour after firing.

### Alert: Action failure spike

Fires when 3 or more action failures occur within 10 minutes.

```kusto
customEvents
| where name == "Action.Failed"
| where timestamp > ago(10m)
| summarize Count = count()
| where Count >= 3
```

Recommended: Severity 2, check every 5 minutes.

### Alert: Zero conversations (agent down)

Fires when no conversations have started in the past 2 hours during business hours.

```kusto
customEvents
| where name == "Conversation.Started"
| where timestamp > ago(2h)
| summarize ConversationCount = count()
| where ConversationCount == 0
```

Recommended: Severity 1, check every 30 minutes, schedule during business hours only.

---

## Investigation Queries

### Trace a single conversation

Replace `<CONV_ID>` with the ConversationId from any event.

```kusto
customEvents
| where tostring(customDimensions["ConversationId"]) == "<CONV_ID>"
| project timestamp, name, customDimensions
| order by timestamp asc
```

### Find conversations with errors

```kusto
customEvents
| where name == "Agent.ErrorOccurred"
| where timestamp > ago(24h)
| extend ConversationId = tostring(customDimensions["ConversationId"]),
         ErrorCode = tostring(customDimensions["ErrorCode"])
| project timestamp, ConversationId, ErrorCode
| order by timestamp desc
```

### Unanswered questions (knowledge gaps)

```kusto
customEvents
| where name == "Knowledge.AnswerNotFound"
| where timestamp > ago(30d)
| extend UserQuery = tostring(customDimensions["UserQuery"])
| summarize Count = count() by UserQuery
| order by Count desc
| take 30
```

Use this output to identify gaps in your knowledge source content.

### Sign-in failures (conversations that started sign-in but never completed)

```kusto
let started = customEvents
    | where name == "Auth.SignInStarted"
    | where timestamp > ago(24h)
    | extend ConversationId = tostring(customDimensions["ConversationId"])
    | project ConversationId, SignInStarted = timestamp;
let completed = customEvents
    | where name == "Auth.SignInCompleted"
    | where timestamp > ago(24h)
    | extend ConversationId = tostring(customDimensions["ConversationId"])
    | project ConversationId, SignInCompleted = timestamp;
started
| join kind=leftanti completed on ConversationId
| summarize FailedSignIns = count()
```

---

## Monthly Health Report Query

Produces a summary table for monthly stakeholder reporting.

```kusto
let start = startofmonth(ago(30d));
let end = endofmonth(ago(30d));
customEvents
| where timestamp between (start .. end)
| summarize
    TotalConversations = countif(name == "Conversation.Started"),
    TotalFallbacks = countif(name == "Agent.FallbackTriggered"),
    TotalEscalations = countif(name == "Agent.EscalationTriggered"),
    TotalErrors = countif(name == "Agent.ErrorOccurred" and tostring(customDimensions["IsTestMode"]) == "false"),
    KnowledgeSearches = countif(name == "Knowledge.SearchInvoked"),
    AnswersFound = countif(name == "Knowledge.AnswerFound"),
    ActionSucceeded = countif(name == "Action.Succeeded"),
    ActionFailed = countif(name == "Action.Failed")
| extend
    FallbackRate = round(100.0 * TotalFallbacks / TotalConversations, 1),
    KnowledgeAnswerRate = round(100.0 * AnswersFound / KnowledgeSearches, 1),
    ActionSuccessRate = round(100.0 * ActionSucceeded / (ActionSucceeded + ActionFailed), 1)
```
