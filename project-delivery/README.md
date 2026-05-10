# Project Delivery Documents

> **Delivery sequence:** Work through documents 00 → 13 in order.
> Each document feeds the next — don't skip 00 (decision framework) or 02 (technical discovery).
> Completed documents become the project record — store in SharePoint alongside the agent YAML.
>
> | Doc | When to complete |
> |-----|-----------------|
> | `00-ai-decision-framework.md` | Before kickoff — is Copilot Studio the right tool? |
> | `01-requirements-questionnaire.md` | Week 1 — discovery with business owner |
> | `02-technical-discovery.md` | Week 1-2 — environment, connectors, auth |
> | `03-agent-design-worksheet.md` | Week 2 — topics, actions, knowledge sources |
> | `04-uat-test-plan.md` | Week 3 — before build starts |
> | `05-eval-scenarios.md` | Week 3 — routing accuracy test cases |
> | `06+` | Supporting design artifacts as needed |

14 numbered documents covering every phase from decision to post-launch. Work through them in phase order — do not skip phases.

---

## Phase map — which files belong to which phase

### Phase 1 — Decision *(before any technical work)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`00-ai-decision-framework.md`](00-ai-decision-framework.md) | Business owner + AI engineer | 1–2 hr |
| [`10-enterprise-readiness-assessment.md`](10-enterprise-readiness-assessment.md) | Tech lead + security | 1–2 hr |

**Gate:** Both signed off → proceed to Discovery.

---

### Phase 2 — Discovery *(what to build and for whom)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`01-requirements-questionnaire.md`](01-requirements-questionnaire.md) | Developer + business owner | 2–3 hr |
| [`02-technical-discovery.md`](02-technical-discovery.md) | Developer + IT admin | 1–2 hr |
| [`11-user-workflow-analysis.md`](11-user-workflow-analysis.md) | Developer + business SME | 1–2 hr |

**Gate:** All three complete → proceed to Design.

---

### Phase 3 — Design *(what exactly to build)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`03-agent-design-worksheet.md`](03-agent-design-worksheet.md) | Developer | 1–2 hr |
| [`06-content-audit.md`](06-content-audit.md) | Developer + content owner | 2–3 hr |
| [`07-functional-design-document.md`](07-functional-design-document.md) | Developer + business owner | 3–4 hr |
| [`08-workflow-logic-design.md`](08-workflow-logic-design.md) | Developer | 2–3 hr |
| [`09-technical-design-document.md`](09-technical-design-document.md) | Developer + security | 2–3 hr |

**Gate:** Files 07 and 09 signed off by business owner and security → proceed to Build.

---

### Phase 4 — Build *(implement in YAML)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`12-build-specification.md`](12-build-specification.md) | Developer | Ongoing during build |
| [`13-ai-engineer-realtime-guide.md`](13-ai-engineer-realtime-guide.md) | AI engineer reference | Read before build starts |

---

### Phase 5 — Test *(verify before any user sees it)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`05-eval-scenarios.md`](05-eval-scenarios.md) | Developer + tester | 2–3 hr |
| [`04-uat-test-plan.md`](04-uat-test-plan.md) | Tester + business owner | 3–4 hr |

**Gate:** Both complete and signed off → proceed to Launch.

---

## Quick reference — file by number

| # | File | Phase | Required |
|---|------|-------|---------|
| 00 | `00-ai-decision-framework.md` | 1 — Decision | Yes |
| 01 | `01-requirements-questionnaire.md` | 2 — Discovery | Yes |
| 02 | `02-technical-discovery.md` | 2 — Discovery | Yes |
| 03 | `03-agent-design-worksheet.md` | 3 — Design | Yes |
| 04 | `04-uat-test-plan.md` | 5 — Test | Yes |
| 05 | `05-eval-scenarios.md` | 5 — Test | Yes |
| 06 | `06-content-audit.md` | 3 — Design | If knowledge sources used |
| 07 | `07-functional-design-document.md` | 3 — Design | Yes |
| 08 | `08-workflow-logic-design.md` | 3 — Design | Yes |
| 09 | `09-technical-design-document.md` | 3 — Design | Yes |
| 10 | `10-enterprise-readiness-assessment.md` | 1 — Decision | Yes |
| 11 | `11-user-workflow-analysis.md` | 2 — Discovery | Yes |
| 12 | `12-build-specification.md` | 4 — Build | Yes |
| 13 | `13-ai-engineer-realtime-guide.md` | All | AI engineer reference |

→ Full delivery sequence with roles and skills: [`../START-HERE.md`](../START-HERE.md)
