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

## Setup Checklist

- [ ] Copy `base/` and the components listed above into your agent project
- [ ] `settings.mcs.yml` — set `authenticationMode: ManualAzureAD`
- [ ] `agent.mcs.yml` — update `instructions` to reference the user's name: `"Address the user as {Global.UserDisplayName}"`
- [ ] Create `global-variable.variable.mcs.yml` for `Global.UserCountry` and `Global.UserDisplayName`
- [ ] `ConversationInit.topic.mcs.yml` — replace `<AGENT-SCHEMA-NAME>` with your `schemaName`; remove the Glossary block if not needed
- [ ] Add the **Office 365 Users** connector to the agent in Copilot Studio
- [ ] All topic files — replace every `_REPLACE` suffix with unique random strings
- [ ] `Fallback.topic.mcs.yml` — replace `<AGENT_SCHEMA>`
- [ ] Push to Copilot Studio and test sign-in flow in the test canvas

## Optional Additions

- Add [`knowledge-search`](../components/topics/knowledge-search/) for generative Q&A
- Add [`sharepoint`](../components/knowledge/sharepoint/) knowledge scoped to the user's region using `Global.UserCountry`
- Add connector actions that call APIs on behalf of the signed-in user
