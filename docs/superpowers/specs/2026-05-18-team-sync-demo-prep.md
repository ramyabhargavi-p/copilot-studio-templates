# Team Sync Demo Prep — Copilot Studio Templates

**Date:** 2026-05-18
**Length:** 30 minutes
**Format:** Live demo (VS Code + Copilot Studio portal)
**Audience:** All role levels — interns, developers, senior engineers, tech leads, manager, directors
**Slide deck:** `docs/demo-prep-presentation.pptx`

---

## Goals

| Goal | How it is covered |
|------|------------------|
| Understand what the repo contains | Section 2 — folder walkthrough |
| Adopt it on the next project | Section 4 — quickstart steps |
| Contribute back to it | Section 4 — contribution paths |

---

## Run of Show

| # | Section | Slides | Time |
|---|---------|--------|------|
| 1 | Why — the problem this repo solves | 1–5 | 5 min |
| 2 | What — repo walkthrough in VS Code | 6–8 | 8 min |
| 3 | How — live build: Basic FAQ agent | 9–11 | 12 min |
| 4 | Start and Contribute | 12–15 | 5 min |

---

## Section 1 — Why (5 min) · Slides 1–5

### Opening (say this out loud)

> "Every time we build a new Copilot Studio agent, the first 2–3 days look the same.
> We set up error handling. We wire telemetry. We write a fallback topic. We create the CI/CD
> pipeline. We put together a UAT test plan. None of that is the actual agent — it is just
> scaffolding we need before we can even start. And we do it from scratch every time,
> slightly differently each time."

### Before vs After (Slide 5)

| What you built from scratch before | What you use now |
|------------------------------------|------------------|
| Greeting, Fallback, OnError, OutOfScope topics | `base/` — 5 files, telemetry and retry built in |
| Knowledge source YAML | `components/knowledge/` — copy and fill in your URL |
| CI/CD pipeline | `ci-cd/` — 5 workflows, Dev → UAT → Prod wired |
| UAT test plans and requirements docs | `project-delivery/` — 12 delivery artifacts ready |

### Honest expectation-setter (say this to your manager)

> "Engineers still configure the placeholders and understand the YAML — this is not a wizard.
> What it removes is the repetitive setup work, and it makes sure every agent we ship has the
> same quality baseline: consistent error handling, telemetry, and CI/CD, regardless of who built it."

---

## Section 2 — What (8 min) · Slides 6–8

Open VS Code with this repo. Walk the folder tree. One sentence per folder.

| Folder | What to say |
|--------|-------------|
| `base/` | "Every agent starts from these 5 files. Copy them first, configure the placeholders." |
| `components/topics/` | "11 drop-in topic patterns. Pick the one that matches what your agent needs to do." |
| `components/knowledge/` | "SharePoint, public website, or Dataverse glossary. Copy the matching one." |
| `components/actions/` | "Connector action or MCP tool. One template each." |
| `components/adaptive-cards/` | "6 card designs: confirmations, feedback, forms, status." |
| `recipes/` | "8 step-by-step guides combining base + components. Show the recipe table from README.md." |
| `prompts/` | "4 ready-made system prompt personas. 6 AI prompts for Claude to generate YAML for you." |
| `ci-cd/` | "5 GitHub Actions workflows. Copy them in, set your environment IDs, done." |
| `project-delivery/` | "12 delivery artifacts — requirements, design worksheets, UAT test plan, readiness assessment." |

### Engineering Playbook — show the role table (Slide 8)

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

## Section 3 — How (12 min) · Slides 9–11

### Pre-stage checklist — complete 10 min before the call

- [ ] Browser tab 1: `make.preview.microsoft.com` — blank agent "Demo FAQ Agent" already created, on Overview page
- [ ] Browser tab 2: Copilot Studio test pane open
- [ ] VS Code: this repo open, terminal at repo root
- [ ] Run `pac auth list` — confirm Dev environment is selected
- [ ] All other windows closed

### Step 1 — Clone the agent (2 min)

`Ctrl+Shift+P` → `Copilot Studio: Clone Agent` → sign in → select environment → select "Demo FAQ Agent" → output to `agents\`

> "Agent was created in the portal before the call to save time. The extension creates
> `agents\Demo FAQ Agent\` with minimal system topics — no telemetry, no retry logic yet."

### Step 2 — Copy base templates in (2 min)

```powershell
$t = "Greeting","Fallback","OnError","OutOfScope"
$t | % { Copy-Item "base\topics\$_.topic.mcs.yml" "agents\Demo FAQ Agent\topics\$_.mcs.yml" -Force }
Copy-Item "base\agent.mcs.yml" "agents\Demo FAQ Agent\agent.mcs.yml" -Force
Copy-Item "base\settings.mcs.yml" "agents\Demo FAQ Agent\settings.mcs.yml" -Force
```

> "6 files. These already have error handling, telemetry events, and a 3-retry fallback loop.
> Open agent.mcs.yml — paste in the system prompt from prompts/system-prompts/knowledge-base.md."

### Step 3 — Add a knowledge source (2 min)

```powershell
Copy-Item "components\knowledge\sharepoint\sharepoint.knowledge.mcs.yml" "agents\Demo FAQ Agent\" -Force
```

Open the file. Show the 2 placeholders: `url` and `libraryName`.

> "Two placeholders. In a real project you fill in your SharePoint site and library name.
> You did not write this file from scratch."

### Step 4 — Push to the portal (2 min)

`Ctrl+Shift+P` → `Copilot Studio: Apply Changes` (~30 sec)

> "In CI/CD this runs automatically on every PR via ci-cd/push-on-pr.yml.
> The team never manually pushes to Dev."

### Step 5 — Test in the portal (2 min)

| Type this | What to say |
|-----------|-------------|
| `Hello` | "Greeting topic fires. Welcome message matches the template." |
| `What is the refund policy?` | "Knowledge search fires — generative answer from the source." |
| `I want to speak to a human` | "Escalation path. Logs Agent.EscalationTriggered to Application Insights." |

**Closing line:**
> "That is a working agent — base, knowledge source, error handling, telemetry — in under
> 10 minutes of actual work."

---

## Section 4 — Start and Contribute (5 min) · Slides 12–15

### How to start (2.5 min)

1. **Set up tools once (~20 min):** install PAC CLI → `pac auth create` → install 3 VS Code extensions
   Full steps: `ENGINEERING-PLAYBOOK.md` Stage 1
2. **Pick your recipe:** open `README.md`, find your agent type in the recipe table, follow it
3. **Follow the Playbook for your role:** find your entry point, start at your stage
   Key shortcut: `docs/QUICKSTART.md` — working agent in under 1 hour

### How to contribute (2 min)

Show `components/topics/_scaffold/TopicScaffold.topic.mcs.yml`:

> "Every new topic starts from this scaffold — error handling, telemetry, and CSAT guard
> already wired. Build your pattern, open a PR, and the whole team has it next project."

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
- [ ] Time Section 3 specifically — highest overrun risk
- [ ] Delete `agents\Demo FAQ Agent\` folder so Clone Agent starts fresh on the day
- [ ] Backup plan: if Apply Changes fails, have a screenshot of the test pane output ready
- [ ] Confirm `pac auth list` the morning of the call
