# Recipes

Documented combinations of base + components for common agent types. Each recipe lists:
- Which files to copy
- What to replace
- How the components wire together

## Index

| Recipe | What it builds | Complexity |
|--------|---------------|------------|
| [01 — Basic FAQ](01-basic-faq.md) | Generative Q&A over SharePoint docs | Low |
| [02 — Authenticated Agent](02-authenticated-agent.md) | Sign-in flow + personalised user context | Low–Medium |
| [03 — Connector Action Agent](03-connector-action-agent.md) | Agent that calls a Power Platform connector | Medium |
| [04 — MCP Action Agent](04-mcp-action-agent.md) | Agent that calls an MCP server tool | Medium |
| [05 — Orchestrator Agent](05-orchestrator-agent.md) | Multi-specialist orchestrator with child agents | High |
| [06 — Full-Featured Agent](06-full-featured-agent.md) | Auth + knowledge + actions + disambiguation | High |

## How to Read a Recipe

Each recipe follows the same structure:
1. **Use case** — the scenario this recipe is built for
2. **Components** — which files to copy from `base/` and `components/`
3. **Wiring** — how the components interact (order, dependencies, shared variables)
4. **Checklist** — step-by-step setup

Start with the simplest recipe that covers your use case. Add components from the more advanced recipes as your agent grows.
