# Getting Started — Complete Guide for New Developers

This guide walks you through building and deploying a Copilot Studio agent from scratch using this template library, covering every phase: Discovery → Design → Build → Deploy.

No prior Copilot Studio experience required.

---

## What You Need Before Starting

| Prerequisite | Where to get it |
|-------------|----------------|
| Microsoft 365 / Power Platform account | Your IT admin |
| Copilot Studio licence | Your IT admin |
| Power Platform environment access | Your IT admin |
| `pac` CLI installed | [Install guide](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction) |
| VS Code + Copilot Studio extension | VS Code Marketplace: search "Copilot Studio" |
| Git installed | git-scm.com |

---

## Phase 1 — Discovery

> **Goal:** Understand what to build before writing any YAML.

### Step 1.1 — Run the requirements questionnaire
Fill in [`project-delivery/01-requirements-questionnaire.md`](project-delivery/01-requirements-questionnaire.md) with your stakeholder.

The most important questions:
- Q4: Top 5 things users will ask → these become your topics
- Q5: Top 5 out-of-scope areas → these go into `agent.mcs.yml` instructions
- Q6: Escalation path → needed for Fallback and Escalation topics
- Q7: Does it need auth? → determines `authenticationMode`
- Q9: What documents/content? → determines knowledge source paths

### Step 1.2 — Run technical discovery
Fill in [`project-delivery/02-technical-discovery.md`](project-delivery/02-technical-discovery.md) with your environment admin.

Must be confirmed before build:
- Environment name and ID
- Authentication mode
- Connector availability
- SharePoint paths with confirmed read access
- Escalation queue name (exact string)
- Application Insights workspace

### Step 1.3 — Know when you're done with Discovery
Discovery is complete when every field in the two documents above is filled in and signed off. Do not start building with open questions — they become blockers mid-build.

---

## Phase 2 — Design

> **Goal:** Map requirements to specific YAML files before writing a single line.

### Step 2.1 — Complete the design worksheet
Fill in [`project-delivery/03-agent-design-worksheet.md`](project-delivery/03-agent-design-worksheet.md).

This translates your requirements into:
- Exact component files to include
- Agent instructions (scope, out-of-scope, tone, escalation)
- Topic list with trigger phrases
- Action list with connector details
- Global variables needed
- UAT test cases

### Step 2.2 — Write the agent instructions
Use one of the system prompt templates from [`prompts/system-prompts/`](prompts/system-prompts/) as your starting point.

Or use the AI prompt in [`prompts/ai-prompts/generate-agent-instructions.md`](prompts/ai-prompts/generate-agent-instructions.md) — paste your SOW section and get a complete instructions block.

**The instructions field is the most important part of your agent.** Do not skip this step.

### Step 2.3 — Know when you're done with Design
- Design worksheet Section 9 (component checklist) is ticked
- Agent instructions are written and reviewed
- All UAT test cases in Section 10 are written
- No open questions remain from Discovery

---

## Phase 3 — Build

> **Goal:** Create the YAML files using the templates.

### Step 3.1 — Set up your project folder

```bash
# Clone this template repo
git clone <this-repo-url> copilot-studio-templates

# Create your agent project folder
mkdir my-agent
cd my-agent
git init

# Copy the base files into your agent folder
cp -r ../copilot-studio-templates/base/* .
```

Your folder should now look like:
```
my-agent/
├── agent.mcs.yml
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml
```

### Step 3.2 — Fill in the base files

**`agent.mcs.yml`:**
- Replace `<AgentName>` with the internal name from your design worksheet
- Replace `<Agent Display Name>` with the friendly name
- Replace the `instructions` block with your completed system prompt
- Update `conversationStarters`

**`settings.mcs.yml`:**
- Replace `<agent_schema_name>` with the schema name from your worksheet (lowercase, underscores)
- Replace `<Agent Display Name>`
- Set `authenticationMode` based on discovery (None / ManualAzureAD / IntegratedAzureAD)

**All topic files:**
- Replace `<AGENT_SCHEMA>` in Fallback with your `schemaName`
- Replace every `_REPLACE` suffix with a 6-character random string

> **Generating IDs:** In VS Code with the Copilot Studio extension, IDs are auto-generated on save. Or run in PowerShell:
> ```powershell
> [System.Web.Security.Membership]::GeneratePassword(6, 0)
> ```

### Step 3.3 — Add components

Copy components from `../copilot-studio-templates/components/` one at a time based on your design worksheet checklist.

**Minimum for most agents (always include):**
```bash
cp ../copilot-studio-templates/components/topics/escalation/Escalation.topic.mcs.yml topics/
```

**For agents with out-of-scope handling:**
```bash
cp ../copilot-studio-templates/components/topics/out-of-scope/OutOfScope.topic.mcs.yml topics/
```

**For agents with knowledge sources:**
```bash
cp ../copilot-studio-templates/components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml topics/
cp ../copilot-studio-templates/components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml knowledge/
cp ../copilot-studio-templates/components/topics/remove-citations/RemoveCitations.topic.mcs.yml topics/
```

**For agents with auth:**
```bash
cp ../copilot-studio-templates/components/topics/auth/SignIn.topic.mcs.yml topics/
cp ../copilot-studio-templates/components/topics/conversation-init/ConversationInit.topic.mcs.yml topics/
```

After copying each component, open it and:
1. Replace all `_REPLACE` suffixes with unique random strings
2. Replace all `<PLACEHOLDER>` values with your content
3. Replace `<AGENT_SCHEMA>` or `<AGENT-SCHEMA-NAME>` with your `schemaName`

### Step 3.4 — Build your custom topics

For each topic in your design worksheet:
1. Copy the right starting template:
   - [`components/topics/action-invoke/ActionInvoke.topic.mcs.yml`](components/topics/action-invoke/ActionInvoke.topic.mcs.yml) — if the topic calls an action
   - [`components/topics/question-branch/QuestionBranch.topic.mcs.yml`](components/topics/question-branch/QuestionBranch.topic.mcs.yml) — if the topic collects input and branches
2. Rename the file: `<TopicName>.topic.mcs.yml` (e.g. `GetLeaveBalance.topic.mcs.yml`)
3. Fill in trigger phrases, messages, and any action references
4. Or use the AI prompt: [`prompts/ai-prompts/generate-topic.md`](prompts/ai-prompts/generate-topic.md)

### Step 3.5 — Build your actions

For each connector action in your design worksheet:
1. Copy [`components/actions/connector/connector-action.mcs.yml`](components/actions/connector/connector-action.mcs.yml)
2. Rename: `<ActionName>.mcs.yml`
3. Fill in `connectionReference`, `operationId`, inputs, `modelDisplayName`, `modelDescription`

### Step 3.6 — Push to Copilot Studio and do a smoke test

```bash
# Authenticate to your environment
pac auth create --environment <environment-id>

# Push your agent files
pac copilot push --environment <environment-id>
```

Open Copilot Studio → find your agent → open the test canvas → run 3-5 test conversations.

Check:
- [ ] Greeting fires
- [ ] At least one main topic works
- [ ] Error topic shows details in test mode (send an invalid input intentionally)
- [ ] Fallback fires after 3 unrecognised messages

---

## Phase 4 — Deploy

> **Goal:** Move from working local build to published production agent.

### Step 4.1 — Run the AI audit

Use [`prompts/ai-prompts/review-agent.md`](prompts/ai-prompts/review-agent.md) — paste all your YAML files and run the full audit prompt.

Fix every CRITICAL item before proceeding.

### Step 4.2 — Run the pre-publish checklist

Work through [`BEST-PRACTICES.md`](BEST-PRACTICES.md) Section 11 (Testing Checklist).

Every checkbox should be ticked before publishing.

### Step 4.3 — UAT

Run the test cases from your design worksheet Section 10 with the project stakeholder.

| UAT pass criteria |
|------------------|
| All main topic test cases pass |
| Out-of-scope redirect correct |
| Escalation handoff works in target channel |
| Error message is safe (no internal details) in production mode |
| Knowledge search returns relevant answers |
| Stakeholder signs off |

### Step 4.4 — Publish

In Copilot Studio:
1. Open your agent
2. Click **Publish** (top right)
3. Wait for publish to complete
4. Test the published version (not the draft) in the target channel

### Step 4.5 — Configure monitoring

In Application Insights, set up alerts for:
- `Agent.ErrorOccurred` > 5 per hour → page on-call
- `Agent.FallbackTriggered` rate > 30% → review content gaps
- `Action.Failed` rate > 5% → review connector reliability

### Step 4.6 — Handover

Provide the agent owner with:
- Link to this repository (for future component additions)
- Link to the Application Insights dashboard
- The alert thresholds configured
- The design worksheet (documents what was built and why)
- Instructions for how to publish updates (`pac copilot push` → review → publish)

---

## Quick Reference Card

| Phase | Document | Output |
|-------|----------|--------|
| Discovery | `project-delivery/01-requirements-questionnaire.md` | Signed requirements |
| Discovery | `project-delivery/02-technical-discovery.md` | Confirmed tech setup |
| Design | `project-delivery/03-agent-design-worksheet.md` | Component list + instructions + UAT cases |
| Build | `base/` + `components/` templates | YAML files |
| Build | `prompts/system-prompts/` | Agent instructions |
| Build | `prompts/ai-prompts/generate-topic.md` | Topic YAML |
| Deploy | `prompts/ai-prompts/review-agent.md` | Audit report |
| Deploy | `BEST-PRACTICES.md` Section 11 | Testing checklist |

## Common Mistakes by New Developers

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Skipping out-of-scope in instructions | Agent answers questions it shouldn't | Use system prompt template — it includes out-of-scope section |
| Not adding Escalation topic | Fallback crashes (references `topic.Escalate` that doesn't exist) | Always add `escalation` component |
| Using `_REPLACE` IDs as-is | Agent fails to validate/push | Replace every `_REPLACE` suffix with a unique 6-char string |
| Not checking action outputs for blank | Agent sends blank response on connector failure | Use `action-invoke` template — it has ConditionGroup built in |
| Publishing without testing error handling | Production users see raw error messages | Always test with `InTestMode` and verify prod mode shows safe message |
| Forgetting date context in instructions | AI gives wrong answers to date-relative questions | Add `Date: {Text(Today(),DateTimeFormat.LongDate)}` to top of instructions |
