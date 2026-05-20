# Component Registry — Reusable Function Library

Every reusable piece in this repository is listed here with its call signature.
Reference this registry instead of rewriting. Copy the call snippet, fill in the blanks, done.

**Navigation:** [Topic Components](#topic-components) · [Adaptive Cards](#adaptive-cards) · [Actions](#actions) · [Knowledge Sources](#knowledge-sources) · [Prompt Templates](#prompt-templates) · [AI Prompts](#ai-prompts) · [Wiring Diagram](#wiring-diagram)

---

## How components are called

| Component type | How to call | Analogy |
|---|---|---|
| Topic | `BeginDialog` node in any topic | Function call — runs and returns |
| Adaptive card | Inline `SendActivity` + `Question` node | Render a view, capture input |
| Action | `InvokeConnectorTaskAction` node | API call |
| Knowledge source | Attached to agent via `agent.mcs.yml` | Database connection |
| Prompt template | Pasted into `agent.mcs.yml` → `instructions` | Configuration / system config |
| AI prompt | Run in Claude to generate YAML | Code generator |

---

## Topic Components

Each topic is a self-contained dialog. Call any of them from any other topic using `BeginDialog`.

---

### `conversation-init`
**File:** `components/topics/conversation-init/ConversationInit.topic.mcs.yml`
**Trigger:** Auto — fires on first user message (`OnActivity`, type: Message)
**Purpose:** Loads the user's M365 profile (name, country) into global variables before any topic runs.

**Call:** Fires automatically — do not call via `BeginDialog`. It runs once per conversation, guarded by `condition: =IsBlank(Global.UserCountry)`.

**Inputs required before it runs:**
- Office 365 Users connector added to agent (`shared_office365users`)
- Global variables `Global.UserDisplayName` and `Global.UserCountry` declared

**Outputs set:**

| Variable | Type | Value |
|----------|------|-------|
| `Global.UserDisplayName` | String | User's display name from M365, or `"there"` on failure |
| `Global.UserCountry` | String | User's country from M365, or `"Unknown"` on failure |

**Telemetry fired:** `ConversationInit.Completed`, `ConversationInit.ProfileLoadFailed`

**Use at:** Step 13 — add to every agent. Required for personalisation pattern P5.

---

### `auth`
**File:** `components/topics/auth/SignIn.topic.mcs.yml`
**Trigger:** Auto — fires on `OnSignIn` event when auth token is needed.
**Purpose:** Handles the OAuth sign-in flow with telemetry.

**Call:** Fires automatically when `authenticationMode: ManualAzureAD` is set and a token is needed. No `BeginDialog` required.

**Inputs:** Auth mode set in `settings.mcs.yml` to `ManualAzureAD`

**Outputs set:**

| Variable | Type | Value |
|----------|------|-------|
| `System.User.AccessToken` | String | OAuth bearer token (used in connector actions) |
| `System.User.IsLoggedIn` | Boolean | True after successful sign-in |

**Telemetry fired:** `Auth.SignInStarted`, `Auth.SignInCompleted`

**Use at:** Step 14 — add when the agent needs user identity or calls authenticated connectors.

---

### `escalation`
**File:** `components/topics/escalation/Escalation.topic.mcs.yml`
**Trigger:** User says "speak to a human" (and 11 variants) — OR called programmatically.
**Purpose:** Transfers the conversation to a human agent with context.

**Call from any topic when escalation is needed:**
```yaml
- kind: BeginDialog
  id: callEscalation_REPLACE
  dialog: <SCHEMA_NAME>.topic.Escalate
```

**Inputs — set these before calling:**

| Variable | Type | Set to |
|----------|------|--------|
| `Global.EscalationReason` | String | Why escalation is happening, e.g. `"FallbackLimitReached"` |

**Outputs:** None — ends the conversation via `TransferConversation`.

**Telemetry fired:** `Agent.EscalationTriggered` (with `Reason`, `FallbackCount`)

**Called by:** `Fallback` (base), `OutOfScope` (after redirect)

**Use at:** Step 14 — required in every agent. Add `Global.EscalationReason` global variable.

---

### `knowledge-search`
**File:** `components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml`
**Trigger:** `OnUnknownIntent` — fires when no topic matches the user's message.
**Purpose:** Searches attached knowledge sources and returns a generative answer.

**Call:** Fires automatically on `OnUnknownIntent`. No `BeginDialog` required.

**Inputs:** At least one knowledge source attached to the agent (SharePoint or web).

**Outputs:** Generative answer sent to user inline. No variables set.

**Telemetry fired:** `Knowledge.SearchInvoked`, `Knowledge.AnswerFound`, `Knowledge.AnswerNotFound`

**Use at:** Step 14 — add when agent answers from documents. Pair with `remove-citations` if citations should be hidden.

---

### `out-of-scope`
**File:** `components/topics/out-of-scope/OutOfScope.topic.mcs.yml`
**Trigger:** Recognises out-of-scope user messages (phrases defined in component).
**Purpose:** Redirects out-of-scope queries to the correct resource.

**Call:** Fires automatically via trigger phrases. Programmatic call if needed:
```yaml
- kind: BeginDialog
  id: callOutOfScope_REPLACE
  dialog: <SCHEMA_NAME>.topic.OutOfScope
```

**Inputs:** Add out-of-scope phrases to the topic's `triggerQueries`. Add redirect targets to agent instructions using prompt pattern P6.

**Outputs:** None — sends redirect message and ends.

**Telemetry fired:** `Agent.OutOfScope` (with `UserQuery`)

**Use at:** Step 14 — required in every agent. Pair with P6 prompt pattern in agent instructions.

---

### `disambiguation`
**File:** `components/topics/disambiguation/Disambiguation.topic.mcs.yml`
**Trigger:** Auto — fires on `OnSelectIntent` when multiple topics match.
**Purpose:** Asks user to choose between matching topics.

**Call:** Fires automatically — no `BeginDialog` needed.

**Inputs:** None beyond the framework's intent scoring.

**Telemetry fired:** `Agent.DisambiguationTriggered` (with `UserQuery`, `MatchCount`)

**Use at:** Step 14 — add when the agent has ≥5 topics with overlapping trigger phrases.

---

### `question-branch`
**File:** `components/topics/question-branch/QuestionBranch.topic.mcs.yml`
**Trigger:** `OnRecognizedIntent` — user's message matches the topic's trigger phrases.
**Purpose:** Template for any topic that asks the user a question and branches on the answer.

**Call:** Copy once per question-based topic. Replace trigger phrases and branch conditions.

**Inputs:** Topic trigger phrases in `triggerQueries`.

**Outputs:** Sets `Topic.UserChoice` from the question node.

**Use at:** Step 14 — use this as the base for any topic where you ask "which option?" or collect a yes/no.

---

### `action-invoke`
**File:** `components/topics/action-invoke/ActionInvoke.topic.mcs.yml`
**Trigger:** `OnRecognizedIntent` — user's message matches the topic's trigger phrases.
**Purpose:** Template for any topic that calls an action (connector or MCP). Includes error handling, confirmation card, and telemetry.

**Call:** Copy once per action-driven topic. Replace trigger phrases, slot questions, and action reference.

**Inputs:** Topic trigger phrases + slot variables collected in the topic.

**Outputs:**

| Variable | Type | Value |
|----------|------|-------|
| `Topic.ActionResponse` | Object | Response from the connector/MCP action |
| `Topic.ActionSucceeded` | Boolean | True if action returned without error |

**Telemetry fired:** `Topic.Started`, `Action.Succeeded`, `Action.Failed`

**Use at:** Step 14 — use as the base template for every topic that writes data or calls an API. Never write action logic from scratch.

---

### `feedback`
**File:** `components/topics/feedback/Feedback.topic.mcs.yml`
**Trigger:** User says "feedback", "rate this", etc. — OR called programmatically.
**Purpose:** Collects CSAT via thumbs → star rating (if negative) → issue category dropdown (if rating ≤ 3). No free text — PII safe.

**Call from any topic at its natural end point:**
```yaml
- kind: BeginDialog
  id: collectFeedback_REPLACE
  dialog: <SCHEMA_NAME>_feedback_REPLACE
```

**Inputs:** None required.

**Outputs:** None — all data is logged to telemetry directly.

**Telemetry fired:** `Feedback.Thumbs`, `Feedback.Rating` (if negative), `Feedback.Category` (if rating ≤ 3)

**Use at:** Step 14 — call from the end of any topic that resolves a user request. Required for CSAT measurement (Q18 in requirements questionnaire).

---

### `remove-citations`
**File:** `components/topics/remove-citations/RemoveCitations.topic.mcs.yml`
**Trigger:** Auto — fires on `OnGeneratedResponse`.
**Purpose:** Strips `[1][2]` citation markers from generative AI responses before they reach the user.

**Call:** Fires automatically — no `BeginDialog` needed.

**Use at:** Step 14 — add when Q12 in requirements questionnaire is answered "No — hide citations".

---

## Adaptive Cards

Cards are not called via `BeginDialog` — they are inlined in `SendActivity` nodes. Copy the pattern below for each card.

**How to use any card — universal pattern:**

```yaml
# Step 1: Send the card
- kind: SendActivity
  id: sendCard_REPLACE
  activity:
    attachments:
      - contentType: application/vnd.microsoft.card.adaptive
        content: <paste card JSON here>

# Step 2: Wait for response
- kind: Question
  id: waitForCard_REPLACE
  variable: Topic.CardResponse
  prompt: ""
  entityType: UserEntireResponse

# Step 3: Branch on response
- kind: ConditionGroup
  id: checkResponse_REPLACE
  conditions:
    - id: confirmBranch_REPLACE
      condition: =Topic.CardResponse.action = "confirm"
      actions: [ ... ]
    - id: cancelBranch_REPLACE
      condition: =Topic.CardResponse.action = "cancel"
      actions: [ ... ]
```

---

### `confirmation-card`
**File:** `components/adaptive-cards/confirmation-card.json`
**Purpose:** "Are you sure?" — confirm or cancel before a write action.

**Response values:** `action: "confirm"` or `action: "cancel"`

**Use in:** Every `action-invoke` topic before submitting data. Required by prompt pattern P10.

**When:** Step 14 — wire into every topic that writes, submits, or triggers a process.

---

### `status-card`
**File:** `components/adaptive-cards/status-card.json`
**Purpose:** Display a data lookup result with a status colour.

**Variables to bind:** `${title}`, `${statusLabel}`, `${statusColor}` (`Good` / `Warning` / `Attention`), `${details}[]`

**Use in:** Any topic that reads and displays data from a connector.

---

### `form-card`
**File:** `components/adaptive-cards/form-card.json`
**Purpose:** Collect structured user input (text, date, dropdown) in a single card.

**Response values:** Form field values returned as properties on `Topic.CardResponse`.

**Use in:** `action-invoke` topics where you need multiple inputs at once. Alternative to multi-turn slot-filling.

---

### `feedback-thumbs`
**File:** `components/adaptive-cards/feedback-thumbs.json`
**Purpose:** 👍 / 👎 — binary satisfaction.

**Response values:** `feedbackValue: "positive"` or `"negative"`, `score: 1` or `0`

**Use via:** `feedback` topic (automatic) — or inline directly if you only need yes/no.

---

### `feedback-rating`
**File:** `components/adaptive-cards/feedback-rating.json`
**Purpose:** ⭐ 1–5 star rating.

**Response values:** `feedbackValue: "1"` through `"5"`, `score: 1` through `5`

**Use via:** `feedback` topic (automatic) — or inline for standalone rating.

---

### `feedback-text`
**File:** `components/adaptive-cards/feedback-text.json`
**Purpose:** Issue category dropdown — fires when thumbs-down rating ≤ 3. No free-text field (PII safe).

**Response values:** `feedbackCategory: "wrong_answer"` etc., `skipped: true/false`

**Use via:** `feedback` topic (automatic) — fires only when rating ≤ 3.

---

## Actions

Actions are the connector and MCP wrappers. Each lives in `components/actions/` and is referenced inside an `action-invoke` topic.

---

### `connector`
**File:** `components/actions/connector/connector-action.mcs.yml`
**Purpose:** Generic Power Platform connector call template.

**Action Safety — declare tier before build:**

| Tier | Action type | Guardrail required |
|------|------------|-------------------|
| **Low** | Read / lookup / search | None — telemetry only |
| **Medium** | Create / submit / update | `confirmation-card.json` before calling |
| **High** | Delete / revoke / bulk modify | Power Automate approval flow — never inline |

Add this comment at the top of every action file:
```yaml
# SAFETY TIER: Low / Medium / High
# GUARDRAIL:   None / confirmation-card / approval-flow
# REASON:      <one line>
```

**Reference in your topic:**
```yaml
- kind: InvokeConnectorTaskAction
  id: invokeConnector_REPLACE
  connectorId: /providers/Microsoft.PowerApps/apis/<CONNECTOR_LOGICAL_NAME>
  operationId: <OPERATION_ID>
  parameters:
    <param1>: =Topic.<Variable1>
    <param2>: =Topic.<Variable2>
  output:
    binding: Topic.ActionResponse
```

**Inputs:** Set `Topic.*` variables for each parameter before the action node.
**Output:** `Topic.ActionResponse` — the connector's response object.

**Use at:** Step 14 — copy once per connector operation. Never write `InvokeConnectorTaskAction` from scratch.
**Safety:** Classify tier first. See `BEST-PRACTICES.md` Section 12 and `project-delivery/00-ai-decision-framework.md` Step 5.

---

### `mcp`
**File:** `components/actions/mcp/mcp-action.mcs.yml`
**Purpose:** Generic MCP server tool call template.

**Reference in your topic:**
```yaml
- kind: InvokeExternalAgentTaskAction
  id: invokeMcp_REPLACE
  agentId: <MCP_SERVER_SCHEMA_NAME>
  toolName: <TOOL_NAME>
  parameters:
    <param1>: =Topic.<Variable1>
  output:
    binding: Topic.ActionResponse
```

**Use at:** Step 14 — copy once per MCP tool call.

---

## Knowledge Sources

Knowledge sources attach to the agent and are searched automatically by `knowledge-search`. Copy once per source.

---

### `sharepoint`
**File:** `components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml`

**Reference in `agent.mcs.yml`:**
```yaml
knowledgeSources:
  - kind: PublicSiteKnowledgeSource
    id: <SCHEMA_NAME>_knowledge_sharepoint_REPLACE
    displayName: <Display Name>
    siteUrl: https://<tenant>.sharepoint.com/sites/<site>
    libraryPath: <library path>
```

**Use at:** Step 14 (add knowledge) — one entry per SharePoint library.

---

### `public-website`
**File:** `components/knowledge/public-website/public-website.knowledge.mcs.yml`

**Reference in `agent.mcs.yml`:**
```yaml
knowledgeSources:
  - kind: PublicSiteKnowledgeSource
    id: <SCHEMA_NAME>_knowledge_web_REPLACE
    displayName: <Display Name>
    siteUrl: https://<public-url>
```

**Use at:** Step 14 — one entry per public URL.

---

### `glossary`
**File:** `components/knowledge/glossary/glossary.knowledge.mcs.yml`
**Purpose:** JIT acronym glossary loaded explicitly by the `conversation-init` topic. Never auto-searched.

**Key points:**
- `triggerCondition: false` — excluded from all automatic `UniversalSearchTool` searches
- Requires **Dataverse storage** — direct SharePoint sources cannot return full file content
- Configure the knowledge source via Copilot Studio UI first; reference it in `conversation-init`
- The knowledge source reference in `SearchAndSummarizeContent` must match the `.mcs.yml` filename (without the `.knowledge.mcs.yml` suffix, i.e. `glossary`)

**Pair with:**
- `components/topics/conversation-init/ConversationInit.topic.mcs.yml` — loads it into `Global.Glossary`
- `components/variables/glossary-var/Glossary.variable.mcs.yml` — declares the global variable
- Agent instructions glossary block in `base/agent.mcs.yml` — injects `{Global.Glossary}` into the orchestrator

**Use at:** Step 14 — add when the agent needs to understand internal acronyms before searching knowledge.

---

### `child-agent`
**File:** `components/agents/child-agent/child-agent.mcs.yml`
**Purpose:** Wires a specialist sub-agent into an orchestrator topic.

**Reference in your orchestrator topic:**
```yaml
- kind: InvokeExternalAgentTaskAction
  id: callChildAgent_REPLACE
  agentId: <CHILD_AGENT_SCHEMA_NAME>
  input: =Topic.UserQuery
  output:
    binding: Topic.ChildAgentResponse
```

**Use at:** Step 14 — orchestrator pattern only (recipe 05).

---

## Prompt Templates

Prompt templates are pasted into `agent.mcs.yml` → `instructions`. They are configuration, not code — copy once per agent, do not rewrite.

**Source:** `prompts/ai-prompts/prompt-engineering-patterns.md`
**System prompt examples:** `prompts/system-prompts/`

### Which patterns to include — decision table

| Agent type | Required patterns | Optional |
|---|---|---|
| Any agent | P6 (out-of-scope), P7 (escalation), P8 (uncertainty) | — |
| Knowledge / FAQ | P1 (grounded retrieval), P4 (policy lookup) | P5 (personalised) |
| Action / form | P2 (structured task), P10 (confirm before action) | P5 |
| IT support / troubleshooting | P3 (guided troubleshooting) | P8 |
| HR / wellbeing | P9 (sensitive topics) | P4, P5 |
| Authenticated agent | P5 (personalised response) | All |

**How to include a pattern:**
1. Open `prompts/ai-prompts/prompt-engineering-patterns.md`
2. Copy the **System prompt block** for the pattern(s) you need
3. Paste into `agent.mcs.yml` → `instructions`, replacing `[bracketed]` values
4. Run the anti-pattern checklist (bottom of that file) before building

---

### Pattern quick-reference

| ID | Name | Copy from | Add to instructions when |
|----|------|-----------|--------------------------|
| P1 | Grounded Knowledge Retrieval | `prompt-engineering-patterns.md` | Agent answers from documents |
| P2 | Structured Task Completion | `prompt-engineering-patterns.md` | Agent collects and submits data |
| P3 | Guided Troubleshooting | `prompt-engineering-patterns.md` | Agent diagnoses step-by-step |
| P4 | Policy Lookup and Explanation | `prompt-engineering-patterns.md` | Agent explains policies |
| P5 | Personalised Response | `prompt-engineering-patterns.md` | Auth agent — uses user's name/country |
| P6 | Out-of-Scope Boundary | `prompt-engineering-patterns.md` | **Every agent** — mandatory |
| P7 | Escalation with Context | `prompt-engineering-patterns.md` | **Every agent** — mandatory |
| P8 | Uncertainty Acknowledgement | `prompt-engineering-patterns.md` | **Every agent** — mandatory |
| P9 | Sensitive Topic Handling | `prompt-engineering-patterns.md` | HR, wellbeing, legal-adjacent topics |
| P10 | Confirmation Before Action | `prompt-engineering-patterns.md` | Any agent that writes or submits data |

---

### System prompt starters

Pre-written full system prompts for common agent types. Use as a starting point — then add patterns above.

| File | Agent type |
|------|-----------|
| `prompts/system-prompts/hr-assistant.md` | HR self-service |
| `prompts/system-prompts/it-helpdesk.md` | IT support / troubleshooting |
| `prompts/system-prompts/knowledge-base.md` | General knowledge / FAQ |
| `prompts/system-prompts/customer-support.md` | Customer-facing support |

---

## AI Prompts

Run these in your Claude session to generate YAML you'd otherwise write manually.

| Prompt | Command | Generates | Use at step |
|--------|---------|-----------|-------------|
| Generate agent instructions | `/generate-agent-instructions` | Full `instructions` block for `agent.mcs.yml` | Step 13 |
| Generate a topic | `/generate-topic` | Complete topic YAML from a plain-English description | Step 14 |
| Generate an adaptive card | `/generate-adaptive-card` | Card JSON from a description of what it should show | Step 14 |
| Generate eval cases | `/generate-eval-cases` | Eval CSV rows from your topic list | Step 17 |
| Review agent | `/review-agent` | Audit report of the whole agent — CRITICAL issues must be fixed | Before step 17 |

---

## Wiring Diagram

How the components connect at runtime. Read this to understand which components call which.

```
User message arrives
        │
        ▼
[conversation-init]  ← fires once, loads Global.UserDisplayName, Global.UserCountry
        │
        ▼
Intent routing
  ├─ Matched topic → [question-branch] or [action-invoke]
  │       │
  │       ├─ action-invoke calls → [connector] or [mcp]
  │       ├─ action-invoke shows → [confirmation-card] before writing
  │       ├─ action-invoke shows → [status-card] after reading
  │       ├─ action-invoke shows → [form-card] to collect inputs
  │       └─ resolved topic calls → [feedback] (BeginDialog)
  │               └─ feedback shows → [feedback-thumbs]
  │                       └─ if negative → [feedback-rating]
  │                               └─ if ≤3 → [feedback-text]
  │
  ├─ OnUnknownIntent → [knowledge-search]
  │       └─ OnGeneratedResponse → [remove-citations] (if configured)
  │
  ├─ OnSelectIntent → [disambiguation]
  │
  ├─ Out-of-scope phrases → [out-of-scope]
  │       └─ calls → [escalation] (if needed)
  │
  └─ "speak to human" → [escalation]
                └─ TransferConversation → human queue
```

---

## Global Variables Reference

Variables shared across all topics. Ready-made variable files live in `components/variables/`.

| Variable | File | Set by | Used by | Value |
|----------|------|--------|---------|-------|
| `Global.UserDisplayName` | `components/variables/user-display-name/UserDisplayName.variable.mcs.yml` | `conversation-init` | Agent instructions (P5), any topic greeting | User's M365 display name — falls back to `"there"` |
| `Global.UserCountry` | `components/variables/user-country/UserCountry.variable.mcs.yml` | `conversation-init` | Agent instructions (P5), country-specific logic | User's M365 country — falls back to `"Unknown"` |
| `Global.Glossary` | `components/variables/glossary-var/Glossary.variable.mcs.yml` | `conversation-init` | Agent instructions (glossary block) | Customer acronym CSV — injected via `{Global.Glossary}` |
| `Global.EscalationReason` | `components/variables/global-variable/global-variable.variable.mcs.yml` | Any topic before escalating | `escalation` | Why escalation is happening |

---

## Component Checklist — What to Include Per Agent Type

Use this instead of deciding from scratch which components to add.

### Minimum viable agent (knowledge only)
- [ ] `base/` — copy and configure
- [ ] `conversation-init` — loads user profile
- [ ] `knowledge-search` — answers from documents
- [ ] `out-of-scope` — rejects off-topic queries
- [ ] `escalation` — human fallback
- [ ] Prompt patterns: P1, P6, P7, P8
- [ ] At least one knowledge source (SharePoint or web)
- [ ] `feedback` — CSAT (call from knowledge-search on answer found)

### Agent with authentication
- All above, plus:
- [ ] `auth` — sign-in topic
- [ ] `conversation-init` — required for user profile
- [ ] Prompt pattern P5 — personalised response
- [ ] `settings.mcs.yml` → `authenticationMode: ManualAzureAD` or `Integrated`

### Agent with actions (form submission, data read/write)
- All minimum, plus:
- [ ] `action-invoke` — one copy per action topic
- [ ] `connector` or `mcp` — one copy per integration
- [ ] `confirmation-card` — before every write action
- [ ] `status-card` — after every read action
- [ ] `form-card` — if collecting multiple inputs at once
- [ ] Prompt patterns: P2, P10

### Agent with disambiguation
- All minimum, plus:
- [ ] `disambiguation` — when ≥5 topics with overlapping phrases

### Full-featured agent
- All above, plus:
- [ ] `remove-citations` — if Q12 = hide citations
- [ ] `child-agent` — if orchestrator pattern (recipe 05)
- [ ] Prompt pattern P9 — if HR, wellbeing, or legal-adjacent topics
