# Evaluation Scenarios

Copilot Studio has a built-in evaluation framework that tests your agent against a set of utterances and scores it on topic routing accuracy and response quality.

This document explains how to set up evaluations and provides a template CSV for creating eval test sets.

---

## What Evaluations Test

| Dimension | What it measures |
|-----------|----------------|
| **Topic routing accuracy** | Does the agent trigger the correct topic for each test utterance? |
| **Response relevance** | Is the AI-generated response relevant to the question? |
| **Response groundedness** | Is the response grounded in knowledge sources (not hallucinated)? |
| **Response completeness** | Does the response fully answer the question? |

---

## Evaluation CSV Format

Copilot Studio evaluations accept a CSV with this schema:

```csv
utterance,expectedTopic,expectedResponse,notes
```

| Column | Required | Description |
|--------|----------|-------------|
| `utterance` | Yes | The test input (what the user says) |
| `expectedTopic` | Yes | Display name of the topic that should trigger |
| `expectedResponse` | No | Keywords or phrases that should appear in the response |
| `notes` | No | Context for reviewers |

---

## Sample Eval CSV Template

Save as `evals/<agent-name>-eval.csv` in your agent project folder.

```csv
utterance,expectedTopic,expectedResponse,notes
How can you help me?,Greeting,welcome,Conversation start test
How many days of annual leave do I have left?,Get Leave Balance,leave balance,Core topic test
What is the remote working policy?,Knowledge Search,remote working,Knowledge search test
I want to speak to IT support,Out of Scope,IT helpdesk,Out-of-scope redirect test
kjhgfd sdflkj,Fallback,rephrase,Unknown intent test
Speak to a human,Escalate to Human,connecting,Escalation test
Can you book a flight for me,Out of Scope,unable to help,Clear out-of-scope test
What are your opening hours?,Knowledge Search,,Knowledge search - may or may not have answer
```

---

## Building Your Eval CSV

### Step 1: Cover every topic
Include at least 3 utterances per topic:
- One exact trigger phrase
- One paraphrase
- One edge case

### Step 2: Cover system paths
Always include rows for:
- Greeting trigger
- Fallback (nonsense input)
- Escalation ("speak to a human")
- Out-of-scope (one per known out-of-scope area)

### Step 3: Add knowledge search scenarios
For agents with knowledge sources, add:
- 5 questions the knowledge base should answer
- 2 questions that are NOT in the knowledge base (expected topic: Fallback)

### Step 4: Size guide
| Agent size | Minimum eval rows |
|-----------|------------------|
| 1-5 topics | 20 rows |
| 6-10 topics | 40 rows |
| 11+ topics | 60+ rows |

---

## Running Evaluations in Copilot Studio

### Option 1 — Copilot Studio UI (manual, draft agent)
1. Open your agent in Copilot Studio
2. Go to **Test** → **Evaluate** (or similar, varies by version)
3. Upload your CSV
4. Review the routing accuracy report

### Option 2 — Copilot Studio Kit (batch, automated)
The [Copilot Studio Kit](https://github.com/microsoft/Copilot-Studio-Kit) supports batch evaluations via CLI:

```bash
# Install and configure the kit
# Run eval against your draft agent
pac copilot eval run --eval-file evals/my-agent-eval.csv --environment <env-id>
```

### Option 3 — AI-assisted eval case generation
Use the prompt in [`prompts/ai-prompts/generate-eval-cases.md`](../prompts/ai-prompts/generate-eval-cases.md) to generate your eval CSV from your topic list.

---

## Interpreting Eval Results

| Metric | Target | Action if below target |
|--------|--------|----------------------|
| Topic routing accuracy | > 85% | Review trigger phrases on low-scoring topics |
| Response groundedness | > 80% | Check knowledge source content quality |
| Response relevance | > 80% | Refine agent instructions |
| Out-of-scope routing | 100% | Review and tighten out-of-scope trigger phrases |

### Common failure patterns

| Pattern | Likely cause | Fix |
|---------|-------------|-----|
| Out-of-scope utterance routes to wrong topic | Topic trigger phrases are too broad | Add out-of-scope triggers; narrow topic phrases |
| Knowledge question routes to Fallback | Knowledge source doesn't contain the answer | Review SharePoint content; add missing documents |
| Multiple topics tie for the same utterance | Trigger phrase overlap | Add disambiguation topic; make trigger phrases more specific |
| Escalation topic doesn't fire | Trigger phrases don't match test utterance | Add more escalation trigger phrase variations |

---

## Eval Cadence

| When | What to run |
|------|------------|
| After each major build milestone | Spot eval (10-20 rows for new topics only) |
| Before UAT | Full eval (all topics) — target 85%+ routing accuracy |
| Before production publish | Full eval re-run on final build |
| Monthly post-launch | Re-run with new utterances collected from `Agent.FallbackTriggered` telemetry |
