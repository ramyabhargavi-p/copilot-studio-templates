# Should We Build an AI Agent? — Decision Framework

This document guides the first decision every project must make: whether building a Copilot Studio agent is the right solution, and whether it is the right time.

Adapted from the [Microsoft AI Decision Framework](https://microsoft.github.io/Microsoft-AI-Decision-Framework/).

**Who completes this:** Business owner + project sponsor, facilitated by the developer or project manager.
**When:** Before any technical work begins — before requirements, before design, before build.

---

## Step 1 — Do You Even Need an Agent?

Before evaluating which AI tool to use, answer this question: **does this problem actually require an agent?**

| If the problem is… | Use this instead | Why |
|--------------------|-----------------|-----|
| A fixed rule-based workflow with no decisions | Deterministic code or Power Automate flow | Agents introduce non-determinism where you need certainty |
| Looking up a single static piece of information | SharePoint page, FAQ document, or intranet search | Classic retrieval is faster, cheaper, and more reliable |
| A form that collects and submits structured data | Power Apps form | No AI reasoning required |
| A scheduled process that runs without user input | Power Automate scheduled flow | Agents are conversational — not batch processors |
| A report or dashboard | Power BI | Data visualisation is not a conversational problem |

**Only proceed if the problem requires one or more of:**
- [ ] Answering questions from varied, unstructured document sources
- [ ] Guiding users through a process that varies based on their answers
- [ ] Routing requests across multiple topics or systems based on natural language input
- [ ] Providing a 24/7 self-service channel that reduces volume to a human team
- [ ] Personalising responses based on the user's context or M365 profile

If none of these apply, stop here and document the decision in your project brief.

---

## Step 2 — BXT Assessment (Business, Experience, Technology)

The Microsoft AI Decision Framework evaluates AI initiatives across three dimensions before selecting any technology. Complete all three before proceeding to tool selection.

### B — Business Viability

| Question | Answer | Notes |
|----------|--------|-------|
| What is the specific business outcome this agent delivers? | | e.g. "Reduce HR email volume by 30%" |
| Can we quantify the benefit? (cost saving, time saving, ticket deflection, revenue) | | Must be measurable |
| Does this align to an organisational strategic priority? | | Required for enterprise approval |
| What is the total cost of ownership over 12 months? (licences, build, ongoing) | | Include Copilot Studio capacity costs |
| What happens if we don't build this? | | Status quo cost justification |

**Business viability check:**
- [ ] Measurable business outcome defined
- [ ] ROI case made (even rough — "deflect 500 tickets/month at X minutes each")
- [ ] Strategic alignment confirmed with project sponsor
- [ ] Budget and licensing confirmed (see `project-delivery/10-enterprise-readiness-assessment.md`)

### X — Experience Desirability

| Question | Answer | Notes |
|----------|--------|-------|
| Who are the primary users? | | Personas — not job titles |
| What problem does it solve for them, specifically? | | Must be painful and frequent |
| Where do users currently go to solve this problem? | | Email, SharePoint, call a person |
| Will users naturally know to use an agent for this? | | Adoption risk if not |
| What is the expected adoption rate in year 1? | | Required for ROI calculation |

**Experience desirability check:**
- [ ] User problem validated (not assumed) — ideally through user interviews
- [ ] Problem is frequent enough to justify self-service (not rare edge case)
- [ ] Users have access to Teams or the target channel
- [ ] Users are comfortable with chat-based self-service

### T — Technology Feasibility

| Question | Answer | Notes |
|----------|--------|-------|
| Do we have Copilot Studio licensing? | | M365 licence or Copilot Studio capacity pack |
| Do we have the Power Platform environments set up? | | Dev, UAT, Prod — see `10-enterprise-readiness-assessment.md` |
| Is the content the agent will search available in SharePoint or a web URL? | | Knowledge source readiness |
| Do we need to connect to any backend systems? | | Connector availability, API access, auth model |
| Do we have someone who can build and maintain the agent? | | Developer + agent owner identified |

**Technology feasibility check:**
- [ ] Licensing confirmed
- [ ] Environments available
- [ ] Content/knowledge sources accessible
- [ ] Required connectors available and not blocked by DLP policy
- [ ] Developer capacity confirmed

---

## Step 3 — Complexity Classification

Use this to select the right tool. Copilot Studio is the right choice for Tier 1 and Tier 2.

| Tier | Agent behaviour | Recommended tool |
|------|----------------|-----------------|
| **Tier 1 — Informational** | Answers questions from documents. Read-only. No system writes. | **Copilot Studio** |
| **Tier 2 — Transactional** | Collects information and submits to a backend. Linear workflow with human approval. | **Copilot Studio** |
| **Tier 3 — Reasoning** | Multi-step planning, agent selects which tool or path to use based on context. | M365 Agents SDK or Azure AI Foundry |
| **Tier 4 — Autonomous** | Multi-agent collaboration, recursive self-correction, unsupervised execution. | Microsoft Foundry / Agent Framework |

**For this project, the agent is:** Tier ___

If Tier 3 or 4: this toolkit may not be the right fit. Consult with a developer experienced in Azure AI Foundry before proceeding.

---

## Step 4 — Copilot Studio vs Alternatives

If the complexity assessment says Tier 1 or 2, use this table to confirm Copilot Studio is the right tool versus the other options available.

| Criteria | Copilot Studio | M365 Copilot (no build) | Azure AI Foundry |
|----------|---------------|------------------------|-----------------|
| **Time to first working agent** | Days–weeks | Hours (configure, not build) | Weeks–months |
| **Who builds it** | Developer + maker | Maker only | Developer / AI engineer |
| **Customisation level** | High (YAML, topics, connectors) | Low (plugins and Graph Connectors only) | Very high (custom models, pipelines) |
| **Knowledge sources** | SharePoint, web, custom | M365 content only | Any (Azure AI Search) |
| **Channels** | Teams, Copilot, web, telephony, 10+ | M365 apps only | Any (custom integration) |
| **Integration with business systems** | 1,000+ Power Platform connectors | Limited | Unlimited (custom code) |
| **Licensing model** | Capacity packs or pay-as-you-go | Included in M365 Copilot licence | Consumption (Azure) |
| **Governance / DLP** | Power Platform DLP policies | M365 trust boundary | Azure landing zone |
| **Best for** | Departmental agents, business process automation, employee self-service | Extending M365 Copilot with org knowledge | Complex reasoning, high scale, custom models |

**Choose Copilot Studio when:**
- You need a custom conversational experience beyond what M365 Copilot out-of-the-box provides
- You need to connect to business systems via Power Platform connectors
- Your team includes makers or low-code developers (not only pro-code engineers)
- Time to value is weeks, not months
- The use case is departmental or organisational self-service

**Consider alternatives when:**
- The problem requires true reasoning across many steps with no human in the loop → Azure AI Foundry
- M365 Copilot with a Graph Connector or declarative agent already covers the use case → use that first (simpler, cheaper)
- Scale is very high (>100k conversations/month) → evaluate Azure AI Foundry Tier pricing

---

## Step 5 — Quick Scenarios Reference

| Your situation | Recommended path |
|---------------|-----------------|
| "We need something in one week" | Use M365 Copilot + declarative agent, or Copilot Studio with a recipe template |
| "We need a Teams-based HR FAQ bot" | Copilot Studio — `recipes/knowledge-agent/` |
| "We need to let staff submit IT tickets via chat" | Copilot Studio — `recipes/service-desk/` |
| "We need to surface our SharePoint docs in Copilot" | M365 Copilot + SharePoint Graph Connector — no build needed |
| "We need to automate a complex multi-system approval" | Copilot Studio + Power Automate flow |
| "We need a reasoning agent that plans across tools" | Azure AI Foundry (outside scope of this toolkit) |
| "We need the agent in 10+ channels including voice" | Copilot Studio multi-channel configuration |
| "We have a maker team, no pro developers" | Copilot Studio with Copilot Studio UI (not YAML) — limited customisation |

---

## Step 6 — Governance Pre-Check

Before committing to build, confirm these governance requirements are met or planned.

| Requirement | Status | Owner |
|-------------|--------|-------|
| A named **Agent Owner** is identified — a single person, not a team | | |
| Responsible AI review is scheduled (before UAT) | | |
| Data classification of agent content is understood (Public / Internal / Confidential) | | |
| DLP policy for the Power Platform environment exists | | |
| User communication plan is drafted | | |
| Incident response process is known (who to call if the agent goes wrong) | | |

See `governance/enterprise-ai-governance-framework.md` for the full governance model.

---

## Decision Record

Complete this section and include it in the project brief or SOW.

| Field | Value |
|-------|-------|
| Project name | |
| Date of assessment | |
| Completed by | |
| Reviewed by (project sponsor) | |
| Agent complexity tier | Tier 1 / 2 / 3 / 4 |
| Recommended tool | |
| **Decision** | **Proceed / Proceed with conditions / Do not proceed** |
| Conditions (if applicable) | |
| Next step | `project-delivery/01-requirements-questionnaire.md` |

### Decision justification

*(2–3 sentences summarising why this decision was reached — for the project record)*

---

## What Happens Next

If the decision is **Proceed**:

1. Complete `project-delivery/01-requirements-questionnaire.md` with the stakeholder
2. Complete `project-delivery/10-enterprise-readiness-assessment.md` (tech lead + security)
3. Begin `project-delivery/02-technical-discovery.md` (developer + environment admin)

If the decision is **Proceed with conditions**:
- Document the conditions clearly in the decision record above
- Resolve all conditions before starting design (`project-delivery/03-agent-design-worksheet.md`)

If the decision is **Do not proceed**:
- Document the alternative recommended (e.g. "use M365 Copilot Graph Connector instead")
- Save this document as the record that the assessment was completed

---

## Reference — Microsoft AI Decision Framework

This document applies the [Microsoft AI Decision Framework](https://microsoft.github.io/Microsoft-AI-Decision-Framework/) to the specific context of building with Copilot Studio.

Key principles from the framework applied here:
- **Simplicity-First:** Default to the simplest tool that meets requirements. Not every AI problem needs a custom agent.
- **BXT before technology:** Validate business viability, user experience desirability, and technical feasibility before selecting any tool.
- **Governance from day one:** Agent Owner, data classification, and DLP policy must be identified before build begins, not after.
- **Human oversight:** Users remain in control. Agents assist — they do not make decisions on behalf of users without a defined approval path.
