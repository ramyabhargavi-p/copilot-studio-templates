# Agent Design Worksheet

Bridge between the completed requirements questionnaire and the actual YAML files.
Fill this in after requirements, before writing any YAML. One worksheet per agent.

---

## 1. Agent Identity

| Field | Value | Maps to |
|-------|-------|---------|
| Agent name (internal) | | `agent.mcs.yml` → `componentName` |
| Agent display name | | `agent.mcs.yml` → `displayName` |
| Schema name (lowercase, underscores) | | `settings.mcs.yml` → `schemaName` |
| Authentication mode | None / ManualAzureAD / Integrated | `settings.mcs.yml` → `authenticationMode` |
| AI model | GPT5Chat / GPT4o | `agent.mcs.yml` → `modelNameHint` |
| Language | 1033 (English) / other | `settings.mcs.yml` → `language` |
| Generative actions enabled | Yes / No | `settings.mcs.yml` → `GenerativeActionsEnabled` |

---

## 2. Agent Instructions

Complete this section fully before writing YAML. Paste directly into `agent.mcs.yml`.

**What the agent does (1-2 sentences):**
>

**In-scope list (3-5 items, specific):**
- 
- 
- 

**Out-of-scope list (with redirect for each):**
| Out-of-scope area | Redirect target |
|------------------|-----------------|
| | |
| | |

**Tone:** Formal / Conversational / Technical / Empathetic

**Response length guideline:** Under ___ words unless detail is requested

**Escalation trigger sentence:**
>

**Date context needed?** Yes / No
If yes, add to top of instructions: `Date: {Text(Today(),DateTimeFormat.LongDate)}`

---

## 3. Topics to Build

List every topic the agent needs. For each, identify which template to start from.

| Topic display name | Trigger phrases (5+) | Template | Action needed? |
|-------------------|---------------------|---------|----------------|
| | | `question-branch` / `action-invoke` | Yes / No |
| | | | |
| | | | |
| | | | |
| | | | |

**System topics (always include):**

| Topic | Template | Notes |
|-------|----------|-------|
| Greeting | `base/Greeting` | Update welcome text |
| Fallback | `base/Fallback` | Set `<AGENT_SCHEMA>` |
| On Error | `base/OnError` | No changes needed |
| Escalate | `components/escalation` | Set queue name |
| Out of Scope | `components/out-of-scope` | Add trigger phrases from requirements |

**Optional topics (based on requirements):**

| Include? | Topic | Template |
|----------|-------|---------|
| ☐ | Sign In | `components/auth` |
| ☐ | Conversation Init | `components/conversation-init` |
| ☐ | Knowledge Search | `components/knowledge-search` |
| ☐ | Remove Citations | `components/remove-citations` |
| ☐ | Disambiguation | `components/disambiguation` |

---

## 4. Actions to Build

One row per connector operation.

| Action display name | Connector | Connection reference | Operation ID | Mode | Purpose |
|--------------------|-----------|---------------------|-------------|------|---------|
| | | | | Invoker/Caller | |
| | | | | | |

For each action, is a wrapping topic needed?
- [ ] Yes → use `components/topics/action-invoke` template, name: _______________
- [ ] No → `GenerativeActionsEnabled: true` — AI invokes directly

---

## 5. Knowledge Sources

| Source name | Type | URL / Path | Scope | Citations visible? |
|------------|------|------------|-------|-------------------|
| | SharePoint / Website | | | Yes / No |
| | | | | |

Add `knowledge-search` topic? Yes / No
Add `remove-citations` topic? Yes / No

---

## 6. Global Variables

| Variable name (camelCase) | Display name | Default value | AI visible? | Set by |
|--------------------------|-------------|--------------|-------------|--------|
| | | | Yes/No | conversation-init / topic |
| | | | | |

---

## 7. Child Agents (Orchestrator pattern only)

| Child agent name | Domain | Input from parent | Output to parent |
|-----------------|--------|------------------|-----------------|
| | | | |
| | | | |

---

## 8. Conversation Starters

Write 3 conversation starters that reflect the most common user needs:

| Title | Text |
|-------|------|
| | |
| | |
| | |

---

## 9. Component Checklist

Final check before building. Tick each component included in this agent:

**Base (always):**
- [ ] `base/agent.mcs.yml`
- [ ] `base/settings.mcs.yml`
- [ ] `base/topics/Greeting`
- [ ] `base/topics/Fallback`
- [ ] `base/topics/OnError`

**Components selected:**
- [ ] `escalation` (required if Fallback references `Escalate`)
- [ ] `out-of-scope`
- [ ] `auth`
- [ ] `conversation-init`
- [ ] `knowledge-search`
- [ ] `remove-citations`
- [ ] `disambiguation`
- [ ] `action-invoke` (one per action-driven topic)
- [ ] Connector action files: _______________
- [ ] MCP action files: _______________
- [ ] Knowledge source files: _______________
- [ ] Global variable files: _______________
- [ ] Child agent files: _______________

---

## 10. UAT Test Cases

Write at least one test case per topic before development starts. These become the UAT sign-off criteria.

| # | Test input | Expected topic | Expected response (summary) | Pass/Fail |
|---|-----------|---------------|----------------------------|-----------|
| 1 | | Greeting | Welcome message | |
| 2 | | (main topic 1) | | |
| 3 | | (main topic 2) | | |
| 4 | Out-of-scope phrase | Out of Scope | Redirect message | |
| 5 | Nonsense / unclear | Fallback | Retry prompt (×3) then escalate | |
| 6 | "Speak to a human" | Escalation | Transfer confirmation | |
| 7 | (error condition) | On Error | Safe error message + ref ID | |
