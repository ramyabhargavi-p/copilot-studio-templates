# Governance

Governance documents for responsible, secure, and enterprise-ready deployment of Copilot Studio agents.

## Documents

| File | Purpose | When |
|------|---------|------|
| [`enterprise-ai-governance-framework.md`](enterprise-ai-governance-framework.md) | Full enterprise governance model — roles, lifecycle stage gates, naming standards, data classification, DLP, change control, incident response | Before project start; reviewed quarterly |
| [`ai-ethics-checklist.md`](ai-ethics-checklist.md) | Responsible AI review — fairness, safety, privacy, transparency, accountability, prompt injection | Before UAT sign-off |
| [`security-review.md`](security-review.md) | Security review — auth, data handling, prompt injection, DLP, connectors | Before UAT sign-off |

## When to use each document

| Who you are | Document | When |
|-------------|---------|------|
| Tech Lead / CTO (pre-project) | `enterprise-ai-governance-framework.md` | Before committing to any agent programme |
| Security / Compliance reviewer | `security-review.md` + `enterprise-ai-governance-framework.md` Section 4 | Before UAT |
| Developer + Project Owner | `ai-ethics-checklist.md` + `security-review.md` | Before UAT sign-off |
| Agent Owner (post-launch) | `enterprise-ai-governance-framework.md` Section 2 + 6 | Ongoing — quarterly review |

## Re-run triggers

Re-run `ai-ethics-checklist.md` and `security-review.md` whenever you change:
- Agent instructions (`agent.mcs.yml`)
- Knowledge sources
- Authentication configuration
- Connector connections
- Any topic that handles PII

For significant changes (new topics, new connectors, new data integrations), re-run the full enterprise governance review.
