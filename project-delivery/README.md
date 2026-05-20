# Project Delivery Documents

14 documents covering every phase from decision to post-launch. Work through them in phase order — do not skip phases. Completed documents are your project record; store them in SharePoint alongside the agent YAML.

> **Do not skip:** `00-ai-decision-framework.md` (is this the right tool?) and `03-technical-discovery.md` (what can we build with?). Every other doc depends on these two.

---

## Phase map — which files belong to which phase

### Phase 1 — Decision *(before any technical work)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`00-ai-decision-framework.md`](00-ai-decision-framework.md) | Business owner + AI engineer | 1–2 hr |
| [`01-enterprise-readiness-assessment.md`](01-enterprise-readiness-assessment.md) | Tech lead + security | 1–2 hr |

**Gate:** Both signed off → proceed to Discovery.

---

### Phase 2 — Discovery *(what to build and for whom)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`02-requirements-questionnaire.md`](02-requirements-questionnaire.md) | Developer + business owner | 2–3 hr |
| [`03-technical-discovery.md`](03-technical-discovery.md) | Developer + IT admin | 1–2 hr |
| [`04-user-workflow-analysis.md`](04-user-workflow-analysis.md) | Developer + business SME | 1–2 hr |

**Gate:** All three complete → proceed to Design.

---

### Phase 3 — Design *(what exactly to build)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`05-agent-design-worksheet.md`](05-agent-design-worksheet.md) | Developer | 1–2 hr |
| [`06-content-audit.md`](06-content-audit.md) | Developer + content owner | 2–3 hr |
| [`07-functional-design-document.md`](07-functional-design-document.md) | Developer + business owner | 3–4 hr |
| [`08-workflow-logic-design.md`](08-workflow-logic-design.md) | Developer | 2–3 hr |
| [`09-technical-design-document.md`](09-technical-design-document.md) | Developer + security | 2–3 hr |

**Gate:** Files 07 and 09 signed off by business owner and security → proceed to Build.

---

### Phase 4 — Build *(implement in YAML)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`10-build-specification.md`](10-build-specification.md) | Developer | Ongoing during build |
| [`11-ai-engineer-realtime-guide.md`](11-ai-engineer-realtime-guide.md) | AI engineer reference | Read before build starts |

---

### Phase 5 — Test *(verify before any user sees it)*
| File | Who fills it in | Time |
|------|----------------|------|
| [`12-eval-scenarios.md`](12-eval-scenarios.md) | Developer + tester | 2–3 hr |
| [`13-uat-test-plan.md`](13-uat-test-plan.md) | Tester + business owner | 3–4 hr |

**Gate:** Both complete and signed off → proceed to Launch.

---

## Quick reference — file by number

| # | File | Phase | Required |
|---|------|-------|---------|
| 00 | `00-ai-decision-framework.md` | 1 — Decision | Yes |
| 01 | `01-enterprise-readiness-assessment.md` | 1 — Decision | Yes |
| 02 | `02-requirements-questionnaire.md` | 2 — Discovery | Yes |
| 03 | `03-technical-discovery.md` | 2 — Discovery | Yes |
| 04 | `04-user-workflow-analysis.md` | 2 — Discovery | Yes |
| 05 | `05-agent-design-worksheet.md` | 3 — Design | Yes |
| 06 | `06-content-audit.md` | 3 — Design | If knowledge sources used |
| 07 | `07-functional-design-document.md` | 3 — Design | Yes |
| 08 | `08-workflow-logic-design.md` | 3 — Design | Yes |
| 09 | `09-technical-design-document.md` | 3 — Design | Yes |
| 10 | `10-build-specification.md` | 4 — Build | Yes |
| 11 | `11-ai-engineer-realtime-guide.md` | All | AI engineer reference |
| 12 | `12-eval-scenarios.md` | 5 — Test | Yes |
| 13 | `13-uat-test-plan.md` | 5 — Test | Yes |

→ Full delivery sequence with roles and skills: [`../ENGINEERING-PLAYBOOK.md`](../ENGINEERING-PLAYBOOK.md)
