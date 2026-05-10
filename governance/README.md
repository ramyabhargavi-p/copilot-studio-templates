# Governance

Three documents required before every production go-live. Not optional.

## When to complete these checklists

| Checklist | Complete by | Who |
|-----------|-------------|-----|
| `ai-ethics-checklist.md` | Before UAT — before any real users interact with the agent | Agent Owner + Developer |
| `security-review.md` | Before moving to Production — after UAT sign-off | Security team + Developer |
| `enterprise-ai-governance-framework.md` | Before project kickoff — for new agent types | AI Governance team |

> These are blocking gates — the CI/CD pipeline's UAT and Production promote steps require sign-off evidence.
> Store completed checklists in your project delivery folder or SharePoint alongside the agent artifacts.

---

## What to complete and when

| File | What it covers | Complete when |
|------|---------------|--------------|
| [`ai-ethics-checklist.md`](ai-ethics-checklist.md) | Responsible AI — fairness, safety, privacy, transparency, prompt injection resistance | Before UAT begins |
| [`security-review.md`](security-review.md) | Security — connector permissions, DLP, action safety tiers, data classification | Before UAT begins |
| [`enterprise-ai-governance-framework.md`](enterprise-ai-governance-framework.md) | Full org-level governance policy — roles, lifecycle, change control, incident response | Read once at project start; apply throughout |

---

## How these three relate

```
enterprise-ai-governance-framework.md   ← The policy. Read this first.
        │
        ├── ai-ethics-checklist.md      ← Tick-box verification of the Responsible AI rules in the policy
        └── security-review.md         ← Tick-box verification of the security rules in the policy
```

The framework is the policy document — it defines the rules.
The two checklists are how you verify those rules are met before go-live.

---

## Minimum for every agent

Even for a simple internal FAQ bot:
- [ ] `ai-ethics-checklist.md` — complete all items, get business owner sign-off
- [ ] `security-review.md` — complete all items, get security reviewer sign-off

The enterprise framework is mandatory for agents that handle sensitive data, are used by external users, or are organisation-wide.

→ Governance pre-check: [`../project-delivery/00-ai-decision-framework.md`](../project-delivery/00-ai-decision-framework.md) Step 10
