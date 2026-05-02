# Roadmap

Items not yet in this repository — documented here so they can be prioritised and contributed.

---

## Not built (by category)

### Deployment

| Item | Description | Effort |
|------|-------------|--------|
| Solution-based deployment | Package the agent in a Power Platform solution for proper ALM — environment variables, connection references, managed/unmanaged layers | High |
| Power Platform pipelines | Use the native Power Platform Pipelines feature (no GitHub required) for environment promotion | Medium |
| Dataverse import/export | Alternative deployment path via solution export/import for environments without pac CLI access | Medium |

### Integrations

| Item | Description | Effort |
|------|-------------|--------|
| Power Automate flow pattern | Template topic that triggers a Power Automate cloud flow (not a connector directly) — useful for multi-step business logic | Medium |
| SharePoint list read/write | Template for reading/writing SharePoint list items via connector — common pattern for ticket creation, status lookups | Low |
| Dataverse read/write | Template for reading/writing Dataverse tables — native Power Platform data source | Medium |

### Multi-language

| Item | Description | Effort |
|------|-------------|--------|
| Language detection topic | Detect user language from M365 profile or browser locale; set `Global.UserLanguage` | Low |
| Multi-language agent instructions | Structured `agent.mcs.yml` instructions template that serves responses in the user's language | Medium |
| Translated conversation starters | Guidance on setting up localised conversation starters | Low |

### Channels and Packaging

| Item | Description | Effort |
|------|-------------|--------|
| Teams app manifest template | `manifest.json` template for packaging a Copilot Studio agent as a custom Teams app | Low |
| Power Pages embed template | Snippet for embedding the agent on a Power Pages / SharePoint page | Low |
| SharePoint page embed | Web part configuration for SharePoint Online | Low |

### Quality and Testing

| Item | Description | Effort |
|------|-------------|--------|
| Regression test suite | Pre-defined eval CSV covering the base agent's topics (Greeting, Fallback, OnError, Escalation) — run after every publish | Low |
| Performance test guide | Guidance on load testing an agent before large rollouts | Medium |
| A/B testing pattern | Pattern for running two agent variants in parallel and comparing metrics | High |

### Governance and Operations

| Item | Description | Effort |
|------|-------------|--------|
| Center of Excellence template | Governance framework for organisations running multiple agents — naming standards, ownership model, shared component library | High |
| DLP policy reference | Recommended DLP policy configuration for Copilot Studio environments | Medium |
| Agent versioning guide | How to version agents in git, name releases, and manage breaking changes | Low |
| Quarterly review template | Structured review document: usage trends, accuracy trends, knowledge gap analysis, planned improvements | Low |
| Accessibility checklist | WCAG 2.1 / Microsoft accessibility guidelines applied to Copilot Studio agents | Medium |
| Change log template | `CHANGELOG.md` template for tracking agent changes across versions | Low |

### Developer Experience

| Item | Description | Effort |
|------|-------------|--------|
| VS Code snippets | `.code-snippets` file with shortcuts for common YAML node patterns | Low |
| Agent scaffolding script | PowerShell script that copies `base/`, prompts for agent name/schemaName, and replaces all placeholders automatically | Medium |
| Node ID batch replacer | Script that finds all `_REPLACE` suffixes in YAML files and replaces them with generated IDs | Low |

---

## Contributing

Pick any item, implement it, and open a PR. See the Contributing section in [README.md](README.md) for guidelines.

Items marked **Low effort** are good first contributions.
