# Project Delivery

Documents for delivering a Copilot Studio agent from SOW to production — covering all phases: Discovery, Design, Build, Eval, UAT, and Deploy.

## Documents by Phase

| Phase | Document | When | Who |
|-------|----------|------|-----|
| Pre-project | [`10-enterprise-readiness-assessment.md`](10-enterprise-readiness-assessment.md) | Before committing to any agent program — licensing, infra, governance | Tech Lead + CTO + Security |
| Discovery | [`01-requirements-questionnaire.md`](01-requirements-questionnaire.md) | First stakeholder meeting, before any technical work | Developer + Project Owner |
| Discovery | [`02-technical-discovery.md`](02-technical-discovery.md) | After requirements, before build — with IT/admin | Developer + Environment Admin |
| Discovery | [`11-user-workflow-analysis.md`](11-user-workflow-analysis.md) | Before design — map current and future user workflows | Developer + Business SME |
| Design | [`03-agent-design-worksheet.md`](03-agent-design-worksheet.md) | After discovery — high-level component decisions | Developer |
| Design | [`06-content-audit.md`](06-content-audit.md) | Before adding knowledge sources — assess document readiness | Developer + Content Owner |
| Design | [`07-functional-design-document.md`](07-functional-design-document.md) | After discovery — define what the agent must do, use cases, business rules | Developer + Project Owner |
| Design | [`08-workflow-logic-design.md`](08-workflow-logic-design.md) | After FDD — design conversation flows, branching logic, state management | Developer |
| Design | [`09-technical-design-document.md`](09-technical-design-document.md) | After workflow design — security, prompt patterns, error handling architecture | Developer + Security |
| Build | [`12-build-specification.md`](12-build-specification.md) | During build — step-by-step implementation checklist aligned to approved designs | Developer |
| Eval | [`05-eval-scenarios.md`](05-eval-scenarios.md) | During build (topic routing tests) and before UAT | Developer |
| UAT | [`04-uat-test-plan.md`](04-uat-test-plan.md) | After build, before publishing — with stakeholder | Developer + Project Owner |

## Recommended Delivery Sequence

```
1. SOW / project brief received
        │
        ▼
1.5. PRE-PROJECT (enterprise / multi-agent programs)
   10-enterprise-readiness-assessment.md  (tech lead + security + exec sponsor)
        │
        ▼
2. DISCOVERY
   01-requirements-questionnaire.md  (with stakeholder)
   02-technical-discovery.md         (with environment admin)
   11-user-workflow-analysis.md       (with business SME + representative users)
        │
        ▼
3. DESIGN
   03-agent-design-worksheet.md           (developer, internal — component selection)
   06-content-audit.md                    (if using knowledge sources — assess documents first)
   07-functional-design-document.md       (use cases, business rules, data requirements)
   08-workflow-logic-design.md            (conversation flows, branching, state management)
   09-technical-design-document.md        (security, prompt patterns, error handling)
   prompts/system-prompts/               (write agent instructions using approved patterns)
   prompts/ai-prompts/prompt-engineering-patterns.md  (select patterns for system prompt)
        │
        ▼
4. BUILD
   12-build-specification.md              (implementation checklist — aligned to approved designs)
   governance/ai-ethics-checklist.md + governance/security-review.md
   pac copilot push → smoke test in Copilot Studio test canvas
        │
        ▼
5. EVAL
   05-eval-scenarios.md              (build eval CSV)
   prompts/ai-prompts/generate-eval-cases.md  (generate test cases with AI)
   Run evaluation in Copilot Studio → fix routing accuracy < 85%
        │
        ▼
6. UAT
   04-uat-test-plan.md               (with stakeholder)
   prompts/ai-prompts/review-agent.md (AI audit — fix all CRITICAL items)
   BEST-PRACTICES.md Section 11      (full testing checklist)
   Stakeholder sign-off
        │
        ▼
7. DEPLOY
   launch/launch-checklist.md        (all items must pass before publish)
   pac copilot push → Publish in Copilot Studio → verify published version
   launch/user-communication-template.md  (announce to users)
   operations/alert-setup.md         (configure Azure Monitor alerts)
        │
        ▼
8. HYPERCARE (weeks 1–2)
   launch/hypercare-guide.md         (daily monitoring + response)
        │
        ▼
9. ONGOING OPERATIONS
   operations/monitoring-queries.md  (weekly/monthly health checks)
   operations/runbook.md             (incident response)
   Hand over monitoring + repo to agent owner
```

## Common Risks by Question

| If this answer is missing | Risk |
|--------------------------|------|
| Q5 (out-of-scope list) | Agent answers questions it shouldn't — liability risk |
| Q6 (escalation path) | Fallback crashes — references Escalate topic that doesn't exist |
| Q9 (content sources) | Knowledge search returns empty answers at launch |
| Q11 (compliance constraints) | Legal/compliance issue post-launch |
| Technical: connector availability | Blocked during build — delay to delivery |
| Technical: escalation queue name | Fallback broken at launch |
| Technical: Application Insights | No monitoring visibility at launch |
| Eval skipped | Routing accuracy unknown at UAT — rework after stakeholder review |
| UAT test cases not written before build | UAT becomes exploratory — scope creep and delays |
