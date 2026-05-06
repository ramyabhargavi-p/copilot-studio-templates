# Operations

Three documents for keeping a live agent healthy after launch.

---

## What each file covers

| File | What it covers | Cadence |
|------|---------------|---------|
| [`monitoring-queries.md`](monitoring-queries.md) | KQL queries for App Insights — conversations, fallbacks, escalations, CSAT, errors | Weekly |
| [`alert-setup.md`](alert-setup.md) | Azure Monitor alert rules — thresholds, notification channels | Set up at launch, review monthly |
| [`runbook.md`](runbook.md) | Step-by-step responses for every production incident type | On incident |

---

## Weekly health check

Run these four KQL queries from `monitoring-queries.md` every week:

1. **Volume** — total conversations, active users
2. **Quality** — fallback rate, escalation rate, knowledge answer rate
3. **CSAT** — thumbs score, star rating average
4. **Errors** — `Agent.ErrorOccurred` count, top error types

Target thresholds (set alerts in `alert-setup.md`):
- Fallback rate < 15%
- Escalation rate < 10%
- CSAT ≥ 4 / 5 stars
- Error rate < 2%

---

## When to scale or migrate

Watch for these signals from `monitoring-queries.md`:

| Signal | Action |
|--------|--------|
| RPM approaching 8,000 / min | Add environment or evaluate Foundry migration |
| Fallback rate > 25% sustained | Trigger knowledge or topic review |
| CSAT drop > 0.5 stars week-over-week | Review recent topic changes |
| `Topic.ErrorOccurred` spike | Check `runbook.md` → connector or action issue |

→ Progressive enhancement decision: [`../project-delivery/13-ai-engineer-realtime-guide.md`](../project-delivery/13-ai-engineer-realtime-guide.md) Post-launch section
→ Incident response: [`runbook.md`](runbook.md)
