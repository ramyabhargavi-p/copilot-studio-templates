# Workflow Logic Design

Maps how conversations flow through the agent — intent recognition, branching conditions, slot-filling, state management, and recovery paths. This document bridges the functional requirements (what the agent must do) and the YAML implementation (how it does it).

Complete this after `07-functional-design-document.md` is approved. Every decision node here translates directly to a `ConditionGroup` or `BeginDialog` in a topic YAML.

---

## 1 — Topic Interaction Map

Show which topics exist and how they relate. This is not a conversation flow — it is the architecture of the agent's topic graph.

```
[Conversation Start]
        │
        ▼
[Greeting]  ─────────────────────────────────────────────────────┐
        │                                                         │
        ▼                                                         │
[ConversationInit] ← loads user profile into Global.*            │
        │                                                         │
        ▼                                                         │
[User sends message]                                             │
        │                                                         │
        ├── intent matched ──→ [Topic A: UC-03]                  │
        │                              │                          │
        │                              ├── success ──→ [done]    │
        │                              └── action fails ──→ [safe error message]
        │                                                         │
        ├── intent matched ──→ [Topic B: UC-04]                  │
        │                                                         │
        ├── out of scope ──→ [OutOfScope] ──→ redirect message  │
        │                                                         │
        ├── ambiguous ──→ [Disambiguation] ──→ clarify ──┐       │
        │                                                  └──────┘
        ├── unknown ──→ [Fallback]                               │
        │                   ├── retry 1,2 ──→ rephrase prompt   │
        │                   └── retry 3 ──→ [Escalation] ───────┘
        │
        └── error ──→ [OnError] ──→ safe message + telemetry
```

**Instructions:** Replace `[Topic A]`, `[Topic B]` etc. with the actual topics from your `03-agent-design-worksheet.md`. Add branches for every topic you plan to build.

---

## 2 — Conversation Flow Per Use Case

Design the detailed flow for each functional use case. One section per UC from `07-functional-design-document.md`.

### Template per use case:

```
UC-[N]: [Name]
───────────────────────────────────────────
Trigger: [trigger phrase / intent]

Step 1: [Agent action — e.g. "Ask: which department?"]
        │
        ├── User provides value → Step 2
        └── User provides invalid value → [repeat prompt / validation message]

Step 2: [Agent action — e.g. "Confirm the details"]
        │
        ├── User confirms → Step 3
        └── User cancels → [cancel message → end]

Step 3: [Agent action — e.g. "Call connector action"]
        │
        ├── Action succeeds → [success message + telemetry]
        └── Action fails → [safe error message + telemetry]
```

---

### UC-01: Greeting and Orientation

```
Trigger: OnConversationStart (automatic)

Step 1: Send welcome message with agent name and capabilities
        │
        └── Always succeeds → end (user initiates next turn)
```

Telemetry: `Conversation.Started` at step 1.

---

### UC-02: Fallback

```
Trigger: OnUnknownIntent

Step 1: Increment FallbackCount (Topic.FallbackCount = FallbackCount + 1)
        │
        ├── FallbackCount < 3 → Send rephrase prompt → end (wait for next message)
        └── FallbackCount = 3 → Step 2

Step 2: Log Agent.EscalationTriggered (Reason: FallbackExhausted)
        │
        └── Always → Invoke Escalation topic → end
```

Telemetry: `Agent.FallbackTriggered` at step 1. `Agent.EscalationTriggered` at step 2.

---

### UC-0[N]: [Use Case Name]

```
Trigger: [exact trigger phrases listed here]

Preconditions: [list any Global.* variables that must be set]

Step 1: [describe first agent action]
        │
        ├── [condition A] → Step 2
        └── [condition B] → [alternate path]

Step 2: [slot-filling — collecting required inputs]
  Required slots:
    - [Slot name]: [type] — "[question to ask user]"
    - [Slot name]: [type] — "[question to ask user]"
  Validation:
    - [Slot name]: must be [condition] — if invalid: "[re-ask prompt]"
        │
        └── All slots filled and valid → Step 3

Step 3: [confirmation or action]
        │
        ├── Confirmed → Step 4
        └── Cancelled → [cancel message] → end

Step 4: [invoke action / connector]
        │
        ├── Success (response not blank) → [success message] → end
        └── Failure (response blank/error) → [safe error message] → end
```

Telemetry:
- `Topic.Started` at entry
- `Action.Succeeded` at step 4 success
- `Action.Failed` at step 4 failure

YAML components:
- Topic: `components/topics/action-invoke/ActionInvoke.topic.mcs.yml`
- Action: `components/actions/connector/connector-action.mcs.yml`

*(Copy this block for every use case in section 3 of the FDD.)*

---

## 3 — Slot-Filling Design

Slot-filling is the pattern of collecting required information through multi-turn conversation. Design every slot before writing topic YAML — underdefined slots cause awkward conversations and validation gaps.

### Slot definition table

For each topic that collects input, fill in this table:

| Topic | Slot name | Variable | Type | Required? | Question asked | Validation rule | Re-ask prompt |
|-------|-----------|----------|------|-----------|---------------|-----------------|---------------|
| UC-0X | Start date | `Topic.StartDate` | Date | Yes | "What date would you like to start?" | Must be in the future | "That date has already passed — please choose a future date." |
| UC-0X | Leave type | `Topic.LeaveType` | Choice | Yes | "What type of leave is this?" | Must be one of: Annual / Sick / Parental | "Please choose one of: Annual, Sick, or Parental leave." |
| UC-0X | [Slot] | | | | | | |

**Slot-filling principles:**
- Ask for one slot per message — never combine two questions in one response
- Always validate before proceeding — never pass unvalidated user input to a connector
- Provide a clear re-ask prompt that explains what was wrong, not just repeats the question
- For high-stakes actions (submitting forms, sending data), show a confirmation card before executing

---

## 4 — Decision Tree: Branching Logic

Map every condition in the conversation to a concrete Power FX expression. This is the input the developer translates directly into `ConditionGroup` nodes in YAML.

| Use case | Decision point | Condition (Power FX) | True → | False → |
|----------|---------------|---------------------|--------|---------|
| All | Action response valid? | `=!IsBlank(Topic.ActionResponse)` | Send success response | Send safe error message |
| UC-0X | User cancelled? | `=Topic.CardResponse.action = "cancel"` | Send cancel message → end | Proceed to action |
| UC-0X | User authenticated? | `=!IsBlank(Global.UserDisplayName)` | Use display name | Use "there" as fallback |
| UC-0X | Knowledge answer found? | `=!IsBlank(Topic.SearchResult)` | Send answer | Send "couldn't find answer" |
| UC-0X | [Decision name] | `=[PowerFX expression]` | | |

**Important:** Every `ConditionGroup` in YAML must have an `elseActions` branch. A condition with no else branch leaves the user with a blank response if the condition is false.

---

## 5 — State Management Design

Defines which variables exist, their scope, what sets them, and who reads them. Prevents variable name collisions and undeclared variable bugs.

### Global variables (shared across all topics)

| Variable | Type | Set by | Read by | Default if blank | Purpose |
|----------|------|--------|---------|-----------------|---------|
| `Global.UserDisplayName` | Text | `ConversationInit` | Greeting, Escalation, any personalised topic | `"there"` | Personalization |
| `Global.UserCountry` | Text | `ConversationInit` | System prompt via `{Global.UserCountry}` | `"Unknown"` | Locale context |
| `Global.FallbackCount` | Number | `Fallback` topic | `Fallback` topic | `0` | Escalation trigger |
| `Global.[Custom]` | | | | | |

### Topic-scoped variables (local to one topic)

| Topic | Variable | Type | Set by node | Read by node | Purpose |
|-------|----------|------|------------|-------------|---------|
| UC-0X | `Topic.StartDate` | Date | `Question` node | `BeginDialog` (action input) | Slot: leave start date |
| UC-0X | `Topic.ActionResponse` | Record | `BeginDialog` (action output) | `ConditionGroup` | Validate action result |
| UC-0X | `Topic.CardResponse` | Record | `Question` (card submit) | `ConditionGroup` | Confirmation card result |
| UC-0X | `Topic.[Name]` | | | | |

---

## 6 — Error and Recovery Path Design

Every error scenario must have a designed response. "It broke" is not a design.

| Error scenario | Detection method | User-facing response | Telemetry event | Recovery action |
|---------------|-----------------|---------------------|-----------------|----------------|
| Connector action returns null | `ConditionGroup`: `IsBlank(Topic.ActionResponse)` | "I wasn't able to complete that. Please try again or contact [contact]." | `Action.Failed` | None — user must retry or escalate |
| M365 profile load fails | `ConditionGroup` in ConversationInit | Silent — set safe defaults | `ConversationInit.ProfileLoadFailed` | Use `"there"` / `"Unknown"` as defaults |
| Knowledge search returns no answer | `ConditionGroup`: `IsBlank(Topic.SearchResult)` | "I couldn't find an answer to that. You may want to contact [contact]." | `Knowledge.AnswerNotFound` | Offer escalation link |
| System error (OnError fires) | `OnError` trigger | Test mode: full details. Prod: "Reference ID: [ID]. Our team has been notified." | `Agent.ErrorOccurred` | None — OnError is the final safety net |
| User goes silent (no input) | Copilot Studio timeout | Platform default timeout message | None | None — platform handles |
| [Other error] | | | | |

---

## 7 — Escalation Design

Define every path that leads to a human handoff.

| Escalation trigger | Path | Queue / target | Context passed to human agent |
|-------------------|------|---------------|-------------------------------|
| 3× fallback retries | Fallback → Escalation topic via BeginDialog | `[QUEUE_NAME]` | User query that failed, fallback count |
| User explicitly requests human | Escalation topic `OnRecognizedIntent` | `[QUEUE_NAME]` | User's last message, topic context |
| Out-of-scope + no self-serve option | OutOfScope topic elseActions | Redirect to [contact/resource] | N/A — message only, no transfer |
| [Other escalation trigger] | | | |

**Pre-build check:** Confirm the queue name `[QUEUE_NAME]` with the environment admin in `02-technical-discovery.md` before building. An incorrect queue name causes a silent failure at the `TransferConversation` node.

---

## 8 — Conversation Design Standards

Rules that apply to every message written in this agent. Encode these in the system prompt and review every `SendActivity` node against them during UAT.

| Standard | Rule | Example |
|----------|------|---------|
| Tone | [Formal / Friendly / Neutral] — match the persona of the target audience | |
| Response length | 2–4 sentences maximum for conversational responses; bullet points for lists > 3 items | |
| Confirmation before action | Always show a confirmation card before any action that writes data or sends a form | |
| Error messages | State what went wrong simply + what the user can do next; never show technical errors | "I wasn't able to submit that. You can try again or contact [X] directly." |
| Out-of-scope redirect | Name the right resource, don't just say "I can't help" | "For payroll queries, contact payroll@company.com — I can't help with that." |
| Uncertainty | When the agent is not confident in a knowledge answer, say so | "Based on our documentation, [answer]. For your specific situation, confirm with [authority]." |

---

## Sign-Off

This document must be reviewed by the developer and approved by the lead before any topic YAML is written.

| Role | Name | Reviewed? | Date |
|------|------|-----------|------|
| Developer | | ☐ | |
| Tech Lead | | ☐ | |
| Project Owner (sections 1, 6, 7) | | ☐ | |
