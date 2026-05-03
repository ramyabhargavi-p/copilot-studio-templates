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

## Values to change

| File | Find | Replace with |
|------|------|-------------|
| `agent.mcs.yml` | `<AgentName>` | e.g. `hr_assistant` |
| `agent.mcs.yml` | `<Agent Display Name>` | e.g. `HR Assistant` |
| `agent.mcs.yml` | `<SYSTEM_PROMPT>` | 2–3 sentences: what the agent does and what it won't answer |
| `settings.mcs.yml` | `<agent_schema_name>` | same as `<AgentName>` above |
| `Fallback.topic.mcs.yml` | `<AGENT_SCHEMA>` | same as `<AgentName>` above |
| `sharepoint.knowledge.mcs.yml` | `<SHAREPOINT_SITE_URL>` | your SharePoint library URL |

Then run the `_REPLACE` script from `QUICKSTART.md` to generate unique node IDs.

## Copy commands

```bash
cp -r base/ agents/<your-agent>/
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml agents/<your-agent>/topics/
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml agents/<your-agent>/knowledge/
# then: pac copilot push
```

## Setup Checklist

- [ ] Copy files using commands above
- [ ] Fill in all values in the table above
- [ ] Run `_REPLACE` script from `QUICKSTART.md`
- [ ] `pac copilot push --environment <ENV_URL>`
- [ ] Test in Copilot Studio test canvas

## Optional Additions

- Add [`remove-citations`](../components/topics/remove-citations/) to strip `[1][2]` markers from responses
- Add a second `sharepoint.knowledge.mcs.yml` pointing to a different library for broader coverage
- Add [`public-website`](../components/knowledge/public-website/) knowledge if some answers come from public docs
