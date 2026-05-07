# Agent Components

Child agent template for the orchestrator pattern — one specialist sub-agent per domain.

---

## Components

| Folder | Kind | Use when… |
|--------|------|-----------|
| [`child-agent/`](child-agent/) | `AgentDialog` | Building an orchestrator that delegates to specialist agents |

---

## When to use child agents

Use the orchestrator pattern (recipe `05`) when:
- The agent needs to handle multiple distinct domains (HR + IT + Finance)
- Different domains need different knowledge sources or permissions
- You want to isolate failure — one child agent failing doesn't break others

For a single-domain agent, use topic components instead.

```bash
cp components/agents/child-agent/child-agent.mcs.yml \
   agents/<your-agent>/agents/<SpecialistName>/<SpecialistName>.mcs.yml
```

→ Full orchestrator pattern: [`../../recipes/05-orchestrator-agent.md`](../../recipes/05-orchestrator-agent.md)
