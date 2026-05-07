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

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `it_helpdesk` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `IT Helpdesk` |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` |
| `settings.mcs.yml` | `authenticationMode: None` | `ManualAzureAD` if action runs as signed-in user |
| `connector-action.mcs.yml` | `<CONNECTOR_LOGICAL_NAME>` | e.g. `shared_sharepointonline` |
| `connector-action.mcs.yml` | `<OPERATION_ID>` | e.g. `CreateItem` |
| `connector-action.mcs.yml` | `<modelDescription>` | plain-English description of what the action does |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` |

Then run the `_REPLACE` script from `docs/QUICKSTART.md`.

## Copy commands

```bash
cp -r base/ agents/<your-agent>/
mkdir -p agents/<your-agent>/actions
cp components/actions/connector/connector-action.mcs.yml agents/<your-agent>/actions/<ActionName>.mcs.yml
# repeat the last line for each connector operation
# then: pac copilot push
```

## Setup Checklist

- [ ] Copy files using commands above
- [ ] Fill in all values in the table above
- [ ] Run `_REPLACE` script from `docs/QUICKSTART.md`
- [ ] Add the connector connection in Copilot Studio → Settings → Connections
- [ ] `pac copilot push --environment <ENV_URL>`
- [ ] Test by asking the agent to perform the action in natural language

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
