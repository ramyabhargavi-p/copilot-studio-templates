# AI Prompt: Generate Evaluation Test Cases

Use this prompt to generate a Copilot Studio evaluation CSV from your agent's topic list and knowledge sources.

---

## Full Eval CSV Generator

```
You are a Copilot Studio testing specialist. Generate an evaluation test CSV for a Copilot Studio agent.

Output format: CSV with columns: utterance,expectedTopic,expectedResponse,notes
Rules:
- For each topic: write 3 utterances (exact phrase, paraphrase, edge case)
- For topics with knowledge search: write 5 utterances that the knowledge base should answer,
  plus 2 utterances clearly NOT in scope (expectedTopic: Fallback)
- Always include rows for: Greeting, Fallback (nonsense input), Escalation, and each Out-of-Scope area
- expectedResponse column: include 1-3 keywords that should appear in a good response (leave blank if not applicable)
- notes column: brief context for each row (e.g. "core topic", "edge case", "out-of-scope redirect")
- Do not include header commentary — output only the CSV rows (include the header row)

Agent topics:
[LIST YOUR TOPICS AND THEIR TRIGGER PHRASES HERE]

Out-of-scope areas:
[LIST OUT-OF-SCOPE TOPICS]

Knowledge source subject:
[DESCRIBE WHAT THE KNOWLEDGE BASE COVERS]
```

---

## Example Input

```
Agent topics:
- Greeting (OnConversationStart)
- Get Leave Balance: trigger phrases: "how many leave days do I have", "check my annual leave", "leave balance"
- Submit Leave Request: trigger phrases: "I want to book annual leave", "request time off", "submit leave"
- HR Policy: trigger phrases: "what is the policy on", "remote working policy", "dress code"
- Escalate to Human: trigger phrases: "speak to a human", "transfer me", "human please"
- Out of Scope: trigger phrases: "IT support", "payroll", "book a flight"
- Knowledge Search (OnUnknownIntent)
- Fallback (OnUnknownIntent)

Out-of-scope areas:
- IT support → IT helpdesk
- Payroll / salary → Payroll team
- Flights / travel bookings → Travel team

Knowledge source subject:
HR policies and procedures: annual leave policy, remote working policy, performance review process, onboarding guide
```

## Example Output

```csv
utterance,expectedTopic,expectedResponse,notes
,,, System topics
How are you?,Greeting,welcome,Conversation start
asdfghjkl,Fallback,rephrase,Unknown intent - attempt 1
speak to a human,Escalate to Human,connecting,Direct escalation trigger
I need IT help,Out of Scope,IT helpdesk,Clear out-of-scope redirect
what is my salary,Out of Scope,payroll,Out-of-scope - payroll
book me a flight,Out of Scope,travel,Out-of-scope - travel
,,, Leave Balance
how many days of annual leave do I have,Get Leave Balance,leave balance,Core topic - exact
check my holiday entitlement,Get Leave Balance,leave balance,Paraphrase
how much time off do I have left this year,Get Leave Balance,leave balance,Informal phrasing
,,, Leave Request
I want to book 3 days of annual leave,Submit Leave Request,request,Core topic
I'd like to take some time off next week,Submit Leave Request,,Edge case - vague dates
request holiday,Submit Leave Request,,Abbreviated
,,, Knowledge Search
what is the remote working policy,Knowledge Search,remote working,Knowledge source topic
how does performance review work,Knowledge Search,performance review,Knowledge source topic
what should I do on my first day,Knowledge Search,onboarding,Knowledge source topic
how many days annual leave am I entitled to,Knowledge Search,entitlement,Policy question
what is the dress code,Knowledge Search,dress code,Policy question
can the agent help me with my mortgage,Fallback,,Not in knowledge base
what time does the canteen open,Fallback,,Not in knowledge base
```

---

## Targeted Prompt: Expand weak topics

```
My Copilot Studio eval shows low routing accuracy for the topic "[Topic Name]" (current accuracy: X%).
The current trigger phrases are:
[LIST CURRENT TRIGGER PHRASES]

Generate 10 additional trigger phrases that cover:
- Different vocabulary (synonyms, informal language)
- Different question structures (how do I / what is / can you / I need to)
- Different levels of specificity (very specific to very vague)
- Common misspellings or abbreviations

Output as a YAML list.
```

## Targeted Prompt: Identify eval coverage gaps

```
Review this eval CSV and identify coverage gaps:
1. Which topics have fewer than 3 test utterances?
2. Are there test utterances for: Greeting, Fallback, Escalation, Out-of-Scope?
3. Are there any topics in the agent NOT covered by the eval?
4. Are there negative tests (utterances that should NOT match a topic)?

Agent topics: [LIST]
Eval CSV:
[PASTE CSV]
```
