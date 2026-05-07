# Child Agent Template

**Kind:** `AgentDialog`

Specialist sub-agent for the orchestrator pattern. The parent (orchestrator) agent delegates domain-specific tasks to child agents.

## Files

| File | Purpose |
|------|---------|
| `child-agent.mcs.yml` | AgentDialog declaration — configure display name and agent endpoint |

## Quick start

```bash
cp components/agents/child-agent/child-agent.mcs.yml \
   agents/<your-orchestrator>/agents/<SpecialistName>/<SpecialistName>.mcs.yml
```

Each child agent is a separate Copilot Studio agent published to the same environment. The parent references it by `schemaName`.

**When to use:** Only when the orchestrator pattern genuinely adds value — multiple distinct domains, separate knowledge, or different permission requirements. For a single-domain agent, use topic components directly.

→ Full orchestrator recipe: [`../../../recipes/05-orchestrator-agent.md`](../../../recipes/05-orchestrator-agent.md)
