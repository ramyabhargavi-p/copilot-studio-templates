# UAT Test Plan

Formal user acceptance testing plan. Fill in before UAT starts. Get stakeholder sign-off on each section.

---

## Agent Details

| Field | Value |
|-------|-------|
| Agent name | |
| Environment | |
| Test date | |
| Tester(s) | |
| Stakeholder sign-off | |

---

## Section 1 — Core System Tests

These tests apply to EVERY agent. Run these first.

| # | Test input | Expected topic | Expected response (summary) | Pass / Fail | Notes |
|---|-----------|---------------|----------------------------|-------------|-------|
| S1 | *(open conversation)* | Greeting | Welcome message containing bot name | | |
| S2 | `asdfghjkl` | Fallback (attempt 1) | "Could you rephrase that?" variation | | |
| S3 | `asdfghjkl` | Fallback (attempt 2) | "Could you rephrase that?" variation | | |
| S4 | `asdfghjkl` | Fallback (attempt 3) → Escalate | Transfer message + handoff | | |
| S5 | `speak to a human` | Escalate | Transfer message + handoff | | |
| S6 | *(trigger error condition)* | On Error (test mode) | Full error details displayed | | |
| S7 | *(same error, production mode)* | On Error (prod mode) | Safe message + Reference ID only | | |

---

## Section 2 — Main Topic Tests

Add one block per topic. Use 3 test inputs per topic: exact match, paraphrase, and edge case.

### Topic: _______________

| # | Test input | Expected topic | Expected response (summary) | Pass / Fail | Notes |
|---|-----------|---------------|----------------------------|-------------|-------|
| T1a | *(exact trigger phrase)* | | | | |
| T1b | *(paraphrase)* | | | | |
| T1c | *(edge case / partial phrase)* | | | | |

### Topic: _______________

| # | Test input | Expected topic | Expected response (summary) | Pass / Fail | Notes |
|---|-----------|---------------|----------------------------|-------------|-------|
| T2a | | | | | |
| T2b | | | | | |
| T2c | | | | | |

*(Copy this block for each topic)*

---

## Section 3 — Out-of-Scope Tests

| # | Test input | Expected topic | Expected response includes | Pass / Fail | Notes |
|---|-----------|---------------|--------------------------|-------------|-------|
| O1 | *(out-of-scope phrase 1)* | Out of Scope | Redirect to correct resource | | |
| O2 | *(out-of-scope phrase 2)* | Out of Scope | Redirect to correct resource | | |
| O3 | *(borderline phrase)* | Out of Scope OR Fallback | Does NOT attempt to answer | | |

---

## Section 4 — Knowledge Search Tests (if applicable)

| # | Test input | Expected | Pass / Fail | Notes |
|---|-----------|---------|-------------|-------|
| K1 | *(question the knowledge base should answer)* | Generative answer from knowledge source | | |
| K2 | *(another question in scope of knowledge)* | Generative answer | | |
| K3 | *(question NOT in knowledge base)* | Fallback (not a hallucinated answer) | | |
| K4 | *(check citation markers are NOT visible)* | Clean response, no [1][2] markers | | |

---

## Section 5 — Authentication Tests (if applicable)

| # | Test | Expected | Pass / Fail | Notes |
|---|------|---------|-------------|-------|
| A1 | Open conversation (unauthenticated) | Sign-in prompt appears | | |
| A2 | Complete sign-in | User greeted by name after sign-in | | |
| A3 | Re-open conversation (same session) | No re-authentication prompted | | |
| A4 | ConversationInit runs | `Global.UserDisplayName` populated correctly | | |

---

## Section 6 — Action / Integration Tests (if applicable)

For each connector action:

| # | Test input | Action invoked | Expected response | Error case tested? | Pass / Fail |
|---|-----------|---------------|------------------|-------------------|-------------|
| I1 | | | | Yes / No | |
| I2 | | | | Yes / No | |

**Error case test:** confirm that when the action returns empty, the safe error message appears (not a blank response).

---

## Section 7 — Channel-Specific Tests

| Channel | Test | Expected | Pass / Fail |
|---------|------|---------|-------------|
| Microsoft Teams | Full conversation flow | All formatting renders correctly | |
| Teams mobile | Full conversation flow | Adaptive cards / text displays correctly | |
| Website (if applicable) | Full conversation flow | Embeds and renders correctly | |

---

## Section 8 — Performance Observations

| Observation | Acceptable? | Notes |
|-------------|------------|-------|
| Average response time for knowledge search | < 5 seconds | |
| Average response time for connector actions | < 8 seconds | |
| Sign-in flow completes without timeout | Yes / No | |

---

## UAT Sign-Off

| Item | Confirmed by | Date |
|------|-------------|------|
| All Section 1 tests passed | | |
| All Section 2 (topics) tests passed | | |
| Out-of-scope handling correct | | |
| No hallucinations observed | | |
| Escalation path works in target channel | | |
| Stakeholder approval to publish | | |

**Outstanding issues before go-live:**

| Issue | Severity | Owner | Resolution date |
|-------|---------|-------|----------------|
| | | | |
