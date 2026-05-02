# Recipe 01 — Basic FAQ Agent

An agent that answers questions from a SharePoint knowledge base using generative AI.

## Use Case

- Internal knowledge base assistant (HR policies, IT runbooks, company procedures)
- First responder that deflects common questions without a human agent
- Anonymous agent — no sign-in required

## Components

```
base/
├── agent.mcs.yml
├── settings.mcs.yml
└── topics/
    ├── Greeting.topic.mcs.yml
    ├── Fallback.topic.mcs.yml          ← catches questions the knowledge base can't answer
    └── OnError.topic.mcs.yml

components/
├── topics/
│   └── knowledge-search/
│       └── KnowledgeSearch.topic.mcs.yml   ← generative answers from SharePoint
└── knowledge/
    └── sharepoint/
        └── sharepoint.knowledge.mcs.yml    ← points to your SharePoint library
```

## How It Works

```
User message
    │
    ▼
[GenerativeAIRecognizer]
    │
    ├─ Recognised intent → route to matching topic
    │
    └─ No match → KnowledgeSearch topic
                    │
                    ├─ Answer found → send generated response
                    │
                    └─ No answer → Fallback topic → retry or escalate
```

## Setup Checklist

- [ ] Copy `base/` into your agent project folder
- [ ] Copy `components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml` into your agent's `topics/` folder
- [ ] Copy `components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml` into your agent's `knowledge/` folder
- [ ] `agent.mcs.yml` — replace `<AgentName>`, `<Agent Display Name>`, update `instructions` to describe the knowledge domain
- [ ] `settings.mcs.yml` — replace `<agent_schema_name>` and `<Agent Display Name>`; leave `authenticationMode: None`
- [ ] `sharepoint.knowledge.mcs.yml` — replace the `site` URL with your SharePoint library path
- [ ] All topic files — replace every `_REPLACE` suffix with a unique random string
- [ ] `Fallback.topic.mcs.yml` — replace `<AGENT_SCHEMA>` with your `schemaName`
- [ ] Push to Copilot Studio and test with questions your knowledge base should answer

## Optional Additions

- Add [`remove-citations`](../components/topics/remove-citations/) to strip `[1][2]` markers from responses
- Add a second `sharepoint.knowledge.mcs.yml` pointing to a different library for broader coverage
- Add [`public-website`](../components/knowledge/public-website/) knowledge if some answers come from public docs
