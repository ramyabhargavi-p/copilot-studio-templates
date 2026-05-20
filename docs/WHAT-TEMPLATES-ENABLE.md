# What Templates Enable — Complete Development Lifecycle

A grounded analysis of what these templates do across every phase of agent development:
what is genuinely hard without them, what is time-consuming, and what best practices
are baked in that most developers would miss or skip.

---

## The development lifecycle map

```
Phase 0  →  Phase 1  →  Phase 2  →  Phase 3  →  Phase 4  →  Phase 5  →  Phase 6  →  Phase 7
Decision    Discovery    Design       Build        Test         Deploy       Launch       Operate
```

Templates cover all eight phases. Most teams use only the Build phase templates and skip the
rest — which is why agents can pass UAT but struggle in production.

---

## Phase 0 — Decision: Should we build this?

**Template:** `project-delivery/00-ai-decision-framework.md`

Most teams skip this phase entirely and start building. This document answers the question
before a line of YAML is written:

- Is Copilot Studio the right platform, or should this be M365 Agents SDK / Azure AI Foundry?
- Do the users and knowledge sources qualify for this platform?
- Is the business problem solvable with a conversational agent or is a different tool better?

**Without it:** Teams build the wrong thing. The cost of switching platforms mid-project is
measured in weeks.

---

## Phase 1 — Discovery: What exactly are we building?

**Templates:** `project-delivery/02-requirements-questionnaire.md`,
`project-delivery/03-technical-discovery.md`, `project-delivery/04-user-workflow-analysis.md`

These are not paperwork. They surface the blockers early:

- Is the knowledge source (SharePoint, website) actually indexed and accessible?
- Are the Power Platform connectors available in the target environment? *(A connector not
  available in the environment is a build blocker — discovering this on day 10 wastes a week.)*
- Who owns the content? Who updates it? What happens when it goes stale?
- What are the exact user workflows the agent needs to support?

**Without it:** Discovery happens during build. You find the connector is not available,
the SharePoint library is not indexed, or the user workflow has a branch nobody designed for.

---

## Phase 2 — Design: What will it do and how?

**Templates:** `project-delivery/05-agent-design-worksheet.md`,
`project-delivery/07-functional-design-document.md`,
`project-delivery/08-workflow-logic-design.md`,
`project-delivery/09-technical-design-document.md`,
`project-delivery/10-build-specification.md`,
`project-delivery/01-enterprise-readiness-assessment.md`,
`governance/enterprise-ai-governance-framework.md`

### Enterprise readiness assessment — the most underused template in the repo

`01-enterprise-readiness-assessment.md` is a 36-item scoring checklist across five
dimensions: strategic alignment, technical infrastructure, operational readiness, governance,
and risk. Scores below 28/40 are a formal no-go.

**What it catches that teams miss:**
- Under-licensed environments (Copilot Studio sessions, Power Automate Premium, Entra P1)
  throttle silently in production — no error, just degraded performance
- Application Insights must be provisioned *before* build — adding it later loses all
  early telemetry and complicates the monitoring setup
- Connector availability must be confirmed in the exact target environment before build
  starts — not in a different environment, not "it should be available"
- Operational support model (L1/L2/L3 owners, on-call rotation, SLAs) must be defined
  before launch, not after the first incident

### Governance framework — delivery blocker for all roles

`governance/enterprise-ai-governance-framework.md` defines stage gates that must be passed
before proceeding to the next phase. It cannot be retrofitted after build.

**Non-obvious requirements it encodes:**
- Every agent must have a named Owner, Developer, and Security Reviewer assigned
- Data classification tier must be set before design (Public / Internal / Confidential /
  Restricted-PII / Regulated) — this determines what connectors and logging are allowed
- DLP policy minimums must be applied to the environment before any build work begins
- A formal agent registry entry is required — name, purpose, owner, environment, data tier,
  review date

---

## Phase 3 — Build: Writing the YAML

### Patterns that are nearly impossible to discover without templates

These are platform behaviours that require either deep experience or finding an obscure
documentation page. Most developers working in Copilot Studio for the first time will not
know these exist.

---

**Citation removal from AI responses**
`components/topics/remove-citations/RemoveCitations.topic.mcs.yml`

AI-generated answers include citation markers like `[1][2][3]` that are confusing to end
users. Removing them requires:

1. An `OnGeneratedResponse` hook — a trigger most developers do not know exists
2. Setting `System.ContinueResponse = false` to suppress the default AI response
3. Running nested `Substitute()` calls to strip each citation marker
4. Capping at `Left(text, 3800)` — the SharePoint multiline column character limit, which
   causes silent truncation if exceeded

None of this is documented prominently. Most developers either leave citations in or try
to suppress them in the system prompt (which does not work reliably).

---

**Disambiguation when multiple topics match**
`components/topics/disambiguation/Disambiguation.topic.mcs.yml`

When a user's message scores similarly against two or more topics, the default behaviour is
to pick one arbitrarily. This template handles the `OnSelectIntent` trigger to:

1. Present a choice card using `System.Recognizer.IntentOptions` (a system table variable
   that is not documented clearly)
2. Add a "None of these" escape option using `EditTable`
3. Route the selection back to the correct topic or fall through to fallback
4. Log `Agent.DisambiguationTriggered` with the match count

**Without it:** Ambiguous queries route to the wrong topic silently. Users get wrong
answers with no indication that the agent was uncertain.

---

**Conversation initialisation with M365 user profile**
`components/topics/conversation-init/ConversationInit.topic.mcs.yml`

Loading the signed-in user's display name, country, and custom glossary at conversation
start requires:

1. `OnActivity` trigger with condition `IsBlank(Global.UserCountry)` — prevents the topic
   from re-running on every message
2. Office 365 Users connector in **Invoker** connection mode — uses the signed-in user's
   identity, not the bot's service account
3. Error handling that allows conversation to continue even if the profile call fails
4. `SearchAndSummarizeContent` for glossary loading — a Copilot Studio YAML node kind
   (`kind: SearchAndSummarizeContent`), not a Power Fx function

**Without it:** Users are greeted as "user" with no personalisation, and the glossary is
not loaded — meaning the agent cannot expand internal acronyms used in questions.

---

**Glossary injection via hidden variable**
`components/variables/glossary-var/Glossary.variable.mcs.yml`

The glossary variable uses `aIVisibility: Hidden`. This is a non-obvious flag that prevents
the AI orchestrator from reading the variable directly. Instead, the glossary is injected
precisely at a chosen point in the system prompt using `{Global.Glossary}`.

**Without it:** The glossary either leaks into AI context in the wrong place, or the
developer uses a normal visible variable and the AI interprets it as a user message.

---

**CSAT collection without PII risk**
`components/topics/feedback/Feedback.topic.mcs.yml`

The feedback flow has three deliberate design decisions that most developers get wrong:

1. **No free-text input.** Every developer's instinct is to add a "tell us more" text box.
   This creates PII risk — users often type personal information. The template uses a
   category dropdown instead.
2. **Star rating only fires if the thumbs response is negative.** Not on every conversation.
3. **`Global.FeedbackShown` guard** prevents the CSAT card from firing more than once per
   conversation. Without this, topics that call the feedback flow as a sub-dialog can
   trigger it multiple times.

---

**Action safety tiers**
`docs/ACTION-SAFETY-PATTERNS.md` + topic templates

Any topic that writes, updates, or deletes data must follow a tiered confirmation pattern:

- **Tier 1 (read-only):** No confirmation needed.
- **Tier 2 (creates/writes):** Confirmation adaptive card with `action.submit` data binding.
  The cancel path must **never** reach the connector call — a common wiring mistake that
  causes the action to fire even when the user clicks Cancel.
- **Tier 3 (deletes/irreversible):** Must **not** execute inline. Routes to an async
  Power Automate approval flow. The action only fires after a named approver responds via
  email. This pattern is entirely absent from the UI and requires building a separate flow.

**Without it:** Tier 2 actions fire on cancel (data corruption), and Tier 3 actions execute
instantly with no approval (irreversible damage in production).

---

### Best practices baked in that developers consistently miss

| Pattern | What it prevents | Where it is |
|---------|-----------------|-------------|
| `System.FallbackCount` retry loop | Single error message with no retry — users give up | `base/topics/Fallback` |
| OnError test-vs-production split | Debug details leaked to end users in production | `base/topics/OnError` |
| OutOfScope as a separate topic | Unknown intent and known out-of-scope treated the same — metrics unusable | `base/topics/OutOfScope` |
| Telemetry at topic START not only end | Topics that error out are invisible in monitoring | Every topic template |
| `priority: -1` on KnowledgeSearch | Knowledge search fires before specific topics — wrong answers on known intents | `components/topics/knowledge-search` |
| `aIVisibility: Hidden` on PII variables | User data exposed to AI orchestrator and potentially logged | `components/variables` |
| `IsBlank()` guard on ConversationInit | Profile loaded on every message — redundant connector calls and cost | `components/topics/conversation-init` |
| `Left(text, 3800)` cap on response text | Silent truncation when response stored to SharePoint multiline column | `components/topics/remove-citations` |
| Unique node IDs (`_REPLACE` pattern) | YAML merge conflicts when two developers copy the same template | All topic templates |

---

## Phase 4 — Test: Structured verification before release

**Templates:** `project-delivery/13-uat-test-plan.md`,
`project-delivery/12-eval-scenarios.md`,
`governance/ai-ethics-checklist.md`

### UAT test plan — not a spot-check

`13-uat-test-plan.md` defines eight test categories that must all pass before release:

- **S1–S7:** System tests — fallback retries exactly 3×, escalation triggers, OnError fires
  in test mode correctly, safe message in production mode
- **Topic tests:** Exact phrase, paraphrase, and edge case per topic
- **Out-of-scope:** Boundary cases — the agent must not hallucinate answers to known
  out-of-scope queries
- **Knowledge search:** Answer from source, graceful fallback when source has no answer,
  no citation markers visible to user
- **Auth flow:** Sign-in prompt, user greeted by name, no re-authentication on session resume
- **Action tests:** Both the success path AND the cancel path (cancel must leave the target
  system unchanged — this test catches the Tier 2 wiring mistake above)

**Without it:** Teams run spot tests. Cancel path wiring bugs, citation markers, and
out-of-scope hallucinations go to production.

### AI ethics checklist — mandatory sign-off

`governance/ai-ethics-checklist.md` is a 7-dimension responsible AI checklist mapped to
Microsoft's RAI principles. Notable requirements:

- **85% routing accuracy** is a hard threshold — measured by running eval scenarios, not
  estimated. Below 85% blocks release.
- **Prompt injection resistance** — 5 attack scenarios must be tested and passed in the
  test canvas (not assumed to pass)
- **Fairness** — agent must not route different user groups to different quality paths
- Every item must have documented evidence, not a checkbox

---

## Phase 5 — Deploy: Consistent promotion across environments

**Templates:** `ci-cd/push-on-pr.yml`, `ci-cd/promote-dev-to-uat.yml`,
`ci-cd/promote-uat-to-prod.yml`, `ci-cd/solution-build-and-deploy.yml`

### What these pipelines do that manual promotion cannot

1. **Placeholder validation** — the CI/CD pipeline fails if any `<PLACEHOLDER>` or
   `_REPLACE` node ID is still in the YAML. Without this check, placeholder text reaches
   production silently.
2. **GitHub environment approval gate** — promotion to UAT and Prod requires a named
   approver to click Approve in GitHub. No one can bypass this.
3. **Push goes to draft, not published** — the pipeline pushes to the draft agent. A human
   must publish after reviewing in the test canvas. Automation cannot accidentally publish
   to live users.
4. **Audit trail** — every promotion is a GitHub Actions run with a log, a PR link, and
   a timestamp. Manual promotion has none of this.

**Time to build from scratch:** 3–5 hours per pipeline. Correctly wiring the Power Platform
CLI authentication (`CLIENT_ID`, `CLIENT_SECRET`, `TENANT_ID`) in GitHub secrets, handling
the PAC CLI install step, and setting up the GitHub environment approval gate requires
specific knowledge of both platforms.

---

## Phase 6 — Launch: Controlled rollout

**Templates:** `launch/launch-checklist.md`, `launch/hypercare-guide.md`,
`launch/user-communication-template.md`

### Hypercare — the phase most teams skip

`launch/hypercare-guide.md` defines a structured post-launch monitoring period:

- **Week 1–2:** Daily review of fallback rate, escalation rate, error frequency
- **Week 3–4:** Weekly review, address content gaps surfaced by monitoring
- **Month 2+:** Monthly review cadence

Without hypercare, agents degrade silently. Fallback rates rise as users ask questions the
agent was not designed for. Knowledge source content goes stale. No one notices until users
complain.

---

## Phase 7 — Operate: Running in production

**Templates:** `operations/runbook.md`, `operations/monitoring-queries.md`,
`operations/alert-setup.md`, `operations/user-feedback.md`

### Monitoring queries — only work with consistent telemetry schema

`operations/monitoring-queries.md` contains ready-to-paste KQL queries for Application
Insights:

```kusto
-- Fallback rate over time
customEvents
| where name == "Agent.FallbackTriggered"
| summarize FallbackCount=count() by bin(timestamp, 1d)
```

These queries work **only** because the base/ templates enforce consistent event names
(`Agent.FallbackTriggered`, `Agent.ErrorOccurred`, `Topic.Started`, etc.) across every
agent. If different developers named their events differently, these queries return nothing.

**Ready queries cover:**
- Conversation volume and topic routing breakdown
- Fallback rate, escalation rate, knowledge answer rate
- Action success vs failure rate
- Error frequency by error code
- Alert: error spike (>5 in 15 min), high fallback (>40% in 1 hour), agent down
  (zero conversations in 2 hours)
- Investigation: trace a single conversation end-to-end, find knowledge gaps from unanswered
  questions

**Time to write from scratch:** Application Insights KQL expertise + knowledge of the exact
event names + correct property key names. 1–2 days for a developer unfamiliar with KQL.

### Runbook — on-call decisions that require platform knowledge

`operations/runbook.md` encodes operational knowledge that only comes from having been
on-call for a Copilot Studio agent. Examples:

- Error code 401 → re-authenticate the connection in Power Platform admin
- Error code 404 on connector → check the operation ID has not changed in a connector update
- Knowledge search failing → check SharePoint indexing job status, not the agent
- Auth sign-in loop → check the app registration redirect URI, not the agent configuration

**Without it:** On-call developers file a P1, spend an hour diagnosing the wrong component,
and escalate before checking the actual cause.

---

## Summary: impossible, time-consuming, or best-practice by category

### Impossible or near-impossible without deep platform knowledge

| Capability | Why it is non-obvious |
|------------|----------------------|
| Citation removal from AI responses | `OnGeneratedResponse` hook + `System.ContinueResponse = false` — undiscovered without deep platform knowledge |
| Disambiguation on tied intent scores | `OnSelectIntent` + `System.Recognizer.IntentOptions` table manipulation — not prominently documented |
| Glossary injection via hidden variable | `aIVisibility: Hidden` + precise injection point in system prompt — no equivalent concept in most platforms |
| Tier 3 async approval for destructive actions | Inline execution must never happen — requires a separate Power Automate flow, non-obvious architecture |
| ConversationInit with Invoker connection mode | Connection mode semantics and `IsBlank()` guard — trial-and-error to discover |

### Very time-consuming without templates

| Capability | Time without templates |
|------------|----------------------|
| Full CI/CD pipelines (Dev → UAT → Prod with approval gates) | 3–5 hours per pipeline |
| Enterprise readiness assessment (36-item, stage-gated) | 1–2 days to create from scratch |
| UAT test plan (8 test categories, structured sign-off) | 3–4 hours per engagement |
| Application Insights monitoring queries (KQL) | 1–2 days without KQL expertise |
| On-call runbook with platform-specific diagnostics | Accumulated over multiple incidents |
| AI ethics checklist (7-dimension RAI sign-off) | Requires RAI expertise to write |
| Governance framework (stage gates, data classification, DLP) | Legal/compliance expertise + platform knowledge |

### Non-obvious best practices consistently missed without templates

| Practice | What goes wrong without it |
|----------|--------------------------|
| 3-retry loop before escalation | Single error message — users give up |
| Test-vs-production error handler | Debug stack traces shown to end users |
| `Global.FeedbackShown` CSAT guard | CSAT card fires multiple times per conversation |
| No free-text in feedback cards | PII captured in CSAT responses |
| OutOfScope as a separate topic from Fallback | Monitoring cannot distinguish known gaps from unknown intent |
| Telemetry at topic start, not only end | Errored topics are invisible in monitoring |
| Cancel path verification in action tests | Cancel executes the action (data corruption) |
| Placeholder validation in CI/CD | `<PLACEHOLDER>` text reaches production |
| Hypercare monitoring for first 2 weeks | Agent degrades silently post-launch |
| Named owner, DLP policy, registry entry before build | Governance cannot be retrofitted after launch |
