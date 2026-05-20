# Topic Components

12 drop-in conversation topics. Each has telemetry, error handling, and a CSAT guard — nothing to add manually.

---

## What to add for your agent type

| If your agent… | Add these topics |
|----------------|-----------------|
| Every production agent | `out-of-scope`, `escalation`, `feedback` |
| Answers questions from SharePoint or a website | + `knowledge-search`, `remove-citations` |
| Persists feedback to SharePoint / Dataverse for Power BI | + `feedback-persisted` (requires `knowledge-search` + `remove-citations`) |
| Signs users in + greets them by name | + `conversation-init`, `auth` (ManualAzureAD only) |
| Calls a connector (reads data, submits a form) | + `action-invoke` |
| Asks one question and branches on the answer | + `question-branch` |
| Has 5+ topics with overlapping trigger phrases | + `disambiguation` |
| Writing a new custom topic | Start from `_scaffold` |

---

## Topic index

### Foundation — add to every production agent

| Folder | Trigger | Purpose |
|--------|---------|---------|
| [`out-of-scope/`](out-of-scope/) | `OnRecognizedIntent` | Redirects queries outside the agent's domain; logs `Agent.OutOfScope` |
| [`escalation/`](escalation/) | `OnRecognizedIntent` / `BeginDialog` from Fallback | Hands off to a live agent queue; logs `Agent.EscalationTriggered` |
| [`feedback/`](feedback/) | `OnRecognizedIntent` / `BeginDialog` | Thumbs → star rating → issue category CSAT; once per conversation |

> **Note:** `out-of-scope` is already included in `base/topics/OutOfScope.topic.mcs.yml`. You do not need to copy it from here if you started from `base/`.

### Knowledge agents — add when knowledge sources are configured

| Folder | Trigger | Purpose |
|--------|---------|---------|
| [`knowledge-search/`](knowledge-search/) | `OnUnknownIntent` | Telemetry hook for generative AI answers; logs `Knowledge.SearchInvoked` |
| [`remove-citations/`](remove-citations/) | `OnGeneratedResponse` | Strips `[1][2]` citation markers before response is sent to user |
| [`feedback-persisted/`](feedback-persisted/) | `BeginDialog` | CSAT that writes feedback + cited sources to SharePoint and Dataverse |

Use all three together. `remove-citations` calls `feedback-persisted`; `knowledge-search` captures the question and context for feedback.

### Authenticated agents — add when users sign in

| Folder | Trigger | Purpose |
|--------|---------|---------|
| [`conversation-init/`](conversation-init/) | `OnActivity` (first message) | Loads `UserDisplayName`, `UserCountry`, and glossary from M365 profile |
| [`auth/`](auth/) | `OnSignIn` | Sign-in flow — add only for `ManualAzureAD` auth mode |

### Interaction patterns — add as needed

| Folder | Trigger | Purpose |
|--------|---------|---------|
| [`action-invoke/`](action-invoke/) | `OnRecognizedIntent` | Calls a connector inline (read data, submit form, update record) |
| [`question-branch/`](question-branch/) | `OnRecognizedIntent` | Asks one question and branches the conversation on the answer |
| [`disambiguation/`](disambiguation/) | `OnSelectIntent` | Shows a choice card when 2+ topics match at similar confidence |

### Template for new topics

| Folder | Trigger | Purpose |
|--------|---------|---------|
| [`_scaffold/`](_scaffold/) | `OnRecognizedIntent` | **Start every new custom topic here** — telemetry, error handling, CSAT guard included |

---

## Usage rule

**Never write a topic from scratch.** Always copy `_scaffold/` first, then add your logic to the MAIN LOGIC section.

```bash
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/<your-agent>/topics/<TopicName>.topic.mcs.yml
```

For pre-built patterns (connector call, branching, sign-in) copy the matching template directly — it is already customised for that use case.

→ Per-topic placeholder tables and examples: open the `README.md` inside any topic folder
→ Call signatures and inputs/outputs: [`../../docs/COMPONENT-REGISTRY.md`](../../docs/COMPONENT-REGISTRY.md)
→ Generate a new topic from plain English: `/copilot-studio:new-topic`
