# Recipe 02 — Authenticated Agent

An agent that requires users to sign in and loads their M365 profile to personalise responses.

## Use Case

- Internal agent where the user's identity matters (personalised responses, role-based access)
- Agent that calls connectors on behalf of the signed-in user (e.g. reading their own calendar or leave balance)
- Agent where you want to greet users by name and tailor responses to their region or department

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml                        ← set authenticationMode: ManualAzureAD
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   ├── auth/
│   │   └── SignIn.topic.mcs.yml            ← prompts user to sign in
│   └── conversation-init/
│       └── ConversationInit.topic.mcs.yml  ← loads M365 profile into global variables
└── variables/
    └── global-variable/
        └── global-variable.variable.mcs.yml  ← declare Global.UserCountry, Global.UserDisplayName
```

## How It Works

```
User opens conversation
    │
    ▼
[Greeting] — sends welcome message

User sends first message
    │
    ▼
[ConversationInit] fires (condition: IsBlank(Global.UserCountry))
    │
    ├─ Calls Office 365 Users API → Topic.M365Profile
    ├─ Sets Global.UserCountry
    └─ Sets Global.UserDisplayName

[SignIn] fires if auth is needed
    │
    └─ Presents OAuthInput card → user authenticates

Subsequent messages
    │
    └─ ConversationInit skipped (Global.UserCountry already set)
       Topics run with Global.UserDisplayName available
```

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | Include: `"Address the user as {Global.UserDisplayName}"` |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` |
| `settings.mcs.yml` | `authenticationMode: None` | `authenticationMode: ManualAzureAD` |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` |
| `ConversationInit.topic.mcs.yml` | `<AGENT-SCHEMA-NAME>` | same as `<AgentName>` |

Then run the `_REPLACE` script from `docs/QUICKSTART.md`.

## Copy commands

```bash
cp -r base/ agents/<your-agent>/
cp components/topics/auth/SignIn.topic.mcs.yml agents/<your-agent>/topics/
cp components/topics/conversation-init/ConversationInit.topic.mcs.yml agents/<your-agent>/topics/
cp components/variables/global-variable/global-variable.variable.mcs.yml agents/<your-agent>/
# then: pac copilot push
```

## Setup Checklist

- [ ] Copy files using commands above
- [ ] Fill in all values in the table above
- [ ] Run `_REPLACE` script from `docs/QUICKSTART.md`
- [ ] Add **Office 365 Users** connector in Copilot Studio → Settings → Connections
- [ ] `pac copilot push --environment <ENV_URL>`
- [ ] Test sign-in flow in Copilot Studio test canvas

## Optional Additions

- Add [`knowledge-search`](../components/topics/knowledge-search/) for generative Q&A
- Add [`sharepoint`](../components/knowledge/sharepoint/) knowledge scoped to the user's region using `Global.UserCountry`
- Add connector actions that call APIs on behalf of the signed-in user
