# Component: Child Agent

A specialist sub-agent that handles a specific domain within an orchestrator (multi-agent) pattern.

## When to Use

Add this component when:
- Building an orchestrator agent that delegates to specialist sub-agents
- Different parts of the agent's scope need independent instructions, knowledge, and tools
- You want strong separation between domains (e.g. HR, IT, Finance in a single corporate assistant)

## File

| File | Purpose |
|------|---------|
| `child-agent.mcs.yml` | AgentDialog — specialist sub-agent with its own instructions, inputs, and outputs |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `<Child Agent Display Name>` | Friendly name (e.g. `HR Specialist`, `IT Helpdesk`) |
| `<ChildAgentName>` | Internal name, no spaces (e.g. `HRSpecialist`) |
| `description` | Detailed routing description — this is what the parent agent reads |
| `instructions` | System prompt for this specialist |
| `inputType.properties` | Inputs the parent passes (or remove block if none) |
| `outputType.properties` | Outputs this agent returns (or remove block if none) |

## The Routing Description is Critical

The parent orchestrator decides which child agent to route to based **entirely** on the `description` field. A vague description leads to misrouting. Be specific:

```yaml
# Bad — too vague
description: Handles HR questions

# Good — specific enough to route correctly
description: >
  Handles all HR queries related to leave and absence management.
  Routes here for: leave balance enquiries, submitting leave requests,
  leave policy questions, sick day reporting.
  Example messages: "How many days off do I have?", "I want to book annual leave",
  "What's the sick leave policy?"
```

## Multi-Agent Architecture

```
Parent Orchestrator Agent
├── child-agent (HR Specialist)
├── child-agent (IT Helpdesk)
└── child-agent (Finance Queries)
```

Each child agent:
- Has its own `instructions` system prompt scoped to its domain
- Can have its own knowledge sources and actions
- Returns results to the parent, which sends the final response to the user

## Inputs and Outputs

Use `inputType` to pass context from the parent (e.g. user's department).
Use `outputType` when the child needs to return structured data the parent will use.

If the child agent just answers conversationally and the parent doesn't need a structured return value, remove both blocks:
```yaml
inputType: {}
outputType: {}
```

## Gotchas

- One `.mcs.yml` file per child agent — don't combine multiple specialists into one file
- The `condition` on `OnToolSelected` lets you restrict a child agent to specific channels (e.g. Teams only). Remove it for channel-agnostic routing
- Child agents in Copilot Studio are YAML-only (not creatable via the canvas UI as of 2025)
