# Writing Instructions and OutOfScope Content

Canonical reference for the two files every agent needs: `agent.mcs.yml → instructions:` and
`topics/OutOfScope.topic.mcs.yml`. All recipe guides link here for the detailed steps.

---

## Why write these two together

`generate-agent-instructions.md` produces both in one Claude pass:
- The `## What I can help with` section → goes into `instructions:`
- The `## What I cannot help with` section → becomes trigger phrases in `OutOfScope.topic.mcs.yml`
- The `## Handling out-of-scope questions` section → becomes the `SendActivity` redirect message

Writing them separately risks mismatches (agent says it handles X but OutOfScope also catches X).

---

## Option A — Use a ready-made persona (5 min)

Each recipe specifies which persona file fits best. The four available are:

| Persona file | Best for |
|---|---|
| `prompts/system-prompts/hr-assistant.md` | HR, leave, benefits, onboarding |
| `prompts/system-prompts/it-helpdesk.md` | IT support, service desk, action-taking agents |
| `prompts/system-prompts/customer-support.md` | External customer-facing agents |
| `prompts/system-prompts/knowledge-base.md` | Generic internal knowledge base agents |

**Steps:**

```
1. Open the persona file your recipe recommends
2. Copy everything inside the triple-backtick block
3. Paste into agent.mcs.yml replacing the entire instructions: | block
4. Replace every [BRACKET] value:
     [Company Name]  →  e.g. Contoso
     [SCOPE]         →  e.g. HR policies and leave management
     [company].com   →  your contact email domain
5. Proceed to "Apply to OutOfScope.topic.mcs.yml" below to fill in trigger phrases manually
```

---

## Option B — Generate both with Claude (10 min, recommended)

```
1. Open prompts/ai-prompts/generate-agent-instructions.md
2. Copy the prompt template and paste into a Claude conversation
3. Fill in the variables:
     Project brief:   "Answers questions about [topic].
                       Must NOT handle [out-of-scope areas]. Redirect to [contact]."
     Agent name:      [Your agent name]
     Primary users:   [Internal employees / External customers / etc.]
     Authentication:  [None / ManualAzureAD / Integrated]
     Tone:            [Professional / Friendly / Formal]
4. Claude returns the full instructions: | block — paste it into agent.mcs.yml
5. Claude also returns OutOfScope phrases — paste those into OutOfScope.topic.mcs.yml
```

Claude's output structure:

```yaml
instructions: |
  ## What I can help with
  - [in-scope topic 1]
  - [in-scope topic 2]

  ## What I cannot help with          ← paste into OutOfScope.topic.mcs.yml triggerQueries
  - Payroll queries — contact: payroll@company.com
  - IT issues — contact: it@company.com

  ## Handling out-of-scope questions  ← becomes the SendActivity text
  Say: "I only handle [domain]. For [topic], [contact] is your best resource."
```

---

## Apply to agent.mcs.yml

Paste the output replacing the entire `instructions: |` block. Every line must be indented
exactly 2 spaces under `instructions: |` — YAML is whitespace-sensitive.

---

## Apply to OutOfScope.topic.mcs.yml

Map Claude's "What I cannot help with" output to the OutOfScope template fields:

```
Claude output                                →  OutOfScope.topic.mcs.yml
─────────────────────────────────────────────────────────────────────────────
"Payroll queries — payroll@company.com"         triggerQueries:
"IT issues — it@company.com"                      - payroll
                                                  - what is my salary
                                                  - IT support
                                                  - my laptop is broken

                                                SendActivity:
                                                  "I'm only set up for [domain].
                                                   For [topic], [contact] is your
                                                   best contact."
```

**Copy the file if it is not already in your topics/ folder:**

```powershell
# PowerShell
Copy-Item "base\topics\OutOfScope.topic.mcs.yml" "agents\<display name>\topics\OutOfScope.mcs.yml" -Force
```
```bash
# Mac / Linux
cp base/topics/OutOfScope.topic.mcs.yml "agents/<display name>/topics/OutOfScope.mcs.yml"
```

**Placeholders to replace:**

| Placeholder | Replace with | Example |
|-------------|-------------|---------|
| `<out-of-scope phrase 1–5>` | Trigger phrases from Claude's "What I cannot help with" | `payroll`, `IT support`, `expense claim` |
| `<DOMAIN>` | What this agent handles | `HR policies and leave management` |
| `<OUT-OF-SCOPE-TOPIC>` | The out-of-scope area in the redirect message | `IT support` |
| `<CONTACT>` | Where to send the user | `it@contoso.com` |
| `_REPLACE1`, `_REPLACE2` | Any 6-char unique string | `_ab3f9x` |

**Need more trigger phrases?** Paste this into Claude:

```
Generate 10 trigger phrases for a Copilot Studio OutOfScope topic.
The agent handles: [your domain].
Out-of-scope areas: [list].
Include: formal, casual, abbreviated, and question-form phrasings.
Output as a YAML list (- phrase format).
```

→ Prompt template: [`prompts/ai-prompts/generate-topic.md`](../prompts/ai-prompts/generate-topic.md)
→ All prompt templates: [`prompts/README.md`](../prompts/README.md)
