# Knowledge Search Topic

**Trigger:** `OnUnknownIntent` (fires when no topic matches the user's message)
**Telemetry:** `Knowledge.SearchInvoked`, `Knowledge.AnswerFound`, `Knowledge.AnswerNotFound`

Queries all configured knowledge sources and generates a grounded answer. Falls back to escalation when no answer is found.

## Files

| File | Purpose |
|------|---------|
| `KnowledgeSearch.topic.mcs.yml` | Generative answer node with found/not-found branches and telemetry |

## Quick start

```bash
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml \
   agents/<your-agent>/topics/KnowledgeSearch.topic.mcs.yml
```

**Requires:** At least one knowledge source configured in `agents/<your-agent>/knowledge/`.

**Guardrail:** Add explicit grounding instructions to `agent.mcs.yml`:
```
Only answer questions based on the knowledge sources provided.
If you cannot find the answer, say so — do not speculate.
```

→ SharePoint knowledge source: [`../../knowledge/sharepoint/README.md`](../../knowledge/sharepoint/README.md)
→ Troubleshooting hallucinated answers: [`../../../troubleshooting/README.md`](../../../troubleshooting/README.md)
