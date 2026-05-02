# Agent Components

Child agent definitions for orchestrator (multi-agent) patterns.

## Available Agent Components

| Component | Kind | What it does |
|-----------|------|-------------|
| [`child-agent/`](child-agent/) | `AgentDialog` | Specialist sub-agent invoked by an orchestrator agent |

## When to Use This Pattern

Use child agents when:
- You have distinct specialisations that would clutter a single agent (e.g., HR + IT + Finance)
- Each specialisation has its own knowledge sources, actions, or instructions
- You want to route users to the right specialist transparently

**Overhead is high** — each child agent is a fully separate agent in the environment. Only use this pattern when a single agent would become too complex to maintain.

## How to Set Up an Orchestrator Pattern

1. Create the orchestrator agent using `base/` as the starting point
2. Create each child agent as a separate agent project using `base/`
3. In the orchestrator: add this `child-agent` component for each specialist
4. Replace `<CHILD_AGENT_NAME>` and `<CHILD_AGENT_SCHEMA>` with the child agent's details
5. The orchestrator routes to the child based on topic matching

See `recipes/05-orchestrator-agent.md` for the full setup guide.
