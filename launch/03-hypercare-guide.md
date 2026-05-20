# Hypercare Guide — First Two Weeks After Launch

> **When to use:** Days 1–14 after go-live. Assign a named owner for each monitoring shift.
> After Day 14, transition to standard operations: see [`../operations/README.md`](../operations/README.md).

Heightened monitoring and response in the period immediately after go-live, when usage ramps up and unexpected issues surface.

---

## Why Hypercare

The first two weeks after launch are the highest-risk period. User behaviour is unpredictable, edge cases appear that eval and UAT missed, and small issues can damage trust quickly if not addressed. A structured hypercare plan prevents issues from escalating.

---

## Hypercare Schedule

### Day 0 — Launch Day

| Time | Activity |
|------|----------|
| Before send | Confirm Application Insights is receiving events (open Copilot Studio → send test message → check Live Metrics) |
| After announcement sent | Monitor Teams/feedback channel for immediate issues |
| 1 hour post-launch | Run the **Dashboard Queries** in `operations/02-monitoring-queries.md` — baseline the key metrics |
| End of day | Run the **Monthly Health Report** query — record the numbers |

### Days 1–3 — Active Monitoring

Check these every morning:

```
1. Error spike? → 02-monitoring-queries.md → Error frequency query
2. High fallback rate? → Fallback rate query
3. Action failures? → Action success / failure rate query
4. Any unanswered questions that reveal knowledge gaps? → Unanswered questions query
```

If any metric looks wrong: follow the relevant procedure in `operations/03-runbook.md`.

**Daily 5-minute check:**
- Any user feedback or complaints in the feedback channel?
- Any alert rules fired overnight?
- Any known Microsoft service incidents affecting the agent?

### Days 4–7 — First Week Review

At end of week 1, run a quick review:

| Metric | Baseline (Day 1) | Week 1 | Trend | Action needed? |
|--------|-----------------|--------|-------|---------------|
| Conversation volume | | | | |
| Fallback rate | | | | |
| Knowledge answer rate | | | | |
| Action success rate | | | | |
| Error count | | | | |

**Week 1 review tasks:**
- [ ] Review unanswered questions → add missing content to knowledge source if needed
- [ ] Review out-of-scope queries → update out-of-scope topic trigger phrases if anything unexpected is routing there
- [ ] Collect user feedback → identify the top 3 improvement requests
- [ ] Confirm alert thresholds are appropriate (not too noisy, not too quiet)
- [ ] Send a brief week 1 update to the stakeholder

### Days 8–14 — Stabilisation

- Move from daily to every-other-day monitoring
- Address any P3/P4 issues identified in week 1
- Finalise the regular monitoring cadence (weekly checks → monthly reports)

---

## Issue Triage During Hypercare

During hypercare, treat issues at one severity level higher than normal:

| Normal severity | Hypercare severity | Target response |
|----------------|-------------------|-----------------|
| P3 | P2 | 1 hour |
| P4 | P3 | 4 hours |
| P1/P2 | P1/P2 | Immediate (unchanged) |

---

## Escalation During Hypercare

If you can't resolve an issue within the response time:

1. Contact the Project Owner immediately
2. If a Microsoft service is involved: open a support ticket at `https://admin.microsoft.com/support`
3. If the issue affects all users: consider temporarily unpublishing (set agent to draft) and communicating a maintenance window to users

---

## Hypercare Exit Criteria

Hypercare ends when ALL of the following are true:

- [ ] At least 7 consecutive days with no P1/P2 incidents
- [ ] Fallback rate stable and below 30%
- [ ] Knowledge answer rate above 80% (if knowledge sources present)
- [ ] Action success rate above 95% (if actions present)
- [ ] Outstanding user feedback items triaged and prioritised
- [ ] Stakeholder has confirmed they are satisfied with launch quality
- [ ] Agent owner is onboarded and comfortable with monitoring and operations

After hypercare: switch to the regular cadence in docs/BEST-PRACTICES.md Section 11.

---

## Hypercare Sign-Off

| Date hypercare started | |
|------------------------|--|
| Date hypercare ended | |
| Exit criteria met | ☐ Yes / ☐ No — outstanding: |
| Signed off by | |
