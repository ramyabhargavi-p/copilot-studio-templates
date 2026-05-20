# Alert Setup — Azure Monitor

Set up these alerts after go-live so issues are caught before users report them.

---

## Prerequisites

1. Application Insights resource connected to your Copilot Studio agent (configured in settings.mcs.yml)
2. An Action Group with at least one email/Teams webhook recipient
3. Contributor access to the Application Insights resource

---

## Creating an Action Group

Before creating alerts, create a shared Action Group:

1. Azure Portal → **Monitor** → **Alerts** → **Action groups** → **+ Create**
2. Name: `copilot-studio-<agent-name>-oncall`
3. Add notification:
   - Type: **Email/SMS/Push/Voice** → enter on-call email
   - (Optional) Type: **Azure app push notification** → Teams webhook URL
4. Save the action group — use this for all alerts below

---

## Alert Rules

### Alert 1 — Error Spike (P1/P2)

| Setting | Value |
|---------|-------|
| Signal type | Custom log search |
| Query | See [02-monitoring-queries.md](02-monitoring-queries.md) — **Alert: Error rate spike** |
| Threshold | Greater than 0 (query only returns results when > 5 errors) |
| Aggregation granularity | 15 minutes |
| Frequency | Every 5 minutes |
| Severity | 2 |
| Name | `[<AgentName>] Error spike detected` |

### Alert 2 — High Fallback Rate (P2/P3)

| Setting | Value |
|---------|-------|
| Signal type | Custom log search |
| Query | See [02-monitoring-queries.md](02-monitoring-queries.md) — **Alert: High fallback rate** |
| Threshold | Greater than 0 (query only returns results when fallback rate > 40%) |
| Aggregation granularity | 1 hour |
| Frequency | Every 15 minutes |
| Severity | 3 |
| Name | `[<AgentName>] High fallback rate (>40%)` |
| Auto-resolve | Yes, after 1 hour |

### Alert 3 — Action Failures (P2)

| Setting | Value |
|---------|-------|
| Signal type | Custom log search |
| Query | See [02-monitoring-queries.md](02-monitoring-queries.md) — **Alert: Action failure spike** |
| Threshold | Greater than 0 |
| Aggregation granularity | 10 minutes |
| Frequency | Every 5 minutes |
| Severity | 2 |
| Name | `[<AgentName>] Action failures detected` |

### Alert 4 — Agent Down (P1)

| Setting | Value |
|---------|-------|
| Signal type | Custom log search |
| Query | See [02-monitoring-queries.md](02-monitoring-queries.md) — **Alert: Zero conversations** |
| Threshold | Greater than 0 |
| Aggregation granularity | 2 hours |
| Frequency | Every 30 minutes |
| Severity | 1 |
| Name | `[<AgentName>] No conversations — agent may be down` |
| Schedule | Business hours only (recommended) |

---

## Suppression and Tuning

- Set a **15-minute suppression** on all alerts to avoid repeated notifications for the same incident
- After the first week, review which alerts fired and adjust thresholds based on actual traffic patterns
- The **Zero conversations** alert should be scoped to business hours — set a schedule if your Azure Monitor plan supports it

---

## Teams Webhook Integration (Optional)

To send alerts to a Teams channel instead of (or in addition to) email:

1. In the target Teams channel → **Manage channel** → **Connectors** → **Incoming Webhook**
2. Configure and copy the webhook URL
3. In your Action Group → add a **Webhook** notification type → paste the URL
4. Format: Azure Monitor sends a JSON payload; use the default Teams formatter or a Logic App for custom formatting

---

## Monthly Review

After each month, review:
- Which alerts fired and how often
- Whether thresholds need adjusting (too noisy = lower sensitivity; missed incidents = raise sensitivity)
- Add new alerts for any error pattern that caused a P1/P2 but wasn't caught proactively
