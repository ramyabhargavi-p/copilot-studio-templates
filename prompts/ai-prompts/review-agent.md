# AI Prompt: Review an Agent for Gaps

Use this prompt to audit an existing agent's YAML files for quality, completeness, and best practice compliance before publishing.

---

## Full Agent Audit Prompt

```
You are a Copilot Studio specialist reviewing an agent before production deployment.
Audit the YAML files below against these criteria and report findings as a prioritised list:

CRITICAL (must fix before go-live):
- [ ] OnError topic exists and has both test-mode and production message branches
- [ ] Fallback topic exists, has telemetry, and references an Escalate topic
- [ ] Escalation topic exists (Escalate / Escalate to Human)
- [ ] All _REPLACE ID suffixes have been replaced with unique strings
- [ ] All <PLACEHOLDER> values have been replaced
- [ ] Agent instructions include explicit out-of-scope topics with redirect targets
- [ ] No action topic uses connector output without validating for blank first

HIGH (fix before or shortly after go-live):
- [ ] Agent instructions include an escalation trigger and verbatim escalation message
- [ ] All topics with 5+ nodes have LogCustomTelemetryEvent at the start
- [ ] Knowledge search topics log AnswerFound and AnswerNotFound separately
- [ ] Agent instructions include date context: {Text(Today(),DateTimeFormat.LongDate)}
- [ ] OutOfScope topic exists if the agent has a clearly bounded domain
- [ ] Each topic has at least 5 trigger phrases

GOOD TO HAVE:
- [ ] Conversation starters reflect the top 3-4 user tasks
- [ ] remove-citations topic is present (if knowledge sources are internal)
- [ ] disambiguation topic is present (if more than 5 topics exist)
- [ ] ConversationInit has error handling with safe defaults

Agent YAML files:
---
[PASTE YAML FILES HERE — agent.mcs.yml, settings.mcs.yml, and all topic files]
---

For each finding:
1. State the issue (which file, which line/section)
2. State the risk if not fixed
3. Provide the exact fix (YAML snippet or instruction change)
```

---

## Quick Spot-Check Prompt (single file)

```
Review this Copilot Studio topic YAML for issues:

1. Are all _REPLACE ID suffixes unique (even within this file)?
2. Does any action output get used without a blank check?
3. Are there at least 5 trigger phrases?
4. Is there a LogCustomTelemetryEvent at the topic start?
5. Does every elseActions branch send a message (no silent failures)?

File:
[PASTE SINGLE TOPIC YAML HERE]
```

---

## Instructions Quality Review Prompt

```
Review these agent instructions for a Copilot Studio agent.
Identify:
1. Missing sections (scope, out-of-scope, escalation, response quality)
2. Vague or missing redirect targets in the out-of-scope section
3. Missing escalation trigger conditions or verbatim escalation message
4. Any instruction that could cause the AI to answer out-of-scope questions
5. Missing date context injection

Then rewrite the instructions with all gaps filled.

Current instructions:
[PASTE INSTRUCTIONS HERE]
```

---

## Pre-UAT Checklist Generator

```
Based on this agent's topic list and capabilities, generate a UAT test script.
For each topic, provide:
- 2 positive test cases (inputs that SHOULD trigger this topic)
- 1 edge case (ambiguous or borderline input)
- Expected response summary
- Pass/fail criteria

Also include tests for: fallback (3 unrecognised inputs), escalation, out-of-scope, and error handling.

Agent capabilities:
[PASTE topics list, actions list, and knowledge sources]
```
