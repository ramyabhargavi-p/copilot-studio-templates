# Recipe 03 — Connector Action Agent

An agent that calls a Power Platform connector to read or write data in response to user requests.

## Use Case

- "Submit a leave request" → writes to Dataverse or SharePoint
- "What's on my calendar today?" → reads from Outlook
- "Create a support ticket" → writes to ServiceNow via a connector
- Any agent that needs to interact with a Power Platform-connected system

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
└── actions/
    └── connector/
        └── connector-action.mcs.yml        ← one file per connector operation
```

## How It Works

```
User: "I want to submit a leave request"
    │
    ▼
[GenerativeAIRecognizer] → matches a topic or GenerativeActionsEnabled routes to action
    │
    ▼
[Connector Action] — AI collects required inputs from user
    │
    ├─ Calls connector operation (e.g. CreateItem on SharePoint)
    └─ Returns response to user
```

## Setup Checklist

- [ ] Copy `base/` into your agent project
- [ ] Copy `connector-action.mcs.yml` into your agent's `actions/` folder (one copy per operation)
- [ ] `connector-action.mcs.yml` — replace all placeholders:
  - [ ] Action name in the comment header
  - [ ] `connectionReference` (e.g. `shared_sharepointonline`)
  - [ ] `operationId` (e.g. `CreateItem`)
  - [ ] `ManualTaskInput` values for fixed parameters
  - [ ] `AutomaticTaskInput` for dynamic parameters with clear `description` fields
  - [ ] `modelDisplayName` and `modelDescription` — be specific
- [ ] `settings.mcs.yml`:
  - If the connector runs as the signed-in user: set `authenticationMode: ManualAzureAD` or `IntegratedAzureAD`
  - If the connector runs as the service principal: `authenticationMode: None`, set `mode: Caller`
  - Set `GenerativeActionsEnabled: true` if you want the AI to auto-invoke the action without an explicit topic
- [ ] Add the connector connection in Copilot Studio (Settings → Connections)
- [ ] All topic files — replace every `_REPLACE` suffix with unique random strings
- [ ] Push and test — ask the agent to perform the action in natural language

## Multiple Actions

Add one `connector-action.mcs.yml` per connector operation. Rename each file descriptively:
```
actions/
├── GetLeaveBalance.mcs.yml
├── SubmitLeaveRequest.mcs.yml
└── CancelLeaveRequest.mcs.yml
```

## Optional Additions

- Add `auth` + `conversation-init` components if actions should run as the signed-in user
- Add `knowledge-search` + SharePoint knowledge for a hybrid agent that both answers questions and takes actions
