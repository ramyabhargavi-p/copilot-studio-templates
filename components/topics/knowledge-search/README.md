# Component: Knowledge Search

Answers the user's question from the agent's knowledge sources using generative AI, when no explicit topic matches.

## When to Use

Add this component when:
- The agent has one or more knowledge sources (SharePoint, public website, etc.)
- You want unmatched questions answered generatively from those sources
- You want to replace or supplement the default Fallback topic with an intelligent search

Use this **instead of** the base `Fallback` topic if the primary job of the agent is answering questions from a knowledge base. Use it **alongside** Fallback if you want graceful handling of questions that even the knowledge base can't answer.

## File

| File | Purpose |
|------|---------|
| `KnowledgeSearch.topic.mcs.yml` | OnUnknownIntent — searches knowledge sources and generates an answer |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings |

## Prerequisites

At least one knowledge source must be added to the agent in Copilot Studio. Add a [`sharepoint`](../../knowledge/sharepoint/) or [`public-website`](../../knowledge/public-website/) knowledge source, or configure one in the Copilot Studio UI.

## How It Works

1. `CreateSearchQuery` rewrites the user's message into an optimised retrieval query (preserving conversation context)
2. `SearchAndSummarizeContent` searches all agent knowledge sources and generates a summarised answer
3. If an answer is found (`!IsBlank(Topic.Answer)`), the topic ends — Copilot Studio sends the generated response
4. If no answer is found, the topic exits silently and the `Fallback` topic handles the message next

## Customisation

### Search specific knowledge sources only
Replace the default `SearchAndSummarizeContent` with a version that targets specific sources:
```yaml
- kind: SearchAndSummarizeContent
  id: searchContent_REPLACE2
  variable: Topic.Answer
  userInput: =Topic.SearchQuery.SearchQuery
  knowledgeSources:
    kind: SearchSpecificKnowledgeSources
    knowledgeSources:
      - <AGENT_SCHEMA>.knowledge.<source-name>
```

### Suppress citations
Combine with the [`remove-citations`](../remove-citations/) component to strip `[1][2]` markers from responses.

## Gotchas

- Both this topic and `Fallback` have `priority: -1`. The topic that appears first in the agent's topic list takes precedence when priorities are equal — ensure `KnowledgeSearch` is listed before `Fallback`
- `CreateSearchQuery` uses the conversation history, so it works well for multi-turn Q&A
