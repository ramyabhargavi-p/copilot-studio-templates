# Operations

Documents for running a Copilot Studio agent in production. Use these after go-live and throughout the agent's lifetime.

## Documents

| File | When to use |
|------|------------|
| [`monitoring-queries.md`](monitoring-queries.md) | Day-to-day health monitoring — paste KQL queries into Application Insights |
| [`alert-setup.md`](alert-setup.md) | First week after launch — configure Azure Monitor alerts |
| [`runbook.md`](runbook.md) | When something goes wrong — incident response procedures |

## Recommended Cadence

| Frequency | Activity |
|-----------|---------|
| Daily (first 2 weeks) | Run dashboard queries; check alert inbox |
| Weekly | Review fallback rate and unanswered questions |
| Monthly | Run health report query; review knowledge gaps; update eval CSV with new utterances from telemetry |
| Quarterly | Full agent review — accuracy, coverage, user feedback, planned improvements |

See `BEST-PRACTICES.md` Section 11 for the full testing and review checklist.
