# Recipes

Eight step-by-step guides for the most common agent types. Recipes 01–06 are Copilot Studio YAML. Recipes 07–08 are pro-code (M365 Agents SDK and Azure AI Foundry) — use these when Copilot Studio alone is not enough.

---

## Pick your recipe

### Copilot Studio recipes (YAML, low-code)

| Recipe | Build this when… | Complexity | Time |
|--------|-----------------|-----------|------|
| [`01-basic-faq.md`](01-basic-faq.md) | Users ask questions answered in SharePoint docs. No sign-in. | Low | 30 min |
| [`02-authenticated-agent.md`](02-authenticated-agent.md) | Users must sign in. Agent greets them by name. | Low–Medium | 45 min |
| [`03-connector-action-agent.md`](03-connector-action-agent.md) | Agent submits or retrieves data from a business system (Dataverse, ServiceNow, SharePoint lists). | Medium | 60 min |
| [`04-mcp-action-agent.md`](04-mcp-action-agent.md) | Agent calls an external tool via MCP protocol. | Medium | 60 min |
| [`05-orchestrator-agent.md`](05-orchestrator-agent.md) | Agent routes across multiple specialist sub-agents. | High | 2+ hr |
| [`06-full-featured-agent.md`](06-full-featured-agent.md) | Auth + knowledge + connector actions + disambiguation + CSAT. | High | 2+ hr |

### Pro-code recipes (SDK + Azure)

| Recipe | Build this when… | Complexity | Time |
|--------|-----------------|-----------|------|
| [`07-m365-agents-sdk.md`](07-m365-agents-sdk.md) | You need custom orchestration, fine-grained model control, or multi-channel beyond Teams. Pro-code (C# / TypeScript / Python). | High | 2+ hr |
| [`08-azure-ai-foundry.md`](08-azure-ai-foundry.md) | You need code interpreter, custom models, > 8,000 RPM scale, or multi-agent workflows. Migrating from Copilot Studio ("Progressive Enhancement"). | High | 3+ hr |

---

## Not sure which to pick?

**Step 1 — Are you a maker or a pro-dev?**
- Maker / no code preferred → recipes `01`–`06` (Copilot Studio YAML)
- Pro-dev, need full control → recipes `07`–`08`

**Step 2 — Does the agent need to read or write data in a business system?**
- No → `01` or `02`
- Yes, via Power Platform connector → `03`
- Yes, via MCP tool → `04`

**Step 3 — Does the agent need to handle many topics across multiple domains?**
- No → use whichever of `01–04` fits
- Yes, hub-and-spoke → `05` or `06`
- Yes, with custom logic → `07` (SDK) calling `05`/`06`

**Step 4 — Do you need anything Copilot Studio can't provide?**
- Code interpreter (run Python in-agent) → `08` (Foundry)
- > 8,000 RPM / multi-region scale → `08` (Foundry)
- Custom model from Foundry catalog → `08` (Foundry)
- Multi-channel beyond Teams + Copilot → `07` (M365 Agents SDK)
- Fine-grained pre/post processing → `07` (M365 Agents SDK)

---

## How recipes 07 and 08 relate to recipes 01–06

```
Recipes 01–06 (Copilot Studio)
    │
    ├── Recipe 07 (M365 Agents SDK)
    │   └── Wraps or orchestrates Copilot Studio agents
    │       Uses @microsoft/agents-copilotstudio-client
    │
    └── Recipe 08 (Azure AI Foundry)
        ├── Receives calls FROM Copilot Studio (via connector action)
        ├── OR replaces specific Copilot Studio topics/agents
        └── Progressive Enhancement: Copilot Studio → Foundry over time
```

---

## What each recipe contains

Copilot Studio recipes (01–06):
1. **Component list** — exactly which YAML files to copy
2. **Values to change** — find/replace table
3. **Copy commands** — one bash command per file
4. **Setup checklist** — tick-box before pushing

Pro-code recipes (07–08):
1. **When to use vs Copilot Studio** — decision table
2. **Project structure** — folder layout
3. **Step-by-step setup** — scaffold → code → test → deploy
4. **Integration with Copilot Studio templates** — how they connect
5. **Setup checklist** — tick-box before deploying

→ All component call signatures: [`../docs/COMPONENT-REGISTRY.md`](../docs/COMPONENT-REGISTRY.md)
→ Full end-to-end guide: [`../docs/END-TO-END-DEV-GUIDE.md`](../docs/END-TO-END-DEV-GUIDE.md)
→ If you're new: start with [`../docs/GETTING-STARTED.md`](../docs/GETTING-STARTED.md) first
