# Templates Inventory

Complete list of every buildable template in this repository — 60 templates across 11 categories.

> **When to use this doc:** When you want a complete inventory of all YAML templates before starting a build.
> Use this as a checklist to confirm which templates you've customized and which still have `<PLACEHOLDER>` values.
> Cross-reference with `components/README.md` for per-template placeholder guides.

---

## Base Templates
*6 files — copy `base/` to start every new agent*

| # | File | Purpose |
|---|------|---------|
| 1 | `base/agent.mcs.yml` | Agent identity, system prompt, conversation starters |
| 2 | `base/settings.mcs.yml` | Auth mode, language, recognizer, access policy |
| 3 | `base/topics/Greeting.topic.mcs.yml` | Welcome message + `Conversation.Started` telemetry |
| 4 | `base/topics/Fallback.topic.mcs.yml` | Unknown intent — retries 3× then escalates to human |
| 5 | `base/topics/OnError.topic.mcs.yml` | System error handler — safe message + `Agent.ErrorOccurred` telemetry |
| 6 | `base/topics/OutOfScope.topic.mcs.yml` | Known out-of-domain phrases — clear redirect message + `Agent.OutOfScope` telemetry |

---

## Topic Component Templates
*12 drop-in topics — copy the one you need into your agent's `topics/` folder*

| # | File | Trigger | Purpose |
|---|------|---------|---------|
| 7 | `components/topics/_scaffold/TopicScaffold.topic.mcs.yml` | `OnRecognizedIntent` | **Start every new topic here** — built-in error handling, telemetry, CSAT guard |
| 8 | `components/topics/action-invoke/ActionInvoke.topic.mcs.yml` | `OnRecognizedIntent` | Calls a connector action with output validation and telemetry |
| 9 | `components/topics/auth/SignIn.topic.mcs.yml` | `OnSignIn` | Sign-in flow with `Auth.SignInStarted` / `Auth.SignInCompleted` telemetry |
| 10 | `components/topics/conversation-init/ConversationInit.topic.mcs.yml` | `OnActivity` (first message) | Loads M365 user profile into `Global.UserDisplayName` and `Global.UserCountry` |
| 11 | `components/topics/disambiguation/Disambiguation.topic.mcs.yml` | `OnSelectIntent` | Clarifies ambiguous intents, logs `Agent.DisambiguationTriggered` |
| 12 | `components/topics/escalation/Escalation.topic.mcs.yml` | `BeginDialog` | Human handoff via `TransferConversation`, logs `Agent.EscalationTriggered` |
| 13 | `components/topics/feedback/Feedback.topic.mcs.yml` | `OnRecognizedIntent` / `BeginDialog` | Thumbs → star rating → issue category CSAT sequence |
| 14 | `components/topics/feedback-persisted/FeedbackPersisted.topic.mcs.yml` | `BeginDialog` | CSAT that writes feedback + cited sources to SharePoint and Dataverse; fires `Feedback.Persisted` telemetry |
| 15 | `components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml` | `OnUnknownIntent` | Generative answers from knowledge sources, logs `Knowledge.AnswerFound` / `AnswerNotFound` |
| 16 | `components/topics/out-of-scope/OutOfScope.topic.mcs.yml` | `OnRecognizedIntent` | Redirects out-of-scope queries with named resource, logs `Agent.OutOfScope` |
| 17 | `components/topics/question-branch/QuestionBranch.topic.mcs.yml` | `OnRecognizedIntent` | Collects user input and branches the conversation |
| 18 | `components/topics/remove-citations/RemoveCitations.topic.mcs.yml` | `OnGeneratedResponse` | Strips `[1][2]` citation markers from AI-generated responses |

---

## Action Templates
*2 templates — copy once per connector operation or MCP tool*

| # | File | Kind | Purpose |
|---|------|------|---------|
| 19 | `components/actions/connector/connector-action.mcs.yml` | `InvokeConnectorTaskAction` | Calls any Power Platform connector operation |
| 20 | `components/actions/mcp/mcp-action.mcs.yml` | `InvokeExternalAgentTaskAction` | Calls an MCP server tool |

---

## Knowledge Source Templates
*3 templates — copy once per knowledge source*

| # | File | Source Type | Purpose |
|---|------|------------|---------|
| 21 | `components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml` | SharePoint library | Internal document search and generative answers |
| 22 | `components/knowledge/public-website/public-website.knowledge.mcs.yml` | Public URL | Public website and documentation search |
| 23 | `components/knowledge/glossary/glossary.knowledge.mcs.yml` | Dataverse (CSV) | JIT acronym glossary — `triggerCondition: false`, loaded explicitly by `conversation-init` |

---

## Adaptive Card Templates
*6 templates — used inline inside topic YAML*

| # | File | Use case |
|---|------|---------|
| 24 | `components/adaptive-cards/confirmation-card.json` | Confirm or cancel before executing an action (required for Medium safety tier) |
| 25 | `components/adaptive-cards/status-card.json` | Display action result with status colour (success / warning / error) |
| 26 | `components/adaptive-cards/form-card.json` | Collect structured input — text, date, dropdown — in a single card |
| 27 | `components/adaptive-cards/feedback-thumbs.json` | Binary satisfaction (Yes / No) |
| 28 | `components/adaptive-cards/feedback-rating.json` | 1–5 star rating |
| 29 | `components/adaptive-cards/feedback-text.json` | Issue category dropdown (no free-text — PII safe) |

---

## Agent and Variable Templates
*8 templates*

| # | File | Kind | Purpose |
|---|------|------|---------|
| 30 | `components/agents/child-agent/child-agent.mcs.yml` | `AgentDialog` | Specialist sub-agent for orchestrator pattern (recipe 05) |
| 31 | `components/variables/global-variable/global-variable.variable.mcs.yml` | Conversation scope | Generic shared-state variable — user profile, locale, flags |
| 32 | `components/variables/user-country/UserCountry.variable.mcs.yml` | Conversation scope | User's M365 country — loaded by `conversation-init`, used for country-aware answers |
| 33 | `components/variables/user-display-name/UserDisplayName.variable.mcs.yml` | Conversation scope | User's M365 display name — loaded by `conversation-init`, used for personalised responses |
| 34 | `components/variables/glossary-var/Glossary.variable.mcs.yml` | Conversation scope | Customer acronym glossary — loaded by `conversation-init`, injected into orchestrator instructions |
| 35 | `components/variables/feedback-context/FeedbackContext.variable.mcs.yml` | Conversation scope | Topic name for the current interaction — set before calling `feedback-persisted` |
| 36 | `components/variables/feedback-context/FeedbackQuestion.variable.mcs.yml` | Conversation scope | User's question text — captured by `knowledge-search` or set manually in structured topics |
| 37 | `components/variables/feedback-context/FeedbackSources.variable.mcs.yml` | Conversation scope | Raw AI response with `[1][2]` citation markers — captured by `remove-citations` |

---

## CI/CD Pipeline Templates
*4 pipeline workflows + 1 CLI reference guide*

| # | File | Trigger | Purpose |
|---|------|---------|---------|
| 38 | `ci-cd/01-push-on-pr.yml` | Pull request to main | Validate YAML — blocks merge if placeholders remain |
| 39 | `ci-cd/02-promote-dev-to-uat.yml` | Merge to main | Promote agent from Dev to UAT |
| 40 | `ci-cd/03-promote-uat-to-prod.yml` | GitHub release tag | Promote UAT → Prod with approval gate; publish draft live |
| 41 | `ci-cd/04-solution-build-and-deploy.yml` | Push to main or manual | Solution-based build and deploy for managed environments |
| 42 | `ci-cd/05-solution-cli-guide.md` | Reference | Full `pac solution` command reference for building and deploying solutions from CLI |

---

## System Prompt Templates
*4 ready-made agent personas — paste into `agent.mcs.yml` → `instructions`*

| # | File | For |
|---|------|-----|
| 43 | `prompts/system-prompts/hr-assistant.md` | HR policies, leave management, benefits |
| 44 | `prompts/system-prompts/it-helpdesk.md` | IT support, service desk, password resets |
| 45 | `prompts/system-prompts/customer-support.md` | External customer-facing service agent |
| 46 | `prompts/system-prompts/knowledge-base.md` | Generic internal knowledge base assistant |

---

## AI Generation Prompts
*6 prompts — run in Claude to auto-generate YAML*

| # | File | What it generates |
|---|------|------------------|
| 47 | `prompts/ai-prompts/generate-topic.md` | Complete `.topic.mcs.yml` from a plain-English scenario |
| 48 | `prompts/ai-prompts/generate-agent-instructions.md` | System prompt for `agent.mcs.yml` |
| 49 | `prompts/ai-prompts/generate-adaptive-card.md` | Adaptive card JSON from a description |
| 50 | `prompts/ai-prompts/generate-eval-cases.md` | Eval test cases for routing accuracy testing |
| 51 | `prompts/ai-prompts/review-agent.md` | Agent quality review and improvement checklist |
| 52 | `prompts/ai-prompts/prompt-engineering-patterns.md` | P1–P10 pattern reference for system prompt design |

---

## Recipe Guides
*8 step-by-step guides — 6 Copilot Studio YAML, 2 pro-code (M365 Agents SDK + Azure AI Foundry)*

| # | File | What it builds | Complexity | Time |
|---|------|---------------|-----------|------|
| 53 | `recipes/01-basic-faq.md` | Generative Q&A from SharePoint documents | Low | 30 min |
| 54 | `recipes/02-authenticated-agent.md` | Sign-in + personalised M365 user context | Low–Medium | 45 min |
| 55 | `recipes/03-connector-action-agent.md` | Calls a Power Platform connector (submit, retrieve) | Medium | 60 min |
| 56 | `recipes/04-mcp-action-agent.md` | Calls an MCP server tool | Medium | 60 min |
| 57 | `recipes/05-orchestrator-agent.md` | Multi-specialist agent with child agents | High | 2+ hr |
| 58 | `recipes/06-full-featured-agent.md` | Auth + knowledge + actions + CSAT | High | 2+ hr |
| 59 | `recipes/07-m365-agents-sdk.md` | Pro-code agent (C# / TypeScript / Python) — wraps or extends Copilot Studio agents | High | 2+ hr |
| 60 | `recipes/08-azure-ai-foundry.md` | Azure AI Foundry agent — code interpreter, custom models, > 8K RPM scale, Progressive Enhancement from Copilot Studio | High | 3+ hr |

---

## Summary

| Category | Count |
|----------|-------|
| Base YAML templates | 6 |
| Topic component templates | 12 |
| Action templates | 2 |
| Knowledge source templates | 3 |
| Adaptive card templates | 6 |
| Agent / variable templates | 8 |
| CI/CD pipeline templates | 5 |
| System prompt templates | 4 |
| AI generation prompts | 6 |
| Recipe guides — Copilot Studio | 6 |
| Recipe guides — Pro-code (SDK + Foundry) | 2 |
| **Total** | **60** |

---

## How templates relate to each other

```
base/                          ← every agent starts here (6 files)
  │
  ├── components/topics/       ← drop in topics as needed (12 options)
  │     └── _scaffold/         ← start every NEW topic from this
  │
  ├── components/actions/      ← add connector or MCP actions (2 options)
  │
  ├── components/knowledge/    ← add knowledge sources (3 options)
  │
  ├── components/adaptive-cards/  ← wire into topic YAML (6 options)
  │
  └── components/agents/       ← add child agents for orchestrator (1)

recipes/                       ← documented combinations of the above (8 recipes)

prompts/system-prompts/        ← paste into agent.mcs.yml instructions (4)
prompts/ai-prompts/            ← run in Claude to generate any of the above (6)

ci-cd/                         ← wire up after first successful push (4 pipelines + 1 guide)
```

→ Full call signatures for every template: [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md)
→ Build walkthrough: [`QUICKSTART.md`](QUICKSTART.md)
