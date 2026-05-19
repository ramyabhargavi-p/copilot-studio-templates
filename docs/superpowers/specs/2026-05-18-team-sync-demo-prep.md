# Team Sync Demo Prep — Copilot Studio Templates

**Date:** 2026-05-18
**Length:** 30 minutes
**Format:** Live demo (VS Code + Copilot Studio portal)
**Audience:** All role levels — interns, developers, senior engineers, tech leads, manager, directors
**Slide deck:** `docs/demo-prep-presentation.pptx`  (17 slides)

---

## Goals

| Goal | How it is covered |
|------|------------------|
| Understand what the repo contains and why | Section 1 — UI vs templates, what each folder solves |
| Adopt it on the next project | Section 4 — quickstart steps |
| Contribute back to it | Section 4 — contribution paths |

---

## Run of Show

| # | Section | Slides | Time |
|---|---------|--------|------|
| 1 | Why — where the UI stops and templates start | 1–5 | 5 min |
| 2 | What — repo walkthrough: what each folder solves | 6–9 | 8 min |
| 3 | How — live build: Basic FAQ agent | 10–13 | 12 min |
| 4 | Start and Contribute | 14–17 | 5 min |

---

## Section 1 — Why (5 min) · Slides 1–5

### Key message

The UI can build a working agent. These templates exist for what comes after — team consistency, production monitoring, multi-environment deployment, and repeatable delivery.

> **Anticipate this question from your manager:** "We can already build agents in the UI — why do we need templates?"
> Answer it on Slide 4 before anyone asks.

### Slide 4 — The UI is fine, until… (say one row at a time)

| Scenario | What happens without templates |
|----------|-------------------------------|
| Team of developers | Every developer wires error handling and telemetry differently. Six months later you have 5 agents with 5 different patterns nobody can maintain consistently. |
| Multiple environments | The UI has no Dev → UAT → Prod promotion. Every release is a manual republish and reconfigure with no audit trail. |
| Production monitoring | Default topics emit no telemetry. Zero visibility into fallback rate, escalation triggers, or error frequency once live. |
| More than one agent project | The second agent, you rebuild the same retry logic, CI/CD pipeline, and UAT test plan from scratch. |
| Onboarding a new team member | New developers learn by reading whatever the last person wrote — which varies. Templates give everyone the same starting point. |

### Slide 5 — The one-line answer (say this out loud)

> "The UI builds a working agent. Templates build an agent a team can maintain, monitor, and deploy consistently."

Then clarify what "production-ready" means versus "working":
- **Working agent** — right responses, correct topics, knowledge connected
- **Production agent** — telemetry to monitor it, CI/CD to deploy it, consistent patterns across the team, governance docs to sign it off

### Honest expectation-setter

> "Engineers still configure the placeholders and understand the YAML. This is not a wizard.
> What it removes is the repetitive setup work and makes sure every agent we ship has the same
> quality baseline — regardless of who built it."

---

## Section 2 — What (8 min) · Slides 6–9

Open VS Code with this repo. Walk the folder tree using the two-column slides. For each folder: name it, then say what problem it solves — not just what it contains.

### Slide 7 — base/ and components/

| Folder | What to say |
|--------|-------------|
| `base/` | "Copilot Studio creates Greeting, Fallback, and OnError by default — but minimal: one message, nothing else. These 5 files replace them. Fallback gets a 3-retry loop and escalation. OnError gets test-vs-production detection and telemetry. OutOfScope is not created by the UI at all — it only exists if you copy this template." |
| `components/topics/` | "11 drop-in patterns for common problems every team solves from scratch: escalation, disambiguation, CSAT collection, auth sign-in, knowledge search. Solved once, reused everywhere." |
| `components/knowledge/` | "Knowledge source YAML has a specific structure. Without a template, developers look up the schema each time or copy from a past project inconsistently. Pick the type matching your source, fill in your URL." |
| `components/actions/` | "The UI wires connector and MCP actions but without error handling or telemetry on the action call. These templates add output validation and logging so you know when an action fails in production." |
| `components/adaptive-cards/` | "Adaptive card JSON is complex to write from scratch. 6 tested, PII-safe cards: confirmation before an action, status after an action, form for structured input, thumbs/star/category for feedback." |

### Slide 8 — recipes/, prompts/, ci-cd/, project-delivery/

| Folder | What to say |
|--------|-------------|
| `recipes/` | "8 step-by-step guides. Each tells you exactly which base files and components to combine for a specific agent type. Without this, each developer assembles a different set of templates in a different order." |
| `prompts/system-prompts/` | "4 ready-made agent personas — HR, IT helpdesk, customer support, knowledge base. Paste directly into agent.mcs.yml. Skip writing the system prompt from scratch." |
| `prompts/ai-prompts/` | "6 prompts to run in Claude: generate topic YAML from plain English, generate eval test cases, review agent quality. Turns a description into production-ready YAML." |
| `ci-cd/` | "This is the biggest gap the UI leaves. No CI/CD, no environment promotion, no pipeline. These 5 workflows add Dev → UAT → Prod with a proper promotion process. Copy them in, set your environment IDs, done." |
| `project-delivery/` | "12 delivery artifacts every project needs: requirements questionnaire, UAT test plan, enterprise readiness assessment. Without templates, teams create these ad-hoc or skip them. These are fill-in, not create-from-scratch." |

### Slide 9 — Engineering Playbook role table

> "Nobody needs to read the whole thing. Find your role, start at your stage."

| Role | Start here |
|------|-----------|
| Intern / New to Copilot Studio | Stage 0 → Stage 3 (walk every step) |
| Developer (1–2 years) | Stage 0 → Stage 2 → Stage 3 |
| Senior developer | Stage 4, 4.5, 6, 9 |
| Tech lead | Stage 5, 6, 10 |
| Director / Business owner | Stage 0 and Stage 5 only |

**All roles: Stage 5 Governance is a delivery blocker. Read it before every engagement.**

---

## Section 3 — How (12 min) · Slides 10–13

### Pre-stage checklist — complete 10 min before the call

- [ ] Browser tab 1: `make.preview.microsoft.com` — blank agent "Demo FAQ Agent" already created, on Overview page
- [ ] Browser tab 2: Copilot Studio test pane open
- [ ] VS Code: this repo open, terminal at repo root
- [ ] Run `pac auth list` — confirm Dev environment is selected
- [ ] All other windows closed

### Step 1 — Clone the agent (2 min)

`Ctrl+Shift+P` → `Copilot Studio: Clone Agent` → sign in → select environment → select "Demo FAQ Agent" → output to `agents\`

> "The UI created this agent with the minimal defaults — Greeting, Fallback, OnError. One
> message each. Now we replace those with the production-ready versions from base/."

### Step 2 — Replace default topics with base/ (2 min)

```powershell
$t = "Greeting","Fallback","OnError","OutOfScope"
$t | % { Copy-Item "base\topics\$_.topic.mcs.yml" "agents\Demo FAQ Agent\topics\$_.mcs.yml" -Force }
Copy-Item "base\agent.mcs.yml"    "agents\Demo FAQ Agent\agent.mcs.yml"    -Force
Copy-Item "base\settings.mcs.yml" "agents\Demo FAQ Agent\settings.mcs.yml" -Force
```

> "We are overwriting the defaults, not creating topics from scratch. Open Fallback —
> show the retry logic. Open OnError — show the test-vs-production condition.
> This is what the UI default does not give you."

Open `agent.mcs.yml`, paste in `prompts/system-prompts/knowledge-base.md` as the system prompt.

### Step 3 — Add a knowledge source (2 min)

```powershell
Copy-Item "components\knowledge\sharepoint\sharepoint.knowledge.mcs.yml" "agents\Demo FAQ Agent\" -Force
```

Open the file. Show the 2 placeholders: `url` and `libraryName`.

> "Without this template, a developer looks up the knowledge source YAML schema, writes it
> from scratch, and gets the structure slightly wrong. Two placeholders — done."

### Step 4 — Push to the portal (2 min)

`Ctrl+Shift+P` → `Copilot Studio: Apply Changes` (~30 sec)

> "In CI/CD this runs automatically on every PR via ci-cd/push-on-pr.yml.
> The team never manually pushes to Dev."

### Step 5 — Test in the portal (2 min)

| Type this | What to say |
|-----------|-------------|
| `Hello` | "Greeting fires. Notice the response uses System.Bot.Name — not hardcoded." |
| `What is the refund policy?` | "Knowledge search fires — generative answer from the source." |
| `I want to speak to a human` | "Escalation path. This logs Agent.EscalationTriggered to Application Insights — you can alert on this in production." |

### Slide 13 — What the templates did in that demo (say before moving on)

> "What just happened: we did not write the retry logic, the telemetry, the error handler, or the
> knowledge source YAML. We configured placeholders. That is the difference. And every agent the
> team builds from this repo will have that same structure — same event names in Application
> Insights, same retry behaviour, same escalation pattern."

---

## Section 4 — Start and Contribute (5 min) · Slides 14–17

### How to start (2.5 min)

1. **Set up tools once (~20 min):** install PAC CLI → `pac auth create` → install 3 VS Code extensions
   Full steps: `ENGINEERING-PLAYBOOK.md` Stage 1
2. **Pick your recipe:** open `README.md`, find your agent type in the recipe table, follow it
3. **Follow the Playbook for your role:** find your entry point, start at your stage
   Key shortcut: `docs/QUICKSTART.md` — working agent in under 1 hour

### How to contribute (2 min)

Show `components/topics/_scaffold/TopicScaffold.topic.mcs.yml`:

> "Every new topic starts from this scaffold — error handling, telemetry, and CSAT guard
> already wired. Build your pattern on top, open a PR, and the whole team has it next project."

| Want to add | Where it goes |
|-------------|--------------|
| New topic pattern | `components/topics/` |
| New agent persona | `prompts/system-prompts/` |
| New recipe | `recipes/` |

### Closing line

> "The goal is not for everyone to memorise this repo. It is for the team to stop reinventing
> the same scaffolding. Next time you start an agent, open README.md, pick your recipe, and
> you are building on what we have already figured out — not from blank."

---

## Rehearsal checklist

- [ ] Full dry run end-to-end at least once before the call
- [ ] Time Section 3 — highest overrun risk; stop at 12 min regardless
- [ ] Delete `agents\Demo FAQ Agent\` folder before the call so Clone Agent starts fresh
- [ ] Practice opening Fallback and OnError YAML to show the difference from defaults — this is the key visual moment
- [ ] Backup plan: if Apply Changes fails, have a screenshot of the working test pane ready
- [ ] Confirm `pac auth list` the morning of the call

---

## Key objections and answers

| Objection | Answer |
|-----------|--------|
| "We can build agents in the UI already" | Slide 4 — yes, the UI builds a working agent. Templates build a production agent a team can maintain. |
| "Developers still need to understand YAML" | Correct — this is not a wizard. It removes the reinvention of patterns, not the need to understand them. |
| "This adds overhead to every project" | The overhead is one command to copy files. The saving is 2–3 days of scaffold work and inconsistency across agents. |
| "What if we want to do something the templates don't cover?" | The scaffold topic is the starting point. Build your pattern on it and add it back — the repo grows with the team. |
