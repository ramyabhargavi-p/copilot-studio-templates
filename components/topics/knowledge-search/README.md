# knowledge-search — Knowledge Search Topic

Adds a `Knowledge.SearchInvoked` telemetry event to the `OnUnknownIntent` hook. In Generative Orchestration mode, the AI answers from knowledge sources automatically when no topic matches — this topic adds the telemetry logging around that.

## When to use

Add to any agent that has knowledge sources so you can track when the AI is answering open-ended questions vs when users hit the Fallback topic.

| Add knowledge-search | Skip it |
|---|---|
| Agent has knowledge sources (SharePoint, web, glossary) | Agent routes only to explicit topics (no free-form Q&A) |
| You want `Knowledge.SearchInvoked` telemetry | Agents without knowledge sources |

## How it works

The `OnUnknownIntent` trigger fires when no topic matches the user's message. Two things can then handle it:
- **Fallback topic** (`base/topics/Fallback.topic.mcs.yml`) — retries up to 3× then escalates
- **This topic** — logs telemetry, then lets Generative Orchestration answer from knowledge sources

Both topics use `OnUnknownIntent`. The `priority: -1` on this topic means Fallback runs first (it has a higher default priority). If Fallback doesn't claim the conversation, this topic fires and generative AI answers from configured knowledge sources automatically.

**In Generative Orchestration mode** (`GenerativeActionsEnabled: true` in `settings.mcs.yml`), the AI answers from all configured knowledge sources without any additional nodes in this topic. You do not need to add a `GenerativeAnswers` node manually.

## Quick start

```bash
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml \
   agents/hr_assistant/topics/KnowledgeSearch.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

Only `_REPLACE1` — one node ID to replace.

## Prerequisites checklist

- [ ] `GenerativeActionsEnabled: true` in `agents/<schema>/settings.mcs.yml`
- [ ] At least one knowledge source exists in `agents/<schema>/knowledge/`
- [ ] Knowledge source is indexed (SharePoint: 5–30 min after first push)
- [ ] Grounding instructions in `agent.mcs.yml` to prevent out-of-document answers

## Grounding instructions (add to `agent.mcs.yml`)

```yaml
instructions: |
  Only answer questions based on the knowledge sources provided.
  If you cannot find the answer in the available documents, say so clearly.
  Do not speculate or invent information not found in the knowledge sources.
```

Without these, the AI may answer from its training data rather than your documents.

## Telemetry

| Event | When |
|---|---|
| `Knowledge.SearchInvoked` | Fires when `OnUnknownIntent` triggers this topic |

## Common mistakes

- **Missing `GenerativeActionsEnabled: true`** — without it, the agent doesn't use knowledge sources for AI answering even if knowledge source files are configured
- **Adding knowledge sources without grounding instructions** — AI may answer from training data (hallucination risk)
- **Not adding `remove-citations/`** — AI responses include `[1][2]` citation markers in Teams/web chat

→ Enable Generative Orchestration: `settings.mcs.yml` → `GenerativeActionsEnabled: true`
→ SharePoint knowledge source: [`../../knowledge/sharepoint/README.md`](../../knowledge/sharepoint/README.md)
→ Remove citation markers: [`../remove-citations/README.md`](../remove-citations/README.md)
