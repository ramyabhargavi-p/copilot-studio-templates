# Functional Design Document (FDD)

A structured specification of what the agent must do, for whom, under what conditions, and to what standard. This document is the contract between the business and the development team. Every topic, action, and knowledge source built during Phase 3 (Build) must trace back to a functional requirement here.

Complete this document after `05-agent-design-worksheet.md` and before writing any YAML.

---

## Document Control

| Field | Value |
|-------|-------|
| Agent name | |
| Version | 1.0 |
| Author | |
| Reviewed by | |
| Status | Draft / Under Review / Approved |
| Approval date | |

---

## 1 — Agent Purpose Statement

Write a single sentence that defines exactly what this agent does, for whom, and within what context. This sentence becomes the first line of the agent's system prompt.

> **Template:** "[Agent Name] helps [target audience] [accomplish what] within [scope/context]."

**Approved purpose statement:**

```
[WRITE THE PURPOSE STATEMENT HERE]
```

**Validation test:** Hand this sentence to someone unfamiliar with the project. If they can correctly predict whether a given user question is in scope or not, the statement is precise enough.

---

## 2 — User Personas

Define the people who will use this agent. Be specific — different personas have different vocabulary, expectations, and permissions.

### Persona 1: [Primary User]

| Field | Detail |
|-------|--------|
| Role / job title | |
| Technical familiarity | Low / Medium / High |
| Primary goal when using the agent | |
| Typical questions they will ask | |
| What frustrates them in current process | |
| Channel they will use | Teams / Copilot / Website |
| Authenticated? | Yes / No |
| Language(s) | |

### Persona 2: [Secondary User] *(copy block as needed)*

| Field | Detail |
|-------|--------|
| Role / job title | |
| Technical familiarity | |
| Primary goal | |
| Typical questions | |
| Channel | |
| Authenticated? | |

---

## 3 — Functional Use Cases

Each use case maps to one or more topics in the agent. Number them — requirements in later documents (UAT, eval) reference these numbers.

**Use case format:**

> **UC-[N]: [Name]**
> - **Actor:** Who triggers this
> - **Trigger:** What the user says or does
> - **Preconditions:** What must be true before this can run
> - **Main flow:** The expected path
> - **Alternate flows:** Variations that still succeed
> - **Exception flows:** What can go wrong and what happens
> - **Postconditions:** State after success
> - **Acceptance criteria:** How QA/UAT verifies this works

---

### UC-01: Greeting and Orientation

- **Actor:** Any user
- **Trigger:** User opens a new conversation
- **Preconditions:** None
- **Main flow:** Agent sends a welcome message identifying itself, states what it can help with, and offers conversation starters
- **Alternate flows:** N/A
- **Exception flows:** If the channel does not support rich formatting, a plain text greeting is sent
- **Postconditions:** `Conversation.Started` telemetry event is logged
- **Acceptance criteria:** Welcome message contains the agent name; at least one conversation starter is shown; `Conversation.Started` event appears in Application Insights within 5 minutes

---

### UC-02: Unknown Intent / Fallback

- **Actor:** Any user
- **Trigger:** User sends a message that does not match any topic
- **Preconditions:** None
- **Main flow:** Agent asks the user to rephrase; retries up to 3 times
- **Alternate flows:** After 3 failed attempts, agent escalates to human
- **Exception flows:** If escalation queue is unavailable, agent provides contact details
- **Postconditions:** `Agent.FallbackTriggered` or `Agent.EscalationTriggered` event logged
- **Acceptance criteria:** Rephrasing prompt appears on attempt 1 and 2; escalation triggers on attempt 3; no raw errors shown

---

### UC-03: [Business Use Case Name]

- **Actor:**
- **Trigger:**
- **Preconditions:**
- **Main flow:**
  1.
  2.
  3.
- **Alternate flows:**
  - A1:
  - A2:
- **Exception flows:**
  - E1: [condition] → [what the agent does]
  - E2:
- **Postconditions:**
- **Acceptance criteria:**
  - [ ]
  - [ ]
  - [ ]

*(Copy this block for each use case. Minimum: one block per topic you plan to build.)*

---

## 4 — Business Rules

Rules that govern the agent's behaviour beyond simple conversation flow. These must be encoded in the system prompt (`agent.mcs.yml` instructions) or enforced in topic logic.

| Rule ID | Rule statement | Where enforced | Priority |
|---------|---------------|----------------|---------|
| BR-01 | The agent must not provide [prohibited advice type] | System prompt instructions | Critical |
| BR-02 | If the user expresses distress, the agent must immediately escalate | Escalation topic trigger phrases | Critical |
| BR-03 | All responses about [policy area] must state "check with [authority] for your specific situation" | System prompt instructions | High |
| BR-04 | The agent must not confirm, deny, or speculate about [sensitive topic] | System prompt out-of-scope section | High |
| BR-05 | | | |

---

## 5 — Data Requirements

What data the agent reads, writes, or transforms. This informs the connector and variable design.

### Data inputs (what the agent reads)

| Data item | Source | Sensitivity | Used in use case(s) |
|-----------|--------|-------------|---------------------|
| User display name | Microsoft 365 profile | Low — internal | All personalised responses |
| User country | Microsoft 365 profile | Low — internal | Locale-aware responses |
| [Business data item] | [System / connector] | [Low / Medium / High / PII] | UC-0X |

### Data outputs (what the agent writes or submits)

| Data item | Destination | Sensitivity | Triggered by use case(s) |
|-----------|------------|-------------|--------------------------|
| [Form submission] | [System / connector] | | UC-0X |
| Telemetry events | Application Insights | Low — anonymised | All |

### Data that must NOT be stored or logged

| Data item | Reason |
|-----------|--------|
| Full name in telemetry | GDPR / privacy policy |
| Employee ID in telemetry | Internal PII policy |
| [Other PII] | |

---

## 6 — Integration Requirements

Each integration must be confirmed as available before the build starts. See `03-technical-discovery.md` for the technical details.

| Integration ID | System | Operation | Connector logical name | Required for use case(s) | Confirmed available? |
|---------------|--------|-----------|----------------------|--------------------------|---------------------|
| INT-01 | Microsoft 365 Users | UserProfileV2 | `shared_office365users` | All authenticated flows | ☐ |
| INT-02 | [System name] | [Operation] | `shared_[name]` | UC-0X | ☐ |

---

## 7 — Out-of-Scope Requirements

What this agent explicitly will not do. Documenting this prevents scope creep during build and ensures the agent's `OutOfScope` topic is comprehensive.

| Topic | Why out of scope | Where to redirect users |
|-------|-----------------|------------------------|
| [Topic 1] | [Reason — e.g. handled by another system/team] | [Contact / resource] |
| [Topic 2] | | |

---

## 8 — Non-Functional Requirements

| Requirement | Target | Notes |
|-------------|--------|-------|
| Response time — knowledge search | < 5 seconds | P95 in production |
| Response time — connector action | < 8 seconds | P95 in production |
| Availability | Follows Power Platform SLA (99.9%) | |
| Supported languages | [List] | Primary language in system prompt |
| Supported channels | [Teams / Copilot / Website] | Test each channel before UAT |
| Authentication | [None / AAD] | Defined in `settings.mcs.yml` |
| Audit logging | All conversations traceable via ConversationId | Application Insights |

---

## 9 — Constraints and Assumptions

### Constraints

| # | Constraint |
|---|-----------|
| C1 | The agent must operate within the existing Power Platform environment — no new environment provisioning |
| C2 | No third-party connectors — only Microsoft-certified connectors |
| C3 | [Other constraint from discovery] |

### Assumptions

| # | Assumption | Risk if wrong |
|---|-----------|---------------|
| A1 | The SharePoint document library will be indexed and up to date before go-live | Knowledge search returns wrong or no answers |
| A2 | The escalation queue `[QUEUE_NAME]` will be active when the agent is published | Escalation fails silently |
| A3 | [Other assumption] | |

---

## 10 — Sign-Off

This document must be approved before Phase 3 (Build) begins. Any change to a functional requirement after this point is a scope change and requires a new approval.

| Role | Name | Approved? | Date |
|------|------|-----------|------|
| Developer | | ☐ | |
| Project Owner | | ☐ | |
| Stakeholder | | ☐ | |

**Outstanding questions before approval:**

| # | Question | Owner | Due |
|---|----------|-------|-----|
| | | | |
