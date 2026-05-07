# Components

Drop-in building blocks for Copilot Studio agents. Each component is a self-contained YAML file (or small folder) with built-in error handling, telemetry, and CSAT — copy it into your agent and configure the placeholders.

---

## How components assemble into an agent

```mermaid
flowchart TD
    BASE[base/] --> AGENT([Your Agent])

    subgraph COMP["components/  — drop in as needed"]
        T[topics x11]
        AC[actions x2]
        K[knowledge x3]
        CA[adaptive-cards x6]
        V[variables x5]
        CH[agents x1]
    end

    T --> AGENT
    AC --> AGENT
    K --> AGENT
    CA --> T
    V --> T
    CH --> AGENT
```

Start with `base/` (6 files). Add components from `components/` as your agent needs them. Never write YAML from scratch.

---

## What's here

| Folder | Count | Contents | Use when… |
|--------|-------|----------|-----------|
| [`topics/`](topics/) | 11 | Conversation topic templates | Adding a capability to an agent |
| [`actions/`](actions/) | 2 | Connector and MCP action types | Calling external systems |
| [`knowledge/`](knowledge/) | 3 | Knowledge source types (SharePoint, web, glossary) | Answering questions from documents |
| [`adaptive-cards/`](adaptive-cards/) | 6 | Card templates (confirmation, form, feedback) | Collecting input or showing results |
| [`agents/`](agents/) | 1 | Child agent template | Orchestrator pattern with specialist sub-agents |
| [`variables/`](variables/) | 5 | Global variable templates | Sharing state across topics in a conversation |

---

## How to use a component

```bash
# Step 1 — Copy the component into your agent folder
cp components/topics/escalation/Escalation.topic.mcs.yml \
   agents/<your-agent>/topics/Escalation.topic.mcs.yml

# Step 2 — Replace <SCHEMA> with your agent's schemaName in the file
sed -i 's/<SCHEMA>/<your-schema-name>/g' agents/<your-agent>/topics/Escalation.topic.mcs.yml

# Step 3 — Open in VS Code — extension replaces _REPLACE node IDs on save

# Step 4 — Replace any remaining <PLACEHOLDER> values (queue names, URLs, etc.)
grep -n "<" agents/<your-agent>/topics/Escalation.topic.mcs.yml
```

### Placeholder convention (applies to all components)

| Placeholder type | Example | Action |
|-----------------|---------|--------|
| `<ANGLE_BRACKETS>` | `<SCHEMA>`, `<SHAREPOINT_URL>` | Replace manually before push |
| `_REPLACE` | `sendActivity_REPLACE` | Auto-replaced by VS Code extension on save |
| `schemaName` prefix | `contoso_agent.topic.Escalate` | Follows from your `schemaName` in `agent.mcs.yml` |

### Verify nothing was missed before pushing

```bash
# Both commands must return zero output before pac copilot push
grep -rn "<" agents/<your-agent> --include="*.yml"
grep -rn "_REPLACE" agents/<your-agent> --include="*.yml"
```

---

## Claude skills for components

| Task | Skill |
|------|-------|
| Generate a new topic from a description | `/copilot-studio:new-topic` |
| Add a connector or MCP action | `/copilot-studio:add-action` |
| Add a knowledge source | `/copilot-studio:add-knowledge` |
| Add an adaptive card to a topic | `/copilot-studio:add-adaptive-card` |
| Validate all component YAML | `/copilot-studio:validate` |

→ Full call signatures and input/output specs: [`../docs/COMPONENT-REGISTRY.md`](../docs/COMPONENT-REGISTRY.md)
