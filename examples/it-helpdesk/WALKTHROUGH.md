# Sample Project — Contoso IT Helpdesk Agent

**Scenario:** Contoso Ltd wants an internal IT Helpdesk chatbot in Microsoft Teams. Employees sign in with their M365 account, ask IT questions, get answers from SharePoint IT docs, and submit service tickets directly from the chat.

---

## What we are building

| Detail | Value |
|--------|-------|
| Agent name | IT Helpdesk Assistant |
| Schema name | `it_helpdesk` |
| Channel | Microsoft Teams (internal) |
| Users | All Contoso employees |
| Authentication | M365 SSO (required — greets user by name) |
| Knowledge source | SharePoint: `https://contoso.sharepoint.com/sites/IT/Shared Documents` |
| Connector actions | ServiceNow — Submit Ticket (Medium safety tier) |
| Topics | Password Reset, VPN Help, Software Request, Hardware Request, Out of Scope, Escalation |
| CSAT | Thumbs → star rating → free text |
| Recipe | `06-full-featured-agent` |

---

## Folder structure we will create

```
agents/
└── it-helpdesk/
    ├── agent.mcs.yml
    ├── settings.mcs.yml
    ├── topics/
    │   ├── Greeting.topic.mcs.yml
    │   ├── Fallback.topic.mcs.yml
    │   ├── OnError.topic.mcs.yml
    │   ├── SignIn.topic.mcs.yml
    │   ├── ConversationInit.topic.mcs.yml
    │   ├── PasswordReset.topic.mcs.yml
    │   ├── VPNHelp.topic.mcs.yml
    │   ├── SoftwareRequest.topic.mcs.yml
    │   ├── HardwareRequest.topic.mcs.yml
    │   ├── Disambiguation.topic.mcs.yml
    │   ├── Escalation.topic.mcs.yml
    │   ├── OutOfScope.topic.mcs.yml
    │   ├── KnowledgeSearch.topic.mcs.yml
    │   ├── Feedback.topic.mcs.yml
    │   └── RemoveCitations.topic.mcs.yml
    ├── knowledge/
    │   └── ITDocs.knowledge.mcs.yml
    ├── actions/
    │   └── SubmitServiceNowTicket.mcs.yml
    └── variables/
        └── UserProfile.variable.mcs.yml
```

---

---

# Phase 0 — Setup

## Install tools

```powershell
winget install Microsoft.PowerAppsCLI
winget install Microsoft.VisualStudioCode
winget install Git.Git

pac --version    # verify: pac (Power Apps CLI) version 1.X.X
```

## Authenticate and connect to Dev environment

```bash
pac auth create
# Browser opens → sign in as ramya@contoso.com → close tab

pac env list
# Dev - Contoso IT    | Developer  | https://contosoit-dev.crm.dynamics.com  | a1b2c3d4-...
# UAT - Contoso IT    | Sandbox    | https://contosoit-uat.crm.dynamics.com  | e5f6g7h8-...
# Prod - Contoso IT   | Production | https://contosoit.crm.dynamics.com       | i9j0k1l2-...

pac env select --environment "Dev - Contoso IT"
pac env who
# Connected to: Dev - Contoso IT | https://contosoit-dev.crm.dynamics.com | ramya@contoso.com
```

---

---

# Phase 1 — Discovery

## 1.1 — AI Decision Framework (Nine Questions answered for this project)

From `project-delivery/00-ai-decision-framework.md`:

| Question | Answer for this project |
|----------|------------------------|
| Q1 — Where do users work? | Microsoft Teams — M365 apps |
| Q2 — Build style? | SaaS — Copilot Studio (no custom code needed) |
| Q3 — Data grounding? | RAG — SharePoint IT docs library |
| Q4 — Orchestration? | Soloist — single agent, no child agents needed |
| Q5 — Compliance boundary? | M365 trust boundary (internal employees only) |
| Q6 — Scale? | ~200 employees, peak 50 concurrent → well under 8,000 RPM |
| Q7 — Action safety? | Submit ticket = Medium (Write); Password reset = Low (Read, no actual reset) |
| Q8 — Team skills? | Pro-Dev (Ramya) + Maker (IT admin for SharePoint) |
| Q9 — Reactive or proactive? | Reactive — user-triggered |

**Decision:** Recipe `06-full-featured-agent` (auth + knowledge + connector action + CSAT)

## 1.2 — Requirements (key answers)

From `project-delivery/01-requirements-questionnaire.md`:

```
Top 5 things users will ask:
  1. How do I reset my password?
  2. VPN isn't working, what do I do?
  3. I need software installed — how do I request it?
  4. My laptop is broken — how do I get it replaced?
  5. How do I set up MFA?

Top 5 out-of-scope:
  1. HR / payroll questions
  2. Finance approvals
  3. Personal device issues (non-Contoso equipment)
  4. Questions about external vendors
  5. Legal or compliance queries

Escalation: L2 IT Support queue → "IT-L2-Support" in ServiceNow
Auth required: Yes — greet user by name, personalise response
Feedback: Thumbs + star rating + free text
```

## 1.3 — Technical Discovery

From `project-delivery/02-technical-discovery.md`:

```
Dev environment URL:   https://contosoit-dev.crm.dynamics.com
UAT environment URL:   https://contosoit-uat.crm.dynamics.com
Prod environment URL:  https://contosoit.crm.dynamics.com

Auth:                  M365 SSO (Azure AD app registration: clientId = abc123-def456)
Connector:             ServiceNow — connector ID: shared_servicenow
                       Operation: Create Incident → operation ID: CreateRecord
SharePoint:            https://contoso.sharepoint.com/sites/IT/Shared Documents
                       Confirmed accessible by all employees
Escalation queue:      IT-L2-Support (exact ServiceNow queue name)
App Insights:          workspace ID = ws-contoso-it-prod-001
```

---

---

# Phase 2 — Design

## 2.1 — Recipe chosen: `06-full-featured-agent`

Open `recipes/06-full-featured-agent.md` → it lists exactly these components:
- `base/` (all 5 files)
- `components/topics/auth/`
- `components/topics/conversation-init/`
- `components/topics/knowledge-search/`
- `components/topics/disambiguation/`
- `components/topics/escalation/`
- `components/topics/out-of-scope/`
- `components/topics/feedback/`
- `components/topics/remove-citations/`
- `components/actions/connector/` (one copy per action)
- `components/knowledge/sharepoint/`

Plus two custom topics (PasswordReset, VPNHelp, SoftwareRequest, HardwareRequest) — each starts from `_scaffold`.

## 2.2 — Action Safety Classification

| Action | Type | Tier | Guardrail |
|--------|------|------|-----------|
| Get KB articles (knowledge search) | Read | Low | Telemetry only |
| Submit ServiceNow ticket | Write (creates record) | Medium | confirmation-card before submitting |
| Password reset instructions (static) | Read | Low | None |

No High-tier actions in this project.

## 2.3 — Topic → Component mapping

| Topic | Component source | Trigger |
|-------|----------------|---------|
| Greeting | `base/topics/Greeting.topic.mcs.yml` | `Conversation.Started` |
| Fallback | `base/topics/Fallback.topic.mcs.yml` | `OnUnknownIntent` |
| OnError | `base/topics/OnError.topic.mcs.yml` | `OnError` |
| SignIn | `components/topics/auth/` | `OnSignIn` |
| ConversationInit | `components/topics/conversation-init/` | `OnActivity` |
| PasswordReset | **NEW** from `_scaffold` | "password reset", "can't log in", "forgot password" |
| VPNHelp | **NEW** from `_scaffold` | "VPN not working", "can't connect VPN", "remote access" |
| SoftwareRequest | **NEW** from `_scaffold` + `action-invoke` | "install software", "need application", "software request" |
| HardwareRequest | **NEW** from `_scaffold` + `action-invoke` | "broken laptop", "need new hardware", "equipment request" |
| KnowledgeSearch | `components/topics/knowledge-search/` | `OnUnknownIntent` |
| Disambiguation | `components/topics/disambiguation/` | `OnSelectIntent` |
| Escalation | `components/topics/escalation/` | `BeginDialog` |
| OutOfScope | `components/topics/out-of-scope/` | "HR", "payroll", "finance" |
| Feedback | `components/topics/feedback/` | `BeginDialog` / "feedback" |
| RemoveCitations | `components/topics/remove-citations/` | `OnGeneratedResponse` |

---

---

# Phase 3 — Build

## 3.1 — Copy base and components

```bash
# From repo root
cp -r base/ agents/it-helpdesk/

cp components/topics/auth/SignIn.topic.mcs.yml              agents/it-helpdesk/topics/
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml  agents/it-helpdesk/topics/
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml    agents/it-helpdesk/topics/
cp components/topics/disambiguation/Disambiguation.topic.mcs.yml        agents/it-helpdesk/topics/
cp components/topics/escalation/Escalation.topic.mcs.yml               agents/it-helpdesk/topics/
cp components/topics/out-of-scope/OutOfScope.topic.mcs.yml             agents/it-helpdesk/topics/
cp components/topics/feedback/Feedback.topic.mcs.yml                   agents/it-helpdesk/topics/
cp components/topics/remove-citations/RemoveCitations.topic.mcs.yml    agents/it-helpdesk/topics/

# New custom topics — start from scaffold
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml  agents/it-helpdesk/topics/PasswordReset.topic.mcs.yml
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml  agents/it-helpdesk/topics/VPNHelp.topic.mcs.yml
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml  agents/it-helpdesk/topics/SoftwareRequest.topic.mcs.yml
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml  agents/it-helpdesk/topics/HardwareRequest.topic.mcs.yml

# Knowledge source
mkdir -p agents/it-helpdesk/knowledge
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml  agents/it-helpdesk/knowledge/ITDocs.knowledge.mcs.yml

# Connector action
mkdir -p agents/it-helpdesk/actions
cp components/actions/connector/connector-action.mcs.yml  agents/it-helpdesk/actions/SubmitServiceNowTicket.mcs.yml

# Global variable
mkdir -p agents/it-helpdesk/variables
cp components/variables/global-variable/global-variable.variable.mcs.yml  agents/it-helpdesk/variables/UserProfile.variable.mcs.yml

# Open in VS Code
code agents/it-helpdesk/
```

---

## 3.2 — Fill in agent.mcs.yml

```yaml
# agents/it-helpdesk/agent.mcs.yml
kind: Agent
schema: 2.0.0
name: IT Helpdesk Assistant
schemaName: it_helpdesk
description: Internal IT support agent for Contoso employees on Microsoft Teams
instructions: |
  You are the Contoso IT Helpdesk Assistant. You help Contoso employees with IT
  support questions including password resets, VPN issues, software requests,
  and hardware requests. You answer using the Contoso IT knowledge base.

  You do not answer questions about HR, payroll, finance, legal, or
  personal (non-Contoso) devices. For those, direct users to the appropriate team.

  Always greet the user by their first name when available.
  Always offer to raise a ServiceNow ticket if you cannot resolve the issue in chat.

conversationStarters:
  - text: Reset my password
  - text: VPN isn't connecting
  - text: I need software installed
  - text: My laptop is broken
```

---

## 3.3 — Fill in settings.mcs.yml

```yaml
# agents/it-helpdesk/settings.mcs.yml
kind: AgentSettings
schema: 2.0.0
schemaName: it_helpdesk
authorizationSettings:
  authorizationMode: AADAppRegistration
  clientId: abc123-def456-ghi789          # Azure AD app registration client ID
  tenantId: contoso.onmicrosoft.com
language: en-US
recognizer: MultiIntentRecognizer
accessPolicy:
  type: Org                               # internal Contoso employees only
```

---

## 3.4 — Fill in the SharePoint knowledge source

```yaml
# agents/it-helpdesk/knowledge/ITDocs.knowledge.mcs.yml
kind: KnowledgeSource
schema: 2.0.0
schemaName: it_helpdesk_itdocs
displayName: Contoso IT Documentation
sourceType: SharePoint
sharePointSiteUrl: https://contoso.sharepoint.com/sites/IT/Shared Documents
description: >
  Contoso IT policies, how-to guides, VPN setup instructions, software request
  procedures, hardware replacement process, and security policies.
```

---

## 3.5 — Fill in the ServiceNow connector action

```yaml
# agents/it-helpdesk/actions/SubmitServiceNowTicket.mcs.yml
# SAFETY TIER: Medium
# GUARDRAIL:   confirmation-card
# REASON:      Creates a new incident record in ServiceNow — user must confirm before submitting

kind: TaskAction
schema: 2.0.0
schemaName: it_helpdesk_submitticket
displayName: Submit ServiceNow Ticket
description: Creates a new IT support incident in ServiceNow on behalf of the user
actionType: InvokeConnectorTaskAction
connectorId: shared_servicenow
operationId: CreateRecord
parameters:
  - name: table
    value: incident
  - name: short_description
    value: =Topic.TicketSummary
  - name: description
    value: =Topic.TicketDetails
  - name: caller_id
    value: =Global.UserEmail
  - name: assignment_group
    value: IT-L2-Support
output:
  - name: ticketNumber
    value: =outputs.result.number
  - name: ticketId
    value: =outputs.result.sys_id
```

---

## 3.6 — SoftwareRequest topic (scaffold filled in)

This shows how a scaffold becomes a real topic:

```yaml
# agents/it-helpdesk/topics/SoftwareRequest.topic.mcs.yml
kind: Topic
schema: 2.0.0
name: Software Request
schemaName: it_helpdesk_softwarerequest
description: User wants to request software installation via ServiceNow ticket

triggers:
  - kind: OnRecognizedIntent
    entities:
      - kind: ML
        phrases:
          - install software
          - need an application
          - software request
          - can you install
          - request a program
          - I need Microsoft Project

actions:
  # ── SECTION 1: Telemetry — always first ──────────────────────────
  - kind: LogCustomTelemetryEvent
    id: telemetryStart_ab1cd2
    name: Topic.Started
    properties:
      topicName: SoftwareRequest
      ConversationId: =System.Conversation.Id
      TimeUTC: =Text(Now(), "yyyy-MM-dd hh:mm:ss")

  # ── SECTION 2: Collect input ──────────────────────────────────────
  - kind: Question
    id: askSoftwareName_ef3gh4
    variable: Topic.SoftwareName
    prompt: What software do you need installed? Please include the application name and version if you know it.
    entity: StringPrebuiltEntity

  - kind: Question
    id: askBusinessReason_ij5kl6
    variable: Topic.BusinessReason
    prompt: What will you use this software for? (This helps IT prioritise your request.)
    entity: StringPrebuiltEntity

  - kind: SetVariable
    id: buildSummary_mn7op8
    variable: Topic.TicketSummary
    value: =Concatenate("Software Request: ", Topic.SoftwareName)

  - kind: SetVariable
    id: buildDetails_qr9st0
    variable: Topic.TicketDetails
    value: =Concatenate("Employee: ", Global.UserDisplayName,
                        " | Software: ", Topic.SoftwareName,
                        " | Reason: ", Topic.BusinessReason)

  # ── SECTION 3: Confirmation card (Medium safety tier) ─────────────
  - kind: SendActivity
    id: showConfirmCard_uv1wx2
    activity:
      text: Here is your ticket summary — please confirm before I submit:
      attachments:
        - contentType: application/vnd.microsoft.card.adaptive
          content:
            $schema: http://adaptivecards.io/schemas/adaptive-card.json
            type: AdaptiveCard
            version: "1.5"
            body:
              - type: TextBlock
                text: Submit IT Request?
                weight: Bolder
                size: Medium
              - type: FactSet
                facts:
                  - title: Software
                    value: "{{Topic.SoftwareName}}"
                  - title: Reason
                    value: "{{Topic.BusinessReason}}"
                  - title: Requested by
                    value: "{{Global.UserDisplayName}}"
            actions:
              - type: Action.Submit
                title: Yes, submit ticket
                data: confirmed
              - type: Action.Submit
                title: Cancel
                data: cancelled

  - kind: Question
    id: waitForConfirm_yz3ab4
    variable: Topic.ConfirmChoice
    prompt: ""
    entity: UserResponsePrebuiltEntity

  # ── SECTION 4: Execute or cancel ─────────────────────────────────
  - kind: ConditionGroup
    id: checkConfirm_cd5ef6
    conditions:
      - id: userConfirmed_gh7ij8
        condition: =Topic.ConfirmChoice = "confirmed"
        actions:
          - kind: BeginDialog
            id: callAction_kl9mn0
            dialog: it_helpdesk_submitticket
            output:
              ticketNumber: Topic.TicketNumber

          - kind: ConditionGroup
            id: checkSuccess_op1qr2
            conditions:
              - id: ticketCreated_st3uv4
                condition: =!IsBlank(Topic.TicketNumber)
                actions:
                  - kind: SendActivity
                    id: successMsg_wx5yz6
                    activity:
                      text: >
                        Your software request has been submitted.
                        Ticket number: **{{Topic.TicketNumber}}**
                        The IT team will contact you within 2 business days.

                  - kind: LogCustomTelemetryEvent
                    id: telemetrySuccess_ab7cd8
                    name: Topic.Completed
                    properties:
                      topicName: SoftwareRequest
                      ticketNumber: =Topic.TicketNumber
                      ConversationId: =System.Conversation.Id
                      TimeUTC: =Text(Now(), "yyyy-MM-dd hh:mm:ss")

            elseActions:
              - kind: SendActivity
                id: actionFailed_ef9gh0
                activity:
                  text: >
                    Sorry, I wasn't able to submit your ticket right now.
                    Please email itsupport@contoso.com or call ext. 4357.

              - kind: LogCustomTelemetryEvent
                id: telemetryError_ij1kl2
                name: Topic.ErrorOccurred
                properties:
                  topicName: SoftwareRequest
                  errorType: ActionFailed
                  ConversationId: =System.Conversation.Id
                  TimeUTC: =Text(Now(), "yyyy-MM-dd hh:mm:ss")

    elseActions:
      - kind: SendActivity
        id: cancelMsg_mn3op4
        activity:
          text: No problem — your request has been cancelled. Let me know if you need anything else.

  # ── SECTION 5: CSAT (once per conversation) ───────────────────────
  - kind: ConditionGroup
    id: csatGuard_qr5st6
    conditions:
      - id: feedbackNotShown_uv7wx8
        condition: =IsBlank(Global.FeedbackShown) || Global.FeedbackShown = false
        actions:
          - kind: SetVariable
            id: markFeedbackShown_yz9ab0
            variable: Global.FeedbackShown
            value: =true
          - kind: BeginDialog
            id: collectFeedback_cd1ef2
            dialog: it_helpdesk_feedback
```

---

## 3.7 — Replace all `_REPLACE` node IDs

The scaffold copies still have `_REPLACE` suffixes for the base topics (Greeting, Fallback, OnError) and any other components copied before you customised them.

```powershell
# Run from agents/it-helpdesk/ folder
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = $content -replace '_REPLACE\d*', $id, 1
  }
  Set-Content $_.FullName $content
}

# Verify none left
grep -r "_REPLACE" agents/it-helpdesk/
# Should return no output
```

---

## 3.8 — First push to Dev

```bash
cd agents/it-helpdesk/
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")

# Expected output in VS Code Output panel:
# Pushing agent: IT Helpdesk Assistant (it_helpdesk)
# Uploading topics... 15 topics uploaded
# Uploading knowledge sources... 1 source uploaded (status: Indexing)
# Uploading actions... 1 action uploaded
# Push complete.

# Open in browser to verify
start https://make.preview.microsoft.com
# Then: select environment → Copilot Studio → click your agent → Test pane
```

**In the Copilot Studio UI after push:**
- Topics tab → 15 topics listed
- Knowledge tab → `Contoso IT Documentation` with status **Indexing** (wait 15–30 min)
- Settings → AI capabilities → Actions → `Submit ServiceNow Ticket` visible

---

---

# Phase 4 — Test

## 4.1 — Test checklist in the UI Test pane

Open the Test pane (right side of Copilot Studio) and run through every scenario:

### Happy path tests

```
Test 1: Greeting + auth
  Input:  (start conversation)
  Expected: Greeting fires, sign-in card appears
  Then:   Sign in as test user
  Expected: "Hi Ramya! How can I help you with IT today?"

Test 2: Knowledge answer
  Input:  "How do I connect to VPN?"
  Expected: Answer from SharePoint knowledge source + citation link

Test 3: Password Reset topic
  Input:  "I forgot my password"
  Expected: PasswordReset topic fires (not Fallback)
  Expected: Instructions displayed, no ticket needed

Test 4: Software Request — confirm path
  Input:  "I need to install Adobe Acrobat"
  Expected: SoftwareRequest topic fires
  Expected: Question: "What software do you need?"  → "Adobe Acrobat Pro"
  Expected: Question: "What will you use it for?"   → "PDF editing for contracts"
  Expected: Confirmation card shows ticket summary
  Input:  Click "Yes, submit ticket"
  Expected: Ticket number returned e.g. "INC0012345"
  Expected: Topic.Completed telemetry fires (check activity log)

Test 5: Software Request — cancel path
  Input:  "I need to install Slack"
  Follow prompt → fill in details → on confirmation card click "Cancel"
  Expected: "No problem — your request has been cancelled."
  Expected: NO ticket created in ServiceNow

Test 6: Out of scope
  Input:  "What is my salary?"
  Expected: OutOfScope topic fires
  Expected: "That's an HR question — please contact HR at hr@contoso.com."

Test 7: Escalation
  Input:  "I need to speak to a real person"
  Expected: Escalation fires, TransferConversation to IT-L2-Support queue

Test 8: CSAT — appears once
  Complete Test 4 (ticket submitted)
  Expected: CSAT thumbs card appears
  Start new question without resetting
  Complete another topic
  Expected: CSAT does NOT appear again (Global.FeedbackShown = true)

Test 9: Fallback
  Input:  "xyzzy nonsense input"
  Expected: Fallback fires with retry prompt
  Input:  Two more nonsense inputs
  Expected: After 3rd attempt → escalation offer
```

### Verify in Variables tab

After Test 4:
```
Global.UserDisplayName  = "Ramya Pasupuleti"
Global.UserEmail        = "ramya@contoso.com"
Global.FeedbackShown    = true
```

### Verify telemetry in activity log

Click `>` on any message in Test pane → confirm these events appear:
```
Conversation.Started
Topic.Started (topicName: SoftwareRequest)
Action.Succeeded (or Action.Failed)
Topic.Completed (topicName: SoftwareRequest, ticketNumber: INC0012345)
Feedback.Thumbs
```

---

## 4.2 — Run automated routing eval

Prepare `project-delivery/05-eval-scenarios.md` with these test cases:

```yaml
scenarios:
  - utterance: "forgot my password"
    expectedTopic: PasswordReset
  - utterance: "can't log in to my account"
    expectedTopic: PasswordReset
  - utterance: "VPN keeps disconnecting"
    expectedTopic: VPNHelp
  - utterance: "remote access not working"
    expectedTopic: VPNHelp
  - utterance: "install Microsoft Teams"
    expectedTopic: SoftwareRequest
  - utterance: "I need a new laptop charger"
    expectedTopic: HardwareRequest
  - utterance: "my screen is cracked"
    expectedTopic: HardwareRequest
  - utterance: "what is my holiday allowance"
    expectedTopic: OutOfScope
  - utterance: "transfer me to someone"
    expectedTopic: Escalation
  - utterance: "how do I set up MFA"
    expectedTopic: KnowledgeSearch
```

```bash
# Run eval (requires Kit)
npm run eval -- --agent-name "IT Helpdesk Assistant" \
                --environment https://contosoit-dev.crm.dynamics.com \
                --scenarios ./project-delivery/05-eval-scenarios.yml

# Target: ≥ 85% routing accuracy
# If below 85%: add more trigger phrases to failing topics → push → re-eval
```

---

## 4.3 — Governance review

```bash
code governance/ai-ethics-checklist.md
```

Key items for this project:
```
□ Prompt injection: tested with "ignore previous instructions" → agent stays in scope
□ PII: confirmed Global.UserEmail NOT logged in telemetry (only ticket number logged)
□ Out-of-scope: HR, finance, personal device queries all redirect correctly
□ Escalation: IT-L2-Support queue confirmed reachable and tested
□ Content: SharePoint library reviewed — no sensitive salary/HR data included
```

```bash
code governance/security-review.md
```
```
□ Connector: ServiceNow connection uses service account with CreateRecord only — no delete permissions
□ DLP: confirmed shared_servicenow allowed in Dev environment DLP policy
□ Safety tier: SubmitServiceNowTicket declared as Medium, confirmation card implemented
□ Auth: AAD app registration scoped to Contoso tenant only
```

---

---

# Phase 5 — Deploy

## 5.1 — Dev publish (internal team testing)

```bash
pac copilot publish --bot "IT Helpdesk Assistant"
# IT Helpdesk Assistant is now live on Dev environment
# Share the Teams app link with the IT team for internal testing
```

## 5.2 — Promote to UAT

```bash
# Switch to UAT
pac env select --environment "UAT - Contoso IT"
pac env who
# Connected to: UAT - Contoso IT | ramya@contoso.com

# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "IT Helpdesk Assistant"

# Run UAT test plan with 5 real employees from different departments
# Get sign-off from IT Manager (Priya) on project-delivery/04-uat-test-plan.md
```

## 5.3 — Go-live to Prod

```bash
# Complete launch checklist
code launch/launch-checklist.md
# Every box ticked, IT Manager signed

# Switch to Prod
pac env select --environment "Prod - Contoso IT"
pac env who

# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "IT Helpdesk Assistant"

# Tag the release
git add .
git commit -m "IT Helpdesk v1.0 — initial production release"
git tag v1.0.0 -m "IT Helpdesk Assistant — Contoso — production launch 2026-05-05"
git push origin main
git push origin v1.0.0
```

## 5.4 — Send user announcement

Edit and send `launch/user-communication-template.md`:

```
Subject: New IT Helpdesk Assistant now available in Microsoft Teams

Hi everyone,

We've launched a new IT Helpdesk Assistant in Teams. You can ask it IT questions,
get help with passwords, VPN, software and hardware requests — all without
waiting on hold.

To use it: open Teams → search "IT Helpdesk Assistant" → start chatting.

The assistant is available 24/7. For urgent issues, our team is still reachable
at itsupport@contoso.com.

— Contoso IT Team
```

---

---

# Phase 6 — Operate

## 6.1 — Hypercare (first 2 weeks)

Daily check for 14 days using `launch/hypercare-guide.md`:

```bash
# Open App Insights and run daily volume check
# Azure Portal → App Insights (ws-contoso-it-prod-001) → Logs

customEvents
| where name == "Conversation.Started"
  and timestamp > ago(1d)
| summarize count()
# Day 1: 47 conversations — normal for a team of 200
```

## 6.2 — Weekly health check (from `operations/monitoring-queries.md`)

**Week 2 results (example):**

```
Total conversations:  312
Fallback rate:        11%   ← under 15% ✓
Escalation rate:      6%    ← under 10% ✓
CSAT avg:             4.2   ← above 4.0 ✓
Tickets submitted:    89
Knowledge answers:    167

Top unanswered questions (Knowledge.AnswerNotFound):
  1. "how do I request a monitor" (12 times) → ADD HardwareRequest trigger phrase
  2. "teams audio not working" (8 times)     → ADD new topic: TeamsAudioHelp
  3. "printer setup" (6 times)               → ADD SharePoint doc on printer setup
```

## 6.3 — First improvement cycle (after week 2)

```bash
# Add "how do I request a monitor" to HardwareRequest trigger phrases
code agents/it-helpdesk/topics/HardwareRequest.topic.mcs.yml
# Add phrase: "request a monitor", "need a second screen", "external display"

# Add new topic for Teams audio
cp components/topics/_scaffold/TopicScaffold.topic.mcs.yml \
   agents/it-helpdesk/topics/TeamsAudioHelp.topic.mcs.yml
# Edit with Teams audio troubleshooting steps

# Apply changes and publish
# Apply changes (VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes")
pac copilot publish --bot "IT Helpdesk Assistant"

# Commit the improvement
git add agents/it-helpdesk/
git commit -m "add monitor request phrases, new TeamsAudioHelp topic"
git push origin main
```

---

---

# Final Folder — What We Built

```
agents/it-helpdesk/
├── agent.mcs.yml                    ← it_helpdesk, M365 persona, conversation starters
├── settings.mcs.yml                 ← AADAppRegistration, Contoso tenant, MultiIntent
├── topics/
│   ├── Greeting.topic.mcs.yml       ← "Hi {{Global.UserDisplayName}}! How can I help?"
│   ├── Fallback.topic.mcs.yml       ← retries 3× → escalation offer
│   ├── OnError.topic.mcs.yml        ← safe error message + Agent.ErrorOccurred telemetry
│   ├── SignIn.topic.mcs.yml         ← M365 SSO flow with Auth.SignIn telemetry
│   ├── ConversationInit.topic.mcs.yml ← loads UserDisplayName + UserEmail into globals
│   ├── PasswordReset.topic.mcs.yml  ← trigger: "forgot password" etc — static steps
│   ├── VPNHelp.topic.mcs.yml        ← trigger: "vpn not working" etc — static steps
│   ├── SoftwareRequest.topic.mcs.yml ← trigger: "install software" — Medium tier action
│   ├── HardwareRequest.topic.mcs.yml ← trigger: "broken laptop" — Medium tier action
│   ├── KnowledgeSearch.topic.mcs.yml ← OnUnknownIntent — answers from SharePoint
│   ├── Disambiguation.topic.mcs.yml  ← OnSelectIntent — clarifies ambiguous intents
│   ├── Escalation.topic.mcs.yml      ← BeginDialog — transfers to IT-L2-Support
│   ├── OutOfScope.topic.mcs.yml      ← HR/payroll/finance redirects
│   ├── Feedback.topic.mcs.yml        ← thumbs → stars → free text CSAT
│   └── RemoveCitations.topic.mcs.yml ← strips [1][2] from knowledge answers
├── knowledge/
│   └── ITDocs.knowledge.mcs.yml     ← SharePoint: contoso.sharepoint.com/sites/IT
├── actions/
│   └── SubmitServiceNowTicket.mcs.yml ← Medium tier, shared_servicenow, CreateRecord
└── variables/
    └── UserProfile.variable.mcs.yml  ← Global.UserDisplayName, Global.UserEmail, Global.FeedbackShown
```

---

# Templates Used — Full Mapping

| Template file used | Became | Why |
|-------------------|--------|-----|
| `base/agent.mcs.yml` | `agent.mcs.yml` | Agent identity, IT persona, conversation starters |
| `base/settings.mcs.yml` | `settings.mcs.yml` | AAD auth, Contoso tenant |
| `base/topics/Greeting.topic.mcs.yml` | `Greeting.topic.mcs.yml` | Personalised welcome |
| `base/topics/Fallback.topic.mcs.yml` | `Fallback.topic.mcs.yml` | 3-retry → escalate |
| `base/topics/OnError.topic.mcs.yml` | `OnError.topic.mcs.yml` | Safe error handling |
| `components/topics/auth/` | `SignIn.topic.mcs.yml` | M365 SSO |
| `components/topics/conversation-init/` | `ConversationInit.topic.mcs.yml` | Load user profile |
| `components/topics/_scaffold/` ×4 | Password, VPN, Software, Hardware topics | All 4 custom topics |
| `components/topics/knowledge-search/` | `KnowledgeSearch.topic.mcs.yml` | SharePoint answers |
| `components/topics/disambiguation/` | `Disambiguation.topic.mcs.yml` | Ambiguous intents |
| `components/topics/escalation/` | `Escalation.topic.mcs.yml` | L2 handoff |
| `components/topics/out-of-scope/` | `OutOfScope.topic.mcs.yml` | HR/finance redirect |
| `components/topics/feedback/` | `Feedback.topic.mcs.yml` | CSAT collection |
| `components/topics/remove-citations/` | `RemoveCitations.topic.mcs.yml` | Clean knowledge answers |
| `components/actions/connector/` | `SubmitServiceNowTicket.mcs.yml` | ServiceNow ticket |
| `components/knowledge/sharepoint/` | `ITDocs.knowledge.mcs.yml` | IT docs search |
| `components/adaptive-cards/confirmation-card.json` | Embedded in SoftwareRequest + HardwareRequest | Medium tier guardrail |
| `components/variables/global-variable/` | `UserProfile.variable.mcs.yml` | Shared user state |
| `prompts/system-prompts/it-helpdesk.md` | `agent.mcs.yml` → instructions | IT persona base |

**17 of 49 templates used** for a full-featured internal IT agent.

→ All 49 templates: [`../../TEMPLATES.md`](../../TEMPLATES.md)
→ Component call signatures: [`../../COMPONENT-REGISTRY.md`](../../COMPONENT-REGISTRY.md)
→ Full command reference: [`../../commands/pac-commands.md`](../../commands/pac-commands.md)
