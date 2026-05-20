# Should We Build an AI Agent? — Decision Framework

This document guides every decision before a single line of YAML is written: whether to build, what to build, how complex it is, and whether the organisation is ready.

Adapted from and expanded with the full [Microsoft AI Decision Framework](https://microsoft.github.io/Microsoft-AI-Decision-Framework/).

**Who completes this:** Business owner + AI engineer, facilitated by the project manager.
**When:** Before requirements, before design, before build. Non-negotiable.

---

## Step 1 — Do You Even Need an Agent?

Agents introduce nondeterminism, latency, and cost. Default to a simpler tool unless the problem genuinely requires one.

| If the problem is… | Use this instead | Why |
|--------------------|-----------------|-----|
| Fixed rule-based workflow, no decisions | Power Automate flow | Agents introduce nondeterminism where you need certainty |
| Looking up one static piece of information | SharePoint page, FAQ doc, or intranet search | Classic retrieval is faster and cheaper |
| A form collecting and submitting structured data | Power Apps form | No AI reasoning required |
| A scheduled batch process, no user input | Power Automate scheduled flow | Agents are conversational, not batch processors |
| A report or dashboard | Power BI | Data visualisation is not a conversational problem |
| M365 content already indexed | M365 Copilot + declarative agent | No build required — configure, not code |

**Only proceed if the problem requires one or more of:**
- [ ] Answering questions from varied, unstructured document sources
- [ ] Guiding users through a process that varies based on their answers
- [ ] Routing requests across multiple topics or systems via natural language
- [ ] Providing 24/7 self-service that reduces volume to a human team
- [ ] Personalising responses based on user context or M365 profile
- [ ] Taking write actions on behalf of the user (submit, update, create)

If none apply, stop here and document the decision.

---

## Step 2 — BXT Assessment (Business · Experience · Technology)

Validate all three dimensions before selecting any technology. Low scores in any single dimension halt progression.

### B — Business Viability

| Question | Answer | Notes |
|----------|--------|-------|
| What precise business outcome does this agent deliver? | | e.g. "Reduce HR email volume by 30%" |
| Can we quantify the benefit? | | Cost saving, time saving, ticket deflection, revenue |
| Does this align to a strategic organisational priority? | | Required for enterprise approval |
| What is the 12-month total cost of ownership? | | Licences + build time + ongoing maintenance |
| What happens if we don't build this? | | Status quo cost justification |

- [ ] Measurable outcome defined
- [ ] ROI case made (even rough)
- [ ] Strategic alignment confirmed
- [ ] Budget and licensing confirmed

### X — Experience Desirability

| Question | Answer | Notes |
|----------|--------|-------|
| Who are the primary users? | | Personas, not job titles |
| What specific problem does it solve for them? | | Must be painful and frequent |
| Where do users currently solve this problem? | | Email, SharePoint, call a person |
| Will users naturally know to use an agent for this? | | Adoption risk if not |
| What is the expected adoption rate in year 1? | | Required for ROI |

- [ ] User problem validated (ideally through interviews, not assumption)
- [ ] Problem is frequent enough to justify self-service
- [ ] Users have access to Teams or the target channel
- [ ] Users are comfortable with chat-based self-service

### T — Technology Feasibility

| Question | Answer | Notes |
|----------|--------|-------|
| Do we have Copilot Studio licensing? | | M365 licence or Copilot Studio capacity pack |
| Do we have Dev, UAT, Prod environments? | | See `01-enterprise-readiness-assessment.md` |
| Is the knowledge content in SharePoint or accessible via URL? | | Knowledge source readiness |
| Do we need backend system connections? | | Connector availability, API access, auth model |
| Do we have a developer AND a named agent owner? | | Both required — build and operate |

- [ ] Licensing confirmed
- [ ] Environments available
- [ ] Content/knowledge sources accessible and current
- [ ] Required connectors available and not blocked by DLP
- [ ] Developer capacity and agent owner confirmed

**Decision gate:** All three dimensions must score medium or high to proceed.

---

## Step 3 — Nine Critical Questions

Run these questions in order. Each answer narrows your technology and architecture choices. Document the outputs — they directly determine which recipe and components to use.

### Q1 — Where does the user experience live?

| Surface | Technology path | Copilot Studio recipe |
|---------|-----------------|-----------------------|
| Teams / M365 Copilot / Outlook | Default Copilot Studio channels | Any recipe |
| Custom web or mobile app | Direct Line channel or M365 Agents SDK | Any recipe + custom channel config |
| Headless / API-only | Service-to-service agent call | Requires M365 Agents SDK or Foundry |
| Embedded button/feature in existing app | Narrow embedded trigger | Requires custom app integration |

---

### Q2 — What is your build style?

The "Kitchen" model — start with what's already made:

| Level | Analogy | Platform | When to use |
|-------|---------|----------|------------|
| **SaaS (Dining out)** | Order off-menu | M365 Copilot + declarative agent | Content already in M365; minimal customisation |
| **Orchestration (Meal kit)** | Ingredients provided | **Copilot Studio** | Custom conversations, connectors, topics |
| **Foundation (Scratch cooking)** | Source ingredients yourself | Microsoft Foundry / M365 Agents SDK | Full control, complex reasoning, custom models |

**Rule:** Use SaaS → move to Orchestration only when SaaS can't meet requirements → move to Foundation only when Orchestration can't.

---

### Q3 — What is your data grounding pattern?

Separate three distinct concerns:

| Concern | Purpose | What to use |
|---------|---------|------------|
| **Grounding (RAG)** | Retrieve relevant content per question | SharePoint knowledge source, public website knowledge, Azure AI Search |
| **Memory** | Persist conversation state | Copilot Studio global variables + Dataverse |
| **Analytics** | Retain transcripts for review | Application Insights + 02-monitoring-queries.md |

**In this template repo:** SharePoint knowledge = Foundry IQ layer (grounding). WorkIQ = Work IQ layer (live org context).

---

### Q4 — What is your orchestration complexity?

| Pattern | What it means | Complexity tier | Recipe |
|---------|--------------|-----------------|--------|
| **Soloist** | One agent, multiple topics, tools only | Tier 1–2 | `01`, `02`, `03`, `04` |
| **Orchestra (hub-and-spoke)** | Central agent routes to specialist child agents | Tier 3 | `05` |
| **Mesh (Agent-to-Agent)** | Independent agents discover and message each other | Tier 4 | Outside scope — needs Foundry or Agent Framework |

---

### Q5 — What is your compliance trust boundary?

This determines where data travels and which compliance certifications apply.

| Boundary | Data location | Compliance | Use when |
|----------|--------------|------------|---------|
| **M365 trust boundary** | Stays within M365 tenant | Existing M365 certifications (ISO, SOC, HIPAA) | Regulated orgs needing tenant guarantees |
| **Power Platform boundary** | Core data in-region; inherits each connector's compliance | Risk inherited from third-party APIs | Standard enterprise Copilot Studio builds |
| **Azure landing zone** | Customer-controlled Azure subscription | VNet, Private Links, CMK, custom policies | Full-control orgs with strict data residency |

---

### Q6 — What is your scale and cost model?

| Model | Cost | Best for |
|-------|------|---------|
| **Capacity packs** | $200–$10k/month | Predictable Copilot Studio usage, fixed budgets |
| **Pay-as-you-go (PAYG)** | $0.01 / Copilot Credit | Pilots, experiments, variable demand |
| **Agent Commit Units (ACU / P3)** | $19k+/year | Running Copilot Studio + Foundry together |
| **Per-user M365 Copilot** | $30/user/month | Orgs already on M365 Copilot, using declarative agents |

**Scale limits to know:**
- Copilot Studio: ~**8,000 requests/minute** per environment. Above this, multi-region or Foundry required.
- Azure OpenAI: TPM quotas are **region-specific**. Design multi-region failover for mission-critical deployments.

---

### Q7 — Can the agent take destructive actions?

See Step 5 (Action Safety) for full implementation patterns. Summary:

| Safety level | Agent behaviour | Guardrail required |
|-------------|-----------------|-------------------|
| **Read-only** | Search, lookup, summarise | Audit log |
| **Write** | Submit, create, update | User confirmation before execution |
| **Destructive** | Delete, transfer, change permissions | Middleware + separate approval channel |

---

### Q8 — What are your team skills?

| Team profile | Best platform | What this means for build |
|-------------|--------------|--------------------------|
| **Makers / fusion team** | Copilot Studio + AI Builder | Use visual canvas, recipes, component library |
| **Professional developers** | M365 Agents SDK, Foundry | YAML build + pac CLI + GitHub Actions CI/CD |
| **AI / ML engineers** | Microsoft Foundry | Custom models, evals, advanced grounding |
| **Integration architects** | Logic Apps + Copilot Studio | Connector-heavy workflows, approval chains |

**Note:** Maker and pro-code are not binary. Mixed teams use Pattern 6 (progressive enhancement) — makers own the canvas, developers own complex orchestration.

---

### Q9 — Does the agent need to initiate actions?

| Behaviour | What it means | Platform |
|-----------|--------------|----------|
| **Reactive** | Waits for user to send a message | Copilot Studio (default) |
| **Proactive** | Fires on schedule, webhook, or system event | Copilot Studio + Power Automate trigger, or Foundry Agent Service |

If proactive: design the trigger in Power Automate and call the agent via the API, or use Foundry Agent Service for event-driven execution.

---

## Step 4 — Complexity Classification and Architecture Pattern

Select the tier that matches your agent's behaviour. This directly maps to a recipe.

| Tier | Behaviour | Architecture pattern | Tool | Recipe |
|------|-----------|---------------------|------|--------|
| **1 — Informational** | Questions from documents. Read-only. No system writes. | RAG / Knowledge Search | **Copilot Studio** | `01-basic-faq` |
| **2 — Transactional** | Collects input and submits to a backend. Linear workflow, human approval optional. | Orchestrated workflow | **Copilot Studio** | `02`, `03`, `04` |
| **3 — Reasoning** | Multi-step planning, agent selects tool/path based on context, multiple specialists | ReAct / Hub-and-spoke | M365 Agents SDK or Foundry | `05-orchestrator` |
| **4 — Autonomous** | Multi-agent collaboration, recursive self-correction, long-running async | Multi-agent systems | Microsoft Foundry / Agent Framework | Outside scope |

**For this project, the agent is:** Tier ___

If Tier 3 or 4: this template library may not be the right fit. Consult with a Foundry-experienced developer before proceeding.

---

## Step 5 — Action Safety Classification

**Every connector action must be classified before build starts.** This is not a post-go-live consideration.

| Tier | What the action does | Guardrail required | Copilot Studio implementation |
|------|---------------------|-------------------|-----------------------------|
| **Low — Read** | Search, look up, summarise, retrieve | Audit log (telemetry only) | Direct `InvokeConnectorTaskAction` — no card needed |
| **Medium — Write** | Create record, submit form, update status, send message | User confirmation before execution | `confirmation-card.json` → user approves → then action |
| **High — Destructive** | Delete record, transfer funds, change permissions, bulk update | Middleware + separate approval channel | `confirmation-card.json` → Power Automate approval flow → action only if approved |

### Action Safety audit table

Complete one row per planned connector action:

| Action name | What it does | Safety tier | Guardrail component | Approved by |
|-------------|-------------|-------------|--------------------|-----------| 
| | | Low / Medium / High | | |
| | | Low / Medium / High | | |

### YAML pattern — Medium (Write) with confirmation

```yaml
# Step 1: Show confirmation card before calling the action
- kind: SendActivity
  id: sendConfirmation_REPLACE
  activity:
    attachments:
      - contentType: application/vnd.microsoft.card.adaptive
        content: ${{confirmation-card.json}}   # fill in the card details

# Step 2: Capture user decision
- kind: Question
  id: waitForConfirmation_REPLACE
  variable: Topic.UserConfirmed
  prompt: ""
  entityType: UserEntireResponse

# Step 3: Branch on confirmation
- kind: ConditionGroup
  id: checkConfirmation_REPLACE
  conditions:
    - id: confirmed_REPLACE
      condition: =Topic.UserConfirmed.action = "confirm"
      actions:
        - kind: InvokeConnectorTaskAction   # call the action only if confirmed
          id: invokeWrite_REPLACE
  elseActions:
    - kind: SendActivity
      id: sendCancelled_REPLACE
      activity: Action cancelled. Let me know if you need anything else.
```

### YAML pattern — High (Destructive) with approval flow

```yaml
# Step 1: Show confirmation card
# Step 2: On confirm — call Power Automate flow that sends approval request
# Step 3: Wait for approval webhook callback before executing destructive action
# NOTE: Destructive actions should never execute inline — always use an approval flow
- kind: InvokeConnectorTaskAction
  id: triggerApprovalFlow_REPLACE
  connectorId: /providers/Microsoft.PowerApps/apis/shared_flowmanagement
  operationId: RunFlow
  parameters:
    flowId: <APPROVAL_FLOW_ID>
    requestData:
      actionDescription: <What will be deleted/changed>
      requestedBy: =Global.UserDisplayName
      conversationId: =System.Conversation.Id
```

---

## Step 6 — Experience Interaction Model

How the agent is accessed determines channel configuration in `settings.mcs.yml` and the conversation starter design.

| Model | Description | Example | Channel setting |
|-------|-------------|---------|----------------|
| **Immersive (Destination)** | User navigates to the agent — it is the destination | Standalone Teams bot, dedicated web page | Teams channel, Direct Line |
| **Assistive (Companion)** | Agent travels with the user inside their existing M365 apps | Agent surfaced in Word sidebar, Outlook, Teams chat | Declarative agent via M365 Copilot |
| **Embedded (Feature)** | Single-purpose trigger inside an existing application | "Summarise this ticket" button in ServiceNow | Direct Line API call from the app |

**For this project, the model is:** ___

---

## Step 7 — Knowledge and Intelligence Layers (IQ)

Map your data sources to the three intelligence layers before selecting knowledge components.

| Layer | What it provides | In this repo | Use when |
|-------|-----------------|-------------|---------|
| **Foundry IQ (Memory)** | Grounding — retrieve relevant content per question from static sources | `components/knowledge/sharepoint/` and `public-website/` | Agent answers from documents |
| **Work IQ (Awareness)** | Live org context — emails, meetings, Teams chats, calendar | WorkIQ via `ask_work_iq` in docs/SKILLS-REFERENCE.md | Dev needs real M365 context to fill in discovery docs; agent needs live user context |
| **Fabric IQ (Understanding)** | Business logic and semantic reasoning over structured operational data | Outside scope — requires Fabric Data Agents (Preview) | Agent needs to reason over Dataverse/SQL/OneLake data |

---

## Step 8 — Copilot Studio vs Alternatives

Use this only if Step 4 left Tier ambiguous or if stakeholders are questioning the tool choice.

| Criteria | Copilot Studio | M365 Copilot (no build) | Azure AI Foundry |
|----------|---------------|------------------------|-----------------|
| Time to first working agent | Days–weeks | Hours | Weeks–months |
| Who builds it | Developer + maker | Maker only | Developer / AI engineer |
| Customisation | High (YAML, topics, connectors) | Low (plugins + Graph Connectors) | Very high (custom models, pipelines) |
| Knowledge sources | SharePoint, web, custom | M365 content only | Any (Azure AI Search) |
| Channels | Teams, Copilot, web, telephony, 10+ | M365 apps only | Any (custom integration) |
| Integration | 1,000+ Power Platform connectors | Limited | Unlimited (custom code) |
| Governance / DLP | Power Platform DLP | M365 trust boundary | Azure landing zone |
| Best for | Departmental agents, employee self-service | Extending M365 Copilot with org knowledge | Complex reasoning, high scale, custom models |

**Choose Copilot Studio when:**
- Custom conversation beyond what M365 Copilot provides out of the box
- Backend system integration via Power Platform connectors
- Team includes makers or low-code developers
- Time to value is weeks, not months

**Move to alternatives when:**
- True multi-step reasoning with no human in the loop → Azure AI Foundry
- M365 Copilot + Graph Connector already covers the use case → use that (simpler, cheaper)
- Scale > 8,000 RPM sustained → evaluate Foundry or multi-region

---

## Step 9 — Quick Scenarios

| Your situation | Recommended path |
|---------------|-----------------|
| Need something working in one week | M365 Copilot + declarative agent, or Copilot Studio + recipe template |
| Teams-based HR FAQ bot | Copilot Studio — `01-basic-faq` |
| Staff submit IT tickets via chat | Copilot Studio — `03-connector-action-agent` |
| Surface SharePoint docs in M365 Copilot | M365 Copilot + SharePoint Graph Connector — no build |
| Complex multi-system approval workflow | Copilot Studio + Power Automate approval flow (High safety tier) |
| Reasoning agent that plans across tools | Azure AI Foundry (outside scope of this toolkit) |
| Agent in 10+ channels including voice | Copilot Studio multi-channel configuration |
| Maker team only, no pro developers | Copilot Studio UI — limited YAML customisation |

---

## Step 10 — Governance Pre-Check and Evaluation Criteria

### 10A — Governance requirements

| Requirement | Status | Owner |
|-------------|--------|-------|
| Named Agent Owner identified (a person, not a team) | | |
| Responsible AI review scheduled (before UAT) | | |
| Data classification confirmed (Public / Internal / Confidential) | | |
| DLP policy for Power Platform environment exists | | |
| User communication plan drafted | | |
| Incident response process defined (who to call if agent breaks) | | |
| All connector actions classified by Safety Tier (Step 5) | | |

### 10B — Evaluation criteria checklist (from CAF)

Complete before committing to build:

**Lifecycle**
- [ ] Technology status confirmed: GA / Preview / Deprecated
- [ ] Go-live date does not conflict with platform retirement dates
- [ ] Agent owner identified for post-launch maintenance

**Architecture**
- [ ] Complexity tier assigned (Step 4)
- [ ] Orchestration pattern selected: Soloist / Orchestra / Mesh
- [ ] Data boundaries mapped (Step 3 — Q5)
- [ ] All connector actions classified by Safety Tier (Step 5)

**Resources**
- [ ] Team capability matches platform (Step 3 — Q8)
- [ ] ALM / DevOps pipeline defined (`ci-cd/`)
- [ ] Dev, UAT, Prod environments provisioned

**Governance**
- [ ] Trust boundary confirmed (M365 / Power Platform / Azure)
- [ ] Action Safety guardrails designed for every Medium and High tier action
- [ ] DLP policy applied to environment

**Budget**
- [ ] Cost model selected (capacity packs / PAYG / ACU)
- [ ] Monthly spend estimate documented
- [ ] Azure Cost Management alerts configured (if using metered consumption)

See `governance/01-enterprise-ai-governance-framework.md` for the full model.

---

## Decision Record

| Field | Value |
|-------|-------|
| Project name | |
| Date of assessment | |
| Completed by | |
| Reviewed by (project sponsor) | |
| Complexity tier | Tier 1 / 2 / 3 / 4 |
| Orchestration pattern | Soloist / Orchestra / Mesh |
| Experience model | Immersive / Assistive / Embedded |
| Trust boundary | M365 / Power Platform / Azure |
| Cost model | Capacity packs / PAYG / ACU |
| Highest action safety tier | Low / Medium / High |
| Recommended tool | |
| **Decision** | **Proceed / Proceed with conditions / Do not proceed** |
| Conditions (if applicable) | |
| Next step | `project-delivery/02-requirements-questionnaire.md` |

### Decision justification

*(2–3 sentences summarising why this decision was reached)*

---

## What Happens Next

**Proceed:**
1. Complete `02-requirements-questionnaire.md` with the stakeholder
2. Complete `01-enterprise-readiness-assessment.md` (tech lead + security)
3. Begin `03-technical-discovery.md` (developer + environment admin)

**Proceed with conditions:**
- Document the conditions in the Decision Record above
- Resolve all conditions before starting design (`05-agent-design-worksheet.md`)

**Do not proceed:**
- Document the alternative (e.g. "use M365 Copilot Graph Connector instead")
- Save this document as the completed assessment record

---

## Reference

Source: [Microsoft AI Decision Framework](https://microsoft.github.io/Microsoft-AI-Decision-Framework/)

Key principles applied in this document:
- **Simplicity-First:** Default to the simplest tool. SaaS → Orchestration → Foundation.
- **BXT before technology:** Business viability, experience desirability, technical feasibility — all three before any tool is selected.
- **Action Safety by design:** Every action classified before build. Never designed retrospectively.
- **Governance from day one:** Agent Owner, data classification, DLP, and trust boundary confirmed before build begins.
- **Human oversight:** Agents assist — they do not make irreversible decisions without a defined approval path.
- **Composability over monoliths:** Specialised agents that delegate are more robust than a single agent doing everything.
