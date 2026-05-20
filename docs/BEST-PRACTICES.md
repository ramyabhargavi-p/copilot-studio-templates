# Copilot Studio — Best Practices

Guidelines for building production-quality agents with these templates. Each section answers a specific category of design question.

> **When to use this doc:** Reference when designing a new agent or reviewing an existing one.
> These rules apply to both Cloud-First (browser + VS Code Apply Changes) and CLI-only (`pac copilot create`) paths.
> Read before building — most mistakes happen at design time, not deployment time.

---

## 1. Agent Instructions (System Prompt)

The system prompt is the single most important lever for agent quality. Write it like a policy document, not a description.

### Structure
```
[Who you are and what you do — 1-2 sentences]

## What I can help with
- [In-scope item 1]
- [In-scope item 2]

## What I cannot help with
- [Out-of-scope item 1] — direct users to: [resource]
- [Out-of-scope item 2] — direct users to: [resource]

## Handling out-of-scope
Say: "I'm only set up to help with [domain]. For [topic], please contact [resource]."
Never attempt to answer out-of-scope questions.

## Response quality
- [Tone guidance]
- [Format guidance]
- [Length guidance]

## Escalation
[When and how to hand off to a human]
```

### Rules
- **Be explicit about scope** — vague instructions produce vague agents. List both in-scope and out-of-scope.
- **Write redirect text verbatim** — tell the AI exactly what to say for out-of-scope, not just "redirect".
- **Include formatting instructions** — "use numbered lists for steps, bullet points for options".
- **Test with adversarial prompts** — try to make the agent answer out-of-scope questions. If it does, tighten the instructions.

---

## 2. Error Handling

### Rule: Never let errors reach the user without a safe message
The `OnError` topic in `base/` handles system errors. Every agent must have it. Do not remove it.

### Rule: Always validate action outputs before using them
Actions return `null` when they fail. Always check:
```yaml
- kind: ConditionGroup
  conditions:
    - condition: =!IsBlank(Topic.ActionResponse)
      actions:
        # success path
  elseActions:
    # failure path — send safe message + log
```
Use the `action-invoke` component as the starting point for any action-driven topic.

### Rule: Set safe defaults in initialisation
`ConversationInit` wraps the M365 profile call in a condition check. If the call fails, the conversation continues with defaults (`"Unknown"` / `"there"`). Never let an initialisation failure block the user.

### Rule: Distinguish test mode from production in error messages
```yaml
condition: =System.Conversation.InTestMode = true
# → show detailed error (message, code, time)
elseActions:
# → show only: safe message + conversation ID (for support triage)
```
Never expose `System.Error.Message` to production users.

### Rule: Never swallow errors silently
Every `elseActions` block on a failed action must have a `LogCustomTelemetryEvent`. A silent failure is invisible in production.

---

## 3. Logging and Telemetry

### Telemetry event naming convention
Use `{Category}.{Action}` format:

| Category | Events |
|----------|--------|
| `Conversation` | `Started` |
| `Agent` | `FallbackTriggered`, `DisambiguationTriggered`, `OutOfScope`, `EscalationTriggered`, `ErrorOccurred` |
| `Auth` | `SignInStarted`, `SignInCompleted` |
| `Knowledge` | `SearchInvoked`, `AnswerFound`, `AnswerNotFound` |
| `Topic` | `Started` |
| `Action` | `Succeeded`, `Failed` |
| `ConversationInit` | `Completed`, `ProfileLoadFailed` |

→ Full event registry: [`ENGINEERING-PLAYBOOK.md` → Telemetry & Logging](../ENGINEERING-PLAYBOOK.md#stage-9--telemetry--logging)

### Standard properties
Include these in every telemetry event:
```yaml
properties: "={ConversationId: System.Conversation.Id, TimeUTC: Text(Now(), DateTimeFormat.UTC)}"
```

Add context-specific properties as needed:
- `Channel: System.Activity.Channel` — for channel breakdown (Teams, Web, etc.)
- `UserQuery: System.Activity.Text` — for query analysis (avoid PII)
- `FallbackCount: System.FallbackCount` — for fallback trend analysis

### What to log (and what not to)
| Log | Don't log |
|-----|-----------|
| Event type and timing | Full message content (PII risk) |
| ConversationId (anonymous) | User email, name, or ID |
| Action name and success/failure | Action input/output values |
| Channel and bot name | Sensitive business data |
| Error codes (not messages) | Internal system paths |

### Using telemetry data
Connect to Application Insights via the Azure Monitor integration in Copilot Studio. Key queries:
- **Fallback rate**: `Agent.FallbackTriggered` / `Conversation.Started` — should be < 20%
- **Knowledge hit rate**: `Knowledge.AnswerFound` / `Knowledge.SearchInvoked` — should be > 60%
- **Escalation rate**: `Agent.EscalationTriggered` / `Conversation.Started` — monitor for spikes
- **Action failure rate**: `Action.Failed` / (`Action.Failed` + `Action.Succeeded`) — alert if > 5%
- **Out-of-scope rate**: `Agent.OutOfScope` / `Conversation.Started` — high rates suggest discovery issues

---

## 4. Out-of-Scope Handling

### Two-layer approach

**Layer 1 — Agent instructions (long tail)**
Explicitly list out-of-scope topics in the system prompt with redirect targets. The AI handles the nuanced cases conversationally.

**Layer 2 — OutOfScope topic (explicit signals)**
Add trigger phrases for the most common out-of-scope requests. The recogniser catches these before the AI processes them — faster, more consistent, separately logged.

### What NOT to do
- Don't rely on the AI alone — it will occasionally answer out-of-scope questions if it thinks it can help
- Don't use Fallback for out-of-scope — Fallback means "I didn't understand", not "I understood but can't help"
- Don't give a generic "I can't help with that" — always name the redirect resource

### Monitoring
Track `Agent.OutOfScope` events. High rates signal:
- Users are finding the agent through the wrong channel (discovery problem)
- The agent's scope is misrepresented in its name/description
- Users need a capability the agent doesn't have yet (consider expanding scope)

---

## 5. Topic Design

### One purpose per topic
A topic that does multiple unrelated things is hard to debug and maintain. If a topic has more than ~15 nodes, consider splitting it.

### Priority values
| Priority | When to use |
|----------|-------------|
| (default / omitted) | Normal intent-triggered topics |
| `-1` | Topics that fire only after all others fail (Fallback, KnowledgeSearch) |
| `1` or higher | Topics that should preempt other topics (use sparingly) |

### `interruptionPolicy`
```yaml
interruptionPolicy:
  allowInterruption: false   # Use during multi-step collection — prevents mid-flow topic switches
  allowInterruption: true    # Use when it's fine for users to change subject mid-topic
```

### `alwaysPrompt`
```yaml
alwaysPrompt: true    # Always ask the question even if a value was extracted from the trigger phrase
alwaysPrompt: false   # Skip the question if the AI already has the value from context (default)
```

### Trigger phrases
- Write 5–10 trigger phrases per topic — more coverage = better recognition
- Include variations: formal, informal, abbreviated ("what is my leave balance" / "check leave" / "how many days off do I have")
- Avoid overlap with other topics — run disambiguation tests to check
- Trigger phrases are case-insensitive

---

## 6. Action Design

### `modelDescription` is the most important field
The AI reads `modelDescription` to decide whether to invoke the action. A vague description causes misrouting.

```yaml
# Bad — too vague
modelDescription: Get information

# Good — specific and distinctive
modelDescription: >
  Retrieves the signed-in user's remaining annual leave balance in days.
  Use when the user asks how many days of annual leave they have left,
  their leave entitlement, or their holiday balance.
```

### `mode` selection
```yaml
mode: Invoker   # Action runs as the signed-in user — requires ManualAzureAD or Integrated
mode: Caller    # Action runs as the agent's service principal — works with authenticationMode: None
```

Use `Invoker` when the action's result is user-specific (my calendar, my leave balance).
Use `Caller` when the action is a shared lookup (list of offices, product catalogue).

### One file per action
Never combine multiple connector operations into one `TaskDialog`. Each action file should wrap exactly one `operationId`.

### Input validation
Always use `shouldPromptUser: true` for required inputs unless the AI can reliably infer the value from conversation context. Silent inference failures are hard to debug.

---

## 7. Knowledge Source Design

### Scope as narrowly as useful
| Too broad | Too narrow |
|-----------|-----------|
| Entire SharePoint site | A single document |
| `https://contoso.sharepoint.com/sites/HR` | `https://contoso.sharepoint.com/sites/HR/Shared%20Documents/Policies/Leave/2024LeavePolicy.docx` |
| **Better:** `https://contoso.sharepoint.com/sites/HR/Shared%20Documents/Policies` | |

### Always use `CreateSearchQuery`
Before `SearchAndSummarizeContent`, run `CreateSearchQuery` to rewrite the user's message into an optimised query. This preserves conversation context for multi-turn accuracy.

### Combine `knowledge-search` with `remove-citations`
If your knowledge sources are internal, users don't need to see `[1]`, `[2]` markers. Add `remove-citations` to clean up responses.

### Multiple knowledge sources
If the agent should answer from multiple libraries, add a separate `.knowledge.mcs.yml` file per library. `SearchAndSummarizeContent` (without `SearchSpecificKnowledgeSources`) searches them all automatically.

---

## 8. Authentication and Security

### Auth mode selection
| Scenario | Auth mode |
|----------|-----------|
| Anonymous agent (no user identity needed) | `None` |
| Teams/M365 deployment (SSO) | `Integrated` |
| Web/external channel (explicit sign-in) | `ManualAzureAD` |

### Load user context once
Use `ConversationInit` to load M365 profile on the first message and store in global variables. Don't call the Office 365 Users API in every topic.

### Never trust user-supplied values for security decisions
If a topic allows users to query data, use `mode: Invoker` so the connector enforces the user's own permissions — don't pass user-supplied IDs into system-trust queries.

### Guard sensitive variables from the AI
Set `aIVisibility: Hidden` on global variables that contain auth tokens, internal flags, or sensitive business data. Prevents the AI from accidentally revealing them.

---

## 9. Multi-Agent (Orchestrator) Design

### Child agent descriptions drive all routing
Write descriptions as if explaining to a human: precise, with concrete examples.
```yaml
# Bad
description: Handles HR questions

# Good
description: >
  Handles HR queries about leave and absence only.
  Routes here for: leave balance, annual leave requests, sick leave reporting, leave policies.
  Example messages: "How many days off do I have?", "I want to book annual leave",
  "What's the sick leave policy?", "I need to report a sick day"
```

### Make domain boundaries mutually exclusive
If two child agents' descriptions overlap, routing becomes unpredictable. Test with borderline queries ("What is the HR IT password policy?" — HR or IT?).

### Pass only the minimum context
Only use `inputType` when the child needs data the parent already has (e.g. user's department). Passing everything makes child agents tightly coupled to the parent's state.

---

## 10. Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Agent `componentName` | PascalCase, no spaces | `HrAssistant` |
| Agent `schemaName` | lowercase, underscores | `hr_assistant` |
| Topic display name | Title Case | `Get Leave Balance` |
| Topic file name | PascalCase, `.topic.mcs.yml` | `GetLeaveBalance.topic.mcs.yml` |
| Action file name | PascalCase, `.mcs.yml` | `GetLeaveBalance.mcs.yml` |
| Knowledge source file | kebab-case, `.knowledge.mcs.yml` | `hr-policies.knowledge.mcs.yml` |
| Global variable name | camelCase | `userCountry` |
| Telemetry event name | `{Category}.{Action}` | `Knowledge.AnswerFound` |
| Node IDs | descriptive prefix + `_` + 6-char random | `sendMessage_a1b2c3` |

---

## 11. Testing Checklist

Before publishing any agent, verify:

### Core flow
- [ ] Greeting fires on conversation start
- [ ] `System.Bot.Name` displays the correct name
- [ ] Conversation start telemetry (`Conversation.Started`) appears in Application Insights

### Topic coverage
- [ ] All trigger phrases route to the correct topic
- [ ] Disambiguation fires for genuinely ambiguous phrases
- [ ] 3 unrecognised messages trigger Fallback then Escalate

### Error handling
- [ ] Force an error (e.g. call an action with invalid input) — verify test mode shows details, production shows safe message
- [ ] Error telemetry (`Agent.ErrorOccurred`) appears in Application Insights
- [ ] `ConversationInit` succeeds when M365 connector is unavailable — conversation continues with defaults

### Knowledge search
- [ ] Questions answered by knowledge sources return generative answers
- [ ] Citation markers are stripped (if `remove-citations` is active)
- [ ] Questions not in knowledge base fall through to Fallback
- [ ] `Knowledge.AnswerFound` and `Knowledge.AnswerNotFound` telemetry fires

### Auth (if applicable)
- [ ] Sign-in prompt appears on first message
- [ ] Sign-in prompt does NOT appear on token refreshes
- [ ] `Auth.SignInCompleted` telemetry fires after successful sign-in
- [ ] User's display name appears correctly after `ConversationInit`

### Out-of-scope
- [ ] Out-of-scope trigger phrases route to the `OutOfScope` topic
- [ ] The redirect message names the correct resource
- [ ] `Agent.OutOfScope` telemetry fires

### Escalation
- [ ] "Speak to a human" triggers `Escalation` directly
- [ ] Fallback escalates after 3 failed attempts
- [ ] `Agent.EscalationTriggered` telemetry fires with correct `Reason`
- [ ] `TransferConversation` handoff works in the target channel

### Action Safety (if connector actions are present)
- [ ] Every connector action has a `# SAFETY TIER:` comment at the top of its file
- [ ] All Medium tier actions show a confirmation card before executing — test Cancel path
- [ ] All High tier actions route through an approval flow — they never execute inline
- [ ] Safety tier table in `00-ai-decision-framework.md` Step 5 is complete and signed off

---

## 12. Action Safety

Every connector action must be classified into one of three safety tiers before build starts. Assign the tier based on what the action does — not what you intend it for.

### The three tiers

| Tier | What the action does | Guardrail | Copilot Studio implementation |
|------|---------------------|-----------|-------------------------------|
| **Low — Read** | Search, look up, summarise, retrieve | Audit log (telemetry only) | Direct `InvokeConnectorTaskAction` — scaffold telemetry already handles the log |
| **Medium — Write** | Create, submit, update, send | User confirmation before execution | `confirmation-card.json` → ConditionGroup → action only if confirmed |
| **High — Destructive** | Delete, transfer funds, revoke access, bulk modify | Middleware + separate approval channel | `confirmation-card.json` → Power Automate approval flow → action only on approval |

### Rule: never execute destructive actions inline

High tier actions must never execute in the same turn as the user's request. Always route through an external approval step.

```yaml
# WRONG — destructive action inline
- kind: InvokeConnectorTaskAction
  operationId: DeleteRecord   # fires immediately on user request

# RIGHT — destructive action via approval flow
- kind: InvokeConnectorTaskAction
  operationId: RunFlow        # triggers an approval flow; action executes only after approval
  parameters:
    flowId: <APPROVAL_FLOW_ID>
    requestedBy: =Global.UserDisplayName
```

### Declare the tier in every action file

Add this comment block at the top of every action file (`connector-action.mcs.yml` or `mcp-action.mcs.yml`):

```yaml
# SAFETY TIER: Low / Medium / High
# GUARDRAIL:   None / confirmation-card / approval-flow
# REASON:      <one line — why this tier was assigned>
```

### Medium tier — confirmation card pattern

```yaml
# 1. Show the card
- kind: SendActivity
  id: sendConfirmCard_REPLACE
  activity:
    attachments:
      - contentType: application/vnd.microsoft.card.adaptive
        content: ${{confirmation-card content here}}

# 2. Capture the user's choice
- kind: Question
  id: waitForChoice_REPLACE
  variable: Topic.UserChoice
  prompt: ""
  entityType: UserEntireResponse

# 3. Branch: execute only if confirmed
- kind: ConditionGroup
  id: checkChoice_REPLACE
  conditions:
    - id: confirmed_REPLACE
      condition: =Topic.UserChoice.action = "confirm"
      actions:
        - kind: InvokeConnectorTaskAction   # safe — user confirmed
          id: executeAction_REPLACE
  elseActions:
    - kind: SendActivity
      id: sendCancelled_REPLACE
      activity: Action cancelled. Nothing was changed.
```

### Audit command

Before go-live, run this to confirm every connector action has a declared tier:

```bash
# Find all connector action files
grep -rl "InvokeConnectorTaskAction" agents/
# For each file — confirm it contains # SAFETY TIER:
grep -l "SAFETY TIER" agents/**/*.yml
```

The two lists should match. Any file in list 1 that is not in list 2 is missing its tier declaration.

→ Full implementation guide: [`project-delivery/13-ai-engineer-realtime-guide.md`](../project-delivery/13-ai-engineer-realtime-guide.md)
