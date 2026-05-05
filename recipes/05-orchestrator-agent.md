# Recipe 05 — Orchestrator Agent

A parent agent that routes user requests to specialist child agents, each handling a specific domain.

## Use Case

- Corporate assistant with HR, IT, and Finance specialists
- Multi-product support agent where each product has its own specialist
- Any agent where domain separation improves quality, maintainability, or compliance

## Components

```
base/                                       ← the parent orchestrator agent
├── agent.mcs.yml                           ← orchestrator instructions (routing, not domain knowledge)
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   └── disambiguation/
│       └── Disambiguation.topic.mcs.yml    ← when multiple specialists could apply
└── agents/
    └── child-agent/
        └── child-agent.mcs.yml             ← one copy per specialist (rename per domain)
```

## How It Works

```
User message
    │
    ▼
[Parent Orchestrator] reads child agent descriptions
    │
    ├─ Clear match → routes directly to matching child agent
    │
    ├─ Ambiguous match → Disambiguation topic → user clarifies
    │
    └─ No match → Fallback topic

[Child Agent] handles the request with its own instructions + knowledge + actions
    │
    └─ Returns result → Parent delivers to user
```

## Setup Checklist

### Parent Orchestrator

- [ ] Copy `base/` into the parent agent project folder
- [ ] `agent.mcs.yml` — write `instructions` focused on routing, not domain knowledge:
  ```
  You are an orchestrator. Route user requests to the appropriate specialist.
  Do not answer domain-specific questions yourself — always delegate to a specialist.
  ```
- [ ] Copy `Disambiguation.topic.mcs.yml` into the parent's `topics/` folder
- [ ] `Disambiguation.topic.mcs.yml` — replace `_REPLACE` suffixes and `<AGENT_SCHEMA>`

### Each Child Agent

- [ ] Copy `child-agent.mcs.yml` into the parent's `agents/` folder (one file per specialist)
- [ ] Rename each file descriptively: `HRSpecialist.mcs.yml`, `ITHelpdesk.mcs.yml`, etc.
- [ ] For each child agent file — replace all placeholders:
  - [ ] Display name and internal name
  - [ ] `description` — **this is the most important field** — be specific about what the child handles
  - [ ] `instructions` — the child's system prompt, scoped tightly to its domain
  - [ ] `inputType` / `outputType` — or remove if not passing structured data
- [ ] All topic files — replace every `_REPLACE` suffix with unique random strings

### Publishing

- [ ] Push to Copilot Studio
- [ ] In Copilot Studio, open each child agent and configure its knowledge sources and actions
- [ ] Test routing by asking questions that belong to each domain — verify the right specialist answers

## Naming Child Agent Files

```
agents/
├── HRSpecialist.mcs.yml
├── ITHelpdesk.mcs.yml
└── FinanceQueries.mcs.yml
```

## Gotchas

- Child agent `description` fields drive all routing — test routing with ambiguous queries to identify gaps
- Overlap between specialist domains causes misrouting — make descriptions mutually exclusive
- Child agents are YAML-only (not available in the Copilot Studio canvas UI)
- Each child agent can have its own knowledge sources and actions configured separately in Copilot Studio
