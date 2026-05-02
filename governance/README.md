# Governance

Checklists for responsible, secure deployment of Copilot Studio agents. Both documents are required sign-offs before go-live.

## Documents

| File | Purpose | When |
|------|---------|------|
| [`ai-ethics-checklist.md`](ai-ethics-checklist.md) | Responsible AI review — fairness, safety, privacy, transparency, accountability | Before UAT sign-off |
| [`security-review.md`](security-review.md) | Security review — auth, data handling, prompt injection, DLP, connectors | Before UAT sign-off |

## Who completes these

Both checklists should be completed jointly by the **Developer** and **Project Owner**. For regulated industries or enterprise deployments, involve a Security or Compliance reviewer.

## Re-run triggers

Re-run both checklists whenever you change:
- Agent instructions (`agent.mcs.yml`)
- Knowledge sources
- Authentication configuration
- Connector connections
- Any topic that handles PII
