# Build Specification

The implementation guide that translates approved discovery, design, and governance documents into a working Copilot Studio agent. Every build decision here must trace back to an approved document — no undocumented implementation choices.

**Prerequisite:** The following documents must be approved before this build spec is used:
- `07-functional-design-document.md` ✓ approved
- `08-workflow-logic-design.md` ✓ approved
- `09-technical-design-document.md` ✓ approved

---

## Document Control

| Field | Value |
|-------|-------|
| Agent name | |
| schemaName | |
| Target environment (dev) | |
| Developer | |
| Build start date | |
| Target build-complete date | |

---

## 1 — Agent Configuration

### 1.1 — Base setup

| Step | Action | Source document | Done? |
|------|--------|----------------|-------|
| 1 | Copy `base/` into your agent project folder: `agents/<schemaName>/` | README quick start | ☐ |
| 2 | Set `schemaName` in `settings.mcs.yml` — must be unique per environment | `09-TDD` Section 1.1 | ☐ |
| 3 | Set `displayName` in `agent.mcs.yml` | `07-FDD` Section 1 | ☐ |
| 4 | Set `authenticationMode` in `settings.mcs.yml` | `09-TDD` Section 3.1 | ☐ |
| 5 | Set `GenerativeActionsEnabled` in `settings.mcs.yml` | `09-TDD` Section 1.1 | ☐ |
| 6 | Write the system prompt in `agent.mcs.yml` → `instructions` | `09-TDD` Section 1.2 pattern; `07-FDD` Sections 1–4 | ☐ |
| 7 | Add conversation starters (3–5) in `agent.mcs.yml` | `07-FDD` Section 2 — user personas | ☐ |
| 8 | Verify date context injection: `Date: {Text(Today(),DateTimeFormat.LongDate)}` is in instructions | `docs/BEST-PRACTICES.md` Section 1 | ☐ |

### 1.2 — System prompt verification checklist

Before proceeding to topics, verify the system prompt against the approved design:

| Check | Required content | Present? |
|-------|-----------------|---------|
| Identity | One-sentence purpose from `07-FDD` Section 1 | ☐ |
| Can-help list | All UC topics listed specifically | ☐ |
| Cannot-help list | All out-of-scope items from `07-FDD` Section 7, each with a named redirect | ☐ |
| Grounding instructions | Pattern from `09-TDD` Section 2 matching agent type | ☐ |
| Date injection | `{Text(Today(),DateTimeFormat.LongDate)}` | ☐ |
| Escalation guidance | When and how to offer human handoff | ☐ |
| Guardrails | Refusal of legal/medical/financial advice; system prompt disclosure refusal | ☐ |
| Tone | Matches persona defined in `07-FDD` Section 2 | ☐ |

---

## 2 — Knowledge Source Integration

Complete only if the agent uses knowledge sources. Reference `06-content-audit.md` — all sources must have passed the content audit before this step.

### 2.1 — SharePoint knowledge source

| Step | Action | Configuration | Done? |
|------|--------|--------------|-------|
| 1 | Confirm SharePoint site is indexed (check Site Settings → Search) | Site URL from `02-technical-discovery.md` | ☐ |
| 2 | Confirm all documents are checked in (not draft) | Content owner sign-off in `06-content-audit.md` | ☐ |
| 3 | Copy `components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml` | | ☐ |
| 4 | Set `siteUrl` and `libraryName` | From `02-technical-discovery.md` | ☐ |
| 5 | Set component ID: `<schemaName>.knowledge.SharePoint` | `schemaName` from `settings.mcs.yml` | ☐ |
| 6 | Replace all `_REPLACE` node ID suffixes | | ☐ |
| 7 | Add `components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml` | | ☐ |
| 8 | Add `components/topics/remove-citations/RemoveCitations.topic.mcs.yml` | Required for all knowledge agents | ☐ |
| 9 | `pac copilot push` to dev environment | | ☐ |
| 10 | Test in test canvas: ask 3 questions the knowledge base should answer | | ☐ |
| 11 | Test in test canvas: ask 2 questions NOT in the knowledge base — confirm Fallback fires | | ☐ |

### 2.2 — Knowledge source quality verification

| Test | Expected | Actual | Pass? |
|------|----------|--------|-------|
| Ask "[question that is in the docs]" | Answer from document content | | ☐ |
| Ask "[question that is in the docs]" | Answer from document content | | ☐ |
| Ask "[question not in the docs]" | "I couldn't find that" — no hallucination | | ☐ |
| Ask "[question not in the docs]" | "I couldn't find that" — no hallucination | | ☐ |
| Confirm no `[1][2]` citation markers | Clean response | | ☐ |

If any knowledge test fails: review the document content (not the agent YAML) — the content audit missed a gap.

---

## 3 — Conversational Flow Implementation

Build topics in this order: system topics first, then business topics, then optional components.

### 3.1 — Topic build sequence

| Order | Topic | Source | Use case | Done? |
|-------|-------|--------|---------|-------|
| 1 | Greeting | `base/topics/Greeting.topic.mcs.yml` | UC-01 | ☐ |
| 2 | Fallback | `base/topics/Fallback.topic.mcs.yml` | UC-02 | ☐ |
| 3 | OnError | `base/topics/OnError.topic.mcs.yml` | All | ☐ |
| 4 | Escalation | `components/topics/escalation/` | UC-02 + explicit escalation | ☐ |
| 5 | ConversationInit | `components/topics/conversation-init/` | All authenticated flows | ☐ |
| 6 | Auth | `components/topics/auth/` | If `authenticationMode` ≠ `None` | ☐ |
| 7 | OutOfScope | `components/topics/out-of-scope/` | All out-of-scope items from `07-FDD` Section 7 | ☐ |
| 8 | KnowledgeSearch | `components/topics/knowledge-search/` | If knowledge sources present | ☐ |
| 9 | [Business topic: UC-03] | `components/topics/action-invoke/` or custom | UC-03 | ☐ |
| 10 | [Business topic: UC-04] | | UC-04 | ☐ |
| N | Disambiguation | `components/topics/disambiguation/` | If multiple topics have overlapping triggers | ☐ |

### 3.2 — Per-topic build checklist

For each topic, complete all items before moving to the next.

**[ ] Topic: _______________**

| Check | Source | Done? |
|-------|--------|-------|
| Trigger phrases cover all vocabulary variations from workflow analysis | `11-user-workflow-analysis.md` Section 3 | ☐ |
| Slot-filling: all required variables collected and validated | `08-workflow-logic-design.md` Section 3 | ☐ |
| All `ConditionGroup` nodes have `elseActions` branch | `09-TDD` Section 4 | ☐ |
| Action output validated with `!IsBlank(Topic.ActionResponse)` | `09-TDD` Section 4 | ☐ |
| Error path shows safe message with next step and named contact | `09-TDD` Section 4.2 | ☐ |
| Confirmation card shown before any write operation | `09-TDD` Section 5.1 | ☐ |
| `LogCustomTelemetryEvent` node fires `Topic.Started` at entry | Telemetry convention in `README.md` | ☐ |
| `LogCustomTelemetryEvent` fires outcome event (`Action.Succeeded` / `Action.Failed`) | Telemetry convention | ☐ |
| All `_REPLACE` node IDs replaced with unique 6-char strings | YAML convention | ☐ |
| All `<PLACEHOLDER>` values replaced | YAML convention | ☐ |
| Component ID prefixed with `schemaName` | YAML convention | ☐ |
| Tested in test canvas: happy path | | ☐ |
| Tested in test canvas: error path (action fails / backend down) | | ☐ |
| Tested in test canvas: out-of-scope question handled correctly | | ☐ |

### 3.3 — Cross-topic wiring

After all topics are built, verify cross-topic references:

| Check | Done? |
|-------|-------|
| Fallback `BeginDialog` references the correct Escalation topic dialog name | ☐ |
| OutOfScope `BeginDialog` (if escalation is offered) references the correct Escalation topic | ☐ |
| ConversationInit condition guard: `=IsBlank(Global.UserCountry)` prevents duplicate runs | ☐ |
| All `BeginDialog` targets exist — no references to non-existent topics | ☐ |
| Global variable names in topics match declarations in `components/variables/global-variable/` | ☐ |

---

## 4 — Action Configuration

Complete only if the agent calls connector or MCP actions.

### 4.1 — Per-action build checklist

**[ ] Action: _______________**

| Check | Source | Done? |
|-------|--------|-------|
| Connector logical name confirmed with environment admin | `02-technical-discovery.md` | ☐ |
| Connector operation name matches the exact API operation (case-sensitive) | Test in Power Platform connector explorer | ☐ |
| All input parameters defined and mapped from topic variables | `08-workflow-logic-design.md` Section 2 | ☐ |
| Output mapping: connector response mapped to `Topic.ActionResponse` | | ☐ |
| Connection reference exists in the target environment | Env admin confirms | ☐ |
| Action ID prefixed with `schemaName` | | ☐ |
| All `_REPLACE` IDs replaced | | ☐ |
| Tested: successful call returns expected data structure | | ☐ |
| Tested: calling with invalid inputs returns a handled error (not a null crash) | | ☐ |
| Tested: connector unavailable — `ConditionGroup` catches the null response | | ☐ |

---

## 5 — Security and DLP Alignment

### 5.1 — Security implementation checklist

| Control | Implementation | Verified? |
|---------|---------------|---------|
| Prompt injection tests I1–I5 all pass | `09-TDD` Section 3.2 | ☐ |
| No PII in any `LogCustomTelemetryEvent` `customDimensions` | Review all telemetry nodes | ☐ |
| All error messages contain no system details (API names, endpoints, queue names) | Review all error `SendActivity` nodes | ☐ |
| `OnError` production branch tested — shows Reference ID only, not full error | Test in canvas with `System.IsTestMode = false` simulation | ☐ |
| Connection references use service accounts (not personal accounts) | Env admin confirms | ☐ |
| Azure AD app registration permissions are minimum required | `09-TDD` Section 3.1 | ☐ |
| `governance/security-review.md` completed and signed | Security reviewer | ☐ |

### 5.2 — DLP alignment verification

| Check | Done? |
|-------|-------|
| All connectors used in this agent are in the Business tier of the DLP policy | ☐ |
| No HTTP (anonymous) connectors are used | ☐ |
| No third-party AI connectors are used | ☐ |
| DLP policy has been confirmed with environment admin | ☐ |
| Agent does not attempt to call a connector blocked by DLP (test in dev environment) | ☐ |

---

## 6 — Build Validation

### 6.1 — Pre-push validation

Run before every `pac copilot push`:

```bash
# Check for unreplaced placeholders
grep -r "<" . --include="*.yml"

# Check for unreplaced node IDs
grep -r "_REPLACE" . --include="*.yml"

# Check for duplicate node IDs (PowerShell)
Get-ChildItem -Recurse -Filter "*.yml" | Select-String "^\s*id:" | Group-Object {$_.Line.Trim()} | Where-Object {$_.Count -gt 1}
```

### 6.2 — Post-push smoke test (dev environment)

| Test | Expected | Pass? |
|------|----------|-------|
| Open conversation | Greeting fires; welcome message shown | ☐ |
| Type `asdfghjkl` 3 times | Fallback retries × 2 then escalates | ☐ |
| Type `speak to a human` | Escalation topic fires | ☐ |
| Trigger an error (if possible in test canvas) | Safe error message shown; `Agent.ErrorOccurred` in App Insights | ☐ |
| Type an out-of-scope question | Correct redirect shown; no attempt to answer | ☐ |
| Type a knowledge question (if applicable) | Answer from document content; no citation markers | ☐ |
| Complete a full business use case (UC-03) | Correct response; confirmation card shown; action succeeds | ☐ |
| Simulate action failure | Safe error message with named next step | ☐ |

### 6.3 — Telemetry verification

After smoke test, confirm events appear in Application Insights (allow 5 minutes):

| Event | Expected after which test | Present? |
|-------|--------------------------|---------|
| `Conversation.Started` | Opening the conversation | ☐ |
| `Agent.FallbackTriggered` | Typing nonsense | ☐ |
| `Agent.EscalationTriggered` | 3× fallback or explicit escalation | ☐ |
| `Knowledge.SearchInvoked` | Knowledge question | ☐ |
| `Topic.Started` | Business topic | ☐ |
| `Action.Succeeded` or `Action.Failed` | Action invocation | ☐ |

### 6.4 — Eval run

| Step | Action | Result |
|------|--------|--------|
| 1 | Build eval CSV using `prompts/ai-prompts/generate-eval-cases.md` | |
| 2 | Save to `evals/<schemaName>-eval.csv` | |
| 3 | Run eval in Copilot Studio or via Copilot Studio Kit | |
| 4 | Topic routing accuracy | ___% (target: ≥ 85%) |
| 5 | Out-of-scope routing accuracy | ___% (target: 100%) |
| 6 | Response groundedness | ___% (target: ≥ 80%) |
| 7 | Fix any topic with accuracy < 85% — add trigger phrases | |
| 8 | Re-run eval after fixes | |
| 9 | Eval results committed to `evals/` folder | ☐ |

---

## 7 — Build Sign-Off

The developer signs off that the build is complete, tested, and ready for promotion to UAT.

| Check | Done? |
|-------|-------|
| All topics built and tested | ☐ |
| All actions tested (success and failure paths) | ☐ |
| Knowledge sources verified | ☐ |
| All security controls implemented | ☐ |
| DLP alignment confirmed | ☐ |
| Eval: ≥ 85% routing accuracy | ☐ |
| Telemetry verified in Application Insights | ☐ |
| All YAML committed to version control | ☐ |
| `governance/ai-ethics-checklist.md` completed | ☐ |
| `governance/security-review.md` completed | ☐ |

| Role | Name | Sign-off | Date |
|------|------|---------|------|
| Developer | | ☐ | |
| Tech Lead | | ☐ | |

**Ready for promotion to UAT:** Yes / No

If No — outstanding items:
