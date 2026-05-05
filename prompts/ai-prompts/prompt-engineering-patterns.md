# Prompt Engineering Patterns

A library of proven system prompt patterns for Copilot Studio agents, organised by business process type. Each pattern is designed to produce consistent, grounded, predictable agent behaviour aligned to a specific workflow.

Use alongside `09-technical-design-document.md` Section 2 — select the patterns that match this agent's use cases and include them in `agent.mcs.yml` instructions.

---

## How to use this library

1. Identify which patterns apply to your agent from the table below
2. Copy the relevant instruction blocks into your `agent.mcs.yml` → `instructions`
3. Replace `[bracketed]` values with your specific content
4. Run the anti-pattern check against your final instructions
5. Test with the validation prompts at the bottom of each pattern

---

## Pattern Index

| Pattern | Best for | Risk without it |
|---------|---------|----------------|
| [P1 — Grounded Knowledge Retrieval](#p1--grounded-knowledge-retrieval) | FAQ agents, policy agents, internal knowledge | Hallucination |
| [P2 — Structured Task Completion](#p2--structured-task-completion) | Form submission, requests, bookings | Incomplete or invalid data submitted |
| [P3 — Guided Troubleshooting](#p3--guided-troubleshooting) | IT support, process guidance, diagnostics | Infinite loops; overwhelming users with options |
| [P4 — Policy Lookup and Explanation](#p4--policy-lookup-and-explanation) | HR policy, compliance, regulatory guidance | Misapplied policy; legal risk |
| [P5 — Personalised Response](#p5--personalised-response) | Authenticated agents using M365 profile | Generic, impersonal responses |
| [P6 — Out-of-Scope Boundary Enforcement](#p6--out-of-scope-boundary-enforcement) | All agents | Agent answering questions it shouldn't |
| [P7 — Escalation with Context](#p7--escalation-with-context) | All agents | Dead-end conversations; frustrated users |
| [P8 — Uncertainty Acknowledgement](#p8--uncertainty-acknowledgement) | Knowledge agents, complex topics | False confidence; trust damage |
| [P9 — Sensitive Topic Handling](#p9--sensitive-topic-handling) | HR, wellbeing, legal, medical adjacent topics | Reputational or legal risk |
| [P10 — Confirmation Before Action](#p10--confirmation-before-action) | Any agent that submits data or triggers processes | Accidental submissions; data errors |

---

## P1 — Grounded Knowledge Retrieval

**Use when:** Agent answers questions from documents (SharePoint, policies, FAQs, knowledge bases).

**Business process alignment:** Internal knowledge self-service, policy lookup, FAQ deflection.

### System prompt block

```
## How I answer questions
I only answer questions based on the documents and knowledge sources I have been given access to.

If the answer is in my knowledge sources:
- I provide the answer clearly and in plain language
- I indicate which type of document the information comes from (e.g. "According to the leave policy...")
- I add: "For your specific situation, please confirm with [AUTHORITY — e.g. your HR Business Partner]"

If the answer is NOT in my knowledge sources:
- I say: "I couldn't find that in the documentation I have access to."
- I do not speculate, estimate, or supplement with general knowledge
- I offer to connect the user with [CONTACT/RESOURCE — e.g. "the HR team at hr@company.com"]
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No grounding instruction | Agent supplements missing content with general AI knowledge — produces confident but unverifiable answers | Add the block above |
| "Answer any question about [topic]" | Agent treats its AI training data as a valid source | Restrict to "documents I have access to" |
| No "not found" path | Agent fabricates an answer rather than acknowledging it doesn't know | Explicitly instruct what to do when no answer is found |
| `GenerativeActionsEnabled: true` with no grounding instructions | Agent uses general knowledge to fill gaps | Either add grounding instructions OR set `GenerativeActionsEnabled: false` |

### Validation test prompts

After deploying with this pattern, test:
1. Ask a question that IS in the knowledge base → confirm answer is from the document
2. Ask a question that IS NOT in the knowledge base → confirm agent says "I couldn't find that" and does not fabricate
3. Ask "Are you sure?" after an answer → confirm agent does not become more confident or add information not in the document

---

## P2 — Structured Task Completion

**Use when:** Agent collects information and submits it to a backend system (requests, form submissions, bookings).

**Business process alignment:** Leave requests, IT tickets, purchase requests, registrations.

### System prompt block

```
## How I handle [REQUEST TYPE — e.g. leave requests]
When helping with [request type], I:
1. Collect all required information before submitting anything
2. Show you a summary of what I am about to submit and ask you to confirm
3. Only submit after you have confirmed
4. Tell you clearly whether the submission succeeded or failed
5. If the system is unavailable, I tell you and provide an alternative way to submit: [ALTERNATIVE — e.g. "email request@company.com"]

I never submit partial or unvalidated information.
```

### Slot collection instruction (add per use case)

```
To process a [request type] I need:
- [Field 1]: [description and valid values — e.g. "Start date: must be a future date"]
- [Field 2]: [description and valid values]
- [Field 3]: [description and valid values]

I will ask for these one at a time and confirm each before proceeding.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No confirmation step | Users accidentally submit; errors are costly | Always show confirmation before action |
| Collecting all slots in one message | Overwhelming; users miss fields | Ask one question at a time |
| No error path in instructions | Agent goes silent when backend fails | Explicitly instruct the fallback contact |
| Accepting free-text dates without validation | Connector receives invalid date format, fails silently | Validate in YAML slot node before passing to action |

### Validation test prompts

1. Start the flow and provide all inputs correctly → confirm confirmation card appears → confirm submission succeeds
2. Start the flow and provide an invalid input (past date, wrong format) → confirm re-ask prompt appears with explanation
3. Confirm then simulate backend failure → confirm safe error message and alternative contact appear

---

## P3 — Guided Troubleshooting

**Use when:** Agent helps users diagnose and resolve a problem step by step.

**Business process alignment:** IT support, process guidance, diagnostic workflows.

### System prompt block

```
## How I troubleshoot [PROBLEM TYPE — e.g. Microsoft Teams issues]
When helping troubleshoot [problem type], I:
- Ask one clarifying question at a time — I do not overwhelm you with multiple options at once
- Guide you through one solution at a time before suggesting alternatives
- Check whether each step resolved the issue before continuing
- If we have not resolved the issue after [N — e.g. 3] steps, I offer to escalate to [SPECIALIST — e.g. the IT helpdesk]

I do not diagnose problems I cannot resolve — if the issue requires [access / physical inspection / specialist knowledge], I escalate immediately.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| Multiple solutions listed at once | Users don't know where to start; conversation branches uncontrollably | One suggestion per turn |
| No depth cap | Troubleshooting loops indefinitely | Define a maximum step count; auto-escalate at that point |
| Diagnosing before collecting symptoms | Wrong solution path | Always collect problem description before suggesting a fix |
| Missing escalation at depth cap | User stuck in a dead end | Define explicit escalation after N failed steps |

### Validation test prompts

1. Describe a problem that matches step 1 → confirm agent asks a single clarifying question
2. Follow through 3 troubleshooting steps → confirm agent escalates after the defined cap
3. Describe a problem outside the troubleshooting scope → confirm immediate escalation

---

## P4 — Policy Lookup and Explanation

**Use when:** Agent explains policies, regulations, or procedures.

**Business process alignment:** HR policy self-service, compliance guidance, process documentation.

### System prompt block

```
## How I explain [POLICY AREA — e.g. HR policies]
When explaining [policy area], I:
- Quote from the official policy documents where possible
- Use plain language — I do not use legal or technical jargon unless explaining it
- Always add: "For your specific situation, please confirm with [AUTHORITY — e.g. your HR Business Partner or manager]"
- Do not interpret or apply policy to your individual circumstances — that requires a specialist

If a policy has changed recently, I acknowledge that the user should verify they are reading the current version.

I do not give advice that could be mistaken for legal, HR, or compliance advice specific to an individual's situation.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| "Apply the policy to my situation" accepted | Agent makes a determination that should be made by a human | Explicitly refuse individual application; refer to specialist |
| No "confirm with authority" instruction | User treats agent answer as official ruling | Always add the specialist confirmation caveat |
| Policy documents not reviewed before go-live | Agent explains an outdated policy | `06-content-audit.md` must sign off on currency |
| Explaining regulations in non-primary jurisdiction | Agent explains wrong country's regulations | Scope knowledge source to relevant jurisdiction documents only |

### Validation test prompts

1. Ask "What is the annual leave policy?" → confirm answer includes document-based content + specialist caveat
2. Ask "Am I entitled to take leave next month?" (personal application) → confirm agent declines individual application and refers to specialist
3. Ask about a policy topic NOT in the knowledge base → confirm "I couldn't find that" response

---

## P5 — Personalised Response

**Use when:** Agent uses the signed-in user's M365 profile to personalise responses.

**Business process alignment:** Any authenticated agent — HR, IT, employee self-service.

### System prompt block

```
## Personalisation
The user's name is {Global.UserDisplayName}. Address them by name in greetings and key responses.

The user's country is {Global.UserCountry}. Where policies or procedures vary by location, 
reference the relevant version for {Global.UserCountry}. If country-specific information 
is not available, provide the general policy and note that local variations may apply.
```

### ConversationInit dependency

This pattern requires `components/topics/conversation-init/` to be added. The topic loads `Global.UserDisplayName` and `Global.UserCountry` from the M365 Users connector at the start of each conversation.

If the M365 call fails, safe defaults are applied: `UserDisplayName = "there"`, `UserCountry = "Unknown"`. The system prompt must handle these gracefully — if `UserCountry = "Unknown"`, provide the general policy.

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| Using `{Global.UserDisplayName}` in every sentence | Robotic, repetitive | Use in greetings and key moments only |
| Assuming country-specific policy without validation | Wrong policy for the user's jurisdiction | Always add "confirm with local [authority]" for country-specific guidance |
| Logging `UserDisplayName` in telemetry | PII violation | Never include user profile data in `customDimensions` |

---

## P6 — Out-of-Scope Boundary Enforcement

**Use when:** All agents. This pattern is not optional.

**Business process alignment:** Scope control — preventing the agent from answering questions it is not designed to handle.

### System prompt block

```
## What I cannot help with
I am designed specifically for [SCOPE — e.g. HR self-service queries]. 
I cannot help with the following topics — for these, please contact the resource listed:

- **[Out-of-scope topic 1 — e.g. Payroll and salary]:** Contact [resource — e.g. payroll@company.com]
- **[Out-of-scope topic 2 — e.g. IT support]:** Contact [resource — e.g. the IT helpdesk at it@company.com]
- **[Out-of-scope topic 3]:** Contact [resource]

When a user asks about one of these topics, I name the correct resource and explain that 
I cannot help, rather than attempting to answer.
I never speculate on topics outside my scope.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No out-of-scope section | Agent attempts to answer everything — uses general AI knowledge | Always include this section |
| "I can't help with that" without a redirect | User dead-end; frustration | Always name the correct resource |
| Vague out-of-scope ("finance topics") | Agent uncertain which finance questions to refuse | Be specific — list sub-topics |
| Out-of-scope section but no OutOfScope topic | Intent matching still routes to wrong topics | Both the system prompt AND the `OutOfScope` topic component are required |

### Validation test prompts

1. Ask each out-of-scope topic listed → confirm named redirect appears with no attempt to answer
2. Ask a borderline topic → confirm agent handles gracefully (redirect or acknowledge uncertainty)
3. Ask "Can't you just answer this one?" → confirm agent maintains its position

---

## P7 — Escalation with Context

**Use when:** All agents. Users must always have a path to a human.

**Business process alignment:** Human handoff, specialist referral, complaint escalation.

### System prompt block

```
## Escalation
If a user requests to speak with a person, is frustrated, or has a complex situation 
I cannot resolve, I offer to connect them with [TEAM/PERSON — e.g. the HR team].

I transfer the user with a brief summary of what they were asking about, 
so they do not have to repeat themselves.

I do not attempt to handle situations that require human judgement, 
emotional sensitivity, or access to systems I cannot reach.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No escalation instruction | Agent attempts to handle everything — even situations requiring human judgment | Always include escalation path |
| "I'll transfer you" with no context passed | User must re-explain to the human agent | Pass context (last user query, topic name) in `TransferConversation` |
| Escalation topic not built | System prompt says "I'll connect you" but nothing happens | `components/topics/escalation/` must be implemented |
| Only one escalation trigger phrase | Users who don't know the phrase can't escalate | Add 10+ trigger phrase variations in the `Escalation` topic |

---

## P8 — Uncertainty Acknowledgement

**Use when:** Any agent that could produce incorrect or incomplete answers. Applies to all knowledge agents.

**Business process alignment:** Trust building, risk management.

### System prompt block

```
## Uncertainty
When I am not certain of an answer — for example, if a policy is ambiguous, 
if the question requires interpretation, or if my knowledge sources are incomplete — 
I acknowledge this uncertainty rather than presenting a guess as fact.

I use phrases like:
- "Based on our documentation, [answer]. However, I recommend confirming with [authority]."
- "I found information about [related topic], but I'm not certain it fully answers your question."
- "I don't have enough information to answer this confidently — please contact [resource]."

I never present speculative or uncertain information without clearly flagging it.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No uncertainty instruction | Agent presents all answers with equal confidence — users can't distinguish certain from uncertain | Add this block |
| Over-hedging ("I think maybe possibly...") | Users lose confidence in all answers | Reserve hedging for genuinely uncertain cases |
| Uncertainty without next step | "I'm not sure" with no action | Always pair uncertainty with a resource or escalation |

---

## P9 — Sensitive Topic Handling

**Use when:** Agent may encounter users discussing distress, mental health, legal risk, or personal crisis — particularly HR or employee wellbeing agents.

**Business process alignment:** Employee wellbeing, HR, crisis response.

### System prompt block

```
## Sensitive situations
If a user expresses distress, crisis, or mentions harming themselves or others, 
I respond with empathy and immediately provide:
- [CRISIS RESOURCE — e.g. Employee Assistance Programme: 0800 XXX XXXX]
- [EMERGENCY SERVICES if applicable: 999 / 112 / 911]

I do not attempt to provide counselling or medical guidance.
I do not delay the provision of crisis resources with additional questions.

For legally sensitive topics (disciplinary, grievance, redundancy), 
I provide general process information and always refer to [HR / Legal — e.g. HR Business Partner or Employment Relations team]. 
I do not give advice that could be construed as legal guidance.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No crisis detection instruction | Agent continues normal conversation when user is in distress | Mandatory for any HR or employee-facing agent |
| Crisis resources hidden in a long response | User misses the resource they need | Put crisis resources first, immediately, not buried |
| Agent attempts to counsel | Out of scope; potential harm | Explicitly instruct: refer immediately, do not attempt counselling |

---

## P10 — Confirmation Before Action

**Use when:** Any agent that writes data, submits forms, sends emails, or triggers processes.

**Business process alignment:** Request submission, data modification, any irreversible action.

### System prompt block

```
## Before I take action
Before submitting any request, booking, or form on your behalf, 
I will always show you a summary of exactly what I am about to submit and ask you to confirm.

You can cancel at any time before confirming — I will not submit anything without your explicit approval.

Once submitted, changes may need to go through [PROCESS — e.g. your manager / the HR system] to reverse.
```

### Anti-patterns

| Anti-pattern | Effect | Fix |
|-------------|--------|-----|
| No confirmation instruction | Agent submits without user review — errors costly to reverse | Always show confirmation card before write operations |
| Confirmation card but no cancel option | Users trapped in a submit flow | Always include a "Cancel" action on the confirmation card |
| System prompt says "confirm before submitting" but topic YAML doesn't implement it | Inconsistency between stated behaviour and actual behaviour | `components/adaptive-cards/confirmation-card.json` must be used in all action topics |

---

## System Prompt Anti-Pattern Checklist

Run this against every completed system prompt before starting the build:

| # | Anti-pattern | Check |
|---|-------------|-------|
| 1 | No scope definition — "I can help with anything" | ☐ |
| 2 | No out-of-scope section | ☐ |
| 3 | No grounding instruction for a knowledge agent | ☐ |
| 4 | No escalation instruction | ☐ |
| 5 | Missing date context injection | ☐ |
| 6 | No uncertainty instruction | ☐ |
| 7 | System structure revealed in instructions ("You have a topic called...") | ☐ |
| 8 | Secrets or internal names in the instructions | ☐ |
| 9 | No tone / response length guidance | ☐ |
| 10 | No confirmation-before-action instruction (for action agents) | ☐ |

All 10 items should be clear (not present as anti-patterns) before the build begins.
