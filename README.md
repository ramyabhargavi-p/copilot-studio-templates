# Copilot Studio Templates

Reusable YAML templates for building production-quality Copilot Studio agents.
Every topic has built-in error handling, telemetry, and CSAT — nothing to add manually.

```mermaid
flowchart TD
    subgraph Start["Step 1 — Copy base/"]
        B[base]
    end
    subgraph Add["Step 2 — Add from components/"]
        C[topics]
        K[knowledge]
        AC[actions]
        V[variables]
    end
    subgraph Guide["Reference"]
        R[recipes]
        P[prompts]
    end
    subgraph Ship["Step 3 — Automate with ci-cd/"]
        CI[ci-cd]
    end

    B --> AGENT([Your Agent])
    C --> AGENT
    K --> AGENT
    AC --> AGENT
    V --> AGENT
    P -->|paste into| B
    R -.->|follow| AGENT
    CI -.->|deploys| AGENT
```

---

## Where to start

| Goal | Go to |
|------|-------|
| **Build your first agent** (30–60 min) | [`QUICKSTART.md`](QUICKSTART.md) |
| **Engineering guide — intern to director** | [`ENGINEERING-PLAYBOOK.md`](ENGINEERING-PLAYBOOK.md) |
| **Full enterprise delivery** (all phases) | [`START-HERE.md`](START-HERE.md) |
| **Something is broken** | [`troubleshooting/README.md`](troubleshooting/README.md) |

---

## Folder structure

| Folder | What's inside | Go here when… |
|--------|--------------|---------------|
| [`base/`](base/) | 5 files every agent needs — agent, settings, Greeting, Fallback, OnError | Starting a new agent |
| [`components/`](components/) | Drop-in topics, actions, knowledge sources, cards, variables | Adding a capability |
| [`recipes/`](recipes/) | Step-by-step guides for 8 common agent patterns | Choosing an agent architecture |
| [`prompts/`](prompts/) | System prompt templates + AI generation prompts | Writing the agent persona |
| [`examples/`](examples/) | End-to-end worked examples (IT Helpdesk) | Seeing a full build in context |
| [`project-delivery/`](project-delivery/) | Discovery → Design → Build → UAT documents (`00`–`13`) | Running a governed delivery |
| [`governance/`](governance/) | Responsible AI + security review checklists | Pre-go-live sign-off |
| [`launch/`](launch/) | Go-live checklist, user communication, hypercare guide | Shipping to production |
| [`operations/`](operations/) | KQL monitoring queries, alerts, runbook | Post-launch health and incidents |
| [`ci-cd/`](ci-cd/) | GitHub Actions pipelines for Dev → UAT → Prod | Setting up CI/CD |
| [`troubleshooting/`](troubleshooting/) | Common errors and fixes | Something is broken |
| [`commands/`](commands/) | Quick-reference command sheets (pac, git, VS Code) | Looking up a command |

---

## Reference docs

| File | What it covers |
|------|---------------|
| [`COMPONENT-REGISTRY.md`](COMPONENT-REGISTRY.md) | Call signatures, inputs, and outputs for every component |
| [`TEMPLATES.md`](TEMPLATES.md) | Full inventory of all 55 templates |
| [`ENGINEERING-PLAYBOOK.md`](ENGINEERING-PLAYBOOK.md) | Platform decision, setup, build, governance, CI/CD, telemetry, monitoring |
| [`BEST-PRACTICES.md`](BEST-PRACTICES.md) | Design rules, error handling, telemetry, naming |
| [`TOOLS-AND-PLUGINS.md`](TOOLS-AND-PLUGINS.md) | Install `pac` CLI, VS Code extensions, Copilot Studio Kit |
| [`ACTION-SAFETY-PATTERNS.md`](ACTION-SAFETY-PATTERNS.md) | Safety tiers and confirmation patterns for write actions |
| [`SKILLS-REFERENCE.md`](SKILLS-REFERENCE.md) | Claude skills for generating topics, running evals, validating YAML |
| [`TEAM-GUIDE.md`](TEAM-GUIDE.md) | Role-based entry points, onboarding for new developers |

---

## Conventions

| Convention | Rule |
|------------|------|
| `<AngleBrackets>` | Required placeholder — replace before use |
| `_REPLACE` suffixes | Node IDs — auto-replaced by VS Code extension on save |
| `schemaName` prefix | Every component ID starts with the agent's `schemaName` |
| One file per component | Never combine actions, knowledge, or child agents into one file |
| Feature branch only | Never work directly on `main` — use `feature/<agent-name>` |
