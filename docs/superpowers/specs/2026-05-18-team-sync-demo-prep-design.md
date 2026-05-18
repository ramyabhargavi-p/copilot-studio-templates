# Demo Prep — Team Sync: Copilot Studio Templates

**Date:** 2026-05-18
**Format:** 30-minute live demo
**Audience:** Mixed — interns, developers, senior engineers, tech leads, directors, and manager
**Goals:** Understand what the repo contains → Adopt it on next projects → Know how to contribute back

---

## Overview

A 30-minute structured walkthrough of the Copilot Studio templates repo. Four sections with a
clear narrative arc: why the repo exists, what's in it, how to use it (live build), and how to
start and contribute. Designed to land for all role levels simultaneously.

**Run of show:**

| # | Section | Time |
|---|---------|------|
| 1 | Why — the problem this solves | 5 min |
| 2 | What — repo walkthrough in VS Code | 8 min |
| 3 | How — live build of Basic FAQ agent (Recipe 01) | 12 min |
| 4 | Start + Contribute | 5 min |

---

## Section 1 — Why (5 min)

### Goal
Get everyone hooked before any code appears — including manager and directors.

### Talking points

Open with the actual problem the team recognizes:

> "Every time we build a new Copilot Studio agent, the first 2–3 days look the same. We set up
> error handling. We wire telemetry. We write a fallback topic. We create the CI/CD pipeline. We
> put together a UAT test plan. None of that is the actual agent — it's just the scaffolding we
> need before we can even start. And we do it from scratch every time, slightly differently each
> time."

Show the repo as the practical answer — one category at a time, one sentence each:

| What you used to do from scratch | What you use now |
|---|---|
| Write Greeting, Fallback, OnError, OutOfScope topics manually | Copy `base/` — 5 files, already has telemetry and retry logic built in |
| Figure out knowledge source YAML structure every time | Copy `components/knowledge/sharepoint/` or `public-website/` — fill in your URL |
| Build CI/CD pipelines per project | Copy `ci-cd/` — 5 GitHub Actions workflows, Dev → UAT → Prod already wired |
| Create UAT test plans and requirements docs each engagement | Open `project-delivery/` — 12 delivery artifacts ready to fill in |

Close the section with this honest expectation-setter:

> "Engineers still configure the placeholders and understand the YAML — this isn't a wizard.
> What it removes is the repetitive setup work, and it makes sure every agent we ship has the
> same quality baseline: consistent error handling, telemetry, and CI/CD, regardless of who
> built it."

---

## Section 2 — What (8 min)

### Goal
Show the repo folder structure in VS Code. Audience leaves knowing where to look for anything.
Do not open every file — one sentence per folder.

### Folder walkthrough script

**`base/`** (30 sec)
> "Every agent starts here. 5 files — agent definition, settings, and 4 system topics. Copy
> these first, configure the placeholders. These are the only files every agent needs regardless
> of what it does."

**`components/`** (2 min) — show subfolders:
- `topics/` — 11 drop-in topic patterns. Pick the one that matches what your agent needs to do.
- `knowledge/` — SharePoint, public website, or Dataverse glossary. Copy the one matching your source.
- `actions/` — connector action or MCP tool. One template each.
- `adaptive-cards/` — 6 card designs for confirmations, feedback, forms, status.
- `agents/` — child agent template for orchestrator pattern.

**`recipes/`** (1 min)
> "Recipes are the bridge between templates and a working agent. Each recipe is a step-by-step
> guide that tells you exactly which base files and components to combine, in what order, for a
> specific agent type."

Show the recipe table from `README.md`. Point out: recipes 1–4 for developers, 5–6 for senior
engineers, 7–8 for pro-code paths.

**`prompts/`** (30 sec)
> "Two types. System prompts are ready-made agent personas — HR, IT helpdesk, customer support,
> knowledge base. AI prompts are instructions you run in Claude to generate YAML or eval test
> cases for you."

**`ci-cd/`** (30 sec)
> "5 GitHub Actions workflows. Push to Dev on every PR. Manual promote to UAT. Manual promote
> to Prod. Copy them in, set your environment IDs, done."

**`project-delivery/`** (30 sec)
> "12 delivery artifacts — requirements questionnaire, design worksheets, UAT test plan,
> enterprise readiness assessment. These are for the non-code side of delivery. Useful from day
> one of a project, not just at the end."

**`ENGINEERING-PLAYBOOK.md`** (1 min)
> "The single reference document for the entire repo."

Put the role-based entry point table on screen:
> "Interns start at Stage 0 and walk every step. Developers jump to Stage 2. Tech leads go
> straight to governance and CI/CD. Directors only need Stage 0 and Stage 5. Nobody has to read
> the whole thing."

---

## Section 3 — How (12 min)

### Goal
Live build of a Basic FAQ agent using Recipe 01. Show the full developer workflow:
browser → VS Code → push → test.

### Pre-staging checklist (complete 10 min before the call)

- [ ] Browser tab 1: `make.preview.microsoft.com` — blank agent already created and named "Demo FAQ Agent", on Overview page
- [ ] Browser tab 2: Copilot Studio test pane open and ready
- [ ] VS Code: this repo open in Explorer, terminal open at repo root
- [ ] PAC CLI authenticated — run `pac auth list` to confirm Dev environment is selected
- [ ] All other windows closed

### Live build steps

**Step 1 — Clone the agent (2 min)**

> "Agent is already created in the portal — I did that before the call to save time. Now I pull
> it into VS Code so I can work locally."

`Ctrl+Shift+P` → `Copilot Studio: Clone Agent` → sign in → select environment → select
"Demo FAQ Agent" → select `agents\` as output folder.

> "The extension creates `agents\Demo FAQ Agent\` with the minimal system topics. No telemetry,
> no retry logic yet — that's what we fix next."

**Step 2 — Copy base templates in (2 min)**

Run in terminal:
```powershell
$topics = "Greeting","Fallback","OnError","OutOfScope"
$topics | % { Copy-Item "base\topics\$_.topic.mcs.yml" "agents\Demo FAQ Agent\topics\$_.mcs.yml" -Force }
Copy-Item "base\agent.mcs.yml" "agents\Demo FAQ Agent\agent.mcs.yml" -Force
Copy-Item "base\settings.mcs.yml" "agents\Demo FAQ Agent\settings.mcs.yml" -Force
```

> "Four topic files and two config files. That's the base. These already have error handling,
> telemetry events, and a 3-retry fallback loop. I didn't write any of that — it came from the
> template."

Open `agent.mcs.yml`, show the `instructions` field, paste in
`prompts/system-prompts/knowledge-base.md` content.

> "System prompt — copy and paste, done."

**Step 3 — Add a SharePoint knowledge source (2 min)**

```powershell
Copy-Item "components\knowledge\sharepoint\sharepoint.knowledge.mcs.yml" "agents\Demo FAQ Agent\sharepoint.knowledge.mcs.yml"
```

Open the copied file. Show the two placeholders:
```yaml
url: <SHAREPOINT_SITE_URL>
libraryName: <LIBRARY_NAME>
```

> "Two placeholders. In a real project you put your SharePoint site URL and library name here.
> The point is you didn't write this file from scratch."

**Step 4 — Push to the portal (2 min)**

`Ctrl+Shift+P` → `Copilot Studio: Apply Changes`

While pushing:
> "In CI/CD this step is automated — `ci-cd/push-on-pr.yml` runs Apply Changes on every PR.
> The team never manually pushes to Dev."

**Step 5 — Test in the portal (2 min)**

Switch to browser tab 2 — Copilot Studio test pane.

| Input | What to say |
|-------|-------------|
| `Hello` | "Greeting topic fires. Welcome message matches the template." |
| `What is the refund policy?` | "Knowledge search fires — generative answer from the knowledge source." |
| `I want to speak to a human` | "Escalation path. Logs `Agent.EscalationTriggered` — that event lands in Application Insights if telemetry is wired." |

Close with:
> "That's a working agent — base, knowledge source, error handling, telemetry — in under 10
> minutes of actual work."

Transition:
> "Now — how does your team start using this, and how do you add your own templates back in?"

---

## Section 4 — Start + Contribute (5 min)

### Goal
Give every role a concrete next action. End with an open door for contribution.

### Part A — How to start (2.5 min)

Show `docs/QUICKSTART.md` on screen.

**1. Set up tools once** (30 sec)
> "Install PAC CLI, authenticate to your Dev environment, install the three VS Code extensions.
> `ENGINEERING-PLAYBOOK.md` Stage 1 walks every step — takes about 20 minutes the first time."

**2. Pick your recipe** (1 min)
> "Before writing a line of YAML, open `README.md` and find your agent type in the recipe table.
> That recipe tells you exactly which base files and components to combine. You're not figuring
> out the structure — it's already decided."

Show recipe table. Point to the Time column:
> "30 minutes to 2 hours depending on complexity. That's wall-clock time for the build itself,
> not including requirements or UAT."

**3. Follow the Engineering Playbook for your role** (30 sec)

Put role table on screen:
> "Interns — Stage 0 to 3. Developers — Stage 0 then Stage 2 onwards. Tech leads — Stage 5
> governance is a delivery blocker for everyone, read it first. Directors — Stage 0 decision
> matrix is the one page you need."

### Part B — How to contribute (2 min)

Show `components/topics/_scaffold/TopicScaffold.topic.mcs.yml`:
> "Every new topic starts from this scaffold — error handling, telemetry, and CSAT guard already
> wired in. If you build a topic pattern that solves a problem we don't have a template for,
> copy the scaffold, build your pattern, open a PR. It goes into `components/topics/` and the
> whole team has it next project."

Same principle for prompts and recipes:
> "New agent persona? Add it to `prompts/system-prompts/`. New recipe? Add it to `recipes/`.
> One markdown file, one PR."

### Closing line

> "The goal isn't for everyone to memorize this repo. It's for the team to stop reinventing
> the same scaffolding. Next time you start an agent, open `README.md`, pick your recipe, and
> you're building on what we've already figured out — not from blank."

---

## Rehearsal checklist

- [ ] Full dry run at least once end-to-end before the call
- [ ] Time each section — Section 3 (live demo) is the highest risk for overrun
- [ ] Have the `agents\Demo FAQ Agent\` folder pre-deleted so Clone Agent starts fresh
- [ ] Keep a backup: if Clone Agent or Apply Changes fails, have a pre-built screenshot of the test pane output ready
- [ ] Confirm PAC CLI auth the morning of the call (`pac auth list`)

---

## Reference links

- Repo entry point: `README.md`
- Full template inventory: `docs/TEMPLATES.md`
- Engineering Playbook: `ENGINEERING-PLAYBOOK.md`
- Quickstart: `docs/QUICKSTART.md`
- Recipe 01: `recipes/01-basic-faq.md`
- Topic scaffold: `components/topics/_scaffold/TopicScaffold.topic.mcs.yml`
