# Project Delivery

Documents for delivering a Copilot Studio agent from SOW to production — covering all four phases: Discovery, Design, Build, and Deploy (including Eval and UAT).

## Documents by Phase

| Phase | Document | When | Who |
|-------|----------|------|-----|
| Discovery | [`01-requirements-questionnaire.md`](01-requirements-questionnaire.md) | First stakeholder meeting, before any technical work | Developer + Project Owner |
| Discovery | [`02-technical-discovery.md`](02-technical-discovery.md) | After requirements, before build — with IT/admin | Developer + Environment Admin |
| Design | [`03-agent-design-worksheet.md`](03-agent-design-worksheet.md) | After discovery, before writing YAML | Developer |
| Eval | [`05-eval-scenarios.md`](05-eval-scenarios.md) | During build (topic routing tests) and before UAT | Developer |
| UAT | [`04-uat-test-plan.md`](04-uat-test-plan.md) | After build, before publishing — with stakeholder | Developer + Project Owner |

## Recommended Delivery Sequence

```
1. SOW / project brief received
        │
        ▼
2. DISCOVERY
   01-requirements-questionnaire.md  (with stakeholder)
   02-technical-discovery.md         (with environment admin)
        │
        ▼
3. DESIGN
   03-agent-design-worksheet.md      (developer, internal)
   prompts/system-prompts/           (write agent instructions)
   prompts/ai-prompts/               (generate topic YAML if needed)
        │
        ▼
4. BUILD
   Copy base/ → add components/ → write custom topics and actions
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
   pac copilot push → Publish in Copilot Studio → verify published version
   Configure Application Insights alerts
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
