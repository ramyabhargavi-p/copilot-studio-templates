# Recipe 06 — Full-Featured Agent

An agent with authentication, personalised context, generative knowledge search, a connector action, and disambiguation. The kitchen-sink starting point.

## Use Case

- Internal enterprise agent where users are identified and content is personalised
- Agent that both answers questions (from knowledge) and takes actions (via connector)
- Production-grade agent with proper error handling, telemetry, and citation management

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml                        ← authenticationMode: ManualAzureAD or IntegratedAzureAD
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml
    └── OnError.topic.mcs.yml

components/
├── topics/
│   ├── auth/
│   │   └── SignIn.topic.mcs.yml
│   ├── conversation-init/
│   │   └── ConversationInit.topic.mcs.yml
│   ├── disambiguation/
│   │   └── Disambiguation.topic.mcs.yml
│   ├── knowledge-search/
│   │   └── KnowledgeSearch.topic.mcs.yml
│   └── remove-citations/
│       └── RemoveCitations.topic.mcs.yml
├── actions/
│   └── connector/
│       └── connector-action.mcs.yml        ← one per operation
├── knowledge/
│   └── sharepoint/
│       └── sharepoint.knowledge.mcs.yml    ← one per library
└── variables/
    └── global-variable/
        ├── UserCountry.variable.mcs.yml
        └── UserDisplayName.variable.mcs.yml
```

## Conversation Flow

```
User opens conversation
    └─ [Greeting] fires → welcome message

User sends first message
    └─ [ConversationInit] fires once → loads M365 profile into Global.UserCountry, Global.UserDisplayName
    └─ [SignIn] fires if not authenticated → OAuthInput

Subsequent messages
    │
    ▼
[GenerativeAIRecognizer]
    │
    ├─ Single match → fires matched topic or connector action
    │
    ├─ Multiple matches → [Disambiguation] → user clarifies
    │
    └─ No match → [KnowledgeSearch] → generative answer from SharePoint
                        │
                        ├─ Answer found → [RemoveCitations] strips markers → clean response sent
                        └─ No answer → [Fallback] → retry or escalate

Any error → [OnError] → debug info (test) or safe message (prod) + telemetry log
```

## Setup Checklist

- [ ] Copy all components listed above into your agent project
- [ ] `settings.mcs.yml` — set `authenticationMode: ManualAzureAD` (or `IntegratedAzureAD` for Teams SSO)
- [ ] `agent.mcs.yml` — write comprehensive `instructions` referencing `{Global.UserDisplayName}` and `{Global.UserCountry}`
- [ ] `ConversationInit.topic.mcs.yml` — replace `<AGENT-SCHEMA-NAME>`; remove Glossary block if not needed
- [ ] `sharepoint.knowledge.mcs.yml` — replace `site` URL; add more copies for additional libraries
- [ ] `connector-action.mcs.yml` — replace all placeholders; rename file descriptively
- [ ] `global-variable.variable.mcs.yml` — create one file each for `UserCountry` and `UserDisplayName`; replace all `_REPLACE` values
- [ ] All topic files — replace every `_REPLACE` suffix with unique random strings
- [ ] `Fallback.topic.mcs.yml` and `Disambiguation.topic.mcs.yml` — replace `<AGENT_SCHEMA>`
- [ ] Add Office 365 Users connector in Copilot Studio (for ConversationInit)
- [ ] Add the connector for your action in Copilot Studio
- [ ] Push to Copilot Studio and run end-to-end test:
  - [ ] Sign-in flow works
  - [ ] User is greeted by name
  - [ ] Knowledge search returns answers without citation markers
  - [ ] Connector action is invoked correctly
  - [ ] Ambiguous queries trigger disambiguation
  - [ ] Unknown queries hit Fallback after 3 attempts
  - [ ] Forced error shows safe message in prod mode

## Scaling This Recipe

- Add more `connector-action.mcs.yml` files for additional operations
- Add more `sharepoint.knowledge.mcs.yml` files for additional libraries
- Evolve into the [orchestrator pattern](05-orchestrator-agent.md) by replacing the parent's domain logic with child agents
