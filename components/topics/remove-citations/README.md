# Remove Citations Topic

**Trigger:** `OnGeneratedResponse` (fires after every AI-generated response)

Strips `[1]` `[2]` citation markers from generative AI responses. Add this topic whenever citation markers in responses would confuse users or look unprofessional.

## Files

| File | Purpose |
|------|---------|
| `RemoveCitations.topic.mcs.yml` | Intercepts generated responses and removes citation markers |

## Quick start

```bash
cp components/topics/remove-citations/RemoveCitations.topic.mcs.yml \
   agents/<your-agent>/topics/RemoveCitations.topic.mcs.yml
```

No configuration needed — it strips any `[N]` pattern from the generated text automatically.

**When to add:** If knowledge search answers contain `[1][2]` markers in the test canvas, add this topic. It applies globally to all AI-generated responses in the agent.
