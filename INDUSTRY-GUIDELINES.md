# Industry Guidelines for Copilot Studio Agent Development

Best practices from Microsoft's official guidance, the Power Platform community, and real-world delivery experience. Organised by theme.

---

## 1 — Start With the User Problem, Not the Technology

The single most common mistake is starting with "what can Copilot Studio do?" rather than "what does the user actually need?".

**Guideline:** Define the top 3–5 use cases your agent will handle before writing a single line of YAML. For each use case, write:
- Who is the user?
- What are they trying to do?
- How do they currently do it (without the agent)?
- What does success look like?

A well-scoped agent that does 3 things well delivers more value than an agent that does 20 things poorly.

**Reference:** Microsoft's [Responsible AI design principles for conversational AI](https://learn.microsoft.com/azure/ai-services/responsible-use-of-ai-overview)

---

## 2 — Define Scope and Out-of-Scope Before You Build

If you haven't defined what the agent *won't* do, you haven't defined what it *will* do.

**Guideline:** Before building any topic, write your out-of-scope list. For every out-of-scope area, define:
- What it is (e.g., "payroll queries")
- Where to redirect users (e.g., "contact payroll@company.com")

Put this directly in the system prompt and build an `OutOfScope` topic component. See `components/topics/out-of-scope/`.

**Why this matters:** An agent without defined scope will attempt to answer everything. Users who get wrong or hallucinated answers lose trust in the agent — and that trust is very hard to rebuild.

---

## 3 — Never Deploy Without an Escalation Path

Every agent must have a way to reach a human. This is not optional.

**Guideline:** Define the escalation queue name before you start building. Add the `escalation` component. Test it before UAT.

**Reference:** [Microsoft's responsible AI principle: Human oversight](https://learn.microsoft.com/azure/ai-services/responsible-use-of-ai-overview#human-oversight)

---

## 4 — Treat AI-Generated Answers as Outputs That Need Grounding

Copilot Studio uses generative AI for knowledge search answers. Generative AI can hallucinate — produce confident-sounding answers that are factually wrong.

**Guidelines:**
- Always configure knowledge sources with real, up-to-date documents
- Add grounding instructions to the system prompt: "Only answer based on the provided documents. If the answer is not in the documents, say so."
- Never deploy an agent to production without running eval and verifying groundedness ≥ 80%
- Audit the knowledge source content before adding it (see `project-delivery/06-content-audit.md`)

**Reference:** [Microsoft's grounding documentation](https://learn.microsoft.com/copilot-studio/nlu-generative-answers)

---

## 5 — Security and Privacy Are Not Afterthoughts

**Guidelines:**
- Complete `governance/security-review.md` and `governance/ai-ethics-checklist.md` before every go-live
- Use least-privilege permissions for all connector connections
- Never log PII in telemetry
- Test prompt injection resistance before go-live (tests I1–I5 in the ethics checklist)
- Apply DLP policies in the Power Platform environment to restrict which connectors can be used

**Reference:** [Power Platform DLP policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)

---

## 6 — Design for the Failure Case First

Most agent designs start with the happy path. Good agent design starts with: what happens when it goes wrong?

**Guidelines:**
- Every topic that calls an action must validate the response before using it
- The `OnError` topic must be configured and tested in production simulation mode
- Fallback must retry and then escalate — never leave a user with no path forward
- Error messages must be user-friendly — never expose raw exception messages to users

**Reference:** See `base/topics/OnError.topic.mcs.yml` and `BEST-PRACTICES.md` Section 2.

---

## 7 — Measure Before You Ship

Deploying without measurement means you have no way to know if the agent is working.

**Guidelines:**
- Connect Application Insights before go-live
- Run eval with routing accuracy ≥ 85% before UAT
- Set up alert rules from day one
- Define your baseline metrics on day 1 of hypercare — you can't improve what you haven't measured

**Reference:** `operations/monitoring-queries.md` and `project-delivery/05-eval-scenarios.md`

---

## 8 — Conversation Design Principles

**Be specific, not generic.** "I can help with HR queries" is less useful than "I can help with leave requests, HR policies, and onboarding questions."

**Confirm, don't assume.** For actions with real-world consequences (submitting a form, booking a resource), show a confirmation card and ask the user to confirm before executing.

**Handle partial input gracefully.** Users rarely provide complete information in one message. Design topics to collect missing information through follow-up questions.

**Keep responses concise.** Long walls of text in a chat interface are ignored. Aim for 2–4 sentences per response. Use bullet points for lists.

**Don't apologise excessively.** One "I'm sorry, I can't help with that" is professional. Three apologies in one response reads as unconfident.

**Reference:** [Microsoft Copilot Studio conversation design guidance](https://learn.microsoft.com/copilot-studio/guidance/overview)

---

## 9 — Version Control Everything

YAML files are code. Treat them like code.

**Guidelines:**
- Every agent's YAML must be in a git repository from day one
- Commit after every working change, not just at milestones
- Tag releases (e.g. `v1.0.0`) that correspond to production publishes
- Never make changes directly in Copilot Studio UI without subsequently extracting the YAML and committing it

**Why:** Without version control, there is no rollback. When something breaks in production, you cannot recover the last good state.

---

## 10 — Plan for Maintenance From the Start

Agents are not set-and-forget. Knowledge goes stale. User needs evolve. Routing accuracy degrades as language patterns shift.

**Guidelines:**
- Assign a named agent owner before go-live
- Schedule a quarterly review at launch (not "we'll do it when something breaks")
- Set up a feedback mechanism so users can report incorrect answers
- Re-run eval monthly using new utterances collected from `Agent.FallbackTriggered` telemetry

**Reference:** `BEST-PRACTICES.md` Section 11 — Testing Checklist.

---

## 11 — Apply These Microsoft-Specific Best Practices

| Practice | Why |
|----------|-----|
| Use `schemaName` prefixes on all component IDs | Prevents ID collisions across agents in the same environment |
| Use `_REPLACE` suffix convention and replace before push | Ensures every node has a unique ID — required for PAC CLI to accept the file |
| Inject the current date into the system prompt | Prevents the AI from answering time-relative questions with outdated assumptions |
| Use `ConversationInit` to load user context once | More efficient than loading M365 profile on every topic; sets safe defaults on failure |
| Use `remove-citations` for knowledge agents | Users don't need to see `[1][2]` markers — they look broken in a chat context |
| Set `startBehavior: UseLatestPublishedContentAndCancelOtherTopics` on OnError | Ensures error handler always runs even if another topic is in progress |

---

## 12 — Regulated Industry Guidance

### Healthcare

- Do not allow the agent to provide medical advice — always escalate to a healthcare professional
- Consider HIPAA / local health data regulations when storing conversation data
- Use `IsTestMode` checks to ensure patient data is never displayed in error messages

### Financial Services

- Do not allow the agent to provide investment advice — include explicit out-of-scope topic
- Consider FCA / SEC / local financial regulation for any agent touching financial data
- Log all agent-assisted financial transactions in Application Insights for audit purposes

### HR and People

- Be cautious with performance, disciplinary, or sensitive employee matters — always escalate to HR
- Ensure agents that access employee data comply with GDPR / local data protection law
- PII (names, IDs, salaries) must not appear in telemetry — review all `LogCustomTelemetryEvent` nodes

### Public Sector

- Apply accessibility standards (WCAG 2.1 AA) to all agent interfaces
- Follow government AI ethics frameworks (e.g. UK CDDO, Australian AIGI) where applicable
- Ensure the agent's knowledge sources are approved for public-facing use

---

## Key References

| Resource | URL |
|----------|-----|
| Microsoft Copilot Studio documentation | https://learn.microsoft.com/copilot-studio |
| Copilot Studio guidance (best practices) | https://learn.microsoft.com/copilot-studio/guidance/overview |
| Responsible AI for conversational AI | https://learn.microsoft.com/azure/ai-services/responsible-use-of-ai-overview |
| Power Platform DLP | https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention |
| Adaptive Cards documentation | https://adaptivecards.io |
| Power Platform Community | https://community.powerplatform.com |
| Copilot Studio Kit (GitHub) | https://github.com/microsoft/Copilot-Studio-Kit |
