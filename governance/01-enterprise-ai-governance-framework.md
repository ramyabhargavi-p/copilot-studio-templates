# Enterprise AI Agent Governance Framework

Defines the policies, processes, roles, and controls that govern the design, build, deployment, and operation of Copilot Studio AI agents across the organization.

This framework applies to every agent — from a single-topic FAQ bot to a multi-specialist orchestrator. Governance is not optional and is not a post-launch activity. It starts at project initiation.

---

## 1 — Governing Principles

These principles take precedence over all implementation decisions.

| Principle | What it means in practice |
|-----------|--------------------------|
| **Human oversight** | Every agent must have a human escalation path. No agent operates without a way to reach a person. |
| **Least privilege** | Agents access only the data and systems they need for their defined purpose. No broad-scope connectors. |
| **Transparency** | Users know they are talking to an AI. Agent responses acknowledge uncertainty rather than fabricate confidence. |
| **Accountability** | Every agent has a named owner who is responsible for its accuracy, security, and ongoing fitness. |
| **Auditability** | Every agent interaction is traceable via ConversationId in Application Insights. |
| **Reversibility** | Every agent can be taken offline within 15 minutes. Every change can be rolled back. |

---

## 2 — Roles and Responsibilities

### Core roles (required for every agent)

| Role | Responsibilities | Who fills this role |
|------|-----------------|---------------------|
| **Agent Owner** | Single accountable person. Signs off on go-live. Receives incident alerts. Approves content changes. Reviews quarterly reports. | A named individual, not a team. |
| **Developer** | Builds and maintains the agent YAML. Runs eval. Deploys via approved pipeline. | Power Platform developer with Copilot Studio training. |
| **Project Owner** | Defines requirements. Signs off on UAT. Approves scope changes. | Business stakeholder with authority over the process being automated. |
| **Environment Admin** | Manages Power Platform environments, DLP policies, connection references, and licensing. | Power Platform / M365 admin. |
| **Security Reviewer** | Completes `governance/03-security-review.md` before each go-live. | Security or IT compliance function. |

### Organizational roles (for multi-agent programs)

| Role | Responsibilities |
|------|----------------|
| **CoE Lead** | Maintains the agent registry. Enforces naming and taxonomy standards. Reviews new agent proposals. Manages the shared template library. |
| **AI Ethics Reviewer** | Completes `governance/02-ai-ethics-checklist.md`. Escalates Responsible AI concerns. |
| **Legal / Data Privacy** | Reviews agents handling PII, regulated data, or providing guidance that carries legal risk. |

---

## 3 — Agent Lifecycle Governance

Every agent follows this lifecycle. No stage can be skipped.

```
PROPOSAL ──→ ASSESSMENT ──→ DESIGN ──→ BUILD ──→ REVIEW ──→ DEPLOY ──→ OPERATE ──→ RETIRE
    │               │            │          │          │           │          │           │
  CoE review    Readiness    FDD + WLA   YAML +     Security   Go-live     Monthly    Decom
  required      assessment   approved    tests      + ethics   checklist   metrics    notice
```

### Stage gates

| Gate | Documents required | Approvers |
|------|--------------------|-----------|
| Proposal → Assessment | Agent proposal (use case, persona, scope, data) | CoE Lead |
| Assessment → Design | `01-enterprise-readiness-assessment.md` passed | Tech Lead + CoE Lead |
| Design → Build | `07-functional-design-document.md` + `08-workflow-logic-design.md` approved | Developer + Project Owner |
| Build → Review | All YAML committed; eval ≥ 85% routing accuracy | Developer |
| Review → Deploy | `governance/02-ai-ethics-checklist.md` + `governance/03-security-review.md` passed; UAT signed off | Agent Owner + Security |
| Deploy → Operate | `launch/01-launch-checklist.md` complete | Agent Owner |
| Operate → Retire | Retirement notice issued; users informed; agent decommissioned | Agent Owner + CoE Lead |

---

## 4 — Agent Registry

The CoE maintains a central registry of all agents across the organization. Every agent must be registered before it enters production.

### Registry fields (one row per agent)

| Field | Description |
|-------|-------------|
| Agent ID | Unique identifier (e.g. `AGT-001`) |
| Agent name | Display name |
| schemaName | Power Platform schema name (must be unique across all environments) |
| Purpose | One-sentence purpose statement from FDD |
| Agent owner | Named individual and email |
| Developer | Named individual and email |
| Environment (Prod) | Production environment URL |
| Channel(s) | Teams / Copilot / Website |
| Go-live date | |
| Last review date | |
| Next review due | |
| Status | Active / Under review / Deprecated |
| Sensitive data? | Yes / No — if Yes, list data types |
| External integrations | List connectors used |

---

## 5 — Naming and Taxonomy Standards

Consistent naming prevents collisions, makes agents discoverable, and enables governance tooling to query the environment programmatically.

### Agent naming

| Element | Standard | Example |
|---------|----------|---------|
| Display name | `[Function] Assistant` or `[Function] Agent` — plain English | `HR Assistant`, `IT Helpdesk Agent` |
| schemaName | `[org_prefix]_[function]_[environment_code]` — lowercase, underscores | `cyclotron_hr_assistant_prod` |
| Environment suffix | `_dev`, `_uat`, `_prod` | `cyclotron_hr_assistant_dev` |

### Component naming within an agent

| Component | Pattern | Example |
|-----------|---------|---------|
| Topic files | `[FunctionName].topic.mcs.yml` (PascalCase) | `GetLeaveBalance.topic.mcs.yml` |
| Action files | `[ActionName]-action.mcs.yml` | `leave-balance-action.mcs.yml` |
| Knowledge files | `[Source]-knowledge.mcs.yml` | `sharepoint-knowledge.mcs.yml` |
| Node IDs | `[camelCaseDescription]_[6charAlphanumeric]` | `sendGreeting_a1b2c3` |

### Telemetry event naming

All events use `{Category}.{Action}` — see the Telemetry Events Reference in root `README.md`. Never create event names outside this convention.

---

## 6 — Data Classification and Handling Policy

### Data tiers

| Tier | Definition | Agent handling rule |
|------|-----------|---------------------|
| **Public** | Information already publicly available | May be surfaced freely; no restrictions |
| **Internal** | Organization-internal but not sensitive | Agent may surface to authenticated internal users only |
| **Confidential** | Business-sensitive; limited audience | Agent may surface only to authorized users; access must be confirmed with data owner |
| **Restricted / PII** | Personal data, HR records, financial data | Agent must not log, store, or repeat PII; DPO review required |
| **Regulated** | Legal, medical, financial advice | Agent must not provide; must escalate to qualified professional |

### PII handling rules (mandatory)

1. Never write PII to `customDimensions` in any `LogCustomTelemetryEvent` node
2. Never include PII in `SendActivity` text that is also logged
3. Use `Global.UserDisplayName` (first name only acceptable) for personalization — never employee ID, salary, medical data
4. Any agent topic that handles PII must be reviewed in `governance/03-security-review.md` Section 2

---

## 7 — DLP Policy Requirements

Power Platform DLP policies are the first line of defense. Every environment hosting agents must have a DLP policy applied before any agent is built in it.

### Minimum DLP policy for agent environments

| Connector | Classification | Rationale |
|-----------|---------------|-----------|
| Microsoft 365 Users | Business | Required for ConversationInit |
| SharePoint | Business | Required for knowledge sources |
| Office 365 Outlook | Business | Approved email connector |
| [Approved LOB connectors] | Business | Approved on a case-by-case basis |
| HTTP with Azure AD | Business | Approved for internal APIs only |
| HTTP (anonymous) | Non-business (blocked) | Prevents data exfiltration to arbitrary URLs |
| All third-party AI connectors | Non-business (blocked) | Prevents use of non-approved AI services |
| [All other connectors] | Non-business (blocked) unless explicitly approved | |

**Process for adding a connector:** Developer submits request → Environment Admin reviews against data classification → Security approves → DLP policy updated → Developer can proceed.

---

## 8 — Change Control

### Change categories

| Category | Description | Approval required | Testing required |
|----------|-------------|------------------|-----------------|
| **Minor** | Trigger phrase additions, response text changes, content updates | Agent Owner | Spot eval (5–10 rows) |
| **Significant** | New topic, new action, new knowledge source, authentication change | Agent Owner + Project Owner | Full eval + UAT section |
| **Major** | New connector, schema change, system prompt rewrite, new channel | Agent Owner + Security Reviewer | Full eval + full UAT + security review |
| **Emergency** | P1 fix — agent down or returning errors to all users | Agent Owner (verbal) — document post-incident | Post-fix spot test |

### Change process

```
1. Developer creates a branch from main (feature/fix-description)
2. Make changes; update YAML; update eval CSV if topics changed
3. Run eval — confirm accuracy ≥ 85%
4. Push branch; create PR
5. CI/CD pipeline validates placeholders, node IDs, and pushes to dev env
6. Developer tests in dev environment test canvas
7. Get approval (per change category table above)
8. Merge to main → CI/CD promotes to UAT
9. UAT testing (scope per change category)
10. Merge / tag release → CI/CD promotes to prod
11. Post-deployment smoke test
12. Close change record
```

---

## 9 — Incident Governance

### Severity definitions (AI-specific)

| Severity | Definition | Example |
|----------|-----------|---------|
| P1 — Critical | Agent is down or producing harmful / incorrect responses to all users | All conversations failing; agent giving dangerous advice |
| P2 — High | Major feature broken; significant user impact | All knowledge search returning no answers; authentication broken |
| P3 — Medium | Partial degradation; some users affected; no harmful output | One topic routing incorrectly; single action failing |
| P4 — Low | Cosmetic, accuracy, or content issue; no user harm | Citation markers showing; slightly off-scope routing |

### AI-specific escalation: harmful or inappropriate output

If the agent produces output that is harmful, discriminatory, legally risky, or in violation of the Responsible AI principles:

1. **Immediately:** Agent Owner takes the agent offline (unpublish or disable the channel)
2. **Within 1 hour:** Notify the CoE Lead and Legal
3. **Within 4 hours:** Root cause identified — was this a prompt injection, a knowledge source issue, or a system prompt gap?
4. **Fix:** Do not republish until `governance/02-ai-ethics-checklist.md` is re-run and all affected items pass
5. **Post-incident:** Document in the incident log and update the ethics checklist with the new test case

---

## 10 — Retirement and Decommissioning

Agents must be formally retired when they are no longer needed. Abandoned agents consume licensing, contain stale content, and present a security risk.

### Retirement triggers

- Agent has had zero conversations for 60 consecutive days
- The business process the agent supports has been replaced or discontinued
- The agent is being replaced by a new version with breaking changes

### Retirement process

| Step | Action | Owner | Timing |
|------|--------|-------|--------|
| 1 | Confirm retirement decision with Project Owner and Agent Owner | CoE Lead | At trigger |
| 2 | Notify users via `launch/02-user-communication-template.md` (adapted for retirement) | Agent Owner | 4 weeks before |
| 3 | Disable agent channels (Teams, website) in Copilot Studio | Developer | 1 week before |
| 4 | Unpublish agent | Developer | Retirement date |
| 5 | Archive YAML in git with a `retired/` tag | Developer | Retirement date |
| 6 | Remove agent from the registry | CoE Lead | Within 1 week |
| 7 | Confirm Application Insights data retention policy (default 90 days) | Environment Admin | Within 1 week |
| 8 | Revoke app registration if agent-specific | Environment Admin | Within 2 weeks |

---

## 11 — Governance Review Cadence

| Review | Frequency | Participants | Output |
|--------|-----------|-------------|--------|
| Individual agent review | Quarterly | Agent Owner + Developer | Updated metrics, knowledge gaps addressed, roadmap items prioritised |
| CoE portfolio review | Quarterly | CoE Lead + all Agent Owners | Registry updated, cross-agent patterns identified, shared component improvements |
| DLP and security review | Annually | Environment Admin + Security | DLP policy updated, app registrations rotated, risk register reviewed |
| AI ethics framework review | Annually | CoE Lead + Legal + HR | Ethics checklist updated for new Microsoft AI policies and regulatory changes |
| Full governance framework review | Annually | CoE Lead + Tech Lead + Legal | This document updated |
