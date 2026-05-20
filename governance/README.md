# Governance

Three documents required before every production go-live. Not optional.

## When to complete these checklists

| Checklist | Complete by | Who |
|-----------|-------------|-----|
| `02-ai-ethics-checklist.md` | Before UAT — before any real users interact with the agent | Agent Owner + Developer |
| `03-security-review.md` | Before moving to Production — after UAT sign-off | Security team + Developer |
| `01-enterprise-ai-governance-framework.md` | Before project kickoff — for new agent types | AI Governance team |

> These are blocking gates — the CI/CD pipeline's UAT and Production promote steps require sign-off evidence.
> Store completed checklists in your project delivery folder or SharePoint alongside the agent artifacts.

---

## What to complete and when

| File | What it covers | Complete when |
|------|---------------|--------------|
| [`02-ai-ethics-checklist.md`](02-ai-ethics-checklist.md) | Responsible AI — fairness, safety, privacy, transparency, prompt injection resistance | Before UAT begins |
| [`03-security-review.md`](03-security-review.md) | Security — connector permissions, DLP, action safety tiers, data classification | Before UAT begins |
| [`01-enterprise-ai-governance-framework.md`](01-enterprise-ai-governance-framework.md) | Full org-level governance policy — roles, lifecycle, change control, incident response | Read once at project start; apply throughout |

---

## How these three relate

```
01-enterprise-ai-governance-framework.md   ← The policy. Read this first.
        │
        ├── 02-ai-ethics-checklist.md      ← Tick-box verification of the Responsible AI rules in the policy
        └── 03-security-review.md         ← Tick-box verification of the security rules in the policy
```

The framework is the policy document — it defines the rules.
The two checklists are how you verify those rules are met before go-live.

---

## Minimum for every agent

Even for a simple internal FAQ bot:
- [ ] `02-ai-ethics-checklist.md` — complete all items, get business owner sign-off
- [ ] `03-security-review.md` — complete all items, get security reviewer sign-off

The enterprise framework is mandatory for agents that handle sensitive data, are used by external users, or are organisation-wide.

→ Governance pre-check: [`../project-delivery/00-ai-decision-framework.md`](../project-delivery/00-ai-decision-framework.md) Step 10
