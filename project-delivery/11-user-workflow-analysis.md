# User Workflow Analysis

Maps the intended user workflows the agent will support — current state, future state with the agent, and the delta. This document ensures the agent is designed around real user behaviour, not assumed behaviour, and informs topic design, conversation flow, and change management.

Complete this alongside `07-functional-design-document.md`. User workflows validate functional requirements from the user's perspective.

---

## How to Use This Document

1. For each workflow the agent will touch, complete one Workflow Analysis Block (Section 3)
2. Complete the Pain Point Analysis (Section 4) to prioritize which workflows to automate first
3. Complete the Future State Summary (Section 5) to validate that the agent genuinely improves the workflow
4. Use the Impact Assessment (Section 6) for change management planning

---

## 1 — Scope of Analysis

| Field | Value |
|-------|-------|
| Agent name | |
| Business processes in scope | |
| User groups affected | |
| Date of analysis | |
| Analysis conducted with | *(list stakeholders, SMEs, user representatives interviewed)* |

---

## 2 — Workflow Inventory

List every user workflow this agent will touch. Prioritize by frequency and pain level.

| # | Workflow name | User persona | Current channel | Frequency | Pain level (1–5) | In scope for agent? |
|---|--------------|-------------|----------------|-----------|-----------------|---------------------|
| W-01 | | | | Per day/week/month | | Yes / No |
| W-02 | | | | | | |
| W-03 | | | | | | |

**Prioritization:** Build the highest-frequency, highest-pain workflows first. Low-frequency workflows are lower ROI and harder to eval.

---

## 3 — Workflow Analysis Blocks

Complete one block per workflow from the inventory. These map directly to use cases in `07-functional-design-document.md`.

---

### W-01: [Workflow Name]

**Linked use case(s):** UC-0[N]

#### Current State (Before Agent)

**Step-by-step process:**

| Step | What the user does | System / channel used | Time taken | Pain point? |
|------|------------------|----------------------|------------|------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

**Current metrics (if known):**

| Metric | Value |
|--------|-------|
| Average end-to-end time | |
| Volume per week / month | |
| Error / rework rate | |
| Escalation rate | |
| User satisfaction score | |

**Top 3 pain points users report:**
1.
2.
3.

**Current workarounds users use:**

*(What do users do when the normal process doesn't work?)*

---

#### Future State (With Agent)

**Step-by-step process with agent:**

| Step | What the user does | Agent response / action | Improvement |
|------|------------------|------------------------|-------------|
| 1 | User types "[example trigger]" | Agent responds: "[expected response]" | |
| 2 | | | |
| 3 | | | |

**Expected metrics (post-agent):**

| Metric | Current | Target | Basis for target |
|--------|---------|--------|-----------------|
| Average end-to-end time | | | |
| Self-service rate | | | |
| Escalation rate | | | |
| User satisfaction score | | | |

**What the agent does NOT change:**

*(Be explicit — unmet expectations are the primary cause of adoption failure)*

---

#### Workflow Delta

| Element | Current state | Future state | Change type |
|---------|--------------|-------------|------------|
| User entry point | [email / portal / phone] | Teams / Copilot | Channel change |
| Authentication required | [Yes/No] | [Yes/No] | |
| Data the user must provide | [what they type/attach today] | [what they say to the agent] | |
| Time to resolution | [current] | [target] | |
| Escalation path | [current path] | [same queue via agent TransferConversation] | |

---

#### User Acceptance Criteria

These map directly to UAT test cases in `04-uat-test-plan.md`.

| # | Scenario | Expected agent behaviour | Pass criteria |
|---|---------|------------------------|--------------|
| 1 | User asks "[exact example question]" | Agent routes to correct topic, collects required info, returns correct response | Response contains [keyword]; no raw error |
| 2 | User provides invalid input (e.g. past date) | Agent re-asks with a clear explanation of the problem | Re-ask prompt appears; user can correct without restarting |
| 3 | Backend system is unavailable | Agent shows safe error message | No raw exception; user is given a next step |
| 4 | User asks an out-of-scope question | Agent redirects with a named resource | Correct redirect message appears within 1 turn |

---

*(Copy this block for each workflow in the inventory.)*

---

## 4 — Pain Point Analysis

Rank the pain points identified across all workflows. This drives prioritization decisions.

| Pain point | Affected workflow(s) | Affected persona(s) | Frequency | Severity | Agent addresses this? |
|-----------|---------------------|-------------------|-----------|---------|----------------------|
| | | | High/Med/Low | High/Med/Low | Yes / Partially / No |

**Workflows the agent does NOT address (and why):**

| Workflow | Reason not automated | Alternative |
|---------|---------------------|------------|
| | Too complex / requires human judgement | Escalation only |
| | Outside agent scope | Separate agent in roadmap |
| | Data access not available | Future integration |

---

## 5 — Future State Summary

A concise summary of the improved workflow experience — used in stakeholder presentations and user communications.

### Before and after

| Dimension | Before | After |
|-----------|--------|-------|
| How users get help | [email/portal/phone/search] | Teams / Microsoft Copilot |
| Time to first response | [e.g. "next business day"] | [e.g. "< 30 seconds"] |
| Available hours | [e.g. "9–5, Mon–Fri"] | 24/7 |
| Escalation | [e.g. "email queue, 4-hour SLA"] | Same queue, faster triage |
| Self-service rate | [e.g. "20%"] | [e.g. "Target 60%"] |

### What users gain

-
-
-

### What users must change

*(Be honest — adoption fails when change impacts are not communicated)*

-
-
-

### What stays the same

*(Reassure users — not everything is changing)*

-
-

---

## 6 — Change Impact Assessment

For each affected user group, assess the change impact and required management actions.

| User group | # affected | Change impact | Training needed? | Communication needed? | Resistance risk | Action |
|-----------|-----------|--------------|-----------------|----------------------|----------------|--------|
| | | Low/Medium/High | Yes/No | Yes/No | Low/Medium/High | |

### Change management actions

| Action | Owner | Timing | Status |
|--------|-------|--------|--------|
| User announcement (see `launch/user-communication-template.md`) | | Before go-live | ☐ |
| Manager briefing (if workflow change is significant) | | 1 week before go-live | ☐ |
| User guide / FAQ document | | By go-live | ☐ |
| Feedback channel set up | | By go-live | ☐ |
| Hypercare monitoring (see `launch/hypercare-guide.md`) | | Weeks 1–2 post-launch | ☐ |

---

## 7 — Workflow Analysis Sign-Off

This document must be reviewed by a representative from each affected user group before design is finalised.

| Role | Name | Reviewed? | Date |
|------|------|-----------|------|
| Developer | | ☐ | |
| Business SME (process owner) | | ☐ | |
| Representative end user | | ☐ | |
| Project Owner | | ☐ | |
