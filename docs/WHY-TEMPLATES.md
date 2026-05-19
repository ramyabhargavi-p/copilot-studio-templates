# Why Use These Templates?

A direct answer to the question every developer asks: "Can't I just build this in the UI,
or write the same thing myself?"

**Yes — you can.** These templates do not unlock capabilities the UI or a skilled developer
cannot. They exist for different reasons depending on which folder you are looking at.

---

## When you do not need templates

| Scenario | Verdict |
|----------|---------|
| Proof of concept or demo | UI is completely sufficient. Build, test, publish. |
| One developer, one-off project, never going to production | UI is fine. |
| Exploring Copilot Studio for the first time | Start in the UI. Come back to templates when you are ready to ship. |

---

## Where templates genuinely help — ranked by value

### 1. CI/CD pipelines — `ci-cd/`  *(highest value)*

The UI has no Dev → UAT → Prod promotion. Every release is a manual republish and
reconfigure in each environment with no audit trail and no rollback path.

The `ci-cd/` templates close this gap: push to Dev on every PR, manual promote to UAT,
manual promote to Prod. Any developer *could* write GitHub Actions workflows from scratch —
but it takes hours, and the result varies per person. These are tested, copy-and-configure.

---

### 2. Delivery artifacts — `project-delivery/`  *(high value)*

Requirements questionnaire, UAT test plan, enterprise readiness assessment, functional design
document — every project needs these, and without templates they get created ad-hoc, skipped
under deadline pressure, or inconsistent in structure across engagements.

No developer would write the same UAT test plan twice by choice. These are fill-in, not
create-from-scratch.

---

### 3. Consistent telemetry schema — `base/`  *(high value for teams, medium for solo)*

Any developer can add telemetry. The problem is they name events differently:

| Developer | What they log |
|-----------|--------------|
| Dev A | `FallbackTriggered` |
| Dev B | `fallback_triggered` |
| Dev C | `Agent.Fallback` |
| Dev D | `UnknownIntent` |

Six months later you have five agents in production and you cannot write a single
Application Insights query that works across all of them. You have to know which agent used
which naming convention, then write five separate queries.

The `base/` templates enforce one schema across every agent — same event names, same property
keys — regardless of who built it:

```
Agent.FallbackTriggered   { ConversationId, UserQuery, FallbackCount, Channel, TimeUTC }
Agent.ErrorOccurred       { ConversationId, ErrorCode, Channel, TimeUTC }
Agent.OutOfScope          { ConversationId, UserQuery, Channel, TimeUTC }
Agent.EscalationTriggered { ConversationId, Channel, TimeUTC }
Knowledge.AnswerFound     { ConversationId, UserQuery, Channel, TimeUTC }
Knowledge.AnswerNotFound  { ConversationId, UserQuery, Channel, TimeUTC }
```

One KQL query monitors the entire agent fleet:

```kusto
customEvents
| where name == "Agent.FallbackTriggered"
| summarize count() by tostring(customDimensions.Channel), bin(timestamp, 1d)
```

---

### 4. Error handling and retry logic — `base/`  *(medium value — speed and floor, not capability)*

Any senior developer can write a 3-retry fallback loop and a test-vs-production error handler.
The templates do not save you from not knowing how.

What they do:

- **Speed:** Copying takes 30 seconds. Writing it takes 30–45 minutes. Across ten projects
  that is meaningful time.
- **Quality floor:** A junior developer or someone new to Copilot Studio may not know about
  `System.FallbackCount`, may not split `OnError` into test vs production mode, and will
  likely skip `OutOfScope` entirely (the UI does not create it on a blank agent). Templates
  make the production baseline apply to everyone, not just senior staff.

---

### 5. Topic and action patterns — `components/`  *(medium value)*

`components/topics/` contains solved patterns for problems every team encounters: escalation,
disambiguation, CSAT collection, auth sign-in, knowledge search with citation removal.

Any developer could write these. The templates save the research time (how does
`TransferConversation` work? what triggers `OnSelectIntent`?) and give a tested starting
point rather than a blank file.

`components/actions/` adds output validation and telemetry on connector/MCP calls that the
UI does not include when it generates action YAML.

---

### 6. Adaptive cards — `components/adaptive-cards/`  *(medium value)*

Adaptive card JSON is verbose and error-prone to write from scratch. The 6 templates
(confirmation, status, form, feedback thumbs/rating/category) are PII-safe and tested. The
feedback cards deliberately use dropdowns instead of free-text to avoid capturing PII in CSAT
responses — a constraint that is easy to miss when writing your own.

---

### 7. System prompts and AI generation prompts — `prompts/`  *(convenience)*

`prompts/system-prompts/` are ready-made agent personas. Any developer can write a system
prompt — these are a starting point, not a requirement.

`prompts/ai-prompts/` are prompts to run in Claude to generate topic YAML, eval cases, or
review agent quality from plain-English descriptions. Useful for speeding up authoring, not
a capability gap.

---

## The honest summary

| Template area | The real reason to use it |
|---------------|--------------------------|
| `ci-cd/` | The UI has no CI/CD at all — this closes a genuine capability gap |
| `project-delivery/` | Delivery artifacts get skipped without templates — this makes them default |
| `base/` telemetry schema | Any dev can add telemetry, but naming diverges — templates enforce one schema for cross-agent monitoring |
| `base/` error handling | Senior devs can replicate it — templates make the production floor apply to juniors too, and save 30 min per project |
| `components/topics/` | Solved patterns — saves research time, not capability |
| `components/actions/` | Adds output validation and logging the UI omits |
| `components/adaptive-cards/` | Verbose JSON, PII-safe constraints — saves authoring time |
| `prompts/` | Convenience — any developer can write these |

---

## The one-line version

> "The UI builds a working agent. Templates build an agent a team can maintain, monitor,
> and deploy consistently — regardless of who built it."

- **Working agent** — right responses, correct topics, knowledge connected
- **Production agent** — telemetry schema consistent enough to query across agents, CI/CD
  to promote across environments, delivery artifacts to sign it off

---

→ For the full lifecycle breakdown — what is impossible, time-consuming, or a non-obvious
best practice at each development phase: [WHAT-TEMPLATES-ENABLE.md](WHAT-TEMPLATES-ENABLE.md)
