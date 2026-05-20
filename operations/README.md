# Operations

> **When to use:** After hypercare ends (Day 14+). These queries run in Application Insights
> connected to your Copilot Studio agent. Required setup: Application Insights workspace linked
> in Copilot Studio → Settings → Telemetry.
>
> | File | Use for |
> |------|---------|
> | `02-monitoring-queries.md` | Weekly health checks — run every Monday |
> | `01-alert-setup.md` | One-time setup — create Azure Monitor alerts |
> | `03-runbook.md` | On-call reference — what to do when an alert fires |
> | `04-user-feedback.md` | Monthly CSAT analysis |

Three documents for keeping a live agent healthy after launch.

---

## What each file covers

| File | What it covers | Cadence |
|------|---------------|---------|
| [`02-monitoring-queries.md`](02-monitoring-queries.md) | KQL queries for App Insights — conversations, fallbacks, escalations, CSAT, errors | Weekly |
| [`01-alert-setup.md`](01-alert-setup.md) | Azure Monitor alert rules — thresholds, notification channels | Set up at launch, review monthly |
| [`03-runbook.md`](03-runbook.md) | Step-by-step responses for every production incident type | On incident |

---

## Weekly health check

Run these four KQL queries from `02-monitoring-queries.md` every week:

1. **Volume** — total conversations, active users
2. **Quality** — fallback rate, escalation rate, knowledge answer rate
3. **CSAT** — thumbs score, star rating average
4. **Errors** — `Agent.ErrorOccurred` count, top error types

Target thresholds (set alerts in `01-alert-setup.md`):
- Fallback rate < 15%
- Escalation rate < 10%
- CSAT ≥ 4 / 5 stars
- Error rate < 2%

---

## When to scale or migrate

Watch for these signals from `02-monitoring-queries.md`:

| Signal | Action |
|--------|--------|
| RPM approaching 8,000 / min | Add environment or evaluate Foundry migration |
| Fallback rate > 25% sustained | Trigger knowledge or topic review |
| CSAT drop > 0.5 stars week-over-week | Review recent topic changes |
| `Topic.ErrorOccurred` spike | Check `03-runbook.md` → connector or action issue |

→ Progressive enhancement decision: [`../project-delivery/11-ai-engineer-realtime-guide.md`](../project-delivery/11-ai-engineer-realtime-guide.md) Post-launch section
→ Incident response: [`03-runbook.md`](03-runbook.md)
